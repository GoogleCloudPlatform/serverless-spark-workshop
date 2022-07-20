# ======================================================================================
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 
#
# ABOUT
# In this PySpark script, we augment relevant attributes within customer master data with 
# services threshold data and persist to GCS
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
customerMasterDataDir="gs://"+sourceBucketNm+"/cell-tower-anomaly-detection/01-datasets/cust_raw_data/*"
serviceThresholdReferenceDataDir="gs://"+sourceBucketNm+"/cell-tower-anomaly-detection/01-datasets/service_threshold_data.csv"

# Output directory declaration
outputGCSURI="gs://"+sourceBucketNm+"/cell-tower-anomaly-detection/output_data"

# Get or create a Spark session
spark =SparkSession.builder.appName("Curate-Customer-Data").getOrCreate()

# Read the customer master data from GCS
customerMasterDataDF = spark.read.format("parquet").option("header", True).option("inferschema",True).load(customerMasterDataDir)
customerMasterDataDF.printSchema()

# Read the service threshold data from GCS, infer schema
serviceThresholdReferenceDataDF = spark.read.format("csv").option("header", True).option("inferschema",True).load(serviceThresholdReferenceDataDir)
serviceThresholdReferenceDataDF.printSchema()

# Subset the customer master data for relevant attributes
# ...Drop a few fields
customerMasterDataInitialSubsetDF=customerMasterDataDF.drop("customerID","gender","SeniorCitizen","Partner","Dependents","OnlineSecurity","OnlineBackup","DeviceProtection","TechSupport","StreamingTV","StreamingMovies","Contract","PaperlessBilling","PaymentMethod","MonthlyCharges","TotalCharges")
# ...Add a new field off of the Index attribute
customerMasterDataInitialSubsetDF=customerMasterDataInitialSubsetDF.withColumn('customerID', customerMasterDataInitialSubsetDF.Index)
# ...Drop the Index attribute
customerMasterDataFinalSubsetDF=customerMasterDataInitialSubsetDF.drop(customerMasterDataInitialSubsetDF.Index)
customerMasterDataFinalSubsetDF.show(10,truncate=False)
customerMasterDataFinalSubsetDF.printSchema()

# Subset the service threshold reference data for relevant attributes, with some renaming
serviceThresholdReferenceDataInitialDF=serviceThresholdReferenceDataDF.drop(serviceThresholdReferenceDataDF.Time)
serviceThresholdReferenceDataInitialDF.createOrReplaceTempView("Services")
serviceThresholdReferenceDataInitialDF2 = spark.sql('''select * from (SELECT  *,  ROW_NUMBER()  OVER(PARTITION BY CellName ORDER BY CellName) AS Rank FROM Services) as Service_Rank where Rank=1  ''')
serviceThresholdReferenceDataFinalDF=serviceThresholdReferenceDataInitialDF2.drop(serviceThresholdReferenceDataInitialDF2.Rank).withColumnRenamed('maxUE_UL+DL', 'maxUE_UL_DL')
serviceThresholdReferenceDataFinalDF.show(10,truncate=False)
serviceThresholdReferenceDataFinalDF.printSchema()

# Join the customer master data with the services threshold reference data
consolidatedDataDF = customerMasterDataFinalSubsetDF.join(serviceThresholdReferenceDataFinalDF, customerMasterDataFinalSubsetDF.CellTower ==  serviceThresholdReferenceDataFinalDF.CellName, "inner")
consolidatedDataDF.show(10,truncate=False)
consolidatedDataDF.printSchema()

# Persist the augmented customer dataset to GCS
consolidatedDataDF.write.parquet(os.path.join(outputGCSURI, "customer_augmented"), mode = "overwrite")
