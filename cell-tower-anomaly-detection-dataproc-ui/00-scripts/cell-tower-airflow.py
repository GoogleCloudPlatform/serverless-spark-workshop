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

import os
from airflow.models import Variable
from datetime import datetime
from airflow import models
from airflow.providers.google.cloud.operators.dataproc import (DataprocCreateBatchOperator,DataprocGetBatchOperator)
from datetime import datetime
from airflow.utils.dates import days_ago
import string
import random # define the random module
S = 10  # number of characters in the string.
# call random.choices() string module to find the string in Uppercase + numeric data.
ran = ''.join(random.choices(string.digits, k = S))
project_id = models.Variable.get("project_id")
region = models.Variable.get("region")
subnet=models.Variable.get("subnet")
phs_server=Variable.get("phs")
code_bucket=Variable.get("code_bucket")
bq_dataset=Variable.get("bq_dataset")
umsa=Variable.get("umsa")

name=<<your_name_here>>

dag_name= name+"_Cell_Tower_Anomaly_Detection"
service_account_id= umsa+"@"+project_id+".iam.gserviceaccount.com"

cust_threshold_join_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/customer_threshold_join.py"
cust_threshold_services_join_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/customer_threshold_services_join.py"
cust_service_indicator_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/customer_service_indicator.py"
cell_tower_performance_indicator_script= "gs://"+code_bucket+"/cell-tower-anomaly-detection/00-scripts/cell_tower_performance_indicator.py"

BATCH_ID = name+"-cell-tower-anomaly-detection-"+str(ran)

BATCH_CONFIG1 = {
    "pyspark_batch": {
        "main_python_file_uri": cust_threshold_join_script,
        "args": [
          project_id,
          bq_dataset,
          code_bucket,
          name
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
        "main_python_file_uri": cust_threshold_services_join_script,
        "args": [
        project_id,
        bq_dataset,
        code_bucket,
        name
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
        "main_python_file_uri": cust_service_indicator_script,
        "args": [
        project_id,
        bq_dataset,
        code_bucket,
        name
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
        "main_python_file_uri": cell_tower_performance_indicator_script,
        "args": [
        project_id,
        bq_dataset,
        code_bucket,
        name
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
    # [START how_to_cloud_dataproc_create_batch_operator]
    create_serverless_batch1 = DataprocCreateBatchOperator(
        task_id="Cleaning_Joining_Customer-Services",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG1,
        batch_id=BATCH_ID,
    )
    create_serverless_batch2 = DataprocCreateBatchOperator(
        task_id="Cleaning_Joining_Customer-Services-Telecom",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG2,
        batch_id=BATCH_ID,
    )
    create_serverless_batch3 = DataprocCreateBatchOperator(
        task_id="Customer_Aggregation_Workflow",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG3,
        batch_id=BATCH_ID,
    )
    create_serverless_batch4 = DataprocCreateBatchOperator(
        task_id="Celltower_Aggregation_Workflow",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG4,
        batch_id=BATCH_ID,
    )
    # [END how_to_cloud_dataproc_create_batch_operator]

    create_serverless_batch1 >> create_serverless_batch2
    create_serverless_batch2 >> create_serverless_batch3
    create_serverless_batch2 >> create_serverless_batch4
