#!/usr/bin/env bash
set -e

export TEXT_BLUE=`tput setaf 4`
export TEXT_RED=`tput setaf 1`
export BOLD=`tput bold`
export RESET_FORMATTING=`tput sgr0`
INFO="$TEXT_BLUE$BOLD[INFO]$RESET_FORMATTING"
ERROR="$TEXT_RED$BOLD[ERROR]$RESET_FORMATTING"

function setupDirs () {
    # Create the Ozone directory
    source ozone-dir.env
    mkdir -p $OZONE_DIR

    # Export the DISTRO_PATH value
    export DISTRO_PATH=$OZONE_DIR
    echo "→ DISTRO_PATH=$DISTRO_PATH"

    export ANALYTICS_CONFIG_PATH=$DISTRO_PATH/configs/analytics
    echo "→ ANALYTICS_CONFIG_PATH=$ANALYTICS_CONFIG_PATH"
}

function exportEnvs () {
    echo "$INFO Exporting envs..."
    export ANALYTICS_CONFIG_FILE_PATH=$ANALYTICS_CONFIG_PATH/config.yaml
    export ANALYTICS_DB_PORT=5432
    export CONNECT_MYSQL_PORT=3306
    export CONNECT_MYSQL_USER=root
    export CONNECT_MYSQL_PASSWORD=3cY8Kve4lGey
    export CONNECT_ODOO_DB_PORT=5432
    export CONNECT_ODOO_DB_NAME=odoo
    export CONNECT_ODOO_DB_USER=odoo
    export CONNECT_ODOO_DB_PASSWORD=password
    export ODOO_DB_PORT=5432
    export ODOO_DB_NAME=odoo
    export ODOO_DB_USER=odoo
    export ODOO_DB_PASSWORD=password
    export OPENMRS_DB_PORT=3306
    export OPENMRS_DB_NAME=openmrs
    export EXPORT_DESTINATION_TABLES_PATH=$ANALYTICS_CONFIG_PATH/dsl/export/tables/
    export EXPORT_SOURCE_QUERIES_PATH=$ANALYTICS_CONFIG_PATH/dsl/export/queries
    export EXPORT_OUTPUT_PATH=$(pwd)/data/parquet/
    export EXPORT_OUTPUT_TAG=h1
    export MYSQL_USER=openmrs
    export MYSQL_PASSWORD=password
    export ANALYTICS_CONFIG_FILE_PATH=$ANALYTICS_CONFIG_PATH/config.yaml
    export ANALYTICS_SOURCE_TABLES_PATH=$ANALYTICS_CONFIG_PATH/dsl/flattening/tables
    export ANALYTICS_QUERIES_PATH=$ANALYTICS_CONFIG_PATH/dsl/flattening/queries
    export ANALYTICS_DESTINATION_TABLES_MIGRATIONS_PATH=$ANALYTICS_CONFIG_PATH/liquibase/analytics
    export SQL_SCRIPTS_PATH=$DISTRO_PATH/data
    export SUPERSET_CONFIG_PATH=$DISTRO_PATH/configs/superset/
    export SUPERSET_DASHBOARDS_PATH=$DISTRO_PATH/configs/superset/assets/
    export EIP_KEYCLOAK_SUPERSET_ROUTES_PATH=$DISTRO_PATH/binaries/eip-keycloak-superset
    export EIP_KEYCLOAK_SUPERSET_PROPERTIES_PATH=$DISTRO_PATH/configs/eip-keycloak-superset/properties
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
    echo "→ SQL_SCRIPTS_PATH=$SQL_SCRIPTS_PATH"
    echo "→ SUPERSET_CONFIG_PATH=$SUPERSET_CONFIG_PATH"
    echo "→ SUPERSET_DASHBOARDS_PATH=$SUPERSET_DASHBOARDS_PATH"
    echo "→ EIP_KEYCLOAK_SUPERSET_ROUTES_PATH=$EIP_KEYCLOAK_SUPERSET_ROUTES_PATH"
    echo "→ EIP_KEYCLOAK_SUPERSET_PROPERTIES_PATH=$EIP_KEYCLOAK_SUPERSET_PROPERTIES_PATH"
    echo "→ JAVA_OPTS=$JAVA_OPTS"
}

function setDockerHost {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        export DOCKER_GATEWAY_HOST="172.17.0.1" 
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        export DOCKER_GATEWAY_HOST="host.docker.internal"
    fi
    export DOCKER_GATEWAY_HOST="host.docker.internal"
    export CONNECT_MYSQL_HOSTNAME=$DOCKER_GATEWAY_HOST
    export CONNECT_ODOO_DB_HOSTNAME=$DOCKER_GATEWAY_HOST
    export ODOO_DB_HOST=$DOCKER_GATEWAY_HOST
    export OPENMRS_DB_HOST=$DOCKER_GATEWAY_HOST
}

function setTraefikIP {

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        # Using the static Docker IP
        export IP="172.17.0.1"
        echo "$INFO 'linux-gnu' OS detected, using Docker static IP ($IP) in Traefik hostnames..."
        export IP="172.17.0.1"
        export IP_WITH_DASHES="${IP//./-}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        # Fetching the LAN IP
        export IP=$(ipconfig getifaddr en0)
        echo "$INFO 'darwin' OS detected, using LAN IP ($IP) in Traefik hostnames..."
        export IP_WITH_DASHES="${IP//./-}"
    fi
}

function setTraefikHostnames {
    echo "$INFO Exporting Traefik hostnames..."

    export SUPERSET_HOSTNAME=analytics-"${IP_WITH_DASHES}.traefik.me"
    export KEYCLOAK_HOSTNAME=auth-"${IP_WITH_DASHES}.traefik.me"
    echo "→ SUPERSET_HOSTNAME=$SUPERSET_HOSTNAME"
    echo "→ KEYCLOAK_HOSTNAME=$KEYCLOAK_HOSTNAME"
}

function setDockerComposeCLIOptions () {
    # Parse 'docker-compose-files.txt' to get the list of Docker Compose files to run
    dockerComposeFiles=$(cat docker-compose-files.txt)
    for file in ${dockerComposeFiles}
    do
        export dockerComposeCLIOptions="$dockerComposeCLIOptions -f ../docker/$file"
    done
    if [ "$withOzoneSSO" = "true" ]; then
        export dockerComposeCLIOptions="$dockerComposeCLIOptions --env-file ../docker/.env --env-file ../docker/secrets.env  -f ../docker-compose-eip-keycloak-superset.yaml"
    fi
}