In this article we are going to discuss test case on Retail store analytics with Serverless Spark Batch integrated with metastore, both by gcloud command & cloud console.

**Through Gcloud command:**

[1 Declaring variables](unit_test_case.md#1-through-gcloud-command)<br>
[2 Creating external tables](unit_test_case.md#2-creating-external-tables)<br>
[3 Calculating sales_per_dow_per_departmentproduct](unit_test_case.md#3-calculating-sales_per_dow_per_departmentproduct)<br>
[4 Calculating inventory](unit_test_case.md#4-calculating-inventory)<br>
[5 Calculating top 20 and bottom 20 products and suggesting asile id's](unit_test_case.md#4-calculating-top-20-and-bottom-20-products-and-suggesting-asile-id's)<br>
[6 Check the output table in BigQuery](unit_test_case.md#6-check-the-output-table-in-bigquery)<br>

**Through Gcloud console:**

[7 Creating external tables](unit_test_case.md#7-through-gcloud-console)<br>
[8 Calculating sales_per_dow_per_departmentproduct](unit_test_case.md#8-calculating-sales_per_dow_per_departmentproduct)<br>
[9 Calculating inventory](unit_test_case.md#9-calculating-inventory)<br>
[10 Calculating top 20 and bottom 20 products and suggesting asile id's](unit_test_case.md#10-calculating-top-20-and-bottom-20-products-and-suggesting-asile-id's)<br>
[11 Check the output table in BigQuery](unit_test_case.md#11-check-the-output-table-in-bigquery)<br>

**Airflow:**

[12. Uploading DAG files to DAGs folder](unit_test_case.md#12-airflow)<br>
[13. Execution of Airflow DAG](unit_test_case.md#13-execution-of-airflow-dag)<br>


#### 1. Through Gcloud command:

In order to test effectively we need few variables to be declared-

Declaring variables
 
```
PROJECT_ID=tgs-internal-gcpgtminit-dev-01
REGION=us-central1                                           
SUBNET=ss-private-subnet-1                                            
BUCKET_CODE=retail-store-analysis-bucket                                                          
HISTORY_SERVER_NAME=spark-phs                               
UMSA=serverless-spark                              
METASTORE_NAME=ss-metastore                            
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=aj
```

<br>

#### 2. Creating external tables:


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



Output

<br>

<kbd>
<img src=../images/one.PNG />
</kbd>

<br>


Once the job starts executing and the job is in running state , copy the data files one by one from serverless_spark_streaming/01-datasets/data_files  to  /serverless_spark_streaming/01-datasets/streaming_data/ for the streaming job to pick the files  and process them.

#### 3. Calculating sales_per_dow_per_departmentproduct

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


Output

<br>

<kbd>
<img src=../images/Two.PNG />
</kbd>

<br>

#### 4. Calculating inventory

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

Output

<br>

<kbd>
<img src=../images/Th1.PNG />
</kbd>

<br>

<kbd>
<img src=../images/Th2.PNG />
</kbd>

<br>

#### 5. Calculating top 20 and bottom 20 products and suggesting asile id's

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

Output 

<br>

<kbd>
<img src=../images/Four-1.PNG />
</kbd>

<br>

<kbd>
<img src=../images/Four-2.PNG />
</kbd>

<br>

#### 6. Check the output table in BigQuery

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
  SELECT * FROM `tgs-internal-gcpgtminit-dev-01.retailstore_aj_metastore.retailstoreaj_inventory_data` LIMIT 1000;
  SELECT * FROM `tgs-internal-gcpgtminit-dev-01.retailstore_aj_metastore.retailstoreaj_suggested_aisles_data` LIMIT 1000;


```
<br>

<kbd>
<img src=../images/Five.PNG />
</kbd>

<br>

<br>


<kbd>
<img src=../images/Six.PNG />
</kbd>

<br>

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively

<br>



#### 7. Through Gcloud Console


#### 7. Creating external tables.

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics/00-scripts/retail_analytics_table_creation.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/M1.PNG />
</kbd>

<br>

- **Arguments** - <br>
  Four Arguments needs to be provided: <br>
    *  <your_project_name>                                                                      #project name
    *  <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>
    <database_name>                                                                           #retail_store_analytics_database_<your_name_here>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/M2.2.PNG />
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/M3.PNG />
</kbd>

<br>

<br>

<kbd>
<img src=../images/M4.PNG />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 8. Calculating sales_per_dow_per_departmentproduct.

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics/00-scripts/retail_analytics_sales_per_dow_per_departmentproduct.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/Msales.PNG />
</kbd>

<br>


- **Arguments** - <br>
  Four Arguments needs to be provided: <br>
    *  <your_project_name>                                                                      #project name
    *  <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>
    <database_name>                                                                           #retail_store_analytics_database_<your_name_here>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/M2.2.PNG />
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/M3.PNG />
</kbd>

<br>

<br>

<kbd>
<img src=../images/M4.PNG />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 9. Calculating inventory

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics/00-scripts/retail_analytics_inventory.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/Minventory.PNG />
</kbd>

<br>

- **Arguments** - <br>
  Four Arguments needs to be provided: <br>
    *  <your_project_name>                                                                      #project name
    *  <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>
    <database_name>                                                                           #retail_store_analytics_database_<your_name_here>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/M2.2.PNG />
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/M3.PNG />
</kbd>

<br>

<br>

<kbd>
<img src=../images/M4.PNG />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 10. Calculating top 20 and bottom 20 products and suggesting asile id's

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics/00-scripts/retail_analytics_suggestionofaisle_id.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/Maisle.PNG />
</kbd>

<br>

- **Arguments** - <br>
  Four Arguments needs to be provided: <br>
    *  <your_project_name>                                                                      #project name
    *  <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>
    <database_name>                                                                           #retail_store_analytics_database_<your_name_here>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/M2.2.PNG />
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/M3.PNG />
</kbd>

<br>

<br>

<kbd>
<img src=../images/M4.PNG />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 11. Check the output table in BigQuery

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
  SELECT * FROM `tgs-internal-gcpgtminit-dev-01.retailstore_aj_metastore.retailstoreaj_inventory_data` LIMIT 1000;
  SELECT * FROM `tgs-internal-gcpgtminit-dev-01.retailstore_aj_metastore.retailstoreaj_suggested_aisles_data` LIMIT 1000;


```
<br>

<kbd>
<img src=../images/Five.PNG />
</kbd>

<br>

<br>


<kbd>
<img src=../images/Six.PNG />
</kbd>

<br>

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively

<br>



#### 12. Airflow:

#### 12. Uploading DAG files to DAGs folder

* From the code repository, download the file located at: **retail_store_analytics_metastore**>**00-scripts**>**retail-analytics-airflow.py**
* Rename file to <your_name_here>-cell-tower-airflow.py
* Open the file and replace your name on row 22
* Navigate to **Composer**>**<composer_environment>**
* Next, navigate to **Environment Configuration**>**DAGs folder URI**
* Next, upload the DAG file to the GCS bucket corresponding to the **DAGs folder URI**

<kbd>
<img src=../images/composer_2.png />
</kbd>

<br>
<br>
<br>

<kbd>
<img src=../images/composer_3.png />
</kbd>

<br>
<br>
<br>


#### 13. Execution of Airflow DAG

* Navigate to **Composer**>**<your_environment>**>**Open Airflow UI**

<kbd>
<img src=../images/composer_5.png />
</kbd>

<br>

* Once the Airflow UI opens, navigate to **DAGs** and open your respective DAG
* Next, trigger your DAG by clicking on the **Trigger DAG** button

<kbd>
<img src=../images/composer_6.png />
</kbd>

<br>

DAGS folder

<kbd>
<img src=../images/Airflow-2.PNG />
</kbd>

<br>

Variables 

<kbd>
<img src=../images/Airflow-var.PNG />
</kbd>

<br>


* Once the DAG is triggered, the DAG can be monitored directly through the Airflow UI as well as the Dataproc>Serverless>Batches window

<kbd>
<img src=../images/Airflow-final.PNG />
</kbd>

<br>


