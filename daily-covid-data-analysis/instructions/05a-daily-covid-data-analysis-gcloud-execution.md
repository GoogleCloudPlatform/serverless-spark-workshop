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

# Daily covid data analysis with Serverless Spark Batch through Google Cloud Shell.

Following are the lab modules:

[1. Understanding Data](05a-daily-covid-data-analysis-gcloud-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](05a-daily-covid-data-analysis-gcloud-execution.md#2-solution-architecture)<br>
[3. Declaring Variables](05a-daily-covid-data-analysis-gcloud-execution.md#3-declaring-variables)<br>
[4. Running the job as a serverless batch on Dataproc](05a-daily-covid-data-analysis-gcloud-execution.md#4-running-the-job-as-a-serverless-batch-on-dataproc)<br>
[5. Logging](05a-daily-covid-data-analysis-gcloud-execution.md#5-logging)<br>

## 1. Understanding the data 

The datasets used for this project are 


1. [Confirmed data](01-datasets/confirmed_df.csv) <br>
2. [Death data](01-datasets/death_df.csv)<br>
3. [Latest data](01-datasets/latest_data.csv)<br>
4. [US Medical data](01-datasets/us_medical_data.csv)<br>


<br>

## 2. Solution Architecture

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


## 3. Declaring Variables

#### 3.1 Set the PROJECT_ID in Cloud Shell

Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)<br>
Run the below
```
gcloud config set project $PROJECT_ID

```

####  3.2 Verify the PROJECT_ID in Cloud Shell

Next, run the following command in cloud shell to ensure that the current project is set correctly:

```
gcloud config get-value project
```

####  3.3 Declare the variables

Based on the prereqs and checklist, declare the following variables in cloud shell by replacing with your values:


```
PROJECT_ID=$(gcloud config get-value project)       #current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
SUBNET=                                             #subnet which has private google access enabled
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
BUCKET_PHS=                                         #bucket where our application logs created in the history server will be stored
HISTORY_SERVER_NAME=                                #name of the history server which will store our application logs
UMSA=serverless-spark                               #name of the user managed service account required for the PySpark job executions
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=                                               #your name
```
### 3.4 Update Cloud Shell SDK version

Run the below on cloud shell-

```
gcloud components update

```

## 4.  Running the job as a serverless batch on Dataproc

* Execute the following gcloud commands in cloud shell in the given order to execute daily-covid-data-analysis python file.


```
gcloud dataproc batches submit \
--project $PROJECT_ID \
--region $REGION pyspark \
--batch $NAME-daily-covid-data-analysis-$RANDOM \
gs://$BUCKET_CODE/daily-covid-data-analysis/00-scripts/covid.py \
--subnet $SUBNET \
--service-account $SERVICE_ACCOUNT \
--history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
-- $BUCKET_CODE

```

## 5. Logging

### 5.1 Serverless Batch logs

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

### 5.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>
