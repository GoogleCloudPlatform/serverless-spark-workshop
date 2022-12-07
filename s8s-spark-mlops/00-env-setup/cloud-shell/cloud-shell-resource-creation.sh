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
CC_GMSA_FQN=service-$PROJECT_NBR@cloudcomposer-accounts.iam.gserviceaccount.com
GCE_GMSA_FQN=$PROJECT_NBR-compute@developer.gserviceaccount.com
ADMIN_ACCOUNT_ID=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
SPARK_CONTAINER_IMG_TAG=1.0.0
UMSA=s8s-lab-sa
UMSA_FQN=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
BQ_DATAMART_DS=customer_churn_ds
BQ_CONNECTOR_JAR_GCS_URI="gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
CLOUD_COMPOSER2_IMG_VERSION="composer-2.0.11-airflow-2.2.3"
S8S_SPARK_BUCKET=s8s-spark-bucket-$PROJECT_NBR
S8S_SPARK_SPHS_BUCKET=s8s-sphs-$PROJECT_NBR
PHS_CLUSTER_NAME=s8s-sphs-$PROJECT_NBR
VPC_NM=s8s-vpc-$PROJECT_NBR
SUBNET_NM=spark-snet
SUBNET_CIDR=10.0.0.0/16
LOCATION=us-central1
S8S_ARTIFACT_REPOSITORY_NM=s8s-gar-repo-$PROJECT_NBR
METASTORE_NAME=s8s-dpms-$PROJECT_NBR

# 1. Update Organization Policies

gcloud resource-manager org-policies enable-enforce compute.disableSerialPortLogging --project=$PROJECT_ID
gcloud resource-manager org-policies enable-enforce compute.requireOsLogin --project=$PROJECT_ID
gcloud resource-manager org-policies enable-enforce compute.requireShieldedVm --project=$PROJECT_ID
gcloud resource-manager org-policies enable-enforce compute.vmCanIpForward --project=$PROJECT_ID
gcloud resource-manager org-policies enable-enforce compute.vmExternalIpAccess --project=$PROJECT_ID
gcloud resource-manager org-policies enable-enforce compute.restrictVpcPeering --project=$PROJECT_ID

# 2. Enable Google APIs

gcloud services enable orgpolicy.googleapis.com
gcloud services enable dataproc.googleapis.com
gcloud services enable composer.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable metastore.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable notebooks.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudscheduler.googleapis.com

# 3. Create User Managed Service Account

gcloud iam service-accounts create $UMSA \
 --description="User Managed Service Account" \
 --display-name "User Managed Service Account"

## 4a. Grant IAM roles to User Managed Service Account

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/iam.serviceAccountTokenCreator

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/storage.objectAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/storage.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/metastore.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/metastore.editor

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/dataproc.worker

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataEditor

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/dataproc.editor

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/artifactregistry.writer

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/logging.logWriter

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/cloudbuild.builds.editor

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/aiplatform.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/aiplatform.viewer

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/aiplatform.user

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/viewer

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/composer.worker

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/composer.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/cloudfunctions.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/cloudfunctions.serviceAgent

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/cloudscheduler.serviceAgent

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/cloudscheduler.admin

# IAM role grants to Google Managed Service Account for Cloud Composer 2

gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$CC_GMSA_FQN --role roles/composer.ServiceAgentV2Ext

# IAM role grants to google Managed Service Account for Compute Engine

gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$GCE_GMSA_FQN --role roles/editor

# 6. Grant IAM role to Admin User/yourslef

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/storage.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/metastore.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/dataproc.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/bigquery.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/bigquery.user

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/bigquery.dataEditor

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/bigquery.jobUser

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/composer.environmentAndStorageObjectViewer

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/iam.serviceAccountTokenCreator

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/composer.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/aiplatform.user

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/aiplatform.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/compute.networkAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/compute.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$ADMIN_ACCOUNT_ID --role roles/artifactregistry.admin


# 7. Create VPC network, subnet & reserved static IP creation

