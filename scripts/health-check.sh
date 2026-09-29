#!/usr/bin/env bash
fail=0

check() {
  label=$1
  shift
  if "$@" >/dev/null 2>&1; then
    echo "OK    $label"
  else
    echo "FAIL  $label"
    fail=1
  fi
}

gitlab_healthy() { [ "$(docker inspect --format '{{.State.Health.Status}}' gitlab)" = healthy ]; }
is_running() { [ "$(docker inspect --format '{{.State.Running}}' "$1")" = true ]; }
disk_ok() { [ "$(df --output=pcent / | tail -1 | tr -dc '0-9')" -lt 85 ]; }

check "GitLab container healthy" gitlab_healthy
check "GitLab web endpoint" curl -fsS -o /dev/null http://localhost/users/sign_in
check "GitLab Runner container running" is_running gitlab-runner
check "Sample app health endpoint" curl -fsS -o /dev/null http://localhost:8501/_stcore/health
check "Root disk under 85 percent" disk_ok

echo
free -h
df -h /
exit $fail