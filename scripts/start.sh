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
dockerComposeCommand="docker compose -p ozone-analytics -f ../docker/docker-compose-db.yaml -f ../docker/docker-compose-superset.yaml -f ../docker/docker-compose-superset-ports.yaml up -d"
echo "$INFO Running Ozone Analytics Services..."
echo "$dockerComposeCommand"
$dockerComposeCommand


# Display Access URLs
echo "$INFO Ozone Analytics Services are running!"
echo "$INFO ┌──────────────────────────────────────────────"
echo "$INFO │ Access URLs"
echo "$INFO ├──────────────────────────────────────────────"
echo "$INFO │ Superset: $SCHEME://$SUPERSET_HOSTNAME"
if [ "$ENABLE_OAUTH" != "true" ]; then
    echo "$INFO │ Credentials: admin / password"
else
    echo "$INFO │ Credentials: jdoe / password"
fi
echo "$INFO ├──────────────────────────────────────────────"
echo "$INFO │ Keycloak: $SCHEME://$KEYCLOAK_HOSTNAME"
echo "$INFO │ Credentials: admin / password"
echo "$INFO └──────────────────────────────────────────────"
