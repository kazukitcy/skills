# Worked Examples

One end-to-end example per destination tier: lint rule, runtime enforcement,
repository script, skill, instruction file rule, memory note.

## Lint rule (syntax-detectable)

- First attempt: in TypeScript, computed a set's size with
  `Array.from(set).length`; review flagged it as wasteful.
- Final solution: use `set.size`.
- Insight: for `Set`/`Map` size, use the `.size` property. The anti-pattern is
  detectable at the syntax level, so it must not live in prose.

Artifacts — `rules/no-array-from-size.yml`:

```yaml
id: no-array-from-size
language: TypeScript
severity: warning
rule:
  pattern: Array.from($COLL).length
message: Use the .size property for Set/Map size. (Array.from copies the collection.)
```

and its test, `rule-tests/no-array-from-size-test.yml` (validated with
`ast-grep test`):

```yaml
id: no-array-from-size
valid:
  - const n = mySet.size
invalid:
  - const n = Array.from(mySet).length
```

## Runtime enforcement (operation-enforceable)

- First attempt: deleted a tracked file with plain `rm`; the deletion never
  entered the index and the commit silently missed it.
- Final solution: use `git rm` for tracked files.
- Insight: "never do X with command Y" is enforceable at the operation level —
  stronger than a sentence in an instruction file.

Artifact — in Claude Code, a `settings.json` permission entry that forces a
confirmation (other runtimes: the equivalent command gate):

```jsonc
"permissions": { "ask": ["Bash(rm:*)"] }
```

## Repository script (fixed command sequence, no gate)

- First attempt: hand-wrote the same log-watching loop and JSONL extraction
  one-liner four separate times during one debugging session, with small
  errors each time.
- Final solution: checked the sequence in as `scripts/watch-extract.sh` with
  a one-line pointer in the instruction file.
- Insight: re-deriving the same snippet is the signal — the sequence needs
  no gate and no judgment, so a script beats both prose and a skill. This
  lesson also splits: the procedure became the script; the warning ("do not
  re-derive it inline") became the instruction-file pointer line.

Artifacts: `scripts/watch-extract.sh` (executable, run once to validate) and
the pointer line in the instruction file.

## Skill (procedure with judgment)

- First attempt: to call a C library from MoonBit, tried several layouts and
  got stuck on where FFI declarations and stubs belong.
- Final solution: an `extern "c"` declaration plus a stub using `moonbit.h`
  plus `native-stub` / `link.native` settings in `moon.pkg.json`.
- Insight: three layers (declaration, stub, build config) must be understood
  together — a procedure, not a one-liner.

Artifact: a new skill `moonbit-c-binding` with the procedure and templates.
If the dedup check finds it already exists, this becomes an append instead.

## Instruction file rule (short, always-on)

- First attempt: ran `pnpm install` and CI broke on a lockfile format diff.
- Final solution: pinned pnpm to the v10 line.
- Insight: not syntax-detectable, not operation-enforceable, no judgment
  needed — a one-sentence always-on rule.

Artifact — appended to the tools section of the global instruction file
(`~/.claude/CLAUDE.md` in Claude Code):

```markdown
- Use pnpm v10 or later (reason: the lockfile format is incompatible with v9 and earlier, causing CI diffs)
```

## Memory note with later promotion (first occurrence)

- First attempt: assumed a flaky integration test was a timing issue and added
  a sleep; it kept flaking.
- Final solution: the test depended on unordered map iteration; sorting fixed it.
- Insight: plausible lesson ("suspect iteration order before timing"), but seen
  once — confidence too low for a global rule.

Artifact: a memory note `suspect-iteration-order-in-flaky-tests`. In a later
session the dedup grep hits this note while codifying a similar fix — that
recurrence is the evidence to propose promoting it to a CLAUDE.md rule or
skill.
