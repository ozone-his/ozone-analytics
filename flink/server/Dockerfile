FROM flink:1.13.3-scala_2.11-java8
RUN  wget https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc_2.11/1.13.3/flink-connector-jdbc_2.11-1.13.3.jar -O /opt/flink/lib/flink-connector-jdbc_2.11-1.13.3.jar\
     && wget  https://repo1.maven.org/maven2/com/ververica/flink-sql-connector-mysql-cdc/2.1.0/flink-sql-connector-mysql-cdc-2.1.0.jar -O /opt/flink/lib/flink-sql-connector-mysql-cdc-2.1.0.jar\
     && wget  https://repo1.maven.org/maven2/com/ververica/flink-sql-connector-postgres-cdc/2.1.0/flink-sql-connector-postgres-cdc-2.1.0.jar -O /opt/flink/lib/flink-sql-connector-postgres-cdc-2.1.0.jar
