#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: gh-safe-write.sh --repo [HOST/]OWNER/REPO --operation NAME --target TARGET --command-summary TEXT [--payload-file FILE]

Prints a write summary. It does not execute the command.
USAGE
}

repo=""
operation=""
target=""
command_summary=""
payload_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      repo="$2"
      shift 2
      ;;
    --operation)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      operation="$2"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      target="$2"
      shift 2
      ;;
    --command-summary)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      command_summary="$2"
      shift 2
      ;;
    --payload-file)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      payload_file="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

[[ -n "$repo" && -n "$operation" && -n "$target" && -n "$command_summary" ]] || { usage; exit 2; }

if [[ ! "$repo" =~ ^([A-Za-z0-9.-]+(:[0-9]+)?/)?[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  printf 'Invalid repository %s; expected [HOST/]OWNER/REPO.\n' "$repo" >&2
  exit 2
fi

printf 'GitHub write summary\n'
printf 'repo: %s\n' "$repo"
printf 'operation: %s\n' "$operation"
printf 'target: %s\n' "$target"
printf 'command intent: %s\n' "$command_summary"

if [[ -n "$payload_file" ]]; then
  if [[ ! -f "$payload_file" ]]; then
    printf 'Payload file not found: %s\n' "$payload_file" >&2
    exit 2
  fi
  bytes="$(wc -c <"$payload_file" | tr -d '[:space:]')"
  printf 'payload file: %s (%s bytes, contents not printed)\n' "$payload_file" "$bytes"
else
  printf 'payload file: none\n'
fi

printf 'No command was executed.\n'
