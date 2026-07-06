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

### Authoring

| Skill | Description | Install |
| --- | --- | --- |
| [skill-writer](./skill-writer) | Create, revise, and evaluate agent skills with a source-model-based rubric and review checklist. | `apm install -g kazukitcy/skills/skill-writer` |

### Review

`review-code` is a single skill: an orchestrator that risk-routes a diff to the
relevant review checklists (correctness, security, tests, design, performance,
reliability, release, adversarial, intent), runs each as a subagent over a bundled
reference file under `review-code/references/`, and consolidates severity-ranked
findings.

| Skill | Description | Install |
| --- | --- | --- |
| [review-code](./review-code) | Risk-routed, multi-checklist code review with consolidated severity-ranked findings. | `apm install -g kazukitcy/skills/review-code` |

### Rust

| Skill | Description | Install |
| --- | --- | --- |
| [rust-api-guidelines](./rust-api-guidelines) | Review Rust APIs against the Rust API Guidelines and the Microsoft Rust Guidelines, with both upstream guideline sets vendored as references. | `apm install -g kazukitcy/skills/rust-api-guidelines` |

## License

Each skill may carry its own license. Skills without an explicit license default to the repository license.
