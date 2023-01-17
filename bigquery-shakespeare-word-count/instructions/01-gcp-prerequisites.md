# About

This module includes all prerequisites for running the Serverless Spark lab-<br>
[1. Enable Google Bigquery APIs](01-gcp-prerequisites.md#1-enable-google-bigquery-apis)<br>
[2. Create dataset in your project](01-gcp-prerequisites.md#2-create-a-new-dataset-in-your-project)<br>
[3. Create Spark Connection](01-gcp-prerequisites.md#3-create-spark-connection)<br>
[4. Grant the Service Account the following roles](01-gcp-prerequisites.md#4-grant-the-service-account-the-following-roles)<br>
                                   
## 0. Prerequisites 

#### 1. Create a project new project or select an existing project.
Note the project number and project ID. <br>
We will need this for the rest fo the lab

#### 2. IAM Roles needed to execute the prereqs
Grant yourself the following roles. <br>
1. roles/bigquery.admin

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com). <br>
Run the below command to set the project to cloud shell terminal:

```
gcloud config set project <enter your project id here>

```

<br>

## 1. Enable Google Bigquery APIs

From cloud shell, run the below-
```
gcloud services enable bigquery.googleapis.com
gcloud services enable bigqueryconnection.googleapis.com
```

<br>

## 2. Create a new dataset in your project

Edit and use the following command to create a dataset in your project environment and use the location that can be throughout the workshop:

```
PROJECT_ID=<your_project_ID>
LOCATION=<insert_the_location>
BIGQUERY_DATASET=<your_bq_dataset_name>

bq --location=$LOCATION mk --dataset $PROJECT_ID:$BIGQUERY_DATASET
```

<br>

## 3. Create Spark Connection

Run the commands below to create a Spark connection required for the hands on lab.

```
bq mk --connection --connection_type='SPARK' \
 --project_id=$PROJECT_ID \
 --location=$LOCATION \
 shakespeare-connection
```

## 4. Grant the Service Account (used to create the Spark connection table) the following roles

### 4.1. Copy the Service Account ID

Run the following code to get the service account ID and copy it to use later

```
bq show --location=$LOCATION --connection $PROJECT_ID.$LOCATION.shakespeare-connection

```

### 4.2. Grant IAM Permissions to the SA

1. Declare the SA variable
```
BQ_SERVICE_ACCOUNT=<Insert_the_Service_account_ID_here>
```

#### 4.2.a.  role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$BQ_SERVICE_ACCOUNT --role roles/storage.admin

```

#### 4.2.b. BigQuery Admin role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$BQ_SERVICE_ACCOUNT --role roles/bigquery.admin

```