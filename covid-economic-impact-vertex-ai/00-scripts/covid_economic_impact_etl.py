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

from datetime import datetime
import os
import json
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf, col
from pyspark.sql.functions import year, month, dayofmonth, hour, weekofyear, dayofweek, date_format
from google.cloud import storage
import sys


#Reading the arguments and storing them in variables
project_name=<<your_project_name>>
dataset_name=<<your_dataset_name>>
bucket_name=<<your_bucket_name>>
user_name=<<your_user_name>>

#creating a spark session
spark =SparkSession.builder.appName("ETLCoviddata").config('spark.jars', 'gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar').getOrCreate()

#Writing the output to BigQuery
spark.conf.set("parentProject", project_name)
bucket = bucket_name
spark.conf.set("temporaryGcsBucket",bucket)

# read stock data file
stock_df = spark.read.options(inferSchema = True, header= True, delimiter=";").csv('gs://'+bucket_name+'/covid-economic-impact-vertex-ai/01-datasets/stock.csv')

# read stringency data file
stringency_df = spark.read.options(inferSchema = True, header= True, delimiter=";").csv('gs://'+bucket_name+'/covid-economic-impact-vertex-ai/01-datasets/stringency.csv')

# extract columns to create country table
country_table = stringency_df.selectExpr('Code as country_code','Country as country').dropDuplicates()

# write country table to parquet files
country_table.write.format('bigquery') .mode("overwrite").option('table', project_name+':'+dataset_name+'.'+user_name+'_countries') .save()

# extract columns to create stock table
stock_table = stock_df.selectExpr('Ticker as stock_id','names as company_name','Sector as sector').dropDuplicates()

# write stocks table to parquet files
stock_table.write.format('bigquery') .mode("overwrite").option('table', project_name+':'+dataset_name+'.'+user_name+'_stocks') .save()
    
# create time_table
time_table = stringency_df.select(['Date']).withColumn('day', dayofmonth('Date')).withColumn('month', month('Date')).withColumn('year', year('Date')).withColumn('weekday', date_format('Date', 'E')).dropDuplicates()
time_table.write.format('bigquery') .mode("overwrite").option('table', project_name+':'+dataset_name+'.'+user_name+'_times') .save()

stock_df.createOrReplaceTempView("stocks")
stringency_df.createOrReplaceTempView("stringency")
Ec_status_table = spark.sql(

'''SELECT DISTINCT monotonically_increasing_id() as ec_status_id, stringency.Date as date, stringency.Code as country_code, stringency.Stringency_Index as stringency_index, stocks.Ticker as stock_id, stocks.Value_Type as value_type, stocks.Value as value
FROM stocks
JOIN stringency 
ON stocks.Date = stringency.Date AND stocks.Country = stringency.Country'''

)
Ec_status_table.write.format('bigquery') .mode("overwrite").option('table', project_name+':'+dataset_name+'.'+user_name+'_ec_status') .save()

print('Job Completed Successfully!')
