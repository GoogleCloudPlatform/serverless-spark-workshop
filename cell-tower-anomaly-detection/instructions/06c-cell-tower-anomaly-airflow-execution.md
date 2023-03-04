# Cell Tower Anomaly Detection using Serverless Spark through Google Cloud Composer

**Goal** - Detecting anomalous cell towers using network and customer data through serverless.

Following are the lab modules:

[1. Understanding Data](06c-cell-tower-anomaly-airflow-execution.md#1-understanding-the-data)<br>
[2. Solution Diagram](06c-cell-tower-anomaly-airflow-execution.md#2-solution-diagram)<br>
[3. Uploading DAG files to DAGs folder](06c-cell-tower-anomaly-airflow-execution.md#3-uploading-dag-files-to-dags-folder)<br>
[4. Execution of Airflow DAG](06c-cell-tower-anomaly-airflow-execution.md#4-execution-of-airflow-dag)<br>
[5. BQ Output Tables](06c-cell-tower-anomaly-airflow-execution.md#5-bq-output-tables)<br>
[6. Logging](06c-cell-tower-anomaly-airflow-execution.md#6-logging)<br>

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
	- Copy the raw data files, PySpark and notebook files into GCS <br>
	- Create a Cloud Composer environment and Airflow jobs to run the serverless spark job <br>
	- Creating Google BigQuery tables with summary of anomalous cell towers <br>

<br>

## 3. Uploading DAG files to DAGs folder

* From the code repository, download the file located at: **cell-tower-anomaly-detection**>**00-scripts**>**cell-tower-airflow.py**
* Rename file to <your_name_here>-cell-tower-airflow.py
* Open the file and replace your name on row 21
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
<img src=../images/composer_7.png />
</kbd>

<br>


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
