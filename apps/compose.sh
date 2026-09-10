#!/usr/bin/env bash

set -e

ACTION=${1:-up}

SERVICES=(
  "caddy"
  "dockhand"
  "dufs"
  "glance"
  "immich"
  "upsnap"
  "syncthing"
)

docker_compose_cmd() {
  env_args=""

  for env_file in "$service"/.env*; do
    [[ -f "$env_file" ]] && env_args+=" --env-file $env_file"
  done

  docker compose $env_args -f "$service/compose.yaml" "$@"
}

for service in "${SERVICES[@]}"; do
  case "$ACTION" in
    up)
      echo "> ${service}: starting..."
      docker_compose_cmd up -d
      ;;
    down)
      echo "> ${service}: stopping..."
      docker_compose_cmd down
      ;;
    update)
      echo "> ${service}: updating..."
      docker_compose_cmd pull --quiet || true
      docker_compose_cmd build --pull || true
      docker_compose_cmd up -d
      ;;
    build)
      echo "> ${service}: building..."
      docker_compose_cmd build --pull
      ;;
    pull)
      echo "> ${service}: pulling..."
      docker_compose_cmd pull
      ;;
    restart)
      echo "> ${service}: restarting..."
      docker_compose_cmd restart
      ;;
    *)
      echo "> unknown action: $ACTION"
      echo "  usage: $0 [up|down|update|build|pull|restart]"
      exit 1
      ;;
  esac
done

