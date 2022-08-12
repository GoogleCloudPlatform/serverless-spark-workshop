variable "project_id" {}
variable "region" {}
variable "terraform_key_location" {}
variable "bq_dataset_name" {}
variable "customer_data_gcs_uri" {}
variable "service_data_gcs_uri" {}
variable "telecom_data_gcs_uri" {}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = var.terraform_key_location
}

resource "google_bigquery_connection" "connection" {
    provider = google-beta
    location = var.region
    connection_id = "biglake-dbt-spark"
    cloud_resource {}
}

resource "google_project_iam_member" "connectionPermissionGrant" {
    provider = google-beta
    project = var.project_id
    role = "roles/storage.objectViewer"
    member = format("serviceAccount:%s", google_bigquery_connection.connection.cloud_resource[0].service_account_id)
}

resource "time_sleep" "wait_5_min" {
depends_on = [google_project_iam_member.connectionPermissionGrant]
create_duration = "5m"
}


resource "google_bigquery_table" "biglakeTable_cust_raw_data" {
    provider = google-beta
    depends_on = [time_sleep.wait_5_min]
    dataset_id = var.bq_dataset_name
    table_id   = "cust_raw_data"
    external_data_configuration {
        autodetect = true
        source_format = "PARQUET"
        connection_id = google_bigquery_connection.connection.name
        source_uris = [var.customer_data_gcs_uri]
    }
    deletion_protection = false
}

resource "google_bigquery_table" "biglakeTable_service_data" {
    provider = google-beta
    depends_on = [time_sleep.wait_5_min]
    dataset_id = var.bq_dataset_name
    table_id   = "service_data"
    external_data_configuration {
        autodetect = true
        source_format = "CSV"
        connection_id = google_bigquery_connection.connection.name
        source_uris = [var.service_data_gcs_uri]
    }
    deletion_protection = false
}


resource "google_bigquery_table" "biglakeTable_telecom_data" {
    provider = google-beta
    depends_on = [time_sleep.wait_5_min]
    dataset_id = var.bq_dataset_name
    table_id   = "telecom_data"
    external_data_configuration {
        autodetect = true
        source_format = "CSV"
        connection_id = google_bigquery_connection.connection.name
        source_uris = [var.telecom_data_gcs_uri]
    }
    deletion_protection = false
}





