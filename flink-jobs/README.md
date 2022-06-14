
# Ozone ETL pipelines

## Flink

  

This repository contains an ETL [Flink](hhttps://ci.apache.org/projects/flink/flink-docs-master/) [job](https://ci.apache.org/projects/flink/flink-docs-master/docs/internals/job_scheduling/#:~:text=A%20Flink%20job%20is%20first,it%20cancels%20all%20running%20tasks) for flattening [Ozone HIS](https://github.com/ozone-his) data.

## Features

  

- Provides both [batch]() and [streaming]() modes

- Currently flattens OpenMRS to output reporting friendly tables for:

- patients

- observations

- visits

- concepts

  

## Tech

- [Flink](hhttps://ci.apache.org/projects/flink/flink-docs-master/)

- [Flink CDC connectors](https://github.com/ververica/flink-cdc-connectors) - For streaming

  

## Building and Installation

  

### Prerequisites

- A running Flink [installation](https://ci.apache.org/projects/flink/flink-docs-release-1.13/docs/try-flink/local_installation/)

- A running OpenMRS installation

- A running PostgreSQL installation

- A liquibase installation

  

### Build and install

- Update the [job.properties](./job.properties) files with the details for your OpenMRS MySQL database and the analytics PostgreSQL database

- Build with `mvn clean package`

- Retrieve and apply the [Liquibase file](https://github.com/ozone-his/ozonepro-docker/tree/master/flink/liquidbase) needed to create tables on the analytics database (more on installation and usage of Liquibase see [liquibase](https://www.liquibase.org/get-started/quickstart))

- Run with `flink run -m <flink-job-manager-url> target/ozone-etl-flink-1.0-SNAPSHOT.jar`

  

### Layout

src/main/java/net/mekomsolutions/data/pipelines/batch

src/main/java/net/mekomsolutions/data/pipelines/export

src/main/java/net/mekomsolutions/data/pipelines/streaming

src/main/java/net/mekomsolutions/data/pipelines/utils

src/main/java/net/mekomsolutions/data/pipelines/shared

  

### Adding new jobs
#### Sources and Sinks
This project uses flink's [Table API & SQL](https://nightlies.apache.org/flink/flink-docs-release-1.15/docs/dev/table/overview/) ,for you to access data you need to setup [temporary](https://nightlies.apache.org/flink/flink-docs-release-1.15/docs/dev/table/sql/create/) tables both for data sources and data sinks. For most cases all the tables you will every need for writting OpenMRS data processing jobs are already added under `src/main/java/net/mekomsolutions/data/pipelines/shared/dsl` . But incase you need to add more you can add them to either `src/main/java/net/mekomsolutions/data/pipelines/shared/dsl/source` or  `src/main/java/net/mekomsolutions/data/pipelines/shared/dsl/sink`   You will then need to register them in factory class `src/main/java/net/mekomsolutions/data/pipelines/shared/dsl/TableDSLFactory.java` . See `src/main/java/net/mekomsolutions/data/pipelines/streaming/StreamingETLJob.java` for an example of how to use the factory to setup sources and sinks. 

#### Setting up jobs
Assuming you already have all the source and sink tables setup adding new jobs involves;

 - Adding your SQL files to `src/main/resources`
 - Registering the jobs in `flink-jobs/src/main/resources/jobs.json`