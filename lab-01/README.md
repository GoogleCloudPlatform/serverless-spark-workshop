# Lab 1: Cell Tower Anomany Detection

This lab is data engineering centric and uses rules based processing to detect defective cell towers needing maintenance. It is self-contained and fully scripted to follow along at your own pace.

## 1. Prerequisites

Successful environment creation per instructions in go/scw-tf

## 2. About the lab

## 3. About the data

## 4. The individual Spark applications & what they do

## 5. Declare variables

In cloud shell, declare the following variables after substituting with yours. Its useful to persist the variables in a textpad of some kind or http://gist.github.com for ease.

```
PROJECT_ID=YOUR_PROJECT_ID
PROJECT_NBR=YOUR_PROJECT_NUMBER
LOCATION=us-central1
VPC_NM=VPC=s8s-vpc-$PROJECT_NBR
SPARK_SERVERLESS_SUBNET=spark-snet
PERSISTENT_HISTORY_SERVER_NM=s8s-sphs-$PROJECT_NBR
UMSA_FQN=s8s-lab-sa@$PROJECT_ID.iam.gserviceaccount.com
CODE_AND_DATA_BUCKET=s8s_data_and_code_bucket-${PROJECT_NBR}
COMPOSER_ENV=pavarotti-cc2
```

## 6. Clone this repo

```
cd ~
git clone https://github.com/anagha-google/s8s-spark-ce-workshop.git
```

## 7. Upload the code and data to the designated GCS bucket
Navigate to the cloned repo and upload the files (code and data) as shown below-
```
cd ~/s8s-spark-ce-workshop/lab-01/
gsutil cp -r cell-tower-anomaly-detection/00-scripts gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/00-scripts
gsutil cp -r cell-tower-anomaly-detection/01-datasets gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/01-datasets
```

## 8. Curate cutsomer master data
In this section, from PySpark, we transform customer master data (parquet) and service threshold data (CSV) and join them, and persist to GCS.<br>

Review the [code](cell-tower-anomaly-detection/00-scripts/curate_customer_data.py) first.<br>

### 8.1. Abstract of the Pyspark script
This script -<br>
(a) Reads the customer master data<br>
(b) Reads the service threshold data<br>
(c) Subsets each of the datasets for relevant attributes<br>
(d) Then joins them both based on cell tower name and<br> 
(e) Persists to GCS

