#!/bin/bash

set -e

ACTION=${1:-up}

# SERVICES=("immich" "portainer")
SERVICES=("immich")

for service in "${SERVICES[@]}"; do
  echo "docker compose $ACTION - $service"
  
  ENV_ARGS=""
  if [ -f "$service/.env.secret" ]; then
    ENV_ARGS="--env-file $service/.env --env-file $service/.env.secret"
  fi

  case "$ACTION" in
    up)
      docker compose $ENV_ARGS -f "$service/docker-compose.yml" up -d
      ;;
    down)
      docker compose -f "$service/docker-compose.yml" down
      ;;
    pull)
      docker compose -f "$service/docker-compose.yml" pull
      ;;
    restart)
      docker compose -f "$service/docker-compose.yml" restart
      ;;
    *)
      echo "unknown action: $ACTION"
      echo "usage: $0 [up|down|pull|restart]"
      exit 1
      ;;
  esac
done

