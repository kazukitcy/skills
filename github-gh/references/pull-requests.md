# Pull Requests

Prefer `gh pr` commands before API fallback. Use `[HOST/]OWNER/REPO` for GitHub Enterprise Server when the host is not GitHub.com.

Common read commands:

```sh
gh pr list --repo owner/repo --state open --json number,title,headRefName,baseRefName,isDraft
gh pr list --repo owner/repo --search "review:required status:failure" --json number,title,state,url
gh pr view 123 --repo owner/repo --json title,state,author,files,reviews,statusCheckRollup
gh pr diff 123 --repo owner/repo
gh pr checks 123 --repo owner/repo
```

Common write commands:

```sh
gh pr create --repo owner/repo --base main --head branch --title "Title" --body-file body.md
gh pr edit 123 --repo owner/repo --add-label ready
gh pr comment 123 --repo owner/repo --body-file comment.md
gh pr review 123 --repo owner/repo --approve --body-file review.md
gh pr merge 123 --repo owner/repo --squash
```

Labels, assignees, milestones, title, body, base branch, head branch, review body, and merge options are payload. Include them in the write summary before create, edit, comment, review, or merge commands.

PRs are issues in the GitHub data model, so `gh search issues` can find PRs with `type:pr` or `is:pr`. Prefer `gh pr list --search` for PR-specific search when it covers the query.

Start PR-related CI inspection with `gh pr checks`. Move to `gh run view` only when run details, logs, artifacts, reruns, or cancellation are needed.

PR merge is a high-impact write operation. Confirm repo, PR number, merge strategy, branch deletion behavior, and expected checks state before running it.

`gh pr create` can prompt to push a branch or create a fork. Avoid surprise prompts by checking branch state first and using explicit flags where possible.
