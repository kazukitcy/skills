#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BACKEND_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
SHIM_DIR="$SCRIPT_DIR/shim"
ORIGINAL_TMPDIR=${TMPDIR:-/tmp}
failures=0
tests=0
workspace=""
tracked_pids=""

track_pid() { tracked_pids="$tracked_pids $1"; }

terminate_and_reap() {
  active_file=$(mktemp /tmp/codex-delegate-active-jobs.XXXXXX) || return 1
  jobs -pr > "$active_file"
  active=$(tr '\n' ' ' < "$active_file")
  rm -f "$active_file"
  roots=""
  for tracked in $tracked_pids; do
    case " $active " in *" $tracked "*) roots="$roots $tracked" ;; esac
  done
  for victim in $roots; do kill -TERM "$victim" 2>/dev/null || true; done
  for root in $roots; do wait "$root" 2>/dev/null || true; done
  tracked_pids=""
}

cleanup_files() {
  [ -n "$workspace" ] && [ -d "$workspace" ] && rm -rf "$workspace"
}

cleanup() {
  terminate_and_reap
  cleanup_files
}

on_signal() {
  signal=$1
  trap '' HUP TERM
  terminate_and_reap
  cleanup_files
  trap - EXIT
  case "$signal" in HUP) exit 129 ;; TERM) exit 143 ;; esac
}

trap 'cleanup' EXIT
trap 'on_signal HUP' HUP
trap 'on_signal TERM' TERM

pass() { tests=$((tests + 1)); printf 'PASS %s\n' "$1"; }
fail() { tests=$((tests + 1)); failures=$((failures + 1)); printf 'FAIL %s\n' "$1"; }
assert() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }

run_capture() {
  stdout="$workspace/stdout"
  stderr="$workspace/stderr"
  "$@" >"$stdout" 2>"$stderr"
  rc=$?
}

run_capture_deadline() {
  stdout="$workspace/stdout"
  stderr="$workspace/stderr"
  "$@" >"$stdout" 2>"$stderr" & deadline_bg=$!; track_pid "$deadline_bg"
  i=0
  while kill -0 "$deadline_bg" 2>/dev/null && [ "$i" -lt 20 ]; do
    sleep 0.1
    i=$((i + 1))
  done
  if kill -0 "$deadline_bg" 2>/dev/null; then
    kill -TERM "$deadline_bg" 2>/dev/null
    wait "$deadline_bg" 2>/dev/null
    rc=124
  else
    wait "$deadline_bg"
    rc=$?
  fi
}

dead_pid() {
  candidate=999999
  while kill -0 "$candidate" 2>/dev/null; do candidate=$((candidate - 1)); done
  printf '%s\n' "$candidate"
}

wait_for_file() {
  target=$1
  limit=${2:-50}
  i=0
  while [ ! -e "$target" ] && [ "$i" -lt "$limit" ]; do
    sleep 0.1
    i=$((i + 1))
  done
  [ -e "$target" ]
}

wait_for_lines() {
  target=$1
  wanted=$2
  limit=${3:-20}
  i=0
  count=0
  [ -f "$target" ] && count=$(wc -l < "$target")
  while [ "$count" -lt "$wanted" ] && [ "$i" -lt "$limit" ]; do
    sleep 0.1
    i=$((i + 1))
    count=0
    [ -f "$target" ] && count=$(wc -l < "$target")
  done
  [ "$count" -ge "$wanted" ]
}

stop_shim() {
  touch "$CODEX_SHIM_MARKERS/release" 2>/dev/null || true
  if [ -f "$CODEX_SHIM_MARKERS/shim-pid" ]; then
    victim=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
    kill -TERM "$victim" 2>/dev/null || true
  fi
}

make_prompt() {
  prompt="$workspace/prompt.md"
  printf '%s\n' 'test prompt' > "$prompt"
}

run_exec() {
  run_capture bash "$BACKEND_DIR/codex-exec-backend.sh" "$@"
}

claimed_resume_job() {
  job="$workspace/job"
  mkdir -p "$job/.claim"
  printf '%s\n' '{"type":"thread.started","thread_id":"shim-thread"}' > "$job/events.jsonl"
}

run_resume() {
  run_capture bash "$BACKEND_DIR/codex-resume-backend.sh" "$@"
}

complete_events() {
  printf '%s\n' '{"type":"turn.completed","usage":{}}' >> "$1"
}

reserve_attempt() {
  : > "$job/events-resume-$1.jsonl"
}

write_announcement() {
  printf 'job-dir:      %s\nlast-message: %s\nevents:       %s\nstderr:       %s\nstatus:       %s\n' \
    "$1" "$2" "$3" "$4" "$5" > "$6"
}

if [ -n "${CODEX_DELEGATE_SIGNAL_PROBE_DIR:-}" ]; then
  workspace="$CODEX_DELEGATE_SIGNAL_PROBE_DIR/inner-workspace"
  mkdir "$workspace" || exit 2
  sleep 30 & probe_sleeper=$!; track_pid "$probe_sleeper"
  bash -c 'child=""; stop() { [ -n "$child" ] && kill -TERM "$child" 2>/dev/null; [ -n "$child" ] && wait "$child" 2>/dev/null; exit 143; }; trap stop HUP TERM; sleep 30 & child=$!; printf "%s %s\n" "$$" "$child" > "$1"; wait "$child"' sh \
    "$CODEX_DELEGATE_SIGNAL_PROBE_DIR/pids" & probe_wrapper=$!; track_pid "$probe_wrapper"
  printf '%s %s\n' "$probe_wrapper" "$probe_sleeper" > "$CODEX_DELEGATE_SIGNAL_PROBE_DIR/ready"
  wait "$probe_wrapper"
  exit $?
fi

new_workspace() {
  cleanup
  export TMPDIR=$ORIGINAL_TMPDIR
  workspace=$(mktemp -d "${TMPDIR:-/tmp}/codex-delegate-tests.XXXXXX") || exit 2
  stdout="$workspace/stdout"
  stderr="$workspace/stderr"
  export CODEX_DELEGATE_JOBS="$workspace/jobs"
  export CODEX_SHIM_MARKERS="$workspace/markers"
  export CODEX_PS_LOG="$workspace/ps.log"
  export PATH="$SHIM_DIR:/usr/bin:/bin"
  /bin/mkdir -p "$CODEX_DELEGATE_JOBS" "$CODEX_SHIM_MARKERS"
  : > "$CODEX_PS_LOG"
  unset CODEX_DELEGATE_TEST_PRE_PUBLISH_DELAY CODEX_DELEGATE_TEST_SUPPRESS_STATUS
  unset CODEX_DELEGATE_TEST_POST_REAP_HOLD CODEX_MKDIR_RACE_PATH CODEX_MKDIR_LOG
  unset CODEX_PS_MODE CODEX_PS_COMM CODEX_MV_CORRUPT_DEST
  export CODEX_SHIM_MODE=complete
}

new_workspace
[ "$CODEX_DELEGATE_JOBS" = "$workspace/jobs" ] && [ -d "$CODEX_DELEGATE_JOBS" ] || exit 2
[ "$(command -v codex)" = "$SHIM_DIR/codex" ] || {
  printf 'FATAL test shim not first on PATH: %s\n' "$(command -v codex 2>/dev/null)" >&2
  exit 2
}

# M2: codex-wait-started.sh
WAIT="$BACKEND_DIR/codex-wait-started.sh"

new_workspace; job="$workspace/job"; mkdir "$job"
run_capture_deadline bash "$WAIT" "$job" nope
assert "1 non-numeric timeout exits 2" '[ "$rc" -eq 2 ]'

new_workspace; job="$workspace/job"; mkdir "$job"
run_capture_deadline bash "$WAIT" "$job" 0
assert "2 zero timeout exits 2" '[ "$rc" -eq 2 ]'

new_workspace; job="$workspace/job"; mkdir "$job"
run_capture_deadline bash "$WAIT" "$job" 01
assert "3 leading-zero timeout exits 2" '[ "$rc" -eq 2 ]'

