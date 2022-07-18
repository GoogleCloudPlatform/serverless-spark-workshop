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

from pyspark.sql import SparkSession
from pyspark.sql.functions import expr
from pyspark.sql.types import *
import sys

# Creating a sparksession.

spark = SparkSession \
        .builder \
        .appName("Invoice data") \
        .config("spark.streaming.stopGracefullyOnShutdown", "true") \
        .config("spark.sql.streaming.schemaInference", "true") \
		.config('spark.jars', 'gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar') \
        .getOrCreate()

#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
user_name=sys.argv[4]

# Creating the Raw Dataframe by reading the data.
raw_df = spark.readStream \
        .format("json") \
        .option("path", 'gs://'+bucket_name+'/serverless_spark_streaming/01-datasets/streaming_data/*') \
        .option("mode", "DROPMALFORMED") \
        .option("maxFilesPerTrigger", 1) \
        .load()
        


# Flattening the JSON data using explode function.
explode_df = raw_df.selectExpr("InvoiceNumber", "CreatedTime", "StoreID", "PosID",
                                "CustomerType", "PaymentMethod", "DeliveryType", "DeliveryAddress.City",
                                "DeliveryAddress.State",
                                "DeliveryAddress.PinCode", "explode(InvoiceLineItems) as LineItem")

# Creating new columns.
flattened_df = explode_df \
        .withColumn("ItemCode", expr("LineItem.ItemCode")) \
        .withColumn("ItemDescription", expr("LineItem.ItemDescription")) \
        .withColumn("ItemPrice", expr("LineItem.ItemPrice")) \
        .withColumn("ItemQty", expr("LineItem.ItemQty")) \
        .withColumn("TotalValue", expr("LineItem.TotalValue")) \
        .drop("LineItem")
		
		

# Writing the data to big query .
spark.conf.set("parentProject", project_name)
bucket = bucket_name
spark.conf.set("temporaryGcsBucket",bucket)

invoiceWriterQuery = flattened_df.writeStream \
        .format("bigquery") \
        .queryName("Flattened Invoice Writer") \
        .outputMode("append") \
        .option("table", project_name+':'+dataset_name+'.'+user_name+'_invoicedata') \
        .option("checkpointLocation", 'gs://'+bucket_name+'/serverless_spark_streaming/01-datasets/checkpointdir_'+user_name+'/') \
        .trigger(processingTime="1 minute") \
        .start()

invoiceWriterQuery.awaitTermination()



