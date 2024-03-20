#!/usr/bin/env bash
set -e

export TEXT_BLUE=`tput setaf 4`
export TEXT_RED=`tput setaf 1`
export BOLD=`tput bold`
export RESET_FORMATTING=`tput sgr0`
INFO="$TEXT_BLUE$BOLD[INFO]$RESET_FORMATTING"
ERROR="$TEXT_RED$BOLD[ERROR]$RESET_FORMATTING"
function exportEnvs () {
    echo "$INFO Exporting envs..."
    export ANALYTICS_CONFIG_FILE_PATH=$DISTRO_PATH/distro/configs/analytics/config.yaml;\
    export ANALYTICS_DB_PORT=5432;\
    export CONNECT_MYSQL_PORT=3306;\
    export CONNECT_MYSQL_USER=root;\
    export CONNECT_MYSQL_PASSWORD=3cY8Kve4lGey;\
    export CONNECT_ODOO_DB_PORT=5432;\
    export CONNECT_ODOO_DB_NAME=odoo;\
    export CONNECT_ODOO_DB_USER=odoo;\
    export CONNECT_ODOO_DB_PASSWORD=password;\
    export ODOO_DB_PORT=5432;\
    export ODOO_DB_NAME=odoo;\
    export ODOO_DB_USER=odoo;\
    export ODOO_DB_PASSWORD=password;\
    export OPENMRS_DB_PORT=3306;\
    export OPENMRS_DB_NAME=openmrs;\
    export EXPORT_DESTINATION_TABLES_PATH=$DISTRO_PATH/distro/configs/analytics/dsl/export/tables/;\
    export EXPORT_SOURCE_QUERIES_PATH=$DISTRO_PATH/distro/configs/analytics/dsl/export/queries;\
    export EXPORT_OUTPUT_PATH=$(pwd)/data/parquet/;\
    export EXPORT_OUTPUT_TAG=h1;
    export MYSQL_USER=openmrs;\
    export MYSQL_PASSWORD=password;\
    export ANALYTICS_CONFIG_FILE_PATH=$DISTRO_PATH/distro/configs/analytics/config.yaml;\
    export ANALYTICS_SOURCE_TABLES_PATH=$DISTRO_PATH/distro/configs/analytics/dsl/flattening/tables/;\
    export ANALYTICS_QUERIES_PATH=$DISTRO_PATH/distro/configs/analytics/dsl/flattening/queries/;\
    export ANALYTICS_DESTINATION_TABLES_MIGRATIONS_PATH=$DISTRO_PATH/distro/configs/analytics/liquibase/analytics/;\
    export JAVA_OPTS='-Xms2048m -Xmx8192m';

    echo "→ ANALYTICS_CONFIG_FILE_PATH=$ANALYTICS_CONFIG_FILE_PATH"
    echo "→ ANALYTICS_DB_PORT=$ANALYTICS_DB_PORT"
    echo "→ ANALYTICS_SOURCE_TABLES_PATH=$ANALYTICS_SOURCE_TABLES_PATH"
    echo "→ ANALYTICS_QUERIES_PATH=$ANALYTICS_QUERIES_PATH"
    echo "→ ANALYTICS_DESTINATION_TABLES_MIGRATIONS_PATH=$ANALYTICS_DESTINATION_TABLES_MIGRATIONS_PATH"
    echo "→ MYSQL_USER=$MYSQL_USER"
    echo "→ MYSQL_PASSWORD=$MYSQL_PASSWORD"
    echo "→ CONNECT_MYSQL_PORT=$CONNECT_MYSQL_PORT"
    echo "→ CONNECT_MYSQL_USER=$CONNECT_MYSQL_USER"
    echo "→ CONNECT_MYSQL_PASSWORD=$CONNECT_MYSQL_PASSWORD"
    echo "→ CONNECT_ODOO_DB_PORT=$CONNECT_ODOO_DB_PORT"
    echo "→ CONNECT_ODOO_DB_NAME=$CONNECT_ODOO_DB_NAME"
    echo "→ CONNECT_ODOO_DB_USER=$CONNECT_ODOO_DB_USER"
    echo "→ CONNECT_ODOO_DB_PASSWORD=$CONNECT_ODOO_DB_PASSWORD"
    echo "→ ODOO_DB_PORT=$ODOO_DB_PORT"
    echo "→ ODOO_DB_NAME=$ODOO_DB_NAME"
    echo "→ ODOO_DB_USER=$ODOO_DB_USER"
    echo "→ ODOO_DB_PASSWORD=$ODOO_DB_PASSWORD"
    echo "→ OPENMRS_DB_PORT=$OPENMRS_DB_PORT"
    echo "→ OPENMRS_DB_NAME=$OPENMRS_DB_NAME"
    echo "→ EXPORT_DESTINATION_TABLES_PATH=$EXPORT_DESTINATION_TABLES_PATH"
    echo "→ EXPORT_SOURCE_QUERIES_PATH=$EXPORT_SOURCE_QUERIES_PATH"
    echo "→ EXPORT_OUTPUT_PATH=$EXPORT_OUTPUT_PATH"
    echo "→ EXPORT_OUTPUT_TAG=$EXPORT_OUTPUT_TAG"
    echo "→ JAVA_OPTS=$JAVA_OPTS"
}