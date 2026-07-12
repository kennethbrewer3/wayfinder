#!/usr/bin/env bash
# Start the Wayfinder Flutter web client container.

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly ENV_FILE="${SCRIPT_DIR}/.env"
readonly DOCKER_LIB="${SCRIPT_DIR}/docker_lib.sh"

cd "$SCRIPT_DIR"

if [[ ! -f "$DOCKER_LIB" ]]; then
  printf 'Error: Docker helper library not found: %s\n' "$DOCKER_LIB" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$DOCKER_LIB"

if [[ ! -f "$ENV_FILE" ]]; then
  printf '%s\n' \
    "Error: Missing ${ENV_FILE}" \
    "Copy .env.example to .env and configure WAYFINDER_API_URL." >&2
  exit 1
fi

# Load values needed by this script.
set -a
# shellcheck source=/dev/null
source "$ENV_FILE"
set +a

readonly IMAGE="${WAYFINDER_CLIENT_IMAGE:-ghcr.io/kennethbrewer3/wayfinder-client:latest}"
readonly PORT="${WAYFINDER_CLIENT_PORT:-8080}"
readonly NAME="${WAYFINDER_CLIENT_CONTAINER_NAME:-wayfinder-client}"

if [[ -z "${WAYFINDER_API_URL:-}" ]]; then
  printf 'Error: WAYFINDER_API_URL is required in %s\n' "$ENV_FILE" >&2
  exit 1
fi

if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
  printf 'Error: WAYFINDER_CLIENT_PORT must be between 1 and 65535; received: %s\n' \
    "$PORT" >&2
  exit 1
fi

wayfinder_select_docker_cli

if (( ${#WAYFINDER_DOCKER[@]} == 0 )); then
  printf 'Error: No usable Docker command was selected.\n' >&2
  exit 1
fi

if [[ "${WAYFINDER_DOCKER[*]}" == "sudo docker" ]]; then
  printf '%s\n' \
    "Note: using sudo docker because ordinary Docker is unavailable" \
    "      or the existing container was created as root." >&2
fi

printf 'Pulling %s...\n' "$IMAGE"
"${WAYFINDER_DOCKER[@]}" pull "$IMAGE"

IMAGE_ID="$(
  "${WAYFINDER_DOCKER[@]}" image inspect \
    "$IMAGE" \
    --format '{{.Id}}'
)"

if [[ -z "$IMAGE_ID" ]]; then
  printf 'Error: Unable to determine image ID for %s\n' "$IMAGE" >&2
  exit 1
fi

remove_wayfinder_client_container

printf 'Starting %s on port %s...\n' "$NAME" "$PORT"

CONTAINER_ID="$(
  "${WAYFINDER_DOCKER[@]}" run -d \
    --name "$NAME" \
    --restart unless-stopped \
    --env-file "$ENV_FILE" \
    --publish "${PORT}:8080" \
    --env "WAYFINDER_DOCKER_IMAGE_ID=${IMAGE_ID}" \
    --env "WAYFINDER_DOCKER_IMAGE_REF=${IMAGE}" \
    "$IMAGE"
)"

if [[ -z "$CONTAINER_ID" ]]; then
  printf 'Error: Docker did not return a container ID.\n' >&2
  exit 1
fi

printf '\nClient started successfully.\n'

"${WAYFINDER_DOCKER[@]}" ps \
  --filter "name=^/${NAME}$" \
  --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

printf '\n'
printf 'Config:  curl -fsS http://127.0.0.1:%s/config.json | jq\n' "$PORT"
printf 'Open:    http://127.0.0.1:%s/\n' "$PORT"
