# github-gh Skill

`github-gh` helps agents choose and run local GitHub CLI (`gh`) commands safely from natural-language requests.

## Install

Install through APM:

```sh
apm install -g kazukitcy/skills/github-gh
```

For local runtime validation from this repository:

```sh
mkdir -p ~/.agents/skills
cp -R github-gh ~/.agents/skills/github-gh
```

## Requirements

- `gh` installed and authenticated for the target host.
- A local git checkout or explicit `[HOST/]OWNER/REPO` for repository-scoped work. For GitHub Enterprise Server, authenticate with `gh auth login --hostname HOST` and use `GH_HOST` or `--repo HOST/OWNER/REPO`.
- `jq` when local JSON processing is needed.

Detailed command choices live in `references/`. Write operations require a target summary before execution: repo, operation, target object, payload, and command intent. If the repo is ambiguous, do not write.

Destructive/admin operations require explicit user intent and the procedure in `references/admin-and-destructive-ops.md`.

## Validation

```sh
node --test github-gh/tests/*.test.mjs
node --test */tests/*.test.mjs
gh skill publish --dry-run
```

If `gh skill` is unavailable, rely on the Node tests plus manual checks for frontmatter, reference routing, executable scripts, no unsafe `eval`, and no token output.
