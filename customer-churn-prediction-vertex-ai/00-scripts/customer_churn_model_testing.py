'''
  Copyright 2022 Google LLC
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
'''

import pyspark
import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import sys

spark = SparkSession.builder \
                    .appName('model testing') \
                    .getOrCreate()

#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
user_name=sys.argv[4]


sparkDF = spark.read.options(inferSchema = True, header= True).csv('gs://'+bucket_name+'/customer-churn-prediction-vertex-ai/01-datasets/customer_churn_test_model_data.csv')


sparkDF=sparkDF.withColumn("Partner",sparkDF.Partner.cast('string')).withColumn("Dependents",sparkDF.Dependents.cast('string')).withColumn("PhoneService",sparkDF.PhoneService.cast('string')).withColumn("PaperlessBilling",sparkDF.PaperlessBilling.cast('string'))
sparkDF=sparkDF.head(1)
sparkDF=spark.createDataFrame(sparkDF)

from pyspark.ml import PipelineModel
rf_model = PipelineModel.load(os.path.join('gs://'+bucket_name+'/customer-churn-prediction-vertex-ai/'+user_name+'_churn_model/model_files'))

#Replacing 'No internet service' to No for the following columns
replace_cols = [ 'OnlineSecurity', 'OnlineBackup', 'DeviceProtection',
                'TechSupport','StreamingTV', 'StreamingMovies']
#replace values
for col_name in replace_cols:
    dfwithNo = sparkDF.withColumn(col_name, when(col(col_name)== "No internet service","No").otherwise(col(col_name)))
    sparkDF = dfwithNo

predic = rf_model.transform(dfwithNo)


spark.conf.set("parentProject", project_name)
bucket = bucket_name
spark.conf.set("temporaryGcsBucket",bucket)
predic.write.format('bigquery') \
.mode("overwrite")\
.option('table', project_name+':'+dataset_name+'.'+user_name+'_test_output') \
.save()

print(predic.show(truncate=False))
