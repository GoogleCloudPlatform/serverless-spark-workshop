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
input_data1="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/output_data/"+user_name+"_customer_threshold_join/part*"
input_data2="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/01-datasets/telecom_customer_churn_data.csv"
output_data="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/output_data"

# Building the Spark Session
spark =SparkSession.builder.appName("cell_tower_performance_dataset-exploration").getOrCreate()


#Reading the input datasets
custDF1 = spark.read.format("parquet")       .option("header", True)       .option("inferschema",True)       .load(input_data1)
custDF1.printSchema()

telecomDF1 = spark.read.format("csv")       .option("header", True)       .option("inferschema",True)       .load(input_data2)
telecomDF1.printSchema()

# Cleaning the telecome performance dataset
telecom_table = telecomDF1.selectExpr("roam_Mean","change_mou","drop_vce_Mean","drop_dat_Mean","blck_vce_Mean","blck_dat_Mean","plcd_vce_Mean","plcd_dat_Mean","comp_vce_Mean","comp_dat_Mean","peak_vce_Mean","peak_dat_Mean","mou_peav_Mean","mou_pead_Mean","opk_vce_Mean","opk_dat_Mean","mou_opkv_Mean","mou_opkd_Mean","drop_blk_Mean","callfwdv_Mean","callwait_Mean","churn","months","uniqsubs","actvsubs","area","dualband","forgntvl","Customer_ID")
telecomDF2=telecom_table.withColumn('customer_ID', substring('Customer_ID', 4,7))
telecomDF2=telecomDF2.withColumn('customer_ID_index', telecomDF2.customer_ID>1000)
telecomDF2.createOrReplaceTempView("telecom")
telecomDF3 = spark.sql('''select * from telecom where customer_ID_index = 'true' ''')
telecomDF3=telecomDF3.drop(telecomDF3.customer_ID_index)
telecomDF3.createOrReplaceTempView("Telecome_Mean")
telecomDF4 = spark.sql('''select * from (SELECT  *,  ROW_NUMBER()  OVER(PARTITION BY customer_ID ORDER BY customer_ID) AS Rank FROM Telecome_Mean) as Service_Rank where Rank between 1 and 6  ''')
telecomDF4=telecomDF4.drop(telecomDF4.Rank)
telecomDF4.show(truncate=False)

# Joining the customer threshold data with the telecom performance data
custDF2 = custDF1.join(telecomDF4, custDF1.customerID ==  telecomDF4.customer_ID, "inner").drop(telecomDF4.customer_ID).drop(telecomDF4.churn)
custDF2.show(truncate=False)

#Writing the output data to BigQuery
custDF2.write.parquet(os.path.join(output_data, user_name+"_customer_threshold_service_join"), mode = "overwrite")
