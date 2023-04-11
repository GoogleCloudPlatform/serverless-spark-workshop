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
bucket_name=sys.argv[1]


spark = SparkSession.builder.appName('graphframes_data').getOrCreate()

#Reading Vertex and Edges data from GCS
edges= spark.read.options(header='True', inferSchema='True', delimiter=',').csv("gs://"+bucket_name+"/social_network_graph/01-datasets/edges/*.csv")
edges=edges.withColumnRenamed("Source","src").withColumnRenamed("Target","dst")
vertices= spark.read.options(header='True', inferSchema='True', delimiter=',').csv("gs://"+bucket_name+"/social_network_graph/01-datasets/nodes/*.csv")
vertices=vertices.withColumnRenamed("Id","id")

g = GraphFrame(vertices, edges)
## Take a look at the DataFrames
g.vertices.show(20)
g.edges.show(20)
## Check the number of edges of each vertex
g.degrees.sort(g.degrees.degree.desc()).show(20)
