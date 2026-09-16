#!/usr/bin/env bash
set -e

# tput fails when there is no terminal (CI, piped output); fall back to empty so `set -e` is happy.
export TEXT_BLUE=$(tput setaf 4 2>/dev/null || true)
export TEXT_YELLOW=$(tput setaf 3 2>/dev/null || true)
export TEXT_RED=$(tput setaf 1 2>/dev/null || true)
export BOLD=$(tput bold 2>/dev/null || true)
export RESET_FORMATTING=$(tput sgr0 2>/dev/null || true)
INFO="$TEXT_BLUE$BOLD[INFO]$RESET_FORMATTING"
WARN="$TEXT_YELLOW$BOLD[WARN]$RESET_FORMATTING"
ERROR="$TEXT_RED$BOLD[ERROR]$RESET_FORMATTING"

# Fails fast with a clear message instead of a cryptic error deep inside a `docker compose` call --
# there is no useful way to run any of this without Docker actually up and Compose v2 available.
function requireDocker () {
    if ! command -v docker >/dev/null 2>&1; then
        echo "$ERROR docker is not installed or not on PATH."
        exit 1
    fi
    if ! docker compose version >/dev/null 2>&1; then
        echo "$ERROR Docker Compose v2 (the 'docker compose' plugin) is required but not available."
        exit 1
    fi
    if ! docker info >/dev/null 2>&1; then
        echo "$ERROR Docker does not appear to be running. Start Docker and try again."
        exit 1
    fi
}

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

# Fetches and unpacks the Ozone distribution this repo's analytics config, flattening queries and
# Flink job images come from. Called automatically by start.sh so a bare checkout of this repo can
# go from nothing to a running stack in one command. setupDirs must have run first.
#
# Configurable via env vars:
#   OZONE_DISTRO_VERSION        Version to fetch, e.g. 1.0.0-SNAPSHOT. Required only when there is
#                                no distro fetched yet; an already-fetched one is reused otherwise.
#   OZONE_DISTRO_ARTIFACT       Maven groupId:artifactId to fetch (default: com.ozonehis:ozone)
#   OZONE_DISTRO_REPOSITORY     Maven repository to fetch from
#                                (default: https://nexus.mekomsolutions.net/repository/maven-public)
#   FETCH_OZONE_DISTRO=false    Skip fetching entirely; reuse whatever is already at $DISTRO_PATH
#   FORCE_FETCH_OZONE_DISTRO=true  Refetch even if the requested version is already there
#
# Idempotent: records what was fetched in $OZONE_DIR/.ozone-distro-fetched, and skips re-fetching on
# a later run that requests the same coordinates -- so re-running start.sh does not re-download the
# distro (and its Docker images) every time.
function fetchOzoneDistro () {
    if [ "${FETCH_OZONE_DISTRO:-true}" == "false" ]; then
        echo "$INFO FETCH_OZONE_DISTRO=false: skipping distro fetch, using whatever is already at $DISTRO_PATH."
        return 0
    fi

    : "${OZONE_DISTRO_ARTIFACT:=com.ozonehis:ozone}"
    : "${OZONE_DISTRO_REPOSITORY:=https://nexus.mekomsolutions.net/repository/maven-public}"
    local marker="$OZONE_DIR/.ozone-distro-fetched"
    local haveDistro=false
    [ -f "$ANALYTICS_CONFIG_PATH/config.yaml" ] && haveDistro=true

    # No version requested and something is already there: nothing to do. This is what lets a
    # second `./start.sh` (or one where the distro was fetched manually, the old way) run with zero
    # env vars.
    if [ "$haveDistro" == "true" ] && [ -z "${OZONE_DISTRO_VERSION:-}" ] && [ "${FORCE_FETCH_OZONE_DISTRO:-false}" != "true" ]; then
        echo "$INFO Reusing the already-fetched Ozone distro at $DISTRO_PATH (set OZONE_DISTRO_VERSION to fetch a specific one)."
        return 0
    fi

    if [ -z "${OZONE_DISTRO_VERSION:-}" ]; then
        echo "$ERROR No Ozone distro found at $DISTRO_PATH, and OZONE_DISTRO_VERSION is not set to fetch one."
        echo "$ERROR   Set it, e.g.: OZONE_DISTRO_VERSION=1.0.0-SNAPSHOT ./start.sh"
        exit 1
    fi

    local fingerprint="$OZONE_DISTRO_ARTIFACT:$OZONE_DISTRO_VERSION@$OZONE_DISTRO_REPOSITORY"

    if [ "$haveDistro" == "true" ] && [ "${FORCE_FETCH_OZONE_DISTRO:-false}" != "true" ] \
        && [ -f "$marker" ] && [ "$(cat "$marker")" == "$fingerprint" ]; then
        echo "$INFO Ozone distro already fetched ($fingerprint); skipping. Set FORCE_FETCH_OZONE_DISTRO=true to refetch."
        return 0
    fi
    if [ -f "$marker" ] && [ "$(cat "$marker")" != "$fingerprint" ]; then
        echo "$WARN Switching distro from $(cat "$marker") to $fingerprint..."
    fi

    echo "$INFO Fetching Ozone distro: $fingerprint"
    if ! ./mvnw -q org.apache.maven.plugins:maven-dependency-plugin:3.2.0:get \
        -DremoteRepositories="$OZONE_DISTRO_REPOSITORY" \
        -Dartifact="$OZONE_DISTRO_ARTIFACT:$OZONE_DISTRO_VERSION:zip" -Dtransitive=false; then
        echo "$ERROR Failed to download $fingerprint -- check the version exists and $OZONE_DISTRO_REPOSITORY is reachable."
        exit 1
    fi

    # Remove the Maven Dependency plugin markers, then unpack the distro.
    rm -rf "$OZONE_DIR/target/dependency-maven-plugin-markers/"
    if ! ./mvnw -q org.apache.maven.plugins:maven-dependency-plugin:3.2.0:unpack \
        -Dproject.basedir="$OZONE_DIR" -Dartifact="$OZONE_DISTRO_ARTIFACT:$OZONE_DISTRO_VERSION:zip" \
        -DoutputDirectory="$DISTRO_PATH"; then
        echo "$ERROR Failed to unpack $fingerprint."
        exit 1
    fi

    echo "$fingerprint" > "$marker"
    echo "$INFO Ozone distro ready: $DISTRO_PATH"
}

# Polls a URL until it responds successfully or the timeout elapses, instead of a blind sleep --
# so the script does not report success before the service can actually serve requests, and does
# not hang forever if something is actually wrong.
function waitForHttp () {
    local url="$1" timeoutSeconds="${2:-120}" waited=0
    if ! command -v curl >/dev/null 2>&1; then
        echo "$WARN curl not found; waiting a fixed 15s instead of polling $url."
        sleep 15
        return 0
    fi
    echo "$INFO Waiting for $url to respond (up to ${timeoutSeconds}s)..."
    while ! curl -ksf -o /dev/null "$url" 2>/dev/null; do
        if [ "$waited" -ge "$timeoutSeconds" ]; then
            echo "$WARN $url did not respond within ${timeoutSeconds}s; continuing anyway -- it may still be starting up."
            return 1
        fi
        sleep 3
        waited=$((waited + 3))
    done
    echo "$INFO $url is up."
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
