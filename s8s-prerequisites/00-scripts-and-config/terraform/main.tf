/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
Local variables declaration
 *****************************************/

locals {
project_id                  = "${var.project_id}"
project_nbr                 = "${var.project_number}"
admin_upn_fqn               = "${var.gcp_account_name}"
location                    = "${var.gcp_region}"
umsa                        = "s8s-lab-sa"
umsa_fqn                    = "${local.umsa}@${local.project_id}.iam.gserviceaccount.com"
cc_umsa                     = "s8s-cc-sa"
cc_umsa_fqn                 = "${local.cc_umsa}@${local.project_id}.iam.gserviceaccount.com"
s8s_spark_bucket            = "s8s-spark-bucket-${local.project_nbr}"
s8s_spark_sphs_nm           = "s8s-sphs-${local.project_nbr}"
s8s_spark_sphs_bucket       = "s8s-sphs-bucket-${local.project_nbr}"
s8s_code_and_data_bucket    = "s8s-code-and-data-bucket-${local.project_nbr}"
vpc_nm                      = "s8s-vpc-${local.project_nbr}"
spark_subnet_nm             = "spark-snet"
spark_subnet_cidr           = "10.0.0.0/16"
psa_ip_length               = 16
s8s_artifact_repository_nm  = "s8s-spark-${local.project_nbr}"
bq_dataset_nm               = "s8s_bq_dataset_${local.project_nbr}"
mnb_server_machine_type     = "n1-standard-4"
cc_gmsa_fqn                 = "service-${local.project_nbr}@cloudcomposer-accounts.iam.gserviceaccount.com"
gce_gmsa_fqn                = "${local.project_nbr}-compute@developer.gserviceaccount.com"
cloud_composer2_img_version = "${var.cloud_composer_image_version}"
spark_container_img_tag     = "${var.spark_container_image_tag}"
dpms_nm                     = "s8s-dpms-${local.project_nbr}"
}

/******************************************
1. Enable Google APIs in parallel
 *****************************************/

