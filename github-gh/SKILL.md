---
name: github-gh
description: "Use when the user wants to query or operate GitHub through the local gh CLI: repositories, files, code search, issues, pull requests, reviews, checks, Actions runs, workflows, releases, projects, gists, and gh api fallbacks. Do not use for purely conceptual GitHub explanations, browser-only tasks, or destructive/admin operations unless explicitly requested and safety checks are satisfied."
---

# github-gh

Use this skill to translate a user's GitHub request into safe local `gh` CLI actions. It is not a GitHub MCP Server compatibility layer and does not reimplement MCP tool schemas.

## Common Procedure

1. Check authentication first with `gh auth status` or `scripts/gh-check-auth.sh`.
2. Resolve the target repository and host explicitly. Prefer the user's `[HOST/]OWNER/REPO`; otherwise use `--repo [HOST/]OWNER/REPO`, `GH_REPO` plus `GH_HOST`, current git remote, then `gh repo view --json nameWithOwner`.
3. Use `--repo [HOST/]OWNER/REPO` whenever the command supports it, and use `gh api --hostname HOST` for GitHub Enterprise Server API calls.
4. If the user did not specify a repo and asks for a write operation, do not guess.
5. For read operations, prefer structured output: `--json`, `--jq`, or `gh api --jq`.
6. For write operations, state the target repo, object, payload, and command intent before execution. Use `references/safe-writes.md`.
7. For destructive/admin operations, follow `references/admin-and-destructive-ops.md` and require explicit user intent.
8. Never store or print tokens, credentials, secret values, or private auth output in skill files, logs, README files, tests, or evals.

## Risk Classes

- Read: listing, viewing, searching, diffing, checking status, downloading artifacts, and inspecting API results.
- Write: creating or editing issues, comments, PRs, reviews, workflow dispatches, reruns, cancels, merges, releases, gists, and project items.
- Destructive/admin: deletion, archive, rename, secrets, variables, deploy keys, org administration, rulesets, security alert state changes, Dependabot alert state changes, secret scanning, and notification state changes.

## Reference Routing

- Command choice: `references/command-selection.md`.
- Repo resolution and GitHub Enterprise host handling: `references/repo-context.md`.
- Repository metadata, creation, branches, commits, and compare: `references/repositories.md`.
- File contents and code search: `references/files-search.md`.
- Issues, issue comments, labels, assignees, and milestones: `references/issues.md`.
- Pull requests, PR comments, reviews, checks, diffs, and merges: `references/pull-requests.md`.
- Actions runs, logs, artifacts, workflows, reruns, cancels, and dispatch: `references/actions.md`.
- Projects basics and Project v2 GraphQL fallback: `references/projects.md`.
- Releases: `references/releases.md`.
- Gists: `references/gists.md`.
- REST or GraphQL fallback with `gh api`: `references/gh-api.md`.
- Write summaries and payload handling: `references/safe-writes.md`.
- Admin/destructive isolation: `references/admin-and-destructive-ops.md`.
- Migration or gap evaluation versus MCP-like workflows only: `references/mcp-coverage.md`.

## Completion Criteria

Finish only after the requested GitHub state or information is handled, the repo and host used are clear, structured output has been summarized for the user, and any skipped write/destructive action has a concrete safety reason.
