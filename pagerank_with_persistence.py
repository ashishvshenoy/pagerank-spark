import re
import sys
from operator import add

from pyspark.sql import SparkSession


def computeContribs(urls, rank):
    num_urls = len(urls)
    for url in urls:
        yield (url, rank / num_urls)


def toLines(data):
  return '\n'.join(str(d) for d in data)

def parseNeighbors(urls):
    parts = re.split(r'\s+', urls)
    return parts[0], parts[1]


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: pagerank <file> <output_file> <partitions>")
        exit(-1)

    spark = SparkSession\
        .builder\
        .appName(sys.argv[4])\
	.config("spark.driver.memory","1g")\
	.config("spark.eventLog.enabled","true")\
	.config("spark.eventLog.dir","hdfs://10.254.0.33:8020/user/ubuntu/applicationHistory")\
	.config("spark.executor.memory","2g")\
	.config("spark.executor.cores","4")\
	.config("spark.task.cpus","1")\
	.config("spark.executor.instances","4")\
	.config("spark.default.parallelism","16")\
	.master("spark://10.254.0.33:7077")\
        .getOrCreate()

    partitions = int(sys.argv[3])
    #lines = spark.read.text(sys.argv[1]).rdd.map(lambda ir: r[0])
    lines = spark.sparkContext.textFile(sys.argv[1],partitions)

    links = lines.map(lambda urls: parseNeighbors(urls)).distinct().groupByKey().partitionBy(partitions).cache()

    ranks = links.mapValues(lambda url_neighbors: 1.0)
    ranks = ranks.partitionBy(partitions)

    for iteration in range(10):
        contribs = links.join(ranks).flatMap(
            lambda url_urls_rank: computeContribs(url_urls_rank[1][0], url_urls_rank[1][1]))
        ranks = contribs.reduceByKey(add).mapValues(lambda rank: rank * 0.85 + 0.15).partitionBy(partitions).cache()

    ranks.saveAsTextFile('/user/ubuntu/'+str(sys.argv[2]))
    spark.stop()
