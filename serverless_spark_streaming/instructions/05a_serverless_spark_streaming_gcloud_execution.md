# Serverless Spark Streaming through Google Cloud Shell



Following are the lab modules:

[1. Understanding Data](05a_serverless_spark_streaming_gcloud_execution.md#1-understanding-data)<br>
[2. Solution Architecture](05a_serverless_spark_streaming_gcloud_execution.md#2-solution-architecture)<br>
[3. Declaring Variables](05a_serverless_spark_streaming_gcloud_execution.md#3-declaring-cloud-shell-variables)<br>
[4. Execution](05a_serverless_spark_streaming_gcloud_execution.md#4-execution)<br>
[5. Logging](05a_serverless_spark_streaming_gcloud_execution.md#5-logging)<br>

<br>

## 1. Understanding Data

## Data Files

The data used for this project are:

- InvoiceNumber   -  a unique, sequential code that is systematically assigned to invoices.
- CreatedTime     -  time , when invoice is created.
- StoreID         -  ID of the store where purchase is done.
- PosID           -  
- CustomerType    - type of the customer, whether they are PRIME/NON PRIME member.
- PaymentMethod   - type of payment done.
- DeliveryType    - type of delivery done for the purchased products.
- City            - city in which product is to be delivered.
- State           - state in which product is to be delivered.
- PinCode         - pincode of the city in which product is to be delivered.
- ItemCode        - itemcode of the purchased product.
- ItemDescription - description of the item purchased.
- ItemPrice       - price of the purchased item.
- ItemQty         - quantity of the item purchased.
- TotalValue      - price to be paid for the purchased product.

<br>

## 2. Solution Architecture
 
 
![this is a screenshot of the solution diagram](../images/Flow_of_Resources.png)
 

## 3. Declaring cloud shell variables

#### 3.1 Set the PROJECT_ID in Cloud Shell

Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)<br>
Run the below
```
gcloud config set project $PROJECT_ID

```

#### 3.2 Verify the PROJECT_ID in Cloud Shell

Next, run the following command in cloud shell to ensure that the current project is set correctly:

```
gcloud config get-value project
```

#### 3.3 Declare the variables

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
NAME=                                               #Your unique identifier
```

**Note:** For all the variables except 'NAME', please ensure to use the values provided by the admin team.

<br>



### 3.4 Update Cloud Shell SDK version
Run the below on cloud shell-
```
gcloud components update
```


## 4. Execution 


#### 4.1. Run PySpark Serverless Batch

Run the below on cloud shell -
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

<br>

Once the job starts executing and the job is in running state , copy the data files one by one from serverless_spark_streaming/01-datasets/data_files  to  /serverless_spark_streaming/01-datasets/streaming_data/ for the streaming job to pick the files  and process them.

For copying the files open new cloud shell and declare the following variables and Run the following commands.

#### 4.2.1 Declare the variables

```
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored

```

#### 4.2.2 Command to copy Files.

```
gsutil cp gs://$BUCKET_CODE/serverless_spark_streaming/01-datasets/data_files/<<file_name>>  gs://$BUCKET_CODE/serverless_spark_streaming/01-datasets/streaming_data/

```

Note :
- **<<file_name>>**: Provide the file names one by one.

<br>


#### 4.2.3 Check the output table in BigQuery

Navigate to BigQuery Console, and check the **serverless spark streaming** dataset. <br>
As the files get processed, one new table '<your_name_here>_invoicedata' will be created and the data will be inserted into this table:

To view the data in these tables -

* Select the table from BigQuery Explorer by navigating 'project_id' **>** 'dataset' **>** 'table_name'
* Click on the **Preview** button to see the data in the table

<br>

**Note:** If the **Preview** button is not visible, run the below queries to view the data. However, these queries will be charged for the full table scan.
<br>

To query the data and view all the data, run the following query - 

```
 select * from `<GCP-PROJECT-NAME>.<BQ-DATASET-NAME>.<user_name>_invoicedata` 
```

**Note:** Edit the occurrence of <GCP-PROJECT-NAME> and <BQ-DATASET-NAME> to match the values of the variables PROJECT_ID,user_name and BQ_DATASET_NAME respectively

<kbd>
<img src=../images/bq1.png />
</kbd>

<br>

<br>
To find the count of data, run the following query - 

```
  select count(*) as count from `<GCP-PROJECT-NAME>.<BQ-DATASET-NAME>.<user_name>_invoicedata`
```

**Note:** Edit all occurrences of <GCP-PROJECT-NAME> and <BQ-DATASET-NAME> to match the values of the variables PROJECT_ID,user_name and BQ_DATASET_NAME respectively

<kbd>
<img src=../images/bq2.png />
</kbd>

<br>

<br>

<br>

## 4.3  Stop the Serverless Batch.

For stopping the serverless batch open new gcloud shell and  Declare the following variables and Run the following command.

#### 4.3.1 Declare variables

```
BATCH_ID =                                        # Batch Id of the batch running.
PROJECT_ID=$(gcloud config get-value project)       #current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
```

#### 4.3.2 Command to stop the batch

Run the following command in gcloud shell-

```
gcloud dataproc batches cancel $BATCH_ID \
--project=$PROJECT_ID \
--region=$REGION
```

## 5. Logging

#### 5.1 Serverless Batch logs

Logs associated with the application can be found in the logging console under 
**Dataproc > Serverless > Batches > <batch_name>**. 
<br> You can also click on “View Logs” button on the Dataproc batches monitoring page to get to the logging page for the specific Spark job.

<kbd>
<img src=../images/image10.PNG />
</kbd>

<kbd>
<img src=../images/image11.png />
</kbd>

<br>

#### 5.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page so the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.PNG />
</kbd>

<kbd>
<img src=../images/image13.PNG />
</kbd>

<br>
