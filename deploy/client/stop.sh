#!/usr/bin/env bash
# Stop and remove the Wayfinder web client container.

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly DOCKER_LIB="${SCRIPT_DIR}/docker_lib.sh"

if [[ ! -f "$DOCKER_LIB" ]]; then
  printf 'Error: Docker helper library not found: %s\n' "$DOCKER_LIB" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$DOCKER_LIB"

remove_wayfinder_client_container

printf 'Stopped %s.\n' "$WAYFINDER_CLIENT_CONTAINER_NAME"
