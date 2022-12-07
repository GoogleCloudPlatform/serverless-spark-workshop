/**
 * Copyright 2022 Google LLC
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
zone                        = "${var.gcp_zone}"
location_multi              = "${var.gcp_multi_region}"
umsa                        = "s8s-lab-sa"
umsa_fqn                    = "${local.umsa}@${local.project_id}.iam.gserviceaccount.com"
vpc_nm                      = "s8s-vpc-${local.project_nbr}"
spark_subnet_nm             = "spark-snet"
user_id                     = split("@","${var.gcp_account_name}")[0]
s8s_data_bucket             = "${local.user_id}-s8s_data_bucket-${local.project_nbr}"
s8s_code_bucket             = "${local.user_id}-s8s_code_bucket-${local.project_nbr}"
s8s_notebook_bucket         = "${local.user_id}-s8s_notebook_bucket-${local.project_nbr}"
s8s_model_bucket            = "${local.user_id}-s8s_model_bucket-${local.project_nbr}"
s8s_pipeline_bucket         = "${local.user_id}-s8s_pipeline_bucket-${local.project_nbr}"
s8s_metrics_bucket          = "${local.user_id}-s8s_metrics_bucket-${local.project_nbr}"
s8s_functions_bucket        = "${local.user_id}-s8s_functions_bucket-${local.project_nbr}"
bq_datamart_ds              = "${local.user_id}_customer_churn_ds"
umnb_server_machine_type    = "e2-medium"
umnb_server_nm              = "${local.user_id}-s8s-spark-ml-pipelines-nb-server"
mnb_server_machine_type     = "n1-standard-4"
mnb_server_nm               = "${local.user_id}-s8s-spark-ml-interactive-nb-server"
SPARK_CONTAINER_IMG_TAG     = "${var.spark_container_image_tag}"
bq_connector_jar_gcs_uri    = "${var.bq_connector_jar_gcs_uri}"
cloud_scheduler_timezone    = "${var.cloud_scheduler_time_zone}"
composer_bucket             = "${var.composer_bucket}"
}


/******************************************
1. Create Storage bucket
 *****************************************/

resource "google_storage_bucket" "s8s_data_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_data_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
}

resource "google_storage_bucket" "s8s_code_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_code_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
}

resource "google_storage_bucket" "s8s_notebook_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_notebook_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
}

resource "google_storage_bucket" "s8s_model_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_model_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
}

resource "google_storage_bucket" "s8s_metrics_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_metrics_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
}

resource "google_storage_bucket" "s8s_vai_pipeline_bucket_creation" {
  project                           = local.project_id
  name                              = local.s8s_pipeline_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_bucket_creation" {
  create_duration = "60s"
  depends_on = [
    google_storage_bucket.s8s_data_bucket_creation,
    google_storage_bucket.s8s_code_bucket_creation,
    google_storage_bucket.s8s_notebook_bucket_creation,
    google_storage_bucket.s8s_model_bucket_creation,
    google_storage_bucket.s8s_metrics_bucket_creation,
    google_storage_bucket.s8s_vai_pipeline_bucket_creation
  ]
}

/******************************************
2. Customize scripts and notebooks
 *****************************************/
 # Copy from templates and replace variables

