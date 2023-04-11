# About

This module includes the cleanup of resources created for the lab.

[1. Declare variables](07-cleanup.md#1-declare-variables)<br>
[2. Delete Buckets](07-cleanup.md#2-delete-buckets)<br>
[3. Delete Spark Persistent History Server](07-cleanup.md#3-delete-spark-persistent-history-server)<br>
[4. Delete Docker image](07-cleanup.md#4-delete-docker-image)<br>
                                   
## 0. Prerequisites 

#### 1. GCP Project Details
Note the project number and project ID. <br>
We will need this for the rest fo the lab

#### 2. IAM Roles needed to create Persistent History Server
Grant the following permissions
- Viewer
- Dataproc Editor
- Storage Admin
- BigQuery DataEditor
- Service Usage Admin
                                

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com) <br>
Run the below command to set the project in the cloud shell terminal:
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
BUCKET_PHS= #Bucket name for Persistent History Server
BUCKET_CODE=
BQ_DATASET_NAME=
CONTAINER_IMAGE=gcr.io/project-id/graphframe-image:1.0.1 #Container Image needs to be provided
```

<br>

## 2. Delete buckets

Follow the commands to delete the following buckets 
1. Bucket attached to spark history server
2. Bucket with code files

```
gcloud alpha storage rm --recursive gs://$BUCKET_PHS
gcloud alpha storage rm --recursive gs://$BUCKET_CODE
```

<br>

## 3. Delete Spark Persistent History Server

Run the below command to delete Spark PHS

```
gcloud dataproc clusters delete spark-phs \
  --region=${REGION} 
```

<br>

## 4. Delete Docker image

Run the below command to delete the Docker image

```
gcloud container images delete $CONTAINER_IMAGE
```
