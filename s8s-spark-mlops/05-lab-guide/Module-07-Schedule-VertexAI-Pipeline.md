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

# About Module 7

This module covers creating a Cloud Scheduler job to trigger the Vertex AI Spark ML model training pipeline via the Cloud Function we created in the prior module. The approximate time for the module content review is 15 minutes but the pipeline execution could take an hour.

<hr>

## 1. Where we are in the SparK ML model lifecycle

![M8](../06-images/module-7-01.png)   
<br><br>

<hr>

## 2. The lab environment

![M8](../06-images/module-7-02.png)   
<br><br>

<hr>

## 3. The exercise

![M8](../06-images/module-7-03.png)   
<br><br>

<hr>

## 4. Review the Cloud Scheduler job configuration

A Cloud Scheduler job has been precreated for you that calls the Cloud Function which inturn calls the Vertex AI Spark ML pipeline we created in module 5. Lets walk through the setup in the author's environment.

![CS](../06-images/module-1-cloud-scheduler-01.png)   
<br><br>

![CS](../06-images/module-1-cloud-scheduler-02.png)   
<br><br>

![CS](../06-images/module-1-cloud-scheduler-03.png)   
<br><br>

![CS](../06-images/module-1-cloud-scheduler-04.png)   
<br><br>

![CS](../06-images/module-1-cloud-scheduler-05.png)   
<br><br>

<hr>

## 5. Run the Cloud Scheduler job manually to test it

![M8](../06-images/module-7-04.png)   
<br><br>

<hr>

## 6. Monitor the exeuction through completion of the pipeline execution
~ 1 hour

![M8](../06-images/module-7-05.png)   
<br><br>

![M8](../06-images/module-7-06.png)   
<br><br>

![M8](../06-images/module-7-07.png)   
<br><br>

<hr>

This concludes the lab module. Proceed to the [next module](../05-lab-guide/Module-08-Orchestrate-Batch-Scoring.md) where we will operationalize batch scoring on Cloud Composer.

<hr>

