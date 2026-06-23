#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

NAME="wayfinder-client"

docker rm -f "$NAME" 2>/dev/null || true
docker compose down --remove-orphans 2>/dev/null || true

echo "Stopped ${NAME}."
