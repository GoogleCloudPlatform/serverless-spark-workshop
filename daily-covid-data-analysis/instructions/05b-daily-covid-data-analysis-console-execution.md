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

# Daily covid data analysis with Serverless Spark Batch through Google cloud console.

Following are the lab modules:

[1. Understanding Data](05b-daily-covid-data-analysis-console-execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](05b-daily-covid-data-analysis-console-execution.md#2-solution-architecture)<br>
[3. Create a new serverless batch on Dataproc](05b-daily-covid-data-analysis-console-execution.md#3-create-a-new-serverless-batch-on-dataproc)<br>
[4. Logging](05b-daily-covid-data-analysis-console-execution.md#4-logging)<br>

## 1. Understanding the data 

The datasets used for this project are 


1. [Confirmed data](01-datasets/confirmed_df .csv). <br>
2. [Death data](01-datasets/death_df.csv) . <br>
3. [Latest data](01-datasets/latest_data.csv). <br>
4. [US Medical data](01-datasets/us_medical_data.csv). <br>


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

## 3. Create a new serverless batch on Dataproc


Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

Next, fill in the following values in the batch creation window :

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/daily-covid-data-analysis/00-scripts/covid.py

<br>

<kbd>
<img src=../images/batches_4.JPG />
</kbd>

<br>

- **Arguments** - <br>
  Four Arguments needs to be provided: <br>
  
    * <your_code_bucket_name>

  **Note:** Press RETURN after each argument <br>
  **Note:** The arguments must be passed in the same order as mentioned as they are extracted in the order they are provided

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled

<br>

<kbd>
<img src=../images/batches_4_2_1.JPG />
<img src=../images/batch_4_2.png />
</kbd>

<br>

- **History Server Cluster** - <your_phs_cluster_name>

<br>

<kbd>
<img src=../images/batch_4_3.png />
</kbd>

<br>

Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

## 4. Logging

### 4.1 Serverless Batch logs

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

### 4.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=../images/image12.png />
</kbd>

<kbd>
<img src=../images/image13.png />
</kbd>

<br>