new_workspace; job="$workspace/job"; mkdir "$job"
run_capture_deadline bash "$WAIT" "$job" 86401
assert "4 timeout above 86400 exits 2" '[ "$rc" -eq 2 ]'

new_workspace; job="$workspace/job"; mkdir "$job"
run_capture_deadline bash "$WAIT" "$job" 999999999999999999999999999999999999
assert "5 wraparound-sized timeout exits 2" '[ "$rc" -eq 2 ]'

new_workspace; job="$workspace/job"; mkdir "$job"; dead=$(dead_pid); printf '%s\n' "$dead" > "$job/codex.pid"
run_capture_deadline bash "$WAIT" "$job" 86400
assert "6 timeout 86400 is accepted and dead child exits 3" '[ "$rc" -eq 3 ]'

new_workspace
run_capture_deadline bash "$WAIT"
rc_missing=$rc
run_capture_deadline bash "$WAIT" a b c
rc_extra=$rc
assert "7 missing or extra arguments exit 2" '[ "$rc_missing" -eq 2 ] && [ "$rc_extra" -eq 2 ]'

new_workspace
run_capture_deadline bash "$WAIT" "$workspace/missing"
assert "8 nonexistent job directory exits 2" '[ "$rc" -eq 2 ]'

new_workspace; job="$workspace/job"; mkdir "$job"; printf '%s\n' "$$" > "$job/codex.pid"
CODEX_SHIM_MODE=complete codex exec --json -o "$job/last-message.md" - > "$job/events.jsonl" 2>/dev/null
run_capture bash "$WAIT" "$job" 2
assert "9 completed shim exits 0 and prints thread id" '[ "$rc" -eq 0 ] && grep -q shim-thread "$stdout"'

new_workspace; job="$workspace/job"; mkdir "$job"; printf '%s\n' "$$" > "$job/codex.pid"
CODEX_SHIM_MODE=no-session-exit codex exec --json -o "$job/last-message.md" - > "$job/events.jsonl" 2>/dev/null
dead=$(dead_pid); printf '%s\n' "$dead" > "$job/codex.pid"
run_capture bash "$WAIT" "$job" 2
assert "10 dead no-session shim exits 3" '[ "$rc" -eq 3 ]'

new_workspace; job="$workspace/job"; mkdir "$job"
CODEX_SHIM_MODE=no-session-hang codex exec --json -o "$job/last-message.md" - > "$job/events.jsonl" 2>/dev/null & shim_bg=$!; track_pid "$shim_bg"
printf '%s\n' "$shim_bg" > "$job/codex.pid"
i=0; while [ ! -e "$CODEX_SHIM_MARKERS/shim-started" ] && [ "$i" -lt 30 ]; do sleep 0.1; i=$((i + 1)); done
run_capture bash "$WAIT" "$job" 2
touch "$CODEX_SHIM_MARKERS/release"; wait "$shim_bg" 2>/dev/null
assert "11 live no-session shim times out with exit 1" '[ "$rc" -eq 1 ]'

# M3: codex-exec-backend.sh
EXEC="$BACKEND_DIR/codex-exec-backend.sh"

new_workspace; make_prompt; job="$workspace/job"; mkdir "$job"; printf x > "$job/existing"
run_exec -j "$job" "$prompt"
assert "12 non-empty supplied job is rejected before shim" '[ "$rc" -eq 66 ] && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; make_prompt; job="$workspace/unreadable"; mkdir "$job"; printf x > "$job/existing"; chmod 300 "$job"; run_exec -j "$job" "$prompt"; unreadable_rc=$rc; chmod 700 "$job"
assert "87 unreadable non-empty supplied job fails closed before shim" '[ "$unreadable_rc" -eq 66 ] && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; make_prompt; job="$workspace/job"; mkdir -p "$job/.claim"
run_exec -j "$job" "$prompt"
assert "13 pre-existing claim rejects supplied job" '[ "$rc" -eq 66 ] && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; make_prompt; job="$workspace/job"; mkdir "$job"
bash "$EXEC" -j "$job" "$prompt" >"$workspace/out1" 2>"$workspace/err1" & p1=$!; track_pid "$p1"
bash "$EXEC" -j "$job" "$prompt" >"$workspace/out2" 2>"$workspace/err2" & p2=$!; track_pid "$p2"
wait "$p1"; r1=$?; wait "$p2"; r2=$?
invoked=$(wc -l < "$CODEX_SHIM_MARKERS/shim-invoked" 2>/dev/null || printf 0)
assert "14 existing-job claim race has one winner" '( { [ "$r1" -eq 0 ] && [ "$r2" -eq 66 ]; } || { [ "$r1" -eq 66 ] && [ "$r2" -eq 0 ]; } ) && [ "$invoked" -eq 1 ]'

new_workspace; make_prompt; job="$workspace/missing/job"
bash "$EXEC" -j "$job" "$prompt" >"$workspace/out1" 2>"$workspace/err1" & p1=$!; track_pid "$p1"
bash "$EXEC" -j "$job" "$prompt" >"$workspace/out2" 2>"$workspace/err2" & p2=$!; track_pid "$p2"
wait "$p1"; r1=$?; wait "$p2"; r2=$?
invoked=$(wc -l < "$CODEX_SHIM_MARKERS/shim-invoked" 2>/dev/null || printf 0)
assert "15 nonexistent-job container race has one winner" '( { [ "$r1" -eq 0 ] && [ "$r2" -eq 66 ]; } || { [ "$r1" -eq 66 ] && [ "$r2" -eq 0 ]; } ) && [ "$invoked" -eq 1 ]'

new_workspace; run_exec - </dev/null
assert "16 empty stdin prompt exits 66 without paths" '[ "$rc" -eq 66 ] && ! grep -q '^job-dir:' "$stdout"'

new_workspace; make_prompt; run_exec -e 'high"x' "$prompt"
assert "17 invalid effort exits 64 before job creation" '[ "$rc" -eq 64 ] && [ -z "$(find "$CODEX_DELEGATE_JOBS" -mindepth 1 -print -quit)" ]'

new_workspace; make_prompt; run_exec -C "$workspace/missing" "$prompt"
assert "18 nonexistent workdir exits 64 before job creation" '[ "$rc" -eq 64 ] && [ -z "$(find "$CODEX_DELEGATE_JOBS" -mindepth 1 -print -quit)" ]'

new_workspace; make_prompt
PATH=/usr/bin:/bin command -v codex >/dev/null 2>&1; codex_found=$?
PATH=/usr/bin:/bin bash "$EXEC" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr"; rc=$?
assert "19 missing codex exits 66 with empty stdout" '[ "$codex_found" -ne 0 ] && [ "$rc" -eq 66 ] && [ ! -s "$workspace/stdout" ]'

new_workspace; make_prompt; run_exec "$prompt"; job=$(sed -n 's/^job-dir:[[:space:]]*//p' "$stdout"); sed -n '1,5p' "$stdout" > "$workspace/announcement"; write_announcement "$job" "$job/last-message.md" "$job/events.jsonl" "$job/stderr.log" "$job/status" "$workspace/expected-announcement"
shim_pid=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
assert "20 default complete publishes child pid status claim and exact announcement" '[ "$rc" -eq 0 ] && cmp -s "$workspace/announcement" "$workspace/expected-announcement" && [ -e "$CODEX_SHIM_MARKERS/pub-ok-$shim_pid" ] && [ "$(cat "$job/status" 2>/dev/null)" = 0 ] && [ -d "$job/.claim" ] && grep -q '^session-id:' "$stdout" && [ -s "$job/last-message.md" ]'

new_workspace; make_prompt; job="$workspace/job space'quote"; run_exec -j "$job" "$prompt"; shim_pid=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
assert "21 hostile supplied path preserves publication ordering" '[ "$rc" -eq 0 ] && [ -e "$CODEX_SHIM_MARKERS/pub-ok-$shim_pid" ]'

