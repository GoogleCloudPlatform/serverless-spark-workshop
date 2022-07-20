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
import sys

#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
user_name=sys.argv[4]
database_name=sys.argv[5]



# Building the Spark Session
spark = SparkSession.builder.appName('pyspark-retail-inventory').config('spark.jars', 'gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar').getOrCreate()

#Creating the database and using it.

spark.sql(""" CREATE DATABASE IF NOT EXISTS {} """.format(database_name));

spark.sql(""" USE {}""".format(database_name));

# Creating schema for the external tables
spark.sql("""DROP TABLE IF EXISTS aisles""");

spark.sql(""" CREATE EXTERNAL TABLE aisles (
  aisle_id STRING COMMENT 'aisle_id',
  aisle STRING COMMENT 'aisle'
) USING CSV
OPTIONS (path "gs://{}/retail_store_analytics_metastore/01-datasets/aisles",
        delimiter ",",
        header "true")
""".format(bucket_name))


spark.sql("""DROP TABLE IF EXISTS departments""");

spark.sql(""" CREATE EXTERNAL TABLE departments (
  department_id STRING COMMENT 'department_id',
  department STRING COMMENT 'department'
) USING CSV
OPTIONS (path "gs://{}/retail_store_analytics_metastore/01-datasets/departments",
        delimiter ",",
        header "true")
""".format(bucket_name))


spark.sql("""DROP TABLE IF EXISTS orders""");
spark.sql(""" CREATE EXTERNAL TABLE orders (
  order_id STRING COMMENT 'order_id',
  user_id STRING COMMENT 'user_id',
  eval_set STRING COMMENT 'eval_set',
  order_number STRING COMMENT 'order_number',
  order_dow STRING COMMENT 'order_dow',
  order_hour_of_day STRING COMMENT 'order_hour_of_day',
  days_since_prior_order STRING COMMENT 'days_since_prior_order'  
) USING CSV
OPTIONS (path "gs://{}/retail_store_analytics_metastore/01-datasets/orders",
        delimiter ",",
        header "true")
""".format(bucket_name))


spark.sql("""DROP TABLE IF EXISTS products""");

spark.sql(""" CREATE EXTERNAL TABLE products (
  product_id STRING COMMENT 'product_id',
  product_name STRING COMMENT 'product_name',
  aisle_id STRING COMMENT 'aisle_id',
  department_id STRING COMMENT 'department_id'
) USING CSV
OPTIONS (path "gs://{}/retail_store_analytics_metastore/01-datasets/products",
        delimiter ",",
        header "true")
""".format(bucket_name))



spark.sql("""DROP TABLE IF EXISTS order_products""");

spark.sql(""" CREATE EXTERNAL TABLE order_products (
  order_id STRING COMMENT 'order_id',
  product_id STRING COMMENT 'product_id',
  add_to_cart_order STRING COMMENT 'add_to_cart_order',
  reordered STRING COMMENT 'reordered'
) USING CSV
OPTIONS (path "gs://{}/retail_store_analytics_metastore/01-datasets/order_products",
        delimiter ",",
        header "true")
""".format(bucket_name))


print('Job Completed Successfully!')


