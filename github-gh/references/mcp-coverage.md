# MCP Coverage Notes

This skill is not designed for GitHub MCP Server compatibility. It does not mirror MCP command names, toolsets, schemas, or response contracts.

Use this file only for migration, evaluation, or gap checks when comparing MCP-like workflows to local `gh` workflows. Do not use it for normal command routing.

| Workflow | `gh` coverage | Notes |
| --- | --- | --- |
| Repository view/list | full | `gh repo view`, `gh repo list` |
| File contents | partial | Standard commands are limited; use `gh api repos/.../contents/...` |
| Code search | full | `gh search code` covers common search workflows |
| Issue list/view/create/edit/comment | full | `gh issue ...` |
| PR list/view/create/edit/comment/review/diff/checks | full | `gh pr ...`; status details may need `gh run` |
| PR merge | full | High-impact write; requires safe-write summary |
| Actions run inspection | full | `gh run list/view/watch/download` |
| Workflow dispatch | full | `gh workflow run`; write operation |
| Projects v2 simple list/view/item add | partial | `gh project`; complex fields need GraphQL |
| Project field/item mutations | custom | Use `gh api graphql` with explicit IDs |
| Releases | full | `gh release ...` |
| Gists | full | `gh gist ...` |
| Security alerts and secret scanning | gap | Admin/destructive reference only |
| Org administration | gap | Admin/destructive reference only |
