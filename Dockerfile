FROM ubuntu:18.04
# 维护者信息
LABEL maintainer="Abulo Hoo"
LABEL maintainer-email="abulo.hoo@gmail.com"

ENV HIVE_VERSION 1.2.1
ENV HADOOP_VERSION 2.7.0
ENV HBASE_VERSION 1.1.2
ENV SPARK_VERSION 2.3.1
ENV ZK_VERSION 3.4.6
ENV KAFKA_VERSION 1.1.1
ENV LIVY_VERSION 0.6.0
ENV KYLIN_VERSION 3.1.0


ENV JAVA_HOME /home/admin/jdk1.8.0_141
ENV MVN_HOME /home/admin/apache-maven-3.6.1
ENV HADOOP_HOME /home/admin/hadoop-$HADOOP_VERSION
ENV HIVE_HOME /home/admin/apache-hive-$HIVE_VERSION-bin
ENV HADOOP_CONF $HADOOP_HOME/etc/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HBASE_HOME /home/admin/hbase-$HBASE_VERSION
ENV SPARK_HOME /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6
ENV SPARK_CONF_DIR /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6/conf
ENV ZK_HOME /home/admin/zookeeper-$ZK_VERSION
ENV KAFKA_HOME /home/admin/kafka_2.11-$KAFKA_VERSION
ENV LIVY_HOME /home/admin/apache-livy-$LIVY_VERSION-incubating-bin

ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$HBASE_HOME/bin:$MVN_HOME/bin:spark-$SPARK_VERSION-bin-hadoop2.6/bin:$KAFKA_HOME/bin

ENV KYLIN_HOME /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x


USER root

WORKDIR /home/admin

# 设置源
# RUN  sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list && \
RUN	apt-get -y update && \
    apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install --no-install-recommends -y -q  net-tools wget lsof tar git mysql-server mysql-client nodejs npm unzip && \

    cd /home/admin && \
    git config --global http.sslVerify false && \
    git clone https://github.com/abulo/docker-kylin.git && \
    # install mvn
    wget https://archive.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz  && \
    tar -zxvf apache-maven-3.6.1-bin.tar.gz && \
    rm -f apache-maven-3.6.1-bin.tar.gz && \
    cp /home/admin/docker-kylin/conf/maven/settings.xml $MVN_HOME/conf/settings.xml && \

    # install jdk
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz" && \
    tar -zxvf /home/admin/jdk-8u141-linux-x64.tar.gz  && \
    rm -f /home/admin/jdk-8u141-linux-x64.tar.gz && \

    # install hadoop
    wget https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -zxvf /home/admin/hadoop-$HADOOP_VERSION.tar.gz && \
    rm -f /home/admin/hadoop-$HADOOP_VERSION.tar.gz && \
    mkdir -p /data/hadoop && \
    cp -rf /home/admin/docker-kylin/conf/hadoop/* $HADOOP_CONF/ && \

    # install hbase
    wget https://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz && \
    tar -zxvf /home/admin/hbase-$HBASE_VERSION-bin.tar.gz && \
    rm -f /home/admin/hbase-$HBASE_VERSION-bin.tar.gz && \
    mkdir -p /data/hbase && \
    mkdir -p /data/zookeeper && \
    cp /home/admin/docker-kylin/conf/hbase/hbase-site.xml $HBASE_HOME/conf && \

    # install hive
    wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
    tar -zxvf /home/admin/apache-hive-$HIVE_VERSION-bin.tar.gz && \
    rm -f /home/admin/apache-hive-$HIVE_VERSION-bin.tar.gz && \
    wget -P $HIVE_HOME/lib https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar && \
    cp /home/admin/docker-kylin/conf/hive/hive-site.xml $HIVE_HOME/conf && \

    # install spark
    wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
    tar -zxvf /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
    rm -f /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
    cp $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf && \
    cp $SPARK_HOME/yarn/*.jar $HADOOP_HOME/share/hadoop/yarn/lib && \
    cp $HIVE_HOME/lib/mysql-connector-java-5.1.49.jar $SPARK_HOME/jars && \
    cp $HBASE_HOME/lib/hbase-protocol-1.1.2.jar $SPARK_HOME/jars && \
    echo spark.sql.catalogImplementation=hive > $SPARK_HOME/conf/spark-defaults.conf && \

    # install kafka
    wget https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz && \
    tar -zxvf /home/admin/kafka_2.11-$KAFKA_VERSION.tgz && \
    rm -f /home/admin/kafka_2.11-$KAFKA_VERSION.tgz && \

    # install livy
    wget https://www.apache.org/dist/incubator/livy/$LIVY_VERSION-incubating/apache-livy-$LIVY_VERSION-incubating-bin.zip && \
    unzip /home/admin/apache-livy-$LIVY_VERSION-incubating-bin.zip && \
    rm -f /home/admin/apache-livy-$LIVY_VERSION-incubating-bin.zip && \

    # install Kylin
    wget https://archive.apache.org/dist/kylin/apache-kylin-$KYLIN_VERSION/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz && \
    tar -zxvf /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz && \
    rm -f /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz && \
    cp $HIVE_HOME/hcatalog/share/hcatalog/hive-hcatalog-core-1.2.1.jar $SPARK_HOME/jars/ && \

    echo "kylin.engine.livy-conf.livy-enabled=true" >>  $KYLIN_HOME/conf/kylin.properties \
    && echo "kylin.engine.livy-conf.livy-url=http://127.0.0.1:8998" >>  $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.livy-conf.livy-key.file=hdfs://localhost:9000/kylin/livy/kylin-job-$KYLIN_VERSION.jar >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.livy-conf.livy-arr.jars=hdfs://localhost:9000/kylin/livy/hbase-client-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-common-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop2-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-server-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/htrace-core-*-incubating.jar,hdfs://localhost:9000/kylin/livy/metrics-core-*.jar >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.source.hive.quote-enabled=false >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.eventLog.dir=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.history.fs.logDirectory=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf-mergedict.spark.executor.memory=1G >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.driver.memory=512M >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.executor.memory=1G >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.executor.instances=1 >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.executor.memoryOverhead=512M >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.source.hive.redistribute-flat-table=false >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-fact-distinct=true >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-udc-dictionary=true >> $KYLIN_HOME/conf/kylin.properties && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /home/admin/entrypoint.sh
RUN chmod u+x /home/admin/entrypoint.sh
ENTRYPOINT ["/home/admin/entrypoint.sh"]