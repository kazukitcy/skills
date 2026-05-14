# Command Selection

Choose the smallest standard `gh` command that matches the user's intent. Use `gh api` only when the normal command surface does not expose the needed field or mutation. For GitHub Enterprise Server, prefer `--repo HOST/OWNER/REPO` for repository commands and `gh api --hostname HOST` for API fallback.

| User intent | Prefer | Risk |
| --- | --- | --- |
| Check auth | `gh auth status` | read |
| Identify repo | `gh repo view --json nameWithOwner` | read |
| View repo metadata | `gh repo view --repo [HOST/]OWNER/REPO --json ...` | read |
| List repos | `gh repo list OWNER --json ...` | read |
| Find code | `gh search code "query repo:OWNER/REPO" --json ...` | read |
| Read file contents | `gh api repos/OWNER/REPO/contents/PATH --jq ...` | read |
| Inspect branches or commits | `gh api repos/OWNER/REPO/branches`, `gh api repos/OWNER/REPO/commits/SHA` | read |
| Find issues | `gh issue list`, `gh search issues` | read |
| Create or edit issue | `gh issue create`, `gh issue edit`, `gh issue close`, `gh issue reopen` | write |
| View PR state | `gh pr view --json ...` | read |
| View PR diff | `gh pr diff` | read |
| View PR CI | `gh pr checks`, then `gh run view` | read |
| Create or edit PR | `gh pr create`, `gh pr edit` | write |
| Review or comment on PR | `gh pr review`, `gh pr comment` | write |
| Merge PR | `gh pr merge` | write, high-impact |
| Inspect workflow runs | `gh run list`, `gh run view`, `gh run watch` | read |
| Trigger workflow | `gh workflow run` | write |
| Rerun or cancel run | `gh run rerun`, `gh run cancel` | write |
| Releases | `gh release list/view/create/upload/delete` | read/write/destructive |
| Gists | `gh gist list/view/create/edit/delete` | read/write/destructive |
| Projects basics | `gh project ...` | read/write |
| Missing standard support | `gh api` or `gh api graphql` | depends |

Route repository delete, archive, rename, deploy keys, secrets, variables, org admin, rulesets, security alerts, Dependabot alerts, secret scanning, and notification state changes to `admin-and-destructive-ops.md`.
