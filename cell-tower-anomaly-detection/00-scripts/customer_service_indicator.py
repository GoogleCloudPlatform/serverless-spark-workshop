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
from google.cloud import bigquery
import sys


#Reading the arguments and storing them in variables
project_name=sys.argv[1]
data_set=sys.argv[2]
BUCKET_NAME=sys.argv[3]
user_name=sys.argv[4]
input_data="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/output_data/"+user_name+"_customer_threshold_service_join/part*"
output_data="gs://"+BUCKET_NAME+"/cell-tower-anomaly-detection/output_data"

# Building the Spark Session
spark =SparkSession.builder.appName("cell_tower_performance_dataset-exploration").config('spark.jars', 'gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar').getOrCreate()

#Reading the Input Data
custDF1 = spark.read.format("parquet").option("header", True).option("inferschema",True).load(input_data)
custDF1.printSchema()

# Layer1 slicing at avg of 6 months performace  at customer granularity level
custDF1=custDF1.drop(custDF1.months)
custDF1.createOrReplaceTempView("slice1")
custDF2 = spark.sql('''select *,  ROW_NUMBER()  OVER(PARTITION BY customerID ORDER BY customerID) AS month from slice1   ''')
custDF2.createOrReplaceTempView("slice1_1")
custDF3= spark.sql('''select customerID,CellName,tenure,PhoneService,MultipleLines,InternetService,avg(PRBUsageUL) as avg_PRBUsageUL,avg(PRBUsageDL) as avg_PRBUsageDL,avg(meanThr_DL) as avg_meanThr_DL,avg(meanThr_UL) as avg_meanThr_UL,avg(maxThr_DL) as avg_maxThr_DL,avg(maxThr_UL) as 	avg_maxThr_UL,avg(meanUE_DL) as avg_meanUE_DL,avg(meanUE_UL) as avg_meanUE_UL,avg(maxUE_DL) as avg_maxUE_DL,avg(maxUE_UL) as avg_maxUE_UL,avg(maxUE_UL_DL) as avg_maxUE_UL_DL,avg(Unusual) as avg_Unusual,avg(roam_Mean) as avg_roam_Mean,avg(change_mou) as avg_change_mou,avg(drop_vce_Mean) as avg_drop_vce_Mean,avg(drop_dat_Mean) as avg_drop_dat_Mean,avg(blck_vce_Mean) as avg_blck_vce_Mean,avg(blck_dat_Mean) as avg_blck_dat_Mean,avg(plcd_vce_Mean) as avg_plcd_vce_Mean,avg(plcd_dat_Mean) as avg_plcd_dat_Mean,avg(comp_vce_Mean) as avg_comp_vce_Mean,avg(comp_dat_Mean) as avg_comp_dat_Mean,avg(peak_vce_Mean) as avg_peak_vce_Mean,avg(peak_dat_Mean) as avg_peak_dat_Mean,avg(mou_peav_Mean) as avg_mou_peav_Mean,avg(mou_pead_Mean) as avg_mou_pead_Mean,avg(opk_vce_Mean) as avg_opk_vce_Mean,avg(opk_dat_Mean) as avg_opk_dat_Mean,avg(mou_opkv_Mean) as avg_mou_opkv_Mean,avg(mou_opkd_Mean) as avg_mou_opkd_Mean,avg(drop_blk_Mean) as avg_drop_blk_Mean,avg(callfwdv_Mean) as avg_callfwdv_Mean,avg(callwait_Mean) as avg_callwait_Mean  from slice1_1 where PhoneService = 'Yes'  group by customerID,CellName,tenure,PhoneService,MultipleLines,InternetService  ''')

