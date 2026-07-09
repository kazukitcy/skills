#!/usr/bin/env bash
# Verify a codex-delegate run actually started: poll the job's events.jsonl
# until a session/thread id appears (proof of launch), then print that line.
# Exit 0 with the id line on success; exit 1 after the timeout with a hint
# to check stderr.log (per SKILL.md step 4, a run with no session id must be
# relaunched fresh, not resumed).
#
# Usage: codex-wait-started.sh <job-dir> [timeout-seconds]   (default 120)
set -u

job_dir=${1:?usage: codex-wait-started.sh <job-dir> [timeout-seconds]}
timeout=${2:-120}
events="$job_dir/events.jsonl"
deadline=$(( $(date +%s) + timeout ))

while [ "$(date +%s)" -lt "$deadline" ]; do
  if [ -f "$events" ] && line=$(grep -m1 -E '"(session_id|thread_id)"' "$events" 2>/dev/null); then
    printf '%s\n' "$line"
    exit 0
  fi
  sleep 2
done

echo "no session id in $events after ${timeout}s — read $job_dir/stderr.log and relaunch fresh" >&2
exit 1
