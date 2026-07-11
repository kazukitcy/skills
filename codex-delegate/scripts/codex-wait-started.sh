#!/usr/bin/env bash
# Poll events.jsonl for a session/thread id. Exit 0 prints the matching
# line; exit 1 is a pure timeout; exit 2 is invalid usage; exit 3 means
# the published child died without publishing a session id.
#
# Usage: codex-wait-started.sh <job-dir> [timeout-seconds]
# timeout-seconds: 1..86400 (default 120)
set -u

usage() {
  echo "usage: codex-wait-started.sh <job-dir> [timeout-seconds]" >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage
job_dir=$1
timeout=${2:-120}
[ -d "$job_dir" ] || usage

case "$timeout" in
  *[!0-9]*|'') usage ;;
esac
case "$timeout" in
  0|0*|??????*) usage ;;
esac
[ "$timeout" -le 86400 ] || usage

events="$job_dir/events.jsonl"
pid_file="$job_dir/codex.pid"
deadline=$(( $(date +%s) + timeout ))

find_session() {
  [ -f "$events" ] || return 1
  grep -m1 -E '"(session_id|thread_id)"' "$events" 2>/dev/null
}

while [ "$(date +%s)" -lt "$deadline" ]; do
  if line=$(find_session); then
    printf '%s\n' "$line"
    exit 0
  fi
  if [ -f "$pid_file" ]; then
    pid=$(sed -n '1p' "$pid_file" 2>/dev/null)
    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
      if line=$(find_session); then
        printf '%s\n' "$line"
        exit 0
      fi
      echo "codex process died before publishing a session id — read $job_dir/stderr.log" >&2
      exit 3
    fi
  fi
  sleep 1
done

if line=$(find_session); then
  printf '%s\n' "$line"
  exit 0
fi
echo "no session id in $events after ${timeout}s — read $job_dir/stderr.log and run the full liveness check" >&2
exit 1
