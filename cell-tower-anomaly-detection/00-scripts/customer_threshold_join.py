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


# Reading the arguments and storing them in variables
project=sys.argv[1]
data_set=sys.argv[2]
BUCKET_NAME=sys.argv[3]
user_name=sys.argv[4]

input_data="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/01-datasets/cust_raw_data/*"
input_data1="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/01-datasets/service_threshold_data.csv"
output_data="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/output_data"

# Building the Spark Session
spark =SparkSession.builder.appName("cell_tower_performance_dataset-exploration").getOrCreate()

#Reading the customer and service threshold data
custDF1 = spark.read.format("parquet").option("header", True).option("inferschema",True).load(input_data)
custDF1.printSchema()

serviceDF1 = spark.read.format("csv")       .option("header", True)       .option("inferschema",True)       .load(input_data1)
serviceDF1.printSchema()

#Cleaning the customer data to keep relevant features
custDF2=custDF1.drop("customerID","gender","SeniorCitizen","Partner","Dependents","OnlineSecurity","OnlineBackup","DeviceProtection","TechSupport","StreamingTV","StreamingMovies","Contract","PaperlessBilling","PaymentMethod","MonthlyCharges","TotalCharges")
custDF2=custDF2.withColumn('customerID', custDF2.Index)
custDF2=custDF2.withColumn('customer_ID_index', custDF2.Index>1000)
custDF2.createOrReplaceTempView("cust")
custDF3 = spark.sql('''select * from cust where customer_ID_index = 'true' ''')
custDF3=custDF3.drop(custDF3.customer_ID_index)
custDF3=custDF3.drop(custDF3.Index)
custDF3.show(truncate=False)

#Cleaning the services data to keep relevant features
serviceDF1=serviceDF1.drop(serviceDF1.Time)
serviceDF1.createOrReplaceTempView("Services")
serviceDF2 = spark.sql('''select * from (SELECT  *,  ROW_NUMBER()  OVER(PARTITION BY CellName ORDER BY CellName) AS Rank FROM Services) as Service_Rank where Rank=1  ''')
serviceDF3=serviceDF2.drop(serviceDF2.Rank)
serviceDF3=serviceDF3.withColumnRenamed('maxUE_UL+DL', 'maxUE_UL_DL')
serviceDF3.show(truncate=False)

#Joining the customer data with the services threshold data
custDF4 = custDF3.join(serviceDF3, custDF3.CellTower ==  serviceDF3.CellName, "inner")

#Writing the output data to BigQuery
custDF4.write.parquet(os.path.join(output_data, user_name+"_customer_threshold_join"), mode = "overwrite")
