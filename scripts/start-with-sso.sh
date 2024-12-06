#!/usr/bin/env bash
set -e

source utils.sh

export ENABLE_OAUTH=true
echo "$INFO Setting ENABLE_OAUTH=true..."
echo "→ ENABLE_OAUTH=$ENABLE_OAUTH"

source start.sh
