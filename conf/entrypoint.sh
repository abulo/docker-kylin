#!/bin/bash

# clean pid files
rm -f /tmp/*.pid

rm -rf /data/hadoop/*
rm -rf /data/hbase/*
rm -rf /home/admin/first_run
# start hdfs
if [ ! -f "/home/admin/first_run" ]
then
    hdfs namenode -format
fi
$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode
$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode

# start yarn
$HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

# start mr jobhistory
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver


# start hbase
rm -rf /data/zookeeper/*
$HBASE_HOME/bin/start-hbase.sh

# start kafka
rm -rf /data/kafka
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &

mkdir -p ${KYLIN_HOME}/logs

# check hive usability first, this operation will insert one version record into VERSION table
$KYLIN_HOME/bin/check-hive-usability.sh > ${KYLIN_HOME}/logs/kylin-verbose.log 2>&1
# wait for starting hbase server successfully
sleep 20s


# prepare kafka topic and data
if [ ! -f "/home/admin/first_run" ]
then
    $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 3 --topic kylin_streaming_topic
fi


touch /home/admin/first_run
# start kylin
$KYLIN_HOME/bin/kylin.sh -v start >> ${KYLIN_HOME}/logs/kylin-verbose.log 2>&1

while :
do
    sleep 1
done