# Performace check on top of Layer1 for customer level
slice1DF1=custDF3.withColumn('Incomplete_voice_calls',custDF3.avg_plcd_vce_Mean - custDF3.avg_comp_vce_Mean )
slice1DF2=slice1DF1.withColumn('Incomplete_data_calls',custDF3.avg_plcd_dat_Mean - custDF3.avg_comp_dat_Mean )
slice1DF3=slice1DF2.withColumn('service_stability_voice_calls',custDF3.avg_peak_vce_Mean/custDF3.avg_opk_vce_Mean   )
slice1DF4=slice1DF3.withColumn('service_stability_data_calls',custDF3.avg_peak_dat_Mean/custDF3.avg_opk_dat_Mean   )

slice1DF5=slice1DF4.fillna(value =0)
slice1DF6=slice1DF5.withColumn('PRBUsageUL_Thrsld',when(col("avg_PRBUsageUL") < str(slice1DF5.select(avg("avg_PRBUsageUL")).collect()[0][0]), 0)             .when(col("avg_PRBUsageUL") >str(slice1DF5.select(avg("avg_PRBUsageUL")).collect()[0][0]),1) )
slice1DF7=slice1DF6.withColumn('PRBUsageDL_Thrsld', when(col("avg_PRBUsageDL") < str(slice1DF5.select(avg("avg_PRBUsageDL")).collect()[0][0]), 0)              .when(col("avg_PRBUsageDL") > str(slice1DF5.select(avg("avg_PRBUsageDL")).collect()[0][0]), 1))
slice1DF8=slice1DF7.withColumn('meanThr_DL_Thrsld', when(col("avg_meanThr_DL") < str(slice1DF5.select(avg("avg_meanThr_DL")).collect()[0][0]), 1)              .when(col("avg_meanThr_DL") > str(slice1DF5.select(avg("avg_meanThr_DL")).collect()[0][0]), 0) )
slice1DF9=slice1DF8.withColumn('meanThr_UL_Thrsld', when(col("avg_meanThr_UL") < str(slice1DF5.select(avg("avg_meanThr_UL")).collect()[0][0]), 1)              .when(col("avg_meanThr_UL") > str(slice1DF5.select(avg("avg_meanThr_UL")).collect()[0][0]), 0) )
slice1DF10=slice1DF9.withColumn('maxThr_DL_Thrsld', when(col("avg_maxThr_DL") < str(slice1DF5.select(avg("avg_maxThr_DL")).collect()[0][0]), 0)              .when(col("avg_maxThr_DL") > str(slice1DF5.select(avg("avg_maxThr_DL")).collect()[0][0]), 1))
slice1DF11=slice1DF10.withColumn('maxThr_UL_Thrsld', when(col("avg_maxThr_UL") <str(slice1DF5.select(avg("avg_maxThr_UL")).collect()[0][0]), 0)              .when(col("avg_maxThr_UL") > str(slice1DF5.select(avg("avg_maxThr_UL")).collect()[0][0]), 1))
slice1DF12=slice1DF11.withColumn('meanUE_DL_Thrsld', when(col("avg_meanUE_DL") < str(slice1DF5.select(avg("avg_meanUE_DL")).collect()[0][0]), 0)             .when(col("avg_meanUE_DL") > str(slice1DF5.select(avg("avg_meanUE_DL")).collect()[0][0]), 1))
slice1DF13=slice1DF12.withColumn('meanUE_UL_Thrsld', when(col("avg_meanUE_UL") < str(slice1DF5.select(avg("avg_meanUE_UL")).collect()[0][0]), 0)              .when(col("avg_meanUE_UL") >str(slice1DF5.select(avg("avg_meanUE_UL")).collect()[0][0]), 1) )
slice1DF14=slice1DF13.withColumn('maxUE_DL_Thrsld',when(col("avg_maxUE_DL") < str(slice1DF5.select(avg("avg_maxUE_DL")).collect()[0][0]), 0)              .when(col("avg_maxUE_DL") > str(slice1DF5.select(avg("avg_maxUE_DL")).collect()[0][0]), 1))
slice1DF15=slice1DF14.withColumn('maxUE_UL_Thrsld', when(col("avg_maxUE_UL") < str(slice1DF5.select(avg("avg_maxUE_UL")).collect()[0][0]), 0)              .when(col("avg_maxUE_UL") > str(slice1DF5.select(avg("avg_maxUE_UL")).collect()[0][0]), 1) )
slice1DF16=slice1DF15.withColumn('maxUE_UL_DL_Thrsld', when(col("avg_maxUE_UL_DL") < str(slice1DF5.select(avg("avg_maxUE_UL_DL")).collect()[0][0]), 0)              .when(col("avg_maxUE_UL_DL") > str(slice1DF5.select(avg("avg_maxUE_UL_DL")).collect()[0][0]), 1) )
slice1DF17=slice1DF16.withColumn('roam_Mean_Thrsld', when(col("avg_roam_Mean") < str(slice1DF5.select(avg("avg_roam_Mean")).collect()[0][0]), 1)              .when(col("avg_roam_Mean") > str(slice1DF5.select(avg("avg_roam_Mean")).collect()[0][0]), 0) )
slice1DF18=slice1DF17.withColumn('change_mouL_Thrsld', when(col("avg_change_mou") < str(slice1DF5.select(avg("avg_change_mou")).collect()[0][0]), 1)              .when(col("avg_change_mou") > str(slice1DF5.select(avg("avg_change_mou")).collect()[0][0]), 0) )
slice1DF19=slice1DF18.withColumn('drop_vce_Mean_Thrsld', when(col("avg_drop_vce_Mean") < str(slice1DF5.select(avg("avg_drop_vce_Mean")).collect()[0][0]), 0)              .when(col("avg_drop_vce_Mean") > str(slice1DF5.select(avg("avg_drop_vce_Mean")).collect()[0][0]), 1))
slice1DF20=slice1DF19.withColumn('drop_dat_Mean_Thrsld', when(col("avg_drop_dat_Mean") < str(slice1DF5.select(avg("avg_drop_dat_Mean")).collect()[0][0]), 0)              .when(col("avg_drop_dat_Mean") > str(slice1DF5.select(avg("avg_drop_dat_Mean")).collect()[0][0]), 1) )
slice1DF21=slice1DF20.withColumn('blck_vce_Mean_Thrsld', when(col("avg_blck_vce_Mean") < str(slice1DF5.select(avg("avg_blck_vce_Mean")).collect()[0][0]), 0)              .when(col("avg_blck_vce_Mean") > str(slice1DF5.select(avg("avg_blck_vce_Mean")).collect()[0][0]), 1) )
slice1DF22=slice1DF21.withColumn('blck_dat_Mean_Thrsld', when(col("avg_blck_dat_Mean") < str(slice1DF5.select(avg("avg_blck_dat_Mean")).collect()[0][0]), 0)              .when(col("avg_blck_dat_Mean") > str(slice1DF5.select(avg("avg_blck_dat_Mean")).collect()[0][0]), 1) )
slice1DF23=slice1DF22.withColumn('peak_vce_Mean_Thrsld', when(col("avg_peak_vce_Mean") < str(slice1DF5.select(avg("avg_peak_vce_Mean")).collect()[0][0]), 1)              .when(col("avg_peak_vce_Mean") > str(slice1DF5.select(avg("avg_peak_vce_Mean")).collect()[0][0]), 0) )
slice1DF24=slice1DF23.withColumn('peak_dat_Mean_Thrsld', when(col("avg_peak_dat_Mean") < str(slice1DF5.select(avg("avg_peak_dat_Mean")).collect()[0][0]), 1)              .when(col("avg_peak_dat_Mean") > str(slice1DF5.select(avg("avg_peak_dat_Mean")).collect()[0][0]), 0))
slice1DF25=slice1DF24.withColumn('opk_vce_Mean_Thrsld', when(col("avg_opk_vce_Mean") < str(slice1DF5.select(avg("avg_opk_vce_Mean")).collect()[0][0]), 1)              .when(col("avg_opk_vce_Mean") > str(slice1DF5.select(avg("avg_opk_vce_Mean")).collect()[0][0]), 0) )
slice1DF26=slice1DF25.withColumn('opk_dat_Mean_Thrsld', when(col("avg_opk_dat_Mean") < str(slice1DF5.select(avg("avg_opk_dat_Mean")).collect()[0][0]), 1)              .when(col("avg_opk_dat_Mean") > str(slice1DF5.select(avg("avg_opk_dat_Mean")).collect()[0][0]), 0))
slice1DF27=slice1DF26.withColumn('drop_blk_Mean_Thrsld',  when(col("avg_drop_blk_Mean") < str(slice1DF5.select(avg("avg_drop_blk_Mean")).collect()[0][0]), 1)              .when(col("avg_drop_blk_Mean") > str(slice1DF5.select(avg("avg_drop_blk_Mean")).collect()[0][0]), 0) )
slice1DF28=slice1DF27.withColumn('callfwdv_Mean_Thrsld', when(col("avg_callfwdv_Mean") < str(slice1DF5.select(avg("avg_callfwdv_Mean")).collect()[0][0]), 1)              .when(col("avg_callfwdv_Mean") > str(slice1DF5.select(avg("avg_callfwdv_Mean")).collect()[0][0]), 0))
slice1DF29=slice1DF28.withColumn('service_stability_voice_calls_Thrsld', when(col("service_stability_voice_calls")> str(slice1DF5.select(avg("service_stability_voice_calls")).collect()[0][0]) , 0)              .when(col("service_stability_voice_calls")< str(slice1DF5.select(avg("service_stability_voice_calls")).collect()[0][0]), 1))
slice1DF30=slice1DF29.withColumn('service_stability_data_calls_Thrsld', when(col("service_stability_data_calls")> str(slice1DF5.select(avg("service_stability_data_calls")).collect()[0][0]), 0)              .when(col("service_stability_data_calls")< str(slice1DF5.select(avg("service_stability_data_calls")).collect()[0][0]), 1))
slice1DF30=slice1DF30.fillna(value =0)
slice1DF30.show(truncate=False)

