#!/bin/bash

set -e

ACTION=${1:-backup}

BACKUP_DIR="/mnt/backups"

RESTIC_REPOSITORY="$BACKUP_DIR/restic"
TO_BACKUP=(
  "/mnt/cloud"
  "/mnt/immich"
  "/mnt/music"
  "/mnt/sync"

  "dockhand/data"
  "immich/data"
  "music/data"
  "pihole/data"
  "syncthing/data"
  "zerobyte/data"
)

load_restic_password() {
  if [[ -f .env ]]; then
    RESTIC_PASSWORD=$(grep -E "^RESTIC_PASSWORD=" .env | cut -d '=' -f2-)
  fi

  if [[ -z "$RESTIC_PASSWORD" ]]; then
    echo "! RESTIC_PASSWORD not found in .env"
    read -rsp "enter restic password: " RESTIC_PASSWORD
    echo "RESTIC_PASSWORD=$RESTIC_PASSWORD" >> .env
    echo
  fi
}

restic_cmd() {
  load_restic_password
  sudo env RESTIC_PASSWORD="$RESTIC_PASSWORD" \
    restic -r "$RESTIC_REPOSITORY" "$@"
}

mkdir -p "$BACKUP_DIR"
if [ ! -d "$RESTIC_REPOSITORY" ]; then
  echo "> initializing restic repository..."
  restic_cmd init
fi

case "$ACTION" in
  backup)
    echo "> backing up restic..."
    restic_cmd backup "${TO_BACKUP[@]}"
    echo "> pruning old restic snapshots..."
    restic_cmd forget --keep-last 3 --group-by "" --prune
    echo "> restic check"
    restic_cmd check

    echo "> backing up .env files..."
    tar -czf "$BACKUP_DIR/env-$(date +"%Y%m%d-%H%M%S").tar.gz" \
      --transform 's|^\./||' \
      $(sudo find . -type f \( -name ".env" -o -path "./.env" \))

    env_backups=("$BACKUP_DIR"/env-*.tar.gz)
    if (( ${#env_backups[@]} > 3 )); then
      echo "> pruning old .env backups..."
      to_delete=("${env_backups[@]:0:${#env_backups[@]}-3}")
      rm -- "${to_delete[@]}"
    fi
    ;;
  restore)
    latest_env_backup=$(ls -1t "$BACKUP_DIR"/env-*.tar.gz 2>/dev/null | head -n 1)
    if [ -z "$latest_env_backup" ]; then
      echo "! no .env backups found"
    else
      echo "> restoring .env files: $latest_env_backup..."
      tar -xzf "$latest_env_backup" -C .
    fi

    echo "> available restic snapshots:"
    restic_cmd snapshots

    echo
    read -p "restore from latest snapshot? [Y/n]: " choice
    if [[ "$choice" =~ ^[Nn]$ ]]; then
      read -p "enter snapshot ID: " SNAPSHOT_ID
    else
      SNAPSHOT_ID=$(restic_cmd snapshots --json | jq -r '.[-1].short_id')
    fi

    echo "> restoring restic snapshot: $SNAPSHOT_ID..."
    RESTORE_TEMP="$BACKUP_DIR/temp"
    mkdir -p "$RESTORE_TEMP"
    restic_cmd restore "$SNAPSHOT_ID" --target "$RESTORE_TEMP"

    echo "> copying restored files back to original locations..."
    for dir in "${TO_BACKUP[@]}"; do
      subpath="$dir" # relative path
      if [[ "$dir" = /* ]]; then
        subpath="${dir#/}" # absolute path
      fi

      sudo rsync -a "$RESTORE_TEMP/$subpath/" "$dir/"
    done

    echo "> cleaning up temp restore directory..."
    sudo rm -rf "$RESTORE_TEMP"
    ;;
  *)
    echo "> unknown action: $ACTION"
    echo "  usage: $0 [backup|restore]"
    exit 1
    ;;
esac

echo "> $ACTION complete"

