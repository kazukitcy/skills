---
name: testkit-suite-diagnostics
description: Use this skill when the user provides coverage reports, branch gaps, mutation testing results, surviving mutants, flaky test data, CI failures, slow test reports, or says the test suite has high coverage but low confidence. Diagnose weak tests, weak oracles, missing assertions, unreachable code, equivalent mutants, and prioritized improvements.
metadata:
  suite: testkit
  principle_lineage: high-reliability-testing-principles
---


## Purpose

Diagnose the quality of an existing test suite. Treat coverage and mutation results as evidence about the tests, not as direct proof of product quality.


This skill applies generalized diagnostic principles: branch coverage is stronger than statement coverage, defensive code needs deliberate handling, coverage is a meta-test of the test suite, mutation testing reveals weak oracles, and instrumented test configurations should be checked against delivered configurations.

## Use this skill when

- The user provides line, branch, condition, MC/DC, or coverage gap reports.
- The user provides mutation testing results or surviving mutants.
- The user says coverage is high but confidence is low.
- The user has flaky tests, recurring CI failures, slow tests, skipped tests, or weak assertions.
- The user wants prioritized recommendations for improving an existing test suite.

## Do not use this skill when

- The user wants new cases from a spec; use `testkit-case-design`.
- The user wants to turn a specific bug into a regression test; use `testkit-regression-design`.
- The user wants a broad test strategy; use `testkit-strategy-review`.
- The user wants release readiness; use `testkit-release-gate`.

## Workflow

1. Classify the input: coverage, mutation, flaky, CI failure, slow test, skipped test, weak assertion, or mixed.
2. Identify what is actually unverified: path not executed, branch side not taken, condition interaction missing, behavior touched but not asserted, mutant survived, nondeterministic setup, or environment instability.
3. Classify findings:
   - missing behavior check
   - weak oracle
   - unreachable code
   - defensive branch
   - equivalent mutant
   - optimization-only branch
   - flaky infrastructure
   - slow or oversized test
   - skipped or quarantined risk
4. Recommend the smallest high-signal improvement: add assertion, add boundary case, add invariant, add differential oracle, split a test, delete dead code, mark intentional defensive branch, or move slow work to a deeper lane.
5. Prioritize findings P0/P1/P2 and identify which should block release.

## Output format

Use `assets/diagnostics-report-template.md`.

Include:

- executive summary
- evidence reviewed
- finding table with classification
- recommended tests or assertions
- coverage/mutation interpretation
- flaky/CI recommendations when applicable
- release risk if relevant

## Additional resources

- Read `references/coverage-as-meta-test-principles.md` for coverage-as-meta-test and delivered-configuration checks.
- Read `references/coverage-interpretation.md` for branch, MC/DC, defensive, and boundary coverage interpretation.
- Read `references/mutation-classification.md` for surviving mutant triage.
- Read `references/flaky-test-analysis.md` for nondeterminism and CI issues.
- Read `references/weak-oracle-patterns.md` for assertion improvements.

## Quality bar

A good diagnostic report explains why a number or mutant matters. It does not say "increase coverage" without naming the missing behavior and oracle. It distinguishes unreachable or defensive code from genuinely untested behavior.

## Gotchas

- Do not invent expected behavior. If the source material is underspecified, mark it `ambiguous` and propose the smallest clarification or assumption needed.
- Prefer public behavior, external contracts, and user-visible invariants over implementation details.
- Do not optimize for coverage numbers alone. A test without an effective oracle can increase coverage while leaving behavior unverified.
- Keep outputs language-neutral unless the user explicitly asks for framework-specific implementation.
- Preserve reproducibility: include setup, trigger, expected observation, cleanup, and replay notes.
- Answer in the user's language when possible.

- Do not mechanically require 100% coverage for every project. Scale coverage targets to risk, maintenance cost, and expected confidence.
- Do not treat static analyzer warnings as automatically correct. Classify them and decide whether code, tests, or documentation should change.
- Do not accept a killed mutant as strong evidence if the failure was a timeout or unrelated crash unless that is the intended oracle.
