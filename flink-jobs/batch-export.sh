#!/bin/sh
: ${JDBC_URL?"Need to set JDBC_URL"}
: ${JDBC_USERNAME:?"Need to set JDBC_USERNAME"}
: ${JDBC_PASSWORD:?"Need to set JDBC_PASSWORDy"}
: ${OUTPUT_DIR:?"Need to set OUTPUT_DIR"}
: ${LOCATION_TAG:?"Need to set LOCATION_TAG"}
java -jar etl-export.jar --jdbc-url $JDBC_URL --jdbc-username $JDBC_USERNAME --jdbc-password $JDBC_PASSWORD --output-dir $OUTPUT_DIR --location-tag $LOCATION_TAG