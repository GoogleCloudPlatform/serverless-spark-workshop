# Chicago Crimes Analysis with Dataproc Serverless Spark Interactive Sessions on Vertex AI Managed Notebooks

Lab contributed by: [Anagha Khanolkar](https://github.com/anagha-google)

In this lab, you will create a Vertex AI managed notebook environment, launch JupyterLab, create a Dataproc Serverless Spark Interactive Session and  authoring and run Spark code for interactive, exploratory analytics with Spark.

## 1. Prerequisite
See [this lab for an example prerequisite set up](https://github.com/GoogleCloudPlatform/serverless-spark-workshop/blob/main/covid-economic-impact-vertex-ai/instructions/01-gcp-prerequisites.md) or [these Terraform modules to provision and configure a Serverless Spark environment](https://github.com/anagha-google/ts22-just-enough-terraform-for-da).

## 2. Enable APIs

From the Cloud Console, enable the following APIs-
1. Notebook API
2. Vertex AI API

![api-1](images/03-enable-apis-01.png)  
<br>

![api-2](images/03-enable-apis-02.png)  
<br>

![api-3](images/03-enable-apis-03.png)  
<br>

![api-4](images/03-enable-apis-04.png)  
<br>

## 3. IAM permissions

### 3.1. Permissions for the User Managed Service Account
From the Cloud Console, navigate to IAM and grant the UMSA the following permissions-
1. Notebook Admin
2. Notebook Runner
3. BigQuery Admin

![iam-2](images/03-iam-02.png)  
<br>


### 3.2. Permissions for yourself
From the Cloud Console, navigate to IAM and grant yourself the following permissions-
1. Notebook Runner

![iam-1](images/03-iam-01.png)  
<br>

## 4. In Vertex AI, create a managed notebook environment

### 4.1. Navigate to Vertex AI workbench

![vai-1](images/03-vai-01.png)  
<br>

### 4.2. Click on "Managed Notebook.."

![vai-3](images/03-vai-03.png)  
<br>

### 4.3. Create a mannaged notebook environment as shown below

![vai-4](images/03-vai-04.png)  
<br>

![vai-5](images/03-vai-05.png)  
<br>

![vai-6](images/03-vai-06.png)  
<br>

### 4.4. Launch a serverless Spark interactive session as shown below and click submit

![vai-7](images/03-vai-07.png)  
<br>

![vai-8](images/03-vai-08.png)  
<br>

![vai-9](images/03-vai-09.png)  
<br>
<br>
Be sure to include the BigQuery connector jar-

```
spark.jars.packages=com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.25.2
```

<br>

![vai-10](images/03-vai-10.png)  
<br>

### 4.5. Once the session is available, a notebook opens up
![vai-11](images/03-vai-11.png)  
<br>

![vai-12](images/03-vai-12.png)  
<br>

### 4.6. Shut down the kernel of the untitled notebook, we will use a precreated notebook

![vai-13](images/03-vai-13.png)  
<br>

## 5. Clone this git repo

```
cd ~
rm -rf serverless-spark-workshop
git clone https://googlecloudplatform/serverless-spark-workshop.git
```

## 6. Download the Chicago Crimes Analytics notebook from the Cloud Shell

Click on the ellipsis (3 dots) and click on download, and select the location of the notebook.
<br>
```
It's here-
~/serverless-spark-workshop/chicago-crimes-analysis/
```

## 7. Upload the same into the Managed Notebook environment

![vai-18](images/03-vai-18.png)  
<br>

![vai-19](images/03-vai-19.png)  
<br>

![vai-20](images/03-vai-20.png)  
<br>



## 8. Now open the Chicago Crimes Notebook

![vai-14](images/03-vai-14.png)  
<br>

## 9. Select the interactive session created in the kernel picker


![vai-15](images/03-vai-15.png)  
<br>

![vai-16](images/03-vai-16.png)  
<br>

![vai-17](images/03-vai-17.png)  
<br>

## 10. Now run your analysis on the data

![vai-21](images/03-vai-21.png)  
<br>

![vai-22](images/03-vai-22.png)  
<br>

![vai-23](images/03-vai-23.png)  
<br>

##### =====================================================================================================
##### THIS CONCLUDES THIS LAB 
##### PROGRESS TO ANOTHER LAB, OR SHUT DOWN RESOURCES
##### =====================================================================================================
