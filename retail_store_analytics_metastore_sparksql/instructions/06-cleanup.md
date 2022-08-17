# About

This module includes the cleanup of resources created for the lab.

[1. Declare variables](06-cleanup.md#1-declare-variables)<br>
[2. Delete Buckets](06-cleanup.md#2-delete-buckets)<br>
[3. Delete Spark Persistent History Server](06-cleanup.md#3-delete-spark-persistent-history-server)<br>
[4. Delete Metastore service](06-cleanup.md#4-delete-metastore-service)
                                   
## 0. Prerequisites 

#### 1. GCP Project Details
Note the project number and project ID. <br>
We will need this for the rest fo the lab

#### 2. IAM Roles needed to create Persistent History Server
Grant the following permissions
- Viewer
- Dataproc Editor
- Storage Admin
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
PROJECT_ID=                                         #Current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
BUCKET_PHS=                                         #Bucket name for Persistent History Server
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
HISTORY_SERVER_NAME=                                #name of the history server which will store our application logs
ENVIRONMENT_NAME=                                   #Name of the DAGS Environment
LOCATION=                                           #Location of the DAG
PD_NAME=                                            #name of the persistent disk for your environment
PD_LOCATION=                                        #the location of the persistent disk. For example, the location can be [us-central1-a] .
SERVICE=                                            #The name of the metastore service.
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
gcloud dataproc clusters delete $HISTORY_SERVER_NAME \
	--region=${REGION} 
```

<br>


## 4. Delete metastore service

Run the below command to delete metastore service
```
gcloud metastore services delete projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME \
    --location=$LOCATION
```