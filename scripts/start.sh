#!/usr/bin/env bash
set -e

source utils.sh

# Export the DISTRO_PATH variable
setupDirs

setDockerHost

# Export the paths variables to point to distro artifacts
exportEnvs

setTraefikIP

setTraefikHostnames

echo $CONNECT_ODOO_DB_NAME

docker compose -p ozone-analytics -f ../docker/docker-compose-db.yaml -f ../docker/docker-compose-migration.yaml -f ../docker/docker-compose-streaming-common.yaml -f ../docker/docker-compose-kowl.yaml up -d
