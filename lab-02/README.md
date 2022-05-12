# About

This lab demonstrates how to use the BigQuery UI for running Dataproc Serverless Spark jobs

## Code snippet

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
