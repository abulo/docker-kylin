FROM ubuntu:20.04
# 维护者信息
LABEL maintainer="Abulo Hoo"
LABEL maintainer-email="abulo.hoo@gmail.com"




ENV HIVE_VERSION 1.2.1
ENV HADOOP_VERSION 2.7.0
ENV HBASE_VERSION 1.1.2
ENV SPARK_VERSION 2.3.1
ENV KAFKA_VERSION 1.1.1
ENV LIVY_VERSION 0.6.0
ENV KYLIN_VERSION 3.1.1

ENV JAVA_HOME /home/admin/jdk1.8.0_141
ENV MVN_HOME /home/admin/apache-maven-3.6.1
ENV HADOOP_HOME /home/admin/hadoop-$HADOOP_VERSION
ENV HIVE_HOME /home/admin/apache-hive-$HIVE_VERSION-bin
ENV HADOOP_CONF $HADOOP_HOME/etc/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HBASE_HOME /home/admin/hbase-$HBASE_VERSION
ENV SPARK_HOME /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6
ENV SPARK_CONF_DIR /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6/conf
ENV KAFKA_HOME /home/admin/kafka_2.11-$KAFKA_VERSION
ENV LIVY_HOME /home/admin/apache-livy-$LIVY_VERSION-incubating-bin
ENV KYLIN_HOME /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$HBASE_HOME/bin:$MVN_HOME/bin:spark-$SPARK_VERSION-bin-hadoop2.6/bin:$KAFKA_HOME/bin:/usr/local/mysql/bin


USER root

WORKDIR /home/admin


