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

## 9. Curate telecom performance data
In this section, from PySpark, we transform telco customer churn data, join with the augmented customer data, and persist to GCS.<br>

Review the [code](cell-tower-anomaly-detection/00-scripts/curate_telco_performance_data.py) first.<br>

### 9.1. Abstract of the Pyspark script
This script -<br>
(a) Reads the curated customer data<br>
(b) Reads the telco customer churn data<br>
(c) Subsets each of the datasets for relevant attributes<br>
(d) Then joins them both based on customer ID and<br> 
(e) Persists to GCS

### 9.2. Execute the command below
```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $LOCATION pyspark \
--batch s8s-lab1-curate-cell-tower-metrics-$RANDOM \
gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/00-scripts/curate_telco_performance_data.py \
--subnet projects/$PROJECT_ID/regions/$LOCATION/subnetworks/$SPARK_SERVERLESS_SUBNET \
--history-server-cluster=projects/$PROJECT_ID/regions/$LOCATION/clusters/$PERSISTENT_HISTORY_SERVER_NM \
--service-account $UMSA_FQN \
-- $CODE_AND_DATA_BUCKET
```
Here is intermediate console output from the application-
```

9.2.1. The telco customer churn data - schema
root
 |-- rev_Mean: double (nullable = true)
 |-- mou_Mean: double (nullable = true)
 |-- totmrc_Mean: double (nullable = true)
 |-- da_Mean: double (nullable = true)
 |-- ovrmou_Mean: double (nullable = true)
 |-- ovrrev_Mean: double (nullable = true)
 |-- vceovr_Mean: double (nullable = true)
 |-- datovr_Mean: double (nullable = true)
 |-- roam_Mean: double (nullable = true)
 |-- change_mou: double (nullable = true)
 |-- change_rev: double (nullable = true)
 |-- drop_vce_Mean: double (nullable = true)
 |-- drop_dat_Mean: double (nullable = true)
 |-- blck_vce_Mean: double (nullable = true)
 |-- blck_dat_Mean: double (nullable = true)
 |-- unan_vce_Mean: double (nullable = true)
 |-- unan_dat_Mean: double (nullable = true)
 |-- plcd_vce_Mean: double (nullable = true)
 |-- plcd_dat_Mean: double (nullable = true)
 |-- recv_vce_Mean: double (nullable = true)
 |-- recv_sms_Mean: double (nullable = true)
 |-- comp_vce_Mean: double (nullable = true)
 |-- comp_dat_Mean: double (nullable = true)
 |-- custcare_Mean: double (nullable = true)
 |-- ccrndmou_Mean: double (nullable = true)
 |-- cc_mou_Mean: double (nullable = true)
 |-- inonemin_Mean: double (nullable = true)
 |-- threeway_Mean: double (nullable = true)
 |-- mou_cvce_Mean: double (nullable = true)
 |-- mou_cdat_Mean: double (nullable = true)
 |-- mou_rvce_Mean: double (nullable = true)
 |-- owylis_vce_Mean: double (nullable = true)
 |-- mouowylisv_Mean: double (nullable = true)
 |-- iwylis_vce_Mean: double (nullable = true)
 |-- mouiwylisv_Mean: double (nullable = true)
 |-- peak_vce_Mean: double (nullable = true)
 |-- peak_dat_Mean: double (nullable = true)
 |-- mou_peav_Mean: double (nullable = true)
 |-- mou_pead_Mean: double (nullable = true)
 |-- opk_vce_Mean: double (nullable = true)
 |-- opk_dat_Mean: double (nullable = true)
 |-- mou_opkv_Mean: double (nullable = true)
 |-- mou_opkd_Mean: double (nullable = true)
 |-- drop_blk_Mean: double (nullable = true)
 |-- attempt_Mean: double (nullable = true)
 |-- complete_Mean: double (nullable = true)
 |-- callfwdv_Mean: double (nullable = true)
 |-- callwait_Mean: double (nullable = true)
 |-- churn: integer (nullable = true)
 |-- months: integer (nullable = true)
 |-- uniqsubs: integer (nullable = true)
 |-- actvsubs: integer (nullable = true)
 |-- new_cell: string (nullable = true)
 |-- crclscod: string (nullable = true)
 |-- asl_flag: string (nullable = true)
 |-- totcalls: integer (nullable = true)
 |-- totmou: double (nullable = true)
 |-- totrev: double (nullable = true)
 |-- adjrev: double (nullable = true)
 |-- adjmou: double (nullable = true)
 |-- adjqty: integer (nullable = true)
 |-- avgrev: double (nullable = true)
 |-- avgmou: double (nullable = true)
 |-- avgqty: double (nullable = true)
 |-- avg3mou: integer (nullable = true)
 |-- avg3qty: integer (nullable = true)
 |-- avg3rev: integer (nullable = true)
 |-- avg6mou: integer (nullable = true)
 |-- avg6qty: integer (nullable = true)
 |-- avg6rev: integer (nullable = true)
 |-- prizm_social_one: string (nullable = true)
 |-- area: string (nullable = true)
 |-- dualband: string (nullable = true)
 |-- refurb_new: string (nullable = true)
 |-- hnd_price: double (nullable = true)
 |-- phones: integer (nullable = true)
 |-- models: integer (nullable = true)
 |-- hnd_webcap: string (nullable = true)
 |-- truck: integer (nullable = true)
 |-- rv: integer (nullable = true)
 |-- ownrent: string (nullable = true)
 |-- lor: integer (nullable = true)
 |-- dwlltype: string (nullable = true)
 |-- marital: string (nullable = true)
 |-- adults: integer (nullable = true)
 |-- infobase: string (nullable = true)
 |-- income: integer (nullable = true)
 |-- numbcars: integer (nullable = true)
 |-- HHstatin: string (nullable = true)
 |-- dwllsize: string (nullable = true)
 |-- forgntvl: integer (nullable = true)
 |-- ethnic: string (nullable = true)
 |-- kid0_2: string (nullable = true)
 |-- kid3_5: string (nullable = true)
 |-- kid6_10: string (nullable = true)
 |-- kid11_15: string (nullable = true)
 |-- kid16_17: string (nullable = true)
 |-- creditcd: string (nullable = true)
 |-- eqpdays: integer (nullable = true)
 |-- Customer_ID: integer (nullable = true)

9.2.2. The telco customer churn data - schema
+---------+----------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+------------+------------+-------------+-------------+-------------+-------------+-------------+-----+------+--------+--------+-----------------------------+--------+--------+--------------------+-----------+
|roam_Mean|change_mou|drop_vce_Mean|drop_dat_Mean|blck_vce_Mean|blck_dat_Mean|plcd_vce_Mean|plcd_dat_Mean|comp_vce_Mean|comp_dat_Mean|peak_vce_Mean|peak_dat_Mean|mou_peav_Mean|mou_pead_Mean|opk_vce_Mean|opk_dat_Mean|mou_opkv_Mean|mou_opkd_Mean|drop_blk_Mean|callfwdv_Mean|callwait_Mean|churn|months|uniqsubs|actvsubs|area                         |dualband|forgntvl|customer_ID_original|customer_ID|
+---------+----------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+------------+------------+-------------+-------------+-------------+-------------+-------------+-----+------+--------+--------+-----------------------------+--------+--------+--------------------+-----------+
|0.0      |-157.25   |0.666666667  |0.0          |0.666666667  |0.0          |52.33333333  |0.0          |45.0         |0.0          |58.0         |0.0          |132.6        |0.0          |24.0        |0.0         |55.22        |0.0          |1.333333333  |0.0          |0.333333333  |1    |61    |2       |1       |NORTHWEST/ROCKY MOUNTAIN AREA|Y       |0       |1000001             |0001       |
|0.0      |532.25    |8.333333333  |0.0          |1.0          |0.0          |263.3333333  |0.0          |193.3333333  |0.0          |83.66666667  |0.0          |75.33333333  |0.0          |157.0       |0.0         |169.3433333  |0.0          |9.333333333  |0.0          |5.666666667  |0    |56    |1       |1       |CHICAGO AREA                 |N       |0       |1000002             |0002       |
|0.0      |-4.25     |0.333333333  |0.0          |0.0          |0.0          |9.0          |0.0          |6.0          |0.0          |5.0          |0.0          |5.193333333  |0.0          |1.0         |0.0         |0.233333333  |0.0          |0.333333333  |0.0          |0.0          |1    |58    |1       |1       |GREAT LAKES AREA             |N       |0       |1000003             |0003       |
|0.0      |-1.5      |0.0          |0.0          |0.0          |0.0          |3.666666667  |0.0          |3.666666667  |0.0          |1.333333333  |0.0          |3.38         |0.0          |3.666666667 |0.0         |5.45         |0.0          |0.0          |0.0          |0.0          |0    |60    |1       |1       |CHICAGO AREA                 |N       |0       |1000004             |0004       |
|0.0      |38.5      |9.666666667  |0.0          |0.666666667  |0.0          |222.3333333  |0.0          |137.0        |0.0          |97.33333333  |0.0          |173.4766667  |0.0          |90.33333333 |0.0         |218.0866667  |0.0          |10.33333333  |0.0          |0.0          |0    |57    |1       |1       |NEW ENGLAND AREA             |Y       |0       |1000005             |0005       |
|0.0      |156.75    |52.0         |0.0          |7.666666667  |0.0          |702.0        |0.0          |577.3333333  |0.0          |555.6666667  |0.0          |382.0966667  |0.0          |303.6666667 |0.0         |187.76       |0.0          |59.66666667  |0.0          |22.66666667  |0    |59    |2       |2       |GREAT LAKES AREA             |N       |0       |1000006             |0006       |
|0.0      |0.0       |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0         |0.0         |0.0          |0.0          |0.0          |0.0          |0.0          |1    |53    |2       |2       |DALLAS AREA                  |Y       |0       |1000007             |0007       |
|0.0      |147.5     |9.0          |0.0          |1.666666667  |0.0          |97.0         |0.0          |73.33333333  |0.0          |33.33333333  |0.0          |81.06666667  |0.0          |53.0        |0.0         |431.1533333  |0.0          |10.66666667  |0.0          |0.666666667  |0    |53    |1       |1       |DALLAS AREA                  |Y       |1       |1000008             |0008       |
|0.0      |198.0     |12.66666667  |0.0          |3.0          |0.0          |533.6666667  |0.0          |346.6666667  |0.0          |238.3333333  |0.0          |377.4533333  |0.0          |192.3333333 |0.0         |297.32       |0.0          |15.66666667  |0.0          |4.0          |0    |55    |1       |1       |CHICAGO AREA                 |Y       |0       |1000009             |0009       |
|0.0      |59.5      |0.0          |0.0          |1.0          |0.0          |6.666666667  |0.0          |3.333333333  |0.0          |1.666666667  |0.0          |1.866666667  |0.0          |1.666666667 |0.0         |1.933333333  |0.0          |1.0          |0.0          |0.0          |0    |57    |2       |2       |DALLAS AREA                  |Y       |1       |1000010             |0010       |
+---------+----------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+------------+------------+-------------+-------------+-------------+-------------+-------------+-----+------+--------+--------+-----------------------------+--------+--------+--------------------+-----------+
only showing top 10 rows

9.2.2. The joined/consolidated dataset
+------+------------+----------------+---------------+-----+---------+----------+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+---------+----------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+------------+------------+-------------+-------------+-------------+-------------+-------------+------+--------+--------+-----------------------------+--------+--------+--------------------+
|tenure|PhoneService|MultipleLines   |InternetService|Churn|CellTower|customerID|CellName|PRBUsageUL|PRBUsageDL|meanThr_DL|meanThr_UL|maxThr_DL|maxThr_UL|meanUE_DL|meanUE_UL|maxUE_DL|maxUE_UL|maxUE_UL_DL|Unusual|roam_Mean|change_mou|drop_vce_Mean|drop_dat_Mean|blck_vce_Mean|blck_dat_Mean|plcd_vce_Mean|plcd_dat_Mean|comp_vce_Mean|comp_dat_Mean|peak_vce_Mean|peak_dat_Mean|mou_peav_Mean|mou_pead_Mean|opk_vce_Mean|opk_dat_Mean|mou_opkv_Mean|mou_opkd_Mean|drop_blk_Mean|callfwdv_Mean|callwait_Mean|months|uniqsubs|actvsubs|area                         |dualband|forgntvl|customer_ID_original|
+------+------------+----------------+---------------+-----+---------+----------+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+---------+----------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+------------+------------+-------------+-------------+-------------+-------------+-------------+------+--------+--------+-----------------------------+--------+--------+--------------------+
|34    |Yes         |No              |DSL            |0    |7VLTE    |1         |7VLTE   |1.415     |2.021     |0.477     |0.053     |22.06    |8.151    |1.122    |0.01     |3       |3       |6          |0      |0.0      |-157.25   |0.666666667  |0.0          |0.666666667  |0.0          |52.33333333  |0.0          |45.0         |0.0          |58.0         |0.0          |132.6        |0.0          |24.0        |0.0         |55.22        |0.0          |1.333333333  |0.0          |0.333333333  |61    |2       |1       |NORTHWEST/ROCKY MOUNTAIN AREA|Y       |0       |1000001             |
|2     |Yes         |No              |DSL            |1    |10CLTE   |2         |10CLTE  |7.8166    |0.9439    |0.2175    |0.0388    |4.332    |0.3604   |1.12     |1.0079   |4       |4       |8          |1      |0.0      |532.25    |8.333333333  |0.0          |1.0          |0.0          |263.3333333  |0.0          |193.3333333  |0.0          |83.66666667  |0.0          |75.33333333  |0.0          |157.0       |0.0         |169.3433333  |0.0          |9.333333333  |0.0          |5.666666667  |56    |1       |1       |CHICAGO AREA                 |N       |0       |1000002             |
|45    |No          |No phone service|DSL            |0    |6CLTE    |3         |6CLTE   |4.143     |0.505     |0.021     |0.013     |0.409    |0.437    |1.021    |0.01     |2       |2       |4          |0      |0.0      |-4.25     |0.333333333  |0.0          |0.0          |0.0          |9.0          |0.0          |6.0          |0.0          |5.0          |0.0          |5.193333333  |0.0          |1.0         |0.0         |0.233333333  |0.0          |0.333333333  |0.0          |0.0          |58    |1       |1       |GREAT LAKES AREA             |N       |0       |1000003             |
|2     |Yes         |No              |Fiber optic    |1    |4ALTE    |4         |4ALTE   |1.9963    |1.1513    |0.9908    |0.0245    |64.7465  |0.8747   |1.0766   |1.0526   |3       |2       |5          |1      |0.0      |-1.5      |0.0          |0.0          |0.0          |0.0          |3.666666667  |0.0          |3.666666667  |0.0          |1.333333333  |0.0          |3.38         |0.0          |3.666666667 |0.0         |5.45         |0.0          |0.0          |0.0          |0.0          |60    |1       |1       |CHICAGO AREA                 |N       |0       |1000004             |
|22    |Yes         |Yes             |Fiber optic    |0    |6CLTE    |6         |6CLTE   |4.143     |0.505     |0.021     |0.013     |0.409    |0.437    |1.021    |0.01     |2       |2       |4          |0      |0.0      |156.75    |52.0         |0.0          |7.666666667  |0.0          |702.0        |0.0          |577.3333333  |0.0          |555.6666667  |0.0          |382.0966667  |0.0          |303.6666667 |0.0         |187.76       |0.0          |59.66666667  |0.0          |22.66666667  |59    |2       |2       |GREAT LAKES AREA             |N       |0       |1000006             |
|10    |No          |No phone service|DSL            |0    |6ULTE    |7         |6ULTE   |0.202     |1.112     |0.217     |0.013     |4.345    |0.103    |1.021    |0.01     |3       |2       |5          |0      |0.0      |0.0       |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0         |0.0         |0.0          |0.0          |0.0          |0.0          |0.0          |53    |2       |2       |DALLAS AREA                  |Y       |0       |1000007             |
|62    |Yes         |No              |DSL            |0    |3CLTE    |9         |3CLTE   |7.175     |3.638     |1.705     |0.067     |43.851   |1.032    |1.142    |1.041    |4       |3       |7          |0      |0.0      |198.0     |12.66666667  |0.0          |3.0          |0.0          |533.6666667  |0.0          |346.6666667  |0.0          |238.3333333  |0.0          |377.4533333  |0.0          |192.3333333 |0.0         |297.32       |0.0          |15.66666667  |0.0          |4.0          |55    |1       |1       |CHICAGO AREA                 |Y       |0       |1000009             |
|16    |Yes         |No              |No             |0    |8ALTE    |11        |8ALTE   |8.589     |0.808     |0.126     |0.024     |8.344    |0.744    |1.101    |1.051    |5       |4       |9          |0      |0.0      |23.5      |0.0          |0.0          |0.333333333  |0.0          |19.33333333  |0.333333333  |15.0         |0.333333333  |7.666666667  |0.333333333  |66.07333333  |0.056666667  |7.333333333 |0.0         |70.42        |0.0          |0.333333333  |0.0          |0.0          |59    |2       |2       |DALLAS AREA                  |Y       |0       |1000011             |
|58    |Yes         |Yes             |Fiber optic    |0    |9ALTE    |12        |9ALTE   |15.966    |1.819     |0.415     |0.071     |10.116   |0.706    |1.364    |1.314    |6       |5       |11         |0      |0.0      |19.75     |0.0          |0.0          |0.0          |0.0          |9.0          |0.0          |8.0          |0.0          |9.333333333  |0.0          |7.17         |0.0          |1.666666667 |0.0         |0.75         |0.0          |0.0          |0.0          |0.0          |53    |3       |3       |CENTRAL/SOUTH TEXAS AREA     |N       |0       |1000012             |
|49    |Yes         |Yes             |Fiber optic    |1    |10CLTE   |13        |10CLTE  |7.8166    |0.9439    |0.2175    |0.0388    |4.332    |0.3604   |1.12     |1.0079   |4       |4       |8          |1      |0.0      |42.75     |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0          |0.0         |0.0         |0.0          |0.0          |0.0          |0.0          |0.0          |55    |1       |1       |GREAT LAKES AREA             |Y       |0       |1000013             |
|52    |Yes         |No              |No             |0    |8ALTE    |16        |8ALTE   |8.589     |0.808     |0.126     |0.024     |8.344    |0.744    |1.101    |1.051    |5       |4       |9          |0      |0.0      |201.5     |3.333333333  |0.0          |1.666666667  |0.0          |67.66666667  |0.0          |55.33333333  |0.0          |62.33333333  |0.0          |136.7966667  |0.0          |18.0        |0.0         |38.14333333  |0.0          |5.0          |0.0          |0.333333333  |55    |2       |2       |DALLAS AREA                  |Y       |0       |1000016             |
|10    |Yes         |No              |DSL            |1    |8BLTE    |18        |8BLTE   |1.92      |0.505     |0.051     |0.013     |2.179    |0.203    |1.041    |1.011    |3       |2       |5          |0      |0.0      |30.0      |2.0          |0.0          |0.666666667  |0.0          |53.0         |0.0          |33.33333333  |0.0          |48.33333333  |0.0          |77.15333333  |0.0          |7.0         |0.0         |6.086666667  |0.0          |2.666666667  |0.0          |0.333333333  |59    |3       |2       |NORTHWEST/ROCKY MOUNTAIN AREA|N       |0       |1000018             |
|1     |No          |No phone service|DSL            |1    |7WLTE    |20        |7WLTE   |1.415     |5.457     |0.662     |0.072     |40.261   |1.092    |1.334    |0.01     |5       |3       |8          |0      |0.0      |-58.0     |1.666666667  |0.0          |0.333333333  |0.0          |60.66666667  |1.333333333  |50.0         |1.333333333  |19.33333333  |0.0          |37.26666667  |0.0          |42.33333333 |1.333333333 |66.35333333  |2.373333333  |2.0          |0.0          |0.0          |56    |1       |1       |CHICAGO AREA                 |Y       |0       |1000020             |
|12    |Yes         |No              |No             |0    |3ALTE    |21        |3ALTE   |16.6015   |2.3348    |0.607     |0.0856    |24.7564  |1.2857   |1.2781   |1.1818   |6       |4       |10         |1      |0.0      |-1007.0   |7.333333333  |0.0          |18.0         |0.0          |760.3333333  |0.0          |622.0        |0.0          |718.0        |0.0          |1797.173333  |0.0          |60.33333333 |0.0         |115.5766667  |0.0          |25.33333333  |0.0          |20.33333333  |58    |2       |1       |TENNESSEE AREA               |Y       |0       |1000021             |
|30    |Yes         |No              |DSL            |0    |7BLTE    |25        |7BLTE   |0.505     |1.213     |0.265     |0.044     |14.784   |1.033    |1.324    |0.01     |6       |3       |9          |0      |0.0      |-47.5     |2.0          |0.0          |0.666666667  |0.0          |74.0         |0.0          |57.66666667  |0.0          |45.66666667  |0.0          |83.17333333  |0.0          |52.33333333 |0.0         |168.5633333  |0.0          |2.666666667  |0.0          |0.333333333  |52    |2       |2       |NORTHWEST/ROCKY MOUNTAIN AREA|Y       |0       |1000025             |
|1     |No          |No phone service|DSL            |1    |6BLTE    |27        |6BLTE   |5.255     |0.606     |0.124     |0.015     |5.714    |0.324    |1.031    |0.01     |3       |2       |5          |0      |0.0      |226.75    |19.66666667  |0.0          |3.666666667  |0.0          |175.6666667  |0.0          |124.6666667  |0.0          |110.6666667  |0.0          |135.0766667  |0.0          |72.0        |0.0         |120.4866667  |0.0          |23.33333333  |0.0          |4.333333333  |52    |1       |1       |NORTHWEST/ROCKY MOUNTAIN AREA|N       |0       |1000027             |
|72    |Yes         |Yes             |DSL            |0    |6ULTE    |28        |6ULTE   |0.202     |1.112     |0.217     |0.013     |4.345    |0.103    |1.021    |0.01     |3       |2       |5          |0      |0.0      |25.25     |4.0          |0.0          |0.0          |0.0          |343.0        |0.0          |297.6666667  |0.0          |206.3333333  |0.0          |367.47       |0.0          |170.3333333 |0.0         |386.9733333  |0.0          |4.0          |0.0          |0.0          |58    |1       |1       |GREAT LAKES AREA             |Y       |0       |1000028             |
|1     |Yes         |No              |DSL            |0    |10CLTE   |34        |10CLTE  |7.8166    |0.9439    |0.2175    |0.0388    |4.332    |0.3604   |1.12     |1.0079   |4       |4       |8          |1      |0.0      |-15.5     |1.333333333  |0.0          |3.0          |0.0          |32.0         |0.333333333  |20.33333333  |0.333333333  |7.0          |0.0          |8.953333333  |0.0          |14.0        |0.333333333 |25.91333333  |1.29         |4.333333333  |0.0          |0.0          |58    |1       |1       |MIDWEST AREA                 |T       |1       |1000034             |
|72    |Yes         |Yes             |Fiber optic    |0    |6CLTE    |35        |6CLTE   |4.143     |0.505     |0.021     |0.013     |0.409    |0.437    |1.021    |0.01     |2       |2       |4          |0      |0.0      |41.25     |0.333333333  |0.0          |0.0          |0.0          |17.33333333  |0.0          |16.0         |0.0          |31.66666667  |0.0          |32.44333333  |0.0          |6.333333333 |0.0         |8.61         |0.0          |0.333333333  |0.0          |0.333333333  |56    |2       |1       |NORTHWEST/ROCKY MOUNTAIN AREA|Y       |0       |1000035             |
|34    |Yes         |Yes             |Fiber optic    |1    |9ALTE    |38        |9ALTE   |15.966    |1.819     |0.415     |0.071     |10.116   |0.706    |1.364    |1.314    |6       |5       |11         |0      |0.0      |26.25     |0.0          |0.0          |0.0          |0.0          |34.66666667  |0.0          |16.0         |0.0          |21.66666667  |0.0          |42.21333333  |0.0          |5.666666667 |0.0         |18.93        |0.0          |0.0          |0.0          |0.0          |52    |1       |1       |NORTHWEST/ROCKY MOUNTAIN AREA|N       |0       |1000038             |
+------+------------+----------------+---------------+-----+---------+----------+--------+----------+----------+----------+----------+---------+---------+---------+---------+--------+--------+-----------+-------+---------+----------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+------------+------------+-------------+-------------+-------------+-------------+-------------+------+--------+--------+-----------------------------+--------+--------+--------------------+
only showing top 20 rows

```