new_workspace; make_prompt; job="$workspace/closed-stdout"; bash "$EXEC" -j "$job" "$prompt" >&- 2>"$workspace/stderr"; closed_exec_rc=$?
assert "88 closed stdout refuses exec and resume before shim launch" '[ "$closed_exec_rc" -eq 66 ] && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; make_prompt; mkdir "$workspace/-bin"; ln -s "$SHIM_DIR/codex" "$workspace/-bin/codex"; job="$workspace/leading-command"; cd "$workspace" || exit 2; resolved=$(PATH="-bin:$SHIM_DIR:/usr/bin:/bin" command -v codex); PATH="-bin:$SHIM_DIR:/usr/bin:/bin" bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr"; rc=$?; cd - >/dev/null || exit 2
assert "89 inner exec accepts a resolved command path beginning with hyphen" '[ "$resolved" = "-bin/codex" ] && [ "$rc" -eq 0 ] && [ -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; make_prompt; job="$workspace/job"; export CODEX_SHIM_MODE=exit-127-on-term
bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"
wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 40; kill -TERM "$wrapper" 2>/dev/null; wait "$wrapper"; rc=$?
stop_shim
assert "22 TERM child status 127 is authoritative and reported" '[ "$rc" -eq 127 ] && [ "$(cat "$job/status" 2>/dev/null)" = 127 ] && grep -q '^exit:[[:space:]]*127$' "$workspace/stdout"'

new_workspace; make_prompt; job="$workspace/job"; export CODEX_SHIM_MODE=hang-ignore-term
bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"
wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 40
kill -TERM "$wrapper" 2>/dev/null; wait_for_lines "$CODEX_SHIM_MARKERS/term-ack" 1 20
kill -TERM "$wrapper" 2>/dev/null; wait_for_lines "$CODEX_SHIM_MARKERS/term-ack" 2 20
child=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
assert "23 two TERMs are forwarded without supervisor abandonment" 'kill -0 "$wrapper" 2>/dev/null && kill -0 "$child" 2>/dev/null && [ "$(wc -l < "$CODEX_SHIM_MARKERS/term-ack" 2>/dev/null)" -eq 2 ]'
touch "$CODEX_SHIM_MARKERS/release"; wait "$wrapper"; rc=$?
assert "24 release preserves child exit 23 in status and wrapper" '[ "$rc" -eq 23 ] && [ "$(cat "$job/status" 2>/dev/null)" = 23 ]'

new_workspace; make_prompt; job="$workspace/job"; export CODEX_SHIM_MODE=hang-with-session
bash -c 'set -m; p=""; stop() { [ -n "$p" ] && kill -TERM "-$p" 2>/dev/null; [ -n "$p" ] && wait "$p" 2>/dev/null; exit 143; }; trap stop HUP TERM; bash "$1" -j "$2" "$3" >"$4" 2>"$5" & p=$!; kill -0 "-$p" 2>/dev/null; group_ok=$?; printf "%s %s %s\n" "$p" "$p" "$group_ok" >"$6"; wait "$p"; printf "%s\n" "$?" >"$7"' sh "$EXEC" "$job" "$prompt" "$workspace/stdout" "$workspace/stderr" "$workspace/control" "$workspace/group-rc" & helper=$!; track_pid "$helper"
wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 50; read wrapper pgid group_ok < "$workspace/control"
mkdir -p "$job"; printf '%s\n' old > "$job/preexisting-evidence"
kill -TERM "-$pgid" 2>/dev/null; i=0; while kill -0 "$helper" 2>/dev/null && [ "$i" -lt 50 ]; do sleep 0.1; i=$((i + 1)); done; kill -TERM "$helper" 2>/dev/null || true; wait "$helper" 2>/dev/null
child=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null); group_rc=$(cat "$workspace/group-rc" 2>/dev/null); write_announcement "$job" "$job/last-message.md" "$job/events.jsonl" "$job/stderr.log" "$job/status" "$workspace/expected-announcement"; group_announcement_exact=0; cmp -s "$workspace/stdout" "$workspace/expected-announcement" && group_announcement_exact=1
assert "25 whole process-group TERM kills child and recorder only" '[ "$group_ok" -eq 0 ] && ! kill -0 "$child" 2>/dev/null && [ ! -e "$job/status" ] && [ "$(cat "$job/preexisting-evidence")" = old ]'

new_workspace; make_prompt; job="$workspace/raced"; export CODEX_MKDIR_RACE_PATH="$job"; run_exec -j "$job" "$prompt"
assert "44 container EEXIST race falls through to claim" '[ "$rc" -eq 0 ] && [ -d "$job/.claim" ]'

new_workspace; parent="$workspace/parent"; mkdir "$parent"; printf '%s\n' prompt > "$parent/-prompt"; cd "$parent" || exit 2; job="job\$value"; run_exec -j "$job" -- -prompt; cd - >/dev/null || exit 2; shim_pid=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
assert "45 leading-hyphen prompt and dollar job path are normalized" '[ "$rc" -eq 0 ] && [ -e "$CODEX_SHIM_MARKERS/pub-ok-$shim_pid" ]'

new_workspace; make_prompt; job="$workspace/job"; export CODEX_SHIM_MODE=hang-with-session CODEX_DELEGATE_TEST_PRE_PUBLISH_DELAY=12
bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; sleep 1; kill -TERM "$wrapper" 2>/dev/null
wait_for_file "$job/codex.pid" 140; i=0; while kill -0 "$wrapper" 2>/dev/null && [ "$i" -lt 50 ]; do sleep 0.1; i=$((i + 1)); done; stop_shim; wait "$wrapper" 2>/dev/null; child=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
assert "47 pre-publication TERM remains owed and warns after 10 seconds" 'grep -q "waiting for codex.pid" "$workspace/stderr" && [ -f "$job/codex.pid" ] && ! kill -0 "$child" 2>/dev/null'

new_workspace; make_prompt; job="$workspace/job"; export CODEX_SHIM_MODE=complete-exit-67 CODEX_DELEGATE_TEST_SUPPRESS_STATUS=1; run_exec -j "$job" "$prompt"
assert "52 missing status without TERM uses last-wait fallback" '[ "$rc" -eq 67 ] && [ ! -e "$job/status" ] && grep -q '^exit:[[:space:]]*67$' "$stdout"'

new_workspace; make_prompt; run_exec -s bogus "$prompt"
assert "62 invalid sandbox exits 64 with stderr-only diagnostic" '[ "$rc" -eq 64 ] && [ ! -s "$stdout" ] && grep -q -- '-s' "$stderr"'

assert "66 group TERM is byte-exact announcement-only and exits 143" '[ "${group_rc:-}" = 143 ] && [ "${group_announcement_exact:-0}" -eq 1 ]'

new_workspace; make_prompt; lf_job="$workspace/line
refused: injected"; run_exec -j "$lf_job" "$prompt"; lf_rc=$rc; lf_empty=$([ ! -s "$stdout" ]; echo $?)
cr_job="$workspace/carriage$(printf '\r')return"; run_exec -j "$cr_job" "$prompt"; cr_rc=$rc
trailing_lf_job="$workspace/trailing-lf
"; run_exec -j "$trailing_lf_job" "$prompt"; trailing_lf_rc=$rc
exec68_ok=0; [ "$lf_rc" -eq 64 ] && [ "$cr_rc" -eq 64 ] && [ "$trailing_lf_rc" -eq 64 ] && [ "$lf_empty" -eq 0 ] && exec68_ok=1

new_workspace; make_prompt; marker1="$workspace/eval-one"; marker2="$workspace/eval-two"; hostile=$'x\'; touch eval-one; $(touch eval-two) spaced'; printf -v hostile_q '%q' "$hostile"; cd "$workspace" || exit 2; run_exec -m "$hostile" "$prompt"; cd - >/dev/null || exit 2; shim_pid=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
assert "69 hostile model arrives at exact argv index and value" '[ "$rc" -eq 0 ] && [ ! -e "$marker1" ] && [ ! -e "$marker2" ] && [ "$(sed -n "1p" "$CODEX_SHIM_MARKERS/shim-argv")" = "argc=11" ] && [ "$(sed -n "10p" "$CODEX_SHIM_MARKERS/shim-argv")" = "argv[8]=-m" ] && [ "$(sed -n "11p" "$CODEX_SHIM_MARKERS/shim-argv")" = "argv[9]=$hostile_q" ] && [ -e "$CODEX_SHIM_MARKERS/pub-ok-$shim_pid" ]'

