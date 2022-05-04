FROM flink:1.13.5-scala_2.11-java8
RUN  wget https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc_2.11/1.13.5/flink-connector-jdbc_2.11-1.13.5.jar -O /opt/flink/lib/flink-connector-jdbc_2.11-1.13.5.jar
RUN  wget https://repo1.maven.org/maven2/org/apache/flink/flink-parquet_2.11/1.13.5/flink-parquet_2.11-1.13.5.jar -O /opt/flink/lib/flink-parquet_2.11-1.13.5.jar
RUN  wget https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.8.3-10.0/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar -O /opt/flink/lib/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar
RUN  wget https://repo1.maven.org/maven2/org/apache/parquet/parquet-hadoop/1.12.2/parquet-hadoop-1.12.2.jar -O /opt/flink/lib/parquet-hadoop-1.12.2.jar
RUN  wget https://repo1.maven.org/maven2/org/apache/parquet/parquet-common/1.12.2/parquet-common-1.12.2.jar -O /opt/flink/lib/parquet-common-1.12.2.jar
COPY run.sh /
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]