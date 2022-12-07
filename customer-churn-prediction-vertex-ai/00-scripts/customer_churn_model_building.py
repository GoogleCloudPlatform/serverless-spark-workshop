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

from pyspark.sql import SparkSession
from pyspark.ml.feature import OneHotEncoder, StringIndexer, VectorAssembler
from pyspark.ml import Pipeline
import pyspark
from pyspark.ml.tuning import CrossValidator, ParamGridBuilder
from pyspark.ml.classification import LogisticRegression,\
                    RandomForestClassifier, GBTClassifier
from pyspark.ml.classification import MultilayerPerceptronClassifier
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
import sys

spark = SparkSession.builder \
                    .appName('Creating Model') \
                    .getOrCreate()

#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
user_name=sys.argv[4]

trainingData = spark.read \
  .format('bigquery') \
  .load(project_name+'.'+dataset_name+'.'+user_name+'_training_data')


trainingData=trainingData.withColumn("Partner",trainingData.Partner.cast('string')).withColumn("Dependents",trainingData.Dependents.cast('string')).withColumn("PhoneService",trainingData.PhoneService.cast('string')).withColumn("PaperlessBilling",trainingData.PaperlessBilling.cast('string')).withColumn("Churn",trainingData.Churn.cast('string'))

testData = spark.read \
  .format('bigquery') \
  .load(project_name+'.'+dataset_name+'.'+user_name+'_test_data')

testData=testData.withColumn("Partner",testData.Partner.cast('string')).withColumn("Dependents",testData.Dependents.cast('string')).withColumn("PhoneService",testData.PhoneService.cast('string')).withColumn("PaperlessBilling",testData.PaperlessBilling.cast('string')).withColumn("Churn",testData.Churn.cast('string'))


categoricalColumns = ['gender','SeniorCitizen','Partner','Dependents','PhoneService','MultipleLines','InternetService', 'OnlineSecurity', 'OnlineBackup', 'DeviceProtection', 'TechSupport', 'StreamingTV', 'StreamingMovies', 'Contract','PaperlessBilling','PaymentMethod']
stages = [] # stages in our Pipeline
for categoricalCol in categoricalColumns:
    # Category Indexing with StringIndexer
    stringIndexer = StringIndexer(inputCol=categoricalCol, outputCol=categoricalCol + "Index")
    # Use OneHotEncoder to convert categorical variables into binary SparseVectors
    encoder = OneHotEncoder(inputCols=[stringIndexer.getOutputCol()], outputCols=[categoricalCol + "classVec"])
    # Add stages.  These are not run here, but will run all at once later on.
    stages += [stringIndexer, encoder]

# Convert label into label indices using the StringIndexer
label_stringIdx = StringIndexer(inputCol="Churn", outputCol="label")
stages += [label_stringIdx]
# Transform all features into a vector using VectorAssembler
numericCols = ['MonthlyCharges', 'TotalCharges']#'TotalRmbRCN1',
assemblerInputs = numericCols + [c + "classVec" for c in categoricalColumns]
assembler = VectorAssembler(inputCols=assemblerInputs, outputCol="features")
stages += [assembler]
IDcols = ['customerID']

evaluator = MulticlassClassificationEvaluator(labelCol='label',
                                          metricName='accuracy')

rf=RandomForestClassifier(labelCol="label", featuresCol="features")

stages +=[rf]
pipeline_rf = Pipeline(stages=stages)


rf_model = pipeline_rf.fit(trainingData)

test_pred=rf_model.transform(testData)

accurac=evaluator.evaluate(test_pred)

print(accurac)

spark.conf.set("parentProject", project_name)
bucket = bucket_name
spark.conf.set("temporaryGcsBucket",bucket)
test_pred.write.format('bigquery') \
.mode("overwrite")\
.option('table', project_name+':'+dataset_name+'.'+user_name+'_predictions_data') \
.save()

rf_model.write().overwrite().save('gs://'+bucket_name+'/customer-churn-prediction-vertex-ai/'+user_name+'_churn_model/model_files')
