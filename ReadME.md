*  目的 Kylin with Docker

*  software version
   *  [JDK](https://www.oracle.com/cn/java/technologies/javase-jdk8-downloads.html): 1.8
   *  [Hadoop](https://archive.apache.org/dist/hadoop/common/hadoop-3.0.3/hadoop-3.0.3.tar.gz): 3.0.3
   *  [Hive](https://archive.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz): 3.1.2
   *  [HBase](https://archive.apache.org/dist/hbase/2.2.4/hbase-2.2.4-bin.tar.gz): 2.2.4
   *  [Spark](https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz): 2.4.5
   *  [Scala](https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.tgz): 2.11.12
   *  [Zookeeper](https://archive.apache.org/dist/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz): 3.4.5
   *  [Kafka](https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.4.1/kafka_2.11-2.4.1.tgz): 2.4.1
   *  [Maven](https://archive.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz): 3.6.1
   *  MySQL: 5.7
   *  [kylin](https://mirrors.tuna.tsinghua.edu.cn/apache/kylin/apache-kylin-3.0.1/apache-kylin-3.0.1-bin-hadoop3.tar.gz): 3.0.1

*  start: `docker-compose up -d`
*  check after start
   *  HDFS NameNode: http://ip:50070
   *  YARN ResourceManager: http://ip:8088
   *  HBase: http://ip:16010
   *  Kylin: http://ip:7070/kylin
      *  admin/KYLIN
   *  jps
      * HistoryServer
      * DataNode
      * QuorumPeerMain
      * SecondaryNameNode
      * NodeManager
      * Master
      * ResourceManager
      * Kafka
      * NameNode
      * Worker
      * RunJar
      * HMaster
      * KafkaSampleProducer
      * JobHistoryServer

*  kylin operation
   *  auto load sample.sh & sample-streaming.sh
   *  quick start: [http://kylin.apache.org/cn/docs/tutorial/kylin_sample.html](http://kylin.apache.org/cn/docs/tutorial/kylin_sample.html)
   
