#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
target=${1:?usage: redeploy.sh app|gitlab}

case "$target" in
  app)
    docker build \
      --build-arg APP_VERSION=manual \
      --build-arg GIT_COMMIT="$(git -C "$ROOT" rev-parse HEAD)" \
      --build-arg GIT_BRANCH="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)" \
      --build-arg BUILD_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      -t sample-app:latest "$ROOT/sample-app"
    docker rm -f sample-app || true
    docker run -d --name sample-app --restart unless-stopped -p 8501:8501 sample-app:latest
    for _ in $(seq 1 10); do
      if curl -fsS -o /dev/null http://localhost:8501/_stcore/health; then
        echo "App is healthy"
        exit 0
      fi
      sleep 3
    done
    docker logs sample-app
    exit 1
    ;;
  gitlab)
    cd "$ROOT/docker"
    docker compose pull gitlab
    docker compose up -d gitlab
    ;;
  *)
    echo "usage: redeploy.sh app|gitlab"
    exit 1
    ;;
esac