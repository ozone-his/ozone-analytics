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
#dockerComposeCommand="docker compose -p ozone-analytics -f ../docker/docker-compose-db.yaml -f ../docker/docker-compose-superset.yaml up -d"
dockerComposeCommand="docker compose -p ozone-analytics -f ../docker/docker-compose-db.yaml -f ../docker/docker-compose-migration.yaml -f ../docker/docker-compose-streaming-common.yaml -f ../docker/docker-compose-kowl.yaml  -f ../docker/docker-compose-superset.yaml up -d"
echo "$INFO Running Ozone Analytics Services..."
echo "$dockerComposeCommand"
$dockerComposeCommand

# Run Nginx proxy
if [ "$TRAEFIK" == "true" ]; then
    echo "$INFO \$TRAEFIK=true, skip running Nginx Proxy..."
    echo "$INFO Assuming that Traefik is running on the host machine..."
  else
    echo "$INFO \$TRAEFIK!=true, running Nginx Proxy..."
    docker compose -p ozone-analytics -f ../docker/proxy/docker-compose-nginx.yaml up -d
    echo "$INFO Nginx is running!"
fi

# Wait for the services to start
echo "$INFO Waiting for the services to start..."
sleep 10 # Wait for 10 seconds

# Display Access URLs
echo "$INFO Ozone Analytics Services are running!"
echo "$INFO Access URLs:"
echo "$INFO Superset: $SCHEME://$SUPERSET_HOSTNAME ($([ "$ENABLE_OAUTH" != "true" ] && echo "admin" || echo "jdoe") / password)"
echo "$INFO Keycloak: $SCHEME://$KEYCLOAK_HOSTNAME (admin / password)"
