# PageRank in Spark
Experiments with custom partitioning and persistence of RDDs while implementing PageRank using Spark on a Hadoop cluster

## PageRank Algorithm 

PageRank is an algorithm that is used by Google Search to rank websites in their search engine results. This algorithm iteratively updates a rank for each document by adding up contributions from documents that link to it. The algorithm can be summarized in the following steps -
Start each page at a rank of 1.
On each iteration, have page p contribute rank(p)/|neighbors(p)| to its neighbors.
Set each page's rank to 0.15 + 0.85 X contributions.

## Dataset

[Berkeley-Stanford web graph](https://snap.stanford.edu/data/web-BerkStan.html) was used in this project and the algorithm was executed for a total of 10 iterations. Each line in the dataset consists of a URL and one of it's neighbors. This file has to be copied to HDFS.

