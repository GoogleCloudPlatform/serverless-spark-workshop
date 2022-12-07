# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PROJECT_ID=$(gcloud config get-value project)
PROJECT_NBR=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")
USER_ID=<your-username-in-all-lowercase-here-with-no-spaces-hyphens-underscores-numbers-or-special-characters>
S8S_DATA_BUCKET=$USER_ID-s8s_data_bucket-$PROJECT_NBR
S8S_CODE_BUCKET=$USER_ID-s8s_code_bucket-$PROJECT_NBR
S8S_NOTEBOOK_BUCKET=$USER_ID-s8s_notebook_bucket-$PROJECT_NBR
S8S_MODEL_BUCKET=$USER_ID-s8s_model_bucket-$PROJECT_NBR
S8S_PIPELINE_BUCKET=$USER_ID-s8s_pipeline_bucket-$PROJECT_NBR
S8S_METRICS_BUCKET=$USER_ID-s8s_metrics_bucket-$PROJECT_NBR
S8S_FUNCTIONS_BUCKET=$USER_ID-s8s_functions_bucket-$PROJECT_NBR
BQ_DATAMART_DS=${USER_ID}_customer_churn_ds
LOCATION_MULTI=US
UNMB_SERVER_NM=$USER_ID-s8s-spark-ml-pipelines-nb-server
MNB_SERVER_NM=$USER_ID-s8s-spark-ml-interactive-nb-server
MNB_SERVER_MACHINE_TYPE=n1-standard-4
SPARK_CONTAINER_IMG_TAG=1.0.0
LOCATION=<your-gcp-region-where-all-resources-will-be-created>
COMPOSER_BUCKET=<your-composer-bucket-name-provided-by-admin>
CLOUD_SCHEDULER_TIMEZONE=<your-cloud-scheduler-timezone>
UMSA=<your-umsa-name-provided-by-admin-here>
UMSA_FQN=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
ZONE=<your-gcp-zone-here>
VPC_NM=<your-vpc-subnet-name-provided-by-admin>
SUBNET_NM=<your-subnet-name-provided-by-admin>

# 1. Create Storage bucket

gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_DATA_BUCKET
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_CODE_BUCKET
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_NOTEBOOK_BUCKET
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_MODEL_BUCKET
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_METRICS_BUCKET
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_PIPELINE_BUCKET

# 2. Customize scripts and notebooks

gsutil cp ../../04-templates/umnbs-exec-post-startup.sh ../../02-scripts/bash/ && sed -i s/PROJECT_NBR/$PROJECT_NBR/g ../../02-scripts/bash/umnbs-exec-post-startup.sh && sed -i s/USER_ID/$USER_ID/g ../../02-scripts/bash/umnbs-exec-post-startup.sh

gsutil cp ../../04-templates/mnbs-exec-post-startup.sh ../../02-scripts/bash/ && sed -i s/PROJECT_NBR/$PROJECT_NBR/g ../../02-scripts/bash/mnbs-exec-post-startup.sh && sed -i s/USER_ID/$USER_ID/g ../../02-scripts/bash/mnbs-exec-post-startup.sh

gsutil cp ../../04-templates/preprocessing.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/$PROJECT_NBR/g ../../03-notebooks/pyspark/preprocessing.ipynb && sed -i s/YOUR_PROJECT_ID/$PROJECT_ID/g ../../03-notebooks/pyspark/preprocessing.ipynb && sed -i s/USER_ID/$USER_ID/g ../../03-notebooks/pyspark/preprocessing.ipynb

gsutil cp ../../04-templates/model_training.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/$PROJECT_NBR/g ../../03-notebooks/pyspark/model_training.ipynb && sed -i s/YOUR_PROJECT_ID/$PROJECT_ID/g ../../03-notebooks/pyspark/model_training.ipynb && sed -i s/USER_ID/$USER_ID/g ../../03-notebooks/pyspark/model_training.ipynb

gsutil cp ../../04-templates/hyperparameter_tuning.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/$PROJECT_NBR/g ../../03-notebooks/pyspark/hyperparameter_tuning.ipynb && sed -i s/YOUR_PROJECT_ID/$PROJECT_ID/g ../../03-notebooks/pyspark/hyperparameter_tuning.ipynb && sed -i s/USER_ID/$USER_ID/g ../../03-notebooks/pyspark/hyperparameter_tuning.ipynb

