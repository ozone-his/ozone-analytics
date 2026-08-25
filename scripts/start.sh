#!/usr/bin/env bash
#
# Runs Ozone Analytics end to end, in one command: fetches the Ozone distribution this repo plugs
# into (unless already fetched, or FETCH_OZONE_DISTRO=false), then starts the streaming stack --
# Kafka + Kafka Connect (Debezium) -> Flink (streaming flatten) -> analytics PostgreSQL, with
# Superset for visualization and Redpanda Console for Kafka/Connect inspection.
#
# This repo does not run OpenMRS or Odoo itself. It assumes an Ozone distribution is already running
# and plugs into its databases as CDC sources (reached on the host, see setDockerHost in utils.sh).
#
# Configuration (env vars, all optional unless noted):
#   OZONE_DISTRO_VERSION           Ozone distro version to fetch, e.g. 1.0.0-SNAPSHOT. Required the
#                                   first time (nothing fetched yet); reused on later runs.
#   OZONE_DISTRO_ARTIFACT           Maven groupId:artifactId to fetch (default: com.ozonehis:ozone)
#   OZONE_DISTRO_REPOSITORY         Maven repository to fetch from
#                                   (default: https://nexus.mekomsolutions.net/repository/maven-public)
#   OZONE_DIR                       Where to fetch/look for the distro (default: ./distro)
#   FETCH_OZONE_DISTRO=false        Skip fetching; reuse whatever is already at $OZONE_DIR
#   FORCE_FETCH_OZONE_DISTRO=true   Refetch even if the requested version is already there
#   TRAEFIK=true                    Use Traefik ingress hostnames instead of the bundled Nginx proxy
#   ENABLE_OAUTH=true               Configure Superset to authenticate against the distro's Keycloak
#
# Examples:
#   OZONE_DISTRO_VERSION=1.0.0-SNAPSHOT ./start.sh   # first run
#   ./start.sh                                        # later runs: reuses the fetched distro
#   FETCH_OZONE_DISTRO=false ./start.sh               # distro managed/fetched elsewhere
set -euo pipefail

STARTED_AT=$SECONDS
cd "$(dirname "${BASH_SOURCE[0]}")"
source utils.sh

requireDocker

# Resolve the distro layout (DISTRO_PATH, ANALYTICS_CONFIG_PATH), then fetch it if it is not already
# present -- the only thing standing between a bare checkout of this repo and a running stack.
setupDirs
fetchOzoneDistro

# Point the CDC connectors at the running distro's databases, and export the derived paths and
# config the compose files consume.
setDockerHost
exportEnvs

# Superset is reached either through Traefik (hostnames derived from the host IP) or the bundled
# Nginx proxy. OAuth/Keycloak needs the host IP exported too.
if [ "${ENABLE_OAUTH:-false}" == "true" ]; then
    exportHostIP
fi
if [ "${TRAEFIK:-false}" == "true" ]; then
    echo "$INFO TRAEFIK=true: using Traefik hostnames; assuming Traefik runs on the host."
    setTraefikIP
    setTraefikHostnames
else
    echo "$INFO Using the bundled Nginx proxy."
    setNginxHostnames
fi

# Superset attaches to the external `web` network (Traefik ingress). Create it if it does not exist
# so a standalone analytics run does not fail on a missing network.
docker network inspect web >/dev/null 2>&1 || { echo "$INFO Creating the 'web' docker network..."; docker network create web >/dev/null; }

# The streaming stack, brought together from the distro and this repo's compose files.
compose_files=(
    docker-compose-db.yaml               # analytics PostgreSQL sink (+ Superset/HAPI databases)
    docker-compose-migration.yaml        # creates the flattened destination tables
    docker-compose-seaweedfs.yaml        # S3 store for Flink checkpoints/savepoints
    docker-compose-streaming-common.yaml # Kafka (KRaft), Debezium Connect, Flink jobmanager/taskmanager
    docker-compose-redpanda-console.yaml # Kafka + Connect web UI
    docker-compose-superset.yaml         # dashboards
)
compose=(docker compose -p ozone-analytics)
for f in "${compose_files[@]}"; do compose+=(-f "../docker/$f"); done

echo "$INFO Starting Ozone Analytics streaming services (${#compose_files[@]} compose files)..."
if ! "${compose[@]}" up -d; then
    echo "$ERROR Failed to start the streaming stack. Check the Docker Compose output above."
    exit 1
fi

if [ "${TRAEFIK:-false}" != "true" ]; then
    echo "$INFO Starting the Nginx proxy..."
    if ! docker compose -p ozone-analytics -f ../docker/proxy/docker-compose-nginx.yaml up -d; then
        echo "$ERROR Failed to start the Nginx proxy. Check the Docker Compose output above."
        exit 1
    fi
fi

# A real readiness check rather than a blind sleep: report success once Superset can actually serve
# requests, and warn (without failing) rather than hang forever if it is taking unusually long --
# the containers are still up and may just need more time on a slower machine.
waitForHttp "$SCHEME://$SUPERSET_HOSTNAME/health" 180 || true

ELAPSED=$((SECONDS - STARTED_AT))
echo "$INFO Ozone Analytics is running (${ELAPSED}s). Access URLs:"
echo "$INFO   Superset:         $SCHEME://$SUPERSET_HOSTNAME ($([ "${ENABLE_OAUTH:-false}" != "true" ] && echo "admin" || echo "jdoe") / password)"
if [ "${ENABLE_OAUTH:-false}" == "true" ]; then
    # Keycloak itself is not part of this stack -- it belongs to the running Ozone distro this
    # repo plugs into, so only worth pointing at when Superset is actually configured to use it.
    echo "$INFO   Keycloak:         $SCHEME://$KEYCLOAK_HOSTNAME (admin / password)"
fi
echo "$INFO   Flink UI:         http://localhost:8085  (one streaming job per flattened table)"
echo "$INFO   Kafka/Connect UI: http://localhost:8282  (Redpanda Console)"
echo "$INFO   SeaweedFS filer:  http://localhost:8888  (browse the Flink state store)"
echo "$INFO Logs:               docker compose -p ozone-analytics logs -f [service]"
echo "$INFO Stop:               ./destroy.sh"
