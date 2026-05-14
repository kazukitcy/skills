#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: gh-api-json.sh --endpoint ENDPOINT [--hostname HOST] [--method METHOD] [--jq FILTER] [--paginate] [--slurp] [--input-file FILE] [--field KEY=VALUE] [--raw-field KEY=VALUE]
USAGE
}

endpoint=""
hostname=""
method="GET"
jq_filter=""
paginate="false"
slurp="false"
input_file=""
fields=()
raw_fields=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --endpoint)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      endpoint="$2"
      shift 2
      ;;
    --hostname)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      hostname="$2"
      shift 2
      ;;
    --method)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      method="$2"
      shift 2
      ;;
    --jq)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      jq_filter="$2"
      shift 2
      ;;
    --paginate)
      paginate="true"
      shift
      ;;
    --slurp)
      slurp="true"
      shift
      ;;
    --input-file)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      input_file="$2"
      shift 2
      ;;
    --field)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      fields+=("$2")
      shift 2
      ;;
    --raw-field)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      raw_fields+=("$2")
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

[[ -n "$endpoint" ]] || { usage; exit 2; }

if ! command -v gh >/dev/null 2>&1; then
  printf 'GitHub CLI "gh" is required but was not found in PATH.\n' >&2
  exit 127
fi

args=(api --method "$method")

if [[ -n "$hostname" ]]; then
  args+=(--hostname "$hostname")
fi

args+=("$endpoint")

if [[ -n "$jq_filter" ]]; then
  args+=(--jq "$jq_filter")
fi

if [[ "$paginate" == "true" ]]; then
  args+=(--paginate)
fi

if [[ "$slurp" == "true" ]]; then
  args+=(--slurp)
fi

if [[ -n "$input_file" ]]; then
  [[ -f "$input_file" ]] || { printf 'Input file not found: %s\n' "$input_file" >&2; exit 2; }
  args+=(--input "$input_file")
fi

for field in "${fields[@]}"; do
  args+=(--field "$field")
done

for raw_field in "${raw_fields[@]}"; do
  args+=(--raw-field "$raw_field")
done

gh "${args[@]}"
