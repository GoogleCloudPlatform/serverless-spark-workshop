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