# 7.a VPC Network
gcloud compute networks create $VPC_NM \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --mtu=1500

# 7.b Subnet
gcloud compute networks subnets create $SUBNET_NM\
    --network=$VPC_NM \
    --range=$SUBNET_CIDR \
    --region=$LOCATION \
    --enable-private-ip-google-access

# 7.c PSA creation
gcloud compute addresses create private-service-access-ip \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --description="DESCRIPTION" \
    --network=$VPC_NM

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges="private-service-access-ip" \
    --network=$VPC_NM \
    --project=$PROJECT_ID

# 8. Create firewall rules
gcloud compute firewall-rules create allow-intra-snet-ingress-to-any \
 --project=$PROJECT_ID  \
 --network=projects/$PROJECT_ID/global/networks/$VPC_NM \
 --description="Creates firewall rule to allow ingress from within Spark subnet on all ports, all protocols" \
 --direction=INGRESS \
 --priority=65534 \
 --source-ranges=$SUBNET_CIDR \
 --action=ALLOW --rules=all

# 9. Create Storage bucket

gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_SPARK_BUCKET
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on gs://$S8S_SPARK_SPHS_BUCKET

# 10. PHS creation

gcloud dataproc clusters create $PHS_CLUSTER_NAME \
  --project=$PROJECT_ID \
  --region=$LOCATION \
  --subnet=$SUBNET_NM \
  --image-version=2.0 \
  --single-node \
  --enable-component-gateway \
  --properties=spark:spark.history.fs.logDirectory=gs://$S8S_SPARK_SPHS_BUCKET/phs/*/spark-job-history

# 11. Artifact registry for Serverless Spark custom container images

gcloud artifacts repositories create $S8S_ARTIFACT_REPOSITORY_NM \
  --repository-format=docker \
  --location=$LOCATION \
  --description="Artifact repository"

# 12. Create Docker Container image for Serverless Spark

/bin/bash ../../02-scripts/bash/build-container-image.sh $SPARK_CONTAINER_IMG_TAG $BQ_CONNECTOR_JAR_GCS_URI $LOCATION

## 13. Create Composer Environment

gcloud composer environments create ${PROJECT_ID}-cc2 \
--location $LOCATION \
--environment-size small \
--image-version $CLOUD_COMPOSER2_IMG_VERSION \
--network $VPC_NM \
--subnetwork $SUBNET_NM \
--web-server-allow-all \
--env-variables AIRFLOW_VAR_PROJECT_ID=$PROJECT_ID,AIRFLOW_VAR_PROJECT_NBR=$PROJECT_NBR,AIRFLOW_VAR_REGION=$LOCATION,AIRFLOW_VAR_SUBNET=$SUBNET_NM,AIRFLOW_VAR_PHS_SERVER=$PHS_CLUSTER_NAME,AIRFLOW_VAR_CONTAINER_IMAGE_URI=gcr.io/$PROJECT_ID/customer_churn_image:$SPARK_CONTAINER_IMG_TAG,AIRFLOW_VAR_BQ_CONNECTOR_JAR_URI=$BQ_CONNECTOR_JAR_GCS_URI,AIRFLOW_VAR_MODEL_VERSION="REPLACE_ME",AIRFLOW_VAR_DISPLAY_PRINT_STATEMENTS=True,AIRFLOW_VAR_BQ_DATASET=$BQ_DATAMART_DS,AIRFLOW_VAR_UMSA_FQN=$UMSA_FQN

# 14. Create Dataproc Metastore

gcloud metastore services create $METASTORE_NAME \
    --location=$LOCATION \
    --network=$VPC_NM \
    --port=9080 \
    --tier="DEVELOPER" \
    --hive-metastore-version=3.1.2

# 15. Output important variables needed for the demo

echo $PROJECT_ID

echo $PROJECT_NBR

echo $LOCATION

echo $VPC_NM

echo $SUBNET_NM

echo $UMSA_FQN