resource "google_project_service" "enable_compute_google_apis" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_container_google_apis" {
  project = var.project_id
  service = "container.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_containerregistry_google_apis" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_dataproc_google_apis" {
  project = var.project_id
  service = "dataproc.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_bigquery_google_apis" {
  project = var.project_id
  service = "bigquery.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_storage_google_apis" {
  project = var.project_id
  service = "storage.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_notebooks_google_apis" {
  project = var.project_id
  service = "notebooks.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_aiplatform_google_apis" {
  project = var.project_id
  service = "aiplatform.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_logging_google_apis" {
  project = var.project_id
  service = "logging.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_monitoring_google_apis" {
  project = var.project_id
  service = "monitoring.googleapis.com"
  disable_dependent_services = true
}
resource "google_project_service" "enable_servicenetworking_google_apis" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_cloudbuild_google_apis" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_artifactregistry_google_apis" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_cloudresourcemanager_google_apis" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_composer_google_apis" {
  project = var.project_id
  service = "composer.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_pubsub_google_apis" {
  project = var.project_id
  service = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_dpms_google_apis" {
  project = var.project_id
  service = "metastore.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_cloudrun_admin_google_apis" {
  project = var.project_id
  service = "run.googleapis.com"
  disable_dependent_services = true
}


/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_api_enabling" {
  create_duration = "60s"
  depends_on = [
    google_project_service.enable_compute_google_apis,
    google_project_service.enable_container_google_apis,
    google_project_service.enable_containerregistry_google_apis,
    google_project_service.enable_dataproc_google_apis,
    google_project_service.enable_bigquery_google_apis,
    google_project_service.enable_storage_google_apis,
    google_project_service.enable_servicenetworking_google_apis,
    google_project_service.enable_aiplatform_google_apis,
    google_project_service.enable_notebooks_google_apis,
    google_project_service.enable_cloudbuild_google_apis,
    google_project_service.enable_artifactregistry_google_apis,
    google_project_service.enable_cloudresourcemanager_google_apis,
    google_project_service.enable_composer_google_apis,
    google_project_service.enable_pubsub_google_apis,
    google_project_service.enable_cloudrun_admin_google_apis,
    google_project_service.enable_dpms_google_apis
  ]
}


/******************************************
2. Create User Managed Service Account
 *****************************************/
module "umsa_creation" {
  source     = "terraform-google-modules/service-accounts/google"
  project_id = local.project_id
  names      = ["${local.umsa}"]
  display_name = "User Managed Service Account"
  description  = "User Managed Service Account for Serverless Spark"
  depends_on = [
    time_sleep.sleep_after_api_enabling
  ]
}

/******************************************
3a. Grant IAM roles to User Managed Service Account
 *****************************************/

module "umsa_role_grants" {
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${local.umsa_fqn}"
  prefix                  = "serviceAccount"
  project_id              = local.project_id
  project_roles = [

    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.objectAdmin",
    "roles/storage.admin",
    "roles/metastore.admin",
    "roles/metastore.editor",
    "roles/dataproc.editor",
    "roles/dataproc.worker",
    "roles/bigquery.dataEditor",
    "roles/bigquery.admin",
    "roles/bigquery.user",
    "roles/dataproc.editor",
    "roles/artifactregistry.writer",
    "roles/logging.logWriter",
    "roles/cloudbuild.builds.editor",
    "roles/aiplatform.admin",
    "roles/aiplatform.viewer",
    "roles/aiplatform.user",
    "roles/viewer",
    "roles/composer.worker",
    "roles/composer.admin",
    "roles/composer.ServiceAgentV2Ext",
    "roles/notebooks.admin"
  ]
  depends_on = [
    module.umsa_creation,
    time_sleep.sleep_after_api_enabling
  ]
}

# IAM role grants to Google Managed Service Account for Cloud Composer 2
module "gmsa_role_grants_cc" {
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${local.cc_gmsa_fqn}"
  prefix                  = "serviceAccount"
  project_id              = local.project_id
  project_roles = [

    "roles/composer.ServiceAgentV2Ext",
  ]
  depends_on = [
    module.umsa_role_grants,
    time_sleep.sleep_after_api_enabling
  ]
}

# IAM role grants to Google Managed Service Account for Compute Engine (for Cloud Composer 2 to download images)
module "gmsa_role_grants_gce" {
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${local.gce_gmsa_fqn}"
  prefix                  = "serviceAccount"
  project_id              = local.project_id
  project_roles = [

    "roles/editor",
  ]
  depends_on = [
    module.umsa_role_grants,
    time_sleep.sleep_after_api_enabling
  ]
}


/******************************************************
4. Grant Service Account Impersonation privilege to yourself/Admin User
 ******************************************************/

module "umsa_impersonate_privs_to_admin" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam/"
  service_accounts = ["${local.umsa_fqn}"]
  project          = local.project_id
  mode             = "additive"
  bindings = {
    "roles/iam.serviceAccountUser" = [
      "user:${local.admin_upn_fqn}"
    ],
    "roles/iam.serviceAccountTokenCreator" = [
      "user:${local.admin_upn_fqn}"
    ]

  }
  depends_on = [
    module.umsa_creation,
    time_sleep.sleep_after_api_enabling
  ]
}

/******************************************************
5. Grant IAM roles to Admin User/yourself
 ******************************************************/

module "administrator_role_grants" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = ["${local.project_id}"]
  mode     = "additive"

  bindings = {
    "roles/storage.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/metastore.admin" = [

      "user:${local.admin_upn_fqn}",
    ]
    "roles/dataproc.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.user" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.dataEditor" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.jobUser" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/composer.environmentAndStorageObjectViewer" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/iam.serviceAccountUser" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/iam.serviceAccountTokenCreator" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/composer.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/aiplatform.user" = [
      "user:${local.admin_upn_fqn}",
    ]
     "roles/aiplatform.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
     "roles/compute.networkAdmin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/artifactregistry.admin" = [
     "user:${local.admin_upn_fqn}",
   ]
   "roles/compute.admin" = [
    "user:${local.admin_upn_fqn}",
  ]
  }
  depends_on = [
    module.umsa_role_grants,
    module.umsa_impersonate_privs_to_admin,
    time_sleep.sleep_after_api_enabling
  ]
  }

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_identities_permissions" {
  create_duration = "120s"
  depends_on = [
    module.umsa_creation,
    module.umsa_role_grants,
    module.umsa_impersonate_privs_to_admin,
    module.administrator_role_grants,
    module.gmsa_role_grants_cc,
    module.gmsa_role_grants_gce
  ]
}

/************************************************************************
6. Create VPC network, subnet & reserved static IP creation
 ***********************************************************************/
module "vpc_creation" {
  source                                 = "terraform-google-modules/network/google"
  project_id                             = local.project_id
  network_name                           = local.vpc_nm
  routing_mode                           = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.spark_subnet_nm}"
      subnet_ip             = "${local.spark_subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = local.spark_subnet_cidr
      subnet_private_access = true
    }
  ]
  depends_on = [
    time_sleep.sleep_after_identities_permissions,
    time_sleep.sleep_after_api_enabling
  ]
}

