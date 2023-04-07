'''
  Copyright 2023 Google LLC

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
 '''

from pyspark.sql import SparkSession
from pyspark.ml.feature import StopWordsRemover
from pyspark.sql import functions as F
spark = SparkSession.builder \
.appName('Top Shakespeare words')\
.getOrCreate()
# Read data from BigQuery
df = spark.read \
.format('bigquery') \
.load('bigquery-public-data.samples.shakespeare')

# Convert words to lowercase and filter out stop words
df = df.withColumn('lowered', F.array(F.lower(df.word)))
remover = StopWordsRemover(inputCol='lowered', outputCol='filtered')
df = remover.transform(df)
# Create (count, word) struct and take the max of that in each corpus
df.select(df.corpus, F.struct(df.word_count, df.filtered.getItem(0).alias('word')).alias('count_word')) \
.where(F.col('count_word').getItem('word').isNotNull()) \
.groupby('corpus') \
.agg({'count_word': 'max'}) \
.orderBy('corpus') \
.select(
'corpus',
F.col('max(count_word)').getItem('word').alias('word'),
F.col('max(count_word)').getItem('word_count').alias('count')) \
.show(20)