9.2.3. List the results in the GCS bucket-
```
gsutil ls -r gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/output_data/telco_performance_augmented
```
The author's output-
```
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/:
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/_SUCCESS
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00000-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00001-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00002-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00003-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00004-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00005-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00006-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/telco_performance_augmented/part-00007-06106efe-4190-47b2-8565-098ef060f325-c000.snappy.parquet
```
This output will be used in subsequent steps.

## 10. Curate telecom performance data
In this section, from PySpark, we analyze the curated telecom data, and calculate the KPIs by customer.<br>

Review the [code](cell-tower-anomaly-detection/00-scripts/kpis_by_customer.py) first.<br>

### 10.1. Abstract of the Pyspark script
This script -<br>
(a) Reads the curated telecom data <br>
(b) Add a number of derived metrics <br>
(c) that constitute performance indicators and <br>
(d) persists to GCS as parquet and <br>
(e) also creates an external table in BigQuery on the same dataset

### 10.2. Execute the command below
```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $LOCATION pyspark \
--batch s8s-lab1-kpis-by-customer-$RANDOM \
gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/00-scripts/kpis_by_customer.py \
--subnet projects/$PROJECT_ID/regions/$LOCATION/subnetworks/$SPARK_SERVERLESS_SUBNET \
--history-server-cluster=projects/$PROJECT_ID/regions/$LOCATION/clusters/$PERSISTENT_HISTORY_SERVER_NM \
--service-account $UMSA_FQN \
-- $PROJECT_ID "cell_tower_reporting_mart" $CODE_AND_DATA_BUCKET
```
Here is intermediate console output from the application-
```
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
 |-- roam_Mean: double (nullable = true)
 |-- change_mou: double (nullable = true)
 |-- drop_vce_Mean: double (nullable = true)
 |-- drop_dat_Mean: double (nullable = true)
 |-- blck_vce_Mean: double (nullable = true)
 |-- blck_dat_Mean: double (nullable = true)
 |-- plcd_vce_Mean: double (nullable = true)
 |-- plcd_dat_Mean: double (nullable = true)
 |-- comp_vce_Mean: double (nullable = true)
 |-- comp_dat_Mean: double (nullable = true)
 |-- peak_vce_Mean: double (nullable = true)
 |-- peak_dat_Mean: double (nullable = true)
 |-- mou_peav_Mean: double (nullable = true)
 |-- mou_pead_Mean: double (nullable = true)
 |-- opk_vce_Mean: double (nullable = true)
 |-- opk_dat_Mean: double (nullable = true)
 |-- mou_opkv_Mean: double (nullable = true)
 |-- mou_opkd_Mean: double (nullable = true)
 |-- drop_blk_Mean: double (nullable = true)
 |-- callfwdv_Mean: double (nullable = true)
 |-- callwait_Mean: double (nullable = true)
 |-- months: integer (nullable = true)
 |-- uniqsubs: integer (nullable = true)
 |-- actvsubs: integer (nullable = true)
 |-- area: string (nullable = true)
 |-- dualband: string (nullable = true)
 |-- forgntvl: integer (nullable = true)
 |-- customer_ID_original: integer (nullable = true)

22/05/07 02:38:56 WARN package: Truncated the string representation of a plan since it was too large. This behavior can be adjusted by setting 'spark.sql.debug.maxToStringFields'.
+----------+--------+------+------------+-------------+---------------+--------------+------------------+--------------------+--------------------+-------------+-------------------+------------------+--------------------+------------+------------+---------------+-----------+-------------------+--------------+------------------+-----------------+------------------+-----------------+-----------------+-------------------+------------------+-----------------+-----------------+-------------------+-----------------+-----------------+-----------------+--------------------+------------------+--------------------+------------------+-----------------+------------------+----------------------+---------------------+-----------------------------+----------------------------+-----------------+-----------------+-----------------+-----------------+----------------+----------------+----------------+----------------+---------------+---------------+------------------+----------------+------------------+--------------------+--------------------+--------------------+--------------------+--------------------+--------------------+-------------------+-------------------+--------------------+--------------------+------------------------------------+-----------------------------------+------------+
|customerID|CellName|tenure|PhoneService|MultipleLines|InternetService|avg_PRBUsageUL|avg_PRBUsageDL    |avg_meanThr_DL      |avg_meanThr_UL      |avg_maxThr_DL|avg_maxThr_UL      |avg_meanUE_DL     |avg_meanUE_UL       |avg_maxUE_DL|avg_maxUE_UL|avg_maxUE_UL_DL|avg_Unusual|avg_roam_Mean      |avg_change_mou|avg_drop_vce_Mean |avg_drop_dat_Mean|avg_blck_vce_Mean |avg_blck_dat_Mean|avg_plcd_vce_Mean|avg_plcd_dat_Mean  |avg_comp_vce_Mean |avg_comp_dat_Mean|avg_peak_vce_Mean|avg_peak_dat_Mean  |avg_mou_peav_Mean|avg_mou_pead_Mean|avg_opk_vce_Mean |avg_opk_dat_Mean    |avg_mou_opkv_Mean |avg_mou_opkd_Mean   |avg_drop_blk_Mean |avg_callfwdv_Mean|avg_callwait_Mean |incomplete_voice_calls|incomplete_data_calls|service_stability_voice_calls|service_stability_data_calls|PRBUsageUL_Thrsld|PRBUsageDL_Thrsld|meanThr_DL_Thrsld|meanThr_UL_Thrsld|maxThr_DL_Thrsld|maxThr_UL_Thrsld|meanUE_DL_Thrsld|meanUE_UL_Thrsld|maxUE_DL_Thrsld|maxUE_UL_Thrsld|maxUE_UL_DL_Thrsld|roam_Mean_Thrsld|change_mouL_Thrsld|drop_vce_Mean_Thrsld|drop_dat_Mean_Thrsld|blck_vce_Mean_Thrsld|blck_dat_Mean_Thrsld|peak_vce_Mean_Thrsld|peak_dat_Mean_Thrsld|opk_vce_Mean_Thrsld|opk_dat_Mean_Thrsld|drop_blk_Mean_Thrsld|callfwdv_Mean_Thrsld|service_stability_voice_calls_Thrsld|service_stability_data_calls_Thrsld|defect_count|
+----------+--------+------+------------+-------------+---------------+--------------+------------------+--------------------+--------------------+-------------+-------------------+------------------+--------------------+------------+------------+---------------+-----------+-------------------+--------------+------------------+-----------------+------------------+-----------------+-----------------+-------------------+------------------+-----------------+-----------------+-------------------+-----------------+-----------------+-----------------+--------------------+------------------+--------------------+------------------+-----------------+------------------+----------------------+---------------------+-----------------------------+----------------------------+-----------------+-----------------+-----------------+-----------------+----------------+----------------+----------------+----------------+---------------+---------------+------------------+----------------+------------------+--------------------+--------------------+--------------------+--------------------+--------------------+--------------------+-------------------+-------------------+--------------------+--------------------+------------------------------------+-----------------------------------+------------+
|2388      |6ULTE   |1     |Yes         |No           |DSL            |0.202         |1.112             |0.217               |0.013000000000000001|4.345        |0.10300000000000001|1.0210000000000001|0.009999999999999998|3.0         |2.0         |5.0            |0.0        |1.47225            |10.325        |8.633333334       |0.0              |5.4333333334      |0.0              |164.1666666633   |0.3                |114.73333333299999|0.3              |86.566666667     |0.16666666670000002|177.279666656    |1.548666667      |67.13333333329999|0.1333333333        |201.83666666899998|0.43                |14.066666666999998|0.0              |0.9               |49.4333333303         |0.0                  |1.289473684216132            |1.2500000005625003          |0                |0                |1                |1                |0               |0               |0               |0               |0              |0              |0                 |0               |0                 |1                   |0                   |1                   |0                   |1                   |1                   |0                  |1                  |0                   |1                   |1                                   |0                                  |9           |
|2774      |9ALTE   |6     |Yes         |No           |DSL            |15.966        |1.8189999999999997|0.4149999999999999  |0.07099999999999998 |10.116       |0.7059999999999998 |1.3640000000000003|1.314               |6.0         |5.0         |11.0           |0.0        |0.40650000000000003|-5.525        |9.566666667       |0.1333333333     |1.7000000001000004|0.0              |172.0999999957   |1.8                |119.46666667030001|1.666666667      |71.0333333333    |1.0                |138.8203333397   |1.002666667      |82.83333333099998|0.6666666667000001  |212.205333297     |0.5093333333000001  |11.4000000003     |0.0              |0.0666666667      |52.633333325399974    |0.13333333299999994  |0.8575452716535328           |1.4999999999249998          |1                |0                |1                |0                |0               |0               |1               |1               |1              |1              |1                 |1               |0                 |1                   |1                   |0                   |0                   |1                   |0                   |0                  |0                  |0                   |1                   |1                                   |0                                  |13          |
|3364      |10BLTE  |21    |Yes         |Yes          |Fiber optic    |0.303         |0.404             |0.016000000000000004|0.013000000000000001|0.348        |0.16799999999999998|1.0109999999999997|1.0109999999999997  |2.0         |1.0         |3.0            |0.0        |0.126              |-2.05         |2.4000000000999995|0.0              |1.3333333335      |0.0              |72.66666666030001|0.16666666670000002|49.033333334      |0.1333333333     |38.833333327     |0.1                |80.57633333229998|0.0053333333     |28.5333333337    |0.033333333300000004|95.73066666700001 |0.019333333299999998|3.7333333331999996|0.0              |0.4999999998999999|23.63333332630001     |0.033333333400000026 |1.360981308171763            |3.000000003                 |0                |0                |1                |1                |0               |0               |0               |1               |0              |0              |0                 |1               |0                 |0                   |0                   |0                   |0                   |1                   |1                   |1                  |1                  |1                   |1                   |1                                   |0                                  |11          |
+----------+--------+------+------------+-------------+---------------+--------------+------------------+--------------------+--------------------+-------------+-------------------+------------------+--------------------+------------+------------+---------------+-----------+-------------------+--------------+------------------+-----------------+------------------+-----------------+-----------------+-------------------+------------------+-----------------+-----------------+-------------------+-----------------+-----------------+-----------------+--------------------+------------------+--------------------+------------------+-----------------+------------------+----------------------+---------------------+-----------------------------+----------------------------+-----------------+-----------------+-----------------+-----------------+----------------+----------------+----------------+----------------+---------------+---------------+------------------+----------------+------------------+--------------------+--------------------+--------------------+--------------------+--------------------+--------------------+-------------------+-------------------+--------------------+--------------------+------------------------------------+-----------------------------------+------------+
only showing top 3 rows
```

Note the defect count which is a netric derived that indicates issues with the cell tower.<br>


List the results in the GCS bucket-
```
gsutil ls -r gs://$CODE_AND_DATA_BUCKET/cell-tower-anomaly-detection/output_data/kpis_by_customer
```
The author's output-
```
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/kpis_by_customer/:
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/kpis_by_customer/
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/kpis_by_customer/_SUCCESS
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/kpis_by_customer/part-00000-41caca8e-43f5-4509-9569-96dff7b7fb2c-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/kpis_by_customer/part-00001-41caca8e-43f5-4509-9569-96dff7b7fb2c-c000.snappy.parquet
gs://s8s_data_and_code_bucket-159504796045/cell-tower-anomaly-detection/output_data/kpis_by_customer/part-00002-41caca8e-43f5-4509-9569-96dff7b7fb2c-c000.snappy.parquet
```
This output will be used in subsequent steps.




