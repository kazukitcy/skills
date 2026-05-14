# Repositories

Use structured output for repository reads. Use `[HOST/]OWNER/REPO` for GitHub Enterprise Server when the host is not GitHub.com.

Repository metadata:

```sh
gh repo view owner/repo --json nameWithOwner,description,visibility,defaultBranchRef,url
GH_HOST=ghe.example.com gh repo view owner/repo --json nameWithOwner,isArchived,isPrivate,pushedAt
gh repo list owner --json nameWithOwner,description,visibility,updatedAt
```

Branches, commits, and compare:

```sh
gh api repos/owner/repo/branches --jq '.[] | {name,protected}'
gh api repos/owner/repo/commits/main --jq '{sha,commit:{message:.commit.message,author:.commit.author}}'
gh api repos/owner/repo/compare/base...head --jq '{status,ahead_by,behind_by,total_commits}'
```

`gh repo create` is a write operation. Summarize owner, repo name, visibility, source directory, remote behavior, and command intent before running it.

Do not document or run repository delete, archive, rename, or ownership transfer here. Those are admin/destructive operations.
