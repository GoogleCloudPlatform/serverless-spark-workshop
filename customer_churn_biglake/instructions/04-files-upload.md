# About

This module includes all the steps for creating a GCS bucket, and uploading the code files and datasets-<br>
[1. Declare variables](03-files-upload.md#1-declare-variables)<br>
[2. GCS Bucket creation](03-files-upload.md#2-gcs-bucket-creation)<br>
[3. Uploading the repository to GCS Bucket](03-files-upload.md#3-uploading-the-repository-to-gcs-bucket)<br>


## 0. Prerequisites

#### 1. Create a project new project or select an existing project.
Note the project number and project ID. <br>
We will need this for the rest for the lab

#### 2. IAM Roles needed to execute the commands below
- Storage Admin

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)
Run the below
```
gcloud config set project $PROJECT_ID

```

<br>

## 1. Declare variables

We will use these throughout the lab. <br>
Run the below in cloud shells coped to the project you selected-

```
PROJECT_ID= #Project ID
REGION=#Region to be used
BUCKET_CODE=#bucket where code files and datasets will be uploaded
CONNECTION_ID=#Cloud Resource connection id
BQ_DATASET_NAME=#Your BQ dataset
BIGLAKE_TABLE_NAME=#Your BigLake table
```

<br>

## 2. GCS Bucket creation:

Run the following gcloud command in Cloud Shell to create the bucket to store datasets and scripts.

<hr>

```
gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION -b on gs://$BUCKET_CODE
```

<br>

## 3. Uploading the repository to GCS Bucket:


To upload the code repository, please follow the below steps:
* Extract the compressed code repository folder to your local Machine
* Next, navigate to the bucket created in previous step for storing the code and data files and upload the extracted code repository by using the 'Upload Folder' option in Google Cloud Storage Bucket as shown below:

<br>

<kbd>
<img src=../images/files_upload.png />
</kbd>

<br>

## 4. Creating a Cloud Resource Connection:

Run the following command in cloud shell to create the cloud resource connection:<br>

```
bq mk --connection --location=$REGION --project_id=$PROJECT_ID \
    --connection_type=CLOUD_RESOURCE $CONNECTION_ID
```

## 5. Retrieving Service Account ID:

Run the following command in cloud shell and copy the Service Account Id:<br>

```
bq show --connection $PROJECT_ID.$REGION.$CONNECTION_ID
```

Grant the necessary permissions to the Service Account:<br>

```
gsutil iam ch serviceAccount:<your_service_account_id_here>:objectViewer gs://$BUCKET_CODE
```

## 6. Create a BigLake table:

```
bq mk --table \
  --external_table_definition=@CSV=gs://$BUCKET_CODE/customer_churn_biglake/01-datasets/customer_churn_test_model_data.csv@projects/$PROJECT_ID/locations/$REGION/connections/$CONNECTION_ID \
  $BQ_DATASET_NAME.$BIGLAKE_TABLE_NAME \
  customerID:STRING,gender:STRING,SeniorCitizen:INTEGER,Partner:STRING,Dependents:STRING,tenure:INTEGER,PhoneService:STRING,MultipleLines:STRING,InternetService:STRING,OnlineSecurity:STRING,OnlineBackup:STRING,DeviceProtection:STRING,TechSupport:STRING,StreamingTV:STRING,StreamingMovies:STRING,Contract:STRING,PaperlessBilling:STRING,PaymentMethod:STRING,MonthlyCharges:FLOAT,TotalCharges:FLOAT
```
