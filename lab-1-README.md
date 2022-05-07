# Lab 1: Cell Tower Anomany Detection

This lab is data engineering centric and uses rules based processing to detect defective cell towers needing maintenance. It is self-contained and fully scripted to follow along at your own pace.

## Prerequisites

Successful environment creation per instructions in go/scw-tf

## About the lab

## The data

## The individual Spark applications & what they do

## The pipeline

## 1. Declare variables

In cloud shell, declare the following variables after substituting with yours. Its useful to persist the variables in a textpad of some kind or http://gist.github.com for ease.

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

## 2. Clone this repo

```
cd ~
git clone https://github.com/anagha-google/s8s-spark-ce-workshop.git
```

## 3. Upload the code and data to the designated GCS bucket
Navigate to the cloned repo and upload the files (code and data) as shown below-
```
cd ~/s8s-spark-ce-workshop/lab-01/
gsutil cp -r cell-tower-anomaly-detection/00-scripts gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/00-scripts
gsutil cp -r cell-tower-anomaly-detection/01-datasets gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/01-datasets
```

## 4. Curate cutsomer master data
In this section, from PySpark, we transform customer master data (parquet) and service threshold data (CSV) and join them, and persist to GCS.<br>

Review the [code] first.

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $LOCATION pyspark \
--batch s8s-lab1-curate-customer-master-$RANDOM \
gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/00-scripts/curate_customer_data.py \
--subnet projects/$PROJECT_ID/regions/$LOCATION/subnetworks/$SPARK_SERVERLESS_SUBNET \
--history-server-cluster=projects/$PROJECT_ID/regions/$LOCATION/clusters/$PERSISTENT_HISTORY_SERVER_NM \
--service-account $UMSA_FQN \
-- $CODE_AND_DATA_BUCKET
```