### 8.2. Execute the command below
```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $LOCATION pyspark \
--batch s8s-lab1-curate-customer-master-$RANDOM \
gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/00-scripts/curate_customer_data.py \
--subnet projects/$PROJECT_ID/regions/$LOCATION/subnetworks/$SPARK_SERVERLESS_SUBNET \
--history-server-cluster=projects/$PROJECT_ID/regions/$LOCATION/clusters/$PERSISTENT_HISTORY_SERVER_NM \
--service-account $UMSA_FQN \
-- $CODE_AND_DATA_BUCKET
```
Here is intermediate console output from the application-
```

8.2.1. Customer data schema:

root
 |-- Index: long (nullable = true)
 |-- customerID: string (nullable = true)
 |-- gender: string (nullable = true)
 |-- SeniorCitizen: long (nullable = true)
 |-- Partner: string (nullable = true)
 |-- Dependents: string (nullable = true)
 |-- tenure: long (nullable = true)
 |-- PhoneService: string (nullable = true)
 |-- MultipleLines: string (nullable = true)
 |-- InternetService: string (nullable = true)
 |-- OnlineSecurity: string (nullable = true)
 |-- OnlineBackup: string (nullable = true)
 |-- DeviceProtection: string (nullable = true)
 |-- TechSupport: string (nullable = true)
 |-- StreamingTV: string (nullable = true)
 |-- StreamingMovies: string (nullable = true)
 |-- Contract: string (nullable = true)
 |-- PaperlessBilling: string (nullable = true)
 |-- PaymentMethod: string (nullable = true)
 |-- MonthlyCharges: double (nullable = true)
 |-- TotalCharges: string (nullable = true)
 |-- Churn: long (nullable = true)
 |-- CellTower: string (nullable = true)

8.2.2. Service threshold data schema:

root
 |-- Time: string (nullable = true)
 |-- CellName: string (nullable = true)
 |-- PRBUsageUL: double (nullable = true)
 |-- PRBUsageDL: double (nullable = true)
 |-- meanThr_DL: double (nullable = true)
 |-- meanThr_UL: double (nullable = true)
 |-- maxThr_DL: double (nullable = true)
 |-- maxThr_UL: double (nullable = true)
 |-- meanUE_DL: double (nullable = true)
 |-- meanUE_UL: double (nullable = true)
 |-- maxUE_DL: integer (nullable = true)
 |-- maxUE_UL: integer (nullable = true)
 |-- maxUE_UL+DL: integer (nullable = true)
 |-- Unusual: integer (nullable = true)

8.2.3. Subsetted customer data:
+------+------------+-------------+---------------+-----+---------+----------+
|tenure|PhoneService|MultipleLines|InternetService|Churn|CellTower|customerID|
+------+------------+-------------+---------------+-----+---------+----------+
|30    |Yes         |No           |DSL            |0    |9ALTE    |3676      |
|42    |Yes         |No           |DSL            |0    |10WLTE   |5802      |
|3     |Yes         |No           |DSL            |1    |6CLTE    |5179      |
|13    |Yes         |No           |Fiber optic    |1    |4VLTE    |1607      |
|12    |Yes         |Yes          |Fiber optic    |1    |8ULTE    |3610      |
|57    |Yes         |Yes          |Fiber optic    |1    |9WLTE    |6717      |
|32    |Yes         |Yes          |Fiber optic    |1    |4ALTE    |1809      |
|68    |Yes         |Yes          |DSL            |0    |3ULTE    |791       |
|8     |Yes         |No           |No             |0    |4WLTE    |792       |
|1     |Yes         |No           |No             |1    |4ALTE    |6789      |
+------+------------+-------------+---------------+-----+---------+----------+
only showing top 10 rows

8.2.4. Schema of the above-
root
 |-- tenure: long (nullable = true)
 |-- PhoneService: string (nullable = true)
 |-- MultipleLines: string (nullable = true)
 |-- InternetService: string (nullable = true)
 |-- Churn: long (nullable = true)
 |-- CellTower: string (nullable = true)
 |-- customerID: long (nullable = true)

8.2.5. Service threshold data-
+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+
|CellName|PRBUsageUL|PRBUsageDL|meanThr_DL|meanThr_UL|maxThr_DL|maxThr_UL|meanUE_DL|meanUE_UL|maxUE_DL|maxUE_UL|maxUE_UL_DL|Unusual|
+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+
|10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|10BLTE  |0.303     |0.404     |0.016     |0.013     |0.348    |0.168    |1.011    |1.011    |2       |1       |3          |0      |
|10CLTE  |7.8166    |0.9439    |0.2175    |0.0388    |4.332    |0.3604   |1.12     |1.0079   |4       |4       |8          |1      |
|1ALTE   |2.526     |0.707     |0.375     |0.02      |47.39    |0.623    |1.031    |1.021    |3       |2       |5          |0      |
|1BLTE   |22.0438   |2.0016    |0.562     |0.2697    |10.3994  |1.1771   |1.448    |1.163    |6       |5       |11         |1      |
|1CLTE   |33.751    |12.53     |1.807     |0.179     |14.49    |2.29     |2.072    |1.859    |9       |8       |17         |0      |
|2ALTE   |0.1033    |0.4246    |0.0095    |0.0063    |0.0512   |0.017    |1.0608   |0.0107   |2       |1       |3          |1      |
|3ALTE   |16.6015   |2.3348    |0.607     |0.0856    |24.7564  |1.2857   |1.2781   |1.1818   |6       |4       |10         |1      |
|3BLTE   |12.3848   |1.4019    |0.3927    |0.0438    |16.6522  |0.6806   |1.1293   |1.0491   |5       |3       |8          |1      |
|3CLTE   |7.175     |3.638     |1.705     |0.067     |43.851   |1.032    |1.142    |1.041    |4       |3       |7          |0      |
+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+
only showing top 10 rows

8.2.6. Schema of the above
root
 |-- CellName: string (nullable = true)
 |-- PRBUsageUL: double (nullable = true)
 |-- PRBUsageDL: double (nullable = true)
 |-- meanThr_DL: double (nullable = true)
 |-- meanThr_UL: double (nullable = true)
 |-- maxThr_DL: double (nullable = true)
 |-- maxThr_UL: double (nullable = true)
 |-- meanUE_DL: double (nullable = true)
 |-- meanUE_UL: double (nullable = true)
 |-- maxUE_DL: integer (nullable = true)
 |-- maxUE_UL: integer (nullable = true)
 |-- maxUE_UL_DL: integer (nullable = true)
 |-- Unusual: integer (nullable = true)

8.2.7. Dataset from joining the customer data and service threshold-
+------+------------+----------------+---------------+-----+---------+----------+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+
|tenure|PhoneService|MultipleLines   |InternetService|Churn|CellTower|customerID|CellName|PRBUsageUL|PRBUsageDL|meanThr_DL|meanThr_UL|maxThr_DL|maxThr_UL|meanUE_DL|meanUE_UL|maxUE_DL|maxUE_UL|maxUE_UL_DL|Unusual|
+------+------------+----------------+---------------+-----+---------+----------+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+
|59    |Yes         |No              |No             |0    |10ALTE   |6465      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|30    |Yes         |No              |No             |0    |10ALTE   |1797      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|51    |Yes         |No              |No             |0    |10ALTE   |6023      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|1     |Yes         |No              |No             |1    |10ALTE   |4065      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|21    |Yes         |No              |Fiber optic    |1    |10ALTE   |3868      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|27    |No          |No phone service|DSL            |1    |10ALTE   |6039      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|43    |Yes         |No              |DSL            |0    |10ALTE   |4440      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|1     |Yes         |No              |No             |0    |10ALTE   |6338      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|61    |Yes         |Yes             |Fiber optic    |0    |10ALTE   |1367      |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
|17    |Yes         |No              |No             |0    |10ALTE   |42        |10ALTE  |8.892     |1.516     |0.423     |0.028     |17.516   |1.003    |1.071    |1.031    |3       |3       |6          |0      |
+------+------------+----------------+---------------+-----+---------+----------+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+
only showing top 10 rows

8.2.8. Schema of the above-
root
 |-- tenure: long (nullable = true)
 |-- PhoneService: string (nullable = true)
 |-- MultipleLines: string (nullable = true)
 |-- InternetService: string (nullable = true)
 |-- Churn: long (nullable = true)
 |-- CellTower: string (nullable = true)
 |-- customerID: long (nullable = true)
 |-- CellName: string (nullable = true)
 |-- PRBUsageUL: double (nullable = true)
 |-- PRBUsageDL: double (nullable = true)
 |-- meanThr_DL: double (nullable = true)
 |-- meanThr_UL: double (nullable = true)
 |-- maxThr_DL: double (nullable = true)
 |-- maxThr_UL: double (nullable = true)
 |-- meanUE_DL: double (nullable = true)
 |-- meanUE_UL: double (nullable = true)
 |-- maxUE_DL: integer (nullable = true)
 |-- maxUE_UL: integer (nullable = true)
 |-- maxUE_UL_DL: integer (nullable = true)
 |-- Unusual: integer (nullable = true)

```

8.2.9. List the results in the GCS bucket-
```
gsutil ls -r gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/output_data/customer_augmented
```
The author's output-
```
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/customer_augmented/:
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/customer_augmented/
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/customer_augmented/_SUCCESS
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/customer_augmented/part-00000-b06a1fa4-3427-4d94-8ef7-e213fdd2a66f-c000.snappy.parquet
```
This output will be used in subsequent steps.


