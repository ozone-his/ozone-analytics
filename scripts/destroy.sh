#!/usr/bin/env bash
set -e

source utils.sh

# Export the DISTRO_PATH variable
setupDirs

# Export the paths variables to point to distro artifacts
exportEnvs

setTraefikIP

setTraefikHostnames

setDockerComposeCLIOptions

docker compose -p ozone-analytics $dockerComposeCLIOptions down -v 
