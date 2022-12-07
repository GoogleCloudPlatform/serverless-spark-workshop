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
# Preprocessing
# ............................................................
# This script performs data preprocessing on raw data in GCS
# and persists to BigQuery
# ............................................................

import sys,logging,argparse
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
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

    # 1. Capture Spark application input
    pipelineID = args.pipelineID
    projectNbr = args.projectNbr
    projectID = args.projectID
    displayPrintStatements = args.displayPrintStatements

    # 1b. Variables
    bqDatasetNm = f"{projectID}.customer_churn_ds"
    appBaseName = "customer-churn-model"
    appNameSuffix = "preprocessing"
    appName = f"{appBaseName}-{appNameSuffix}"
    scratchBucketUri = f"s8s-spark-bucket-{projectNbr}/{appBaseName}/pipelineId-{pipelineID}/{appNameSuffix}"
    sourceBucketUri = f"gs://s8s_data_bucket-{projectNbr}/customer_churn_train_data.csv"
    bigQueryTargetTableFQN = f"{bqDatasetNm}.training_data"
    pipelineExecutionDt = datetime.now().strftime("%Y%m%d%H%M%S")

    # 1c. Display input and output
    if displayPrintStatements:
        logger.info("Starting preprocessing for the *Customer Churn* experiment")
        logger.info(".....................................................")
        logger.info(f"The datetime now is - {pipelineExecutionDt}")
        logger.info(" ")
        logger.info("INPUT PARAMETERS-")
        logger.info(f"....pipelineID={pipelineID}")
        logger.info(f"....projectID={projectID}")
        logger.info(f"....projectNbr={projectNbr}")
        logger.info(f"....displayPrintStatements={displayPrintStatements}")
        logger.info(" ")
        logger.info("EXPECTED SETUP-")
        logger.info(f"....BQ Dataset={bqDatasetNm}")
        logger.info(f"....Source Data={sourceBucketUri}")
        logger.info(f"....Scratch Bucket for BQ connector=gs://s8s-spark-bucket-{projectNbr}")
        logger.info("OUTPUT-")
        logger.info(f"....BigQuery Table={bigQueryTargetTableFQN}")
        logger.info(f"....Sample query-")
        logger.info(f"....SELECT * FROM {bigQueryTargetTableFQN} WHERE pipeline_id='{pipelineID}' LIMIT 10" )

    try:
        # 2. Spark Session creation
        logger.info('....Initializing spark & spark configs')
        spark = SparkSession.builder.appName(appName).getOrCreate()

        # Spark configuration setting for writes to BigQuery
        spark.conf.set("parentProject", projectID)
        spark.conf.set("temporaryGcsBucket", scratchBucketUri)

        # 3. Read raw data in GCS into a Spark Dataframe
        logger.info('....Read source data')
        rawChurnDF = spark.read.options(inferSchema = True, header= True).csv(sourceBucketUri)

        # 4. View the data
        if displayPrintStatements:
            logger.info(rawChurnDF.count())
            rawChurnDF.show(2)

        # 5. Profile the data
        if displayPrintStatements:
            rawChurnDF.describe().show()

        # 6. Check for spaces, nulls in monthly & total charges
        logger.info('....Exploratory Data Analysis')
        if displayPrintStatements:
            rawChurnDF.createOrReplaceTempView("base_customer_churn")
            spark.sql("select count(*) from base_customer_churn where MonthlyCharges is null or MonthlyCharges=' '").show(5)
            spark.sql("select count(*) from base_customer_churn where TotalCharges is null or TotalCharges=' '").show(5)

        # 7. Replace spaces, space with null values in the TotalCharges and MonthlyCharges columns
        logger.info('....Replace space, nulls with None')
        spaceReplacedDF = common_utils.fnReplaceSpaceWithNone(rawChurnDF)
        if displayPrintStatements:
            logger.info(spaceReplacedDF.count())

        # 8. Replace non-numeric values values in the TotalCharges and MonthlyCharges columns
        logger.info('....Replace non-numeric values in numeric columns with null')
        nanReplacedDF = common_utils.fnReplaceNotANumberWithNone(spaceReplacedDF)
        if displayPrintStatements:
            logger.info(nanReplacedDF.count())

        # 9. Drop rows with null in columns
        logger.info('....Drop nulls')
        nullDroppedDF = nanReplacedDF.na.drop()
        if displayPrintStatements:
            logger.info(nullDroppedDF.count())

        # 10. Replace 'No internet service' across columns to 'No'
        logger.info('....Replace -No internet service across columns- to -No-')
        partiallyProcessedDF = common_utils.fnReplaceWithNoForInternetService(nullDroppedDF)
        if displayPrintStatements:
            logger.info(partiallyProcessedDF.count())

        # 11. Add a bin/bucket category for tenure range using Spark SQL and write transformed to dataframe
        logger.info('....Add a bin for tenure')
        modelTrainingReadyDF = common_utils.fnAddBinForTenure(partiallyProcessedDF, False, spark)
        if displayPrintStatements:
            logger.info(modelTrainingReadyDF.count())

        # 12. Run summary statistics
        if displayPrintStatements:
            modelTrainingReadyDF.describe().show()

        # 13. Print schema
        modelTrainingReadyDF.printSchema()

        # 14. Format column names for consistency (title case to DB style & lowercase)
        logger.info('....Format column names for consistency')
        persistDF = modelTrainingReadyDF.select("customerID", "gender", "SeniorCitizen", "Partner", "Dependents", "tenure", "Tenure_Group", "PhoneService", "MultipleLines", "InternetService", "OnlineSecurity", "OnlineBackup", "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies", "Contract", "PaperlessBilling", "PaymentMethod", "MonthlyCharges", "TotalCharges","Churn") \
                                        .toDF("customer_id", "gender", "senior_citizen", "partner", "dependents", "tenure", "tenure_group", "phone_service", "multiple_lines", "internet_service", "online_security", "online_backup", "device_protection", "tech_support", "streaming_tv", "streaming_movies", "contract", "paperless_billing", "payment_method", "monthly_charges", "total_charges","churn") \
                                        .withColumn("pipeline_id", lit(pipelineID).cast("string")) \
                                        .withColumn("pipeline_execution_dt", lit(pipelineExecutionDt))

        persistDF.printSchema()

        # 15. Persist training dataset to a table in BQ with the pipeline ID and execution date for traceability
        logger.info('....Persist to BQ')
        persistDF.write.format('bigquery') \
        .mode("overwrite")\
        .option('table', bigQueryTargetTableFQN) \
        .save()

    except RuntimeError as coreError:
            logger.error(coreError)
    else:
        logger.info('Successfully completed preprocessing!')
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
    arguments = fnParseArguments()
    logger = fnConfigureLogger()
    fnMain(logger, arguments)