new_workspace; make_prompt; marker="$workspace/trap-eval"; job="$workspace/job'; touch $marker; '"; export CODEX_SHIM_MODE=hang-with-session
bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 40; kill -TERM "$wrapper" 2>/dev/null; wait "$wrapper" 2>/dev/null; stop_shim
assert "72 hostile job path is not evaluated by TERM trap" '[ ! -e "$marker" ] && [ -f "$job/status" ]'

new_workspace; make_prompt; badbase="$workspace/jobs
injected"; export CODEX_DELEGATE_JOBS="$badbase"; run_exec "$prompt"
embedded_lf_rc=$rc; trailing_badbase="$workspace/trailing-base
"; export CODEX_DELEGATE_JOBS="$trailing_badbase"; run_exec "$prompt"; trailing_lf_rc=$rc
assert "74 LF in CODEX_DELEGATE_JOBS is rejected raw before creation" '[ "$embedded_lf_rc" -eq 64 ] && [ "$trailing_lf_rc" -eq 64 ] && [ ! -e "$badbase" ] && [ ! -e "$trailing_badbase" ] && [ ! -s "$stdout" ]'

new_workspace; make_prompt; job="$workspace/job"; export CODEX_DELEGATE_TEST_POST_REAP_HOLD=3; bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$job/status" 50; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; kill -TERM "$wrapper" 2>/dev/null; wait "$wrapper"; rc=$?; protected_alive=0; kill -0 "$protected" 2>/dev/null && protected_alive=1; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
exec79_ok=0; [ "$rc" -eq 0 ] && [ "$protected_alive" -eq 1 ] && grep -q '^exit:[[:space:]]*0$' "$workspace/stdout" && exec79_ok=1

new_workspace; make_prompt; job="$workspace/job"; export CODEX_SHIM_MODE=hang-ignore-term; bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 40; kill -TERM "$wrapper" 2>/dev/null; a1=0; wait_for_lines "$CODEX_SHIM_MARKERS/term-ack" 1 20 && a1=1; kill -TERM "$wrapper" 2>/dev/null; a2=0; wait_for_lines "$CODEX_SHIM_MARKERS/term-ack" 2 20 && a2=1; sleep 1.5; count=$(wc -l < "$CODEX_SHIM_MARKERS/term-ack" 2>/dev/null); touch "$CODEX_SHIM_MARKERS/release"; wait "$wrapper" 2>/dev/null
exec82_ok=0; [ "$a1" -eq 1 ] && [ "$a2" -eq 1 ] && [ "$count" -eq 2 ] && exec82_ok=1

new_workspace; make_prompt; job="$workspace/job"; export CODEX_SHIM_MODE=hang-with-session; bash "$EXEC" -j "$job" "$prompt" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 40; real_child=$(cat "$CODEX_SHIM_MARKERS/shim-pid"); dead=$(dead_pid); printf '%s\n' "$dead" > "$job/codex.pid"; kill -TERM "$wrapper" 2>/dev/null; sleep 0.5; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; sleep 1.5; protected_alive=0; kill -0 "$protected" 2>/dev/null && protected_alive=1; real_alive=0; kill -0 "$real_child" 2>/dev/null && real_alive=1; touch "$CODEX_SHIM_MARKERS/release"; wait "$wrapper"; rc=$?; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
exec83_ok=0; [ "$protected_alive" -eq 1 ] && [ "$real_alive" -eq 1 ] && [ "$rc" -eq 0 ] && [ "$(cat "$job/status" 2>/dev/null)" = 0 ] && exec83_ok=1

new_workspace; make_prompt; job="$workspace/job"; export CODEX_PS_MODE=success; run_exec -j "$job" "$prompt"
exec84_ok=0; [ "$rc" -eq 0 ] && [ ! -s "$CODEX_PS_LOG" ] && exec84_ok=1

new_workspace; make_prompt; unset CODEX_DELEGATE_JOBS; export TMPDIR="$workspace/tmp space"; mkdir "$TMPDIR"; run_exec "$prompt"; tmp_job=$(sed -n 's/^job-dir:[[:space:]]*//p' "$stdout"); mid_ok=0; case "$tmp_job" in "$TMPDIR/codex-delegate/jobs/"*) mid_ok=1;; esac
export TMPDIR="$workspace/tmp
bad"; run_exec "$prompt"; lf_rc=$rc
export TMPDIR="$workspace/trailing-tmp
"; run_exec "$prompt"; trailing_tmp_rc=$rc
export CODEX_DELEGATE_JOBS="$workspace/override" TMPDIR="$workspace/other"; mkdir "$TMPDIR"; run_exec "$prompt"; override_job=$(sed -n 's/^job-dir:[[:space:]]*//p' "$stdout"); override_ok=0; case "$override_job" in "$CODEX_DELEGATE_JOBS/"*) override_ok=1;; esac
assert "86 jobs base honors raw TMPDIR validation and override precedence" '[ "$mid_ok" -eq 1 ] && [ "$lf_rc" -eq 64 ] && [ "$trailing_tmp_rc" -eq 64 ] && [ "$override_ok" -eq 1 ]'

# M4: codex-resume-backend.sh
RESUME="$BACKEND_DIR/codex-resume-backend.sh"

new_workspace; claimed_resume_job; mkdir "$job/resume.lock"; printf '%s\n' "$$" > "$job/resume.lock/pid"; run_resume "$job"
assert "26 live resume lock refuses without removal" '[ "$rc" -eq 65 ] && grep -q "refused: lock-held" "$stdout" && [ -d "$job/resume.lock" ]'

new_workspace; claimed_resume_job; mkdir "$job/resume.lock"; dead=$(dead_pid); printf '%s\n' "$dead" > "$job/resume.lock/pid"; run_resume "$job"
assert "27 dead resume lock refuses stale without removal" '[ "$rc" -eq 65 ] && grep -q "refused: stale-lock" "$stdout" && [ -d "$job/resume.lock" ]'

new_workspace; claimed_resume_job; mkdir "$job/resume.lock"; run_resume "$job"
assert "28 pid-less resume lock refuses stale" '[ "$rc" -eq 65 ] && grep -q "refused: stale-lock" "$stdout" && [ -d "$job/resume.lock" ]'

new_workspace; claimed_resume_job; mkdir "$job/resume.lock"; printf nope > "$job/resume.lock/pid"; run_resume "$job"
assert "29 malformed resume lock refuses stale" '[ "$rc" -eq 65 ] && grep -q "refused: stale-lock" "$stdout" && [ -d "$job/resume.lock" ]'

new_workspace; claimed_resume_job; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; export CODEX_PS_MODE=success CODEX_PS_COMM=codex; before=$(wc -l < "$CODEX_SHIM_MARKERS/shim-invoked" 2>/dev/null || printf 0); run_resume "$job"; after=$(wc -l < "$CODEX_SHIM_MARKERS/shim-invoked" 2>/dev/null || printf 0); kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
assert "30 live codex pid refuses without launching" '[ "$rc" -eq 65 ] && grep -q "refused: live-process" "$stdout" && [ "$before" -eq "$after" ]'

new_workspace; claimed_resume_job; reserve_attempt 1; reserve_attempt 2; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; export CODEX_PS_MODE=success CODEX_PS_COMM=codex; run_resume "$job"; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
assert "31 live process refusal precedes cap" '[ "$rc" -eq 65 ] && grep -q "refused: live-process" "$stdout" && ! grep -q "cap-reached" "$stdout"'

