variable "project_id" {}
variable "region" {}
variable "terraform_key_location" {}
variable "dataproc_cluster_name" {}
variable "bucket_name" {}
variable "bq_dataset_name" {}
variable "serverless_spark" {}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = var.terraform_key_location
}

resource "google_dataproc_cluster" "spark-cluster" {
  #If serverless spark = true, do not create cluster
  count = var.serverless_spark ? 0 : 1
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

resource "google_storage_bucket" "gcs-bucket" {
  provider      = google-beta
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
}


resource "google_bigquery_dataset" "dataset" {
  provider                    = google-beta
  dataset_id                  = var.bq_dataset_name
  location                    = var.region
  delete_contents_on_destroy = true
}