resource "null_resource" "umnbs_post_startup_bash_creation" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/umnbs-exec-post-startup.sh ../../02-scripts/bash/ && sed -i s/PROJECT_NBR/${local.project_nbr}/g ../../02-scripts/bash/umnbs-exec-post-startup.sh && sed -i s/USER_ID/${local.user_id}/g ../../02-scripts/bash/umnbs-exec-post-startup.sh"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "mnbs_post_startup_bash_creation" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/mnbs-exec-post-startup.sh ../../02-scripts/bash/ && sed -i s/PROJECT_NBR/${local.project_nbr}/g ../../02-scripts/bash/mnbs-exec-post-startup.sh && sed -i s/USER_ID/${local.user_id}/g ../../02-scripts/bash/mnbs-exec-post-startup.sh"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "preprocessing_notebook_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/preprocessing.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/${local.project_nbr}/g ../../03-notebooks/pyspark/preprocessing.ipynb && sed -i s/YOUR_PROJECT_ID/${local.project_id}/g ../../03-notebooks/pyspark/preprocessing.ipynb && sed -i s/USER_ID/${local.user_id}/g ../../03-notebooks/pyspark/preprocessing.ipynb"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "training_notebook_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/model_training.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/${local.project_nbr}/g ../../03-notebooks/pyspark/model_training.ipynb && sed -i s/YOUR_PROJECT_ID/${local.project_id}/g ../../03-notebooks/pyspark/model_training.ipynb && sed -i s/USER_ID/${local.user_id}/g ../../03-notebooks/pyspark/model_training.ipynb"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "hpt_notebook_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/hyperparameter_tuning.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/${local.project_nbr}/g ../../03-notebooks/pyspark/hyperparameter_tuning.ipynb && sed -i s/YOUR_PROJECT_ID/${local.project_id}/g ../../03-notebooks/pyspark/hyperparameter_tuning.ipynb && sed -i s/USER_ID/${local.user_id}/g ../../03-notebooks/pyspark/hyperparameter_tuning.ipynb"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "scoring_notebook_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/batch_scoring.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/${local.project_nbr}/g ../../03-notebooks/pyspark/batch_scoring.ipynb && sed -i s/YOUR_PROJECT_ID/${local.project_id}/g ../../03-notebooks/pyspark/batch_scoring.ipynb && sed -i s/USER_ID/${local.user_id}/g ../../03-notebooks/pyspark/batch_scoring.ipynb"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "vai_pipeline_notebook_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/customer_churn_training_pipeline.ipynb ../../03-notebooks/vai-pipelines/ && sed -i s/YOUR_GCP_LOCATION/${local.location}/g ../../03-notebooks/vai-pipelines/customer_churn_training_pipeline.ipynb && sed -i s/YOUR_SPARK_CONTAINER_IMAGE_TAG/${local.SPARK_CONTAINER_IMG_TAG}/g ../../03-notebooks/vai-pipelines/customer_churn_training_pipeline.ipynb && sed -i s/USER_ID/${local.user_id}/g ../../03-notebooks/vai-pipelines/customer_churn_training_pipeline.ipynb"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "pipeline_file_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/pipeline.py ../../02-scripts/airflow/ && sed -i s/USER_ID/${local.user_id}/g ../../02-scripts/airflow/pipeline.py"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "batch_scoring_script_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/batch_scoring.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/${local.user_id}/g ../../02-scripts/pyspark/batch_scoring.py"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "hyperparameter_tuning_script_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/hyperparameter_tuning.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/${local.user_id}/g ../../02-scripts/pyspark/hyperparameter_tuning.py"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "model_training_script_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/model_training.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/${local.user_id}/g ../../02-scripts/pyspark/model_training.py"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "preprocessing_script_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/preprocessing.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/${local.user_id}/g ../../02-scripts/pyspark/preprocessing.py"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "module_01_guide_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/Module-01-Environment-Provisioning-Shared.md ../../05-lab-guide/ && sed -i s/USER_ID/${local.user_id}/g ../../05-lab-guide/Module-01-Environment-Provisioning-Shared.md"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "module_03_guide_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/Module-03-Author-ML-Experiments-With-Spark-Notebooks.md ../../05-lab-guide/ && sed -i s/USER_ID/${local.user_id}/g ../../05-lab-guide/Module-03-Author-ML-Experiments-With-Spark-Notebooks.md"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "module_04_guide_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/Module-04-Author-ML-PySpark-Scripts.md ../../05-lab-guide/ && sed -i s/USER_ID/${local.user_id}/g ../../05-lab-guide/Module-04-Author-ML-PySpark-Scripts.md"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "module_08_guide_customization" {
    provisioner "local-exec" {
        command = "cp ../../04-templates/Module-08-Orchestrate-Batch-Scoring.md ../../05-lab-guide/ && sed -i s/USER_ID/${local.user_id}/g ../../05-lab-guide/Module-08-Orchestrate-Batch-Scoring.md"
        interpreter = ["bash", "-c"]
    }
}

resource "null_resource" "vai_pipeline_customization" {
    provisioner "local-exec" {
        command = "mkdir ../../05-pipelines && cp ../../04-templates/customer_churn_vai_pipeline_template.json ../../05-pipelines/ && sed -i s/YOUR_PROJECT_NBR/${local.project_nbr}/g ../../05-pipelines/customer_churn_vai_pipeline_template.json && sed -i s/YOUR_PROJECT_ID/${local.project_id}/g ../../05-pipelines/customer_churn_vai_pipeline_template.json && sed -i s/YOUR_GCP_LOCATION/${local.location}/g ../../05-pipelines/customer_churn_vai_pipeline_template.json && sed -i s/USER_ID/${local.user_id}/g ../../05-pipelines/customer_churn_vai_pipeline_template.json "
        interpreter = ["bash", "-c"]
    }
}

