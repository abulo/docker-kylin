#!/bin/bash


# 2��start hdfs, yarn and so on
# modify start dfs by root
sed -i '1 a HDFS_SECONDARYNAMENODE_USER=root' /home/admin/hadoop/sbin/start-dfs.sh
sed -i '1 a HDFS_NAMENODE_USER=root' /home/admin/hadoop/sbin/start-dfs.sh
sed -i '1 a HADOOP_SECURE_DN_USER=root' /home/admin/hadoop/sbin/start-dfs.sh
sed -i '1 a HDFS_DATANODE_USER=root' /home/admin/hadoop/sbin/start-dfs.sh
# modify stop dfs by root
sed -i '1 a HDFS_SECONDARYNAMENODE_USER=root' /home/admin/hadoop/sbin/stop-dfs.sh
sed -i '1 a HDFS_NAMENODE_USER=root' /home/admin/hadoop/sbin/stop-dfs.sh
sed -i '1 a HADOOP_SECURE_DN_USER=root' /home/admin/hadoop/sbin/stop-dfs.sh
sed -i '1 a HDFS_DATANODE_USER=root' /home/admin/hadoop/sbin/stop-dfs.sh

# format
hdfs namenode -format

# modify start yarn by root
sed -i '1 a YARN_NODEMANAGER_USER=root' /home/admin/hadoop/sbin/start-yarn.sh
sed -i '1 a HADOOP_SECURE_DN_USER=yarn' /home/admin/hadoop/sbin/start-yarn.sh
sed -i '1 a YARN_RESOURCEMANAGER_USER=root' /home/admin/hadoop/sbin/start-yarn.sh
# modify stop yarn by root
sed -i '1 a YARN_NODEMANAGER_USER=root' /home/admin/hadoop/sbin/stop-yarn.sh
sed -i '1 a HADOOP_SECURE_DN_USER=yarn' /home/admin/hadoop/sbin/stop-yarn.sh
sed -i '1 a YARN_RESOURCEMANAGER_USER=root' /home/admin/hadoop/sbin/stop-yarn.sh

# start dfs, yarn and historyserver
/home/admin/hadoop/sbin/start-dfs.sh
/home/admin/hadoop/sbin/start-yarn.sh
/home/admin/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver


# 3��start hive
# config
hdfs dfs -mkdir /tmp
hdfs dfs -mkdir /hbase
hdfs dfs -mkdir /historyserverforSpark
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+x /tmp
hdfs dfs -chmod g+x /hbase
hdfs dfs -chmod g+x /historyserverforSpark
hdfs dfs -chmod g+x /user/hive/warehouse

# init metastore
schematool -initSchema -dbType mysql

# 4��Hbase
sed -i '28 a export JAVA_HOME=/usr/local/share/jdk1.8.0_181' /usr/local/share/hbase-2.2.4/conf/hbase-env.sh
start-hbase.sh

# 5��start zk
zkServer.sh start

# 6��start kafka
kafka-server-start.sh /home/admin/kafka/config/server.properties &

# 7��start spark
bash /home/admin/spark/sbin/start-all.sh
mkdir /tmp/spark-events
bash /home/admin/spark/sbin/start-history-server.sh


# 8��start kylin
# sample.sh
# nohup sample-streaming.sh &
kylin.sh start

bash
