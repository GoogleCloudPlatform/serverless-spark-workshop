In this article we are going to discuss test case on Social media data analytics use case with vertexAI

## **Docker container image creation:**

Run the below command in cloud shell.
```
 vi Dockerfile
```

Copy the contents of  social_media_data_analytics/02-dependencies/Dockerfile.txt and press Escape.
In Cloud Shell, use the below command to save the contents of the docker file:
```
:wq!
```

Declare Image Name:
```
CONTAINER_IMAGE=gcr.io/tgs-internal-gcpgtminit-dev-01/sctest:1.0.1
```

use the below command to download the MiniConda:
```
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
```

Use the below command to Build and Push the image to GCR
```
docker build -t "${CONTAINER_IMAGE}" .
docker push "${CONTAINER_IMAGE}"

```

The docker container will be built and pushed to Google Container Registry.

<br>

<kbd>
<img src=../images/gcr_sctest.png />
</kbd>

<br>

## **Through VertexAI Managed Notebook:**

Next, fill in the following values in the session creation window as shown in the images below:
<br>

<kbd>
<img src=../images/session_creation_01.png />
</kbd>

<br>

<br>

<kbd>
<img src=../images/session_creation_02.png />
</kbd>

<br>

Once the Session is created select 'No Kernel' from the kernel dropdown list and then delete the notebook

- Next, using the browser option from JupyterLab, navigate to the Notebook file located at: 
<bucket_name> > 'social_media_data_analytics' > 00-scripts > social_media_data_analytics.ipynb
- From the kernel dropdown list, select the kernel for the session created in section 3.2

<br>

<kbd>
<img src=../images/kernel_selection.png />
</kbd>

<br>

- Pass the values to the variable bucket_name as provided by the Admin.
- Next, hit the Execute button as shown below to run the code in the notebook.

## Output 
 We can check the output in the notebook itself.
 
**Most popular trending #tags** 
 <kbd>
<img src=../images/o1.png />
</kbd>

<br>

 <kbd>
<img src=../images/o2.png />
</kbd>

<br>
<br>


**The types of tweets and their followers count**
 <kbd>
<img src=../images/o3.png />
</kbd>

<br>


**The origin of the tweets**
 <kbd>
<img src=../images/o4.png />
</kbd>

<br>
