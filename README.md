# PageRank in Spark

Experiments with custom partitioning and persistence of RDDs while implementing PageRank using Spark on a Hadoop cluster

## PageRank Algorithm 

PageRank is an algorithm that is used by Google Search to rank websites in their search engine results. This algorithm iteratively updates a rank for each document by adding up contributions from documents that link to it. The algorithm can be summarized in the following steps -
* Start each page at a rank of 1.
* On each iteration, have page p contribute rank(p)/|neighbors(p)| to its neighbors.
* Set each page's rank to 0.15 + 0.85 X contributions.

## Dataset

[Berkeley-Stanford web graph](https://snap.stanford.edu/data/web-BerkStan.html) was used in this project and the algorithm was executed for a total of 10 iterations. Each line in the dataset consists of a URL and one of it's neighbors. This file has to be copied to HDFS.

## Scripts

* pagerank_without_partition.py : Spark application that implements the PageRank algorithm without any custom partitioning (RDDs are not partitioned the same way) or RDD persistence.
* pagerank_with_partition.py : Spark application that implements the PageRank algorithm with custom partitioning. The RDDs links and ranks are co-partitioned to achieve narrow dependency and high level of parallelism.
* pagerank_with_persistence.py : This is the version of pagerank_with_partition.py with persistence of the appropriate RDDs.

PS : Please modify the shell scripts and the python program to suit your environments and IP addresses.

## Environment

A 5 node cluster, each node with 20GB RAM and 4 cores was used to run this application.

## Usage 
`spark-submit --verbose pagerank_without_partition.py <input_file_path> <output_file_path>`

`spark-submit --verbose pagerank_with_partition.py <input_file_path> <output_file_path> <number_of_partitions> <application_name>`

`spark-submit --verbose pagerank_with_persistence.py <input_file_path> <output_file_path> <number_of_partitions> <application_name>`

