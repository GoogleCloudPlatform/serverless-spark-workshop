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
code_bucket=Variable.get("code_bucket")
umsa=Variable.get("umsa")

name="<your_name_here>"

dag_name= name+"_covid_data_analytics_dag"
service_account_id= umsa+"@"+project_id+".iam.gserviceaccount.com"

covid_script= "gs://"+code_bucket+"/daily-covid-data-analysis/00-scripts/covid.py"

BATCH_ID = name+"-covid-data-analytics-"+str(ran)

BATCH_CONFIG1 = {
    "pyspark_batch": {
        "main_python_file_uri": covid_script,
        "args": [
          code_bucket
        ],

    },
    "environment_config":{
        "execution_config":{
              "service_account": service_account_id,
            "subnetwork_uri": subnet
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
        task_id="Covid-script",
        project_id=project_id,
        region=region,
        batch=BATCH_CONFIG1,
        batch_id=BATCH_ID,
    )
  
    # [END how_to_cloud_dataproc_create_batch_operator]

    create_serverless_batch1 
