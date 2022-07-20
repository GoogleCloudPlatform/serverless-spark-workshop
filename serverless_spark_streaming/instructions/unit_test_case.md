In this article we are going to discuss Serverless Spark Streaming through Google Cloud Shell command & gcloud console.

**Through Gcloud command:**

[1 Declaring variables](unit_test_case.md#1-through-gcloud-command)<br>
[2 Running the job as a serverless batch on Dataproc](unit_test_case.md#2-running-the-job-as-a-serverless-batch-on-dataproc)<br>
[3 Command to copy Files](unit_test_case.md#3-command-to-copy-files)<br>
[4 Testing Serverless streaming Job](unit_test_case.md#4-testing-serverless-streaming-job)<br>
[5. Check the output table in BigQuery](unit_test_case.md#5-check-the-output-table-in-bigquery)<br>

**Through Gcloud console:**

[6 Provide the details for the batch](unit_test_case.md#6-provide-the-details-for-the-batch)<br>
[7 Command to copy Files](unit_test_case.md#7-command-to-copy-files)<br>
[8 Testing Serverless streaming Job](unit_test_case.md#8-testing-serverless-streaming-job)<br>
[9 Check the output table in BigQuery](unit_test_case.md#9-check-the-output-table-in-bigquery)<br>

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
NAME=aj
```

<br>

## 2. Running the job as a serverless batch on Dataproc:

```
gcloud dataproc batches submit \
  --project $PROJECT_ID \
  --region $REGION \
  pyspark --batch $NAME-batch-${RANDOM} \
  gs://$BUCKET_CODE/serverless_spark_streaming/00-scripts/spark_streaming_invoice.py  \
  --jars gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar \
  --subnet $SUBNET \
  --service-account $SERVICE_ACCOUNT \
  --history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
  -- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE $NAME

```

We can check the output of the batch in dataproc console.

Batch id: **aj-batch-558**

## Output

<br>

<kbd>
<img src=../images/spark-stream-batch.PNG />
</kbd>

<br>


Once the job starts executing and the job is in running state , copy the data files one by one from serverless_spark_streaming/01-datasets/data_files  to  /serverless_spark_streaming/01-datasets/streaming_data/ for the streaming job to pick the files  and process them.

#### 3 Command to copy Files.

```
gsutil cp gs://$BUCKET_CODE/serverless_spark_streaming/01-datasets/data_files/<<file_name>>  gs://$BUCKET_CODE/serverless_spark_streaming/01-datasets/streaming_data/

```

Note :
- **<<file_name>>**: Provide the file names one by one.

<br>

## Output
<br>

<kbd>
<img src=../images/spark-stream-copy.PNG />
</kbd>

<br>

## 4. Testing Serverless streaming Job.

Run the following command in bigquery to check how the serverless streaming job is processing the files when ever we place the files in source folder.


```
  select count(*) as count from `tgs-internal-gcpgtminit-dev-01.serverless_spark_stream_aj.aj_invoicedata`
  
```

The count gives the number of records processed.

<br>


## 5. Check the output table in BigQuery

Navigate to BigQuery Console, and check the **serverless spark streaming** dataset. <br>
Once the data preparation batch is completed, four new tables '<your_name_here>_ec_status', '<your_name_here>_countries', '<your_name_here>_stocks' and '<your_name_here>_times' will be created :

To query the data and view all the data, run the following query - 
```
  select * from `tgs-internal-gcpgtminit-dev-01.serverless_spark_stream_aj.aj_invoicedata` 
  
```

**Note:** Edit all occurrences of <GCP-PROJECT-NAME> and <BQ-DATASET-NAME> to match the values of the variables PROJECT_ID,user_name and BQ_DATASET_NAME respectively

<kbd>
<img src=../images/table1.PNG />
</kbd>

<br>




To query the data to find the count of data, run the following query - 
```
  select count(*) as count from `tgs-internal-gcpgtminit-dev-01.serverless_spark_stream_aj.aj_invoicedata`
  
```

**Note:** Edit all occurrences of <GCP-PROJECT-NAME> and <BQ-DATASET-NAME> to match the values of the variables PROJECT_ID,user_name and BQ_DATASET_NAME respectively

<kbd>
<img src=../images/table2.PNG />
</kbd>

<br>

<br>

<br>




##2. Through Gcloud Console

### 6.  Provide the details for the batch

Next, fill in the following values in the batch creation window as shown in the images below:

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/serverless_spark_streaming/00-scripts/spark_streaming_invoice.py
- **JAR Files** - gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar
- **Arguments** - <br>
  Four Arguments needs to be provided. <br>
    * <your_project_id>
    * <your_dataset_name>
    * <your_code_bucket_name>
    * <your_name>

<br>

  **Note:** Press RETURN after each argument

- **Service Account** - <your_service_account_name>
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled
Run PySpark Serverless Batch for Data Preparation
- **History Server Cluster** - <your_phs_cluster_name>

<kbd>
<img src=../images/creation1.PNG />
</kbd>

<hr>

<br> 

<kbd>
<img src=../images/creation2.PNG />
</kbd>

  <kbd>
  <img src=../images/creation3.PNG />
  </kbd>

<br>

<kbd>
<img src=../images/creation4.PNG />
</kbd>

<hr>


Submit the Serverless batch
Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.


<br>


Once the job starts executing and the job is in running state , copy the data files one by one from serverless_spark_streaming/01-datasets/data_files  to  /serverless_spark_streaming/01-datasets/streaming_data/ for the streaming job to pick the files  and process them.

#### 7. Command to copy Files.

```
gsutil cp gs://$BUCKET_CODE/serverless_spark_streaming/01-datasets/data_files/<<file_name>>  gs://$BUCKET_CODE/serverless_spark_streaming/01-datasets/streaming_data/

```

Note :
- **<<file_name>>**: Provide the file names one by one.

<br>

#### 8. Testing Serverless streaming Job.

Run the following command in bigquery to check how the serverless streaming job is processing the files when ever we place the files in source folder.


```
  select count(*) as count from `tgs-internal-gcpgtminit-dev-01.serverless_spark_stream_aj.aj_invoicedata`
  
```

The count gives the number of records processed.

<br>

### 9. Check the output table in BigQuery

Navigate to BigQuery Console, and check the **serverless spark streaming** dataset. <br>
Once the data preparation batch is completed, four new tables '<your_name_here>_ec_status', '<your_name_here>_countries', '<your_name_here>_stocks' and '<your_name_here>_times' will be created :

To query the data and view all the data, run the following query - 
```
  select * from `tgs-internal-gcpgtminit-dev-01.serverless_spark_stream_aj.aj_invoicedata` 
  
```

**Note:** Edit all occurrences of <GCP-PROJECT-NAME> and <BQ-DATASET-NAME> to match the values of the variables PROJECT_ID,user_name and BQ_DATASET_NAME respectively

<kbd>
<img src=../images/table1.PNG />
</kbd>

<br>


To query the data to find the count of data, run the following query - 
```
  select count(*) as count from `tgs-internal-gcpgtminit-dev-01.serverless_spark_stream_aj.aj_invoicedata`
  
```

**Note:** Edit all occurrences of <GCP-PROJECT-NAME> and <BQ-DATASET-NAME> to match the values of the variables PROJECT_ID,user_name and BQ_DATASET_NAME respectively

<kbd>
<img src=../images/table2.PNG />
</kbd>

<br>

<br>

<br>


## Output

We can check the output of the batch in dataproc console.
Batch id: batch-aj-spark-stream

<kbd>
<img src=../images/console1.PNG />
</kbd>

<br>
