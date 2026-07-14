#!/usr/bin/env bash
# codex-resume-backend.sh — safely resume a claimed codex-delegate job.
#
# Usage: codex-resume-backend.sh [-f FOLLOWUP_FILE|-] [--] JOB_DIR
# Exit 64 usage; 65 refusal; 66 environment/staging; 67 promotion failure;
# otherwise the recorded child status, the last-wait fallback, or silent 143
# when TERM was observed and no status recorder survived.
set -u

usage() { echo "usage: $0 [-f FOLLOWUP_FILE|-] [--] JOB_DIR" >&2; exit 64; }
die64() { echo "error: $1" >&2; exit 64; }
die66() { echo "error: $1" >&2; exit 66; }

absolute_path() {
  case "$1" in /*) printf '%s\n' "$1" ;; *) printf '%s/%s\n' "$PWD" "$1" ;; esac
}

has_line_delimiter() {
  case "$1" in
    *"
"*|*""*) return 0 ;;
    *) return 1 ;;
  esac
}

followup_src=""
followup_set=0
while getopts "f:" opt; do
  case "$opt" in f) followup_src=$OPTARG; followup_set=1 ;; *) usage ;; esac
done
shift $((OPTIND - 1))
[ "$followup_set" -eq 0 ] || [ -n "$followup_src" ] || die64 "-f must not be empty"
[ "$#" -eq 1 ] || usage
[ -n "$1" ] && has_line_delimiter "$1" && usage
jobdir=$(absolute_path "$1")
if [ -n "$followup_src" ] && [ "$followup_src" != "-" ]; then
  followup_src=$(absolute_path "$followup_src")
fi
has_line_delimiter "$jobdir" && usage
while [ "${#jobdir}" -gt 1 ]; do
  case "$jobdir" in
    */.) jobdir=${jobdir%.} ;;
    */) jobdir=${jobdir%/} ;;
    *) break ;;
  esac
done
if [ -n "$followup_src" ] && [ "$followup_src" != "-" ]; then
  [ ! -L "$followup_src" ] && [ -f "$followup_src" ] && [ -r "$followup_src" ] || \
    die64 "follow-up file must be an existing, readable, regular non-symlink file: $followup_src"
fi

[ -d "$jobdir" ] && [ ! -L "$jobdir" ] || die66 "job directory not found: $jobdir"
[ ! -L "$jobdir/.claim" ] && [ -d "$jobdir/.claim" ] || die66 "job directory has no valid .claim lineage"
[ ! -L "$jobdir/events.jsonl" ] && [ -f "$jobdir/events.jsonl" ] || die66 "job directory has no valid events.jsonl lineage"

refuse() {
  printf 'job-dir:      %s\n' "$jobdir"
  printf 'refused: %s\n' "$1"
  exit 65
}

lock=$jobdir/resume.lock
if ! mkdir "$lock" 2>/dev/null; then
  owner=""
  [ -f "$lock/pid" ] && owner=$(sed -n '1p' "$lock/pid" 2>/dev/null)
  case "$owner" in
    ''|*[!0-9]*) echo "error: stale resume.lock; remove it manually after verifying no resume is active" >&2; refuse stale-lock ;;
    *)
      if kill -0 "$owner" 2>/dev/null; then refuse lock-held; fi
      echo "error: stale resume.lock; remove it manually after verifying no resume is active" >&2
      refuse stale-lock
      ;;
  esac
fi
printf '%s\n' "$$" > "$lock/pid" || { rmdir "$lock" 2>/dev/null; die66 "failed to record lock owner"; }
cleanup() { rm -f "$lock/pid" 2>/dev/null; rmdir "$lock" 2>/dev/null; }
trap 'cleanup' EXIT

events_regular() { [ ! -L "$1" ] && [ -f "$1" ]; }
result_complete() { [ ! -L "$1" ] && [ -f "$1" ] && [ -s "$1" ]; }

