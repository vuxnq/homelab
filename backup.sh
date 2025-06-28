#!/bin/bash

set -e

ACTION=${1:-backup}

BACKUP_DIR="$HOME/backups"

RESTIC_REPOSITORY="$BACKUP_DIR/restic"
RESTIC_PASSWORD="$(cat .env.secret | grep RESTIC_PASSWORD | cut -d '=' -f 2)"
TO_BACKUP=("immich/data/library")

restic_cmd() {
  sudo env RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPOSITORY" "$@"
}

echo "> shutting down docker containers..."
./compose.sh down

mkdir -p "$BACKUP_DIR"
if [ ! -d "$RESTIC_REPOSITORY" ]; then
  echo "> initializing restic repository..."
  restic_cmd init
fi

case "$ACTION" in
  backup)
    echo "> backing up .env.secret files..."
    tar -czf "$BACKUP_DIR/env-secrets-$(date +"%Y%m%d-%H%M%S").tar.gz" \
      --transform 's|^\./||' \
      $(sudo find . -type f -name ".env.secret")

    ENV_SECRET_BACKUPS=("$BACKUP_DIR"/env-secrets-*.tar.gz)
    if (( ${#ENV_SECRET_BACKUPS[@]} > 3 )); then
      echo "> pruning old .env.secrets backups..."
      TO_DELETE=("${ENV_SECRET_BACKUPS[@]:0:${#ENV_SECRET_BACKUPS[@]}-3}")
      rm -- "${TO_DELETE[@]}"
    fi

    echo "> backing up restic..."
    restic_cmd backup "${TO_BACKUP[@]}"
    echo "> pruning old restic snapshots..."
    restic_cmd forget --keep-last 3 --prune
    echo "> restic check"
    restic_cmd check
    ;;
  restore)
    ;;
  *)
    echo "> unknown action: $ACTION"
    echo "  usage: $0 [backup|restore]"
    exit 1
    ;;
esac

echo "> starting docker containers"
./compose.sh

echo "> $ACTION complete"

