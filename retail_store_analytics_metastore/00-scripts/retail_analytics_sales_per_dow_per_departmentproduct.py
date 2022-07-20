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
database_name=sys.argv[5]



# Building the Spark Session
spark = SparkSession.builder.appName('pyspark-retail-inventory').config('spark.jars', 'gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar').getOrCreate()

spark.sql(""" USE {}""".format(database_name));

or_df=spark.sql(""" select * from order_products op inner join orders o on op.order_id =o.order_id """)

df_join=spark.sql(""" select * from products p inner join aisles a on p.aisle_id=a.aisle_id
inner join departments d on p.department_id=d.department_id """)

df_join = df_join.withColumnRenamed("product_id","product_id_del")
df=df_join.join(or_df,df_join.product_id_del ==  or_df.product_id,"inner")

windowSpecAgg  = Window.partitionBy("order_dow","department","product_id")

#calculating sales per order_dow_per_department_product

df_1=df.withColumn("sales_per_dow_per_departmentproduct", sum(col("add_to_cart_order")).over(windowSpecAgg)).select("sales_per_dow_per_departmentproduct","department","product_id","aisle","p.aisle_id","order_dow").distinct()

spark.conf.set("parentProject", project_name)
bucket = bucket_name
spark.conf.set("temporaryGcsBucket",bucket)

# writing data to bigquery
df_1.write.format('bigquery') .mode("overwrite").option('table', project_name+':'+dataset_name+'.'+user_name+'_sales_per_dow_per_departmentproduct') .save()

print('Job Completed Successfully!')
