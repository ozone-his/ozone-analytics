#!/bin/bash
#Sleep to wait for postgresql. Do this with an actual wait script
sleep 2m
/opt/liquidbase/liquibase update --changeLogFile=../../liquidbase/dbchangelog.xml --defaultsFile=../../liquidbase/liquibase.properties --url=jdbc:postgresql://$ANALYTICS_DB_HOST:5432/$ANALYTICS_DB_NAME --username=$ANALYTICS_DB_USER --password=$ANALYTICS_DB_PASSWORD
flink run -m jobmanager:8081 /opt/flink/job.jar