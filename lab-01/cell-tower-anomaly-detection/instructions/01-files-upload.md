# About

This module includes all the steps for uploading the code files and datasets for the lab to precreated GCS bucket-<br>
[1. Declare variables](01-files-upload.md#1-declare-variables)<br>
[2. Upload code files and lab data to a GCS Bucket](02-files-upload.md#3-uploading-the-repository-to-gcs-bucket)<br>



## 1. Declare variables

Go to the [cloud console](console.cloud.google.com), launch cloud shell and key in the below variables for use throughout the lab.  
Run the below in cloud shell scoped to the project you selected-

```
PROJECT_ID=YOUR_PROJECT_ID
PROJECT_NBR=YOUR_PROJECT_ID
REGION=us-central1
GCS_BUCKET=s8s_data_and_code_bucket-$PROJECT_NBR
```
<br>

## 2. Upload the Spark data engineering batch job code files and datasets for the lab to GCS bucket

To upload the code repository, please follow the below steps:
```
cd ~/s8s-spark-ce-workshop/lab-01/
gsutil cp -r cell-tower-anomaly-detection/00-scripts gs://$GCS_BUCKET
```

This concludes the module.
