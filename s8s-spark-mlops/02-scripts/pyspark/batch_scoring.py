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
# Batch Scoring
# ............................................................
# This script does batch scoring.
# 1. It loads the model in GCS
# 2. Parses, transforms data to be scored
# 3. Uses the model to predict
# 4. Persists predictions to BigQuery
# ............................................................

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.ml import PipelineModel
import common_utils
import sys, logging, argparse
from datetime import datetime
from pyspark.sql.types import IntegerType

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
        '--modelVersion',
        help='Model version to use for scoring',
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
    modelVersion = args.modelVersion
    projectNbr = args.projectNbr
    projectID = args.projectID
    displayPrintStatements = args.displayPrintStatements

    # 1b. Variables
    appBaseName = "customer-churn-model"
    appNameSuffix = "batch-scoring"
    appName = f"{appBaseName}-{appNameSuffix}"
    modelBaseNm = appBaseName
    bqDatasetNm = f"{projectID}.customer_churn_ds"
    modelBucketUri = f"gs://s8s_model_bucket-{projectNbr}/{modelBaseNm}/hyperparameter-tuning/{modelVersion}"
    scoreDatasetBucketFQN = f"gs://s8s_data_bucket-{projectNbr}/customer_churn_score_data.csv"
    bigQueryOutputTableFQN = f"{bqDatasetNm}.batch_predictions"
    scratchBucketUri = f"s8s-spark-bucket-{projectNbr}/{appBaseName}/pipelineId-{pipelineID}/{appNameSuffix}/"
    pipelineExecutionDt = datetime.now().strftime("%Y%m%d%H%M%S")

    # 1c. Display input and output
    if displayPrintStatements:
        print("Starting batch_scoring for Customer Churn Predictions")
        print(".....................................................")
        print(f"The datetime now is - {pipelineExecutionDt}")
        print(" ")
        print("INPUT-")
        print(f"....pipelineID={pipelineID}")
        print(f"....modelVersion={modelVersion}")
        print(f"....projectNbr={projectNbr}")
        print(f"....projectID={projectID}")
        print(f"....displayPrintStatements={displayPrintStatements}")
        print(" ")
        print("OUTPUT-")
        print(f"....BigQuery Table={bigQueryOutputTableFQN}")
        print(f"SELECT * FROM {bigQueryOutputTableFQN} WHERE model_version='{modelVersion}' AND pipeline_id='{pipelineID}' AND pipeline_execution_dt='{pipelineExecutionDt}' LIMIT 10" )


    try:
        # 2. Spark Session creation
        print('....Initializing spark & spark configs')
        spark = SparkSession.builder.appName(appName).getOrCreate()

        # Spark configuration setting for writes to BigQuery
        spark.conf.set("parentProject", projectID)
        spark.conf.set("temporaryGcsBucket", scratchBucketUri)

        # 3. Read data to be scored from GCS
        print('....Read batch scoring input and profile')
        scoreRawDF = spark.read.options(inferSchema = True, header= True).csv(scoreDatasetBucketFQN)
        if displayPrintStatements:
            print(scoreRawDF.count())

        # 4. Display data, display summary stats
        if displayPrintStatements:
            scoreRawDF.show(2)
            scoreRawDF.describe().show()

        # 5. Replace spaces, space with null values in the TotalCharges and MonthlyCharges columns
        print('....Data pre-process: fnReplaceSpaceWithNone in TotalCharges and MonthlyCharges')
        spaceReplacedDF = common_utils.fnReplaceSpaceWithNone(scoreRawDF)
        if displayPrintStatements:
            print(spaceReplacedDF.count())

        # 6. Replace non-numeric values in the TotalCharges and MonthlyCharges columns
        print('....Data pre-process: ReplaceNotANumberWithNone in TotalCharges and MonthlyCharges')
        nanReplacedDF = common_utils.fnReplaceNotANumberWithNone(spaceReplacedDF)
        if displayPrintStatements:
            print(nanReplacedDF.count())

        # 7. Drop rows with null in columns
        print('....Data pre-process: Drop rows with none')
        nullDroppedDF = nanReplacedDF.na.drop()

        if displayPrintStatements:
            print(nullDroppedDF.count())

        # 8. Replace 'No internet service' across columns to 'No'
        print('....Data pre-process: Replace -No internet service- across columns with -No-')
        partiallyProcessedDF = common_utils.fnReplaceWithNoForInternetService(nullDroppedDF)
        if displayPrintStatements:
            print(partiallyProcessedDF.count())

        # 9. Add a bin/bucket category for tenure range using Spark SQL and write transformed to dataframe
        print('....Data pre-process: Replace -No internet service- across columns with -No-')
        scoreTargetDF = common_utils.fnAddBinForTenure(partiallyProcessedDF, True, spark)
        if displayPrintStatements:
            print(scoreTargetDF.count())
            scoreTargetDF.show(2)

        # 10. Format dataframe names for column name format consistency
        scorableDF = scoreTargetDF.select("customerID", "gender", "SeniorCitizen", "Partner", "Dependents", "tenure", "Tenure_Group", "PhoneService", "MultipleLines", "InternetService", "OnlineSecurity", "OnlineBackup", "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies", "Contract", "PaperlessBilling", "PaymentMethod", "MonthlyCharges", "TotalCharges") \
                                        .toDF("customer_id", "gender", "senior_citizen", "partner", "dependents", "tenure", "tenure_group", "phone_service", "multiple_lines", "internet_service", "online_security", "online_backup", "device_protection", "tech_support", "streaming_tv", "streaming_movies", "contract", "paperless_billing", "payment_method", "monthly_charges", "total_charges")

        if displayPrintStatements:
            print(scorableDF.count())
            scorableDF.show(2)

        # 11. Load the pre-trained, persisted model in GCS
        print('....Scoring: Load model out of GCS into memory')
        model = PipelineModel.load(f"{modelBucketUri}/bestModel/")

        # 12. Batch scoring
        print('....Scoring: Execute model.transform')
        batchScoreResultsDF = model.transform(scorableDF) \
                                .withColumn("model_version", lit(modelVersion).cast("string")) \
                                .withColumn("pipeline_id", lit(pipelineID).cast("string")) \
                                .withColumn("pipeline_execution_dt", lit(pipelineExecutionDt))

        if displayPrintStatements:
            batchScoreResultsDF.show(2)

        # 13. Persist to BigQuery
        print('....Persisting: Batch scoring results to BigQuery')
        batchScoreResultsDF.select("customer_id", "gender", "senior_citizen", "partner", "dependents", "tenure", "tenure_group", "phone_service", "multiple_lines", "internet_service", "online_security", "online_backup", "device_protection", "tech_support", "streaming_tv", "streaming_movies", "contract", "paperless_billing", "payment_method", "monthly_charges", "total_charges","prediction","model_version","pipeline_id","pipeline_execution_dt") \
        .write.format('bigquery') \
        .mode("append")\
        .option('table', bigQueryOutputTableFQN) \
        .save()


    except RuntimeError as coreError:
            logger.error(coreError)
    else:
        logger.info('Successfully completed batch scoring!')
# }} End fn_main()

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
# }} End fn_configureLogger()

if __name__ == "__main__":
    arguments = fnParseArguments()
    logger = fnConfigureLogger()
    fnMain(logger, arguments)
