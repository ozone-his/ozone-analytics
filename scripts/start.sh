#!/usr/bin/env bash
set -e

source utils.sh

# Export the DISTRO_PATH variable
setupDirs

setDockerHost

# Export the paths variables to point to distro artifacts
exportEnvs

# Export IP address of the host machine
if [ "$ENABLE_OAUTH" == "true" ]; then
  exportHostIP
fi

# Set the Traefik host names
if [ "$TRAEFIK" == "true" ]; then
    echo "$INFO \$TRAEFIK=true, setting Traefik hostnames..."
    setTraefikIP
    setTraefikHostnames
else
    echo "$INFO \$TRAEFIK!=true, setting Nginx hostnames..."
    setNginxHostnames
fi

echo "$CONNECT_ODOO_DB_NAME"

# Run Ozone Analytics Services
dockerComposeCommand="docker compose -p ozone-analytics -f ../docker/docker-compose-db.yaml -f ../docker/docker-compose-migration.yaml -f ../docker/docker-compose-streaming-common.yaml -f ../docker/docker-compose-kowl.yaml -f ../docker/docker-compose-superset.yaml up -d"
echo "$INFO Running Ozone Analytics Services..."
echo "$dockerComposeCommand"
$dockerComposeCommand

# Run the Nginx Proxy service, if $TRAEFIK!=true
if [ "$TRAEFIK" != "true" ]; then
    dockerComposeProxyCommand="docker compose -p ozone-analytics -f ../docker/proxy/docker-compose-nginx.yaml up -d"
    echo "$INFO Running Nginx proxy service (\$TRAEFIK!=true)..."
    echo ""
    echo "$dockerComposeProxyCommand"
    echo ""
    ($dockerComposeProxyCommand)
else
    echo "$INFO Skipping running Nginx proxy... (\$TRAEFIK=true)"
fi
