#  Copyright 2023 Google LLC
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

library(igraph)
library(SparkR)

sparkR.session()

args = commandArgs(trailingOnly=TRUE)

bucket_name <- args[1]
label <- args[2]


schema1 <- structType(
    structField('Source', 'string'),
    structField('Target', 'string'),
    structField('Type', 'string'),
    structField('weight', 'integer'),
    structField('book', 'integer'))
bucket_edge_path <- paste("gs://",bucket_name,"/social_network_graph_r/01-datasets/edges/*.csv",sep="")
bucket_node_path <- paste("gs://",bucket_name,"/social_network_graph_r/01-datasets/nodes/*.csv",sep="")
print("CHECK EDGE AND NODE BUCKET PATH")
print(paste("edge path:", bucket_edge_path))
print(paste("node path:", bucket_node_path))
edge_sparkDF <- read.df(bucket_edge_path,
                   source = "csv", header="true", schema=schema1, delimiter=',')


schema2 <- structType(
    structField('Id', 'string'),
    structField('Label', 'string'))

node_sparkDF <- read.df(bucket_node_path,
                   source = "csv", header="true", schema=schema2, delimiter=',')

edge_sparkDF_data <- collect(edge_sparkDF)
node_sparkDF_data <- collect(node_sparkDF)


# remove duplicate rows in subjects column
unique_node_sparkDF_data_id <- unique(node_sparkDF_data$Id)

g <- graph_from_data_frame(edge_sparkDF_data, directed=TRUE, vertices=unique_node_sparkDF_data_id)

list_of_vertices <- which(V(g)$name == label)

list_of_edges <- E(g)[from(list_of_vertices) | to(list_of_vertices)]

neighborhood_subgraph <- subgraph.edges(g, list_of_edges)



print("Result for label:")
result_neighborhood_subgraph <- as_long_data_frame(neighborhood_subgraph)
result_neighborhood_subgraph

print("BFS Result")
bfs_result <- bfs(neighborhood_subgraph,root=1, order=TRUE, rank=TRUE, father=TRUE, pred=TRUE,
          succ=TRUE, dist=TRUE)
