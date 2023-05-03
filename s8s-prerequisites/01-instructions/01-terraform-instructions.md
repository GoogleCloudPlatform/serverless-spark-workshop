# About Module

This module covers environment provisioning for the Serverless Spark labs.

## Note:

1. **Ensure services in use in the workshop are available in the location of your preference**
- Vertex AI Managed Notebooks are currently available in us-central1, us-west1, us-west4, northamerica-northeast1, southamerica-east1, europe-west1, europe-west4, asia-northeast1, asia-southeast1, asia-south1, asia-east2, australia-southeast1, asia-northeast3

2. Get allow listed for the Private Preview Services

- Fill out https://docs.google.com/forms/d/e/1FAIpQLSccIXlE5gJNE0dNs6vQvCfrCcSjnoHqaW2lxpoVkAh56KLOwA/viewform to get allowlisted for access to Serverless Spark interactive (Jupyter, Vertex AI workbench) private preview

- Fill out https://docs.google.com/forms/d/e/1FAIpQLSe3t0tk0N_385rdRoeXg1TD8roPcLeG3Vt-5VNhnVwwWlZlJQ/viewform to get allowlisted for BigQuery Stored Procedures for Spark private preview

3. Once the resources are created, share the locally created file with the list of GCP resource names with the workshop attendees

## 2. Create the environment

### 2.1. IAM Roles needed to execute the prereqs

Ensure that you have **Security Admin**, **Project IAM Admin**, **Service Usage Admin**, **Service Account Admin** and **Role Administrator** roles. This is needed for creating the GCP resources and granting access to attendees.

### 2.2. Clone the Repository and Navigate to the Terraform provisioning directory

Run the following commands in your cloud shell instance:<br>

```
cd ~
git clone https://github.com/GoogleCloudPlatform/serverless-spark-workshop
cd serverless-spark-workshop/s8s-prerequisites/00-scripts-and-config
```

### 2.3. Define variables for use

Modify the below as appropriate for your deployment. Be sure to use the right case for GCP region.<br>
Regions and zones listing can be found [here](https://cloud.google.com/compute/docs/regions-zones)(zone has a -a/b/c as suffix to region/location).<br>

```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
GCP_ACCOUNT_NAME=`gcloud auth list --filter=status:ACTIVE --format="value(account)"`
CLOUD_COMPOSER_IMG_VERSION="composer-2.1.14-airflow-2.4.3"
SPARK_CUSTOM_CONTAINER_IMAGE_TAG="1.0.0"
GCP_REGION=<YOUR_GCP_REGION>
CUSTOM_CONTAINER=<1 or 0. Set this value to 1 if you need a custom container, otherwise set it to 0>
CREATE_COMPOSER=<1 or 0. Set this value to 1 if you need a Composer environment, otherwise set it to 0>
CREATE_METASTORE=<1 or 0. Set this value to 1 if you need a Dataproc Metastore, otherwise set it to 0>

echo "PROJECT_ID=$PROJECT_ID"
echo "PROJECT_NBR=$PROJECT_NBR"
echo "GCP_ACCOUNT_NAME=$GCP_ACCOUNT_NAME"
echo "CLOUD_COMPOSER_IMG_VERSION=$CLOUD_COMPOSER_IMG_VERSION"
echo "SPARK_CUSTOM_CONTAINER_IMAGE_TAG=$SPARK_CUSTOM_CONTAINER_IMAGE_TAG"
echo "GCP_REGION=$GCP_REGION"
echo "CUSTOM_CONTAINER=$CUSTOM_CONTAINER"
echo "CREATE_COMPOSER=$CREATE_COMPOSER"
echo "CREATE_METASTORE=$CREATE_METASTORE"
```

### 2.4. Initialize Terraform

Needs to run in cloud shell from ~/s8s-prerequisites/00-scripts-and-config

```
cd ~/serverless-spark-workshop/s8s-prerequisites/00-scripts-and-config/terraform
terraform init
```

### 2.5. Review the Terraform deployment plan

Needs to run in cloud shell from ~/s8s-prerequisites/00-scripts-and-config

```
cd ~/serverless-spark-workshop/s8s-prerequisites/00-scripts-and-config/terraform

terraform plan \
  -var="project_id=${PROJECT_ID}" \
  -var="project_number=${PROJECT_NBR}" \
  -var="gcp_account_name=${GCP_ACCOUNT_NAME}" \
  -var="cloud_composer_image_version=${CLOUD_COMPOSER_IMG_VERSION}" \
  -var="spark_container_image_tag=${SPARK_CUSTOM_CONTAINER_IMAGE_TAG}" \
  -var="gcp_region=${GCP_REGION}" \
  -var="custom_container=${CUSTOM_CONTAINER}" \
  -var="create_composer=${CREATE_COMPOSER}" \
  -var="create_metastore=${CREATE_METASTORE}"
```

### 2.6. Provision the environment

Needs to run in cloud shell from ~/s8s-prerequisites/00-scripts-and-config

```
cd ~/serverless-spark-workshop/s8s-prerequisites/00-scripts-and-config/terraform

terraform apply \
-var="project_id=${PROJECT_ID}" \
-var="project_number=${PROJECT_NBR}" \
-var="gcp_account_name=${GCP_ACCOUNT_NAME}" \
-var="cloud_composer_image_version=${CLOUD_COMPOSER_IMG_VERSION}" \
-var="spark_container_image_tag=${SPARK_CUSTOM_CONTAINER_IMAGE_TAG}" \
-var="gcp_region=${GCP_REGION}" \
-var="custom_container=${CUSTOM_CONTAINER}" \
-var="create_composer=${CREATE_COMPOSER}" \
-var="create_metastore=${CREATE_METASTORE}" \
--auto-approve
```

### 2.7. Saving GCP resource names to a local file

Once the Terraform script completes execution, run the following commands in Cloud Shell and share the locally created 'resource-list.txt' file with all workshop attendees

```
cd ~/serverless-spark-workshop/s8s-prerequisites/00-scripts-and-config/terraform
terraform output > resource-list.txt
```

### 2.8. Cloning repository to GCP bucket

Execute the following commands in Cloud Shell to clone the lab artifacts to your GCP bucket

```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
cd ~
git clone https://github.com/GoogleCloudPlatform/serverless-spark-workshop
gsutil cp -r serverless-spark-workshop gs://s8s-code-and-data-bucket-$PROJECT_NBR
```

## 3. Roles required for the Hackfest Attendees

Please grant the following GCP roles to all attendees to execute the hands-on labs:<br>

```
Viewer
Dataproc Editor
BigQuery Data Editor
Service Account User
Storage Admin
Environment User and Storage Object Viewer
Notebooks Runner
```
