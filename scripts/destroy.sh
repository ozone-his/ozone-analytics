#!/usr/bin/env bash
set -e

source utils.sh

echo "$INFO Destroying Ozone Analytics Services..."
# Stop and remove the containers
docker compose -p ozone-analytics down -v
echo "$INFO Ozone Analytics Services destroyed!"
