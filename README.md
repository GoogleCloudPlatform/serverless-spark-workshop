# Serverless Spark CE Workshop - May 2022

This repo contains hands-on-labs that cover serverless Spark on GCP powered by Cloud Dataproc, as part of the [Serverless Spark Workshop](go/spark-ce-workshop).

### Audience
The intended audience is Google Customer Engineers but anyone with access to GCP can try the lab modules just as well.

### Prerequisites
Run the setup in Argolis per instructions in [go/scw-tf]

### Goal
(a) Just enough knowledge of serverless Spark on GCP powered by Cloud Dataproc to field customer conversations & questions, <br>(b) completed setup in Argolis for serverless Spark,<br> (c) demos and knowledge of how to run them and <br>(d) awareness of resources available for serverless Spark on GCP.

### What is covered?
| # | Modules | Focus | Feature |
| -- | :--- | :-- | :-- |
| 1 | Environment provisioning (go/scw-tf) | Environment Automation With Terraform | N/A |
| 2 | [Lab 1 - Cell Tower Anomaly Detection](lab-01/README.md) | Data Engineering | Serverless Spark Batch from CLI & with Cloud Composer orchestration|
| 3 | [Lab 2 - Wikipedia Page View Analysis](lab-02/README.md) | Data Analysis | Serverless Spark Batch from BigQuery UI |
| 4 | [Lab 3 - Chicago Crimes Analysis](lab-03/README.md) | Data Analysis | Serverless Spark Interactive from Vertex AI managed notebook|
| N | [Resources for Serverless Spark](https://spark.apache.org/docs/latest/) |

### Dont forget to 
Shut down/delete resources when done

### Credits
Some of the labs are contributed by partners, to Google Cloud, or are contributions from Googlers.<br>
Lab 1 - TekSystems
Lab 2 - TekSystems


### Contributions welcome

Community contribution to improve the labs or new labs are very much appreciated.
