#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=${BACKUP_DIR:-$HOME/gitlab-backups}
DEST=$ROOT_DIR/$(date +%Y%m%d-%H%M%S)
mkdir -p "$DEST"
chmod 700 "$DEST"

docker exec gitlab gitlab-backup create

latest=$(docker exec gitlab sh -c 'ls -t /var/opt/gitlab/backups/*_gitlab_backup.tar | head -1')
docker cp "gitlab:$latest" "$DEST/"
docker cp gitlab:/etc/gitlab/gitlab-secrets.json "$DEST/"
docker cp gitlab:/etc/gitlab/gitlab.rb "$DEST/"
chmod 600 "$DEST"/*

find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} +
docker exec gitlab find /var/opt/gitlab/backups -name '*_gitlab_backup.tar' -mtime +7 -delete

echo "Backup saved in $DEST"
ls -lh "$DEST"