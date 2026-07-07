# Output Templates

Generate artifacts only for items the user adopted. One template per
destination tier: lint rule, runtime enforcement, repository script, skill,
instruction file rule, memory note.

## Lint rule (ast-grep)

Follow the `ast-grep-practice` skill when available. Add YAML under the
project's `rules/` directory and always add a valid/invalid pair under
`rule-tests/`.

```yaml
id: <kebab-case-rule-id>
language: <Language>
severity: warning
rule:
  pattern: <anti-pattern>
message: <imperative instruction>. (<reason>)
```

## Runtime enforcement

The concrete mechanisms and config syntax are defined in the runtime
reference (`runtime-claude-code.md` / `runtime-codex.md`); do not restate
them here. Two rules apply regardless of runtime:

- Prefer the weakest mechanism that enforces the lesson: gate or forbid the
  command before injecting behavior around it. If the runtime cannot express
  the enforcement, fall back to the agent-instruction-file tier and state the
  downgrade in the proposal.
- State the enforced lesson and its reason next to the entry when the format
  allows comments (TOML, JSONC). For strict-JSON configs, put the rationale
  in the proposal and the commit message instead — a comment would break the
  file.

## Repository script

Check the command sequence into the project as an executable script (e.g.
`scripts/<verb-object>.sh`), following the project's existing script
conventions. Add a one-line pointer in the agent instruction file so agents
find it instead of re-deriving the sequence:

```markdown
- Use `scripts/<name>.sh` to <what it does> — do not re-derive it inline (reason: <short rationale>)
```

Validation: run the script once against a real input (or at minimum
`--help` / a dry-run flag) and confirm it is executable (`test -x`).

## Skill (new or append)

For a new skill, follow the `skill-writer` skill (contract, rubric,
checklist). Minimal frontmatter:

```markdown
---
name: <kebab-case>
description: Use when <specific situation> / <symptom>.
---

# <Title>

## When to use
## Workflow
## Pitfalls
```

For an append, add the lesson under the existing section the dedup check
identified, matching the file's style.

## Agent instruction file rule (CLAUDE.md / AGENTS.md / GEMINI.md)

Append one imperative sentence to the matching existing section, always with
the reason in parentheses so a future reader can judge edge cases:

```markdown
- <imperative sentence> (reason: <short rationale>)
```

Destination: the runtime's global instruction file (e.g. `~/.claude/CLAUDE.md`)
for cross-project rules, the project's instruction file (`AGENTS.md`,
`CLAUDE.md`, or the runtime's equivalent) for repository-specific ones.

## Memory note

One lesson per entry, in the location and format the runtime reference
defines. Regardless of format, every note must carry three things: the
imperative instruction, the failure side (why the first attempt did not
work), and the absolute date — a later dedup hit needs all three to justify
promotion.