# install tools
RUN	sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install --no-install-recommends -y -q  net-tools wget lsof tar git nodejs npm unzip ca-certificates vim && \
    cd /home/admin && \
    git config --global http.sslVerify false && \
    git clone https://github.com/abulo/docker-kylin.git && \
    useradd -M -s /sbin/nologin mysql && \
    mkdir -p /usr/local/mysql && \
    mkdir -p /data/mysql && \
    chown mysql.mysql -R /data/mysql && \
    chown mysql.mysql -R /usr/local/mysql && \
    wget -c -nv http://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.5/mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz && \
    tar xzf mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz && \
    mv mysql-5.5.62-linux-glibc2.12-x86_64/* /usr/local/mysql && \
    sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' /usr/local/mysql/bin/mysqld_safe  && \
    sed -i "s@/usr/local/mysql@/usr/local/mysql@g" /usr/local/mysql/bin/mysqld_safe && \
    cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld && \
    sed -i "s@^basedir=.*@basedir=/usr/local/mysql@" /etc/init.d/mysqld && \
    sed -i "s@^datadir=.*@datadir=/data/mysql@" /etc/init.d/mysqld && \
    chmod +x /etc/init.d/mysqld && \
    /usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql && \
    cp -rf /home/admin/docker-kylin/conf/mysql/my.cnf /etc/my.cnf && \
    chmod 600 /etc/my.cnf && \
    /etc/init.d/mysqld start && \
    /usr/local/mysql/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by '12345' with grant option;" && \
    /usr/local/mysql/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by '12345' with grant option;" && \
    /usr/local/mysql/bin/mysql -uroot -p123456 -e "delete from mysql.user where Password='';" && \
    /usr/local/mysql/bin/mysql -uroot -p123456 -e "delete from mysql.db where User='';" && \
    /usr/local/mysql/bin/mysql -uroot -p123456 -e "delete from mysql.proxies_priv where Host!='localhost';" && \
    /usr/local/mysql/bin/mysql -uroot -p123456 -e "drop database test;" && \
    /usr/local/mysql/bin/mysql -uroot -p123456 -e "reset master;"



# RUN cd /home/admin && \
#     # install mvn
#     wget -c -nv --no-check-certificate https://archive.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz && \
#     tar -zxf apache-maven-3.6.1-bin.tar.gz && \
#     rm -f apache-maven-3.6.1-bin.tar.gz && \
#     cp -rf /home/admin/docker-kylin/conf/maven/settings.xml $MVN_HOME/conf/settings.xml && \
#     # setup jdk
#     wget -c -nv --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz" && \
#     tar -zxf /home/admin/jdk-8u141-linux-x64.tar.gz && \
#     rm -f /home/admin/jdk-8u141-linux-x64.tar.gz && \
#     # setup hadoop
#     wget -c -nv --no-check-certificate https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
#     tar -zxf /home/admin/hadoop-$HADOOP_VERSION.tar.gz && \
#     rm -f /home/admin/hadoop-$HADOOP_VERSION.tar.gz && \
#     mkdir -p /data/hadoop && \
#     cp -rf /home/admin/docker-kylin/conf/hadoop/* $HADOOP_CONF/ && \
#     # setup hbase
#     wget -c -nv --no-check-certificate https://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz && \
#     tar -zxf /home/admin/hbase-$HBASE_VERSION-bin.tar.gz && \
#     rm -f /home/admin/hbase-$HBASE_VERSION-bin.tar.gz && \
#     mkdir -p /data/hbase && \
#     mkdir -p /data/zookeeper && \
#     cp -rf /home/admin/docker-kylin/conf/hbase/hbase-site.xml $HBASE_HOME/conf && \
#     # setup hive
#     wget -c -nv --no-check-certificate https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
#     tar -zxf /home/admin/apache-hive-$HIVE_VERSION-bin.tar.gz && \
#     rm -f /home/admin/apache-hive-$HIVE_VERSION-bin.tar.gz && \
#     wget -c -nv --no-check-certificate -P $HIVE_HOME/lib https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar && \
#     cp -rf /home/admin/docker-kylin/conf/hive/hive-site.xml $HIVE_HOME/conf && \
#     # setup spark
#     wget -c -nv --no-check-certificate https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
#     tar -zxf /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
#     rm -f /home/admin/spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
#     cp -rf $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf && \
#     cp -rf $SPARK_HOME/yarn/*.jar $HADOOP_HOME/share/hadoop/yarn/lib && \
#     cp -rf $HIVE_HOME/lib/mysql-connector-java-5.1.38.jar $SPARK_HOME/jars && \
#     cp -rf $HBASE_HOME/lib/hbase-protocol-1.1.2.jar $SPARK_HOME/jars && \
#     echo spark.sql.catalogImplementation=hive > $SPARK_HOME/conf/spark-defaults.conf && \
#     # setup kafka
#     wget -c -nv  --no-check-certificate https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz && \
#     tar -zxf /home/admin/kafka_2.11-$KAFKA_VERSION.tgz && \
#     rm -f /home/admin/kafka_2.11-$KAFKA_VERSION.tgz   && \
#     # setup livy
#     wget -c -nv  --no-check-certificate https://www.apache.org/dist/incubator/livy/$LIVY_VERSION-incubating/apache-livy-$LIVY_VERSION-incubating-bin.zip && \
#     unzip /home/admin/apache-livy-$LIVY_VERSION-incubating-bin.zip && \
#     rm -f /home/admin/apache-livy-$LIVY_VERSION-incubating-bin.zip && \
#     # Download released Kylin
#     wget -c -nv --no-check-certificate https://archive.apache.org/dist/kylin/apache-kylin-$KYLIN_VERSION/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz && \
#     tar -zxf /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz && \
#     rm -f /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz && \
#     cp -rf $HIVE_HOME/hcatalog/share/hcatalog/hive-hcatalog-core-1.2.1.jar $SPARK_HOME/jars/ && \
#     #seting
#     echo "kylin.engine.livy-conf.livy-enabled=true" >>  $KYLIN_HOME/conf/kylin.properties && \
#     echo "kylin.engine.livy-conf.livy-url=http://127.0.0.1:8998" >>  $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.livy-conf.livy-key.file=hdfs://localhost:9000/kylin/livy/kylin-job-$KYLIN_VERSION.jar >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.livy-conf.livy-arr.jars=hdfs://localhost:9000/kylin/livy/hbase-client-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-common-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop2-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-server-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/htrace-core-*-incubating.jar,hdfs://localhost:9000/kylin/livy/metrics-core-*.jar >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.source.hive.quote-enabled=false >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-conf.spark.eventLog.dir=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-conf.spark.history.fs.logDirectory=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-conf-mergedict.spark.executor.memory=1G >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-conf.spark.driver.memory=512M >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-conf.spark.executor.memory=1G >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-conf.spark.executor.instances=1 >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-conf.spark.executor.memoryOverhead=512M >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.source.hive.redistribute-flat-table=false >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-fact-distinct=true >> $KYLIN_HOME/conf/kylin.properties && \
#     echo kylin.engine.spark-udc-dictionary=true >> $KYLIN_HOME/conf/kylin.properties && \
#     cp /home/admin/docker-kylin/entrypoint.sh /home/admin/entrypoint.sh && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* && \
#     rm -rf /home/admin/docker-kylin && \
#     rm -rf /home/admin/oneinstack && \
#     chmod u+x /home/admin/entrypoint.sh
# ENTRYPOINT ["/home/admin/entrypoint.sh"]