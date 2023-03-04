# CellTower Anomaly Detection with Serverless Spark Batch

**Goal** - Detecting anomalous cell towers using network and customer data through serverless.

Following are the lab modules:

[1. Understanding Data](06b-cell-tower-anomaly-console-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](06b-cell-tower-anomaly-console-execution.md#2-solution-diagram)<br>
[3. Create a new serverless batch on Dataproc](06b-cell-tower-anomaly-console-execution.md#3-create-a-new-serverless-batch-on-dataproc)<br>
[4. BQ output tables](06b-cell-tower-anomaly-console-execution.md#4-bq-output-tables)<br>
[5. Logging](06b-cell-tower-anomaly-console-execution.md#5-logging)<br>

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

## 3. Create a new serverless batch on Dataproc

#### 3.1 Cleaning and Joining Customer with Services Threshold Data

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/cell-tower-anomaly-detection/00-scripts/customer_threshold_join.py
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
<img src=../images/batch_4_2.png />
</kbd>

<br>

- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_4_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 3.2 Cleaning and Joining Customer Services with Telecom Data

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/cell-tower-anomaly-detection/00-scripts/customer_threshold_services_join.py
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
<img src=../images/batch_4_2.png />
</kbd>

<br>

- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_4_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 3.3 Customer Service Data Aggregation Workflow

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/cell-tower-anomaly-detection/00-scripts/customer_service_indicator.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/batch_3_1.png />
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
<img src=../images/batch_4_2.png />
</kbd>

<br>

- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_4_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

#### 3.4 Cell Tower Performance Metrics Aggregation Workflow

Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window as shown in the images below:

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/cell-tower-anomaly-detection/00-scripts/cell_tower_performance_indicator.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar

<br>

<kbd>
<img src=../images/batch_4_1.png />
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
<img src=../images/batch_4_2.png />
</kbd>

<br>

- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_4_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>



## 4. BQ output tables

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
