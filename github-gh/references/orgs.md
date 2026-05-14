# Organizations

Use this reference for organization lookup and read-oriented organization discovery. Keep organization administration, membership changes, secrets, variables, rulesets, and security settings in `admin-and-destructive-ops.md`.

## Standard Commands

List organizations visible to the authenticated user:

```sh
gh org list --limit 100
```

`gh org` is intentionally small. For structured organization details, members, teams, and repository lists, prefer `gh api` with explicit host handling.

## Read With API Fallback

For GitHub.com:

```sh
gh api orgs/ORG --jq '{login, name, url, plan: .plan.name}'
gh api orgs/ORG/repos --paginate --jq '.[] | {name, visibility, archived, default_branch}'
gh api orgs/ORG/members --paginate --jq '.[] | {login, type}'
gh api orgs/ORG/teams --paginate --jq '.[] | {name, slug, privacy}'
```

For GitHub Enterprise Server:

```sh
gh api --hostname HOST orgs/ORG --jq '{login, name, url}'
gh api --hostname HOST orgs/ORG/repos --paginate --jq '.[] | {name, visibility, archived}'
```

Use `GH_HOST=HOST gh org list` only when listing organizations for the authenticated account on that host. Prefer `gh api --hostname HOST` when the request names an organization or needs JSON.

## Risk Boundaries

- Read: list visible orgs, view org metadata, list org repos, inspect public or permission-visible members and teams.
- Write/admin: invite/remove members, change member roles, manage teams, manage org secrets or variables, change org settings, rulesets, billing, security settings, or repository ownership. Route these to `admin-and-destructive-ops.md`.

Before reporting membership or team results, mention the host and org used and note when permissions may hide private data.
