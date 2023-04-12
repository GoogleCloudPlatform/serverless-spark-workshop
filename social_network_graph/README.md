# Social Network with Serverless Spark and GraphFrames

## 1. Overview

In this use case, we will use Graphframes with Serverless Spark to build a network of users based on the characters present in the GOT books.

<br>

## 2. Services Used

* Google Cloud Dataproc
* Google Cloud Storage
* Google BigQuery

<br>

## 3. Permissions / IAM Roles required to run the lab

Following permissions / roles are required to execute the serverless batch

- Viewer
- Dataproc Editor
- BigQuery Data Editor
- Service Account User
- Storage Admin

<br>

## 4. Checklist

To perform the lab, below are the list of activities to perform. <br>

[1. GCP Prerequisites](/instructions/01-gcp-prerequisites.md)<br>
[2. Spark History Server Setup](/instructions/02-persistent-history-server.md)<br>
[3. Uploading scripts and datasets to GCP](/instructions/03-files-upload.md)<br>
[4. Creating a BigQuery Dataset](/instructions/04-create-bigquery-dataset.md)<br>

Note down the values for below variables to get started with the lab:

```
PROJECT_ID=                                         #Current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
SUBNET=                                             #subnet which has private google access enabled
BQ_DATASET_NAME=                                    #BigQuery dataset where all the tables will be stored
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
HISTORY_SERVER_NAME=spark-phs                       #name of the history server which will store our application logs
UMSA=serverless-spark                               #user managed service account required for the PySpark job executions
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=<your_name_here>                               #Your Unique Identifier
```
<br>


## 5. Lab Modules

The lab consists of the following modules.

1. Understand the Data
2. Solution Architecture
3. Using GraphFrames to build a network.
4. Explore the output

There are 2 ways of performing the lab.

- Using [Google Cloud Shell with Custom Container](/instructions/06a_social_network_graph_gcloud_container_execution.md)
- Using [GCP console with Custom Container](/instructions/06b_social_network_graph_console_container_execution.md)

Please chose one of the methods to execute the lab.

<br>

## 6. CleanUp

Delete the resources after finishing the lab. <br>
Refer - [Cleanup](/instructions/07-cleanup.md)

<br>
