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
| [codify-lessons](./codify-lessons) | Pair what failed first with what finally worked in a session, then codify the insight as a lint rule, runtime enforcement, skill, memory note, or agent instruction rule, with per-runtime (Claude Code / Codex) references. | `apm install -g kazukitcy/skills/codify-lessons` |
| [skill-gardening](./skill-gardening) | Grow a skill portfolio over its lifecycle: gate new-skill proposals, fix misfiring or underperforming skills against observed failures, and run recurring pruning passes. | `apm install -g kazukitcy/skills/skill-gardening` |
| [skill-writer](./skill-writer) | Write and evaluate agent skill text with a source-model-based rubric and review checklist. | `apm install -g kazukitcy/skills/skill-writer` |

### Review

`review-code` is a single skill: an orchestrator that risk-routes a diff to the
relevant review checklists (correctness, security, tests, design, performance,
reliability, release, adversarial, intent), runs each as a subagent over a bundled
reference file under `review-code/references/`, and consolidates severity-ranked
findings.

| Skill | Description | Install |
| --- | --- | --- |
| [review-code](./review-code) | Risk-routed, multi-checklist code review with consolidated severity-ranked findings. | `apm install -g kazukitcy/skills/review-code` |

### Testing

`test-engineering` is a single skill: a mode router that classifies a testing
request into one of six modes (case-design, regression-design,
robustness-planning, suite-diagnostics, strategy-review, release-gate), each
backed by a mode workflow and reference files under
`test-engineering/references/` and output templates under
`test-engineering/assets/`.

| Skill | Description | Install |
| --- | --- | --- |
| [test-engineering](./test-engineering) | Mode-routed test design and assessment: test cases from specs, bug-to-regression tests, robustness/fuzz planning, suite diagnostics, test strategy review, and release gates. | `apm install -g kazukitcy/skills/test-engineering` |

### Rust

| Skill | Description | Install |
| --- | --- | --- |
| [rust-api-guidelines](./rust-api-guidelines) | Review Rust APIs against the Rust API Guidelines and the Microsoft Rust Guidelines, with both upstream guideline sets vendored as references. | `apm install -g kazukitcy/skills/rust-api-guidelines` |

## License

Each skill may carry its own license. Skills without an explicit license default to the repository license.
