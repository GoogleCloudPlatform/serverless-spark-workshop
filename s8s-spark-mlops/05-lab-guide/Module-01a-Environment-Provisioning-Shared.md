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

# About Module 1a

This module covers environment provisioning for the workshop. This module takes ~10 minutes to complete.
<br><br>
## Note:
1. **Ensure services in use in the workshop are available in the location of your preference** and modify the variables in step 2.4.1 to reflect the same.
2. Get any preview services **allow-listed**
4. Be sure to check out section 5 for glitches/nuances and workarounds.

## 1. Details about the environment that is setup by this module

![PICT1](../06-images/module-1-pictorial-01.png)
<br><br>

![PICT2](../06-images/module-1-pictorial-02.png)
<br><br>

![PICT3](../06-images/module-1-pictorial-03.png)
<br><br>

## Pictorial walkthrough of services provisioned & customization
The author's environment is showcased [here](../05-lab-guide/Services-Created.md)

<hr>

## 2. Create the environment

### 2.1. Create a directory in Cloud Shell for the workshop
```
cd ~
mkdir gcp-spark-mllib-workshop
```

### 2.2. Clone the workshop git repo
```
cd ~/gcp-spark-mllib-workshop
git clone https://github.com/GoogleCloudPlatform/serverless-spark-workshop
cd serverless-spark-workshop/
mv s8s-spark-mlops/ ~/gcp-spark-mllib-workshop/
```

### 2.3. Navigate to the Cloud Shell provisioning directory
```
cd ~/gcp-spark-mllib-workshop/s8s-spark-mlops/00-env-setup-shared/cloud-shell
```

### 2.4. Provision the environment

#### 2.5.1. Define variables for use
Modify the below as appropriate for your deployment.<br>
For Cloud Scheduler timezone, use the Cloud Scheduler UI and see available options for you.<br>

## 3. Running the Shell Script

#### 1. Customizing the shell script

From the '00-env-setup-shared/cloud-shell' folder, edit the 'cloud-shell-resource-creation-shared.sh' script by updating the values for the following variables:<br>

```
USER_ID=<your-username-in-all-lowercase-here-with-no-spaces-hyphens-underscores-numbers-or-special-characters>
LOCATION=<your-gcp-region-where-all-resources-will-be-created>
COMPOSER_BUCKET=<your-composer-bucket-name-provided-by-admin>
CLOUD_SCHEDULER_TIMEZONE=<your-cloud-scheduler-timezone>
UMSA=<your-umsa-name-provided-by-admin-here>
ZONE=<your-gcp-zone-here>
VPC_NM=<your-vpc-subnet-name-provided-by-admin>
SUBNET_NM=<your-subnet-name-provided-by-admin>
```

Once these values have been entered, please save the file.

#### 2. Shell Script Execution

Next, run the following commands in cloud shell to execute the shell script: <br>

```
bash cloud-shell-resource-creation-shared.sh
```

Once the shell script completes execution successfully, all resources mentioned in the script will be successfully created.

<hr>
