In this article we are going to discuss test case on Retail store analytics with Serverless Spark Batch integrated with metastore and SparkSQL, both by gcloud command & cloud console.

**Through Gcloud command:**

[1 Declaring variables](unit_test_case.md#1-through-gcloud-command)<br>
[2 Defining the Schema](unit_test_case.md#2-defining-the-schema)<br>
[3 Calculating Inventory](unit_test_case.md#3-calculating-inventory)<br>

**Through Gcloud console:**

[4 Defining the Schema](unit_test_case.md#4-defining-the-schema)<br>
[5 Calculating Inventory](unit_test_case.md#5-calculating-inventory)<br>

## 1. Through Gcloud command:

In order to test effectively we need few variables to be declared-

Declaring variables
 
```
PROJECT_ID=tgs-internal-gcpgtminit-dev-01
REGION=us-central1                                           
SUBNET=ss-private-subnet-1                                            
BUCKET_CODE=retail_spark_sql_test                                                          
HISTORY_SERVER_NAME=spark-phs                               
UMSA=serverless-spark                              
DIRECTORY_NAME=hh_retail_store
METASTORE_NAME=retail-analytics-metastore                            
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=sc
```

<br>

Running the job as a serverless batch on Dataproc:

## 2 Defining the Schema

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION spark-sql \
--batch $NAME-retail-analytics-schema-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_schema_defination_Sparksql.sql \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--vars="bucket-name=$BUCKET_CODE,directory-name=$DIRECTORY_NAME" \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME 
```

We can check the output of the batch in dataproc console.

Batch id: **sc-retail-analytics-schema-6469**

<br>

<kbd>
<img src=../images/schema_gcloud.png />
</kbd>

<br>


## 3 Calculating Inventory

```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION spark-sql \
--batch $NAME-retail-analytics-inventory-$RANDOM \
gs://$BUCKET_CODE/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_inventory_Sparksql.sql \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
--vars="directory-name=$DIRECTORY_NAME" \
--metastore-service projects/$PROJECT_ID/locations/$REGION/services/$METASTORE_NAME \
--properties spark.hadoop.hive.cli.print.header=true
```


We can check the output of the batch in dataproc console.

Batch id: **sc-retail-analytics-inventory-3521**

<br>

<kbd>
<img src=../images/inventory_gcloud.png />
</kbd>

<br>

## 2. Through Gcloud console:

## 4 Defining the Schema

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - SparkSql
- **Query File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_schema_defination_Sparksql.sql


<br>

<kbd>
<img src=../images/schema_console_test_01.png />
</kbd>

<br>
<br>

- **Query Parameters** - provide key-value pair of your bucket-name and directory name
- **Service Account** - <your_service_account_name>
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/schema_console_test_02.png />
</kbd>

<br>
<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/schema_console_test_03.png />
</kbd>

<br>
<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

## Output 
 We can check the output of the batch in dataproc console.

 Batch id: **sc-retail-analytics-schema-console-6469**
 
 <kbd>
<img src=../images/schema_console.png />
</kbd>

<br>

## 5 Calculating inventory

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - SparkSql
- **Query File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_inventory_Sparksql.sql


<br>

<kbd>
<img src=../images/inventory_console_test_01.png />
</kbd>

<br>
<br>

- **Query Parameters** - provide key-value pair of your bucket-name
- **Service Account** - <your_service_account_name>
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/inventory_console_test_02.png />
</kbd>

<br>
<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/inventory_console_test_03.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

## Output 
 We can check the output of the batch in dataproc console.
 
 Batch id: **sc-retail-analytics-inventory-console-3521**
 
 <kbd>
<img src=../images/inventory_console.png />
</kbd>

<br>