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
# Model training
# ............................................................
# This script does model training, with Spark MLLib-</br>
# Supervised learning, binary classification with
# RandomForestClassifier and uses the Spark MLLib pipeline API
# Uses BigQuery as a source, and writes test results, metrics and
# feature importance scores to BigQuery
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
from pyspark.sql.functions import col, udf
from pyspark.sql.functions import round as spark_round
from pyspark.sql.types import StructType, DoubleType, StringType, IntegerType
from pyspark.sql.functions import lit
from pathlib import Path as path
from google.cloud import storage
from urllib.parse import urlparse, urljoin
from datetime import datetime
import common_utils

def fnParseArguments():
# {{ Start
    """
    Purpose:
        Parse arguments received by script
    Returns:
        args
    """
    argsParser = argparse.ArgumentParser()
    argsParser.add_argument(
        '--pipelineID',
        help='Unique ID for the pipeline stages for traceability',
        type=str,
        required=True)
    argsParser.add_argument(
        '--projectNbr',
        help='The project number',
        type=str,
        required=True)
    argsParser.add_argument(
        '--projectID',
        help='The project id',
        type=str,
        required=True)
    argsParser.add_argument(
        '--displayPrintStatements',
        help='Boolean - print to screen or not',
        type=bool,
        required=True)
    return argsParser.parse_args()
# }} End fnParseArguments()

