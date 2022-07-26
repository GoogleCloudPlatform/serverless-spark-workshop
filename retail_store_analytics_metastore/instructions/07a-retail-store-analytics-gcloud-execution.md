# Retail store analytics with Serverless Spark Batch through Google Cloud Shell.

Following are the lab modules:

[1. Understanding Data](07a-retail-store-analytics-gcloud-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](07a-retail-store-analytics-gcloud-execution.md#2-solution-architecture)<br>
[3. Declaring Variables](07a-retail-store-analytics-gcloud-execution.md#3-declaring-variables)<br>
[4. Running the job as a serverless batch on Dataproc](07a-retail-store-analytics-gcloud-execution.md#4-running-the-job-as-a-serverless-batch-on-dataproc)<br>
[5. BQ output tables](07a-retail-store-analytics-gcloud-execution.md#5-bq-output-tables)<br> 
[6. Logging](07a-retail-store-analytics-gcloud-execution.md#6-logging)<br>

## 1. Understanding the data 

The datasets used for this project are 


1. [Aisles data](01-datasets/aisles/aisles.csv). <br>
2. [Departments data](01-datasets/departments/departments.csv) . <br>
3. [Orders data](01-datasets/orders/orders.csv). <br>
4. [Products data](01-datasets/products/products.csv). <br>
5. [Order_products__prior](01-datasets/order_products/order_products__prior.csv). <br>
6. [Order_products__train](01-datasets/order_products/order_products__train.csv). <br>


- Aisles: This table includes all aisles. It has a single primary key (aisle_id)
- Departments: This table includes all departments. It has a single primary key (department_id)
- Products: This table includes all products. It has a single primary key (product_id)
- Orders: This table includes all orders, namely prior, train, and test. It has single primary key (order_id).
- Order_products_train: This table includes training orders. It has a composite primary key (order_id and product_id)
						and indicates whether a product in an order is a reorder or not (through the reordered variable).
- Order_products_prior : This table includes prior orders. It has a composite primary key (order_id and product_id) and
						indicates whether a product in an order is a reorder or not (through the reordered variable).

<br>

## 2. Solution Architecture

<kbd>
<img src=../images/Flow_of_Resources.jpeg />
</kbd>

<br>
<br>

**Data Pipeline**

The data pipeline involves the following steps: <br>
	- Create buckets in GCS <br>
	- Create Dataproc and Persistent History Server Cluster <br>
	- Copy the raw data files, pyspark and notebook files into GCS <br>
	- Create a metastore service in Cloud Dataproc <br>
	- Executing the Dataproc serverless batches through Cloud Shell <br>
	- Creating tables and writing data in Google BigQuery <br>

<br>


## 3. Declaring Variables

#### 3.1 Set the PROJECT_ID in Cloud Shell

Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)<br>
Run the below
```
gcloud config set project $PROJECT_ID

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
METASTORE_NAME                                      #name of the metastore which will store our schema
NAME=                                               #your name
```

### 3.4 Update Cloud Shell SDK version

Run the below on cloud shell-

```
gcloud components update

```

## 4. Running the job as a serverless batch on Dataproc

* Execute the following gcloud commands in cloud shell in the given order to execute the different steps of the retail store analytics pipeline

**Creating external tables**
```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-retail-analytics-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore/00-scripts/retail_analytics_table_creation.py \
--jars gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME retail_store_analytics_database_$NAME
```

**Calculating sales_per_dow_per_departmentproduct**

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-retail-analytics-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore/00-scripts/retail_analytics_sales_per_dow_per_departmentproduct.py \
--jars gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME retail_store_analytics_database_$NAME

```

**Calculating inventory**

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-retail-analytics-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore/00-scripts/retail_analytics_inventory.py \
--jars gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME 
```


**Calculating top 20 and bottom 20 products and suggesting asile id's**

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-retail-analytics-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore/00-scripts/retail_analytics_suggestionofaisle_id.py \
--jars gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME \
-- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME 
```


## 5. BQ output tables

Navigate to BigQuery Console, and check the **retail_store_analytics** dataset. <br>
Once the Serverless batches execution is completed, three new table '<your_name_here>_inventory_data' , '<your_name_here>_suggested_aisles_data' and '<your_name_here>_sales_per_dow_per_departmentproduct' will be created:

<br>

<kbd>
<img src=../images/bigqueryretail.png />
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
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_inventory_data` LIMIT 1000;
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_suggested_aisles_data` LIMIT 1000;


```
<br>

<kbd>
<img src=../images/bq_3.PNG />
</kbd>

<br>

<br>


<kbd>
<img src=../images/bq_2.png />
</kbd>

<br>

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively

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

### 6.3. Metastore logs

To view the metastore logs, click the 'View Logs' button on the metastore page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/meta_logs01.png />
</kbd>

<kbd>
<img src=../images/meta_logs02.png />
</kbd>

<br>
