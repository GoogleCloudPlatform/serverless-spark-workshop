# Graph Data Analysis with Serverless Spark and iGraph

## 1. Overview

In this use case, we will use a grpah dataset with Serverless Spark on R to build a network of users based on the characters present in the GOT books.

<br>

## 2. Services Used

* Google Cloud Dataproc
* Google Cloud Storage
* Google Artifact Registry

## 3. Permissions / IAM Roles required to run the lab

Following permissions / roles are required to execute the serverless batch

- Viewer
- Dataproc Editor
- Service Account User
- Storage Admin

## 4. Checklist

To perform the lab, below are the list of activities to perform. <br>

[1. GCP Prerequisites](/instructions/01-gcp-prerequisites.md)<br>
[2. Spark History Server Setup](/instructions/02-persistent-history-server.md)<br>
[3. Uploading scripts and datasets to GCP](/instructions/03-files-upload.md)<br>
[4. Creating a custom container image](/instructions/04-create-docker-image.md)<br>

Note down the values for below variables to get started with the lab:

```
PROJECT_ID                                         #Current GCP project where we are building our use case
REGION                                             #GCP region where all our resources will be created
SUBNET                                             #subnet which has private google access enabled
BUCKET_CODE                                        #GCP bucket where our code, data and model files will be stored
HISTORY_SERVER_NAME                                #Name of the history server which will store our application logs
UMSA                                               #User managed service account required for the PySpark job executions
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=<your_name_here>                              #Your Unique Identifier
```

## 5. Lab Modules

The lab consists of the following modules.

1. Understand the Data
2. Solution Architecture
3. Using the graph dataset to build a network
4. Explore the output

There are 4 ways of perforing the lab.
- Using [Google Cloud Shell](/instructions/05a_social_network_graph_gcloud_execution.md)
- Using [GCP console](/instructions/05b_social_network_graph_console_execution.md)

Please chose one of the methods to execute the lab.