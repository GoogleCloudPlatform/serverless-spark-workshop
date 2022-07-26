# Retail store analytics with Serverless Spark Batch through Google cloud console.

Following are the lab modules:

[1. Understanding Data](07b-retail-store-analytics-console-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](07b-retail-store-analytics-console-execution.md#2-solution-architecture)<br>
[3. Create a new serverless batch on Dataproc](07b-retail-store-analytics-console-execution.md#3-create-a-new-serverless-batch-on-dataproc)<br>
[4. BQ output tables](07b-retail-store-analytics-console-execution.md#4-bq-output-tables)<br>
[5. Logging](07b-retail-store-analytics-console-execution.md#5-logging)<br>

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
	- Executing the Dataproc serverless batches through GCP Console <br>
	- Creating tables and writing data in Google BigQuery <br>

<br>

## 3. Create a new serverless batch on Dataproc


#### 3.1 Creating external tables.

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore/00-scripts/retail_analytics_table_creation.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/batches_4.png />
</kbd>

<br>

- **Arguments** - <br>
  Five Arguments needs to be provided: <br>
    * <your_project_name>                                                                      #project name
    * <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>
    * <database_name>                                                                           #retail_store_analytics_database_<your_name_here>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/batch_4_2.png />
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>


#### 3.2 Calculating sales_per_dow_per_departmentproduct.

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore/00-scripts/retail_analytics_sales_per_dow_per_departmentproduct.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/batches_4.png />
</kbd>

<br>

- **Arguments** - <br>
  Five Arguments needs to be provided: <br>
    * <your_project_name>                                                                      #project name
    * <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>
    * <database_name>                                                                           #retail_store_analytics_database_<your_name_here>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/batch_4_2.png />
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>


#### 3.3 Calculating inventory

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore/00-scripts/retail_analytics_inventory.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/batch_1_1.png />
</kbd>

<br>

- **Arguments** - <br>
  Four Arguments needs to be provided: <br>
    *  <your_project_name>                                                                      #project name
    *  <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/batch_4_21.png />
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>
<br>

#### 3.4 Calculating top 20 and bottom 20 products and suggesting asile id's

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore/00-scripts/retail_analytics_suggestionofaisle_id.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/batch_2_1.png />
</kbd>

<br>

- **Arguments** - <br>
  Four Arguments needs to be provided: <br>
    *  <your_project_name>                                                                      #project name
    *  <your_bq_dataset_name>                                                                   #dataset_name
    * <your_code_bucket_name>
    * <your_name>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/batch_4_21.png /> 
</kbd>

<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

<br>

<kbd>
<img src=../images/batch_4_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>


## 4. BQ output tables

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

## 5. Logging

### 5.1 Serverless Batch logs

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

### 5.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>

### 5.3. Metastore logs

To view the metastore logs, click the 'View Logs' button on the metastore page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/meta_logs01.png />
</kbd>

<kbd>
<img src=../images/meta_logs02.png />
</kbd>

<br>
