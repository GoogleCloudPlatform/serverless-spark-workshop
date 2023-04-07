# About

This module includes all the steps for creating a custom container.

Optional: You can create the custom container image either through Cloud Shell or using a Virtual Machine first and run those step below in your VM. See [setup your VM](../instructions/connect_VM_with_cloud_SDK.md).

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

## 1. Copy the Bigquery Jar
<br>
Run the below command in VM.

```
gsutil cp \
  gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar .

```

## 2. Create Container Image

#### 1. Create Dockerfile through vi command

Run the below command in Cloud Shell/VM terminal.

```
vi Dockerfile #Dockerfile to be created

```

#### 2. Copy the contents of dockerfile

Copy the contents of timeseries_forecasting/02-dependencies/Dockerfile.txt and paste it here. Then, press **Escape** to leave the edit mode.

In Cloud Shell/VM terminal, use the below command to save the contents of the docker file:

```
:wq!
```

#### 3. Declare Image Name

In Cloud Shell/VM terminal, use the below command to save the code:

```
PROJECT_ID=#project_id
REGION=#region
REPOSITORY_NAME=#artifact repository
IMAGE_NAME=#container image name for artifact repository
CONTAINER_IMAGE=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_NAME}/${IMAGE_NAME}:1.0.1
```

#### 4. Download the Miniconda Environment

In Cloud Shell/VM terminal use the below command to download the MiniConda:

```
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
```


#### 6. Set up an artifacts repository for the container image to store at.

Run the below command in Cloud Shell/VM terminal.

```
gcloud artifacts repositories create $REPOSITORY_NAME --repository-format=docker \
--location=$REGION
```

#### 7. Build and Push the image to GAR


In Cloud Shell/VM terminal, use the below command to build:

```
docker build -t "${CONTAINER_IMAGE}" .
```

In Cloud Shell/VM terminal, use the below command to push:

```
docker push "${CONTAINER_IMAGE}"

```

The docker container will be built and pushed to Google Artifact Registry.

<kbd>
<img src=../images/di_2.png />
</kbd>
