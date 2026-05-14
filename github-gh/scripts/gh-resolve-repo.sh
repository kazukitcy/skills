#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: gh-resolve-repo.sh [--repo [HOST/]OWNER/REPO] [--hostname HOST] [--mode read|write]

Prints [HOST/]OWNER/REPO on stdout.
Write mode requires --repo [HOST/]OWNER/REPO and refuses inferred repository context.
USAGE
}

mode="read"
repo=""
hostname=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      repo="$2"
      shift 2
      ;;
    --hostname)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      hostname="$2"
      shift 2
      ;;
    --mode)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      mode="$2"
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

case "$mode" in
  read|write) ;;
  *) usage; exit 2 ;;
esac

is_hostname() {
  [[ "$1" =~ ^[A-Za-z0-9.-]+(:[0-9]+)?$ ]]
}

is_owner_repo() {
  [[ "$1" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]
}

is_host_owner_repo() {
  [[ "$1" =~ ^[A-Za-z0-9.-]+(:[0-9]+)?/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]
}

format_repo() {
  local input_repo="$1"
  local input_host="${2:-}"

  if is_host_owner_repo "$input_repo"; then
    local repo_host="${input_repo%%/*}"
    if [[ -n "$input_host" && "$input_host" != "$repo_host" ]]; then
      printf 'Repository host %s does not match requested hostname %s.\n' "$repo_host" "$input_host" >&2
      return 1
    fi
    printf '%s\n' "$input_repo"
    return 0
  fi

  if is_owner_repo "$input_repo"; then
    if [[ -n "$input_host" && "$input_host" != "github.com" ]]; then
      printf '%s/%s\n' "$input_host" "$input_repo"
    else
      printf '%s\n' "$input_repo"
    fi
    return 0
  fi

  return 2
}

if [[ -n "$hostname" ]] && ! is_hostname "$hostname"; then
  printf 'Invalid hostname %s.\n' "$hostname" >&2
  exit 2
fi

if [[ -n "$repo" ]]; then
  if resolved_repo="$(format_repo "$repo" "${hostname:-${GH_HOST:-}}")"; then
    printf '%s\n' "$resolved_repo"
    exit 0
  fi
  printf 'Invalid repository %s; expected [HOST/]OWNER/REPO.\n' "$repo" >&2
  exit 2
fi

if [[ "$mode" == "write" ]]; then
  printf 'Refusing to infer repository for write mode. Pass --repo [HOST/]OWNER/REPO.\n' >&2
  exit 1
fi

if [[ -n "${GH_REPO:-}" ]]; then
  if resolved_repo="$(format_repo "$GH_REPO" "${hostname:-${GH_HOST:-}}")"; then
    printf '%s\n' "$resolved_repo"
    exit 0
  fi
  printf 'GH_REPO is set but is not [HOST/]OWNER/REPO: %s\n' "$GH_REPO" >&2
  exit 2
fi

remote_url=""
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  remote_url="$(git remote get-url origin 2>/dev/null || true)"
fi

if [[ -n "$remote_url" ]]; then
  normalized="$remote_url"
  normalized="${normalized#git@}"
  normalized="${normalized#ssh://git@}"
  normalized="${normalized#https://}"
  normalized="${normalized#http://}"
  normalized="${normalized#www.}"
  normalized="${normalized%.git}"
  normalized="${normalized/:/\/}"
  remote_host="$(printf '%s\n' "$normalized" | awk -F/ 'NF>=3 {print $1}')"
  owner_repo="$(printf '%s\n' "$normalized" | awk -F/ 'NF>=3 {print $(NF-1) "/" $NF}')"
  if [[ -n "$owner_repo" ]] && is_owner_repo "$owner_repo" && is_hostname "$remote_host"; then
    if [[ "$remote_host" == "github.com" ]]; then
      printf '%s\n' "$owner_repo"
    else
      printf '%s/%s\n' "$remote_host" "$owner_repo"
    fi
    exit 0
  fi
fi

if command -v gh >/dev/null 2>&1; then
  resolved="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)"
  if [[ -n "$resolved" ]] && resolved_repo="$(format_repo "$resolved" "${hostname:-${GH_HOST:-}}")"; then
    printf '%s\n' "$resolved_repo"
    exit 0
  fi
fi

printf 'Could not resolve repository. Pass --repo [HOST/]OWNER/REPO.\n' >&2
exit 1
