FROM ubuntu:18.04
# 维护者信息
LABEL maintainer="Abulo Hoo"
LABEL maintainer-email="abulo.hoo@gmail.com"



USER root

WORKDIR /home/admin

# 设置源
# RUN  sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list

#安装 mysql 



#数据分析模块环境变量
ENV JAVA_HOME=/home/admin/jdk 
ENV JAVA_BIN=/home/admin/jdk/bin
ENV JAVA_LIB=/home/admin/jdk/lib
ENV CLASSPATH=$CLASSPATH:/home/admin/jdk/lib/tools.jar:/home/admin/jdk/lib/dt.jar
ENV HADOOP_HOME=/home/admin/hadoop
ENV MAVEN_HOME=/home/admin/maven
ENV HIVE_HOME=/home/admin/hive
ENV ZK_HOME=/home/admin/zookeeper
ENV HBASE_HOME=/home/admin/hbase
ENV SCALA_HOME=/home/admin/scala
ENV SPARK_HOME=/home/admin/spark
ENV KAFKA_HOME=/home/admin/kafka
ENV HADOOP_HDFS_HOME=/home/admin/hadoop
ENV HADOOP_MAPRED_HOME=/home/admin/hadoop
ENV HADOOP_COMMON_HOME=/home/admin/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR=/home/admin/hadoop/lib/native
ENV KYLIN_HOME=/home/admin/kylin
ENV PATH=$PATH:/home/admin/jdk/bin:/home/admin/scala/bin:/home/admin/spark/bin:/home/admin/kafka/bin:/home/admin/spark/sbin:/home/admin/hadoop/bin:/home/admin/hadoop/sbin:/home/admin/maven/bin:/home/admin/hive/bin:/home/admin/zookeeper/bin:/home/admin/hbase/bin:/home/admin/scala/bin:/home/admin/spark/bin:/home/admin/kafka/bin:/home/admin/kylin/bin
ENV # LC_ALL=en_us.UTF-8
ENV LC_CTYPE=en_us
ENV LANG=en_us.UTF-8
#安装 
RUN cd /home/admin && \
    groupadd -r mysql && \
    useradd -r -g mysql mysql && \
    apt-get update && \
    apt-get install -y --no-install-recommends  curl net-tools  ca-certificates wget git mysql-server mysql-client && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
	chmod 1777 /var/run/mysqld /var/lib/mysql && \
    mkdir /docker-entrypoint-initdb.d && \
	cd /home/admin && \
	git config --global http.sslVerify false && \
    git clone https://github.com/abulo/docker-kylin.git && \
	# 安装 jdk 
	wget -c -nv --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u271-b09/61ae65e088624f5aaa0b1d2d801acb16/jdk-8u271-linux-x64.tar.gz" && \
    tar -zxf jdk-8u141-linux-x64.tar.gz && \
    rm -rf jdk-8u141-linux-x64.tar.gz && \
	mv jdk1.8.0_271 jdk && \

	#安装 hadoop
	wget -c -nv --no-check-certificate https://archive.apache.org/dist/hadoop/core/hadoop-3.0.3/hadoop-3.0.3.tar.gz && \
	tar zxf hadoop-3.0.3.tar.gz && \
	rm -rf hadoop-3.0.3.tar.gz && \
	mv hadoop-3.0.3 hadoop && \
	#配置文件
	cp -rf /home/admin/docker-kylin/conf/hadoop/hadoop/core-site.xml /home/admin/hadoop/etc/hadoop/core-site.xml && \
    cp -rf /home/admin/docker-kylin/conf/hadoop/hadoop/hdfs-site.xml /home/admin/hadoop/etc/hadoop/hdfs-site.xml && \
    cp -rf /home/admin/docker-kylin/conf/hadoop/yarn/mapred-site.xml /home/admin/hadoop/etc/hadoop/mapred-site.xml && \
    cp -rf /home/admin/docker-kylin/conf/hadoop/yarn/yarn-site.xml /home/admin/hadoop/etc/hadoop/yarn-site.xml && \
	# 安装 maven
	wget -c -nv --no-check-certificate https://archive.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz && \
    tar -zxf apache-maven-3.6.1-bin.tar.gz && \
    rm -rf apache-maven-3.6.1-bin.tar.gz && \
	mv apache-maven-3.6.1-bin maven && \
	# 安装 hbase 
	wget -c -nv --no-check-certificate  https://archive.apache.org/dist/hbase/2.2.4/hbase-2.2.4-bin.tar.gz && \
	tar -zxf hbase-2.2.4-bin.tar.gz && \
    rm -rf hbase-2.2.4-bin.tar.gz && \
	mv hbase-2.2.4-bin hbase && \
	# 配置文件
	cp -rf /home/admin/docker-kylin/conf/hbase/hbase-site.xml /home/admin/hbase/conf/hbase-site.xml && \
    cp -rf /home/admin/docker-kylin/conf/hbase/hbase /home/admin/hbase/bin/hbase && \
	#安装 hive 
	wget -c -nv --no-check-certificate  https://archive.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz && \
	tar -zxf apache-hive-3.1.2-bin.tar.gz && \
    rm -rf apache-hive-3.1.2-bin.tar.gz && \
	mv apache-hive-3.1.2-bin hive && \
	#配置
	cp -rf /home/admin/docker-kylin/conf/hive/hive-site.xml /home/admin/hive/conf/hive-site.xml && \
	cp -rf /home/admin/docker-kylin/conf/hive/hive-env.sh  /home/admin/hive/conf/hive-env.sh && \
	cp -rf /home/admin/docker-kylin/conf/mysql/mysql-connector-java-5.1.45-bin.jar /home/admin/hive/lib/mysql-connector-java-5.1.45-bin.jar && \
	# 安装 spark
	wget -c -nv --no-check-certificate   https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz && \
	tar -zxf spark-2.4.5-bin-without-hadoop.tgz && \
    rm -rf spark-2.4.5-bin-without-hadoop.tgz && \
	mv spark-2.4.5-bin-without-hadoop spark && \
	# 配置
	cp -rf /home/admin/docker-kylin/conf/spark/spark-env.sh /home/admin/spark/conf/spark-env.sh && \
	cp -rf /home/admin/docker-kylin/conf/spark/spark-default.conf /home/admin/spark/conf/spark-default.conf && \
	cp -rf /home/admin/docker-kylin/conf/spark/slaves /home/admin/spark/conf/slaves && \
	#安装 scala
	wget -c -nv --no-check-certificate https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.tgz && \
	tar -zxf scala-2.11.12.tgz && \
    rm -rf scala-2.11.12.tgz && \
	mv scala-2.11.12 scala && \
	#安装 Zookeeper
	wget -c -nv --no-check-certificate https://archive.apache.org/dist/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz && \
	tar -zxf zookeeper-3.4.5.tar.gz && \
    rm -rf zookeeper-3.4.5.tar.gz && \
	mv zookeeper-3.4.5 zookeeper && \
	cp -rf /home/admin/docker-kylin/conf/zk/zoo.cfg /home/admin/zookeeper/conf/zoo.cfg && \
	# 安装 kafka
	wget -c -nv --no-check-certificate  https://archive.apache.org/dist/kafka/2.4.1/kafka_2.11-2.4.1.tgz && \
	tar -zxf kafka_2.11-2.4.1.tgz && \
    rm -rf kafka_2.11-2.4.1.tgz && \
	mv kafka_2.11-2.4.1 kafka && \
	#安装 kylin 
	wget -c -nv --no-check-certificate https://archive.apache.org/dist/kylin/apache-kylin-3.0.1/apache-kylin-3.0.1-bin-hadoop3.tar.gz && \
	tar -zxf apache-kylin-3.0.1-bin-hadoop3.tar.gz && \
    rm -rf apache-kylin-3.0.1-bin-hadoop3.tar.gz && \
	mv apache-kylin-3.0.1-bin-hadoop3 kylin && \
	cp -rf /home/admin/docker-kylin/conf/kylin/kylin.properties /home/admin/kylin/conf/kylin.properties && \
	cp -rf /home/admin/docker-kylin/conf/mysql/mysql-connector-java-5.1.45-bin.jar /home/admin/kylin/ext/mysql-connector-java-5.1.45-bin.jar && \
	cp /home/admin/docker-kylin/conf/mysql/docker-entrypoint.sh  /home/admin/mysql.sh && \
	chmod u+x /home/admin/mysql.sh && \
	cp /home/admin/docker-kylin/conf/start.sh  /home/admin/start.sh && \
	chmod u+x /home/admin/start.sh && \
	rm -rf /home/admin/docker-kylin && \
	apt-get clean 

VOLUME /var/lib/mysql
ENTRYPOINT ["/home/admin/start.sh"]