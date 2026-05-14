# Projects

Use `gh project` for basic GitHub Projects work when it is available in the installed CLI.

Examples:

```sh
gh project list --owner owner
gh project view PROJECT_NUMBER --owner owner --format json
gh project item-list PROJECT_NUMBER --owner owner --format json
gh project item-add PROJECT_NUMBER --owner owner --url ISSUE_OR_PR_URL
```

Treat item creation, item edits, field updates, and archive/remove actions as writes.

Project v2 field IDs, item IDs, iteration fields, option IDs, and bulk updates often require GraphQL. Use `gh api graphql` only after reading current project state and identifying exact IDs.

Large Project v2 updates require a safety summary: owner, project number, item count, field IDs, proposed changes, and rollback or correction plan.
