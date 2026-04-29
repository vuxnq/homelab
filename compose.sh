#!/bin/bash

set -e

ACTION=${1:-up}

SERVICES=(
  "caddy"
  "dockhand"
  "dufs"
  "glance"
  "immich"
  "music"
  "pihole"
  "upsnap"
  "silverbullet"
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
      docker_compose_cmd up -d
      ;;
    down)
      docker_compose_cmd down
      ;;
    build)
      docker_compose_cmd build --pull
      ;;
    pull)
      docker_compose_cmd pull
      ;;
    restart)
      docker_compose_cmd restart
      ;;
    *)
      echo "> unknown action: $ACTION"
      echo "  usage: $0 [up|down|build|pull|restart]"
      exit 1
      ;;
  esac
done

