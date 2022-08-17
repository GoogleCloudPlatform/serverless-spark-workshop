# Retail store analytics with Serverless Spark Batch through Google cloud console.

Following are the lab modules:

[1. Understanding Data](05b-retail-store-analytics-console-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](05b-retail-store-analytics-console-execution.md#2-solution-architecture)<br>
[3. Create a new serverless batch on Dataproc](05b-retail-store-analytics-console-execution.md#3-create-a-new-serverless-batch-on-dataproc)<br>
[4. Logging](05b-retail-store-analytics-console-execution.md#4-logging)<br>

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

#### 3.1 Defining the Schema

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - SparkSql
- **Query File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_schema_definition_sparksql.sql


<br>

<kbd>
<img src=../images/console1.png />
</kbd>

<br>
<br>

- **Query Parameters** - provide key-value pair of your bucket-name and username like <<your_name_here>>.
- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/parameters.png />
</kbd>

<br>

<kbd>
<img src=../images/console2.png />
</kbd>

<br>
<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/console3.png />
</kbd>

<br>
<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 3.2 Output 

 We can check the output of the batch in dataproc console.
 
 <kbd>
<img src=../images/output1.png />
</kbd>

<br>

#### 3.3 Calculating inventory

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - SparkSql
- **Query File** - gs://<your_code_bucket_name>/retail_store_analytics_metastore_sparksql/00-scripts/retail_analytics_inventory_sparksql.sql


<br>

<kbd>
<img src=../images/5b_inv_01.png />
</kbd>

<br>
<br>

- **Query Parameters** - provide key-value pair of your username like <<your_name_here>>.
- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/parameters.png />
</kbd>

<kbd>
<img src=../images/5b_inv_02.png />
</kbd>

<br>
<br>

- **Metastore Service** - <your_metastore_service_name>
- **History Server Cluster** - <your_phs_cluster_name>
- **Properties** - Add the additional property required for the batch as shown in screenshot.

<br>

<kbd>
<img src=../images/5b_inv_03.png />
</kbd>

<br>
<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 3.4 Output 

 We can check the output of the batch in dataproc console.
 
 <kbd>
<img src=../images/output2.png />
</kbd>

<br>

## 4. Logging

#### 4.1 Serverless Batch logs

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

#### 4.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>

#### 4.3 Metastore logs

To view the metastore logs, click the 'View Logs' button on the metastore page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/meta_logs01.png />
</kbd>

<kbd>
<img src=../images/meta_logs02.png />
</kbd>

<br>