def fnMain(logger, args):
# {{ Start main

    # 1a. Arguments
    pipelineID = args.pipelineID
    projectNbr = args.projectNbr
    projectID = args.projectID
    displayPrintStatements = args.displayPrintStatements

    # 1b. Variables
    appBaseName = "customer-churn-model"
    appNameSuffix = "training"
    appName = f"{appBaseName}-{appNameSuffix}"
    modelBaseNm = appBaseName
    modelVersion = pipelineID
    userid = "USER_ID"
    bqDatasetNm = f"{projectID}.{userid}_customer_churn_ds"
    operation = appNameSuffix
    bigQuerySourceTableFQN = f"{bqDatasetNm}.training_data"
    bigQueryModelTestResultsTableFQN = f"{bqDatasetNm}.test_predictions"
    bigQueryModelMetricsTableFQN = f"{bqDatasetNm}.model_metrics"
    bigQueryFeatureImportanceTableFQN = f"{bqDatasetNm}.model_feature_importance_scores"
    modelBucketUri = f"gs://{userid}-s8s_model_bucket-{projectNbr}/{modelBaseNm}/{operation}/{modelVersion}"
    metricsBucketUri = f"gs://{userid}-s8s_metrics_bucket-{projectNbr}/{modelBaseNm}/{operation}/{modelVersion}"
    scratchBucketUri = f"s8s-spark-bucket-{projectNbr}/{appBaseName}/pipelineId-{pipelineID}/{appNameSuffix}/"
    pipelineExecutionDt = datetime.now().strftime("%Y%m%d%H%M%S")

    # Other variables, constants
    SPLIT_SEED = 6
    SPLIT_SPECS = [0.8, 0.2]

    # 1c. Display input and output
    if displayPrintStatements:
        logger.info("Starting model training for *Customer Churn* experiment")
        logger.info(".....................................................")
        logger.info(f"The datetime now is - {pipelineExecutionDt}")
        logger.info(" ")
        logger.info("INPUT PARAMETERS")
        logger.info(f"....pipelineID={pipelineID}")
        logger.info(f"....projectID={projectID}")
        logger.info(f"....projectNbr={projectNbr}")
        logger.info(f"....displayPrintStatements={displayPrintStatements}")
        logger.info(" ")
        logger.info("EXPECTED SETUP")
        logger.info(f"....BQ Dataset={bqDatasetNm}")
        logger.info(f"....Model Training Source Data in BigQuery={bigQuerySourceTableFQN}")
        logger.info(f"....Scratch Bucket for BQ connector=gs://s8s-spark-bucket-{projectNbr}")
        logger.info(f"....Model Bucket=gs://{userid}-s8s-model-bucket-{projectNbr}")
        logger.info(f"....Metrics Bucket=gs://{userid}-s8s-metrics-bucket-{projectNbr}")
        logger.info(" ")
        logger.info("OUTPUT")
        logger.info(f"....Model in GCS={modelBucketUri}")
        logger.info(f"....Model metrics in GCS={metricsBucketUri}")
        logger.info(f"....Model metrics in BigQuery={bigQueryModelMetricsTableFQN}")
        logger.info(f"....Model feature importance scores in BigQuery={bigQueryFeatureImportanceTableFQN}")
        logger.info(f"....Model test results in BigQuery={bigQueryModelTestResultsTableFQN}")

    try:
        # 2. Spark Session creation
        logger.info('....Initializing spark & spark configs')
        spark = SparkSession.builder.appName(appName).getOrCreate()

        # Spark configuration setting for writes to BigQuery
        spark.conf.set("parentProject", projectID)
        spark.conf.set("temporaryGcsBucket", scratchBucketUri)
        spark.conf.set("spark.sql.execution.arrow.pyspark.enabled", "true")

        # ........................................................
        # TRAINING DATA - READ & SPLIT
        # ........................................................

        # 3. Read training data
        logger.info('....Read the training dataset into a dataframe')
        inputDF = spark.read \
            .format('bigquery') \
            .load(bigQuerySourceTableFQN)

        # Typecast some columns to the right datatype
        inputDF = inputDF.withColumn("partner", inputDF.partner.cast('string')) \
            .withColumn("dependents", inputDF.dependents.cast('string')) \
            .withColumn("phone_service", inputDF.phone_service.cast('string')) \
            .withColumn("paperless_billing", inputDF.paperless_billing.cast('string')) \
            .withColumn("churn", inputDF.churn.cast('string')) \
            .withColumn("monthly_charges", inputDF.monthly_charges.cast('float')) \
            .withColumn("total_charges", inputDF.total_charges.cast('float'))

        if displayPrintStatements:
            inputDF.printSchema()
            logger.info(f"inputDF count={inputDF.count()}")

        # 4. Split to training and test datasets
        logger.info('....Split the dataset')
        trainDF, testDF = inputDF.randomSplit(SPLIT_SPECS, seed=SPLIT_SEED)

        # ........................................................
        # PREPROCESSING, FEATURE ENGINEERING
        # ........................................................
        # 5. Pre-process training data
        logger.info('....Data pre-procesing')
        dataPreprocessingStagesList = []
        # 5a. Create and append to pipeline stages - string indexing and one hot encoding
        for eachCategoricalColumn in common_utils.CATEGORICAL_COLUMN_LIST:
            # Category indexing with StringIndexer
            stringIndexer = StringIndexer(inputCol=eachCategoricalColumn, outputCol=eachCategoricalColumn + "Index")
            # Use OneHotEncoder to convert categorical variables into binary SparseVectors
            encoder = OneHotEncoder(inputCols=[stringIndexer.getOutputCol()], outputCols=[eachCategoricalColumn + "classVec"])
            # Add stages.  This is a lazy operation
            dataPreprocessingStagesList += [stringIndexer, encoder]

        # 5b. Convert label into label indices using the StringIndexer and append to pipeline stages
        labelStringIndexer = StringIndexer(inputCol="churn", outputCol="label")
        dataPreprocessingStagesList += [labelStringIndexer]

        # 6. Feature engineering
        logger.info('....Feature engineering')
        featureEngineeringStageList = []
        assemblerInputs = common_utils.NUMERIC_COLUMN_LIST + [c + "classVec" for c in common_utils.CATEGORICAL_COLUMN_LIST]
        featuresVectorAssembler = VectorAssembler(inputCols=assemblerInputs, outputCol="features")
        featureEngineeringStageList += [featuresVectorAssembler]

        # ........................................................
        # MODEL TRAINING
        # ........................................................

        # 7. Model training
        logger.info('....Model training')
        modelTrainingStageList = []
        rfClassifier = RandomForestClassifier(labelCol="label", featuresCol="features")
        modelTrainingStageList += [rfClassifier]

        # 8. Create a model training pipeline for stages defined
        logger.info('....Instantiating pipeline model')
        pipeline = Pipeline(stages=dataPreprocessingStagesList + featureEngineeringStageList + modelTrainingStageList)

        # 9. Fit the model
        logger.info('....Fit the model')
        pipelineModel = pipeline.fit(trainDF)

        # 10. Persist model to GCS
        logger.info('....Persist the model to GCS')
        pipelineModel.write().overwrite().save(modelBucketUri)

        # ........................................................
        # MODEL TESTING
        # ........................................................

        # 11. Test the model with the test dataset
        logger.info('....Test the model')
        predictionsDF = pipelineModel.transform(testDF)
        predictionsDF.show(2)

        # 12. Persist model testing results to BigQuery
        persistPredictionsDF = predictionsDF.withColumn("pipeline_id", lit(pipelineID).cast("string")) \
                                        .withColumn("model_version", lit(pipelineID).cast("string")) \
                                        .withColumn("pipeline_execution_dt", lit(pipelineExecutionDt)) \
                                        .withColumn("operation", lit(operation))

        persistPredictionsDF.write.format('bigquery') \
        .mode("append")\
        .option('table', bigQueryModelTestResultsTableFQN) \
        .save()


        # ........................................................
        # MODEL EXPLAINABILITY
        # ........................................................

        # 13a. Model explainability - feature importance
        pipelineModel.stages[-1].featureImportances

        # 13b. Function to parse feature importance
        def fnExtractFeatureImportance(featureImportanceSparseVector, predictionsDataframe, featureColumnListing):
            featureColumnMetadataList = []
            for i in predictionsDataframe.schema[featureColumnListing].metadata["ml_attr"]["attrs"]:
                featureColumnMetadataList = featureColumnMetadataList + predictionsDataframe.schema[featureColumnListing].metadata["ml_attr"]["attrs"][i]

            featureColumnMetadataPDF = pd.DataFrame(featureColumnMetadataList)
            featureColumnMetadataPDF['importance_score'] = featureColumnMetadataPDF['idx'].apply(lambda x: featureImportanceSparseVector[x])
            return(featureColumnMetadataPDF.sort_values('importance_score', ascending = False))

        # 13c. Print feature importance
        fnExtractFeatureImportance(pipelineModel.stages[-1].featureImportances, predictionsDF, "features")

        # 13d. Capture into a Pandas DF
        featureImportancePDF = fnExtractFeatureImportance(pipelineModel.stages[-1].featureImportances, predictionsDF, "features")

        # 13e. Persist feature importance scores to BigQuery
        # Convert Pandas to Spark DF & use Spark to persist
        featureImportanceDF = spark.createDataFrame(featureImportancePDF).toDF("feature_index","feature_nm","importance_score")

        persistFeatureImportanceDF = featureImportanceDF.withColumn("pipeline_id", lit(pipelineID).cast("string")) \
                                        .withColumn("model_version", lit(pipelineID).cast("string")) \
                                        .withColumn("pipeline_execution_dt", lit(pipelineExecutionDt)) \
                                        .withColumn("operation", lit(appNameSuffix))

        persistFeatureImportanceDF.show(2)

        persistFeatureImportanceDF.write.format('bigquery') \
        .mode("append")\
        .option('table', bigQueryFeatureImportanceTableFQN) \
        .save()

        # ........................................................
        # MODEL METRICS
        # ........................................................

        # 14a. Metrics capture function
        def fnParseModelMetrics(predictionsDF, labelColumn, operation, boolSubsetOnly):

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
            rocDictionary = common_utils.fnGetTrueScoreAndPrediction(predictionsDF, labelColumn)
            true = rocDictionary['true']
            score = rocDictionary['score']
            prediction = rocDictionary['prediction']

            # Create a metric values array
            metricValuesArray = []
            if boolSubsetOnly:
                metricValuesArray.extend((area_roc, area_prc, acc, f1, prec, rec))
            else:
                metricValuesArray.extend((area_roc, area_prc, acc, f1, prec, rec, true, score, prediction))

            # Zip the keys and values into a dictionary
            metricsDictionary = dict(zip(metricKeys, metricValuesArray))

            return metricsDictionary

        # 14b. Capture & display metrics subset
        modelMetrics = fnParseModelMetrics(predictionsDF, "label", "test", True)
        for m, v in modelMetrics.items():
            print(f'{m}: {v}')

        # 14c. Persist metrics subset to BigQuery
        metricsDF = spark.createDataFrame(modelMetrics.items(), ["metric_nm", "metric_value"])
        metricsWithPipelineIdDF = metricsDF.withColumn("pipeline_id", lit(pipelineID).cast("string")) \
                                        .withColumn("model_version", lit(pipelineID).cast("string")) \
                                        .withColumn("pipeline_execution_dt", lit(pipelineExecutionDt)) \
                                        .withColumn("operation", lit(appNameSuffix))

        metricsWithPipelineIdDF.show()

        metricsWithPipelineIdDF.write.format('bigquery') \
        .mode("append")\
        .option('table', bigQueryModelMetricsTableFQN) \
        .save()

        # 14d. Persist metrics subset to GCS
        blobName = f"{modelBaseNm}/{appNameSuffix}/{modelVersion}/subset/metrics.json"
        common_utils.fnPersistMetrics(urlparse(metricsBucketUri).netloc, modelMetrics, blobName)

        # 14e. Persist metrics in full to GCS
        # (The version persisted to BQ does not have True, Score and Prediction needed for Confusion Matrix
        # This version below has the True, Score and Prediction additionally)
        # {{
        # 14e.1. Capture
        modelMetricsWithTSP = fnParseModelMetrics(predictionsDF, "label", "test", False)

        # 14e.2. Persist
        blobName = f"{modelBaseNm}/{appNameSuffix}/{modelVersion}/full/metrics.json"
        print(blobName)
        common_utils.fnPersistMetrics(urlparse(metricsBucketUri).netloc, modelMetricsWithTSP, blobName)

        # 14e.3. Print
        for m, v in modelMetricsWithTSP.items():
            print(f'{m}: {v}')


    except RuntimeError as coreError:
            logger.error(coreError)
    else:
        logger.info('Successfully completed model training!')

# }} End fnMain()

def fnConfigureLogger():
# {{ Start
    """
    Purpose:
        Configure a logger for the script
    Returns:
        Logger object
    """
    logFormatter = logging.Formatter('%(asctime)s - %(filename)s - %(levelname)s - %(message)s')
    logger = logging.getLogger("data_engineering")
    logger.setLevel(logging.INFO)
    logger.propagate = False
    logStreamHandler = logging.StreamHandler(sys.stdout)
    logStreamHandler.setFormatter(logFormatter)
    logger.addHandler(logStreamHandler)
    return logger
# }} End fnConfigureLogger()

if __name__ == "__main__":
# {{ Entry point
    arguments = fnParseArguments()
    logger = fnConfigureLogger()
    fnMain(logger, arguments)

# }} End enty point
