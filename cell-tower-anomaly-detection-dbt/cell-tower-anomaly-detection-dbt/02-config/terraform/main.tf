# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 

variable "project_id" { type = string}
variable "region" { type = string}
variable "dbt_sa_name" { type = string}
variable "dbt_sa_key_location" { type = string}
variable "dataproc_cluster_name" { type = string}
variable "bucket_name" { type = string}
variable "bq_dataset_name" { type = string}
variable "spark_serverless" { type = string}
variable "project_apis_list" {type    = list(string)}
variable "dbt_sa_roles_list" {type    = list(string)}

variable "src_customer_data" { type = string}
variable "src_service_data" { type = string}
variable "src_telecom_data" { type = string}

variable "dst_customer_data" { type = string}
variable "dst_service_data" { type = string}
variable "dst_telecom_data" { type = string}



provider "google-beta" {
  project     = var.project_id
  region      = var.region
}

#1.Enable API Services
resource "google_project_service" "workshop_gcp_services" {
  provider = google-beta
  count   = length(var.project_apis_list)
  service = var.project_apis_list[count.index]
  disable_dependent_services = true
}


resource "time_sleep" "wait_3_min_after_activate_service_apis" {
depends_on = [google_project_service.workshop_gcp_services]
create_duration = "3m"
}

#2.Create DBT Service Account with roles and downloads JSON key
resource "google_service_account" "dbt_service_account" {
  #This is not inferred from the provider.
  provider = google-beta
  account_id   = var.dbt_sa_name
  display_name = "DBT Service Account"
    depends_on = [
    time_sleep.wait_3_min_after_activate_service_apis
  ]
}

resource "google_project_iam_binding" "dbt_sa_roles" {
project = var.project_id
count = length(var.dbt_sa_roles_list)
role =  var.dbt_sa_roles_list[count.index]
members = [
  "serviceAccount:${google_service_account.dbt_service_account.email}"
]
}

resource "google_service_account_key" "dbt_sa_key" {
  service_account_id = google_service_account.dbt_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "json_local_sa" {
    content     = base64decode(google_service_account_key.dbt_sa_key.private_key)
    filename = "${var.dbt_sa_key_location}"

}

#3.Create Spark cluster
resource "google_dataproc_cluster" "spark-cluster" {
  #If spark serverless = true, do not create cluster
  count = var.spark_serverless ? 0 : 1
  depends_on = [
    time_sleep.wait_3_min_after_activate_service_apis
  ]
  provider = google-beta
  name     = var.dataproc_cluster_name
  region   = var.region
  cluster_config {
    initialization_action {

        script      = format("gs://goog-dataproc-initialization-actions-%s/connectors/connectors.sh",var.region)
    }
      gce_cluster_config {
        metadata = {
            bigquery-connector-version = "1.2.0"
            spark-bigquery-connector-version = "0.21.0"
        }
      service_account_scopes = [
        "cloud-platform"
      ]
    }
    software_config {
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
    }
  }
}
#3.Create GCS Bucket and uploads information
resource "google_storage_bucket" "gcs-bucket" {
  provider      = google-beta
    depends_on = [
    time_sleep.wait_3_min_after_activate_service_apis
  ]
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = "gsutil cp '${var.src_customer_data}' '${var.dst_customer_data}'/ && gsutil cp '${var.src_service_data}' '${var.dst_service_data}'/ && gsutil cp '${var.src_telecom_data}' '${var.dst_telecom_data}'/"

}
}


#4.Create BQ Dataset
resource "google_bigquery_dataset" "dbt_dataset" {
  provider                    = google-beta
    depends_on = [
    time_sleep.wait_3_min_after_activate_service_apis
  ]
  dataset_id                  = var.bq_dataset_name
  location                    = var.region
  delete_contents_on_destroy = true
}

#5.BigLake External connection
resource "google_bigquery_connection" "bl_connection" {
    provider = google-beta
    depends_on = [
        time_sleep.wait_3_min_after_activate_service_apis
    ]
    location = var.region
    connection_id = "biglake-dbt-spark"
    cloud_resource {}
}
#6.Grant permissions on connection SA
resource "google_project_iam_member" "connectionPermissionGrant" {
    provider = google-beta
    project = var.project_id
    role = "roles/storage.objectViewer"
    member = format("serviceAccount:%s", google_bigquery_connection.bl_connection.cloud_resource[0].service_account_id)
}

resource "time_sleep" "wait_3_min_after_grants" {
depends_on = [google_project_iam_member.connectionPermissionGrant]
create_duration = "3m"
}

#6.1 BigLake tables - customer data
resource "google_bigquery_table" "biglakeTable_cust_data" {
    provider = google-beta
    depends_on = [time_sleep.wait_3_min_after_grants, google_bigquery_dataset.dbt_dataset ]
    dataset_id = var.bq_dataset_name
    table_id   = "customer_data"
    external_data_configuration {
        autodetect = true
        source_format = "PARQUET"
        connection_id = google_bigquery_connection.bl_connection.name
        source_uris = [format("%s/*.parquet",var.dst_customer_data)]


    }
    deletion_protection = false
}

#6.2 BigLake tables - service data
resource "google_bigquery_table" "biglakeTable_service_data" {
    provider = google-beta
    depends_on = [time_sleep.wait_3_min_after_grants, google_bigquery_dataset.dbt_dataset ]
    dataset_id = var.bq_dataset_name
    table_id   = "service_data"
    external_data_configuration {
        autodetect = true
        source_format = "CSV"
        connection_id = google_bigquery_connection.bl_connection.name
        source_uris = [format("%s/*.csv",var.dst_service_data)]
    }
    deletion_protection = false
}

#6.3 BigLake tables - telecom data
resource "google_bigquery_table" "biglakeTable_telecom_data" {
    provider = google-beta
    depends_on = [time_sleep.wait_3_min_after_grants, google_bigquery_dataset.dbt_dataset ]
    dataset_id = var.bq_dataset_name
    table_id   = "telecom_data"
    external_data_configuration {
        autodetect = true
        source_format = "CSV"
        connection_id = google_bigquery_connection.bl_connection.name
        source_uris = [format("%s/*.csv",var.dst_telecom_data)]
    }
    deletion_protection = false
}
