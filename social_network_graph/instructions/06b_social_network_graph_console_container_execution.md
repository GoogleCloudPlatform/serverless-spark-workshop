# Graph Database using Serverless Spark through Google Cloud Console using Custom Container

**Goal** - Data Execution in Graph Database.

Following are the lob modules:

[1. Understanding Data](06d_social_network_graph_console_container_execution.md#1-understanding-the-data)<br>
[2. Solution Architecture](06d_social_network_graph_console_container_execution.md#2-solution-architecture)<br>
[3. Declaring Variables](06d_social_network_graph_console_container_execution.md#3-declaring-variables)<br>
[4. Top 20 Degrees in the graph](06d_social_network_graph_console_container_execution.md#4-top-20-degrees-in-the-graph)<br>
[5. Breadth First Search](06d_social_network_graph_console_container_execution.md#5-breadth-first-search)<br>
[6. Logging](06d_social_network_graph_console_container_execution.md#6-logging)<br>

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


## 3. Declaring Variables

Keep the following details handy for configuring the serverless batch jobs:

```
PROJECT_ID=                                         #current GCP project where we are building our use case
REGION=                                             #GCP region where all our resources will be created
BQ_DATASET_NAME=                                    #BigQuery dataset where all the tables will be stored
BUCKET_CODE=                                        #GCP bucket where our code, data and model files will be stored
HISTORY_SERVER_NAME=spark-phs                     #name of the history server which will store our application logs
VPC_NAME=                                          # Primary VPC containing the subnet
SUBNET=                                             #subnet which has private google access enabled
SERVICE_ACCOUNT=
CONTAINER_IMAGE=${REGION}-docker.pkg.dev/${PROJECT_ID}/<artifical_repo>/<image_name>:1.0.1 #Container Image needs to be provided
NAME=                                                #Your unique identifier
LABEL=                                               # Your node to be searched    
```
**Note:** The values for all the above parameters will be provided by the admin team.

<br>

## 4. Top 20 Degrees in the Graph

The below script will load the edge and node files and construct graph to find the Top 20 Degrees

#### 4.1. Create a new batch
Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

<kbd>
<img src=/images/image23.png />
</kbd>

### 4.2. Provide the details for the batch

Next, fill in the following values in the batch creation window as shown in the images below:

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/social_network_graph/00-scripts/social_network_analysis.py
- **Container Image** - <region>-docker.pkg.dev/<project_id>/<artifical_repo>/<image_name>:1.0.1
- **Arguments** - Argument to be provided. <br>
    * <your_code_bucket_name>

 **Note:** Press RETURN after each argument

- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled
Run PySpark Serverless Batch for Data Preparation
- **History Server Cluster** - <your_phs_cluster_name>


<kbd>
<img src=/images/a1.png />
</kbd>

<hr>

<br>

<kbd>
<img src=/images/a2.png />
</kbd>

<br>

  <kbd>
  <img src=/images/image26.png />
  </kbd>

<br>

### 4.3. Submit the Serverless batch
Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

### 4.4. Once the dataproc serverless batch job completes, the output containing the top 20 degrees will be displayed on the console as below:

<kbd>
<img src=/images/degrees.png />
</kbd>

<br>
<br>

## 5. Breadth First Search

Search all the connections of a character.

#### 5.1. Create a new batch
Navigate to Dataproc > Serverless > Batches and click on **+CREATE**

<kbd>
<img src=/images/image23.png />
</kbd>

### 5.2. Provide the details for the batch

Next, fill in the following values in the batch creation window as shown in the images below:

- **Batch ID**   - A unique identifier for your batch
- **Region**     - The region name provided by the Admin team
- **Batch Type**    - PySpark
- **Main Python File** - gs://<your_code_bucket_name>/social_network_graph/00-scripts/social_network_bfs.py
- **Container Image** - <region>-docker.pkg.dev/<project_id>/<artifical_repo>/<image_name>:1.0.1
- **Arguments** - <br>
  Five Arguments needs to be provided. <br>
    * <your_project_id>
    * <bq_dataset_name>
    * <your_code_bucket_name>
    * <your_node_to_be_searched>
    * <your_name>

 **Note:** Press RETURN after each argument
- **Note:** The arguments shoulp be provided in the same order.
- **Note:** For example the value of the <your_node_to_be_searched> can be 'Jon-Snow'.
- **Service Account** - <UMSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com
- **Network Configuration** - select the network and subnetwork with Private Google Access Enabled
Run PySpark Serverless Batch for Data Preparation
- **History Server Cluster** - <your_phs_cluster_name>




<kbd>
<img src=/images/image24_2.png />
</kbd>

<hr>

<br>

<kbd>
<img src=/images/image25_2.png />
</kbd>

<br>

  <kbd>
  <img src=/images/image26.png />
  </kbd>

<br>

### 5.3. Submit the Serverless batch
Once all the details are in, you can submit the batch. As the batch starts, you can see the execution details and logs on the console.

<br>

### 5.4. Check the output table in BQ

Navigate to BigQuery Console, and check the **social_network** dataset. <br>
Once the bfs batch is completed, a new table '<your_name_here>_bfs_result' will be created as shown below :

<kbd>
<img src=/images/bfs_bq_2.png />
</kbd>

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
  SELECT * FROM `<project_name>.<dataset_name>.<your_name_here>_bfs_result` LIMIT 1000
```

**Note:** Edit all occurrences of <project_name> and <dataset_name> to match the values of the variables PROJECT_ID, and BQ_DATASET_NAME respectively

<kbd>
<img src=/images/bfs_bq.png />
</kbd>

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