custDF5 = slice1DF30.withColumn("defected_count",col("PRBUsageUL_Thrsld")+col("PRBUsageDL_Thrsld")+col("meanThr_DL_Thrsld")+col("meanThr_UL_Thrsld")+col("maxThr_DL_Thrsld")+col("maxThr_UL_Thrsld")+col("meanUE_DL_Thrsld")+col("meanUE_UL_Thrsld")+col("maxUE_DL_Thrsld")+col("maxUE_UL_Thrsld")+col("maxUE_UL_DL_Thrsld")+col("roam_Mean_Thrsld")+col("change_mouL_Thrsld")+col("drop_vce_Mean_Thrsld")+col("drop_dat_Mean_Thrsld")+col("blck_vce_Mean_Thrsld")+col("blck_dat_Mean_Thrsld")+col("peak_vce_Mean_Thrsld")+col("peak_dat_Mean_Thrsld")+col("opk_vce_Mean_Thrsld")+col("opk_dat_Mean_Thrsld")+col("drop_blk_Mean_Thrsld")+col("callfwdv_Mean_Thrsld")+col("service_stability_voice_calls_Thrsld")+col("service_stability_data_calls_Thrsld"))
custDF5.show(truncate = False)

#Creating bucket's in cloud with the level's of slicing as different datasets
custDF5.write.parquet(os.path.join(output_data, user_name+"_customer_service_threshold"), mode = "overwrite")

#Writing the Output data to BigQuery
bq_client = bigquery.Client(project=project_name)

query = f"""
CREATE OR REPLACE EXTERNAL TABLE `"""+data_set+"""."""+user_name+"""_customer_service_metrics_data` OPTIONS (
format = 'PARQUET', uris = ['"""+output_data+"""/"""+user_name+"""_customer_service_threshold/*.parquet'] );
"""

job = bq_client.query(query)
job.result()
spark.stop()
