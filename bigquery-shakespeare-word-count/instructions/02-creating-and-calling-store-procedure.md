<!---->
  Copyright 2023 Google LLC

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

## 1. Create the Store Procedure

* Go to the [BigQuery console](https://console.cloud.google.com/bigquery)

![bigquery](../images/bigquery.png)

* Open the external connection that has been created and then click on 'Create Store Procedure'
* Edit the query that appears in the Editor as follows:
* ![store procedure](../images/store_procedure.png)

```
CREATE PROCEDURE `<Insert_Project_ID>.<insert_bq_dataset_name>.<insert_user_name>_shakespeare_proc`()
WITH CONNECTION `<Insert_Project_ID>.<insert_location_used_in_dataset>.shakespeare-connection`
OPTIONS(engine="SPARK",
runtime_version="1.1")
LANGUAGE PYTHON AS R"""
<insert Spark Code Here>
"""
```
The Spark Code is located [here](../00-scripts-and-config/wordcount-calculation-bigquery.py)

* Click 'Run'

## 2. Calling the Store Procedure

* To call a stored procedure, use the CALL PROCEDURE statement:

- In the Google Cloud console, go to the [BigQuery Console](https://console.cloud.google.com/bigquery)


* In the query editor, enter the following statement:

```
CALL `<insert_PROJECT_ID>`.<insert_bq_dataset_name>.<insert_user_name>_shakespeare_proc()
```
* Click Run

### 3. Results

* Results can be viewed by clicking on 'View Results' > 'Execution Details'
![results](../images/results.png)
