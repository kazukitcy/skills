#!/usr/bin/env bash
# codex-exec-backend.sh — launch Codex with durable file-based evidence.
#
# Usage:
#   codex-exec-backend.sh [-s SANDBOX] [-C DIR] [-m MODEL] [-e EFFORT] [-j DIR] [--] PROMPT_FILE|-
#
# Exit 64: usage/argument error. Exit 66: environment, staging, or claim
# failure. Otherwise the recorded child status is authoritative; if it is
# unavailable, the last wait status is used unless TERM was observed, in
# which case the announcement is left intact and the script exits 143.
set -u

usage() {
  echo "usage: $0 [-s read-only|workspace-write] [-C DIR] [-m MODEL] [-e EFFORT] [-j DIR] [--] PROMPT_FILE|-" >&2
  exit 64
}

absolute_path() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *) printf '%s/%s\n' "$PWD" "$1" ;;
  esac
}

has_line_delimiter() {
  case "$1" in
    *"
"*|*""*) return 0 ;;
    *) return 1 ;;
  esac
}

die64() { echo "error: $1" >&2; exit 64; }
die66() { echo "error: $1" >&2; exit 66; }

directory_is_empty() {
  listing=$(mktemp /tmp/codex-delegate-listing.XXXXXX) || die66 "failed to allocate directory listing"
  if ! ls -A "$1" > "$listing" 2>/dev/null; then
    rm -f "$listing"
    die66 "failed to enumerate supplied job directory"
  fi
  if [ -s "$listing" ]; then
    rm -f "$listing"
    return 1
  fi
  rm -f "$listing"
  return 0
}

sandbox=read-only
workdir=$PWD
model=""
effort=""
jobdir=""
sandbox_set=0
workdir_set=0
model_set=0
effort_set=0
jobdir_set=0

while getopts "s:C:m:e:j:" opt; do
  case "$opt" in
    s) sandbox=$OPTARG; sandbox_set=1 ;;
    C) workdir=$OPTARG; workdir_set=1 ;;
    m) model=$OPTARG; model_set=1 ;;
    e) effort=$OPTARG; effort_set=1 ;;
    j) jobdir=$OPTARG; jobdir_set=1 ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[ "$sandbox_set" -eq 0 ] || [ -n "$sandbox" ] || die64 "-s must not be empty"
[ "$workdir_set" -eq 0 ] || [ -n "$workdir" ] || die64 "-C must not be empty"
[ "$model_set" -eq 0 ] || [ -n "$model" ] || die64 "-m must not be empty"
[ "$effort_set" -eq 0 ] || [ -n "$effort" ] || die64 "-e must not be empty"
[ "$jobdir_set" -eq 0 ] || [ -n "$jobdir" ] || die64 "-j must not be empty"
[ "$#" -eq 1 ] || usage
prompt_src=$1

[ -n "$jobdir" ] && has_line_delimiter "$jobdir" && die64 "job path must not contain CR or LF"
has_line_delimiter "$workdir" && die64 "working directory must not contain CR or LF"

case "$sandbox" in read-only|workspace-write) ;; *) die64 "-s must be read-only or workspace-write" ;; esac
if [ -n "$effort" ]; then
  case "$effort" in *[!a-z]*) die64 "-e must contain lowercase letters only" ;; esac
fi

workdir=$(absolute_path "$workdir")
has_line_delimiter "$workdir" && die64 "working directory must not contain CR or LF"
[ -d "$workdir" ] || die64 "working directory not found: $workdir"
if [ "$prompt_src" != "-" ]; then prompt_src=$(absolute_path "$prompt_src"); fi
if [ -n "$jobdir" ]; then jobdir=$(absolute_path "$jobdir"); fi
while [ "${#jobdir}" -gt 1 ]; do
  case "$jobdir" in
    */.) jobdir=${jobdir%.} ;;
    */) jobdir=${jobdir%/} ;;
    *) break ;;
  esac
done
if [ "$prompt_src" != "-" ]; then
  [ ! -L "$prompt_src" ] && [ -f "$prompt_src" ] && [ -r "$prompt_src" ] || \
    die64 "prompt file must be an existing, readable, regular non-symlink file: $prompt_src"
fi

codex_arg=$(command -v codex 2>/dev/null) || die66 "codex is not resolvable on PATH"

