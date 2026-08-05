#!/usr/bin/env bash
set -e

# tput fails when there is no terminal (CI, piped output); fall back to empty so `set -e` is happy.
export TEXT_BLUE=$(tput setaf 4 2>/dev/null || true)
export TEXT_RED=$(tput setaf 1 2>/dev/null || true)
export BOLD=$(tput bold 2>/dev/null || true)
export RESET_FORMATTING=$(tput sgr0 2>/dev/null || true)
INFO="$TEXT_BLUE$BOLD[INFO]$RESET_FORMATTING"
ERROR="$TEXT_RED$BOLD[ERROR]$RESET_FORMATTING"

function setupDirs () {
    # Create the Ozone directory
    source ozone-dir.env
    mkdir -p $OZONE_DIR

    # Export the DISTRO_PATH value
    export DISTRO_PATH=$OZONE_DIR
    echo "→ DISTRO_PATH=$DISTRO_PATH"

    export ANALYTICS_CONFIG_PATH=$DISTRO_PATH/distro/configs/analytics
    echo "→ ANALYTICS_CONFIG_PATH=$ANALYTICS_CONFIG_PATH"
}

# Exports the values the compose files consume that are not already static defaults in docker/.env:
# the paths into the fetched distro (which depend on DISTRO_PATH, so they cannot live in .env) and
# the connection details for reaching the running distro's source databases.
function exportEnvs () {
    echo "$INFO Exporting envs..."

    # Paths into the fetched Ozone distro. setupDirs must have run first.
    export ANALYTICS_CONFIG_FILE=$ANALYTICS_CONFIG_PATH/config.yaml
    export ANALYTICS_SOURCE_TABLES_PATH=$ANALYTICS_CONFIG_PATH/dsl/flattening/tables
    export ANALYTICS_QUERIES_PATH=$ANALYTICS_CONFIG_PATH/dsl/flattening/queries
    export ANALYTICS_DESTINATION_TABLES_MIGRATIONS_PATH=$ANALYTICS_CONFIG_PATH/liquibase/analytics
    export SQL_SCRIPTS_PATH=$DISTRO_PATH/distro/data
    export SUPERSET_CONFIG_PATH=../docker/superset/config
    export SUPERSET_DASHBOARDS_PATH=$DISTRO_PATH/distro/configs/superset/assets/

    # Batch/Parquet export (used by run-batch-export.sh).
    export EXPORT_DESTINATION_TABLES_PATH=$ANALYTICS_CONFIG_PATH/dsl/export/tables/
    export EXPORT_SOURCE_QUERIES_PATH=$ANALYTICS_CONFIG_PATH/dsl/export/queries
    export EXPORT_OUTPUT_PATH=$(pwd)/data/parquet/
    export EXPORT_OUTPUT_TAG=h1

    # Source databases in the running distro (host set separately by setDockerHost). The analytics
    # sink and Kafka credentials are static and live in docker/.env.
    export OPENMRS_DB_PORT=3306
    export OPENMRS_DB_NAME=openmrs
    export MYSQL_USER=openmrs
    export MYSQL_PASSWORD=password
    export CONNECT_MYSQL_PORT=3306
    export CONNECT_MYSQL_USER=root
    export CONNECT_MYSQL_PASSWORD=3cY8Kve4lGey
    export ODOO_DB_PORT=5432
    export ODOO_DB_NAME=odoo
    export ODOO_DB_USER=odoo
    export ODOO_DB_PASSWORD=password
    export CONNECT_ODOO_DB_PORT=5432
    export CONNECT_ODOO_DB_NAME=odoo
    export CONNECT_ODOO_DB_USER=odoo
    export CONNECT_ODOO_DB_PASSWORD=password
    export ANALYTICS_DB_PORT=5432

    export SCHEME=https

    echo "$INFO Distro config: $ANALYTICS_CONFIG_PATH"
    echo "$INFO Source DBs: OpenMRS ${OPENMRS_DB_HOST:-<host>}:$OPENMRS_DB_PORT, Odoo ${ODOO_DB_HOST:-<host>}:$ODOO_DB_PORT"
}

# Points the CDC connectors and JDBC sources at the databases of the Ozone distro running on the
# host. `host.docker.internal` resolves to the host from inside a container on Docker Desktop, and on
# Linux when the compose files map it via `extra_hosts: host-gateway`.
function setDockerHost {
    export DOCKER_GATEWAY_HOST="host.docker.internal"
    export CONNECT_MYSQL_HOSTNAME=$DOCKER_GATEWAY_HOST
    export CONNECT_ODOO_DB_HOSTNAME=$DOCKER_GATEWAY_HOST
    export ODOO_DB_HOST=$DOCKER_GATEWAY_HOST
    export OPENMRS_DB_HOST=$DOCKER_GATEWAY_HOST
}

function setTraefikIP {

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux: use the static Docker bridge IP.
        export IP="172.17.0.1"
        echo "$INFO 'linux-gnu' OS detected, using Docker static IP ($IP) in Traefik hostnames..."
        export IP_WITH_DASHES="${IP//./-}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        # Fetching the LAN IP
        export IP=$(ipconfig getifaddr en0)
        echo "$INFO 'darwin' OS detected, using LAN IP ($IP) in Traefik hostnames..."
        export IP_WITH_DASHES="${IP//./-}"
    fi
}

function exportHostIP() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        export HOST_IP_ADDRESS=$(hostname -I | awk '{print $1}')
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        export HOST_IP_ADDRESS=$(ipconfig getifaddr en0)
    else
        echo "$ERROR Unsupported OS type: $OSTYPE"
        return 1
    fi
    echo "$INFO IP address set to: $HOST_IP_ADDRESS"
}

function setTraefikHostnames {
    echo "$INFO Exporting Traefik hostnames..."

    export SUPERSET_HOSTNAME=analytics-"${IP_WITH_DASHES}.traefik.me"
    export KEYCLOAK_HOSTNAME=auth-"${IP_WITH_DASHES}.traefik.me"

    echo "→ SUPERSET_HOSTNAME=$SUPERSET_HOSTNAME"
    echo "→ KEYCLOAK_HOSTNAME=$KEYCLOAK_HOSTNAME"
}

function setNginxHostnames() {
    echo "$INFO Exporting Nginx hostnames..."

    export SUPERSET_HOSTNAME="${HOST_IP_ADDRESS:-localhost}:8088"
    export KEYCLOAK_HOSTNAME="${HOST_IP_ADDRESS:-localhost}:8084"
    export SCHEME=http

    echo "→ SUPERSET_HOSTNAME=$SUPERSET_HOSTNAME"
    echo "→ KEYCLOAK_HOSTNAME=$KEYCLOAK_HOSTNAME"
    echo "→ SCHEME=$SCHEME"
}
