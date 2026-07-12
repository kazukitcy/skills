#!/usr/bin/env bash
# Standalone tests for codex-collect.sh. Run directly: bash collect-tests.sh
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
COLLECT=$SCRIPT_DIR/../codex-collect.sh
failures=0

check() {
  desc=$1; expected=$2; actual=$3
  if [ "$actual" = "$expected" ]; then
    echo "ok: $desc"
  else
    echo "FAIL: $desc"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    failures=$((failures + 1))
  fi
}

fresh_job() {
  job=$(mktemp -d "${TMPDIR:-/tmp}/collect-test.XXXXXX") || { echo "FATAL: mktemp failed" >&2; exit 1; }
  [ -n "$job" ] || { echo "FATAL: mktemp returned empty path" >&2; exit 1; }
  mkdir "$job/.claim" || { echo "FATAL: claim fixture failed" >&2; exit 1; }
}

verdict() { bash "$COLLECT" "$job" | sed -n 's/^collect: //p'; }

# Completed launch: valid result + turn.completed + status 0 -> result-ok.
fresh_job
printf '{"type":"turn.completed"}\n' > "$job/events.jsonl"
printf 'final message\n' > "$job/last-message.md"
printf '0\n' > "$job/status"
check "completed launch is result-ok" "result-ok $job/last-message.md" "$(verdict)"
rm -rf "$job"

# Row 2: valid result + status 0, completion event never flushed -> result-ok
# (the hand-rolled check this script replaces misclassified this as a death).
fresh_job
printf '{"type":"item.completed"}\n' > "$job/events.jsonl"
printf 'final message\n' > "$job/last-message.md"
printf '0\n' > "$job/status"
check "unflushed completion with status 0 is result-ok" \
  "result-ok $job/last-message.md" "$(verdict)"
rm -rf "$job"

# Whitespace-tolerant completion match (parity with codex-resume-backend.sh).
fresh_job
printf '{"type" : "turn.completed"}\n' > "$job/events.jsonl"
printf 'final message\n' > "$job/last-message.md"
check "spaced completion JSON still counts as completed" \
  "result-ok $job/last-message.md" "$(verdict)"
rm -rf "$job"

# Row 3: completion event present but result missing -> recover-from-events.
fresh_job
printf '{"type":"turn.completed"}\n' > "$job/events.jsonl"
check "missing result with completed events recovers from events" \
  "recover-from-events $job/events.jsonl" "$(verdict)"
rm -rf "$job"

# Row 4: no completion, no status, dead pid -> died-midflight.
fresh_job
printf '{"type":"thread.started"}\n' > "$job/events.jsonl"
printf '999999999\n' > "$job/codex.pid"
check "dead child without completion is died-midflight" "died-midflight" "$(verdict)"
rm -rf "$job"

# Live child wins over everything.
fresh_job
printf '{"type":"turn.completed"}\n' > "$job/events.jsonl"
printf 'final message\n' > "$job/last-message.md"
# The classifier treats only *codex*|sh basenames as live; keep sh resident
# with a compound command (a lone `sleep` would be exec'd, renaming comm).
sh -c 'sleep 5; exit 0' & sh_pid=$!
printf '%s\n' "$sh_pid" > "$job/codex.pid"
check "live child reports live" "live" "$(verdict)"
kill "$sh_pid" 2>/dev/null; wait "$sh_pid" 2>/dev/null
rm -rf "$job"

# Promoted resume: resume attempt completed and promoted to canonical path.
fresh_job
printf '{"type":"thread.started"}\n' > "$job/events.jsonl"
printf '{"type":"turn.completed"}\n' > "$job/events-resume-1.jsonl"
printf 'resumed message\n' > "$job/last-message-resume-1.md"
printf '0\n' > "$job/status-resume-1"
cp "$job/last-message-resume-1.md" "$job/last-message.md"
check "promoted resume prefers the canonical result path" \
  "result-ok $job/last-message.md" "$(verdict)"
rm -rf "$job"

# Row 1 with a non-zero recorded status: completion event wins regardless.
fresh_job
printf '{"type":"turn.completed"}\n' > "$job/events.jsonl"
printf 'final message\n' > "$job/last-message.md"
printf '143\n' > "$job/status"
check "completed events beat a non-zero status" \
  "result-ok $job/last-message.md" "$(verdict)"
rm -rf "$job"

# Row 4: valid result but missing status and no completion -> died-midflight.
fresh_job
printf '{"type":"thread.started"}\n' > "$job/events.jsonl"
printf 'partial message\n' > "$job/last-message.md"
check "valid result without status or completion is died-midflight" \
  "died-midflight" "$(verdict)"
rm -rf "$job"

# Row 2 without any events file: valid result + status 0 is still result-ok.
fresh_job
printf 'final message\n' > "$job/last-message.md"
printf '0\n' > "$job/status"
check "missing events with valid result and status 0 is result-ok" \
  "result-ok $job/last-message.md" "$(verdict)"
rm -rf "$job"

# Row 4 without any events file: status alone marks an attempt.
fresh_job
printf '1\n' > "$job/status"
check "missing events with non-zero status is died-midflight" \
  "died-midflight" "$(verdict)"
rm -rf "$job"

# Fail-closed pid classifier: kill -0 succeeds but ps yields nothing -> live.
fresh_job
printf '{"type":"turn.completed"}\n' > "$job/events.jsonl"
printf 'final message\n' > "$job/last-message.md"
printf '%s\n' "$$" > "$job/codex.pid"
shim_dir=$(mktemp -d "${TMPDIR:-/tmp}/collect-shim.XXXXXX") || { echo "FATAL: mktemp failed" >&2; exit 1; }
printf '#!/bin/sh\nexit 1\n' > "$shim_dir/ps" && chmod +x "$shim_dir/ps"
actual=$(PATH="$shim_dir:$PATH" bash "$COLLECT" "$job" | sed -n 's/^collect: //p')
check "failed ps output fails closed as live" "live" "$actual"
rm -rf "$shim_dir" "$job"

# Empty directory (claimed, nothing launched) -> no-attempt.
fresh_job
check "claimed but unlaunched job is no-attempt" "no-attempt" "$(verdict)"
rm -rf "$job"

# Unclaimed directory refuses with exit 66.
job=$(mktemp -d "${TMPDIR:-/tmp}/collect-test.XXXXXX") || { echo "FATAL: mktemp failed" >&2; exit 1; }
[ -n "$job" ] || { echo "FATAL: mktemp returned empty path" >&2; exit 1; }
bash "$COLLECT" "$job" >/dev/null 2>&1
check "unclaimed directory exits 66" "66" "$?"
rm -rf "$job"

if [ "$failures" -gt 0 ]; then
  echo "$failures test(s) failed"
  exit 1
fi
echo "all collect tests passed"
