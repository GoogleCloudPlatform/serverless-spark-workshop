# ======================================================================================
# ABOUT
# In this PySpark script, we augment the Telecom data with curated customer data (prior
# job), curate it and persist to GCS
# ======================================================================================

import configparser
from datetime import datetime
import os
import json
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf, col, substring, lit, when, avg
from pyspark.sql import functions as F
from pyspark.sql.functions import input_file_name
import random
from pyspark.sql.types import *
from pyspark.sql.functions import year, month, dayofmonth, hour, weekofyear, dayofweek, date_format
from pyspark import SparkContext, SparkConf, SQLContext
from google.cloud import storage
import sys


# Parse arguments
sourceBucketNm=sys.argv[1]

# Source data definition
customerCuratedDataDir="gs://"+sourceBucketNm+"/cell-tower-anomaly-detection/output_data/customer_augmented/part*"
telcoCustomerChurnDataDir="gs://"+sourceBucketNm+"/cell-tower-anomaly-detection/01-datasets/telecom_customer_churn_data.csv"

# Output directory declaration
outputGCSURI="gs://"+sourceBucketNm+"/cell-tower-anomaly-detection/output_data"

# Get or create a Spark session
spark =SparkSession.builder.appName("Curate-Cell_Tower-Performance-Data").getOrCreate()

# Read the curated customer data (blended with services threshold data) from GCS
curatedCustomerDataDF = spark.read.format("parquet").option("header", True).option("inferschema",True).load(customerCuratedDataDir)

# Read the telecom customer churn data from GCS
telecomCustomerChurnRawDataDF = spark.read.format("csv").option("header", True).option("inferschema",True).load(telcoCustomerChurnDataDir)
telecomCustomerChurnRawDataDF.printSchema()

# Subset the telecom customer churn/performance data for relevant attributes
# ... Create subset
telecomCustomerChurnSubsetDF = telecomCustomerChurnRawDataDF.selectExpr("roam_Mean","change_mou","drop_vce_Mean","drop_dat_Mean","blck_vce_Mean","blck_dat_Mean","plcd_vce_Mean","plcd_dat_Mean","comp_vce_Mean","comp_dat_Mean","peak_vce_Mean","peak_dat_Mean","mou_peav_Mean","mou_pead_Mean","opk_vce_Mean","opk_dat_Mean","mou_opkv_Mean","mou_opkd_Mean","drop_blk_Mean","callfwdv_Mean","callwait_Mean","churn","months","uniqsubs","actvsubs","area","dualband","forgntvl","Customer_ID")
# ... Create a column called customer_ID_Short that is a substring of the original Customer_ID
telecomCustomerChurnFinalDF=telecomCustomerChurnSubsetDF.withColumn('customer_ID_Short', substring('Customer_ID', 4,7))
# ... Rename the Customer_ID column, customer_ID_original
telecomCustomerChurnFinalDF=telecomCustomerChurnFinalDF.withColumnRenamed('Customer_ID', 'customer_ID_original')
# ... Rename the newly added customer_ID_Short column, customer_ID
telecomCustomerChurnFinalDF=telecomCustomerChurnFinalDF.withColumnRenamed('customer_ID_Short', 'customer_ID')
# ... Quick visual
telecomCustomerChurnFinalDF.show(10,truncate=False)

# Join the curated customer data with the telecom network performance data based on customer ID
consolidatedDataDF = curatedCustomerDataDF.join(telecomCustomerChurnFinalDF, curatedCustomerDataDF.customerID ==  telecomCustomerChurnFinalDF.customer_ID, "inner").drop(telecomCustomerChurnFinalDF.customer_ID).drop(telecomCustomerChurnFinalDF.churn)
consolidatedDataDF.show(truncate=False)

# Persist the augmented telecom tower performance data to GCS
consolidatedDataDF.write.parquet(os.path.join(outputGCSURI, "telco_performance_augmented"), mode = "overwrite")
