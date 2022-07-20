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
PROJECT_ID = Variable.get("project_id")
REGION = Variable.get("region")
metastore_name=Variable.get("metastore_name")
subnet=models.Variable.get("subnet")
phs_server=Variable.get("phs")
code_bucket=Variable.get("code_bucket")
database_name=Variable.get("database_name")
bq_dataset=Variable.get("bq_dataset")
umsa=Variable.get("umsa")

name=<your_name_here>

dag_name= name+"_retail_data_analytics"
service_account= umsa+"@"+PROJECT_ID+".iam.gserviceaccount.com"

BATCH_ID1 = "retail-data-analytics-1"+str(ran)
BATCH_ID2 = "retail-data-analytics-2"+str(ran)
BATCH_ID3 = "retail-data-analytics-3"+str(ran)
BATCH_ID4 = "retail-data-analytics-4"+str(ran)

retail_url_table_creation= "gs://"+code_bucket+"/retail_store_analytics_metastore/00-scripts/retail_analytics_table_creation.py"
retail_url_sales_per_dow_per_departmentproduct="gs://"+code_bucket+"/retail_store_analytics_metastore/00-scripts/retail_analytics_sales_per_dow_per_departmentproduct.py"
retail_url_inventory= "gs://"+code_bucket+"/retail_store_analytics_metastore/00-scripts/retail_analytics_inventory.py"
retail_url_asileid= "gs://"+code_bucket+"/retail_store_analytics_metastore/00-scripts/retail_analytics_suggestionofaisle_id.py"



BATCH_CONFIG1 = {
    "pyspark_batch": {
        "main_python_file_uri": retail_url_table_creation,
        "args":[
          PROJECT_ID,
          bq_dataset,
          code_bucket,
          name,
          database_name
        ],
        "jar_file_uris": [
      "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
    ]
    },
    "environment_config":{
        "execution_config":{
            "service_account": service_account,
            "subnetwork_uri": subnet
            },         
        "peripherals_config": {
            "metastore_service": f"projects/{PROJECT_ID}/locations/{REGION}/services/{metastore_name}",
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{PROJECT_ID}/regions/{REGION}/clusters/{phs_server}"
                }
            },
        },
}

BATCH_CONFIG2 = {
    "pyspark_batch": {
        "main_python_file_uri": retail_url_sales_per_dow_per_departmentproduct,
        "args":[
          PROJECT_ID,
          bq_dataset,
          code_bucket,
          name,
          database_name
        ],
        "jar_file_uris": [
      "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
    ]
    },
    "environment_config":{
        "execution_config":{
            "service_account": service_account,
            "subnetwork_uri": subnet
            },         
        "peripherals_config": {
            "metastore_service": f"projects/{PROJECT_ID}/locations/{REGION}/services/{metastore_name}",
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{PROJECT_ID}/regions/{REGION}/clusters/{phs_server}"
                }
            },
        },
}

BATCH_CONFIG3 = {
    "pyspark_batch": {
        "main_python_file_uri": retail_url_inventory,
        "args":[
          PROJECT_ID,
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
            "service_account": service_account,
            "subnetwork_uri": subnet
            },         
        "peripherals_config": {
            "metastore_service": f"projects/{PROJECT_ID}/locations/{REGION}/services/{metastore_name}",
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{PROJECT_ID}/regions/{REGION}/clusters/{phs_server}"
                }
            },
        },
}

BATCH_CONFIG4 = {
    "pyspark_batch": {
        "main_python_file_uri": retail_url_asileid,
        "args":[
          PROJECT_ID,
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
            "service_account": service_account,
            "subnetwork_uri": subnet
            },         
        "peripherals_config": {
            "metastore_service": f"projects/{PROJECT_ID}/locations/{REGION}/services/{metastore_name}",
            "spark_history_server_config": {
                "dataproc_cluster": f"projects/{PROJECT_ID}/regions/{REGION}/clusters/{phs_server}"
                }
            },
        },
}

with models.DAG(
    name+"_retail_store_analytics",
    schedule_interval=None,
    start_date = days_ago(2),
    catchup=False,
) as dag_serverless_batch:
    # [START how_to_cloud_dataproc_create_batch_operator]
    
        create_serverless_batch1 = DataprocCreateBatchOperator(
        task_id="retail_analytics_table_creation",
        project_id=PROJECT_ID,
        region=REGION,
        batch=BATCH_CONFIG1,
        batch_id=BATCH_ID1,
    )    
        
        create_serverless_batch2 = DataprocCreateBatchOperator(
        task_id="retail_analytics_sales_per_dow_per_departmentproduct",
        project_id=PROJECT_ID,
        region=REGION,
        batch=BATCH_CONFIG2,
        batch_id=BATCH_ID2,
    )
    
    
        create_serverless_batch3 = DataprocCreateBatchOperator(
        task_id="retail_analytics_inventory",
        project_id=PROJECT_ID,
        region=REGION,
        batch=BATCH_CONFIG3,
        batch_id=BATCH_ID3,
    )
    
        create_serverless_batch4 = DataprocCreateBatchOperator(
        task_id="retail_analytics_asile_id",
        project_id=PROJECT_ID,
        region=REGION,
        batch=BATCH_CONFIG4,
        batch_id=BATCH_ID4,
    )
    
        create_serverless_batch1 >> create_serverless_batch2
        create_serverless_batch2 >> create_serverless_batch3
        create_serverless_batch2 >> create_serverless_batch4