new_workspace; claimed_resume_job; old=$(dead_pid); printf '%s\n' "$old" > "$job/codex.pid"; run_resume "$job"; newpid=$(cat "$job/codex.pid" 2>/dev/null)
assert "32 dead pid archives old pointer before new publication" '[ "$rc" -eq 0 ] && [ "$(cat "$job/codex.pid.stale-1" 2>/dev/null)" = "$old" ] && [ "$newpid" = "$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)" ]'

new_workspace; claimed_resume_job; complete_events "$job/events.jsonl"; printf result > "$job/last-message.md"; run_resume "$job"
assert "33 whole original events file is scanned for completion" '[ "$rc" -eq 0 ] && grep -q "already-completed: $job/last-message.md" "$stdout"'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; printf one > "$job/last-message-resume-1.md"; reserve_attempt 2; run_resume "$job"
assert "34 recovery skips empty newest reservation" '[ "$rc" -eq 0 ] && grep -q "recovered-from:.*last-message-resume-1.md" "$stdout"'

new_workspace; claimed_resume_job; printf stale > "$job/last-message.md"; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; printf recovered > "$job/last-message-resume-1.md"; run_resume "$job"
assert "35 complete numbered pair promotes without status" '[ "$rc" -eq 0 ] && cmp -s "$job/last-message.md" "$job/last-message-resume-1.md"'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"nothing"}' > "$job/events.jsonl"; run_resume "$job"
assert "36 missing session refuses no-session" '[ "$rc" -eq 65 ] && grep -q "refused: no-session" "$stdout"'

new_workspace; claimed_resume_job; reserve_attempt 1; reserve_attempt 2; run_resume "$job"
assert "37 two reservations refuse cap-reached" '[ "$rc" -eq 65 ] && grep -q "refused: cap-reached" "$stdout"'

new_workspace; claimed_resume_job; reserve_attempt 1; run_resume "$job"
assert "38 empty reservation is consumed and attempt two launches" '[ "$rc" -eq 0 ] && grep -q "events:.*events-resume-2.jsonl" "$stdout"'

new_workspace; claimed_resume_job; printf original > "$job/last-message.md"; run_resume "$job"; expected=$(printf 'job-dir:      %s\nlast-message: %s/last-message-resume-1.md\nevents:       %s/events-resume-1.jsonl\nstderr:       %s/stderr-resume-1.log\nstatus:       %s/status-resume-1\npromoted:     %s/last-message.md\nexit:         0' "$job" "$job" "$job" "$job" "$job" "$job")
shim_pid=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null)
assert "39 complete resume emits exact two-phase promoted schema" '[ "$rc" -eq 0 ] && [ "$(cat "$stdout")" = "$expected" ] && cmp -s "$job/last-message.md" "$job/last-message-resume-1.md" && [ "$(cat "$job/status-resume-1")" = 0 ] && [ -e "$CODEX_SHIM_MARKERS/pub-ok-$shim_pid" ]'

new_workspace; claimed_resume_job; printf original > "$job/last-message.md"; export CODEX_SHIM_MODE=die-early; run_resume "$job"
assert "40 incomplete resume stays unpromoted and preserves canonical" '[ "$rc" -eq 1 ] && grep -q "unpromoted:.*incomplete-evidence" "$stdout" && [ "$(cat "$job/last-message.md")" = original ]'

new_workspace; claimed_resume_job; printf original > "$job/last-message.md"; export CODEX_SHIM_MODE=result-no-event; run_resume "$job"
assert "41 result without same-attempt event is not promoted" '[ "$rc" -eq 0 ] && grep -q "unpromoted:.*incomplete-evidence" "$stdout" && [ "$(cat "$job/last-message.md")" = original ]'

new_workspace; claimed_resume_job; export CODEX_SHIM_MODE=complete-exit-67; run_resume "$job"
assert "42 genuine child 67 still promotes completed pair" '[ "$rc" -eq 67 ] && [ "$(cat "$job/status-resume-1")" = 67 ] && grep -q '^promoted:' "$stdout" && ! grep -q '^promotion-failed:' "$stdout"'

new_workspace; claimed_resume_job; mkdir "$job/last-message.md"; export CODEX_SHIM_MODE=complete; run_resume "$job"
assert "43 canonical directory causes guarded promotion failure" '[ "$rc" -eq 67 ] && grep -q '^promotion-failed:' "$stdout" && [ -s "$job/last-message-resume-1.md" ] && [ ! -e "$job/last-message.md/.promote.tmp" ]'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; printf numbered > "$job/last-message-resume-1.md"; export CODEX_MV_CORRUPT_DEST="$job/last-message.md"; run_resume "$job"
assert "90 post-move verification failure preserves numbered result" '[ "$rc" -eq 67 ] && [ -s "$job/last-message-resume-1.md" ] && [ -d "$job/last-message.md" ] && grep -q "^promotion-failed:" "$stdout"'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; printf recovered > "$job/last-message-resume-1.md"; run_resume "$job"
assert "46 completed numbered pair needs no status file" '[ "$rc" -eq 0 ] && grep -q '^already-completed:' "$stdout" && grep -q '^recovered-from:' "$stdout"'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; printf one > "$job/last-message-resume-1.md"; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-2.jsonl"; printf two > "$job/last-message-resume-2.md"; run_resume "$job"
assert "48 newest complete pair is selected" '[ "$rc" -eq 0 ] && [ "$(cat "$job/last-message.md")" = two ] && grep -q 'recovered-from:.*resume-2' "$stdout"'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; : > "$job/last-message-resume-1.md"; reserve_attempt 2; dead=$(dead_pid); printf '%s\n' "$dead" > "$job/codex.pid"; run_resume "$job"
assert "49 cross-attempt evidence is rejected at cap" '[ "$rc" -eq 65 ] && grep -q cap-reached "$stdout" && ! grep -q already-completed "$stdout"'

new_workspace; claimed_resume_job; PATH=/usr/bin:/bin command -v codex >/dev/null 2>&1; codex_found=$?; PATH=/usr/bin:/bin bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr"; rc=$?
assert "50 missing codex preflight does not consume reservation" '[ "$codex_found" -ne 0 ] && [ "$rc" -eq 66 ] && [ ! -s "$stdout" ] && grep -q codex "$stderr" && [ ! -e "$job/events-resume-1.jsonl" ]'

new_workspace; claimed_resume_job; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; token="$wrapper 1"; i=0; while [ "$(cat "$job/grace-began" 2>/dev/null)" != "$token" ] && [ "$i" -lt 80 ]; do sleep 0.1; i=$((i + 1)); done; complete_events "$job/events.jsonl"; printf done > "$job/last-message.md"; wait "$wrapper"; rc=$?; expected=$(printf 'job-dir:      %s\nalready-completed: %s/last-message.md\nevents:       %s/events.jsonl' "$job" "$job" "$job"); grace51_rc=$rc; grace51_exact=0; [ "$(cat "$stdout")" = "$expected" ] && grace51_exact=1; grace51_launched=0; [ -e "$CODEX_SHIM_MARKERS/shim-invoked" ] && grace51_launched=1
assert "51 grace rerun detects completion before launch" '[ "$grace51_rc" -eq 0 ] && [ "$grace51_exact" -eq 1 ] && [ "$grace51_launched" -eq 0 ]'

new_workspace; claimed_resume_job; export CODEX_SHIM_MODE=hang-with-session CODEX_DELEGATE_TEST_PRE_PUBLISH_DELAY=12; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; i=0; while ! grep -q '^status:' "$workspace/stdout" 2>/dev/null && [ "$i" -lt 90 ]; do sleep 0.1; i=$((i + 1)); done; kill -TERM "$wrapper" 2>/dev/null; wait_for_file "$job/codex.pid" 140; wait "$wrapper"; rc=$?; child=$(cat "$CODEX_SHIM_MARKERS/shim-pid" 2>/dev/null); stop_shim
assert "53 resume prepublication TERM remains owed and reports recorded status" 'grep -q "waiting for codex.pid" "$workspace/stderr" && ! kill -0 "$child" 2>/dev/null && [ -f "$job/status-resume-1" ] && grep -q '^unpromoted:' "$workspace/stdout" && grep -q '^exit:' "$workspace/stdout"'

