# kazukitcy/skills

A collection of agent skills maintained by [@kazukitcy](https://github.com/kazukitcy), distributed via [APM (Agent Package Manager)](https://github.com/microsoft/apm).

Each top-level directory is a standalone skill. A skill directory should contain a `SKILL.md` file and any supporting references, scripts, or assets needed by that skill.

## Install

Install an individual skill globally:

```sh
apm install -g kazukitcy/skills/<skill-name>
```

Or add it to a project's `apm.yml`:

```yaml
dependencies:
  apm:
    - kazukitcy/skills/<skill-name>
```

Pin to a tag when reproducibility matters:

```sh
apm install -g kazukitcy/skills/<skill-name>#v0.1.0
```

## Skills

### Claude Code Review

Use local Claude Code from an agent for independent read-only code review.

Install with APM:

```sh
apm install -g kazukitcy/skills/claude-code-review
```

Or add it to a project's `apm.yml`:

```yaml
dependencies:
  apm:
    - kazukitcy/skills/claude-code-review
```

## Conventions

- Write public documentation in English.
- Keep each skill self-contained in its own top-level directory.
- Put agent-facing instructions in `SKILL.md`.
- Add supporting files only when they are required to run or understand the skill.

## License

Each skill may define its own license. Skills without an explicit license default to the repository license.
