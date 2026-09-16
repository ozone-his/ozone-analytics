#!/usr/bin/env bash
#
# Explicitly (re-)fetches the Ozone distribution into $OZONE_DIR. You normally do not need to run
# this directly -- start.sh calls the same logic automatically the first time. Use this to refresh a
# SNAPSHOT, or to switch versions/artifact/repository ahead of the next start.sh run.
#
# Usage: ./fetch-ozone-distro.sh <version>
#    or: OZONE_DISTRO_VERSION=<version> ./fetch-ozone-distro.sh
#
# See fetchOzoneDistro() in utils.sh for the full set of OZONE_DISTRO_* env vars this respects.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
source utils.sh

# The positional arg wins, for backwards compatibility with the historical
# `./fetch-ozone-distro.sh <version>` invocation.
if [ -n "${1:-}" ]; then
    export OZONE_DISTRO_VERSION="$1"
fi
if [ -z "${OZONE_DISTRO_VERSION:-}" ]; then
    echo "$ERROR Missing version. Usage: $0 <version>  (or set OZONE_DISTRO_VERSION)"
    echo "$ERROR   Eg: $0 1.0.0-SNAPSHOT"
    exit 1
fi

# Called directly, so the point is always to (re-)fetch -- not to silently reuse a cached copy.
export FORCE_FETCH_OZONE_DISTRO=true

setupDirs
fetchOzoneDistro
