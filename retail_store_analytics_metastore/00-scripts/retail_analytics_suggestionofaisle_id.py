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

import pyspark
from datetime import datetime
from pyspark.sql.functions import col,isnan, when, count
import os
from pyspark.sql.functions import col
from pyspark.sql import SparkSession
from google.cloud import bigquery
from pyspark.sql.window import Window
from pyspark.sql.functions import col,avg,sum,min,max,row_number
from pyspark.sql.functions import round
from pyspark.sql.functions import desc
from pyspark.sql.functions import asc
from pyspark.sql.functions import rank
from pyspark.sql.functions import row_number
from pyspark.sql.functions import lag
import sys


#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
user_name=sys.argv[4]



# Building the Spark Session
spark = SparkSession.builder.appName('pyspark-retail-inventory').config('spark.jars', 'gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar').getOrCreate()

df_1=spark.read.format("bigquery").load(project_name+'.'+dataset_name+'.'+user_name+'_sales_per_dow_per_departmentproduct')

#Using window function on Department and arranging sales per order_dow_per_department_product on ascending  and descending order

windowSpecAgg1  = Window.partitionBy("order_dow","department").orderBy("sales_per_dow_per_departmentproduct")
windowSpecAgg2  = Window.partitionBy("order_dow","department").orderBy(col("sales_per_dow_per_departmentproduct").desc())

#Using row number function to rank based on the highest and lowest

df_2=df_1.withColumn("rank_ascending",row_number().over(windowSpecAgg1)).select("sales_per_dow_per_departmentproduct","department","product_id","rank_ascending","aisle","aisle_id","order_dow")

df_asc=df_2.filter(col("rank_ascending")<=20).orderBy(col("order_dow"),col("department"),col("rank_ascending").asc())

df_3=df_1.withColumn("rank_descending",row_number().over(windowSpecAgg2)).select("sales_per_dow_per_departmentproduct","department","product_id","rank_descending","aisle","aisle_id","order_dow")

df_dsc=df_3.filter(col("rank_descending")<=20)

df_asc=df_asc.withColumnRenamed("product_id","bottom_20_product_ids")
df_dsc=df_dsc.withColumnRenamed("product_id","top_20_product_ids")

#Calculating bottom and top 20 products

df_merge=df_dsc.unionByName(df_asc,allowMissingColumns=True)

#suggesting asile_id's


windowSpeclag = Window.partitionBy("order_dow","department").orderBy(col("sales_per_dow_per_departmentproduct").desc())
df_merge= df_merge.withColumn("suggested_asile_id",lag("aisle_id",20).over(windowSpeclag))

df_merge=df_merge.filter("bottom_20_product_ids IS NOT NULL")
df_merge=df_merge.select("department","aisle","aisle_id","bottom_20_product_ids","rank_ascending","suggested_asile_id","order_dow")
df_merge=df_merge.withColumnRenamed("aisle_id","current_aisle_id").withColumnRenamed("rank_ascending","rank")

# Printing test data for analysis
df_test=df_merge.filter(col("department")=="dairy eggs").filter(col("order_dow")==0)
df_test.show(100)

spark.conf.set("parentProject", project_name)
bucket = bucket_name
spark.conf.set("temporaryGcsBucket",bucket)

# writing data to bigquery
df_merge.write.format('bigquery') .mode("overwrite").option('table', project_name+':'+dataset_name+'.'+user_name+'_suggested_aisles_data') .save()

print('Job Completed Successfully!')


