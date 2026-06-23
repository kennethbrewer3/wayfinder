#!/usr/bin/env bash
# Start the Wayfinder web client container.
#
# Uses plain `docker run` by default because some Docker/Compose setups hang
# indefinitely at "Creating" for auto-generated names like client-client-1.
set -euo pipefail

cd "$(dirname "$0")"

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
NAME="wayfinder-client"

if [[ -z "${WAYFINDER_API_URL:-}" ]]; then
  echo "WAYFINDER_API_URL is required in .env" >&2
  exit 1
fi

echo "Pulling ${IMAGE}..."
docker pull "$IMAGE"

echo "Removing any existing ${NAME} container..."
docker rm -f "$NAME" 2>/dev/null || true

echo "Starting ${NAME} on port ${PORT}..."
docker run -d \
  --name "$NAME" \
  --restart unless-stopped \
  -p "${PORT}:8080" \
  -e "WAYFINDER_API_URL=${WAYFINDER_API_URL}" \
  -e "WAYFINDER_WEB_URL=${WAYFINDER_WEB_URL:-}" \
  "$IMAGE"

echo
echo "Client started."
docker ps --filter "name=^/${NAME}$" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo
echo "Config:  curl -s http://127.0.0.1:${PORT}/config.json"
echo "Open:    http://127.0.0.1:${PORT}/"
