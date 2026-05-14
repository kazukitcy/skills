#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [--hostname HOST]\n' "${0##*/}" >&2
}

hostname=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --hostname)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      hostname="$2"
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

if ! command -v gh >/dev/null 2>&1; then
  printf 'GitHub CLI "gh" is required but was not found in PATH.\n' >&2
  exit 127
fi

if [[ -n "$hostname" ]]; then
  if gh auth status --hostname "$hostname" >/dev/null 2>&1; then
    printf 'gh authentication OK for %s\n' "$hostname"
    exit 0
  fi
  printf 'GitHub CLI authentication is required for %s. Run: gh auth login --hostname %s\n' "$hostname" "$hostname" >&2
  exit 1
fi

if gh auth status >/dev/null 2>&1; then
  printf 'gh authentication OK\n'
  exit 0
fi

printf 'GitHub CLI authentication is required. Run: gh auth login\n' >&2
exit 1
