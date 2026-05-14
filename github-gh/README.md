# github-gh Skill

`github-gh` helps agents choose and run local GitHub CLI (`gh`) commands safely from natural-language requests.

This is not a GitHub MCP Server compatibility layer. It does not reimplement MCP tools or schemas. It is a router, policy, and decision guide for using the installed `gh` CLI.

## Install or Copy

For local runtime validation, copy the skill directory:

```sh
mkdir -p ~/.agents/skills
cp -R github-gh ~/.agents/skills/github-gh
```

For APM-style packaging, publish or install `kazukitcy/skills/github-gh` according to your runtime's skill distribution mechanism.

## Requirements

- GitHub CLI `gh` installed.
- `gh auth login` completed for the target host.
- `jq` installed when local JSON processing is needed.
- A local git checkout or explicit `[HOST/]OWNER/REPO` for repository-scoped work. For GitHub Enterprise Server, authenticate with `gh auth login --hostname HOST` and use `GH_HOST` or `--repo HOST/OWNER/REPO`.

## Usage Examples

Read operations:

```sh
gh issue list --repo owner/repo --label bug --json number,title,state,url
gh issue list --repo ghe.example.com/owner/repo --label bug --json number,title,state,url
gh pr view 123 --repo owner/repo --json title,state,author,files,statusCheckRollup
gh search code "functionName repo:owner/repo" --json path,repository,url
gh api --hostname ghe.example.com repos/owner/repo/collaborators --paginate --jq '.[].login'
```

Write operations require a target summary before execution: repo, operation, target object, payload, and command intent. If the repo is ambiguous, do not write.

Destructive and admin operations are outside the normal flow. Repository delete/archive/rename, secrets, deploy keys, org administration, rulesets, security alert state changes, Dependabot alert state changes, secret scanning, and notification state changes require explicit user intent and the procedure in `references/admin-and-destructive-ops.md`.

## Validation

Run local checks:

```sh
node --test github-gh/tests/*.test.mjs
```

Optional `gh` skill packaging validation may be attempted with:

```sh
gh skill publish --dry-run
```

If `gh skill` is not installed or is a preview feature unavailable in the environment, use the manual checks above: verify frontmatter, references, script executability, no unsafe `eval`, no token output, and no tests that modify GitHub state.

## Future Split

If destructive/admin workflows become common, split them into an optional `github-gh-admin` skill. Keep `github-gh` focused on ordinary repository, issue, PR, Actions, release, gist, project, search, and `gh api` fallback work.
