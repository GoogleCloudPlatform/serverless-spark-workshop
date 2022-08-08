# CellTower Anomaly Detection with Serverless Spark Batch

**Goal** - Detecting anomalous cell towers using network and customer data through serverless.

Following are the lab modules:

[1. Understanding Data](06a-cell-tower-anomaly-gcloud-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](06a-cell-tower-anomaly-gcloud-execution.md#2-solution-diagram)<br>
[3. Declaring Variables](06a-cell-tower-anomaly-gcloud-execution.md#3-declaring-variables)<br>
[4. Running the job as a serverless batch on Dataproc](06a-cell-tower-anomaly-gcloud-execution.md#4-running-the-job-as-a-serverless-batch-on-dataproc)<br>
[5. BQ output tables](06a-cell-tower-anomaly-gcloud-execution.md#5-bq-output-tables)<br>
[6. Logging](06a-cell-tower-anomaly-gcloud-execution.md#6-logging)<br>

## 1. Understanding the data

The datasets used for this project are

1.[telecom_customer_churn_data.csv](../01-datasets/telecom_customer_churn_data.csv) <br>
2.[service_threshold_data.csv](../01-datasets/service_threshold_data.csv) <br>
3.[customer_data](../01-datasets/cust_raw_data/L1_Customer_details_raw_part-00000-fc7d6e20-dbda-4143-91b5-d9414310dfd1-c000.snappy.parquet) <br>

- Telecom Customer Churn Data   - This dataset contains information of services provided to the customers by the celltowers.
- Service Threshold Data -  This dataset contains the performance metrics thresold information of the celltowers.
- Cust Raw Data - This is a folder which contains the files which are in parquet format and holds the information of the customer data.


## 2. Solution Diagram

<kbd>
<img src=../images/Flow_of_Resources.jpeg />
</kbd>

<br>
<br>

**Model Pipeline**

The model pipeline involves the following steps: <br>
	- Create buckets in GCS <br>
	- Create Dataproc and Persistent History Server Cluster <br>
	- Copy the raw data files, pyspark and notebook files into GCS <br>
	- Create a Cloud Composer environment and Airflow jobs to as Serverless spark job <br>
	- Creating external tables on GCS bucket data in Google BigQuery <br>

<br>


## 3. Declaring Variables

#### 3.1 Set the PROJECT_ID in Cloud Shell

Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)<br>
Run the below
```
gcloud config set project <enter your project id here>

```

####  3.2 Verify the PROJECT_ID in Cloud Shell

Next, run the following command in cloud shell to ensure that the current project is set correctly:

```
gcloud config get-value project
```

####  3.3 Declare the variables

Based on the prereqs and checklist, declare the following variables in cloud shell by replacing with your values:


```
PROJECT_ID=$(gcloud config get-value project)       #current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
SUBNET=                                             #subnet which has private google access enabled
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
BUCKET_PHS=                                         #bucket where our application logs created in the history server will be stored
HISTORY_SERVER_NAME=                                #name of the history server which will store our application logs
BQ_DATASET_NAME=                                    #BigQuery dataset where all the tables will be stored
UMSA=serverless-spark                               #name of the user managed service account required for the PySpark job executions
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=                                               #your name
```

### 3.4 Update Cloud Shell SDK version

Run the below on cloud shell-
```
gcloud components update

```

## 4.  Running the job as a serverless batch on Dataproc

* Execute the following gcloud commands in cloud shell in the given order to execute the different steps of the cell towr anomaly detection pipeline

**Cleaning and Joining Customer with Services Threshold Data**

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-cell-tower-$RANDOM \
gs://$BUCKET_CODE/cell-tower-anomaly-detection/00-scripts/customer_threshold_join.py \
--subnet $SUBNET \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME
```

**Cleaning and Joining Customer Services with Telecom Data**

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-cell-tower-$RANDOM \
gs://$BUCKET_CODE/cell-tower-anomaly-detection/00-scripts/customer_threshold_services_join.py \
--subnet $SUBNET \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME
```


**Customer Service Data Aggregation Workflow**

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-cell-tower-$RANDOM \
gs://$BUCKET_CODE/cell-tower-anomaly-detection/00-scripts/customer_service_indicator.py \
--subnet $SUBNET \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME
```


**Celltower Performance Metrics Aggregation Workflow**

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-cell-tower-$RANDOM \
gs://$BUCKET_CODE/cell-tower-anomaly-detection/00-scripts/cell_tower_performance_indicator.py \
--subnet $SUBNET \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME
```

## 5. BQ output tables

Navigate to BigQuery Console, and check the **cell_tower_anomaly_detection** dataset. <br>
Once the Airflow DAG execution is completed, two new tables '<your_name_here>_cell_tower_performance_data' and '<your_name_here>_customer_service_metrics_data' will be created:

<br>

<kbd>
<img src=../images/bq_1.png />
</kbd>

<br>

To view the data in these tables -

* Select the table from BigQuery Explorer by navigating 'project_id' **>** 'dataset' **>** 'table_name'
* Click on the **Preview** button to see the data in the table

<br>

<kbd>
<img src=../images/bq_preview.png />
</kbd>

<br>

**Note:** If the **Preview** button is not visible, run the below queries to view the data. However, these queries will be charged for the full table scan.

```
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_cell_tower_performance_data` LIMIT 1000;
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_customer_service_metrics_data` LIMIT 1000;
```

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively

<br>

<kbd>
<img src=../images/bq_2.png />
</kbd>

<br>

## 6. Logging

### 6.1 Serverless Batch logs

Logs associated with the application can be found in the logging console under
**Dataproc > Serverless > Batches > <batch_name>**.
<br> You can also click on “View Logs” button on the Dataproc batches monitoring page to get to the logging page for the specific Spark job.

<kbd>
<img src=../images/image10.png />
</kbd>

<kbd>
<img src=../images/image11.png />
</kbd>

<br>

### 6.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>
