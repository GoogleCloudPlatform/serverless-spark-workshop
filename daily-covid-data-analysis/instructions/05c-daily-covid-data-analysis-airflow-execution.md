<!---->
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
 <!---->

# Daily covid data analysis with Serverless Spark Batch through Airflow.

Following are the lab modules:

[1. Understanding Data](05c-daily-covid-data-analysis-airflow-execution.md#1-understanding-data)<br>
[2. Solution Diagram](05c-daily-covid-data-analysis-airflow-execution.md#2-solution-diagram)<br>
[3. Uploading DAG files to DAGs folder](05c-daily-covid-data-analysis-airflow-execution.md#3-uploading-dag-files-to-dags-folder)<br>
[4. Execution of Airflow DAG](05c-daily-covid-data-analysis-airflow-execution.md#4-execution-of-airflow-dag)<br>
[5. Logging](05c-daily-covid-data-analysis-airflow-execution.md#6-logging)<br>

## 1. Understanding the data 

The datasets used for this project are 


1. [Confirmed data](01-datasets/confirmed_df .csv). <br>
2. [Death data](01-datasets/death_df.csv) . <br>
3. [Latest data](01-datasets/latest_data.csv). <br>
4. [US Medical data](01-datasets/us_medical_data.csv). <br>


<br>

## 2. Solution Diagram

<kbd>
<img src=../images/Flow_of_Resources.jpeg />
</kbd>

<br>
<br>

**Model Pipeline**

The model pipeline involves the following steps: <br>
	- Create buckets in GCS <br>
	- Create Dataproc and Persistent History Server Cluster <br>
	- Copy the raw data files, pyspark and notebook files into GCS <br>
	- Create a Cloud Composer environment and Airflow jobs to as Serverless spark job <br>

<br>

## 3. Uploading DAG files to DAGs folder

* From the code repository, download the file located at: **daily-covid-data-analysis**>**00-scripts**>**pipeline_covid.py**
* Rename file to <your_name_here>-pipeline_covid.py
* Open the file and replace your name on row 19
* Navigate to **Composer**>**<composer_environment>**
* Next, navigate to **Environment Configuration**>**DAGs folder URI**
* Next, upload the DAG file to the GCS bucket corresponding to the **DAGs folder URI**

<kbd>
<img src=../images/composer_2.png />
</kbd>

<br>
<br>
<br>

<kbd>
<img src=../images/composer_3.png />
</kbd>

<br>
<br>
<br>


## 4. Execution of Airflow DAG

* Navigate to **Composer**>**<your_environment>**>**Open Airflow UI**

<kbd>
<img src=../images/composer_5.png />
</kbd>

<br>

* Once the Airflow UI opens, navigate to **DAGs** and open your respective DAG
* Next, trigger your DAG by clicking on the **Trigger DAG** button

<kbd>
<img src=../images/composer_6.png />
</kbd>

<br>

* Once the DAG is triggered, the DAG can be monitored directly through the Airflow UI as well as the Dataproc>Serverless>Batches window

<kbd>
<img src=../images/composer_7.JPG />
</kbd>

<br>

## 5. Logging

### 5.1 Airflow logging

* To view the logs of any step of the DAG execution, click on the **<DAG step>**>**Log** button <br>

<kbd>
<img src=../images/composer_8.png />
</kbd>

<br>

### 5.2 Serverless Batch logs

Logs associated with the application can be found in the logging console under
**Dataproc > Serverless > Batches > <batch_name>**.
<br> You can also click on “View Logs” button on the Dataproc batches monitoring page to get to the logging page for the specific Spark job.

<kbd>
<img src=../images/image10.png />
</kbd>

<kbd>
<img src=../images/image11.png />
</kbd>

<br>


### 5.3 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>
