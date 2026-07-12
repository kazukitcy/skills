#!/usr/bin/env bash
# codex-collect.sh — read-only classification of a claimed codex-delegate job.
#
# Usage: codex-collect.sh JOB_DIR
#
# Prints one `attempt:` line per existing attempt block (original, resume-1,
# resume-2) with its evidence — recorded status, result validity, completion
# event, pid liveness — then one `collect:` verdict for the newest attempt:
#
#   collect: live                       child still running; do not act
#   collect: result-ok <result-path>    step-5 row 1 or 2: read the result
#   collect: recover-from-events <events-path>   row 3: collection fault
#   collect: died-midflight             row 4: resume per the taxonomy
#   collect: no-attempt                 no attempt has produced evidence yet
#
# The script never mutates the job directory; the SKILL.md step-5 table stays
# authoritative for the disposition. Exit 0 with a verdict; 64 usage; 66 when
# the job directory is missing or lacks claim lineage.
#
# The predicates mirror codex-resume-backend.sh (events_regular,
# result_complete, the whitespace-tolerant turn.completed grep, and the
# normalized pid classifier). Keep the two files in sync.
set -u

usage() { echo "usage: $0 JOB_DIR" >&2; exit 64; }
die66() { echo "error: $1" >&2; exit 66; }

[ "$#" -eq 1 ] || usage
case "$1" in -*) usage ;; esac
jobdir=$1
[ -d "$jobdir" ] && [ ! -L "$jobdir" ] || die66 "job directory not found: $jobdir"
[ ! -L "$jobdir/.claim" ] && [ -d "$jobdir/.claim" ] || die66 "job directory has no valid .claim lineage"

events_regular() { [ ! -L "$1" ] && [ -f "$1" ]; }
result_complete() { [ ! -L "$1" ] && [ -f "$1" ] && [ -s "$1" ]; }
turn_completed() {
  events_regular "$1" && \
    grep -q '"type"[[:space:]]*:[[:space:]]*"turn.completed"' "$1" 2>/dev/null
}

# Normalized liveness classifier, mirroring codex-resume-backend.sh:
# missing pid file -> absent (indeterminate); kill -0 failure -> dead;
# empty/failed ps output fails closed as live; only a foreign basename
# proves pid reuse.
classify_pid() {
  pid_state=absent
  [ -f "$jobdir/codex.pid" ] || return 0
  pid_value=$(sed -n '1p' "$jobdir/codex.pid" 2>/dev/null)
  if [ -z "$pid_value" ] || ! kill -0 "$pid_value" 2>/dev/null; then
    pid_state=dead
    return 0
  fi
  comm=$(ps -o comm= -p "$pid_value" 2>/dev/null)
  ps_status=$?
  if [ "$ps_status" -ne 0 ] || [ -z "$comm" ]; then pid_state=live; return 0; fi
  comm=$(printf '%s\n' "$comm" | sed -n '1p')
  base=${comm##*/}
  case "$base" in *codex*|sh) pid_state=live ;; *) pid_state=dead ;; esac
}

report_attempt() {
  label=$1; events=$2; result=$3; status_path=$4
  status_text=missing
  if [ ! -L "$status_path" ] && [ -f "$status_path" ]; then
    status_text=$(sed -n '1p' "$status_path" 2>/dev/null)
    [ -n "$status_text" ] || status_text=empty
  fi
  result_text=invalid
  result_complete "$result" && result_text=valid
  completed_text=no
  turn_completed "$events" && completed_text=yes
  printf 'attempt: %s status=%s result=%s turn.completed=%s\n' \
    "$label" "$status_text" "$result_text" "$completed_text"
}

verdict_for() {
  events=$1; result=$2; status_path=$3
  status_value=""
  if [ ! -L "$status_path" ] && [ -f "$status_path" ]; then
    status_value=$(sed -n '1p' "$status_path" 2>/dev/null)
  fi
  if result_complete "$result" && { turn_completed "$events" || [ "$status_value" = 0 ]; }; then
    printf 'collect: result-ok %s\n' "$result"
    return 0
  fi
  if turn_completed "$events"; then
    printf 'collect: recover-from-events %s\n' "$events"
    return 0
  fi
  printf 'collect: died-midflight\n'
}

# An attempt exists when ANY of its block's files does (even invalid or
# symlinked): step-5 row 2 needs no events file, and row 4 covers invalid
# evidence. `no-attempt` is reserved for a claimed directory with no attempt
# evidence at all.
attempt_evidence() {
  for p in "$1" "$2" "$3"; do
    if [ -e "$p" ] || [ -L "$p" ]; then return 0; fi
  done
  return 1
}

newest_events=""; newest_result=""; newest_status=""; newest_found=0
if attempt_evidence "$jobdir/events.jsonl" "$jobdir/last-message.md" "$jobdir/status"; then
  report_attempt original "$jobdir/events.jsonl" "$jobdir/last-message.md" "$jobdir/status"
  newest_events=$jobdir/events.jsonl
  newest_result=$jobdir/last-message.md
  newest_status=$jobdir/status
  newest_found=1
fi
n=1
while [ "$n" -le 2 ]; do
  e=$jobdir/events-resume-$n.jsonl
  r=$jobdir/last-message-resume-$n.md
  s=$jobdir/status-resume-$n
  if attempt_evidence "$e" "$r" "$s"; then
    report_attempt "resume-$n" "$e" "$r" "$s"
    # A promoted resume result lands in the canonical last-message.md; prefer
    # it when it is valid and byte-identical to the attempt result.
    newest_events=$e; newest_result=$r; newest_status=$s; newest_found=1
    if result_complete "$r" && result_complete "$jobdir/last-message.md" && \
       cmp -s "$r" "$jobdir/last-message.md" 2>/dev/null; then
      newest_result=$jobdir/last-message.md
    fi
  fi
  n=$((n + 1))
done

classify_pid
printf 'codex.pid: %s\n' "$pid_state"
if [ "$pid_state" = live ]; then
  printf 'collect: live\n'
  exit 0
fi
if [ "$newest_found" -eq 0 ]; then
  printf 'collect: no-attempt\n'
  exit 0
fi
verdict_for "$newest_events" "$newest_result" "$newest_status"
