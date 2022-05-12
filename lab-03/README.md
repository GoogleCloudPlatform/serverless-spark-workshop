# Lab 3: Chicago Crimes Analysis with Dataproc Serverless Spark Interactive Sessions on Vertex AI Managed Notebooks

In this lab, you will create a Vertex AI managed notebook environment, launch JupyterLab, create a Dataproc Serverless Spark Interactive Session and  authoring and run Spark code for interactive, exploratory analytics with Spark.

## 1. Prerequisite
The setup detailed in the environment provisioning instructions in go/scw-tf

## 2. Enable APIs

From the Cloud Console, enable the following APIs-
1. Notebook API
2. Vertex AI API

![api-1](../images/03-enable-apis-01.png)  
<br>

![api-2](../images/03-enable-apis-02.png)  
<br>

![api-3](../images/03-enable-apis-03.png)  
<br>

![api-4](../images/03-enable-apis-04.png)  
<br>

## 3. IAM permissions

### 3.1. Permissions for the User Managed Service Account
From the Cloud Console, navigate to IAM and grant the UMSA the following permissions-
1. Notebook Admin
2. Notebook Runner
3. BigQuery Admin

![iam-2](../images/03-iam-02.png)  
<br>


### 3.2. Permissions for yourself
From the Cloud Console, navigate to IAM and grant yourself the following permissions-
1. Notebook Runner

![iam-1](../images/03-iam-01.png)  
<br>

## 4. In Vertex AI, create a managed notebook environment

### 4.1. Navigate to Vertex AI workbench

![vai-1](../images/03-vai-01.png)  
<br>

### 4.2. Click on "Managed Notebook.."

![vai-3](../images/03-vai-03.png)  
<br>

### 4.3. Create a mannaged notebook environment as shown below

![vai-4](../images/03-vai-04.png)  
<br>

![vai-5](../images/03-vai-05.png)  
<br>

![vai-6](../images/03-vai-06.png)  
<br>

### 4.4. Launch a serverless Spark interactive session as shown below and click submit

![vai-7](../images/03-vai-07.png)  
<br>

![vai-8](../images/03-vai-08.png)  
<br>

![vai-9](../images/03-vai-09.png)  
<br>
<br>
Be sure to include the BigQuery connector jar-

```
spark.jars=gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar
```

<br>

![vai-10](../images/03-vai-10.png)  
<br>

### 4.5. Once the session is available, a notebook opens up
![vai-11](../images/03-vai-11.png)  
<br>

![vai-12](../images/03-vai-12.png)  
<br>

### 4.6. Shut down the kernel of the untitled notebook, we will use a precreated notebook

![vai-13](../images/03-vai-13.png)  
<br>

## 5. Clone this git repo

```
cd ~
rm -rf s8s-spark-ce-workshop
git clone https://github.com/anagha-google/s8s-spark-ce-workshop.git
```

## 6. Download the Chicago Crimes Analytics notebook from the Cloud Shell

Click on the ellipsis (3 dots) and click on download, and select the location of the notebook.
<br>
```
Its here-
~/s8s-spark-ce-workshop/lab-03/
 

## 7. Upload the same into the Managed Notebook environment


## 8. Click on "Launcher"

## 9. Launch an interactive session

## 10.Shut down the kernel of the Untitled.ipynb and close it

Ensure that it is fully shutdown

## 11. Now open the Chicago Crimes Notebook

## 12. Select the interactive session created in the kernel picker

## 13. Now run your analysis on the data

