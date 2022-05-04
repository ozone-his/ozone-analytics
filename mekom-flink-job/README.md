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
