#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCKER_DIR="${REPO_ROOT}/docker"

# Set Superset config path (can be overridden by existing env)
export SUPERSET_CONFIG_PATH="${SUPERSET_CONFIG_PATH:-${REPO_ROOT}/docker/superset/config/}"

echo "Using SUPERSET_CONFIG_PATH=${SUPERSET_CONFIG_PATH}"

COMPOSE_FILES=(
  -f docker-compose-db.yaml
  -f docker-compose-hapi.yaml
)

# Central / multi-site HAPI: request-tenant partitioning + SHR-friendly IDs.
# Enable with: USE_HAPI_SHR_OVERRIDE=true ./start-fhir-data-pipes.sh
if [ "${USE_HAPI_SHR_OVERRIDE:-false}" = "true" ]; then
  COMPOSE_FILES+=(-f docker-compose-hapi-shr-override.yaml)
  echo "Using HAPI SHR override (partitioning enabled)"
fi

COMPOSE_FILES+=(
  -f docker-compose-fhir-data-pipes.yaml
  -f docker-compose-superset.yaml
  -f docker-compose-superset-ports.yaml
)

echo "Starting FHIR data pipes stack..."
cd "${DOCKER_DIR}"
docker compose "${COMPOSE_FILES[@]}" up -d --build
