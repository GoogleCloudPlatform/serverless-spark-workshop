# About

This module includes all the steps for uploading the code files and datasets for the lab to precreated GCS bucket-<br>
[1. Declare variables](01-files-upload.md#1-declare-variables)<br>
[2. Clone the lab git repo](01-files-upload.md#2-clone-the-git-repo-in-cloud-shell)<br>
[2. Upload code files and lab data to a GCS Bucket](01-files-upload.md#2-upload-the-lab-code--data-to-the-lab-gcs-bucket)<br>

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

## 2. Clone the git repo in cloud shell

```
cd ~
git clone git clone https://github.com/anagha-google/s8s-spark-ce-workshop.git
```

## 3. Upload the lab code & data to the lab GCS bucket

Run the commands below to load the files in cloud shell to the GCS bucket-
```
cd ~/s8s-spark-ce-workshop/lab-01/
gsutil cp -r cell-tower-anomaly-detection/00-scripts gs://$GCS_BUCKET
```

This concludes the module.
