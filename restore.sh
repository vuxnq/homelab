#!/usr/bin/env bash

set -eo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "> run this script as root to handle volume permissions"
  exit 1
fi

echo "> select backup source:"
echo "  1) local drive (/mnt/backups/zerobyte)"
echo "  2) backblaze B2"
read -rp "> choice [1 or 2]: " SOURCE_CHOICE

DOCKER_ENV=()
REPO_ARGS=()

if [ "$SOURCE_CHOICE" = "1" ]; then
  BASE_DIR="/mnt/backups/zerobyte"
  
  if [ ! -d "$BASE_DIR" ]; then
    echo "> error: directory '$BASE_DIR' does not exist" >&2
    exit 1
  fi
  
  echo "> scanning for repos in $BASE_DIR..."
  shopt -s nullglob
  repos=("$BASE_DIR"/*/)
  shopt -u nullglob
  
  repos=("${repos[@]%/}")
  
  if [ ${#repos[@]} -eq 0 ]; then
    echo "> no repos found in $BASE_DIR!"
    exit 1
  elif [ ${#repos[@]} -eq 1 ]; then
    LOCAL_REPO="${repos[0]}"
    echo "> auto-selected only repo: $(basename "$LOCAL_REPO")"
  else
    echo "> multiple repos found. please select one:"
    select repo_path in "${repos[@]}"; do
      if [ -n "$repo_path" ]; then
        LOCAL_REPO="$repo_path"
        break
      else
        echo "> invalid selection"
      fi
    done
  fi
  
  echo "> using repo path: $LOCAL_REPO"
  
  DOCKER_ENV+=("-v" "$LOCAL_REPO:/repo:ro")
  REPO_ARGS=("-r" "/repo" "--no-lock")

elif [ "$SOURCE_CHOICE" = "2" ]; then
  read -rp "> enter bucket name (e.g., vuxnq-sheol): " B2_BUCKET
  read -rp "> enter key ID: " B2_ID
  read -rsp "> enter application key: " B2_KEY
  echo ""
  
  DOCKER_ENV+=(
    "-e" "RESTIC_REPOSITORY=b2:${B2_BUCKET}"
    "-e" "B2_ACCOUNT_ID=$B2_ID"
    "-e" "B2_ACCOUNT_KEY=$B2_KEY"
  )
  REPO_ARGS=("--no-lock")

else
  echo "> invalid choice. aborting" >&2
  exit 1
fi

read -rsp "> enter restic encryption password: " RESTIC_PASSWORD
echo ""
DOCKER_ENV+=("-e" "RESTIC_PASSWORD=$RESTIC_PASSWORD")

# volume mappings (from zerobyte's container)
RESTORE_MAP=(
  "/volumes/sheol:/home/vuxnq/sheol"
  "/volumes/mnt:/mnt"
)

echo ""
echo "> starting volume restores..."

for mapping in "${RESTORE_MAP[@]}"; do
  SNAP_PATH="${mapping%%:*}"
  HOST_DEST="${mapping##*:}"
  
  echo ">> restoring $SNAP_PATH directly to $HOST_DEST..."
  
  mkdir -p "$HOST_DEST"
  
  docker run --rm -i \
    "${DOCKER_ENV[@]}" \
    -v "$HOST_DEST:$SNAP_PATH" \
    restic/restic:latest \
    "${REPO_ARGS[@]}" \
    restore latest \
    --path "$SNAP_PATH" \
    --target /
    
  echo ">> done!"
done

echo ""
echo "> recovery complete!"
