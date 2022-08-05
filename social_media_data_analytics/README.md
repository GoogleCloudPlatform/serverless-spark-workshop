# Social Media Data Analysis using Vertex AI and Serverless Spark

Lab contributed by: [TEKsystems](https://www.teksystems.com/en/about-us/partnerships/google-cloud)

## Overview

With the advent of cloud environments, the concept of huge capital investments in infrastructure in terms of capital and maintenance is a thing of the past. Even when it comes to provisioning infrastructure on cloud services, it can get tedious and cumbersome.

In this example, you will look at executing a simple PySpark code which runs on Serverless batch (a fully managed Dataproc cluster). It is similar to executing code on a Dataproc cluster without the need to initialize, deploy or manage the underlying infrastructure.<br>

This repository processes tweets data using spark and finds out most popular trending #tags, 
plots a bar graph for the types of tweets and 
their followers count and also plots a map about the origin of the tweets. 

## Services Used
* Google Cloud Storage
* Google Cloud Dataproc
* Google Cloud VertexAI

## 3. Permissions / IAM Roles required to run the lab

Following permissions / roles are required to execute the serverless batch

- Viewer
- Dataproc Editor
- Service Account User
- Storage Admin
- Notebooks Runner

<br>

## 4. Checklist

To perform the lab, below are the list of activities to perform. <br>

[1. GCP Prerequisites](instructions/01-gcp-prerequisites.md)<br>
[2. Spark History Server Setup](instructions/02-persistent-history-server.md)<br>
[3. Creating a GCS Bucket ad Uploading the Files](instructions/03-files-upload.md)<br>
[4. Creating a docker image](instructions/04-create-docker-image.md)<br>


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
CONTAINER_IMAGE=gcr.io/<<project-name>>/<<image-name>>:1.0.1 #Container Image needs to be provided
NAME=<your_name_here>                               #Your Unique Identifier
```
<br>

## 5. Lab Modules

The lab consists of the following modules.

1. Understand the Data
2. Solution Architecture
3. Executing ETL
4. Examine the logs
5. Explore the output

There is one way of performing the lab.
- Using [GCP sessions through Vertex AI](instructions/05-social-media-data-analytics-vertex-ai-notebook-execution.md)

<br>

## 6. CleanUp

Delete the resources after finishing the lab. <br>
Refer - [Cleanup](instructions/06-cleanup.md )

<br>
