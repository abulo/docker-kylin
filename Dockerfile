FROM ubuntu:20.04
# 维护者信息
LABEL maintainer="Abulo Hoo"
LABEL maintainer-email="abulo.hoo@gmail.com"

ENV JAVA_HOME /home/admin/jdk
ENV MVN_HOME /home/admin/maven
ENV HADOOP_HOME /home/admin/hadoop    
ENV HADOOP_CONF $HADOOP_HOME/etc/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HBASE_HOME /home/admin/hbase
ENV HIVE_HOME /home/admin/hive
ENV SPARK_HOME /home/admin/spark
ENV SPARK_CONF_DIR /home/admin/spark/conf
ENV KAFKA_HOME /home/admin/kafka
ENV KYLIN_HOME=/home/admin/kylin
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$HBASE_HOME/bin:$MVN_HOME/bin:$SPARK_HOME/bin:$KAFKA_HOME/bin

USER root
WORKDIR /home/admin

RUN cd /home/admin && \
    apt-get update && \
    apt-get install -y --no-install-recommends  curl net-tools  vim wget ca-certificates tar  git && \
    apt-get remove -f && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean all && \
    git config --global http.sslVerify false && \
    git clone https://github.com/abulo/docker-kylin.git && \
    #安装 jdk 
    cd /home/admin && \
    wget -c -nv  --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u271-b09/61ae65e088624f5aaa0b1d2d801acb16/jdk-8u271-linux-x64.tar.gz" && \
    tar -zxf jdk-8u271-linux-x64.tar.gz && \
    rm -rf jdk-8u141-linux-x64.tar.gz && \
	mv jdk1.8.0_271 jdk && \
	# 安装 maven
    cd /home/admin && \
	wget -c -nv --no-check-certificate https://archive.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz && \
    tar -zxf apache-maven-3.6.1-bin.tar.gz && \
    rm -rf  apache-maven-3.6.1-bin.tar.gz && \
	mv apache-maven-3.6.1 maven   && \
    cp -rf /home/admin/docker-kylin/conf/maven/settings.xml $MVN_HOME/conf/settings.xml && \
    #安装 hadoop
    cd /home/admin && \
	wget -c -nv --no-check-certificate https://archive.apache.org/dist/hadoop/core/hadoop-3.0.3/hadoop-3.0.3.tar.gz && \
	tar -zxf hadoop-3.0.3.tar.gz && \
	rm -rf hadoop-3.0.3.tar.gz && \
	mv hadoop-3.0.3 hadoop && \
    mkdir -p /data/hadoop && \
    cp -rf /home/admin/docker-kylin/conf/hadoop/* $HADOOP_CONF/ && \
    # 安装 hbase 
    cd /home/admin && \
	wget -c -nv --no-check-certificate  https://archive.apache.org/dist/hbase/2.2.4/hbase-2.2.4-bin.tar.gz && \
	tar -zxf hbase-2.2.4-bin.tar.gz && \
    rm -rf  hbase-2.2.4-bin.tar.gz && \
	mv hbase-2.2.4 hbase && \
    mkdir -p /data/hbase && \
    mkdir -p /data/zookeeper && \
    cp -rf /home/admin/docker-kylin/conf/hbase/hbase-site.xml $HBASE_HOME/conf && \
    #安装 hive 
    cd /home/admin && \
	wget -c -nv --no-check-certificate  https://archive.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz && \
	tar -zxf apache-hive-3.1.2-bin.tar.gz && \
    rm -rf  apache-hive-3.1.2-bin.tar.gz && \
	mv apache-hive-3.1.2-bin hive && \
    cp -rf /home/admin/docker-kylin/conf/hive/hive-site.xml $HIVE_HOME/conf && \
    cp -rf /home/admin/docker-kylin/conf/hive/mysql-connector-java-8.0.22.jar $HIVE_HOME/lib/mysql-connector-java-8.0.22.jar && \
    #安装 spark 
    cd /home/admin && \
    wget -c -nv --no-check-certificate   https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz && \
	tar -zxf spark-2.4.5-bin-without-hadoop.tgz && \
    rm -rf  spark-2.4.5-bin-without-hadoop.tgz && \
	mv spark-2.4.5-bin-without-hadoop spark && \
    cp $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf && \
    cp $SPARK_HOME/yarn/*.jar $HADOOP_HOME/share/hadoop/yarn/lib && \
    cp $HIVE_HOME/lib/mysql-connector-java-8.0.22.jar $SPARK_HOME/jars && \
    cp $HBASE_HOME/lib/hbase-protocol-2.2.4.jar $SPARK_HOME/jars && \
    cp $HIVE_HOME/hcatalog/share/hcatalog/hive-hcatalog-core-3.1.2.jar $SPARK_HOME/jars/ && \
    echo spark.sql.catalogImplementation=hive > $SPARK_HOME/conf/spark-defaults.conf && \
    # 安装 kafka
    cd /home/admin && \
	wget -c -nv --no-check-certificate  https://archive.apache.org/dist/kafka/2.4.1/kafka_2.11-2.4.1.tgz && \
	tar -zxf kafka_2.11-2.4.1.tgz && \
    rm -rf  kafka_2.11-2.4.1.tgz && \
	mv kafka_2.11-2.4.1 kafka && \
    mkdir -p /data/kafka && \
    sed -i -e 's/log.dirs=.*/log.dirs=\/data\/kafka/' $KAFKA_HOME/config/server.properties && \
    #安装 kylin 
    cd /home/admin && \
	wget -c -nv --no-check-certificate https://archive.apache.org/dist/kylin/apache-kylin-3.0.1/apache-kylin-3.0.1-bin-hadoop3.tar.gz && \
	tar -zxf apache-kylin-3.0.1-bin-hadoop3.tar.gz && \
    rm -rf  apache-kylin-3.0.1-bin-hadoop3.tar.gz && \
	mv apache-kylin-3.0.1-bin-hadoop3 kylin && \
    echo kylin.source.hive.quote-enabled=false >> $KYLIN_HOME/conf/kylin.properties && \
    echo kylin.engine.spark-conf.spark.eventLog.dir=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties  &&  \
    echo kylin.engine.spark-conf.spark.history.fs.logDirectory=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties  &&  \
    echo kylin.engine.spark-conf-mergedict.spark.executor.memory=1G >> $KYLIN_HOME/conf/kylin.properties  &&  \
    echo kylin.engine.spark-conf.spark.driver.memory=512M >> $KYLIN_HOME/conf/kylin.properties  &&  \
    echo kylin.engine.spark-conf.spark.executor.memory=1G >> $KYLIN_HOME/conf/kylin.properties  && \
    echo kylin.engine.spark-conf.spark.executor.instances=1 >> $KYLIN_HOME/conf/kylin.properties   && \
    echo kylin.engine.spark-conf.spark.executor.memoryOverhead=512M >> $KYLIN_HOME/conf/kylin.properties  &&  \
    echo kylin.source.hive.redistribute-flat-table=false >> $KYLIN_HOME/conf/kylin.properties  &&  \
    echo kylin.engine.spark-fact-distinct=true >> $KYLIN_HOME/conf/kylin.properties  &&  \
    echo kylin.engine.spark-udc-dictionary=true >> $KYLIN_HOME/conf/kylin.properties && \
    echo kylin.web.dashboard-enabled=true >> $KYLIN_HOME/conf/kylin.properties && \
    cp -rf /home/admin/docker-kylin/conf/entrypoint.sh /home/admin/entrypoint.sh && \
    chmod u+x /home/admin/entrypoint.sh && \
    rm -rf /home/admin/docker-kylin && \
    rm -rf /tmp/* && \
    rm -rf /var/log/* && \
    rm -rf /var/cache/* && \
    rm -rf /var/lib/*

    

ENTRYPOINT ["/home/admin/entrypoint.sh"]