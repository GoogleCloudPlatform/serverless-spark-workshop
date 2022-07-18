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

import os
from pyspark.sql.functions import col
from pyspark.sql import SparkSession
from google.cloud import bigquery
from pyspark.sql.window import Window
from pyspark.sql.functions import col,avg,sum,min,max,row_number
from pyspark.sql.functions import round
import sys

#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
user_name=sys.argv[4]



# Building the Spark Session
spark = SparkSession.builder.appName('pyspark-retail-inventory').config('spark.jars', 'gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar').getOrCreate()

df_1=spark.read.format("bigquery").load(project_name+'.'+dataset_name+'.'+user_name+'_sales_per_dow_per_departmentproduct')


average_windowspec=Window.partitionBy("product_id")

#calculating average sales
avg_df=df_1.withColumn("avg_sales",avg(col("sales_per_dow_per_departmentproduct")).over(average_windowspec))

#calculating inventory
inventory_df=avg_df.withColumn("inventory",round(col("avg_sales")-col("sales_per_dow_per_departmentproduct")))

# Printing test data for analysis
inventory_df.filter(col("product_id")==27845).show(20)

spark.conf.set("parentProject", project_name)
bucket = bucket_name
spark.conf.set("temporaryGcsBucket",bucket)

# writing data to bigquery
inventory_df.write.format('bigquery') .mode("overwrite").option('table', project_name+':'+dataset_name+'.'+user_name+'_inventory_data') .save()

print('Job Completed Successfully!')