resource "google_compute_global_address" "reserved_ip_for_psa_creation" {
  provider      = google-beta
  name          = "private-service-access-ip"
  purpose       = "VPC_PEERING"
  network       =  "projects/${local.project_id}/global/networks/s8s-vpc-${local.project_nbr}"
  address_type  = "INTERNAL"
  prefix_length = local.psa_ip_length

  depends_on = [
    module.vpc_creation,
    time_sleep.sleep_after_api_enabling
  ]
}

resource "google_service_networking_connection" "private_connection_with_service_networking" {
  network                 =  "projects/${local.project_id}/global/networks/s8s-vpc-${local.project_nbr}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.reserved_ip_for_psa_creation.name]

  depends_on = [
    module.vpc_creation,
    google_compute_global_address.reserved_ip_for_psa_creation,
    time_sleep.sleep_after_api_enabling
  ]
}

/******************************************
7. Create Firewall rules
 *****************************************/

resource "google_compute_firewall" "allow_intra_snet_ingress_to_any" {
  project   = local.project_id
  name      = "allow-intra-snet-ingress-to-any"
  network   = local.vpc_nm
  direction = "INGRESS"
  source_ranges = [local.spark_subnet_cidr]
  allow {
    protocol = "all"
  }
  description        = "Creates firewall rule to allow ingress from within Spark subnet on all ports, all protocols"
  depends_on = [
    module.vpc_creation,
    module.administrator_role_grants,
    time_sleep.sleep_after_api_enabling
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_network_and_firewall_creation" {
  create_duration = "120s"
  depends_on = [
    module.vpc_creation,
    google_compute_firewall.allow_intra_snet_ingress_to_any
  ]
}

/******************************************
9. Create Storage buckets
 *****************************************/

resource "google_storage_bucket" "s8s_spark_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_spark_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation,
      time_sleep.sleep_after_api_enabling
  ]
}

resource "google_storage_bucket" "s8s_spark_sphs_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_spark_sphs_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation,
      time_sleep.sleep_after_api_enabling
  ]
}

resource "google_storage_bucket" "s8s_code_and_data_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_code_and_data_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation,
      time_sleep.sleep_after_api_enabling
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_bucket_creation" {
  create_duration = "60s"
  depends_on = [
    google_storage_bucket.s8s_spark_sphs_bucket_creation,
    google_storage_bucket.s8s_spark_bucket_creation,
    google_storage_bucket.s8s_code_and_data_bucket_creation
  ]
}

/******************************************
10. PHS creation
******************************************/

resource "google_dataproc_cluster" "sphs_creation" {
  project  = local.project_id
  provider = google-beta
  name     = local.s8s_spark_sphs_nm
  region   = local.location

  cluster_config {

    endpoint_config {
        enable_http_port_access = true
    }

    staging_bucket = local.s8s_spark_bucket

    # Override or set some custom properties
    software_config {
      image_version = "2.0"
      override_properties = {
        "dataproc:dataproc.allow.zero.workers"=true
        "dataproc:job.history.to-gcs.enabled"=true
        "spark:spark.history.fs.logDirectory"="gs://${local.s8s_spark_sphs_bucket}/*/spark-job-history"
        "mapred:mapreduce.jobhistory.read-only.dir-pattern"="gs://${local.s8s_spark_sphs_bucket}/*/mapreduce-job-history/done"
      }
    }
    gce_cluster_config {
      subnetwork =  "projects/${local.project_id}/regions/${local.location}/subnetworks/${local.spark_subnet_nm}"
      service_account = local.umsa_fqn
      service_account_scopes = [
        "cloud-platform"
      ]
    }
  }
  depends_on = [
    module.administrator_role_grants,
    module.vpc_creation,
    time_sleep.sleep_after_bucket_creation,
    time_sleep.sleep_after_api_enabling
  ]
}

