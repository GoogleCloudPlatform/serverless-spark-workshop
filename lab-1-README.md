# Lab 1: Cell Tower Anomany Detection

This lab is data engineering centric and uses rules based processing to detect defective cell towers needing maintenance. It is self-contained and fully scripted to follow along at your own pace.

## Prerequisites

Successful environment creation per instructions in go/scw-tf

## About the lab

## The data

## The individual Spark applications & what they do

## The pipeline

## 1. Declare variables

In cloud shell, declare the following variables after substituting with yours-
```
PROJECT_ID=YOUR_PROJECT_ID
PROJECT_NBR=YOUR_PROJECT_NUMBER
LOCATION=us-central1
VPC_NM=VPC=s8s-vpc-$PROJECT_NBR
SPARK_SERVERLESS_SUBNET=spark-snet
PERSISTENT_HISTORY_SERVER_NM=s8s-sphs-$PROJECT_NBR
UMSA_FQN=s8s-lab-sa@$PROJECT_ID.iam.gserviceaccount.com
CODE_AND_DATA_BUCKET=s8s_data_and_code_bucket-${PROJECT_NBR}
COMPOSER_ENV=pavarotti-cc2
```

