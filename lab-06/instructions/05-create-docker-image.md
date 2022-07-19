# About

This module includes all the steps for creating a custom container image and pushing the image to container registry-
<br>

[1. Create Container Image](05-create-docker-image.md#1-create-container-image)<br>

## 1. Create Container Image 

#### 1. Create Dockerfile through vi command

Run the below command in cloud shell.

```
vi Dockerfile #Dockerfile to be created

```

<br>

#### 2. Copy the contents of dockerfile

Copy the contents of  timeseries_forecasting/02-dependencies/Dockerfile.txt and press Escape.


In Cloud Shell, use the below command to save the contents of the docker file:

```
:wq!
```
<br>

#### 3. Declare Image Name


In Cloud Shell, use the below command to save the code:

```
CONTAINER_IMAGE=gcr.io/<<my-project>>/<<my-image>>:1.0.1
```

Note :Change the variables my-project,my-image with your project name and image name.
<br>
<br>

#### 4. Download the Miniconda Environment


In Cloud Shell, use the below command to download the MiniConda:

```
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
```
<br>

#### 5. Copy the Bigquery Jar

Run the below command in cloud shell.

```
gsutil cp \
  gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar .

```

<br>

#### 6. Build and Push the image to GCR

In Cloud Shell, use the below command to Push and Pull:

```
docker build -t "${CONTAINER_IMAGE}" .
docker push "${CONTAINER_IMAGE}"

```

The docker container will be built and pushed to Google Container Registry.

<kbd>
<img src=../images/di_2.png />
</kbd>

<br>
