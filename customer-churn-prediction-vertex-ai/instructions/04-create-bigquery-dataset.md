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

# About

This module includes all the steps for creating a BigQuery dataset and uploading data to BigQuery tables-<br>
[1. Declare variables](instructions/04-create-bigquery-dataset.md#1-declare-variables)<br>
[2. BigQuery Dataset Creation](instructions/04-create-bigquery-dataset.md#2-bigquery-dataset-creation)<br>


## 0. Prerequisites

#### 1. Create a project new project or select an existing project.
Note the project number and project ID.
We will need this for the rest for the lab

#### 2. IAM Roles needed to execute the prereqs
- BigQuery Data Editor

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)
Run the below
```
gcloud config set project $PROJECT_ID

```

<br>

## 1. Declare variables

We will use these throughout the lab. <br>
Run the below in cloud shells coped to the project you selected-

```
BQ_DATASET_NAME= #BigQuery dataset to be created

```

<br>

## 2. BigQuery Dataset Creation

We need to create a dataset for the tables to be created after the batch successful execution
In Cloud Shell, use the bq mk command to create a dataset under the current project using the following command:


```
bq mk $BQ_DATASET_NAME
```
<br>
