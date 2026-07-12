#!/usr/bin/env bash
#
# Shared Docker helpers for the Wayfinder web client.
#
# Source this file from start.sh. Do not execute it directly.

WAYFINDER_CLIENT_CONTAINER_NAME="${WAYFINDER_CLIENT_CONTAINER_NAME:-wayfinder-client}"

declare -ag WAYFINDER_DOCKER=()

_wayfinder_has_sudo() {
  command -v sudo >/dev/null 2>&1
}

_wayfinder_container_exists() {
  local -a docker_command=("$@")

  "${docker_command[@]}" container inspect \
    "$WAYFINDER_CLIENT_CONTAINER_NAME" >/dev/null 2>&1
}

_wayfinder_container_ids() {
  local -a docker_command=("$@")

  "${docker_command[@]}" ps -aq \
    --filter "name=^/${WAYFINDER_CLIENT_CONTAINER_NAME}$"
}

_wayfinder_docker_usable() {
  local -a docker_command=("$@")

  "${docker_command[@]}" info >/dev/null 2>&1
}

# Populate the global WAYFINDER_DOCKER array with either:
#
#   WAYFINDER_DOCKER=(docker)
#
# or:
#
#   WAYFINDER_DOCKER=(sudo docker)
wayfinder_select_docker_cli() {
  WAYFINDER_DOCKER=()

  if ! command -v docker >/dev/null 2>&1; then
    printf 'Error: docker was not found in PATH.\n' >&2
    return 1
  fi

  # Prefer whichever CLI can see an existing Wayfinder container.
  if _wayfinder_container_exists docker; then
    WAYFINDER_DOCKER=(docker)
    return 0
  fi

  if _wayfinder_has_sudo &&
     _wayfinder_container_exists sudo docker; then
    WAYFINDER_DOCKER=(sudo docker)
    return 0
  fi

  # No existing container. Prefer non-sudo Docker when available.
  if _wayfinder_docker_usable docker; then
    WAYFINDER_DOCKER=(docker)
    return 0
  fi

  if _wayfinder_has_sudo &&
     _wayfinder_docker_usable sudo docker; then
    WAYFINDER_DOCKER=(sudo docker)
    return 0
  fi

  printf '%s\n' \
    'Error: Docker is installed, but the Docker daemon is inaccessible.' \
    'Start Docker or correct the Docker socket permissions.' >&2

  return 1
}

wayfinder_client_container_present() {
  if _wayfinder_container_exists docker; then
    return 0
  fi

  if _wayfinder_has_sudo &&
     _wayfinder_container_exists sudo docker; then
    return 0
  fi

  return 1
}

_wayfinder_remove_with() {
  local -a docker_command=("$@")
  local ids
  local -a container_ids=()

  ids="$(_wayfinder_container_ids "${docker_command[@]}")"

  if [[ -n "$ids" ]]; then
    mapfile -t container_ids <<< "$ids"

    printf 'Removing existing %s via %s...\n' \
      "$WAYFINDER_CLIENT_CONTAINER_NAME" \
      "${docker_command[*]}"

    "${docker_command[@]}" rm -f "${container_ids[@]}"
    return 0
  fi

  if _wayfinder_container_exists "${docker_command[@]}"; then
    printf 'Removing existing %s via %s...\n' \
      "$WAYFINDER_CLIENT_CONTAINER_NAME" \
      "${docker_command[*]}"

    "${docker_command[@]}" rm -f \
      "$WAYFINDER_CLIENT_CONTAINER_NAME"

    return 0
  fi

  return 1
}

remove_wayfinder_client_container() {
  local removed=false

  if _wayfinder_remove_with docker; then
    removed=true
  fi

  if _wayfinder_has_sudo &&
     _wayfinder_remove_with sudo docker; then
    removed=true
  fi

  if [[ "$removed" == false ]]; then
    printf 'No existing %s container found.\n' \
      "$WAYFINDER_CLIENT_CONTAINER_NAME"
  fi

  if wayfinder_client_container_present; then
    printf 'Error: Failed to remove %s.\n' \
      "$WAYFINDER_CLIENT_CONTAINER_NAME" >&2

    printf '%s\n' \
      'Try removing it manually:' \
      "  docker rm -f ${WAYFINDER_CLIENT_CONTAINER_NAME}" \
      "  sudo docker rm -f ${WAYFINDER_CLIENT_CONTAINER_NAME}" >&2

    return 1
  fi
}
