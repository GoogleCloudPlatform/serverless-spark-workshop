# Lab 1: Cell Tower Anomaly Detection with dbt

This lab is an adaptation of Lab 1 : Cell Tower Anomaly Detection.
It includes/changes:
- Use BigLake to create GCS external tables in for parquet and CSV files formats.
- Port some of the pySpark logic to SQL
- Use dbt to orchestrate the logic for both SQL jobs and pySpark scripts accessing data in BQ
- Adds a bootstrap script to deploy required cloud infrastructure (GCS bucket, BQ datasets, Service Accounts .)
It is self-contained and fully scripted to follow along at your own pace.<br>

Lab contributed by: [TEKsystems](https://www.teksystems.com/en/about-us/partnerships/google-cloud)

## 2. Lab overview and architecure

The lab includes studying and running a series of data engineering jobs, exploring results -<br>
1. Curate Customer Master Data<br>
2. Curate Telco Customer Churn Data <br>
3. Calculate Cell Tower KPIs by Customer<br>
4. Calculate KPIs by cell tower<br>

It then covers orchestrating execution of the jobs withdbt and exploring the results/cell towers needing maintenance in BigQuery.

## 3. Lab execution
Pre-requistes : A working Google Cloud Project
1) Open a Cloud Terminal and clone the repository

```bash 
git clone https://github.com/GoogleCloudPlatform/serverless-spark-workshop.git
cd serverless-spark-workshop/cell-tower-anomaly-detection-dbt/cell-tower-anomaly-detection-dbt/
```


2) Edit the`variables.json` file with your own values:
```bash 
cd 02-config
vi variables.json  
```

For instance:
```json 
{
    "project_id": "velascoluis-dev-sandbox",
    "dataproc_cluster_name" : "spark-dataproc",
    "region": "us-central1",
    "bucket_name": "spark-dataproc-velascoluis-dev-sandbox",
    "bq_dataset_name": "spark_dataproc",
    "terraform_sa_name": "terraform-sa",
    "terraform_key_location" : "terraform-sa.json"
}
```



3) Launch the infrastructure bootstrap script:
```bash 
./setup_infra.sh variables.json  
```

This script reads the config file and :
* Checks and install binaries/packages if needed
* Enables GCP APIs
* Creates Service Account (SA) and key for deployment
* Grants roles to the SA
* Terraforms core infrastructure, including a single node dataproc cluster, a GCS bucket and a BigQuery dataset
* Stages data in GCS
* Terraforms data infrastructure, inlcuding a BQ external connection, a couple of BigLake tables
* Generates DBT config files (profile and config)

4) Launch dbt:
```bash 
cd
./run_dbt.sh
```
