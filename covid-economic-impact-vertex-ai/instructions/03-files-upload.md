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
REGION= #Region to be used
BUCKET_CODE= #bucket where code files and datasets will be uploaded

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
<img src=/images/files_upload.png />
</kbd>

<br>