/******************************************
3. Copy of datasets, scripts and notebooks to buckets
 ******************************************/

resource "google_storage_bucket_object" "datasets_upload_to_gcs" {
  for_each = fileset("../../01-datasets/", "*")
  source = "../../01-datasets/${each.value}"
  name = "${each.value}"
  bucket = "${local.s8s_data_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "pyspark_scripts_dir_upload_to_gcs" {
  for_each = fileset("../../02-scripts/", "*")
  source = "../../02-scripts/${each.value}"
  name = "${each.value}"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "pyspark_scripts_upload_to_gcs" {
  for_each = fileset("../../02-scripts/pyspark/", "*")
  source = "../../02-scripts/pyspark/${each.value}"
  name = "pyspark/${each.value}"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    google_storage_bucket_object.pyspark_scripts_dir_upload_to_gcs,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "notebooks_dir_create_in_gcs" {
  for_each = fileset("../../03-notebooks/", "*")
  source = "../../03-notebooks/${each.value}"
  name = "03-notebooks/${each.value}"
  bucket = "${local.s8s_notebook_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "notebooks_pyspark_upload_to_gcs" {
  for_each = fileset("../../03-notebooks/pyspark/", "*")
  source = "../../03-notebooks/pyspark/${each.value}"
  name = "pyspark/${each.value}"
  bucket = "${local.s8s_notebook_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    google_storage_bucket_object.notebooks_dir_create_in_gcs,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "notebooks_vai_pipelines_upload_to_gcs" {
  for_each = fileset("../../03-notebooks/vai-pipelines/", "*")
  source = "../../03-notebooks/vai-pipelines/${each.value}"
  name = "vai-pipelines/${each.value}"
  bucket = "${local.s8s_notebook_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    google_storage_bucket_object.notebooks_dir_create_in_gcs,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "bash_dir_create_in_gcs" {
  for_each = fileset("../../02-scripts/", "*")
  source = "../../02-scripts/${each.value}"
  name = "${each.value}"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "bash_scripts_upload_to_gcs" {
  for_each = fileset("../../02-scripts/bash/", "*")
  source = "../../02-scripts/bash/${each.value}"
  name = "bash/${each.value}"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    google_storage_bucket_object.bash_dir_create_in_gcs,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "airflow_scripts_upload_to_gcs" {
  name   = "airflow/pipeline.py"
  source = "../../02-scripts/airflow/pipeline.py"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

# Substituted version of pipeline JSON
resource "google_storage_bucket_object" "vai_pipeline_json_upload_to_gcs" {
  name   = "templates/customer_churn_vai_pipeline_template.json"
  source = "../../05-pipelines/customer_churn_vai_pipeline_template.json"
  bucket = "${local.s8s_pipeline_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    null_resource.vai_pipeline_customization,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.module_01_guide_customization
  ]
}

resource "google_storage_bucket_object" "gcf_scripts_upload_to_gcs" {
  for_each = fileset("../../02-scripts/cloud-functions/", "*")
  source = "../../02-scripts/cloud-functions/${each.value}"
  name = "cloud-functions/${each.value}"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    null_resource.preprocessing_notebook_customization,
    null_resource.training_notebook_customization,
    null_resource.hpt_notebook_customization,
    null_resource.scoring_notebook_customization,
    null_resource.vai_pipeline_notebook_customization,
    null_resource.pipeline_file_customization,
    null_resource.batch_scoring_script_customization,
    null_resource.hyperparameter_tuning_script_customization,
    null_resource.model_training_script_customization,
    null_resource.preprocessing_script_customization,
    null_resource.module_03_guide_customization,
    null_resource.module_04_guide_customization,
    null_resource.module_08_guide_customization,
    null_resource.vai_pipeline_customization,
    null_resource.module_01_guide_customization
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_storage_steps" {
  create_duration = "120s"
  depends_on = [
      time_sleep.sleep_after_bucket_creation,
      google_storage_bucket_object.notebooks_vai_pipelines_upload_to_gcs,
      google_storage_bucket_object.notebooks_pyspark_upload_to_gcs,
      google_storage_bucket_object.pyspark_scripts_upload_to_gcs,
      google_storage_bucket_object.bash_scripts_upload_to_gcs,
      google_storage_bucket_object.airflow_scripts_upload_to_gcs,
      google_storage_bucket_object.vai_pipeline_json_upload_to_gcs,
      google_storage_bucket_object.gcf_scripts_upload_to_gcs
  ]
}

/******************************************
4. BigQuery dataset creation
******************************************/

resource "google_bigquery_dataset" "bq_dataset_creation" {
  dataset_id                  = local.bq_datamart_ds
  location                    = local.location_multi
}


/******************************************************************
5. Vertex AI Workbench - User Managed Notebook Server Creation
******************************************************************/

resource "google_storage_bucket_object" "bash_umnbs_script_upload_to_gcs" {
  name   = "bash/umnbs-exec-post-startup.sh"
  source = "../../02-scripts/bash/umnbs-exec-post-startup.sh"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    time_sleep.sleep_after_storage_steps,
    google_storage_bucket_object.bash_dir_create_in_gcs,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    google_storage_bucket_object.bash_scripts_upload_to_gcs

  ]
}

resource "google_notebooks_instance" "umnb_server_creation" {
  project  = local.project_id
  name = local.umnb_server_nm
  location = local.zone
  machine_type = "e2-medium"

  service_account = local.umsa_fqn
  network = "projects/${local.project_id}/global/networks/s8s-vpc-${local.project_nbr}"
  subnet = "projects/${local.project_id}/regions/${local.location}/subnetworks/${local.spark_subnet_nm}"
  post_startup_script = "gs://${local.s8s_code_bucket}/bash/umnbs-exec-post-startup.sh"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu"
  }
  depends_on = [
    time_sleep.sleep_after_storage_steps,
    google_storage_bucket_object.bash_scripts_upload_to_gcs,
    google_storage_bucket_object.notebooks_vai_pipelines_upload_to_gcs,
    google_storage_bucket_object.bash_umnbs_script_upload_to_gcs
  ]
}

/******************************************************************
6. Vertex AI Workbench - Managed Notebook Server Creation
******************************************************************/

resource "google_storage_bucket_object" "bash_mnbs_script_upload_to_gcs" {
  name   = "bash/mnbs-exec-post-startup.sh"
  source = "../../02-scripts/bash/mnbs-exec-post-startup.sh"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation,
    time_sleep.sleep_after_storage_steps,
    google_storage_bucket_object.bash_dir_create_in_gcs,
    null_resource.umnbs_post_startup_bash_creation,
    null_resource.mnbs_post_startup_bash_creation,
    google_storage_bucket_object.bash_scripts_upload_to_gcs

  ]
}

resource "google_notebooks_runtime" "mnb_server_creation" {
  project              = local.project_id
  provider             = google-beta
  name                 = local.mnb_server_nm
  location             = local.location

  access_config {
    access_type        = "SERVICE_ACCOUNT"
    runtime_owner      = local.umsa_fqn
  }

  software_config {
    post_startup_script = "gs://${local.s8s_code_bucket}/bash/mnbs-exec-post-startup.sh"
    post_startup_script_behavior = "DOWNLOAD_AND_RUN_EVERY_START"
  }

  virtual_machine {
    virtual_machine_config {
      machine_type     = local.mnb_server_machine_type
      network = "projects/${local.project_id}/global/networks/s8s-vpc-${local.project_nbr}"
      subnet = "projects/${local.project_id}/regions/${local.location}/subnetworks/${local.spark_subnet_nm}"

      data_disk {
        initialize_params {
          disk_size_gb = "100"
          disk_type    = "PD_STANDARD"
        }
      }
      container_images {
        repository = "gcr.io/deeplearning-platform-release/base-cpu"
        tag = "latest"
      }
    }
  }
  depends_on = [
    time_sleep.sleep_after_storage_steps,
    google_storage_bucket_object.bash_scripts_upload_to_gcs,
    google_storage_bucket_object.notebooks_pyspark_upload_to_gcs,
    google_storage_bucket_object.bash_mnbs_script_upload_to_gcs
  ]
}

/*******************************************
7. Upload Airflow DAG to Composer DAG bucket
******************************************/
# Remove the gs:// prefix and /dags suffix

resource "google_storage_bucket_object" "upload_cc2_dag_to_airflow_dag_bucket" {
  name   = "dags/${local.user_id}-pipeline.py"
  source = "../../02-scripts/airflow/pipeline.py"
  bucket = local.composer_bucket
}

/******************************************
8. Configure Cloud Scheduler to run the function
******************************************/

resource "google_cloud_scheduler_job" "schedule_vai_pipeline" {
  name             = "${local.user_id}_customer_churn_model_training_batch"
  description      = "Customer Churn One-time Model Training Vertex AI Pipeline"
  schedule         = "0 9 * * 1"
  time_zone        = local.cloud_scheduler_timezone
  attempt_deadline = "320s"
  region           = local.location

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.deploy_gcf_vai_pipeline_trigger.service_config[0].uri
    body        = base64encode("{\"foo\":\"bar\"}")
    oidc_token {
      service_account_email = local.umsa_fqn
    }
  }

  depends_on = [
    time_sleep.sleep_after_storage_steps,
    google_storage_bucket_object.gcf_scripts_upload_to_gcs,
    google_cloudfunctions2_function.deploy_gcf_vai_pipeline_trigger
  ]
}


