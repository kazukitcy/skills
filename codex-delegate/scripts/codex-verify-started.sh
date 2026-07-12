#!/usr/bin/env bash
# Read the prelaunch announcement from a file capturing the backend's stdout,
# then run codex-wait-started.sh for the announced job directory. Tests may set
# CODEX_DELEGATE_TEST_ANNOUNCEMENT_POLL_LIMIT to a positive poll count; when
# unset, production uses 75 polls at 0.2 seconds each (15 seconds total).
#
# Usage: codex-verify-started.sh <stdout-capture-file> [timeout-seconds]
# timeout-seconds: 1..86400 (default 120)
set -u

usage() {
  echo "usage: codex-verify-started.sh <stdout-capture-file> [timeout-seconds]" >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage
capture_file=$1
timeout=${2:-120}

case "$timeout" in
  *[!0-9]*|'') usage ;;
esac
case "$timeout" in
  0|0*|??????*) usage ;;
esac
[ "$timeout" -le 86400 ] || usage

poll_limit=${CODEX_DELEGATE_TEST_ANNOUNCEMENT_POLL_LIMIT:-75}
case "$poll_limit" in
  *[!0-9]*|''|0|0*|??????*) poll_limit=75 ;;
esac

announcement_line=""
i=0
while [ "$i" -lt "$poll_limit" ]; do
  if [ -f "$capture_file" ]; then
    announcement_line=$(grep -m1 '^job-dir:' "$capture_file" 2>/dev/null) || announcement_line=""
    [ -n "$announcement_line" ] && break
  fi
  sleep 0.2
  i=$((i + 1))
done

if [ -z "$announcement_line" ]; then
  echo "no announcement in $capture_file — backend preflight failure (exit 64/66) or wrong capture file; read the file and the backend's stderr" >&2
  exit 4
fi

job_dir=$(printf '%s\n' "$announcement_line" | sed 's/^job-dir:[[:space:]]*//')
grep -E '^(job-dir:|last-message:|events:|stderr:|status:)' "$capture_file"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
exec bash "$SCRIPT_DIR/codex-wait-started.sh" "$job_dir" "$timeout"
