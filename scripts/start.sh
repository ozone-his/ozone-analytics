#!/usr/bin/env bash
#
# Starts the Ozone Analytics streaming stack.
#
# This repo does not run OpenMRS or Odoo. It assumes an Ozone distribution is already running and
# plugs into its databases as CDC sources (reached on the host, see setDockerHost in utils.sh). The
# flattening queries and the Flink job images come from that distribution -- fetch it first with:
#
#     ./fetch-ozone-distro.sh <version>
#
# The stack this starts: Kafka + Kafka Connect (Debezium) -> Flink (streaming flatten) -> analytics
# PostgreSQL, with Superset for visualization and Redpanda Console for Kafka/Connect inspection.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
source utils.sh

# Resolve the distro layout (DISTRO_PATH, ANALYTICS_CONFIG_PATH) and fail early with a clear pointer
# if it has not been fetched -- every path the services mount hangs off it.
setupDirs
if [ ! -f "$ANALYTICS_CONFIG_PATH/config.yaml" ]; then
    echo "$ERROR No Ozone distro found at $ANALYTICS_CONFIG_PATH."
    echo "$ERROR Fetch it first:  ./fetch-ozone-distro.sh <version>"
    exit 1
fi

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

# MinIO and Superset attach to the external `web` network (Traefik ingress). Create it if it does
# not exist so a standalone analytics run does not fail on a missing network. MINIO_DOMAIN just
# needs a value for the Traefik label to parse; the Nginx path does not route through it.
docker network inspect web >/dev/null 2>&1 || { echo "$INFO Creating the 'web' docker network..."; docker network create web >/dev/null; }
export MINIO_DOMAIN="${MINIO_DOMAIN:-minio.localhost}"

# The streaming stack, brought together from the distro and this repo's compose files.
compose_files=(
    docker-compose-db.yaml               # analytics PostgreSQL sink (+ Superset/HAPI databases)
    docker-compose-migration.yaml        # creates the flattened destination tables
    docker-compose-minio.yaml            # S3 store for Flink checkpoints/savepoints
    docker-compose-streaming-common.yaml # Kafka (KRaft), Debezium Connect, Flink jobmanager/taskmanager
    docker-compose-redpanda-console.yaml # Kafka + Connect web UI
    docker-compose-superset.yaml         # dashboards
)
compose=(docker compose -p ozone-analytics)
for f in "${compose_files[@]}"; do compose+=(-f "../docker/$f"); done

echo "$INFO Starting Ozone Analytics streaming services..."
"${compose[@]}" up -d

if [ "${TRAEFIK:-false}" != "true" ]; then
    echo "$INFO Starting the Nginx proxy..."
    docker compose -p ozone-analytics -f ../docker/proxy/docker-compose-nginx.yaml up -d
fi

echo "$INFO Waiting for services to start..."
sleep 10

echo "$INFO Ozone Analytics is running. Access URLs:"
echo "$INFO   Superset:         $SCHEME://$SUPERSET_HOSTNAME ($([ "${ENABLE_OAUTH:-false}" != "true" ] && echo "admin" || echo "jdoe") / password)"
echo "$INFO   Keycloak:         $SCHEME://$KEYCLOAK_HOSTNAME (admin / password)"
echo "$INFO   Flink UI:         http://localhost:8085  (one streaming job per flattened table)"
echo "$INFO   Kafka/Connect UI: http://localhost:8282  (Redpanda Console)"
echo "$INFO   MinIO console:    http://localhost:8091  ($MINIO_ROOT_USER / $MINIO_ROOT_PASSWORD)"
