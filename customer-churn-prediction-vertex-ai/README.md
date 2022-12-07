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
 
# Retail reorder prediction using Vertex AI

## 1. Overview

With the advent of cloud environments, the concept of huge capital investments in infrastructure in terms of capital and maintenance is a thing of the past. Even when it comes to provisioning infrastructure on cloud services, it can get tedious and cumbersome.

In this example, you will look at executing a simple PySpark code which runs on Serverless batch (a fully managed Dataproc cluster). It is similar to executing code on a Dataproc cluster without the need to initialize, deploy or manage the underlying infrastructure.

In this use case, we will be building a predictive model capable of using customer orders collected over time to predict which previously purchased products will be in a user’s next order.
<br>
## Services Used
* Google Cloud Storage
* Google Cloud Dataproc
* Google Cloud Bigquery
* Google Cloud VertexAI

## 3. Permissions / IAM Roles required to run the lab

Following permissions / roles are required to execute the serverless batch

- Viewer
- Dataproc Editor
- BigQuery Data Editor
- Service Account User
- Storage Admin
- Notebooks Runner

<br>

## 4. Checklist

To perform the lab, below are the list of activities to perform. <br>

[1. GCP Prerequisites](instructions/01-gcp-prerequisites.md)<br>
[2. Spark History Server Setup](instructions/02-persistent-history-server.md)<br>
[3. Creating a GCS Bucket and Uploading Files](instructions/03-files-upload.md)<br>
[4. Creating a BigQuery Dataset](instructions/04-create-bigquery-dataset.md)<br>

Note down the values for below variables to get started with the lab:

```
PROJECT_ID=                                         #Current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
SUBNET=                                             #subnet which has private google access enabled
BQ_DATASET_NAME=                                    #BigQuery dataset where all the tables will be stored
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
BUCKET_PHS=                                         #bucket where our application logs created in the history server will be stored
HISTORY_SERVER_NAME=                                #name of the history server which will store our application logs
UMSA_NAME=                                          #user managed service account required for the PySpark job executions
SERVICE_ACCOUNT=$UMSA_NAME@$PROJECT_ID.iam.gserviceaccount.com
NAME=<your_name_here>                               #Your Unique Identifier
```
<br>

## 5. Lab Modules

Following are the lab modules:

1. Understanding Data
2. Solution Architecture
3. Execution
4. Logging

The ways to perform the lab is, 
- Using [GCP sessions through Vertex AI](instructions/05a_customer_churn_vertex_ai_notebook_execution.md)



<br>

## 6. CleanUp

Delete the resources after finishing the lab. <br>
Refer - [Cleanup](instructions/06-cleanup.md )

<br>