found_kind=""
found_n=""
found_events=""
found_result=""
scan_completed() {
  found_kind=""; found_n=""; found_events=""; found_result=""
  n=2
  while [ "$n" -ge 1 ]; do
    e=$jobdir/events-resume-$n.jsonl
    r=$jobdir/last-message-resume-$n.md
    if events_regular "$e" && result_complete "$r" && grep -q '"type"[[:space:]]*:[[:space:]]*"turn.completed"' "$e" 2>/dev/null; then
      found_kind=resume; found_n=$n; found_events=$e; found_result=$r; return 0
    fi
    n=$((n - 1))
  done
  e=$jobdir/events.jsonl
  r=$jobdir/last-message.md
  if events_regular "$e" && result_complete "$r" && grep -q '"type"[[:space:]]*:[[:space:]]*"turn.completed"' "$e" 2>/dev/null; then
    found_kind=original; found_events=$e; found_result=$r; return 0
  fi
  return 1
}

promotion_source=""
promote_result() {
  promotion_source=$1
  canonical=$jobdir/last-message.md
  result_complete "$promotion_source" || return 1
  if [ -e "$canonical" ] || [ -L "$canonical" ]; then
    [ ! -L "$canonical" ] && [ -f "$canonical" ] || return 1
  fi
  stage=$(mktemp "$jobdir/.promote.XXXXXX") || return 1
  if ! cp "$promotion_source" "$stage"; then rm -f "$stage"; return 1; fi
  if ! mv "$stage" "$canonical"; then rm -f "$stage"; return 1; fi
  result_complete "$canonical" && cmp -s "$promotion_source" "$canonical"
}

report_completed() {
  if [ "$found_kind" = original ]; then
    printf 'job-dir:      %s\n' "$jobdir"
    printf 'already-completed: %s\n' "$jobdir/last-message.md"
    printf 'events:       %s\n' "$found_events"
    exit 0
  fi
  if promote_result "$found_result"; then
    printf 'job-dir:      %s\n' "$jobdir"
    printf 'already-completed: %s\n' "$jobdir/last-message.md"
    printf 'recovered-from: %s\n' "$found_result"
    printf 'events:       %s\n' "$found_events"
    exit 0
  fi
  printf 'job-dir:      %s\n' "$jobdir"
  printf 'recovered-from: %s\n' "$found_result"
  printf 'promotion-failed: %s\n' "$jobdir/last-message.md"
  printf 'events:       %s\n' "$found_events"
  exit 67
}

