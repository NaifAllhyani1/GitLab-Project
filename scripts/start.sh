#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../docker"

[ -f .env ] || { echo "docker/.env is missing. Copy .env.example to .env and fill it in."; exit 1; }

docker compose up -d

echo "Waiting for GitLab to become healthy (first start can take 5-10 minutes)"
status=missing
for _ in $(seq 1 90); do
  status=$(docker inspect --format '{{.State.Health.Status}}' gitlab 2>/dev/null || echo missing)
  [ "$status" = healthy ] && break
  sleep 10
done

if [ "$status" != healthy ]; then
  echo "GitLab is not healthy after 15 minutes"
  docker logs gitlab --tail 30
  exit 1
fi

. ./.env
echo "GitLab is up at http://$VM_PUBLIC_IP"