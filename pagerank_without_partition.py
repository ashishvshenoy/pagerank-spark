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
    if len(sys.argv) != 3:
        print("Usage: pagerank <file> <output_file>")
        exit(-1)


    spark = SparkSession\
        .builder\
        .appName("CS-838-Assignment2-PartA-1")\
	.config('spark.driver.memory',"1g")\
	.config("spark.eventLog.enabled","true")\
	.config("spark.eventLog.dir","hdfs://10.254.0.33:8020/user/ubuntu/applicationHistory")\
	.config("spark.executor.memory","1g")\
	.config("spark.executor.cores","4")\
	.config("spark.task.cpus","1")\
	.config("spark.executor.instances","4")\
	.master("spark://10.254.0.33:7077")\
        .getOrCreate()


    lines = spark.read.text(sys.argv[1]).rdd.map(lambda r: r[0])

    links = lines.map(lambda urls: parseNeighbors(urls)).distinct().groupByKey()

    ranks = links.map(lambda url_neighbors: (url_neighbors[0], 1.0))
    for iteration in range(10):
        contribs = links.join(ranks).flatMap(
            lambda url_urls_rank: computeContribs(url_urls_rank[1][0], url_urls_rank[1][1]))

        ranks = contribs.reduceByKey(add).mapValues(lambda rank: rank * 0.85 + 0.15)

    ranks.saveAsTextFile('/user/ubuntu/'+str(sys.argv[2]))
    spark.stop()
