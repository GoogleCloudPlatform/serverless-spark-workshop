# Retail store analytics with Serverless Spark Batch through Google Cloud Shell.

Following are the lab modules:

[1. Understanding Data](05a-retail-store-analytics-gcloud-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](05a-retail-store-analytics-gcloud-execution.md#2-solution-architecture)<br>
[3. Declaring Variables](05a-retail-store-analytics-gcloud-execution.md#3-declaring-variables)<br>
[4. Running the job as a serverless batch on Dataproc](05a-retail-store-analytics-gcloud-execution.md#4-running-the-job-as-a-serverless-batch-on-dataproc)<br>
[5. Logging](05a-retail-store-analytics-gcloud-execution.md#5-logging)<br>

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
UMSA=serverless-spark                               #name of the user managed service account required for the PySpark job executions
METASTORE_NAME=                                     #Name of the metastore which will store our schema
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=                                               #your unique identifier
```

### 3.4 Update Cloud Shell SDK version
Run the below on cloud shell-
```
gcloud components update
```


## 4.  Running the job as a serverless batch on Dataproc

* Execute the following gcloud commands in cloud shell in the given order to execute the different steps of the retail store analytics pipeline

#### 4.1 Defining the Schema

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION spark-sql \
--batch $NAME-retail-analytics-schema-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_schema_definition_sparksql.sql \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--vars="bucket-name=$BUCKET_CODE,username=$NAME" \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME 

```

#### 4.2  Output 

 We can check the output of the batch in dataproc console.
 
 <kbd>
<img src=../images/output1.png />
</kbd>

#### 4.3 Calculating Inventory


```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION spark-sql \
--batch $NAME-retail-analytics-inventory-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_inventory_sparksql.sql \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--vars="username=$NAME" \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME \
--properties spark.hadoop.hive.cli.print.header=true

```

#### 4.4 Output 

 We can check the output of the batch in dataproc console.
 
 <kbd>
<img src=../images/output2.png />
</kbd>


## 5. Logging

#### 5.1 Serverless Batch logs

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

#### 5.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>

#### 5.3 Metastore logs

To view the metastore logs, click the 'View Logs' button on the metastore page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/meta_logs01.png />
</kbd>

<kbd>
<img src=../images/meta_logs02.png />
</kbd>

<br>