classify_pid() {
  pid_state=absent
  pid_value=""
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

archive_dead_pid() {
  [ "$pid_state" = dead ] || return 0
  k=1
  while [ -e "$jobdir/codex.pid.stale-$k" ] || [ -L "$jobdir/codex.pid.stale-$k" ]; do k=$((k + 1)); done
  mv "$jobdir/codex.pid" "$jobdir/codex.pid.stale-$k" || die66 "failed to archive stale codex.pid"
}

read_session() {
  events_regular "$jobdir/events.jsonl" || die66 "events.jsonl lineage changed"
  session=$(sed -nE 's/.*"(session_id|thread_id)"[[:space:]]*:[[:space:]]*"([^"]+)".*/\2/p' "$jobdir/events.jsonl" 2>/dev/null | head -1)
  [ -n "$session" ] || refuse no-session
}

choose_attempt() {
  attempt=1
  while [ "$attempt" -le 2 ] && { [ -e "$jobdir/events-resume-$attempt.jsonl" ] || [ -L "$jobdir/events-resume-$attempt.jsonl" ]; }; do
    attempt=$((attempt + 1))
  done
  [ "$attempt" -le 2 ] || refuse cap-reached
}

authorization_pass() {
  if scan_completed; then report_completed; fi
  classify_pid
  [ "$pid_state" != live ] || refuse live-process
  archive_dead_pid
  read_session
  choose_attempt
}

authorization_pass
codex_arg=$(command -v codex 2>/dev/null) || die66 "codex is not resolvable on PATH"

grace_tmp=$jobdir/grace-began.tmp.$$
printf '%s %s\n' "$$" "$attempt" > "$grace_tmp" || die66 "failed to stage grace token"
mv "$grace_tmp" "$jobdir/grace-began" || die66 "failed to publish grace token"
sleep 5
authorization_pass

events=$jobdir/events-resume-$attempt.jsonl
if ! ( set -C; : > "$events" ) 2>/dev/null; then refuse cap-reached; fi
followup_file=$jobdir/followup-$attempt.md
if [ -z "$followup_src" ]; then
  printf '%s\n' 'Continue where you left off; finish the remaining work and emit the complete final message.' > "$followup_file" || die66 "failed to write follow-up"
elif [ "$followup_src" = "-" ]; then
  cat > "$followup_file" || die66 "failed to write follow-up from stdin"
else
  cp "$followup_src" "$followup_file" || die66 "failed to copy follow-up file"
fi

result=$jobdir/last-message-resume-$attempt.md
stderr_file=$jobdir/stderr-resume-$attempt.log
status_file=$jobdir/status-resume-$attempt
pid_file=$jobdir/codex.pid

owed=0
term_seen=0
on_term() { owed=$((owed + 1)); term_seen=1; }
trap 'on_term' TERM

printf 'job-dir:      %s\nlast-message: %s\nevents:       %s\nstderr:       %s\nstatus:       %s\n' \
  "$jobdir" "$result" "$events" "$stderr_file" "$status_file" || \
  die66 "failed to write prelaunch announcement"

(
  /bin/sh -c '
pid_path=$2
delay=$3
if [ -n "$delay" ] && [ "$delay" != 0 ]; then sleep "$delay"; fi
pid_tmp=$pid_path.tmp.$$
printf "%s\n" "$$" > "$pid_tmp" || exit 126
mv "$pid_tmp" "$pid_path" || exit 126
exec -- "$1" exec resume "$4" --json -o "$5" -
' sh "$codex_arg" "$pid_file" "${CODEX_DELEGATE_TEST_PRE_PUBLISH_DELAY:-0}" "$session" "$result" \
    < "$followup_file" > "$events" 2> "$stderr_file"
  child_status=$?
  if [ -z "${CODEX_DELEGATE_TEST_SUPPRESS_STATUS:-}" ]; then
    status_tmp=$status_file.tmp.$$
    if printf '%s\n' "$child_status" > "$status_tmp"; then
      mv "$status_tmp" "$status_file" 2>/dev/null || true
    fi
  fi
  exit "$child_status"
) &
outer_pid=$!

pending_ticks=0
warning_printed=0
last_wait=127
while :; do
  if ! kill -0 "$outer_pid" 2>/dev/null || [ -f "$status_file" ]; then
    wait "$outer_pid"
    last_wait=$?
    break
  fi
  if [ "$owed" -gt 0 ]; then
    if [ -f "$pid_file" ]; then
      target=$(sed -n '1p' "$pid_file" 2>/dev/null)
      [ -n "$target" ] && kill -TERM "$target" 2>/dev/null || true
      owed=$((owed - 1))
      pending_ticks=0
    else
      pending_ticks=$((pending_ticks + 1))
      if [ "$pending_ticks" -ge 50 ] && [ "$warning_printed" -eq 0 ]; then
        echo "TERM received; waiting for codex.pid publication before forwarding" >&2
        warning_printed=1
      fi
    fi
  fi
  sleep 0.2
done

i=0
while [ ! -f "$status_file" ] && [ "$i" -lt 10 ]; do sleep 0.1; i=$((i + 1)); done
[ -n "${CODEX_DELEGATE_TEST_POST_REAP_HOLD:-}" ] && sleep "$CODEX_DELEGATE_TEST_POST_REAP_HOLD"

status_present=0
if [ -f "$status_file" ]; then
  final_status=$(sed -n '1p' "$status_file")
  status_present=1
else
  final_status=$last_wait
fi

terminal_kind=unpromoted
if scan_completed && [ "$found_kind" = resume ] && [ "$found_n" -eq "$attempt" ]; then
  if promote_result "$result"; then terminal_kind=promoted; else terminal_kind=promotion-failed; fi
fi

if [ "$terminal_kind" = promotion-failed ]; then
  printf 'promotion-failed: %s\n' "$jobdir/last-message.md"
  printf 'exit:         67\n'
  exit 67
fi
if [ "$status_present" -eq 0 ] && [ "$term_seen" -eq 1 ]; then exit 143; fi
if [ "$terminal_kind" = promoted ]; then
  printf 'promoted:     %s\n' "$jobdir/last-message.md"
else
  printf 'unpromoted:   incomplete-evidence\n'
fi
printf 'exit:         %s\n' "$final_status"
exit "$final_status"