new_workspace; claimed_resume_job; export CODEX_SHIM_MODE=exit-127-on-term; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 90; kill -TERM "$wrapper" 2>/dev/null; wait "$wrapper"; rc=$?; shim_pid=$(cat "$CODEX_SHIM_MARKERS/shim-pid")
assert "54 resume recorded 127 is authoritative after TERM" '[ "$rc" -eq 127 ] && [ "$(cat "$job/status-resume-1")" = 127 ] && grep -q '^exit:[[:space:]]*127$' "$workspace/stdout" && [ -e "$CODEX_SHIM_MARKERS/pub-ok-$shim_pid" ]'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; printf recovered > "$job/last-message-resume-1.md"; mkdir "$job/last-message.md"; run_resume "$job"; expected=$(printf 'job-dir:      %s\nrecovered-from: %s/last-message-resume-1.md\npromotion-failed: %s/last-message.md\nevents:       %s/events-resume-1.jsonl' "$job" "$job" "$job" "$job")
assert "55 recovery promotion failure emits exact one-phase block" '[ "$rc" -eq 67 ] && [ "$(cat "$stdout")" = "$expected" ] && [ -s "$job/last-message-resume-1.md" ] && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; parent="$workspace/parent"; mkdir "$parent"; job="$parent/-job"; mkdir -p "$job/.claim"; printf '%s\n' '{"type":"thread.started","thread_id":"shim-thread"}' > "$job/events.jsonl"; printf follow > "$parent/-followup"; cd "$parent" || exit 2; run_resume -f -followup -- -job; cd - >/dev/null || exit 2
assert "56 leading-hyphen resume paths normalize and stage exact followup" '[ "$rc" -eq 0 ] && [ "$(cat "$job/followup-1.md")" = follow ]'

new_workspace; claimed_resume_job; printf used > "$job/events-resume-1.jsonl"; old=$(dead_pid); printf '%s\n' "$old" > "$job/codex.pid"; run_resume "$job"
assert "57 attempt two archives stale pid on independent K sequence" '[ "$rc" -eq 0 ] && [ "$(cat "$job/codex.pid.stale-1")" = "$old" ] && grep -q 'events-resume-2.jsonl' "$stdout"'

new_workspace; claimed_resume_job; export CODEX_SHIM_MODE=complete-exit-67 CODEX_DELEGATE_TEST_SUPPRESS_STATUS=1; run_resume "$job"
assert "58 resume missing status uses child 67 fallback and promotes" '[ "$rc" -eq 67 ] && [ ! -e "$job/status-resume-1" ] && cmp -s "$job/last-message.md" "$job/last-message-resume-1.md" && grep -q '^promoted:' "$stdout"'

new_workspace; claimed_resume_job; reserve_attempt 1; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; token="$wrapper 2"; i=0; while [ "$(cat "$job/grace-began" 2>/dev/null)" != "$token" ] && [ "$i" -lt 80 ]; do sleep 0.1; i=$((i + 1)); done; complete_events "$job/events.jsonl"; printf done > "$job/last-message.md"; wait "$wrapper"; rc=$?
assert "59 attempt-two grace token belongs to current invocation" '[ "$rc" -eq 0 ] && [ "$(cat "$job/grace-began")" = "$token" ] && grep -q '^already-completed:' "$workspace/stdout" && ! grep -q '^status:' "$workspace/stdout" && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; claimed_resume_job; export CODEX_PS_MODE=success CODEX_PS_COMM=codex; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; token="$wrapper 1"; i=0; while [ "$(cat "$job/grace-began" 2>/dev/null)" != "$token" ] && [ "$i" -lt 80 ]; do sleep 0.1; i=$((i + 1)); done; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; wait "$wrapper"; rc=$?; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null; expected=$(printf 'job-dir:      %s\nrefused: live-process' "$job")
assert "60 pid published during grace causes exact live refusal" '[ "$rc" -eq 65 ] && [ "$(cat "$stdout")" = "$expected" ] && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; claimed_resume_job; printf '%s\n' '{"type":"turn.completed"}' > "$job/events.jsonl"; mkdir "$job/last-message.md"; run_resume "$job"
assert "61 canonical directory is not completion evidence" '[ "$rc" -eq 65 ] && grep -q no-session "$stdout" && ! grep -q already-completed "$stdout"'

new_workspace; run_resume; usage_rc=$rc; usage_empty=0; [ ! -s "$stdout" ] && usage_empty=1; claimed_resume_job; rm "$job/events.jsonl"; run_resume "$job"; missing_rc=$rc
assert "63 resume usage and missing-events diagnostics are stderr-only" '[ "$usage_rc" -eq 64 ] && [ "$usage_empty" -eq 1 ] && [ "$missing_rc" -eq 66 ] && [ ! -s "$stdout" ] && grep -q events.jsonl "$stderr"'

new_workspace; claimed_resume_job; run_resume -f "$workspace/missing-followup" "$job"
assert "64 followup staging failure consumes empty reservation" '[ "$rc" -eq 66 ] && [ ! -s "$stdout" ] && [ -f "$job/events-resume-1.jsonl" ] && [ ! -s "$job/events-resume-1.jsonl" ]'

new_workspace; claimed_resume_job; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; export CODEX_PS_MODE=success CODEX_PS_COMM=codex; run_resume "$job"; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null; expected=$(printf 'job-dir:      %s\nrefused: live-process' "$job")
assert "65 refusal stdout is exactly job-dir plus reason" '[ "$rc" -eq 65 ] && [ "$(cat "$stdout")" = "$expected" ]'

new_workspace; claimed_resume_job; target="$workspace/target"; printf external > "$target"; ln -s "$target" "$job/last-message.md"; complete_events "$job/events.jsonl"; reserve_attempt 1; reserve_attempt 2; run_resume "$job"; a=$rc; original_ok=0; [ "$(cat "$target")" = external ] && original_ok=1; rm "$job/last-message.md"; printf canon > "$job/last-message.md"; printf '%s\n' '{"type":"thread.started","thread_id":"shim-thread"}' > "$job/events.jsonl"; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; ln -s "$target" "$job/last-message-resume-1.md"; run_resume "$job"; b=$rc
assert "67 symlinked result halves are never completion evidence" '[ "$a" -eq 65 ] && [ "$b" -eq 65 ] && [ "$original_ok" -eq 1 ] && [ "$(cat "$job/last-message.md")" = canon ]'

new_workspace; claimed_resume_job; base=$job; lf="$base
refused: injected"; mv "$job" "$lf"; run_resume "$lf"; lf_rc=$rc; mv "$lf" "$base"; cr="$base$(printf '\r')x"; mv "$base" "$cr"; run_resume "$cr"; cr_rc=$rc
mv "$cr" "$base"; trailing="$base
"; mv "$base" "$trailing"; run_resume "$trailing"; trailing_rc=$rc
assert "68 exec and resume reject raw LF and CR job paths" '[ "$exec68_ok" -eq 1 ] && [ "$lf_rc" -eq 64 ] && [ "$cr_rc" -eq 64 ] && [ "$trailing_rc" -eq 64 ] && [ ! -s "$stdout" ] && [ ! -e "$trailing/resume.lock" ]'

assert "70 grace completion emits no partial announcement" '[ "$grace51_rc" -eq 0 ] && [ "$grace51_exact" -eq 1 ] && [ "$grace51_launched" -eq 0 ]'

new_workspace; claimed_resume_job; target="$workspace/target"; printf external > "$target"; ln -s "$target" "$job/last-message.md"; printf '%s\n' '{"type":"turn.completed"}' > "$job/events-resume-1.jsonl"; printf recovered > "$job/last-message-resume-1.md"; run_resume "$job"; a=$rc; target_ok=0; [ "$(cat "$target")" = external ] && target_ok=1; rm "$job/last-message.md"; planted="$job/.promote.tmp"; ln -s "$target" "$planted"; run_resume "$job"; b=$rc
assert "71 promotion guards canonical symlink and uses exclusive staging" '[ "$a" -eq 67 ] && [ "$target_ok" -eq 1 ] && [ "$b" -eq 0 ] && [ -L "$planted" ] && [ "$(cat "$target")" = external ]'

