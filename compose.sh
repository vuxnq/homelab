#!/bin/bash

set -e

ACTION=${1:-up}

SERVICES=("caddy" "glance" "immich")

docker_compose_cmd() {
  env_args=""

  for env_file in "$service"/.env*; do
    [[ -f "$env_file" ]] && env_args+=" --env-file $env_file"
  done

  docker compose $env_args -f "$service/docker-compose.yml" "$@"
}

for service in "${SERVICES[@]}"; do
  case "$ACTION" in
    up)
      docker_compose_cmd up -d
      ;;
    down)
    docker_compose_cmd down
      ;;
    pull)
      docker_compose_cmd pull
      ;;
    restart)
      docker_compose_cmd restart
      ;;
    *)
      echo "> unknown action: $ACTION"
      echo "  usage: $0 [up|down|pull|restart]"
      exit 1
      ;;
  esac
done

