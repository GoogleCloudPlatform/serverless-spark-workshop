# ======================================================================================
# ABOUT
# This script orchestrates the execution of the cell tower anomany detection jobs
# as a pipeline/workflow with dependencies managed
# ======================================================================================

import os
from airflow.models import Variable
from datetime import datetime
from airflow import models
from airflow.providers.google.cloud.operators.dataproc import (DataprocCreateBatchOperator,DataprocGetBatchOperator)
from datetime import datetime
from airflow.utils.dates import days_ago
import string
import random 

# Read environment variables into local variables
project_id = models.Variable.get("project_id")
region = models.Variable.get("region")
subnet=models.Variable.get("subnet")
phs_server=Variable.get("phs")
code_bucket=Variable.get("code_bucket")
bq_dataset=Variable.get("bq_dataset")
umsa=Variable.get("umsa")

# Define DAG name
dag_name= "cell_tower_anomaly_detection"

# User Managed Service Account FQN
service_account_id= umsa+"@"+project_id+".iam.gserviceaccount.com"

# PySpark script files in GCS, of the individual Spark applications in the pipeline
curate_customer_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/curate_customer_data.py"
curate_telco_performance_metrics_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/curate_telco_performance_data.py"
kpis_by_customer_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/kpis_by_customer.py"
kpis_by_cell_tower_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/kpis_by_cell_tower.py"

# This is to add a random suffix to the serverless Spark batch ID that needs to be unique each run 
# ...Define the random module
S = 10  # number of characters in the string.
# call random.choices() string module to find the string in Uppercase + numeric data.
ran = ''.join(random.choices(string.digits, k = S))

BATCH_ID = "lab-01-"+str(ran)

BATCH_CONFIG1 = {
    "pyspark_batch": {
        "main_python_file_uri": curate_customer_script,
        "args": [
          code_bucket
        ],
        "jar_file_uris": [
      "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
    ]
    },
    "environment_config":{
        "execution_config":{
              "service_account": service_account_id,
            "subnetwork_uri": subnet
            },
        "peripherals_config": {
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{project_id}/regions/{region}/clusters/{phs_server}"
                }
            },
        },
}
BATCH_CONFIG2 = {
    "pyspark_batch": {
        "main_python_file_uri": curate_telco_performance_metrics_script,
        "args": [
        code_bucket
        ],
        "jar_file_uris": [
      "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
    ]
    },
    "environment_config":{
        "execution_config":{
        "service_account": service_account_id,
            "subnetwork_uri": subnet
            },
        "peripherals_config": {
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{project_id}/regions/{region}/clusters/{phs_server}"
                }
            },
        },
}
BATCH_CONFIG3 = {
    "pyspark_batch": {
        "main_python_file_uri": kpis_by_customer_script,
        "args": [
        project_id,
        bq_dataset,
        code_bucket
        ],
        "jar_file_uris": [
      "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
    ]
    },
    "environment_config":{
        "execution_config":{
        "service_account": service_account_id,
            "subnetwork_uri": subnet
            },
        "peripherals_config": {
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{project_id}/regions/{region}/clusters/{phs_server}"
                }
            },
        },
}
BATCH_CONFIG4 = {
    "pyspark_batch": {
        "main_python_file_uri": kpis_by_cell_tower_script,
        "args": [
        project_id,
        bq_dataset,
        code_bucket
        ],
        "jar_file_uris": [
      "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
    ]
    },
    "environment_config":{
        "execution_config":{
        "service_account": service_account_id,
            "subnetwork_uri": subnet
            },
        "peripherals_config": {
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{project_id}/regions/{region}/clusters/{phs_server}"
                }
            },
        },
}


with models.DAG(
    dag_name,
    schedule_interval=None,
    start_date = days_ago(2),
    catchup=False,
) as dag_serverless_batch:
    curate_customer_master = DataprocCreateBatchOperator(
        task_id="Curate_Customer_Master_Data",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG1,
        batch_id=BATCH_ID + "-dej-customer",
    )
    curate_telco_performance_metrics = DataprocCreateBatchOperator(
        task_id="Curate_Telco_Performance_Metrics",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG2,
        batch_id=BATCH_ID + "-dej-telco",
    )
    calc_kpis_by_customer = DataprocCreateBatchOperator(
        task_id="Calc_KPIs_By_Customer",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG3,
        batch_id=BATCH_ID + "-dej-kpis-cust",
    )
    calc_kpis_by_cell_tower = DataprocCreateBatchOperator(
        task_id="Calc_KPIs_By_Cell_Tower",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG4,
        batch_id=BATCH_ID + "-dej-kpis-tower",
    )

    curate_customer_master >> curate_telco_performance_metrics
    curate_telco_performance_metrics >> calc_kpis_by_customer
    curate_telco_performance_metrics >> calc_kpis_by_cell_tower