gsutil cp ../../04-templates/batch_scoring.ipynb ../../03-notebooks/pyspark/ && sed -i s/YOUR_PROJECT_NBR/$PROJECT_NBR/g ../../03-notebooks/pyspark/batch_scoring.ipynb && sed -i s/YOUR_PROJECT_ID/$PROJECT_ID/g ../../03-notebooks/pyspark/batch_scoring.ipynb && sed -i s/USER_ID/$USER_ID/g ../../03-notebooks/pyspark/batch_scoring.ipynb

gsutil cp ../../04-templates/customer_churn_training_pipeline.ipynb ../../03-notebooks/vai-pipelines/ && sed -i s/YOUR_GCP_LOCATION/$LOCATION/g ../../03-notebooks/vai-pipelines/customer_churn_training_pipeline.ipynb && sed -i s/YOUR_SPARK_CONTAINER_IMAGE_TAG/$SPARK_CONTAINER_IMG_TAG/g ../../03-notebooks/vai-pipelines/customer_churn_training_pipeline.ipynb && sed -i s/USER_ID/$USER_ID/g ../../03-notebooks/vai-pipelines/customer_churn_training_pipeline.ipynb

gsutil cp ../../04-templates/pipeline.py ../../02-scripts/airflow/ && sed -i s/USER_ID/$USER_ID/g ../../02-scripts/airflow/pipeline.py

gsutil cp ../../04-templates/batch_scoring.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/$USER_ID/g ../../02-scripts/pyspark/batch_scoring.py

gsutil cp ../../04-templates/hyperparameter_tuning.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/$USER_ID/g ../../02-scripts/pyspark/hyperparameter_tuning.py

gsutil cp ../../04-templates/model_training.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/$USER_ID/g ../../02-scripts/pyspark/model_training.py

gsutil cp ../../04-templates/preprocessing.py ../../02-scripts/pyspark/ && sed -i s/USER_ID/$USER_ID/g ../../02-scripts/pyspark/preprocessing.py

gsutil cp ../../04-templates/Module-01-Environment-Provisioning-Shared.md ../../05-lab-guide/ && sed -i s/USER_ID/$USER_ID/g ../../05-lab-guide/Module-01-Environment-Provisioning-Shared.md

gsutil cp ../../04-templates/Module-03-Author-ML-Experiments-With-Spark-Notebooks.md ../../05-lab-guide/ && sed -i s/USER_ID/$USER_ID/g ../../05-lab-guide/Module-03-Author-ML-Experiments-With-Spark-Notebooks.md

gsutil cp ../../04-templates/Module-04-Author-ML-PySpark-Scripts.md ../../05-lab-guide/ && sed -i s/USER_ID/$USER_ID/g ../../05-lab-guide/Module-04-Author-ML-PySpark-Scripts.md

gsutil cp ../../04-templates/Module-08-Orchestrate-Batch-Scoring.md ../../05-lab-guide/ && sed -i s/USER_ID/$USER_ID/g ../../05-lab-guide/Module-08-Orchestrate-Batch-Scoring.md

mkdir ../../05-pipelines
gsutil cp ../../04-templates/customer_churn_vai_pipeline_template.json ../../05-pipelines/ && sed -i s/YOUR_PROJECT_NBR/$PROJECT_NBR/g ../../05-pipelines/customer_churn_vai_pipeline_template.json && sed -i s/YOUR_PROJECT_ID/$PROJECT_ID/g ../../05-pipelines/customer_churn_vai_pipeline_template.json && sed -i s/YOUR_GCP_LOCATION/$LOCATION/g ../../05-pipelines/customer_churn_vai_pipeline_template.json && sed -i s/USER_ID/$USER_ID/g ../../05-pipelines/customer_churn_vai_pipeline_template.json

# 3. Copy of datasets, scripts and notebooks to buckets