/******************************************
9. Deploy Google Cloud Function to execute VAI pipeline for model training
******************************************/

resource "google_storage_bucket" "create_gcf_source_bucket" {
  name                          = "${local.s8s_functions_bucket}"
  location                      = local.location_multi
  uniform_bucket_level_access   = true
  depends_on = [
    time_sleep.sleep_after_storage_steps
  ]
}

resource "google_storage_bucket_object" "upload_gcf_zip_file" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.create_gcf_source_bucket.name
  source = "../../02-scripts/cloud-functions/function-source.zip"
  depends_on = [
    google_storage_bucket.create_gcf_source_bucket
  ]
}

resource "google_cloudfunctions2_function" "deploy_gcf_vai_pipeline_trigger" {
  provider          = google-beta
  name              = "${local.user_id}-mlops-vai-pipeline-executor-func"
  location          = local.location
  description       = "GCF gen2 to execute a model training Vertex AI pipeline"

  build_config {
    runtime         = "python38"
    entry_point     = "process_request"
    source {
      storage_source {
        bucket = google_storage_bucket.create_gcf_source_bucket.name
        object = google_storage_bucket_object.upload_gcf_zip_file.name
      }
    }
  }

  service_config {
    max_instance_count              = 1
    available_memory                = "256M"
    timeout_seconds                 = 60
    ingress_settings                = "ALLOW_ALL"
    all_traffic_on_latest_revision  = true

    environment_variables = {
        VAI_PIPELINE_JSON_TEMPLATE_GCS_FILE_FQN = "gs://${local.user_id}-s8s_pipeline_bucket-${local.project_nbr}/templates/customer_churn_vai_pipeline_template.json"
        VAI_PIPELINE_JSON_EXEC_DIR_URI = "gs://${local.user_id}-s8s_pipeline_bucket-${local.project_nbr}"
        GCP_LOCATION = local.location
        PROJECT_ID = local.project_id
        VAI_PIPELINE_ROOT_LOG_DIR = "gs://${local.user_id}-s8s_model_bucket-${local.project_nbr}/customer-churn-model/pipelines"
        PIPELINE_NAME="${local.user_id}-customer-churn-prediction-pipeline"
    }
    service_account_email = "s8s-lab-sa@${local.project_id}.iam.gserviceaccount.com"
  }

  depends_on = [
    time_sleep.sleep_after_storage_steps,
    google_storage_bucket_object.gcf_scripts_upload_to_gcs
  ]
}

output "MODEL_TRAINING_VAI_PIPELINE_TRIGGER_FUNCTION_URI" {
  value = google_cloudfunctions2_function.deploy_gcf_vai_pipeline_trigger.service_config[0].uri
}


/******************************************
10. Output important variables needed for the demo
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

output "UMSA_FQN" {
  value = local.umsa_fqn
}

output "DATA_BUCKET" {
  value = local.s8s_data_bucket
}

output "CODE_BUCKET" {
  value = local.s8s_code_bucket
}

output "NOTEBOOK_BUCKET" {
  value = local.s8s_notebook_bucket
}

output "USER_MANAGED_umnb_server_nm" {
  value = local.umnb_server_nm
}

/******************************************
DONE
******************************************/
