'''
Copyright 2023 Google LLC.
SPDX-License-Identifier: Apache-2.0
'''

from pyspark import *
from graphframes import *
from pyspark.sql import SparkSession
import sys
import pyspark.sql.functions as f

#Reading the arguments and storing them in variables
project_name=sys.argv[1]
dataset_name=sys.argv[2]
bucket_name=sys.argv[3]
label=sys.argv[4]
user_name=sys.argv[5]

#Building the Spark Session'

spark = SparkSession.builder.appName('graphframes_data').getOrCreate()

#Reading Vertex and Edges data from GCS
edges= spark.read.options(header='True', inferSchema='True', delimiter=',').csv("gs://"+bucket_name+"/social_network_graph/01-datasets/edges/*.csv")
edges=edges.withColumnRenamed("Source","src").withColumnRenamed("Target","dst")

vertices= spark.read.options(header='True', inferSchema='True', delimiter=',').csv("gs://"+bucket_name+"/social_network_graph/01-datasets/nodes/*.csv")
vertices=vertices.withColumnRenamed("Id","id")

g = GraphFrame(vertices, edges)

from_expr="id = '"+label+"'"
to_expr="id <> '"+label+"'"

#Performing Breadth-First Search on Graph
paths = g.bfs(from_expr,to_expr,maxPathLength=1)
paths=paths.select("from.Label","to.id","e0.book").dropDuplicates()
paths=paths.sort("book")
paths=paths.withColumnRenamed("Label","Source_Node").withColumnRenamed("id","Target_Node").withColumnRenamed("book","Book")
paths.show()

#Write BFS output to BigQuery
spark.conf.set("temporaryGcsBucket",bucket_name)
paths.write.format('bigquery') \
.mode("overwrite")\
.option('table', project_name+':'+dataset_name+'.'+user_name+'_bfs_result') \
.save()
