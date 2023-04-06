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

# Top Words in Shakespeare Dataset


## 1. Overview

With the advent of cloud environments, the concept of huge capital investments in infrastructure in terms of capital and maintenance is a thing of the past. Even when it comes to provisioning infrastructure on cloud services, it can get tedious and cumbersome.
In this example, you will look at executing a simple PySpark code which runs on Serverless batch through Bigquery.

The Goal is to run PySpark code in Bigquery console. The code provided in the repo will calculate top words in the Shakespeare public BigQuery dataset and display the top 20 words.
<br>

## 2. Services Used

* Google Cloud BigQuery

## 3. Permissions / IAM Roles required to run the lab

Following permissions / roles are required to execute the serverless batch

- Viewer
- BigQuery Admin
- Project IAM Admin

## 4. Checklist

To perform the lab, below are the list of activities to perform.-<br>

[1. GCP Prerequisites ](instructions/01-gcp-prerequisites.md) <BR>
[2. Creating and calling store procedure](instructions/02-creating-and-calling-store-procedure.md) <BR>

***Note: The region to create dataset, spark connection and store procedure should be same.***

<br>

## 5. Lab Modules

The lab consists of the following modules.
 - Understand the Data
 - Creating the Apache Spark stored procedure
 - Invoking the Apache Spark stored procedure
 - Examine the logs
 - Explore the output
