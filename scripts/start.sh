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

setDockerComposeCLIOptions

echo $dockerComposeCLIOptions

docker compose -p ozone-analytics $dockerComposeCLIOptions up -d --build --remove-orphans
