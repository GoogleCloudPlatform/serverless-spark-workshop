# Lab 2: Wikipedia Page Views Analysis from the BigQuery UI powered by Dataproc Serverless Spark

This lab demonstrates how to use the BigQuery UI for running Dataproc Serverless Spark jobs for data analytics.

## 1. Prerequisite
The setup detailed in the environment provisioning instructions in go/scw-tf

## 2. Variables

Paste this into gcloud CLI in CLoud Shell after replacing with your values-
```
PROJECT_ID=YOUR_PROJECT_ID
PROJECT_NBR=YOUR_PROJECT_NBR
BQ_UI_BUCKET_NM=gs://s8s-bigspark-$PROJECT_NBR
LOCATION=us-central1
```

## 3. Storage Bucket

A storage bucket is needed, for Serverless Spark. Lets create one-
```
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION -b on $BQ_UI_BUCKET_NM
```

## 4. Needed in the UI

Just the storage bucket created above.
Note: You will run the lab as your own identity.

## 5. Wikipedia Page Views Analysis - code

```
from pyspark.sql import SparkSession
from pyspark.ml.feature import StopWordsRemover
from pyspark.sql import functions as F

spark = SparkSession.builder \
.appName('Wikipedia-Analytics')\
.getOrCreate()

# Base dataset in BQ
bqTableFQN = "bigquery-public-data.wikipedia.pageviews_2019"

# Read base dataset with filters
wikiPageviewsDF = spark.read \
.format("bigquery") \
.option("table", bqTableFQN) \
.option("filter", "datehour >= '2019-01-01' ") \
.load()

# Subset the columns
pageViewsSubsetDF = wikiPageviewsDF \
.select("title", "wiki", "views") \
.where("views > 5")

# Cache
pageViewsSubsetDF.cache()

# Filter to just english
pageViewsSubsetEnglishDF = pageViewsSubsetDF \
.where("wiki in ('en', 'en.m')")

# Aggregate by title
pageViewsSubsetEnglishByTitleDF = pageViewsSubsetEnglishDF \
.groupBy("title") \
.agg(F.sum('views').alias('total_views'))

# Order by and print
pageViewsSubsetEnglishByTitleDF.orderBy('total_views', ascending=False).show(20) 
```

## 6. Lets get started

### 6.1. Navigate to the BQ UI from Cloud Console

![bq-1](../images/00-bq-01.png) 
<br>

### 6.2. Click on create

![bq-2](../images/00-bq-02.png)  
<br>

### 6.3. Click on "Compose new PySpark"

![bq-3](../images/00-bq-03.png) 
<br>

### 6.4. Click on "More -> PySpark Options"

![bq-4](../images/00-bq-04.png) 
<br>

### 6.5. Click on "Browse and select staging folder"

![bq-5](../images/00-bq-05.png)  
<br>

### 6.6. Click on "s8s bigSpark bucket"

![bq-6](../images/00-bq-06.png)  
<br>

![bq-7](../images/00-bq-07.png)  
<br>

### 6.7. Select your network and subnet

![bq-8](../images/00-bq-08.png)
<br>

### 6.8. Click "Save"
![bq-9](../images/00-bq-09.png)  
<br>

### 6.9. Paste the code snippet above, into the UI text area and click "Run"
![bq-10](../images/00-bq-10.png)
<br>

### 6.10. Switch to Dataproc UI "Batches" view

You should see a new batch job-

![bq-11](../images/00-bq-11.png) 
<br>

### 6.11. Switch back to the BQ UI to view the results

![bq-12](../images/00-bq-12.png)
<br>
<br>
![bq-13](../images/00-bq-13.png)  

### 6.12. Switch to Dataproc UI "Batches" view to look at the monitoring tile
You should see the autoscale kick in after 2 minutes
<br>
![bq-13](../images/00-bq-14.png)  
<br>


##### =====================================================================================================
##### THIS CONCLUDES THIS LAB 
##### PROGRESS TO NEXT LAB, OR SHUT DOWN RESOURCES
##### =====================================================================================================

