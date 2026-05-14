# Repository Context

Resolve repository context before running repository-scoped commands.

Repo specs may be `OWNER/REPO` for GitHub.com or `[HOST/]OWNER/REPO` for GitHub Enterprise Server (GHES). Keep the host visible in summaries whenever it is not `github.com`.

Priority:

1. User-specified `[HOST/]OWNER/REPO`.
2. Explicit command argument `--repo [HOST/]OWNER/REPO`.
3. `GH_REPO` plus `GH_HOST` when intentionally set for the session.
4. Current git remote parsed from `origin`.
5. `gh repo view --json nameWithOwner --jq .nameWithOwner`.

Use `--repo [HOST/]OWNER/REPO` whenever supported. Do not rely on implicit current-directory context once a repo has been resolved.

For write operations, do not infer a repo from the current directory when the user did not name one. Ask for clarification or require an explicit `--repo`.

For GHES, respect `GH_HOST` and the host in git remotes. Check auth for the intended host with `gh auth status --hostname HOST` when the host is not `github.com`. For API fallback, pass `gh api --hostname HOST ...`; do not rely on GitHub.com defaults.

Suggested helpers:

```sh
scripts/gh-check-auth.sh
scripts/gh-resolve-repo.sh --repo owner/repo
scripts/gh-resolve-repo.sh --repo ghe.example.com/owner/repo
scripts/gh-resolve-repo.sh --hostname ghe.example.com --repo owner/repo
scripts/gh-resolve-repo.sh --mode read
scripts/gh-resolve-repo.sh --mode write --repo ghe.example.com/owner/repo
```
