# Runtime: Claude Code

Concrete locations and mechanisms when this skill runs inside Claude Code.

## Destination locations

| Destination | Location |
| --- | --- |
| Skills (user-level) | `~/.claude/skills/<name>/SKILL.md` |
| Skills (project) | `.claude/skills/<name>/SKILL.md` |
| Instruction file (global) | `~/.claude/CLAUDE.md` |
| Instruction file (project) | `<project>/CLAUDE.md` or `<project>/.claude/CLAUDE.md`. If the project keeps its rules in `AGENTS.md`, make it effective via an `@AGENTS.md` import in `CLAUDE.md` (or a symlink) — Claude Code loads `CLAUDE.md` |
| Enforcement config | `~/.claude/settings.json` (user), `.claude/settings.json` (project) |
| Memory notes | The session's auto-memory directory, indexed by `MEMORY.md`. Default `~/.claude/projects/<project-slug>/memory/`; check settings for an `autoMemoryDirectory` override first and use it when present |
| Lint rules | `<project>/rules/` with `sgconfig.yml` (ast-grep) |
| Repository scripts | `<project>/scripts/` (or `tools/` / `bin/` — follow the project's existing convention) |

## Dedup search commands

Pass directories, not globs — an unmatched glob aborts the command in zsh
before grep runs. `-s` keeps missing paths quiet: record a missing location
as "checked, absent" and move on; a non-zero grep exit is not a failure.
`-F -e ... --` keeps keys starting with `-` or containing regex
metacharacters literal.

```
grep -risF -e "<key>" -- ~/.claude/skills/ .claude/skills/
grep -isF  -e "<key>" -- ~/.claude/CLAUDE.md CLAUDE.md .claude/CLAUDE.md AGENTS.md
grep -risF -e "<key>" -- rules/
grep -isF  -e "<key>" -- ~/.claude/settings.json .claude/settings.json
grep -risF -e "<key>" -- scripts/ tools/ bin/
grep -rilsF -e "<key>" -- "$HOME/.claude/projects/<project-slug>/memory/"
```

Resolve the memory directory first: use the `autoMemoryDirectory` setting
when one is active, otherwise resolve `<project-slug>` via
`ls ~/.claude/projects/`. Keep the path quoted — an unquoted `<...>`
placeholder parses as shell redirection.

To record each location as hit / no hit / absent (grep -s hides which missing
path failed), wrap the locations of a kind in:

```
for p in "$HOME/.claude/skills/" ".claude/skills/"; do  # quote each path; $HOME, not ~, inside quotes
  if [ ! -e "$p" ]; then echo "absent: $p"
  elif grep -rqisF -e "<key>" -- "$p"; then echo "HIT: $p"
  else echo "no hit: $p"; fi
done
```

## Enforcement mechanisms

Prefer the weakest mechanism that enforces the lesson:

- Gate a command behind confirmation: `permissions.ask`
- Forbid a command: `permissions.deny`
- Check or inject behavior around a tool call: `PreToolUse` / `PostToolUse` hooks

In `settings.json`:

```json
{
  "permissions": { "ask": ["Bash(rm:*)"], "deny": ["Bash(sudo:*)"] },
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "<check-script>" }]
    }]
  }
}
```

Use the built-in `update-config` skill to apply `settings.json` changes.

Validation after an enforcement edit: parse the file as JSON (e.g.
`python3 -m json.tool < settings.json`); for hook entries, also verify the
referenced command or script exists and is executable (`command -v` /
`test -x`) — valid JSON pointing at a missing script is a silent no-op.

## Memory note format

Follow the auto-memory convention: one file per lesson with frontmatter
(`name`, `description`, `metadata.type`), then add a one-line pointer to
`MEMORY.md`. Include the failure side under a `**Why:**` line and the date so
a later dedup hit can justify promotion.

## User-invocation guard

`disable-model-invocation: true` in the frontmatter is honored: the skill is
reachable only via `/codify-lessons`.