new_workspace; job="$workspace/job'\$value"; mkdir -p "$job/.claim"; printf '%s\n' '{"type":"thread.started","thread_id":"shim-thread"}' > "$job/events.jsonl"; run_resume "$job"
assert "73 hostile resume path does not break EXIT lock cleanup" '[ "$rc" -eq 0 ] && [ ! -e "$job/resume.lock" ]'

new_workspace; job="$workspace/job"; mkdir "$job"; printf x > "$job/events.jsonl"; run_resume "$job"; a=$rc; no_lock=0; [ ! -e "$job/resume.lock" ] && no_lock=1; mkdir "$job/.real-claim"; ln -s "$job/.real-claim" "$job/.claim"; run_resume "$job"; b=$rc
assert "75 missing or symlinked claim rejects lineage before lock" '[ "$a" -eq 66 ] && [ "$b" -eq 66 ] && [ "$no_lock" -eq 1 ] && [ ! -e "$job/events-resume-1.jsonl" ]'

new_workspace; claimed_resume_job; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; export CODEX_PS_MODE=success CODEX_PS_COMM=/bin/sh; run_resume "$job"; a=$rc; sh_live=0; grep -q live-process "$stdout" && sh_live=1; export CODEX_PS_COMM=/usr/bin/unrelated; printf '%s\n' "$protected" > "$job/codex.pid"; printf '%s\n' '{"type":"none"}' > "$job/events.jsonl"; run_resume "$job"; b=$rc; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
assert "76 pre-exec sh is live while unrelated comm is archived" '[ "$a" -eq 65 ] && [ "$sh_live" -eq 1 ] && [ "$b" -eq 65 ] && grep -q no-session "$stdout" && [ -f "$job/codex.pid.stale-1" ]'

new_workspace; job="$workspace/job"; mkdir -p "$job/.claim"; external="$workspace/external-events"; printf '%s\n' '{"type":"thread.started","thread_id":"other"}' '{"type":"turn.completed"}' > "$external"; ln -s "$external" "$job/events.jsonl"; printf local > "$job/last-message.md"; export CODEX_MKDIR_LOG="$workspace/mkdir.log"; run_resume "$job"; a=$rc; no_lock_attempt=0; { [ ! -e "$CODEX_MKDIR_LOG" ] || ! grep -q resume.lock "$CODEX_MKDIR_LOG"; } && no_lock_attempt=1; rm "$job/events.jsonl"; printf '%s\n' '{"type":"thread.started","thread_id":"shim-thread"}' > "$job/events.jsonl"; ln -s "$external" "$job/events-resume-1.jsonl"; printf numbered > "$job/last-message-resume-1.md"; reserve_attempt 2; run_resume "$job"; b=$rc
assert "77 symlinked events are invalid lineage or ignored evidence" '[ "$a" -eq 66 ] && [ "$no_lock_attempt" -eq 1 ] && [ "$b" -eq 65 ] && ! grep -q already-completed "$stdout"'

new_workspace; claimed_resume_job; export CODEX_SHIM_MODE=hang-with-session CODEX_DELEGATE_TEST_POST_REAP_HOLD=3; bash -c 'set -m; p=""; stop() { [ -n "$p" ] && kill -TERM "-$p" 2>/dev/null; [ -n "$p" ] && wait "$p" 2>/dev/null; exit 143; }; trap stop HUP TERM; bash "$1" "$2" >"$3" 2>"$4" & p=$!; kill -0 "-$p" 2>/dev/null; ok=$?; printf "%s %s\n" "$p" "$ok" >"$5"; wait "$p"; printf "%s\n" "$?" >"$6"' sh "$RESUME" "$job" "$workspace/stdout" "$workspace/stderr" "$workspace/control" "$workspace/group-rc" & helper=$!; track_pid "$helper"; i=0; while ! grep -q '^status:' "$workspace/stdout" 2>/dev/null && [ "$i" -lt 90 ]; do sleep 0.1; i=$((i + 1)); done; read wrapper group_ok < "$workspace/control"; kill -TERM "-$wrapper" 2>/dev/null; sleep 0.2; survived=0; kill -0 "$wrapper" 2>/dev/null && survived=1; wait "$helper" 2>/dev/null; group_rc=$(cat "$workspace/group-rc"); child=$(cat "$CODEX_SHIM_MARKERS/shim-pid")
assert "78 resume group TERM is silent 143 with no survivors" '[ "$group_ok" -eq 0 ] && [ "$survived" -eq 1 ] && [ "$group_rc" -eq 143 ] && ! kill -0 "$child" 2>/dev/null && [ ! -e "$job/status-resume-1" ] && ! grep -q '^exit:' "$workspace/stdout"'

new_workspace; claimed_resume_job; export CODEX_DELEGATE_TEST_POST_REAP_HOLD=3; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$job/status-resume-1" 90; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; kill -TERM "$wrapper" 2>/dev/null; wait "$wrapper"; rc=$?; alive=0; kill -0 "$protected" 2>/dev/null && alive=1; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
assert "79 exec and resume post-reap TERM never reach reused pid" '[ "$exec79_ok" -eq 1 ] && [ "$rc" -eq 0 ] && [ "$alive" -eq 1 ] && grep -q '^exit:[[:space:]]*0$' "$workspace/stdout"'

new_workspace; claimed_resume_job; target="$workspace/dangling-target"; ln -s "$target" "$job/events-resume-1.jsonl"; run_resume "$job"
assert "80 dangling reservation is consumed without create-through" '[ "$rc" -eq 0 ] && grep -q 'events-resume-2.jsonl' "$stdout" && [ -L "$job/events-resume-1.jsonl" ] && [ ! -e "$target" ]'

new_workspace; claimed_resume_job; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; export CODEX_PS_MODE=fail; run_resume "$job"; a=$rc; fail_live=0; grep -q live-process "$stdout" && fail_live=1; export CODEX_PS_MODE=empty; run_resume "$job"; b=$rc; empty_live=0; grep -q live-process "$stdout" && empty_live=1; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null; dead=$(dead_pid); printf '%s\n' "$dead" > "$job/codex.pid"; export CODEX_PS_MODE=fail; printf '%s\n' '{"type":"none"}' > "$job/events.jsonl"; run_resume "$job"; c=$rc
assert "81 classifier fails closed on ps but skips ps for dead pid" '[ "$a" -eq 65 ] && [ "$b" -eq 65 ] && [ "$fail_live" -eq 1 ] && [ "$empty_live" -eq 1 ] && [ "$c" -eq 65 ] && grep -q no-session "$stdout"'

new_workspace; claimed_resume_job; export CODEX_SHIM_MODE=hang-ignore-term; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 90; kill -TERM "$wrapper"; a1=0; wait_for_lines "$CODEX_SHIM_MARKERS/term-ack" 1 20 && a1=1; kill -TERM "$wrapper"; a2=0; wait_for_lines "$CODEX_SHIM_MARKERS/term-ack" 2 20 && a2=1; sleep 1.5; count=$(wc -l < "$CODEX_SHIM_MARKERS/term-ack"); touch "$CODEX_SHIM_MARKERS/release"; wait "$wrapper" 2>/dev/null
assert "82 exec and resume forward exactly once per TERM" '[ "$exec82_ok" -eq 1 ] && [ "$a1" -eq 1 ] && [ "$a2" -eq 1 ] && [ "$count" -eq 2 ]'

