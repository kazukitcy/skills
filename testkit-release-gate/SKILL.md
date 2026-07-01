---
name: testkit-release-gate
description: Use this skill when the user wants a release readiness review, pre-release testing checklist, quality gate, risk-based go/no-go assessment, or manual verification plan before shipping software.
metadata:
  suite: testkit
  principle_lineage: high-reliability-testing-principles
---


## Purpose

Build a release readiness checklist and quality gate. Use this to make go/no-go or conditional-go decisions based on automated evidence, manual review, known risks, rollback readiness, and accepted gaps.


This skill applies generalized checklist-based release discipline: release decisions should combine automated evidence, human review, platform/configuration checks, known-risk assessment, and rollback readiness.

## Use this skill when

- The user asks for release readiness, pre-release checks, quality gate, go/no-go, or manual verification.
- The user is about to ship a feature, library, service, migration, SDK, CLI, or infrastructure component.
- The user wants a checklist that combines tests, regressions, coverage, fuzz/robustness, platform checks, documentation, monitoring, and rollback.

## Do not use this skill when

- The user is designing test cases from a spec; use `testkit-case-design`.
- The user is turning a bug into a regression test; use `testkit-regression-design`.
- The user is diagnosing coverage or mutation reports; use `testkit-suite-diagnostics`.
- The user is designing fault/fuzz harnesses; use `testkit-robustness-planning`.

## Workflow

1. Identify release scope, changed areas, public contracts, and affected users.
2. Classify risks: data loss, security, compatibility, migration, performance, concurrency, observability, rollback, platform/configuration.
3. Collect evidence: automated tests, regression tests, coverage/mutation, robustness/fuzz, performance, static analysis, manual checks.
4. Look for negative evidence: skipped tests, flaky tests, new warnings, unreviewed failures, stale known issues, unverified rollback.
5. Define quality gate criteria:
   - go
   - conditional-go with explicit accepted risk and mitigation
   - no-go
6. Produce a checklist with owner/status fields and human review prompts.
7. Name release blockers and non-blocking follow-ups separately.

## Output format

Use `assets/release-checklist-template.md`.

Required sections:

- release scope
- risk summary
- automated evidence checklist
- manual review checklist
- platform/configuration matrix
- regression and known issue review
- rollback/monitoring readiness
- decision: go, conditional-go, or no-go

## Additional resources

- Read `references/release-checklist-principles.md` for the generalized release checklist approach.
- Read `references/release-risk-areas.md` when identifying risk categories.
- Read `references/pre-release-checks.md` for specific checklist items.
- Read `references/manual-review-prompts.md` for human-in-the-loop review prompts.

## Quality bar

A good release gate separates objective evidence from judgment, names accepted risks explicitly, and makes it clear what would change the decision from go to no-go.

## Gotchas

- Do not invent expected behavior. If the source material is underspecified, mark it `ambiguous` and propose the smallest clarification or assumption needed.
- Prefer public behavior, external contracts, and user-visible invariants over implementation details.
- Do not optimize for coverage numbers alone. A test without an effective oracle can increase coverage while leaving behavior unverified.
- Keep outputs language-neutral unless the user explicitly asks for framework-specific implementation.
- Preserve reproducibility: include setup, trigger, expected observation, cleanup, and replay notes.
- Answer in the user's language when possible.

- Do not make a release decision solely from green tests. Check skipped tests, flakiness, unexpected warnings, known issues, and rollback readiness.
- Do not let static analysis warning cleanup override behavior preservation without tests.
- Do not hide conditional-go risks. Write them down with mitigations and owners.
