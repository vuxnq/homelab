#!/bin/bash

set -e

BACKUP_DIR="$HOME/backups"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

mkdir -p "$BACKUP_DIR"

echo "> backing up .env.secret files..."
tar -czf "$BACKUP_DIR/env-secrets-$TIMESTAMP.tar.gz" \
  --transform 's|^\./||' \
  $(sudo find . -type f -name ".env.secret")

# echo "> backing up data directories..."
# tar -czf "$BACKUP_DIR/data-$TIMESTAMP.tar.gz" \
#   --transform 's|^\./||' \
#   ./immich/data \

echo "> backup complete: $BACKUP_DIR"
