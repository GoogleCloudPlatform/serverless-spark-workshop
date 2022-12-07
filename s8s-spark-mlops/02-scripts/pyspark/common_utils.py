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

# ............................................................
# Common Utilities
# ............................................................
# This script contains common variable definitions and functions
# ............................................................

from pyspark.sql import SparkSession
from pyspark.ml import Pipeline
from pyspark.ml.feature import OneHotEncoder, StringIndexer, VectorAssembler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.mllib.evaluation import MulticlassMetrics
from pyspark.ml.evaluation import BinaryClassificationEvaluator, MulticlassClassificationEvaluator
from pyspark.ml.tuning import ParamGridBuilder, CrossValidator
from pyspark.sql.types import FloatType
import pyspark.sql.functions as F
from pyspark.ml.feature import StringIndexer
import pandas as pd
import sys, logging, argparse, random, tempfile, json
from pyspark.sql.functions import *
from pyspark.sql.functions import col, udf
from pyspark.sql.functions import round as spark_round
from pyspark.sql.types import StructType, DoubleType, StringType
from pyspark.sql.functions import lit
from pathlib import Path as path
from google.cloud import storage
from urllib.parse import urlparse, urljoin
from datetime import datetime

logFormatter = logging.Formatter('%(asctime)s - %(filename)s - %(levelname)s - %(message)s')
logger = logging.getLogger("common_utils")
logger.setLevel(logging.INFO)
logger.propagate = False
logStreamHandler = logging.StreamHandler(sys.stdout)
logStreamHandler.setFormatter(logFormatter)
logger.addHandler(logStreamHandler)

# ......................................................................................
# Reusable Variables
# ......................................................................................
TARGETED_COLUMNS_FOR_VALUE_CONSISTENCY = ['OnlineSecurity', 'OnlineBackup', 'DeviceProtection',
                                          'TechSupport', 'StreamingTV', 'StreamingMovies']

CATEGORICAL_COLUMN_LIST = ['gender', 'senior_citizen', 'partner', 'dependents', 'phone_service', 'multiple_lines',
                        'internet_service', 'online_security', 'online_backup', 'device_protection', 'tech_support',
                        'streaming_tv', 'streaming_movies', 'contract', 'paperless_billing', 'payment_method']                      
NUMERIC_COLUMN_LIST = ['monthly_charges', 'total_charges']

# ......................................................................................
# Reusable Functions - Data preprocessing
# ......................................................................................

def fnReplaceSpaceWithNone(rawChurnDF):
    """
    Replace spaces with "None" in TotalCharges and MonthlyCharges
    Args:
        rawChurnDF:  Dataframe with raw churn data
    Returns:
        Dataframe with spaces replaced by "None"
    """
    logger.info('....Inside common_utils.fnReplaceSpaceWithNone')
    spaceReplacedDF = rawChurnDF.withColumn('TotalCharges',
                                            when(col('TotalCharges') == ' ', None).otherwise(col('TotalCharges')).cast(
                                                "float")) \
        .withColumn('MonthlyCharges',
                    when(col('MonthlyCharges') == ' ', None).otherwise(col('MonthlyCharges')).cast("float"))

    return spaceReplacedDF
# }} End fnReplaceSpaceWithNone

def fnReplaceNotANumberWithNone(inputDF):
    """
    Replace non-numeric data with "None" in TotalCharges and MonthlyCharges
    Args:
        inputDF:  Input dataframe
    Returns:
        Dataframe with non-numeric values replaced with "None"
    """
    logger.info('....Inside common_utils.fnReplaceNotANumberWithNone')
    nanReplacedDF = inputDF.withColumn('TotalCharges',
                                       when(isnan(col('TotalCharges')), None).otherwise(col('TotalCharges'))) \
        .withColumn('MonthlyCharges', when(isnan(col('MonthlyCharges')), None).otherwise(col('MonthlyCharges')))

    return nanReplacedDF
# }} End fnReplaceNotANumberWithNone

def fnReplaceWithNoForInternetService(inputDF):
    """
    Replace "No internet service" with "No" in columns in TARGETED_COLUMNS_FOR_VALUE_CONSISTENCY
    Args:
        inputDF:  Input dataframe
    Returns:
        Dataframe with values replaced per transformation
    """
    
    logger.info('....Inside common_utils.fnReplaceWithNoForInternetService')
    for col_name in TARGETED_COLUMNS_FOR_VALUE_CONSISTENCY:
        outputDF = inputDF.withColumn(col_name,
                                      when(col(col_name) == "No internet service", "No").otherwise(col(col_name)))
        inputDF = outputDF

    return inputDF
# }} End fnReplaceWithNoForInternetService

