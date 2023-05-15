# Customer Churn using Serverless Spark through Google Cloud Console

**Goal** -  Data Preparation and Model Training for Detecting Customer Churn.

Following are the lab modules:

[1. Understanding Data](instructions/05_customer_churn_console_execution.md#1-understanding-data)<br>
[2. Solution Architecture](instructions/05_customer_churn_console_execution.md#2-solution-architecture)<br>
[3. Parameter Requirements for the lab](instructions/05_customer_churn_console_execution.md#3-parameters-required-for-the-lab)<br>
[4. Data Preparation](instructions/05_customer_churn_console_execution.md#4-data-preparation)<br>
[5. Model Training and Testing](instructions/05_customer_churn_console_execution.md#5-model-training-and-testing)<br>
[6. Model Evaluation](instructions/05_customer_churn_console_execution.md#6-model-evaluation)<br>
[7. Logging](instructions/05_customer_churn_console_execution.md#7-logging)<br>
[8. Fine Grained Access Control on BigLake Tables](instructions/05_customer_churn_console_execution.md#8-fine-grained-access-control-on-biglake-tables)<br>

<br>

## 1. Understanding Data

The dataset used for this project is [customer churn data](01-datasets/customer_churn_train_data.csv) and [customer test data](01-datasets/customer_churn_test_data.csv).. <br>

The dataset contains the following features:

- Churn - Binary field which represents customers who left/were retained within the last month
- Services that each customer has signed up for – phone, multiple lines, internet, online security, online backup, device protection, tech support, and streaming TV and movies
- Customer account information – how long they’ve been a customer, contract, payment method, paperless billing, monthly charges, and total charges
- Demographic info about customers – gender, age range, and if they have partners and dependents

**Note:** The following features refer to these same-host connections.

- serror_rate
- rerror_rate
- same_srv_rate
- diff_srv_rate
- srv_count

**Note:** The following features refer to these same-service connections.
- srv_serror_rate
- srv_rerror_rate
- srv_diff_host_rate

<br>

## 2. Solution Architecture

<kbd>
<img src=../images/sa.png />
</kbd>

<br>
<br>

**Model Pipeline**

The model pipeline involves the following steps:
 - Data cleanup and preparation
 - Building and training a Machine Learning Model (Random Forest Classifier) before saving it into a GCS bucket
 - Using the model built in above step to evaluate test data

<br>


## 3. Parameters required for the lab

Keep the following details handy for configuring the serverless batch jobs:

```
PROJECT_ID=                                         #current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
BQ_DATASET_NAME=                                    #BigQuery dataset where all the tables will be stored
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
HISTORY_SERVER_NAME=                                #name of the history server which will store our application logs
VPC_NAME=                                           #Primary VPC containing the subnet
SUBNET=                                             #subnet which has private google access enabled
UMSA=                                               #name of the user managed service account required for the PySpark job executions
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=                                                #Your unique identifier
```
**Note:** The values for all the above parameters will be provided by the admin team.

<br>

## 4. Data Preparation

Based on EDA, the data preparation script has been created. Among the 21 columns, relevant features have been selected and stored in BQ for the next step of model training.

### 4.1. Create a new batch
Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

<kbd>
<img src=../images/image23.png />
</kbd>

### 4.2. Provide the details for the batch

Next, fill in the following values in the batch creation window as shown in the images below:

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Runtime Version** - 1.1
- **Main Python File** - gs://<your_code_bucket_name>/customer_churn_biglake/00-scripts/customer_churn_data_prep.py
- **Arguments** - <br>
  Four Arguments needs to be provided. <br>
    * <your_project_id>
    * <your_dataset_name>
    * <your_code_bucket_name>
    * <your_name>
  **Note:** Press RETURN after each argument

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled
- **History Server Cluster** - <your_phs_cluster_name>



<kbd>
<img src=../images/image1_1.png />
</kbd>

<br>

<kbd>
<img src=../images/image2_2.png />
</kbd>

<br>

  <kbd>
  <img src=../images/image1_3.png />
  </kbd>

<br>

### 4.3. Submit the Serverless batch
Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

### 4.4. Check the output table in BQ

Navigate to BigQuery Console, and check the **customer_churn_lab** dataset. <br>
Once the data preparation batch is completed, new tables  '<your_name_here>_training_data' and '<your_name_here>_test_data' will be created.

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
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_training_data` LIMIT 1000
```

<kbd>
<img src=../images/image5.png />
</kbd>

```
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_test_data` LIMIT 1000
```

<your_name_here>: _test_data table

<kbd>
<img src=../images/_test_data.png />
</kbd>

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively

<br>


## 5. Model Training and Testing

Repeat the same steps as above to submit another batch for model training.

### 5.1. Create a new batch
Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

<kbd>
<img src=../images/image23.png />
</kbd>

### 5.2. Provide the details for the batch

Next, fill in the following values in the batch creation window as shown in the images below:

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Runtime Version** - 1.1
- **Main Python File** - gs://<your_code_bucket_name>/customer_churn_biglake/00-scripts/customer_churn_model_building.py
- **Arguments** - <br>
  Four Arguments needs to be provided. <br>
    * <your_project_id>
    * <your_dataset_name>
    * <your_code_bucket_name>
    * <your_name>
  **Note:** Press RETURN after each argument
- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled
- **History Server Cluster** - <your_phs_cluster_name>


<kbd>
<img src=../images/image2_1.png />
</kbd>

<br>

<kbd>
<img src=../images/image2_2.png />
</kbd>

<br>

<kbd>
<img src=../images/image1_3.png />
</kbd>

<br>

### 5.3. Submit the Serverless batch
Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

### 5.4. Query the model_test results BQ table

Navigate to BigQuery Console, and check the **customer_churn_lab** dataset. <br>
Once the modeling  batch is completed, a new table '<your_name_here>_predictions_data' will be created.

To view the data in this table -

* Select the table from BigQuery Explorer by navigating 'project_id' **>** 'dataset' **>** 'table_name'
* Click on the **Preview** button to see the data in the table

<br>

<kbd>
<img src=../images/bq_preview.png />
</kbd>

<br>

**Note:** If the **Preview** button is not visible, run the below queries to view the data. However, these queries will be charged for the full table scan.


```
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_predictions_data` LIMIT 1000;
```

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively


<kbd>
<img src=../images/image6.png />
</kbd>

<br>
<br>
<br>

## 6. Model Evaluation

Repeat the same steps as above to submit another batch for model training.

### 6.1. Create a new batch
Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

<kbd>
<img src=../images/image23.png />
</kbd>

### 6.2. Provide the details for the batch

Next, fill in the following values in the batch creation window as shown in the images below:

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Runtime Version** - 1.1
- **Main Python File** - gs://<your_code_bucket_name>/customer_churn_biglake/00-scripts/customer_churn_model_testing.py
- **Arguments** - <br>
  Five Arguments needs to be provided. <br>
    * <your_project_id>
    * <your_dataset_name>
    * <your_code_bucket_name>
    * <your_name>
    * <your_biglake_table_name>

  **Note:** Press RETURN after each argument
- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled
- **History Server Cluster** - <your_phs_cluster_name>


<kbd>
<img src=../images/image3_1.png />
</kbd>

<br>

<kbd>
<img src=../images/image3_2.png />
</kbd>

<br>

<kbd>
<img src=../images/image1_3.png />
</kbd>

<br>

### 6.3. Submit the Serverless batch
Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

### 6.4. Query the model_test results BQ table

Navigate to BigQuery Console, and check the **customer_churn_lab** dataset. <br>
Once the model_testing  batch is completed, a new table '<your_name_here>_test_output' will be created.

To view the data in this table -

* Select the table from BigQuery Explorer by navigating 'project_id' **>** 'dataset' **>** 'table_name'
* Click on the **Preview** button to see the data in the table

<br>

<kbd>
<img src=../images/bq_preview.png />
</kbd>

<br>

**Note:** If the **Preview** button is not visible, run the below queries to view the data. However, these queries will be charged for the full table scan.


```
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_test_output` LIMIT 1000;
```

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively


<kbd>
<img src=../images/image7.png />
</kbd>

<br>
<br>
<br>

## 7. Logging

### 7.1 Serverless Batch logs

Logs associated with the application can be found in the logging console under
**Dataproc > Serverless > Batches > <batch_name>**.
<br> You can also click on “View Logs” button on the Dataproc batches monitoring page to get to the logging page for the specific Spark job.

<kbd>
<img src=../images/image8.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>

### 7.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image17.png />
</kbd>

<kbd>
<img src=../images/image14.png />
</kbd>

<br>

## 8. Fine Grained Access Control on BigLake Tables

### 8.1 Create Taxonomy and Policy Tag

- Navigate to 'BigQuery'>'Policy tags' and click 'Create Taxonomy'
- Next, fill in the following details:
  * Taxonomy name: Business-Critical-Taxonomy
  * Description: Taxonomy to protect business critical fields
  * Location: <The region name provided by the Admin team>
  * Policy tag name: High
  * Description: High criticality fields
- Click 'Create'

<kbd>
<img src=../images/image8_1.png />
</kbd>

- Next, 'Enforce Access Control' by sliding the switch as shown in the screenshot below:

<kbd>
<img src=../images/image8_2.png />
</kbd>

### 8.2 Assigning Policy Tag to BigLake table

- Navigate to 'BigQuery', 'SQL workspace' and open the BigLake table created earlier
- Click on 'Edit Schema'

<kbd>
<img src=../images/image8_3.png />
</kbd>

- From the column list, select the 'Contract', 'PaymentMethod' and 'MonthlyCharges' columns and click on 'Add Policy Tag'

<kbd>
<img src=../images/image8_4.png />
</kbd>

<kbd>
<img src=../images/image8_5.png />
</kbd>

- From the pop-up, select the tag named 'High' under 'Business-Critical-Taxonomy' and click 'Select'

<kbd>
<img src=../images/image8_6.png />
</kbd>

- Click 'Save'

<kbd>
<img src=../images/image8_7.png />
</kbd>

- Open a new query editor tab and run the following query.

```
SELECT * FROM `<your-project-id>.<your-dataset-id>.<your-biglake-table-name>` LIMIT 1000;
```

- You should see the following 'Access Denied' error on the columns on which the Policy Tag is enforced.

<kbd>
<img src=../images/image8_8.png />
</kbd>

- Next, run the following query to view the data in the columns to which you have access.

```
SELECT * except(Contract, MonthlyCharges, PaymentMethod) FROM `<your-project-id>.<your-dataset-id>.<your-biglake-table-name>` LIMIT 1000;
```

<kbd>
<img src=../images/image8_9.png />
</kbd>
