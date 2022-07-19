# About

This module includes all the steps for creating a custom container.
<br>

[1. Create Container Image](04-create-docker-image.md#1-create-container-image)<br>


## 1. Create Container Image 

#### 1. Create Dockerfile through vi command

<br>
Run the below command in cloud shell.

```
vi Dockerfile #Dockerfile to be created

```

<br>


#### 2. Copy the contents of dockerfile

Copy the contents of  social_media_data_analytics/02-dependencies/Dockerfile.txt and press Escape.


In Cloud Shell, use the below command to save the contents of the docker file:

<br>

```
:wq!
```
<br>

#### 3. Declare Image Name


In Cloud Shell, use the below command to save the code:
<br>

```
CONTAINER_IMAGE=gcr.io/<<my-project>>/<<my-image>>:1.0.1
```
<br>

Note :Change the variables my-project,my-image with your project name and image name.

#### 4. Download the Miniconda Environment


In Cloud Shell, use the below command to download the MiniConda:
<br>
```
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
```
<br>

#### 5. Build and Push the image to GCR


In Cloud Shell, use the below command to build:
<br>
```
docker build -t "${CONTAINER_IMAGE}" .
```
In Cloud Shell, use the below command to push:
<br>
```
docker push "${CONTAINER_IMAGE}"

```

The docker container will be built and pushed to Google Container Registry.

<kbd>
<img src=../images/container_registry.png />
</kbd>

<br>