/********************************************************
11. Cloning Repository
********************************************************/

resource "null_resource" "gitclone" {
    provisioner "local-exec" {
        command = "cd ~ && gsutil cp -r serverless-spark-workshop gs://s8s-code-and-data-bucket-${local.project_nbr}"
        interpreter = ["bash", "-c"]
    }
    depends_on = [
    time_sleep.sleep_after_bucket_creation
    ]
}

resource "null_resource" "unzip_file" {
    provisioner "local-exec" {
        command = "unzip ~/serverless-spark-workshop/social_network_graph/02-dependencies/graphframes-0.8.1-spark3.0-s_2.12.zip "
        interpreter = ["bash", "-c"]
    }
    depends_on = [
      null_resource.gitclone
    ]
}

resource "null_resource" "make_build_dir" {
    provisioner "local-exec" {
        command = "cd ~ && mkdir build "
        interpreter = ["bash", "-c"]
    }
    depends_on = [
      null_resource.unzip_file
    ]
}

resource "null_resource" "copy_zip_file" {
    provisioner "local-exec" {
        command = "cp graphframes-0.8.1-spark3.0-s_2.12.jar ~/build "
        interpreter = ["bash", "-c"]
    }
    depends_on = [
      null_resource.unzip_file,
      null_resource.make_build_dir
    ]
}

/********************************************************
12. Artifact registry for Serverless Spark custom container images
********************************************************/