gsutil cp -r ../../01-datasets/* gs://$S8S_DATA_BUCKET

gsutil cp -r ../../02-scripts/* gs://$S8S_CODE_BUCKET

gsutil cp -r ../../03-notebooks/* gs://$S8S_NOTEBOOK_BUCKET

gsutil cp -r ../../05-pipelines/* gs://$S8S_PIPELINE_BUCKET

# 4. BigQuery dataset creation

bq mk $BQ_DATAMART_DS

# 5. Vertex AI Workbench - User Managed Notebook Server Creation

gcloud notebooks instances create $UNMB_SERVER_NM \
--location=$ZONE \
--machine-type=e2-medium \
--service-account=$UMSA_FQN \
--network=projects/$PROJECT_ID/global/networks/$VPC_NM \
--subnet=projects/$PROJECT_ID/regions/$LOCATION/subnetworks/$SUBNET_NM \
--post-startup-script=gs://$S8S_CODE_BUCKET/bash/umnbs-exec-post-startup.sh \
--vm-image-project="deeplearning-platform-release" \
--vm-image-family="common-cpu"

# 6. Vertex AI Workbench - Managed Notebook Server Creation

gcloud notebooks runtimes create $MNB_SERVER_NM \
--location=$LOCATION \
--runtime-access-type=SERVICE_ACCOUNT \
--runtime-owner=$UMSA_FQN \
--post-startup-script=gs://$S8S_CODE_BUCKET/bash/mnbs-exec-post-startup.sh \
--machine-type=$MNB_SERVER_MACHINE_TYPE

# 7. Upload Airflow DAG to Composer DAG bucket

gsutil cp ../../02-scripts/airflow/pipeline.py gs://$COMPOSER_BUCKET/dags/$USER_ID-pipeline.py

# 8. Deploy Google Cloud Function to execute VAI pipeline for model training

gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION_MULTI -b on gs://$S8S_FUNCTIONS_BUCKET
gsutil cp ../../02-scripts/cloud-functions/function-source.zip gs://$S8S_FUNCTIONS_BUCKET

gcloud functions deploy $USER_ID-mlops-vai-pipeline-executor-func \
--trigger-location=$LOCATION \
--runtime=python38 \
--gen2 \
--region=$LOCATION \
--entry-point=process_request \
--source=gs://$S8S_FUNCTIONS_BUCKET/function-source.zip \
--max-instances=1 \
--memory=256m \
--timeout=60s \
--ingress-settings=all \
--serve-all-traffic-latest-revision \
--service-account=$UMSA@$PROJECT_ID.iam.gserviceaccount.com \
--trigger-http \
--set-env-vars=VAI_PIPELINE_JSON_TEMPLATE_GCS_FILE_FQN=gs://$USER_ID-s8s_pipeline_bucket-$PROJECT_NBR/templates/customer_churn_vai_pipeline_template.json,VAI_PIPELINE_JSON_EXEC_DIR_URI=gs://$USER_ID-s8s_pipeline_bucket-$PROJECT_NBR,GCP_LOCATION=$LOCATION,PROJECT_ID=$PROJECT_ID,VAI_PIPELINE_ROOT_LOG_DIR=gs://$USER_ID-s8s_model_bucket-$PROJECT_NBR/customer-churn-model/pipelines,PIPELINE_NAME=$USER_ID-customer-churn-prediction-pipeline

# 9. Configure Cloud Scheduler to run the function

cloud_function_url=$(gcloud functions describe $USER_ID-mlops-vai-pipeline-executor-func --gen2 --region=$LOCATION --format="value(serviceConfig.uri)")

gcloud scheduler jobs create http ${USER_ID}_customer_churn_model_training_batch \
--description="Customer Churn One-time Model Training Vertex AI Pipeline" \
--schedule="0 9 * * 1" \
--time-zone=$CLOUD_SCHEDULER_TIMEZONE \
--attempt-deadline="320s" \
--location=$LOCATION \
--max-retry-attempts=1 \
--http-method=POST \
--uri=$cloud_function_url \
--oidc-service-account-email=$UMSA_FQN \
--message-body="{\"foo\":\"bar\"}"

# 10. Output important variables needed for the demo

echo $PROJECT_ID

echo $PROJECT_NBR

echo $LOCATION

echo $UMSA_FQN

echo $S8S_DATA_BUCKET

echo $S8S_CODE_BUCKET

echo $S8S_NOTEBOOK_BUCKET
