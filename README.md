# kazukitcy/skills

A collection of agent skills maintained by [@kazukitcy](https://github.com/kazukitcy), distributed via [APM (Agent Package Manager)](https://github.com/microsoft/apm).

Each directory is a standalone skill following the [agentskills.io](https://agentskills.io/) open standard.

## Install

Install an individual skill (global / user scope):

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

### Coding

| Skill | Description | Install |
| --- | --- | --- |
| [coding-rescue](./coding-rescue) | Perform a tool-neutral bounded engineering rescue task usable by any coding tool. | `apm install -g kazukitcy/skills/coding-rescue` |
| [coding-review](./coding-review) | Perform a tool-neutral, read-only code review usable by any coding tool. | `apm install -g kazukitcy/skills/coding-review` |

### Claude Code

| Skill | Description | Install |
| --- | --- | --- |
| [claude-code-review](./claude-code-review) | Delegate an independent read-only code review from an agent to local Claude Code. | `apm install -g kazukitcy/skills/claude-code-review` |
| [claude-code-rescue](./claude-code-rescue) | Delegate a bounded investigation or explicitly write-capable engineering task from an agent to local Claude Code. | `apm install -g kazukitcy/skills/claude-code-rescue` |

## License

Each skill may carry its own license. Skills without an explicit license default to the repository license.
