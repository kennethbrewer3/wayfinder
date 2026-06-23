#!/usr/bin/env bash

WAYFINDER_CLIENT_CONTAINER_NAME="wayfinder-client"

_wayfinder_docker() {
  printf '%s\n' docker
}

_wayfinder_sudo_docker() {
  if command -v sudo >/dev/null 2>&1; then
    printf '%s\n' "sudo docker"
  fi
}

_wayfinder_container_exists() {
  local cli="$1"
  # shellcheck disable=SC2086
  $cli container inspect "$WAYFINDER_CLIENT_CONTAINER_NAME" >/dev/null 2>&1
}

_wayfinder_container_ids() {
  local cli="$1"
  # shellcheck disable=SC2086
  $cli ps -aq --filter "name=^/${WAYFINDER_CLIENT_CONTAINER_NAME}$"
}

# Print the docker CLI that can see the existing container, or default docker.
wayfinder_client_docker_cli() {
  local cli
  for cli in "$(_wayfinder_docker)" "$(_wayfinder_sudo_docker)"; do
    [[ -n "$cli" ]] || continue
    if _wayfinder_container_exists "$cli"; then
      printf '%s\n' "$cli"
      return 0
    fi
  done
  _wayfinder_docker
}

wayfinder_client_container_present() {
  local cli
  for cli in "$(_wayfinder_docker)" "$(_wayfinder_sudo_docker)"; do
    [[ -n "$cli" ]] || continue
    if _wayfinder_container_exists "$cli"; then
      return 0
    fi
  done
  return 1
}

remove_wayfinder_client_container() {
  local cli removed=false ids

  for cli in "$(_wayfinder_docker)" "$(_wayfinder_sudo_docker)"; do
    [[ -n "$cli" ]] || continue

    ids="$(_wayfinder_container_ids "$cli")"
    if [[ -n "$ids" ]]; then
      echo "Removing existing ${WAYFINDER_CLIENT_CONTAINER_NAME} via ${cli}..."
      # shellcheck disable=SC2086
      $cli rm -f $ids
      removed=true
    elif _wayfinder_container_exists "$cli"; then
      echo "Removing existing ${WAYFINDER_CLIENT_CONTAINER_NAME} via ${cli}..."
      # shellcheck disable=SC2086
      $cli rm -f "$WAYFINDER_CLIENT_CONTAINER_NAME"
      removed=true
    fi
  done

  if [[ "$removed" == false ]]; then
    echo "No existing ${WAYFINDER_CLIENT_CONTAINER_NAME} container found."
  fi

  if wayfinder_client_container_present; then
    echo "Failed to remove ${WAYFINDER_CLIENT_CONTAINER_NAME}." >&2
    echo "Try manually:" >&2
    echo "  docker rm -f ${WAYFINDER_CLIENT_CONTAINER_NAME}" >&2
    echo "  sudo docker rm -f ${WAYFINDER_CLIENT_CONTAINER_NAME}" >&2
    return 1
  fi
}
