#!/usr/bin/env bash
set -euo pipefail

dir=${1:?usage: restore.sh <backup-directory>}
file=$(ls "$dir"/*_gitlab_backup.tar)
name=$(basename "$file" _gitlab_backup.tar)

read -rp "This overwrites current GitLab data. Type yes to continue: " answer
[ "$answer" = yes ] || exit 1

docker cp "$file" gitlab:/var/opt/gitlab/backups/
docker exec gitlab chown git:git "/var/opt/gitlab/backups/$(basename "$file")"
docker cp "$dir/gitlab-secrets.json" gitlab:/etc/gitlab/gitlab-secrets.json
docker exec gitlab gitlab-ctl reconfigure
docker exec gitlab gitlab-ctl stop puma
docker exec gitlab gitlab-ctl stop sidekiq
docker exec -e GITLAB_ASSUME_YES=1 gitlab gitlab-backup restore BACKUP="$name"
docker restart gitlab
echo "Restore finished. GitLab needs a few minutes to start, then run scripts/health-check.sh"