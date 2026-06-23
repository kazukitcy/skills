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

### Review

The `review-code` orchestrator fans out to the `review-code-*` specialists, so install the orchestrator together with the lenses you want it to route to.

Install the whole family with a project's `apm.yml`:

```yaml
dependencies:
  apm:
    - kazukitcy/skills/review-code
    - kazukitcy/skills/review-code-correctness
    - kazukitcy/skills/review-code-security
    - kazukitcy/skills/review-code-tests
    - kazukitcy/skills/review-code-design
    - kazukitcy/skills/review-code-performance
    - kazukitcy/skills/review-code-reliability
    - kazukitcy/skills/review-code-release
    - kazukitcy/skills/review-code-adversarial
```

| Skill | Description | Install |
| --- | --- | --- |
| [review-code](./review-code) | Orchestrate risk-routed code review and consolidate severity-ranked findings. | `apm install -g kazukitcy/skills/review-code` |
| [review-code-correctness](./review-code-correctness) | Review functional behavior for logic, edge-case, invariant, and error-path defects. | `apm install -g kazukitcy/skills/review-code-correctness` |
| [review-code-security](./review-code-security) | Review security and privacy risks around auth, tenant boundaries, secrets, and exposure. | `apm install -g kazukitcy/skills/review-code-security` |
| [review-code-tests](./review-code-tests) | Review whether changed behavior has meaningful regression and boundary coverage. | `apm install -g kazukitcy/skills/review-code-tests` |
| [review-code-design](./review-code-design) | Review design, module boundaries, contracts, coupling, and maintainability risks. | `apm install -g kazukitcy/skills/review-code-design` |
| [review-code-performance](./review-code-performance) | Review hot paths, unbounded work, query behavior, caching, and latency risks. | `apm install -g kazukitcy/skills/review-code-performance` |
| [review-code-reliability](./review-code-reliability) | Review concurrency, retries, transactions, idempotency, and partial-failure risks. | `apm install -g kazukitcy/skills/review-code-reliability` |
| [review-code-release](./review-code-release) | Review migration, config, feature-flag, deploy-order, rollback, and observability risks. | `apm install -g kazukitcy/skills/review-code-release` |
| [review-code-adversarial](./review-code-adversarial) | Adversarially review high-risk changes by trying to break safety and rollout assumptions. | `apm install -g kazukitcy/skills/review-code-adversarial` |

### Rust

| Skill | Description | Install |
| --- | --- | --- |
| [rust-api-guidelines](./rust-api-guidelines) | Review Rust APIs against the Rust API Guidelines, with the full upstream guidelines vendored as references. | `apm install -g kazukitcy/skills/rust-api-guidelines` |

### Claude Code

| Skill | Description | Install |
| --- | --- | --- |
| [claude-code-review](./claude-code-review) | Delegate an independent read-only code review from an agent to local Claude Code. | `apm install -g kazukitcy/skills/claude-code-review` |
| [claude-code-rescue](./claude-code-rescue) | Delegate a bounded investigation or explicitly write-capable engineering task from an agent to local Claude Code. | `apm install -g kazukitcy/skills/claude-code-rescue` |

## License

Each skill may carry its own license. Skills without an explicit license default to the repository license.
