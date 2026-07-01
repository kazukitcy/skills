---
name: testkit-strategy-review
description: Use this skill when the user asks for a test strategy, test portfolio, CI test layering, prioritization across unit, integration, end-to-end, robustness, fuzz, release, or platform tests, or a roadmap for improving test confidence across a project.
metadata:
  suite: testkit
  principle_lineage: high-reliability-testing-principles
---


## Purpose

Design or review a project-level testing strategy. Use this when the user wants a test portfolio, CI layering plan, release testing roadmap, or risk-based test investment plan rather than individual test cases.


This skill applies generalized high-reliability testing principles: multiple independent harnesses, fast developer checks, deeper release checks, fault and fuzz testing, requirements traceability, coverage as meta-testing, and human release checklists.

## Use this skill when

- The user asks how to organize testing across unit, integration, end-to-end, fuzz, fault injection, and release checks.
- The user wants to know what test layers should run locally, in PR, nightly, before release, or as soak tests.
- The project has high confidence requirements and needs multiple independent oracles or harnesses.
- The user asks whether the current testing strategy is too shallow, too slow, too fragile, or too dependent on one test style.

## Do not use this skill when

- The user asks for concrete test cases from a spec; use `testkit-case-design`.
- The user provides a bug or incident and wants a regression test; use `testkit-regression-design`.
- The user provides coverage, mutation, flaky, or CI failure data; use `testkit-suite-diagnostics`.
- The user specifically wants fuzz or fault-injection harness design; use `testkit-robustness-planning`.
- The user needs a go/no-go checklist for a specific release; use `testkit-release-gate`.

## Workflow

1. Identify the product risk profile: data loss, security boundary, financial impact, concurrency, parser/input complexity, platform diversity, and release cadence.
2. Inventory current tests by harness and layer: unit, integration, public API, CLI, end-to-end, differential, property-based, fuzz, fault injection, performance, and release manual checks.
3. Identify independence gaps: tests sharing the same assumptions, fixtures, mocks, helper libraries, or weak oracle.
4. Define test layers by execution cost:
   - local fast path
   - PR or merge gate
   - nightly or deep checks
   - release candidate matrix
   - soak, fuzz, or chaos lanes
5. Assign oracle types for each layer: explicit expected values, differential, metamorphic, invariant, round-trip, configuration equivalence, and runtime instrumentation.
6. Define traceability expectations: which user-visible requirements should be linked to tests, which risks need checklist review, and which gaps are acceptable.
7. Produce a prioritized roadmap with P0/P1/P2 improvements.

## Output format

Use `assets/test-strategy-template.md`. Include:

- Current-state summary
- Risk profile
- Recommended test portfolio
- CI/release layering
- Harness independence review
- Oracle strategy
- Coverage/mutation/fuzz/release gate plan
- P0/P1/P2 roadmap

## Additional resources

- Read `references/high-reliability-testing-principles.md` for the generalized principles to preserve.
- Read `references/test-portfolio-patterns.md` when choosing test types.
- Read `references/ci-layering.md` when designing local/PR/nightly/release lanes.
- Read `references/harness-independence.md` when evaluating whether multiple harnesses really reduce shared blind spots.

## Quality bar

A good strategy names specific risks and assigns each risk to at least one appropriate test layer and oracle. It does not merely recommend more tests. It distinguishes fast feedback from deep confidence and explicitly says what should not block everyday development.

## Gotchas

- Do not invent expected behavior. If the source material is underspecified, mark it `ambiguous` and propose the smallest clarification or assumption needed.
- Prefer public behavior, external contracts, and user-visible invariants over implementation details.
- Do not optimize for coverage numbers alone. A test without an effective oracle can increase coverage while leaving behavior unverified.
- Keep outputs language-neutral unless the user explicitly asks for framework-specific implementation.
- Preserve reproducibility: include setup, trigger, expected observation, cleanup, and replay notes.
- Answer in the user's language when possible.

- Do not require every project to adopt maximum rigor. Scale test depth to risk, usage, impact, and maintenance cost.
- Do not treat a single green CI pipeline as independent evidence if all tests share the same mocks and expected values.
