# Ozone Analytics
This project hosts Ozone Analytics suite.

It provides multiple services to cover different infrastructure needs:

- Running streaming and flatening data pipelines services only (without Superset)
- Running streaming, flatening pipelines and data visualization services (with Superset)
- Running a Drill-backed analytics server with MinIO service
- Running the Parquet export Flink job

---
The flatening pipelines themselves are composed of two Flink Jobs.

The first job is for handling the streaming data pipelines which uses Kafka and Kafka Connect to stream OpenMRS data in a MySQL database into flatten tables in PostgreSQL.

The second Flink job is used for exporting flattened data generated by the streaming job into Parquet files for the purpose of moving the data into a centralised warehouse.

The project also includes MinIO for centralised Parquet files storage with Drill to query the data directly for MinIO.

The services have been split into multiple files this allows you to start only the services you need for example you could only be interested in starting the streaming data pipelines and not Superset or you may want to run  MinIO/Drill on separate server and just upload  parquet exported from remote data pipelines.

## Architecture

### Streaming analytics pipelines

![Streaming](readme/Streaming.jpg)

### Centralized analytics
![Centralized](readme/Centralized.jpg)

### To run

`git clone https://github.com/ozone-his/ozone-analytics`

`cd ozone-analytics/docker `

### Streaming and flatening pipelines only (without Superset)

In cases where you don't need to start Superset (for example when you will use the Parquet export job to create Parquet files to later upload onto Minio or S3, or if you want to plug your own BI tool) you can start only the streaming and flatening data pipelines by running:

`docker compose -f docker-compose-db.yaml -f docker-compose-data-pipelines.yaml up -d --build`

Which will start ;