new_workspace; claimed_resume_job; export CODEX_SHIM_MODE=hang-with-session; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; wait_for_file "$CODEX_SHIM_MARKERS/shim-started" 90; real_child=$(cat "$CODEX_SHIM_MARKERS/shim-pid"); dead=$(dead_pid); printf '%s\n' "$dead" > "$job/codex.pid"; kill -TERM "$wrapper"; sleep 0.5; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; sleep 1.5; protected_alive=0; kill -0 "$protected" 2>/dev/null && protected_alive=1; real_alive=0; kill -0 "$real_child" 2>/dev/null && real_alive=1; touch "$CODEX_SHIM_MARKERS/release"; wait "$wrapper"; rc=$?; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
assert "83 exec and resume consume failed delivery without retry" '[ "$exec83_ok" -eq 1 ] && [ "$protected_alive" -eq 1 ] && [ "$real_alive" -eq 1 ] && [ "$rc" -eq 0 ]'

new_workspace; claimed_resume_job; export CODEX_PS_MODE=success CODEX_PS_COMM=unrelated; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; bash "$RESUME" "$job" >"$workspace/stdout" 2>"$workspace/stderr" & wrapper=$!; track_pid "$wrapper"; i=0; while ! grep -q '^status:' "$workspace/stdout" 2>/dev/null && [ "$i" -lt 90 ]; do sleep 0.1; i=$((i + 1)); done; before=$(wc -l < "$CODEX_PS_LOG"); wait "$wrapper"; rc=$?; after=$(wc -l < "$CODEX_PS_LOG"); kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
assert "84 supervision never invokes ps in exec or launched resume" '[ "$exec84_ok" -eq 1 ] && [ "$rc" -eq 0 ] && [ "$before" -gt 0 ] && [ "$after" -eq "$before" ]'

new_workspace; claimed_resume_job; sleep 30 & protected=$!; track_pid "$protected"; printf '%s\n' "$protected" > "$job/codex.pid"; export CODEX_PS_MODE=success CODEX_PS_COMM=codex; run_resume "$job"; a=$rc; export CODEX_PS_COMM=/bin/sh; run_resume "$job"; b=$rc; export CODEX_PS_COMM=/usr/bin/unrelated; printf '%s\n' "$protected" > "$job/codex.pid"; printf '%s\n' '{"type":"none"}' > "$job/events.jsonl"; run_resume "$job"; c=$rc; kill "$protected" 2>/dev/null; wait "$protected" 2>/dev/null
assert "85 controlled comm matrix is codex live sh live unrelated dead" '[ "$a" -eq 65 ] && [ "$b" -eq 65 ] && [ "$c" -eq 65 ] && grep -q no-session "$stdout" && [ -f "$job/codex.pid.stale-1" ]'

new_workspace; claimed_resume_job; bash "$RESUME" "$job" >"$workspace/resume1.out" 2>"$workspace/resume1.err" & resume1=$!; track_pid "$resume1"; bash "$RESUME" "$job" >"$workspace/resume2.out" 2>"$workspace/resume2.err" & resume2=$!; track_pid "$resume2"; wait "$resume1"; rr1=$?; wait "$resume2"; rr2=$?; resume_invoked=$(wc -l < "$CODEX_SHIM_MARKERS/shim-invoked" 2>/dev/null || printf 0); reservations=$(find "$job" -name 'events-resume-*.jsonl' -type f | wc -l)
assert "91 concurrent real resumes permit exactly one reservation and launch" '( { [ "$rr1" -eq 0 ] && [ "$rr2" -eq 65 ]; } || { [ "$rr1" -eq 65 ] && [ "$rr2" -eq 0 ]; } ) && [ "$resume_invoked" -eq 1 ] && [ "$reservations" -eq 1 ] && { grep -Eq "refused: (lock-held|stale-lock)" "$workspace/resume1.out" || grep -Eq "refused: (lock-held|stale-lock)" "$workspace/resume2.out"; }'

new_workspace; claimed_resume_job; bash "$RESUME" "$job" >&- 2>"$workspace/stderr"; closed_resume_rc=$?
assert "88b closed stdout refuses resume before shim launch" '[ "$closed_resume_rc" -eq 66 ] && [ ! -e "$CODEX_SHIM_MARKERS/shim-invoked" ]'

new_workspace; signal_ok=1
for sig in HUP TERM; do
  probe="$workspace/probe-$sig"; mkdir "$probe"
  CODEX_DELEGATE_SIGNAL_PROBE_DIR="$probe" bash "$0" >"$probe/stdout" 2>"$probe/stderr" & probe_runner=$!; track_pid "$probe_runner"
  wait_for_file "$probe/ready" 30 || signal_ok=0
  wait_for_file "$probe/pids" 30 || signal_ok=0
  read probe_wrapper probe_shim < "$probe/pids"
  read ready_wrapper probe_sleeper < "$probe/ready"
  kill -"$sig" "$probe_runner" 2>/dev/null || signal_ok=0
  wait "$probe_runner" 2>/dev/null; probe_rc=$?
  i=0; while { kill -0 "$probe_wrapper" 2>/dev/null || kill -0 "$probe_shim" 2>/dev/null || kill -0 "$probe_sleeper" 2>/dev/null; } && [ "$i" -lt 30 ]; do sleep 0.1; i=$((i + 1)); done
  [ "$probe_rc" -ne 0 ] || signal_ok=0
  ! kill -0 "$probe_wrapper" 2>/dev/null || signal_ok=0
  ! kill -0 "$probe_shim" 2>/dev/null || signal_ok=0
  ! kill -0 "$probe_sleeper" 2>/dev/null || signal_ok=0
done
assert "92 HUP and TERM terminate and reap tracked runner children" '[ "$signal_ok" -eq 1 ]'

# Post-acceptance: codex-verify-started.sh
VERIFY="$BACKEND_DIR/codex-verify-started.sh"

new_workspace; make_prompt; capture="$workspace/backend.stdout"
bash "$EXEC" "$prompt" >"$capture" 2>"$workspace/backend.stderr" & backend_bg=$!; track_pid "$backend_bg"
wait "$backend_bg"; backend_rc=$?
run_capture bash "$VERIFY" "$capture" 2
sed -n '1,5p' "$capture" > "$workspace/captured-announcement"
sed -n '1,5p' "$stdout" > "$workspace/verified-announcement"
assert "94 verify-started reprints announcement and session id" '[ "$backend_rc" -eq 0 ] && [ "$rc" -eq 0 ] && cmp -s "$workspace/captured-announcement" "$workspace/verified-announcement" && grep -q shim-thread "$stdout"'

new_workspace; capture="$workspace/backend.stdout"; : > "$capture"
CODEX_DELEGATE_TEST_ANNOUNCEMENT_POLL_LIMIT=2 run_capture bash "$VERIFY" "$capture"
assert "95 verify-started reports missing announcement" '[ "$rc" -eq 4 ] && [ ! -s "$stdout" ] && grep -Fq "no announcement in $capture — backend preflight failure (exit 64/66) or wrong capture file; read the file and the backend'\''s stderr" "$stderr"'

new_workspace
run_capture bash "$VERIFY"
verify_missing_rc=$rc; verify_missing_stdout_size=$(wc -c < "$stdout"); verify_missing_usage=0; grep -q '^usage: codex-verify-started.sh ' "$stderr" && verify_missing_usage=1
run_capture bash "$VERIFY" "$workspace/capture" 01
verify_bad_rc=$rc; verify_bad_stdout_size=$(wc -c < "$stdout"); verify_bad_usage=0; grep -q '^usage: codex-verify-started.sh ' "$stderr" && verify_bad_usage=1
assert "96 verify-started rejects missing arguments and bad timeout" '[ "$verify_missing_rc" -eq 2 ] && [ "$verify_missing_stdout_size" -eq 0 ] && [ "$verify_missing_usage" -eq 1 ] && [ "$verify_bad_rc" -eq 2 ] && [ "$verify_bad_stdout_size" -eq 0 ] && [ "$verify_bad_usage" -eq 1 ]'

if [ "$failures" -ne 0 ]; then
  printf '%s tests, %s failures\n' "$tests" "$failures" >&2
  exit 1
fi
printf '%s tests, 0 failures\n' "$tests"
