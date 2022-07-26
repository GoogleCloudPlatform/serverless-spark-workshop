# Retail store analytics with Serverless Spark Batch through Airflow.

Following are the lab modules:

[1. Understanding Data](07c-retail-store-analytics-airflow-execution.md#1-understanding-data)<br>
[2. Solution Diagram](07c-retail-store-analytics-airflow-execution.md#2-solution-diagram)<br>
[3. Uploading DAG files to DAGs folder](07c-retail-store-analytics-airflow-execution.md#3-uploading-dag-files-to-dags-folder)<br>
[4. Execution of Airflow DAG](07c-retail-store-analytics-airflow-execution.md#4-execution-of-airflow-dag)<br>
[5. BQ Output Tables](07c-retail-store-analytics-airflow-execution.md#5-bq-output-tables)<br>
[6. Logging](07c-retail-store-analytics-airflow-execution.md#6-logging)<br>

## 1. Understanding data
The datasets used for this project are 


1. [Aisles data](../01-datasets/aisles/aisles.csv). <br>
2. [Departments data](../01-datasets/departments/departments.csv) . <br>
3. [Orders data](../01-datasets/orders/orders.csv). <br>
4. [Products data](../01-datasets/products/products.csv). <br>
5. [Order_products__prior](../01-datasets/order_products/order_products__prior.csv). <br>
6. [Order_products__train](../01-datasets/order_products/order_products__train.csv). <br>


- Aisles: This table includes all aisles. It has a single primary key (aisle_id)
- Departments: This table includes all departments. It has a single primary key (department_id)
- Products: This table includes all products. It has a single primary key (product_id)
- Orders: This table includes all orders, namely prior, train, and test. It has single primary key (order_id).
- Order_products_train: This table includes training orders. It has a composite primary key (order_id and product_id)
						and indicates whether a product in an order is a reorder or not (through the reordered variable).
- Order_products_prior : This table includes prior orders. It has a composite primary key (order_id and product_id) and
						indicates whether a product in an order is a reorder or not (through the reordered variable).
<br>

## 2. Solution Diagram

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
	- Create a Cloud Composer environment and Airflow jobs to orchestrate execution of Dataproc serverless batches <br>
	- Creating tables and writing data in Google BigQuery <br>

<br>

## 3. Uploading DAG files to DAGs folder

* From the code repository, download the file located at: **retail_store_analytics_metastore**>**00-scripts**>**retail-analytics-airflow.py**
* Rename file to <your_name_here>-retail-analytics-airflow.py
* Open the file and replace your name on row 23
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


## 4. Execution of Airflow DAG

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

* Once the DAG is triggered, the DAG can be monitored directly through the Airflow UI as well as the Dataproc>Serverless>Batches window

<kbd>
<img src=../images/Airflow-final.PNG />
</kbd>

<br>


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

### 6.1 Airflow logging

* To view the logs of any step of the DAG execution, click on the **<DAG step>**>**Log** button <br>

<kbd>
<img src=../images/composer_8.png />
</kbd>

<br>

### 6.2 Serverless Batch logs

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


### 6.3 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>

### 6.4 Metastore logs

To view the metastore logs, click the 'View Logs' button on the metastore page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/meta_logs01.png />
</kbd>

<kbd>
<img src=../images/meta_logs02.png />
</kbd>

<br>
