# Covid19 Economic Impact Assessment on Serverless Spark

## Overview

With the advent of cloud environments, the concept of huge capital investments in infrastructure in terms of capital and maintenance is a thing of the past. Even when it comes to provisioning infrastructure on cloud services, it can get tedious and cumbersome.

In this example, you will look at executing a simple Spark code which runs on Serverless batch (a fully managed Dataproc cluster). It is similar to executing code on a Dataproc cluster without the need to initialize, deploy or manage the underlying infrastructure.

This repository collects information to assess the _economic impact_ of Covid-19 in the stock market in more than 1850 companies in 50 different countries around the world.
This repository includes a dataset of more than 2.5 million rows with the stock market data of each company that dates back 400 days, which will shows the stock values before the outbreak and the impact during the pandemic.
This repository also includes a file produced by the **Oxford Coronavirus Government Response Tracker (OxCGRT project)** which contains information of each country with a _Government Response Stringency Index_ which indicates the stringency regarding each government's response to reduce the impacts of covid-19 (https://ourworldindata.org/policy-responses-covid#government-stringency-index).

## Services Used
* Google Cloud Storage
* Google Cloud Dataproc
* Google Cloud Bigquery

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

[1. GCP Prerequisites](instructions/01-gcp-prerequisites.md)<br>
[2. Spark History Server Setup](instructions/02-persistent-history-server.md)<br>
[3. Uploading scripts and datasets to GCP](instructions/03-files-upload.md)<br>
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
UMSA_NAME=                                          #user managed service account required for the Spark job executions
SERVICE_ACCOUNT=$UMSA_NAME@$PROJECT_ID.iam.gserviceaccount.com
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

There are 2 ways of perforing the lab.
- Using [Google Cloud Shell](instructions/05a_covid_economic_impact_gcloud_execution.md)
- Using [GCP console](instructions/05b_covid_economic_impact_console_execution.md )

Please chose one of the methods to execute the lab.

<br>

## 6. CleanUp

Delete the resources after finishing the lab. <br>
Refer - [Cleanup](instructions/06-cleanup.md )

<br>
