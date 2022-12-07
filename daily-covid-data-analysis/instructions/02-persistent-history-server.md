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

This module includes all prerequisites for running the Serverless Spark lab-<br>
[1. Declare variables](02-persistent-history-server.md#1-declare-variables)<br>
[2. Create a Bucket](02-persistent-history-server.md#2-create-a-bucket)<br>
[3. Create a Spark Persistent History Server](02-persistent-history-server.md#3-create-a-spark-persistent-history-server)<br>

                                   
## 0. Prerequisites 

#### 1. GCP Project Details
Note the project number and project ID. <br>
We will need this for the rest fo the lab

#### 2. IAM Roles needed to create Persistent History Server
Grant the following permissions
- Viewer
- Dataproc Editor
- Storage Admin
                                

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com) <br>
Run the below command to set the project in the cloud shell terminal:
```
gcloud config set project $PROJECT ID

```

<br>

## 1. Declare variables 

We will use these throughout the lab. <br>
Run the below in cloud shells coped to the project you selected-

```
PROJECT_ID=#Project ID
REGION=#Region to be used
BUCKET_PHS=#Bucket name for Persistent History Server
PHS_NAME=#PHS cluster name
SUBNET=#Your VPC subnet name
```

<br>

## 2. Create a bucket

A bucket is created which will be attached to history server for storing of application logs.

```
gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION -b on gs://$BUCKET_PHS
```

<br>

## 3. Create a Spark Persistent History Server

A single node dataproc cluster will be created with component gateways enabled.

```
gcloud dataproc clusters create $PHS_NAME \
  --project=${PROJECT_ID} \
  --region=${REGION} \
  --single-node \
  --subnet=$SUBNET \
  --image-version=2.0 \
  --enable-component-gateway \
  --properties=spark:spark.history.fs.logDirectory=gs://${BUCKET_PHS}/phs/*/spark-job-history
```