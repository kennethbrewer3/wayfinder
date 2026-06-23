#!/usr/bin/env bash
# Start the Wayfinder web client container.
#
# Uses plain `docker run` because some Docker/Compose setups hang indefinitely
# at "Creating" for auto-generated names like client-client-1.
set -euo pipefail

cd "$(dirname "$0")"
# shellcheck disable=SC1091
source "$(dirname "$0")/docker_lib.sh"

if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example to .env and edit WAYFINDER_API_URL." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

IMAGE="${WAYFINDER_CLIENT_IMAGE:-ghcr.io/kennethbrewer3/wayfinder-client:latest}"
PORT="${WAYFINDER_CLIENT_PORT:-8080}"
NAME="$WAYFINDER_CLIENT_CONTAINER_NAME"
DOCKER="$(wayfinder_client_docker_cli)"

if [[ -z "${WAYFINDER_API_URL:-}" ]]; then
  echo "WAYFINDER_API_URL is required in .env" >&2
  exit 1
fi

if [[ "$DOCKER" == "sudo docker" ]]; then
  echo "Note: using sudo docker because an existing container was created as root." >&2
  echo "      Use sudo docker consistently on this host to avoid name conflicts." >&2
fi

echo "Pulling ${IMAGE}..."
# shellcheck disable=SC2086
$DOCKER pull "$IMAGE"

remove_wayfinder_client_container

echo "Starting ${NAME} on port ${PORT}..."
# shellcheck disable=SC2086
$DOCKER run -d \
  --name "$NAME" \
  --restart unless-stopped \
  -p "${PORT}:8080" \
  -e "WAYFINDER_API_URL=${WAYFINDER_API_URL}" \
  -e "WAYFINDER_WEB_URL=${WAYFINDER_WEB_URL:-}" \
  "$IMAGE"

echo
echo "Client started."
# shellcheck disable=SC2086
$DOCKER ps --filter "name=^/${NAME}$" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo
echo "Config:  curl -s http://127.0.0.1:${PORT}/config.json"
echo "Open:    http://127.0.0.1:${PORT}/"
