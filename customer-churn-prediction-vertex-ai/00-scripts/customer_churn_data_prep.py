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
from pyspark.sql import SparkSession
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.preprocessing import LabelEncoder as LE
import sys

spark = SparkSession.builder \
                    .appName('churn model') \
                    .getOrCreate()
 
#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
user_name=sys.argv[4]
 
#Reading Data into Spark Dataframe.
#sparkDF = spark.read \
  #.format('bigquery') \
  #.load(project_name+'.'+dataset_name+'.'+ user_name+'_churn_data')
  
churn_dataset_df = spark.read.options(inferSchema = True, header= True).csv('gs://'+bucket_name+'/customer-churn-prediction-vertex-ai/01-datasets/customer_churn_train_data.csv')


#print(sparkDF)

#Data Wrangling
#Replacing spaces with null values in total charges column
from pyspark.sql.functions import *
dfWithEmptyReplaced = churn_dataset_df.withColumn('TotalCharges', when(col('TotalCharges') == ' ', None).otherwise(col('TotalCharges')).cast("float"))
dfWithEmptyReplaced = dfWithEmptyReplaced.na.drop()
#Replacing 'No internet service' to No for the following columns
replace_cols = [ 'OnlineSecurity', 'OnlineBackup', 'DeviceProtection',
                'TechSupport','StreamingTV', 'StreamingMovies']
#replace values
for col_name in replace_cols:
    dfwithNo = dfWithEmptyReplaced.withColumn(col_name, when(col(col_name)== "No internet service","No").otherwise(col(col_name)))
    dfWithEmptyReplaced = dfwithNo

dfwithNo.createOrReplaceTempView("datawrangling")
# Using Spark SQL to create categories
df_wrangling = spark.sql("""
select distinct
         customerID
        ,gender
        ,SeniorCitizen
        ,Partner
        ,Dependents
        ,tenure
        ,case when (tenure<=12) then "Tenure_0-12"
              when (tenure>12 and tenure <=24) then "Tenure_12-24"
              when (tenure>24 and tenure <=48) then "Tenure_24-48"
              when (tenure>48 and tenure <=60) then "Tenure_48-60"
              when (tenure>60) then "Tenure_gt_60"
        end as tenure_group
        ,PhoneService
        ,MultipleLines
        ,InternetService
        ,OnlineSecurity
        ,OnlineBackup
        ,DeviceProtection
        ,TechSupport
        ,StreamingTV
        ,StreamingMovies
        ,Contract
        ,PaperlessBilling
        ,PaymentMethod
        ,MonthlyCharges
        ,TotalCharges
        ,Churn
    from datawrangling
""")

(trainingData, testData) = df_wrangling.randomSplit([0.7, 0.3], seed=200)
spark.conf.set("parentProject", project_name)
bucket = bucket_name+"/customer-churn-prediction-vertex-ai"
spark.conf.set("temporaryGcsBucket",bucket)
trainingData.write.format('bigquery') \
.mode("overwrite")\
.option('table', project_name+':'+dataset_name+'.'+user_name+'_training_data') \
.save()

testData.write.format('bigquery') \
.mode("overwrite")\
.option('table', project_name+':'+dataset_name+'.'+user_name+'_test_data') \
.save()
