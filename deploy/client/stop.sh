#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
# shellcheck disable=SC1091
source "$(dirname "$0")/docker_lib.sh"

NAME="$WAYFINDER_CLIENT_CONTAINER_NAME"

remove_wayfinder_client_container
docker compose down --remove-orphans 2>/dev/null || true
sudo docker compose down --remove-orphans 2>/dev/null || true

echo "Stopped ${NAME}."