resource "google_artifact_registry_repository" "artifact_registry_creation" {
    count = var.custom_container == "1" ? 1 : 0
    location          = local.location
    repository_id     = local.s8s_artifact_repository_nm
    description       = "Artifact repository"
    format            = "DOCKER"
    depends_on = [
        module.administrator_role_grants,
        module.vpc_creation,
        time_sleep.sleep_after_bucket_creation,
        time_sleep.sleep_after_api_enabling,
        null_resource.gitclone,
        null_resource.unzip_file,
        null_resource.copy_zip_file,
        null_resource.make_build_dir
    ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_gar_repository_creation" {
  create_duration = "120s"
  depends_on = [
    google_artifact_registry_repository.artifact_registry_creation
  ]
}

/********************************************************
12. Building custom container image
********************************************************/

resource "null_resource" "custom_container_image_creation" {
    count = var.custom_container == "1" ? 1 : 0
    provisioner "local-exec" {

        command = "bash ../image-creation-sh.sh ${local.spark_container_img_tag} ${local.location} ${local.s8s_artifact_repository_nm}"
    }
    depends_on = [
        module.administrator_role_grants,
        module.vpc_creation,
        time_sleep.sleep_after_bucket_creation,
        google_artifact_registry_repository.artifact_registry_creation,
        time_sleep.sleep_after_api_enabling,
        null_resource.gitclone,
        null_resource.unzip_file,
        time_sleep.sleep_after_gar_repository_creation,
        null_resource.copy_zip_file,
        null_resource.make_build_dir
    ]
}

/********************************************************
14. Create Composer Environment
********************************************************/

module "cc_umsa_creation" {

  count = var.create_composer == "1" ? 1 : 0
  source     = "terraform-google-modules/service-accounts/google"
  project_id = local.project_id
  names      = ["${local.cc_umsa}"]
  display_name = "Cloud Composer User Managed Service Account"
  description  = "Cloud Composer User Managed Service Account for Serverless Spark"
  depends_on = [
    time_sleep.sleep_after_api_enabling
  ]
}

module "cc_umsa_role_grants" {
  count = var.create_composer == "1" ? 1 : 0
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${local.cc_umsa_fqn}"
  prefix                  = "serviceAccount"
  project_id              = local.project_id
  project_roles = [

    "roles/iam.serviceAccountUser",
    "roles/dataproc.editor",
    "roles/composer.worker",
    "roles/composer.ServiceAgentV2Ext",
    "roles/editor",
  ]
  depends_on = [
    module.cc_umsa_creation,
    time_sleep.sleep_after_api_enabling
  ]
}

resource "google_composer_environment" "cloud_composer_env_creation" {
  count = var.create_composer == "1" ? 1 : 0
  name   = "${local.project_id}-cc2"
  region = local.location
  provider = google-beta

  config {
    software_config {
      image_version = local.cloud_composer2_img_version
      env_variables = {
        AIRFLOW_VAR_CODE_BUCKET    = "${local.s8s_code_and_data_bucket}"
        AIRFLOW_VAR_PHS            = "${local.s8s_spark_sphs_nm}"
        AIRFLOW_VAR_PROJECT_ID     = "${local.project_id}"
        AIRFLOW_VAR_REGION         = "${local.location}"
        AIRFLOW_VAR_SUBNET         = "${local.spark_subnet_nm}"
        AIRFLOW_VAR_BQ_DATASET     = "${local.bq_dataset_nm}"
        AIRFLOW_VAR_UMSA           = "${local.umsa}"
        AIRFLOW_VAR_METASTORE_NAME = "${local.dpms_nm}"
        AIRFLOW_VAR_DATABASE_NAME  = "retail_store_analytics_metastore"
      }
    }

    node_config {
      network    = local.vpc_nm
      subnetwork = local.spark_subnet_nm
      service_account = local.umsa_fqn
    }
  }

  depends_on = [
        module.administrator_role_grants,
        module.cc_umsa_creation,
        module.cc_umsa_role_grants,
        time_sleep.sleep_after_bucket_creation,
        google_dataproc_cluster.sphs_creation,
        time_sleep.sleep_after_api_enabling
  ]

  timeouts {
    create = "75m"
  }
}

output "CLOUD_COMPOSER_DAG_BUCKET" {
  value = google_composer_environment.cloud_composer_env_creation[*].config.0.dag_gcs_prefix
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/


resource "time_sleep" "sleep_after_composer_creation" {
  create_duration = "180s"
  depends_on = [
      google_composer_environment.cloud_composer_env_creation
  ]
}

/******************************************
15. Create Dataproc Metastore
******************************************/
resource "google_dataproc_metastore_service" "datalake_metastore_creation" {
  count = var.create_metastore == "1" ? 1 : 0
  service_id = local.dpms_nm
  location   = local.location
  port       = 9080
  tier       = "DEVELOPER"
  network    = "projects/${local.project_id}/global/networks/${local.vpc_nm}"

  maintenance_window {
    hour_of_day = 2
    day_of_week = "SUNDAY"
  }

  hive_metastore_config {
    version = "3.1.2"
  }

  depends_on = [
    module.administrator_role_grants,
    time_sleep.sleep_after_bucket_creation,
    google_dataproc_cluster.sphs_creation,
    time_sleep.sleep_after_api_enabling
  ]
}

/******************************************
16. BigQuery dataset creation
******************************************/

resource "google_bigquery_dataset" "bq_dataset_creation" {
  dataset_id                  = local.bq_dataset_nm
  location                    = local.location
  delete_contents_on_destroy  = true
  depends_on = [
  module.administrator_role_grants,
  time_sleep.sleep_after_api_enabling
  ]

}

/******************************************
17. Output important variables needed for the demo
******************************************/

output "PROJECT_ID" {
  value = local.project_id
}

output "PROJECT_NBR" {
  value = local.project_nbr
}

output "LOCATION" {
  value = local.location
}

output "VPC_NM" {
  value = local.vpc_nm
}

output "SUBNET_NM" {
  value = local.spark_subnet_nm
}

output "FIREWALL_NM" {
  value = "allow-intra-snet-ingress-to-any"
}

output "PERSISTENT_HISTORY_SERVER_NM" {
  value = local.s8s_spark_sphs_nm
}

output "DPMS_NM" {
  value = local.dpms_nm
}

output "UMSA_FQN" {
  value = local.umsa_fqn
}

output "BQ_DATASET_NM" {
  value = local.bq_dataset_nm
}

output "COMPOSER_ENV" {
  value = "${local.project_id}-cc2"
}

output "GAR_REPOSITORY" {
  value = local.s8s_artifact_repository_nm
}

output "CODE_AND_DATA_BUCKET" {
  value = local.s8s_code_and_data_bucket
}

output "GAR_REPOSITORY_NM" {
value = local.s8s_artifact_repository_nm
}

output "CUSTOM_CONTAINER_IMAGE_PATH" {
value = "${local.location}-docker.pkg.dev/${local.project_id}/${local.s8s_artifact_repository_nm}/s8s-spark-image:${local.spark_container_img_tag}"
}

/******************************************
DONE
******************************************/