def fnAddBinForTenure(inputDF, isBatchScoring, spark):
    """
    Adds a bin/bucket category for tenure range using Spark SQL
    Args:
        inputDF:  Input dataframe
        isBatchScoring: boolean
        spark: Spark session
    Returns:
        Dataframe with transformation
    """

    logger.info('....Inside common_utils.fnAddBinForTenure')
    inputDF.createOrReplaceTempView("partially_transformed_customer_churn")
    if isBatchScoring:
        outputDF = spark.sql("""
                                select distinct
                                         customerID as CustomerID
                                        ,gender as Gender
                                        ,SeniorCitizen
                                        ,Partner
                                        ,Dependents
                                        ,tenure as Tenure
                                        ,case when (tenure<=12) then "Tenure_0-12"
                                              when (tenure>12 and tenure <=24) then "Tenure_12-24"
                                              when (tenure>24 and tenure <=48) then "Tenure_24-48"
                                              when (tenure>48 and tenure <=60) then "Tenure_48-60"
                                              when (tenure>60) then "Tenure_gt_60"
                                        end as Tenure_Group
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
                                from partially_transformed_customer_churn  
                                """)

    else:
        outputDF = spark.sql("""
                                select distinct
                                         customerID as CustomerID
                                        ,gender as Gender
                                        ,SeniorCitizen
                                        ,Partner
                                        ,Dependents
                                        ,tenure as Tenure
                                        ,case when (tenure<=12) then "Tenure_0-12"
                                              when (tenure>12 and tenure <=24) then "Tenure_12-24"
                                              when (tenure>24 and tenure <=48) then "Tenure_24-48"
                                              when (tenure>48 and tenure <=60) then "Tenure_48-60"
                                              when (tenure>60) then "Tenure_gt_60"
                                        end as Tenure_Group
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
                                        ,lcase(Churn) as Churn
                                from partially_transformed_customer_churn  
                                """)

    return outputDF
# }} End fnAddBinForTenure


# ......................................................................................
# Reusable Functions - Model training and Hyperparameter tuning
# ......................................................................................

def fnGetTrueScoreAndPrediction(predictionsDF, labelColumn):
    """
    Get true, score and prediction
    Args:
        predictionsDF: predictions dataframe
        labelColumn: labelColumn
    Returns:
        rocDictionary: a dictionary of roc values for each class
    """

    fnExtractItemFromVector = udf(lambda value: value[1].item(), DoubleType())
    rocSparkDF = predictionsDF.select(col(labelColumn).alias('true'),
                                     spark_round(fnExtractItemFromVector('probability'), 5).alias('score'),
                                     'prediction')
    rocSparkDF.show(2)
    
    rocPandasDF = rocSparkDF.toPandas()
    rocDictionary = rocPandasDF.to_dict(orient='list')
    return rocDictionary
# }} End fnGetTrueScoreAndPrediction

def fnCaptureModelMetrics(predictionsDF, labelColumn, operation):
    """
    Get model metrics
    Args:
        predictions: predictions
        labelColumn: target column
        operation: train or test
    Returns:
        metrics: metrics
    """
    
    metricLabels = ['area_roc', 'area_prc', 'accuracy', 'f1', 'precision', 'recall']
    metricColumns = ['true', 'score', 'prediction']
    metricKeys = [f'{operation}_{ml}' for ml in metricLabels] + metricColumns

    # Instantiate evaluators
    bcEvaluator = BinaryClassificationEvaluator(labelCol=labelColumn)
    mcEvaluator = MulticlassClassificationEvaluator(labelCol=labelColumn)

    # Capture metrics -> areas, acc, f1, prec, rec
    area_roc = round(bcEvaluator.evaluate(predictionsDF, {bcEvaluator.metricName: 'areaUnderROC'}), 5)
    area_prc = round(bcEvaluator.evaluate(predictionsDF, {bcEvaluator.metricName: 'areaUnderPR'}), 5)
    acc = round(mcEvaluator.evaluate(predictionsDF, {mcEvaluator.metricName: "accuracy"}), 5)
    f1 = round(mcEvaluator.evaluate(predictionsDF, {mcEvaluator.metricName: "f1"}), 5)
    prec = round(mcEvaluator.evaluate(predictionsDF, {mcEvaluator.metricName: "weightedPrecision"}), 5)
    rec = round(mcEvaluator.evaluate(predictionsDF, {mcEvaluator.metricName: "weightedRecall"}), 5)

    # Get the true, score, prediction off of the test results dataframe
    rocDictionary = fnGetTrueScoreAndPrediction(predictionsDF, labelColumn)
    true = rocDictionary['true']
    score = rocDictionary['score']
    prediction = rocDictionary['prediction']

    # Create a metric values array
    metricValuesArray = [] 
    metricValuesArray.extend((area_roc, area_prc, acc, f1, prec, rec))
    #metricValuesArray.extend((area_roc, area_prc, acc, f1, prec, rec, true, score, prediction))
    
    # Zip the keys and values into a dictionary  
    metricsDictionary = dict(zip(metricKeys, metricValuesArray))

    return metricsDictionary
# }} End fnCaptureModelmetrics

def fnPersistMetrics(destinationGcsBucketUri, metricsDictionary, destinationObjectName, dir='/tmp'):
    """
    Persists the metrics dictionary to a local file 
    and then to specified GCS location with specified name
    """
    localTempDir = tempfile.TemporaryDirectory(dir=dir)
    metricsLocalFilePath = str(path(localTempDir.name) / path(destinationObjectName).name)
    with open(metricsLocalFilePath, 'w') as tempFile:
        json.dump(metricsDictionary, tempFile)
    fnPersistToGCS(destinationGcsBucketUri, metricsLocalFilePath, destinationObjectName)
    localTempDir.cleanup()
# }} End fnPersistMetrics

def fnPersistToGCS(destinationGcsBucketUri, localFileAbsolutePath, destinationObjectName):
    """
    Persists a local file to specified GCS location with specified name
    """
    googleCloudStorageClient = storage.Client()
    googleCloudStorageBucket = googleCloudStorageClient.bucket(destinationGcsBucketUri)
    blob = googleCloudStorageBucket.blob(destinationObjectName)
    blob.upload_from_filename(localFileAbsolutePath)
# }} End fnPersistToGCS

