- Jdk 1.8
- Hadoop 2.7.0
- Hive 1.2.1
- Hbase 1.1.2 (With Zookeeper)
- Spark 2.3.1
- Kafka 1.1.1
- MySQL 5.7.32


```
docker run -d \
-m 8G \
-p 7070:7070 \
-p 8088:8088 \
-p 50070:50070 \
-p 8032:8032 \
-p 8042:8042 \
-p 16010:16010 \
--name apache-kylin \
abulo/docker-kylin
```