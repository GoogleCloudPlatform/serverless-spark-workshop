# About

This module includes all the steps for creating a BigQuery dataset and uploading data to BigQuery tables-
<br>


Before you start do this, you must create a Virtual Machine first and run those step below in your VM in google cloud platform. See [setup your VM](../instructions/create_vm.md).

<br>


[1. Uploading Dependencies to VM](05-create-docker-image.md#1-uploading-dependencies-to-cloud-shell)<br>
[2. Create Container Image](05-create-docker-image.md#2-create-container-image)<br>

## 0. Set up authentication for Docker (while using Cloud Shell)
You might encounter permmision issues when using docker push. We will download the standalone Docker credential helper.
```
VERSION=2.1.6
OS=linux  # or "darwin" for OSX, "windows" for Windows.
ARCH=amd64  # or "386" for 32-bit OSs

curl -fsSL "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${VERSION}/docker-credential-gcr_${OS}_${ARCH}-${VERSION}.tar.gz" \
| tar xz docker-credential-gcr \
&& chmod +x docker-credential-gcr && sudo mv docker-credential-gcr /usr/bin/
```
Configure Docker to use your Artifact Registry credentials for a specific region. (Only need to do this once)
```
REGION=#your_gcp_region
gcloud auth configure-docker ${REGION}-docker.pkg.dev
```

## 1. Uploading Dependencies to VM

#### 1. Uploading JAR files

Download the graphframes-0.8.1-spark3.0-s_2.12.jar file from the social_network_graph/02-dependencies and upload it to your VM as shown below.
<br>
We will use it throughout the lab. <br>

<kbd>
<img src=/images/di_1.png />
</kbd>

<br>

#### 2. Copy the Bigquery Jar
<br>
Run the below command in VM.

```
gsutil cp \
  gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar .

```

<br>

## 2. Create Container Image 

#### 1. Create Dockerfile through vi command

<br>
Run the below command in VM.

```
vi Dockerfile #Dockerfile to be created

```

<br>


#### 2. Copy the contents of dockerfile

Copy the contents of  social_network_graph/02-dependencies/Dockerfile.txt and press Escape.


In VM, use the below command to save the contents of the docker file:

<br>

```
:wq!
```
<br>

#### 3. Declare Image Name


In VM, use the below command to save the code:
<br>

```
PROJECT_ID=<your_project_id>
REGION=<your_gcp_region>
REPOSITORY_NAME=<your_gar_reposiotry_name>
IMAGE_NAME=<your_image_name>

CONTAINER_IMAGE=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_NAME}/${IMAGE_NAME}:1.0.1
```
<br>

Note :Change the variables my-project,my-image with your project name and image name.

#### 4. Download the Miniconda Environment


In VM, use the below command to download the MiniConda:
<br>
```
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
```
<br>

#### 5. Set up an artifacts repository for the container image to store at.

Run the below command in Cloud Shell/VM terminal.

```
gcloud artifacts repositories create $REPOSITORY_NAME --repository-format=docker \
--location=$REGION
```

#### 6. Build and Push the image to GAR


In VM, use the below command to Push and Pull:
<br>
```
docker build -t "${CONTAINER_IMAGE}" .
docker push "${CONTAINER_IMAGE}"

```

The docker container will be built and pushed to Google Artifact Registry.

<kbd>
<img src=/images/di_2.png />
</kbd>

<br>