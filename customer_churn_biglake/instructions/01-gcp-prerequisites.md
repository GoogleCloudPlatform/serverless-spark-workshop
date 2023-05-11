# About

This module includes all prerequisites for running the Serverless Spark lab-<br>
[1. Declare variables](01-gcp-prerequisites.md#1-declare-variables)<br>
[2. Enable Google Dataproc and Composer API](01-gcp-prerequisites.md#2-enable-google-dataproc-and-composer-apis)<br>
[3. Network Configuration](01-gcp-prerequisites.md#3-network-configuration)<br>
[4. Create a User Managed Service Account](01-gcp-prerequisites.md#4-create-a-user-managed-service-account)<br>
[5. Grant IAM permissions for UMSA](01-gcp-prerequisites.md#5-grant-iam-permissions-for-umsa)<br>

## 0. Prerequisites

#### 1. Create a project new project or select an existing project.
Note the project number and project ID. <br>
We will need this for the rest fo the lab

#### 2. IAM Roles needed to execute the prereqs
Grant yourself **Security Admin** role. <br>
This is needed for the networking setup and UMSA

#### 3. Attach cloud shell to your project.
Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com). <br>
Run the below command to set the project to cloud shell terminal:

```
gcloud config set project <enter your project id here>

```

<br>

## 1. Declare variables

We will use these throughout the lab. <br>
Run the below in cloud shell coped to the project you selected-

```
PROJECT_ID= #Project ID
REGION= #Region to be used

#User Managed Service Account
UMSA="serverless-spark"

# Note: Lowercase letters, numbers, hyphens allowed. All network names must be unique within the project
VPC=
SUBNET=
FIREWALL=

```

<br>

## 2. Enable Google Dataproc and Composer APIs

From cloud shell, run the below-
```
gcloud services enable dataproc.googleapis.com
gcloud services enable composer.googleapis.com

```

<br>

## 3. Network Configuration

Run the commands below to create the networking entities required for the hands on lab.

#### 3.1. Create a VPC
```
gcloud compute networks create $VPC \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --mtu=1500
```

b) List VPCs with:
```
gcloud compute networks list
```

c) Describe your network with:
```
gcloud compute networks describe $VPC
```

#### 3.2. Create a subnet for Serverless Spark with private google access

```
gcloud compute networks subnets create $SUBNET \
     --network=$VPC \
     --range=10.0.0.0/24 \
     --region=$REGION \
     --enable-private-ip-google-access
```

#### 3.3. Create firewall rules
Intra-VPC, allow all communication

```
gcloud compute firewall-rules create $FIREWALL \
 --project=$PROJECT_ID  \
 --network=projects/$PROJECT_ID/global/networks/$VPC \
 --description="Allows connection from any source to any instance on the network using custom protocols." \
 --direction=INGRESS \
 --priority=65534 \
 --source-ranges=10.0.0.0/9 \
 --action=ALLOW --rules=all
```

<br>

## 4. Create a User Managed Service Account

```
gcloud iam service-accounts create $UMSA \
 --description="User Managed Service Account for Serverless Spark" \
 --display-name "Serverless Spark SA"

```

<br>

## 5. Grant IAM Permissions for UMSA

#### 5.1.a. Basic role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/viewer

```

#### 5.1.b. Storage Admin role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/storage.admin

```

#### 5.1.c. Dataproc Editor role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/dataproc.editor

```

#### 5.1.d. Dataproc Worker role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/dataproc.worker

```

#### 5.1.e. BigQuery Data Editor role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataEditor

```

#### 5.1.f. BigQuery User role for UMSA

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$UMSA@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user

```
                                   