* [ZooKeeper](https://zookeeper.apache.org/ "ZooKeeper") - Used by Flink for High Availability ensuring we can always recover when a job fails or is stopped. Without this, Flink job will restart the streaming every time it is stopped and restarted.
* [Kafka Connect](https://docs.confluent.io/platform/current/connect/ "Kafka Connect")  - Kafka Connect is a tool for scalably and reliably streaming data between Apache Kafka and other systems. In the context of this project Kafka Connect is used as means of deploying [Debezium](https://debezium.io/documentation/reference/stable/architecture.html "Debezium").
* [Kafka](https://kafka.apache.org/ "Kafka") - Used for storing streamed events from MySQL.
* [Kowl](https://github.com/redpanda-data/kowl "Kowl") - Provides and UI for managing Kafka.
* [Flink Job Manager](https://nightlies.apache.org/flink/flink-docs-master/docs/internals/job_scheduling/ "Flink Job Manager") - Coordinates the Flink cluster.
* [Flink Task Manager](https://nightlies.apache.org/flink/flink-docs-master/docs/internals/task_lifecycle/ "Flink Task Manager") - Runs the actual workloads assigned by the Job manager.
* [MySQL](https://www.mysql.com/ "MySQL") - MySQL instance filled with OpenMRS demo data, used for demo purposes with this project.
* [PostgresSQL](https://www.postgresql.org/ "PostgresSQL") - The sink database where the streaming pipelines output the flattened data. Once the data is flattened, it can be used directly for analytics by Superset or exported to Parquet for external storage or using any other anaytics tool (Tableau, Power BI, Metabase...).

###  Streaming, flatening pipelines and data visualization (with Superset)

To start the complete streaming and flatening suite, including Superset as the BI tool, run:

`docker compose -f docker-compose-db.yaml -f docker-compose-data-pipelines.yaml -f docker-compose-superset.yaml up -d --build`

This will start the following services:

* [Redis](https://redis.io/ "Redis") - Used as a backgroud task queue for Superset.
* [Superset](https://superset.apache.org/ "Superset") - Data exploration and data visualization tool.
* [Superset Worker](https://superset.apache.org/docs/intro "Superset Worker") - Run Superset background tasks.


> NOTE: The streaming jobs may fail for a while during the initial start up as Flink discovers data partitions from Kafka. You can wait for this to sort itself out or you can try to restart the `jobmanager` and `taskmanager` services with `docker compose -f docker-compose-data-pipelines.yaml restart jobmanager taskmanager`

### Drill-backed analytics server

In cases where you have multiple instances of Ozone deployed in remote locations, you may what to process data onsite with the streaming and flatening pipelines but ship the data to a central repository for analytics. This provides a solution that uses:
* [Minio](https://min.io/ "Minio") - An S3 compatible object storage server.
* [Drill](https://drill.apache.org/ "Drill") - A Schema-free SQL Query Engine for Hadoop, NoSQL and Cloud Storage.
* [Superset](https://superset.apache.org/ "Superset") - Data exploration and data visualization tool.
* [Superset Worker](https://superset.apache.org/docs/intro "Superset Worker") - Run Superset background tasks.

To start this stack run;

`docker compose -f docker-compose-db.yaml -f docker-compose-superset.yaml -f docker-compose-minio.yaml -f docker-compose-drill.yaml up -d --build`

### Parquet Export Job
For cases where you are running remote streaming and flatening data pipelines onsite with no network access (off-the-grid servers) and thus need to ship it to a the central repository (see **Drill-backed analytics server above**), you can run the export job to move data inside of a `./parquet`  folder of this project. This folder can then be uploaded  to the `openmrs-data` bucket on the MinIO server.

`docker compose -f docker-compose-db.yaml -f docker-compose-data-pipelines.yaml -f docker-compose-export.yaml up parquet-export  --build`

### Usage with external databases

When using this project in production the openmrs database and the analytics will be external to the project meaning you will need to override some environmental variables at runtime.
| Variable|Description |
|---|----|
|CONNECT_MYSQL_HOSTNAME|The project uses Kafka connect to get the OpenMRS changes we need to set this to the source OpenMRS MYSQL host|
|CONNECT_MYSQL_PORT|This is the port the source OpenMRS MYSQL is listening on|
|CONNECT_MYSQL_USERNAME|This is the username of a user in the source  OpenMRS MYSQL with the privileges `SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION` |
|CONNECT_MYSQL_PASSWORD|This is the password of `CONNECT_MYSQL_USERNAME`|
|ANALYTICS_DB_HOST|This is the host of the analytics sink PostgresSQL database |
|ANALYTICS_DB_PORT|This is the port on which the analytics sink PostgresSQL database is listening on |
|ANALYTICS_DB_NAME|This is name of the analytics sink database|
|ANALYTICS_DB_USER|This is the username for for writing into the analytics sink database|
|ANALYTICS_DB_PASSWORD|This is the password for `ANALYTICS_DB_PASSWORD`|

example for a source and sink databases listening on the host. The example assumes a Linux host

```
export CONNECT_MYSQL_HOSTNAME=172.17.0.1 && \
export CONNECT_MYSQL_PORT=3306 && \
export CONNECT_MYSQL_USERNAME=root && \
export CONNECT_MYSQL_PASSWORD=3cY8Kve4lGey && \
export ANALYTICS_DB_HOST=172.17.0.1 && \
export ANALYTICS_DB_PORT=5432 && \
export ANALYTICS_DB_NAME=analytics && \
export ANALYTICS_DB_USER=analytics && \
export ANALYTICS_DB_PASSWORD=password
```

`docker compose -f docker-compose-db.yaml -f docker-compose-data-pipelines-external.yaml docker-compose-superset.yaml up -d --build`

### Services coordinates
| Service  |   Access| Credentials|
| ------------ | ------------ |------------ |
| Kowl  |  http://localhost:8282 | |
| Flink  |  http://localhost:8084 | |
| Superset  | http://localhost:8088  | admin/password|
| Minio   | http://localhost:9000   |minioadmin/minioadmin123|
| Drill  |  http://localhost:8047 | |


# Parquet export using an OpenMRS backup

-  Copy the OpenMRS database to `./docker/sqls/mysql`
-  cd `docker/` and run the following commands: 

Start database services
```
docker compose -f docker-compose-db.yaml up -d 
```
Batch ETL job
```
docker compose -f docker-compose-batch-etl.yaml up
```
Parquet export
```
export LOCATION_TAG=<location_id>
docker compose -f docker-compose-export.yaml up
```
- data folder should be found at `./docker/data/parquet`

# Parquet export using a production deployment

- set the variable
```
export ANALYTICS_DB_HOST=<postgres_host_ip>
export OPENMRS_DB_HOST=<mysql_host_ip>
export LOCATION_TAG=<location_id>
```
Note: if the host of the database is your localhost use `host.docker.internal`

- Start batch ETL job
```
docker compose -f docker-compose-batch-etl.yaml up
```
Parquet export
```
docker compose -f docker-compose-export.yaml up
```
- data folder should be found at `./docker/data/parquet`
