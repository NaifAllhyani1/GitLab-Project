#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../docker"

[ -f .env ] || { echo "docker/.env is missing."; exit 1; }
. ./.env
[ -n "${RUNNER_TOKEN:-}" ] || { echo "Set RUNNER_TOKEN in docker/.env first."; exit 1; }

NETWORK=$(docker inspect gitlab --format '{{range $name, $net := .NetworkSettings.Networks}}{{$name}}{{end}}')

docker compose up -d gitlab-runner
docker exec gitlab-runner rm -f /etc/gitlab-runner/config.toml
docker exec gitlab-runner gitlab-runner register --non-interactive \
  --url http://gitlab \
  --clone-url http://gitlab \
  --token "$RUNNER_TOKEN" \
  --executor docker \
  --docker-image python:3.12-slim \
  --docker-network-mode "$NETWORK" \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock
docker exec gitlab-runner gitlab-runner verify