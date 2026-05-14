# Issues

Prefer `gh issue` commands before API fallback. Use `[HOST/]OWNER/REPO` for GitHub Enterprise Server when the host is not GitHub.com.

Common read commands:

```sh
gh issue list --repo owner/repo --state open --label bug --json number,title,state,labels,url
gh issue view 123 --repo owner/repo --json number,title,body,author,state,labels,assignees,milestone,comments,url
gh search issues "repo:owner/repo is:issue label:bug state:open" --json number,title,state,repository,url
```

Common write commands:

```sh
gh issue create --repo owner/repo --title "Title" --body-file body.md --label bug
gh issue edit 123 --repo owner/repo --add-label triage --add-assignee @me
gh issue comment 123 --repo owner/repo --body-file comment.md
gh issue close 123 --repo owner/repo --comment "Closing with context"
gh issue reopen 123 --repo owner/repo
```

Labels, assignees, milestones, title, body, and state are payload. Include them in the write summary before create, edit, comment, close, or reopen commands.

PRs are issues in the GitHub data model, so `gh search issues` can return both issues and pull requests. Use `type:issue` or `is:issue` when ambiguity matters.

Use `gh api` only when the standard issue commands do not expose the required field or mutation.
