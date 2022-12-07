<!---->
  Copyright 2022 Google LLC
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
 <!---->

# About

This module includes the cleanup of resources created for the lab.

[1. Declare variables](06-cleanup.md#1-declare-variables)<br>
[2. Delete Buckets](06-cleanup.md#2-delete-buckets)<br>
[3. Delete Spark Persistent History Server](06-cleanup.md#3-delete-spark-persistent-history-server)<br>
[4. Delete BQ Dataset](06-cleanup.md#4-delete-bq-dataset)<br>

                                   
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
gcloud config set project <enter your project id here>

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
```

<br>

## 2. Delete buckets

Follow the commands to delete the following buckets 
1. Bucket attached to spark history server
2. Bucket with code files

```
gcloud alpha storage rm --recursive gs://$BUCKET_PHS
gcloud alpha storage rm --recursive gs://BUCKET_CODE
```

<br>

## 3. Delete Spark Persistent History Server

Run the below command to delete Spark PHS

```
gcloud dataproc clusters delete spark-phs \
  --region=${REGION} 
```

<br>

## 4. Delete BQ Dataset

Run the below command to delete BQ dataset and all the tables within the dataset

```
gcloud alpha bq datasets delete $BQ_DATASET_NAME \
--remove-tables
```