if [ -z "$jobdir" ]; then
  if [ -n "${CODEX_DELEGATE_JOBS:-}" ]; then
    has_line_delimiter "$CODEX_DELEGATE_JOBS" && die64 "job path must not contain CR or LF"
  else
    raw_tmpdir=${TMPDIR:-/tmp}
    has_line_delimiter "$raw_tmpdir" && die64 "job path must not contain CR or LF"
  fi
  jobbase=${CODEX_DELEGATE_JOBS:-${TMPDIR:-/tmp}/codex-delegate/jobs}
  jobbase=$(absolute_path "$jobbase")
  has_line_delimiter "$jobbase" && die64 "job path must not contain CR or LF"
  mkdir -p "$jobbase" || die66 "failed to create jobs base: $jobbase"
  jobdir=$(mktemp -d "$jobbase/job-XXXXXX") || die66 "failed to allocate job directory"
else
  has_line_delimiter "$jobdir" && die64 "job path must not contain CR or LF"
  if [ -e "$jobdir" ] || [ -L "$jobdir" ]; then
    [ -d "$jobdir" ] && [ ! -L "$jobdir" ] || die66 "supplied job path is not a directory"
    directory_is_empty "$jobdir" || die66 "supplied job directory is not empty"
  else
    parent=${jobdir%/*}
    [ -n "$parent" ] || parent=/
    mkdir -p "$parent" || die66 "failed to create job parent"
    if ! mkdir "$jobdir" 2>/dev/null; then
      [ -d "$jobdir" ] && [ ! -L "$jobdir" ] || die66 "failed to create job directory"
    fi
    directory_is_empty "$jobdir" || die66 "supplied job directory is not empty"
  fi
fi

mkdir "$jobdir/.claim" 2>/dev/null || die66 "job directory is already claimed"

if [ "$prompt_src" = "-" ]; then
  cat > "$jobdir/prompt.md" || die66 "failed to write prompt from stdin"
else
  cp "$prompt_src" "$jobdir/prompt.md" || die66 "failed to copy prompt file"
fi
[ -f "$jobdir/prompt.md" ] && [ -s "$jobdir/prompt.md" ] || die66 "prompt is empty"

events=$jobdir/events.jsonl
result=$jobdir/last-message.md
stderr_file=$jobdir/stderr.log
pid_file=$jobdir/codex.pid
status_file=$jobdir/status

owed=0
term_seen=0
on_term() {
  owed=$((owed + 1))
  term_seen=1
}
trap 'on_term' TERM

printf 'job-dir:      %s\nworkdir:      %s\nlast-message: %s\nevents:       %s\nstderr:       %s\nstatus:       %s\n' \
  "$jobdir" "$workdir" "$result" "$events" "$stderr_file" "$status_file" || \
  die66 "failed to write prelaunch announcement"

(
  /bin/sh -c '
pid_path=$2
delay=$3
if [ -n "$delay" ] && [ "$delay" != 0 ]; then sleep "$delay"; fi
pid_tmp=$pid_path.tmp.$$
printf "%s\n" "$$" > "$pid_tmp" || exit 126
mv "$pid_tmp" "$pid_path" || exit 126
if [ -n "$8" ]; then
  effort_arg=model_reasoning_effort=\"$8\"
  if [ -n "$7" ]; then
    exec -- "$1" exec -s "$4" -C "$5" --json -o "$6" -m "$7" -c "$effort_arg" -
  fi
  exec -- "$1" exec -s "$4" -C "$5" --json -o "$6" -c "$effort_arg" -
fi
if [ -n "$7" ]; then
  exec -- "$1" exec -s "$4" -C "$5" --json -o "$6" -m "$7" -
fi
exec -- "$1" exec -s "$4" -C "$5" --json -o "$6" -
' sh "$codex_arg" "$pid_file" "${CODEX_DELEGATE_TEST_PRE_PUBLISH_DELAY:-0}" \
    "$sandbox" "$workdir" "$result" "$model" "$effort" \
    < "$jobdir/prompt.md" > "$events" 2> "$stderr_file"
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

if [ -f "$status_file" ]; then
  final_status=$(sed -n '1p' "$status_file")
else
  final_status=$last_wait
  if [ "$term_seen" -eq 1 ]; then exit 143; fi
fi

session=$(sed -nE 's/.*"(session_id|thread_id)"[[:space:]]*:[[:space:]]*"([^"]+)".*/\2/p' "$events" 2>/dev/null | head -1)
[ -n "$session" ] && printf 'session-id:   %s\n' "$session"
printf 'exit:         %s\n' "$final_status"
exit "$final_status"
