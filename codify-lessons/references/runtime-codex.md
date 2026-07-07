# Runtime: Codex

Concrete locations and mechanisms when this skill runs inside the Codex CLI.

## Destination locations

| Destination | Location |
| --- | --- |
| Skills (user-level) | `~/.agents/skills/<name>/SKILL.md` |
| Skills (project) | `.agents/skills/<name>/SKILL.md` |
| Instruction file (global) | `~/.codex/AGENTS.md` |
| Instruction file (project) | `<project>/AGENTS.md` |
| Enforcement config | `~/.codex/rules/*.rules` (user), `.codex/rules/` (project, loaded only when trusted), hooks, `~/.codex/config.toml`, and `.codex/config.toml` (project, loaded only when trusted) |
| Memory notes | `~/.codex/memories/` is Codex-generated state — do not hand-edit it. Write manual lesson notes to `<project>/docs/lessons.md` — this exact path is required so the dedup search finds them for recurrence detection |
| Lint rules | `<project>/rules/` with `sgconfig.yml` (ast-grep) |
| Repository scripts | `<project>/scripts/` (or `tools/` / `bin/` — follow the project's existing convention) |

## Dedup search commands

Pass directories, not globs — an unmatched glob aborts the command in zsh
before grep runs. `-s` keeps missing paths quiet: record a missing location
as "checked, absent" and move on; a non-zero grep exit is not a failure.
`-F -e ... --` keeps keys starting with `-` or containing regex metacharacters
literal.

```
grep -risF -e "<key>" -- ~/.agents/skills/ .agents/skills/
grep -isF  -e "<key>" -- ~/.codex/AGENTS.md AGENTS.md
grep -risF -e "<key>" -- rules/
grep -risF -e "<key>" -- ~/.codex/rules/ .codex/rules/ ~/.codex/hooks.json .codex/hooks.json ~/.codex/config.toml .codex/config.toml
grep -risF -e "<key>" -- scripts/ tools/ bin/
grep -risF -e "<key>" -- docs/lessons.md ~/.codex/memories/
```

Search `~/.codex/memories/` read-only — a hit there counts as recurrence for
the promotion rule, but this skill never writes to it.

To record each location as hit / no hit / absent (grep -s hides which missing
path failed), wrap the locations of a kind in:

```
for p in "$HOME/.agents/skills/" ".agents/skills/"; do  # quote each path; $HOME, not ~, inside quotes
  if [ ! -e "$p" ]; then echo "absent: $p"
  elif grep -rqisF -e "<key>" -- "$p"; then echo "HIT: $p"
  else echo "no hit: $p"; fi
done
```

## Enforcement mechanisms

In order of preference:

- **Execpolicy rules** (`~/.codex/rules/*.rules`, project `.codex/rules/`):
  prefix rules deciding `allow`, `prompt`, or `forbidden` per command; the
  strictest matching decision wins. This is the direct equivalent of a
  permission gate.
- **Hooks**: configured per the Codex hooks documentation; use when behavior
  must run around a tool call rather than gate it.
- **Sandbox and approval posture**: `sandbox_mode` and `approval_policy` in
  `config.toml` for coarse-grained control.

Fall back to the instruction-file tier (`AGENTS.md`) only when none of these
can express the lesson, and state the downgrade in the proposal.

Validation after an enforcement edit: for `.rules` files run
`codex execpolicy check --rules <rules-file> <command>...` at least twice —
once with a command the rule must gate (expect `prompt` or `forbidden`) and
once with one it must not (expect no matching rule, `matchedRules: []`;
expect `allow` only when the artifact intentionally adds an allow rule).
Parse `hooks.json` as JSON and `config.toml` as TOML; for hook entries, also
verify the referenced command or script exists and is executable
(`command -v` / `test -x`) — valid syntax pointing at a missing script is a
silent no-op.

## Memory note format

Append to `<project>/docs/lessons.md` — always this path, never another
notes file, or later dedup runs will miss the recurrence — as a dated bullet
with the failure side included:

```markdown
- <imperative instruction> (why: <first failure and why the fix works>; first seen: <date>)
```

## User-invocation guard

Codex ignores the `disable-model-invocation` frontmatter. This skill instead
ships `agents/openai.yaml` with `policy.allow_implicit_invocation: false`,
which stops Codex from invoking it implicitly; explicit `$codify-lessons`
invocation still works.
