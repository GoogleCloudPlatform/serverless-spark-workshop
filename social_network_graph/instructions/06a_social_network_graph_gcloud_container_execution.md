# Graph Database using Serverless Spark through Google Cloud Shell using Custom Container

**Goal** - Data execution in Graph Database.

Following are the lob modules:

[1. Understanding Data](06c_social_network_graph_gcloud_container_execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](06c_social_network_graph_gcloud_container_execution.md#2-solution-architecture)<br>
[3. Declaring Variables](06c_social_network_graph_gcloud_container_execution.md#3-declaring-cloud-shell-variables)<br>
[4. Top 20 Degrees in the graph](06c_social_network_graph_gcloud_container_execution.md#4-top-20-degrees-in-the-graph)<br>
[5. Breadth First Search](06c_social_network_graph_gcloud_container_execution.md#5-breadth-first-search)<br>
[6. Logging](06c_social_network_graph_gcloud_container_execution.md#6-logging)<br>

<br>

## 1. Understanding the data

The datasets used for this project contain edges files and node files.

##### 1.1. Nodes : [*-nodes](01-datasets/nodes/) <br>
The node file contains information of Ids and Label.

    Id    - Unique ID
    Label - Name of the Character


##### 1.2. Edges : [*-edges](01-datasets/edges/) <br>
The edge files contains information of

    Source - First Character ID
    Target - The other Character ID
    Type   - Type of Edge
    Weight - Weight of the Edge
    Book   - Book number of the Source Charater




<br>


## 2. Solution Architecture

<kbd>
<img src=images/architecture_diagram.png />
</kbd>

<br>
<br>

**Graph Processing**

The lab involves:
 - Load edges and Nodes to create a graph and Find the nodes with highest degree
 - Breadth-first search

<br>

## 3. Declaring cloud shell variables

#### 3.1 Set the PROJECT_ID in Cloud Shell

Open Cloud shell or navigate to [shell.cloud.google.com](https://shell.cloud.google.com)<br>
Run the below
```
gcloud config set project $PROJECT_ID

```

#### 3.2 Verify the PROJECT_ID in Cloud Shell

Next, run the following command in cloud shell to ensure that the current project is set correctly:

```
gcloud config get-value project
```

#### 3.3 Declare the variables

Based on the prereqs and checklist, declare the following variables in cloud shell by replacing with your values:


```
PROJECT_ID=$(gcloud config get-value project)       #current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
SUBNET=                                             #subnet which has private google access enabled
BQ_DATASET_NAME=                                    #BigQuery dataset where all the tables will be stored
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
BUCKET_PHS=                                         #bucket where our application logs created in the history server will be stored
HISTORY_SERVER_NAME=                                #name of the history server which will store our application logs
UMSA=serverless-spark                               #name of the user managed service account required for the PySpark job executions
CONTAINER_IMAGE=gcr.io/project-id/graphframe-image:1.0.1 #Container Image name needs to be provided
CONTAINER_IMAGE=${REGION}-docker.pkg.dev/${PROJECT_ID}/<artifical_repo>/<image_name>:1.0.1 #Example: us-central1-docker.pkg.dev/project-id/artifactrepo/artifactimage:1.0.1
UMSA=serverless-spark                               #name of the user managed service account required for the PySpark job executions
SERVICE_ACCOUNT=$UMSA@$PROJECT_ID.iam.gserviceaccount.com
NAME=                                               #Your unique identifier
LABEL=                                              #Your node to be searched
```

**Note:** 
- For all the variables except 'NAME', please ensure to use the values provided by the admin team.
- For example <your_node_to_be_searched> argument we can give 'JonSnow'.

<br>

#### 3.4 Update Cloud Shell SDK version

Run the below on cloud shell-

```
gcloud components update
```

<br>

## 4. Top 20 Degrees in the graph

The below script will load the edge and node files and construct graph to find the Top 20 Degrees

Run the below on cloud shell -
```
gcloud dataproc batches submit \
  --project $PROJECT_ID \
  --region $REGION \
  pyspark --batch ${NAME}-batch-${RANDOM} \
  gs://$BUCKET_CODE/social_network_graph/00-scripts/social_network_analysis.py \
  --container-image $CONTAINER_IMAGE \
  --subnet $SUBNET \
  --service-account $SERVICE_ACCOUNT \
  --history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
  -- $BUCKET_CODE
```
<br>

Once the dataproc serverless batch job completes, the output containing the top 20 degrees will be displayed on the console as below:

<kbd>
<img src=/images/degrees.png />
</kbd>

<br>

<br>

<br>


## 5. Breadth First Search

The below script will perform a BFS on the entire graph to find the direct neighbors of a given node:

Run the below on cloud shell -

```
gcloud dataproc batches submit \
  --project $PROJECT_ID \
  --region $REGION \
  pyspark --batch ${NAME}-batch-${RANDOM} \
  gs://$BUCKET_CODE/social_network_graph/00-scripts/social_network_bfs.py \
  --container-image $CONTAINER_IMAGE \
  --subnet $SUBNET \
  --service-account $SERVICE_ACCOUNT \
  --history-server-cluster projects/$PROJECT_ID/regions/$REGION/clusters/$HISTORY_SERVER_NAME \
  -- $PROJECT_ID $BQ_DATASET_NAME $BUCKET_CODE <your_node_to_be_searched> $NAME
```
**NOTE** - The arguments should be provided in the same order.

<br>

**Check the output table in BQ**

Navigate to BigQuery Console, and check the **social_network** dataset. <br>
Once the bfs batch is completed, a new table '<your_name_here>__bfs_result' will be created as shown below :

<kbd>
<img src=/images/bfs_bq_2.png />
</kbd>

<br>

<br>


To view the data in this table -

* Select the table from BigQuery Explorer by navigating 'project_id' **>** 'dataset' **>** 'table_name'
* Click on the **Preview** button to see the data in the table

<br>

<kbd>
<img src=images/bq_preview.png />
</kbd>

<br>

**Note:** If the **Preview** button is not visible, run the below queries to view the data. However, these queries will be charged for the full table scan.

```
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>__bfs_result` LIMIT 1000
```

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively

<kbd>
<img src=/images/bfs_bq.png />
</kbd>


<br>

<br>

<br>



## 6. Logging

### 6.1 Serverless Batch logs

Logs associated with the application can be found in the logging console under
**Dataproc > Serverless > Batches > <batch_name>**.
<br> You can also click on “View Logs” button on the Dataproc batches monitoring page to get to the logging page for the specific Spark job.

<kbd>
<img src=/images/log1.png />
</kbd>

<kbd>
<img src=/images/log2.png />
</kbd>

<br>

### 6.2 Persistent History Server logs

To view the Persistent History server logs, click the 'View History Server' button on the Dataproc batches monitoring page and the logs will be shown as below:

<br>

<kbd>
<img src=/images/ps1.png />
</kbd>

<kbd>
<img src=/images/ps2.png />
</kbd>

<br>
