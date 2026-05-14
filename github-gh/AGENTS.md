# github-gh Skill Package Guidelines

This package builds a `gh` CLI Agent Skill, not GitHub MCP Server compatibility.

## Scope

- Keep `SKILL.md` short. It should route, classify risk, and point to references.
- Put command details, examples, and API fallback guidance in `references/`.
- Prefer standard `gh` commands. Use `gh api` only when the standard command surface is insufficient.
- References should be practical decision guides, not copied manpages.

## Safety

- Never store tokens, credentials, secret values, private keys, or local auth output in skill files, docs, logs, tests, or evals.
- Separate GitHub operations into read, write, and destructive/admin classes.
- Do not include destructive/admin operations in the normal flow. Route them to `references/admin-and-destructive-ops.md`.
- Write examples may describe commands, but tests must not modify GitHub state.
- Scripts must be shellcheck-friendly, use `set -euo pipefail`, avoid `eval`, and avoid printing tokens or secret payloads.

## Validation

- Validate frontmatter, routing references, script executability, and safety boundaries with local tests.
- If `gh skill publish --dry-run` is unavailable, document that limitation and use manual validation instead.
