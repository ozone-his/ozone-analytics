#!/bin/sh
printenv > /kafka/env.properties
bash /opt/wait-for-it.sh $ANALYTICS_DB_HOST:5432
/liquibase/liquibase update --changeLogFile=./changelog/dbchangelog.xml --url=jdbc:postgresql://$ANALYTICS_DB_HOST:5432/$ANALYTICS_DB_NAME --username=$ANALYTICS_DB_USER --password=$ANALYTICS_DB_PASSWORD
bash /opt/wait-for-it.sh $CONNECT_HOST:8083
#Work around for 404 issue if ran immediately
sleep 5
bash /opt/setup-connect.sh
