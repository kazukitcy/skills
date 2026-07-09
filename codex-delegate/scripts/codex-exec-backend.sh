#!/usr/bin/env bash
# codex-exec-backend.sh — run Codex non-interactively with file-based results.
#
# Launches `codex exec` as a plain child process: completion is the process
# exiting, the final message lands in a file (-o), and events stream to a
# JSONL log. No app-server, broker, or wrapper state is involved, so there
# is no status to poll and no relay that can stall.
#
# Usage:
#   scripts/codex-exec-backend.sh [-s SANDBOX] [-C DIR] [-m MODEL] [-e EFFORT] [-j DIR] PROMPT_FILE|-
#
#   PROMPT_FILE   file containing the task prompt; `-` reads it from stdin
#   -s SANDBOX    read-only | workspace-write   (default: read-only)
#   -C DIR        agent working root            (default: current directory)
#   -m MODEL      model override                (default: .codex/config.toml)
#   -e EFFORT     model_reasoning_effort        (default: .codex/config.toml)
#   -j DIR        job directory
#                 (default: a fresh timestamped dir under
#                  $CODEX_DELEGATE_JOBS, else ~/.codex-delegate/jobs —
#                  persistent, so past runs stay inspectable; prune old
#                  job dirs yourself when they pile up)
#
# The script prints the job paths first, then runs codex in its own
# foreground — invoke the SCRIPT in the background and wait for its exit.
# Exit code = codex exec's exit code.
#
# Job directory contents:
#   prompt.md        the exact prompt sent
#   last-message.md  the run's final assistant message (codex -o)
#   events.jsonl     event stream (--json); the session id for
#                    `codex exec resume` appears in the first lines
#   stderr.log       codex stderr

set -u

sandbox="read-only"
workdir="$PWD"
model=""
effort=""
jobdir=""

while getopts "s:C:m:e:j:" opt; do
  case "$opt" in
    s) sandbox="$OPTARG" ;;
    C) workdir="$OPTARG" ;;
    m) model="$OPTARG" ;;
    e) effort="$OPTARG" ;;
    j) jobdir="$OPTARG" ;;
    *) echo "usage: $0 [-s read-only|workspace-write] [-C DIR] [-m MODEL] [-e EFFORT] [-j DIR] PROMPT_FILE|-" >&2; exit 64 ;;
  esac
done
shift $((OPTIND - 1))

if [ "$#" -ne 1 ]; then
  echo "error: exactly one PROMPT_FILE (or -) is required; options must precede it" >&2
  exit 64
fi
prompt_src="$1"
case "$sandbox" in
  read-only|workspace-write) ;;
  *) echo "error: -s must be read-only or workspace-write" >&2; exit 64 ;;
esac

if [ -z "$jobdir" ]; then
  jobbase="${CODEX_DELEGATE_JOBS:-$HOME/.codex-delegate/jobs}"
  mkdir -p "$jobbase" || exit 66
  jobdir="$(mktemp -d "$jobbase/$(date +%Y%m%dT%H%M%S)-XXXX")" || exit 66
else
  mkdir -p "$jobdir" || exit 66
fi

# Fail before launching on any prompt-staging error — a reused job dir must
# never run Codex on a stale prompt.md left by a previous run.
if [ "$prompt_src" = "-" ]; then
  cat > "$jobdir/prompt.md" || { echo "error: failed to write prompt from stdin" >&2; exit 66; }
else
  cp "$prompt_src" "$jobdir/prompt.md" || { echo "error: failed to copy prompt file" >&2; exit 66; }
fi

echo "job-dir:      $jobdir"
echo "last-message: $jobdir/last-message.md"
echo "events:       $jobdir/events.jsonl"
echo "stderr:       $jobdir/stderr.log"

args=(exec -s "$sandbox" -C "$workdir" --json -o "$jobdir/last-message.md")
[ -n "$model" ] && args+=(-m "$model")
[ -n "$effort" ] && args+=(-c "model_reasoning_effort=\"$effort\"")

command codex "${args[@]}" - < "$jobdir/prompt.md" \
  > "$jobdir/events.jsonl" 2> "$jobdir/stderr.log"
status=$?

session="$(sed -nE 's/.*"(session_id|thread_id)"[[:space:]]*:[[:space:]]*"([^"]+)".*/\2/p' \
  "$jobdir/events.jsonl" 2>/dev/null | head -1)"
[ -n "$session" ] && echo "session-id:   $session"
echo "exit:         $status"
exit "$status"
