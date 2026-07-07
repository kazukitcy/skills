---
name: test-engineering
description: Use this skill for software testing design and assessment requests. Creating test cases, edge cases, negative tests, or test plans from specs, API docs, schemas, README files, user stories, or source code behavior; turning a bug report, incident, stack trace, log, or failing input into a minimal reproduction and regression test; planning fuzz, property-based, fault-injection, corrupt-input, crash-recovery, or resource-exhaustion testing; diagnosing coverage reports, mutation results, surviving mutants, flaky tests, or CI failures; reviewing a test strategy, test portfolio, or CI test layering; or building a release readiness checklist, quality gate, or go/no-go assessment.
metadata:
  principle_lineage: high-reliability-testing-principles
---

## Purpose

Design and assess software testing work. One skill, six modes that share the
same high-reliability discipline: requirements, oracles, boundaries, negative
cases, reproducibility, and evidence-based decisions.

## Workflow

1. Classify the request into exactly one mode using the table below. Apply the
   boundary rules when signals overlap.
2. Read the mode file under `references/` and follow its workflow to
   completion. Do not answer from the table alone.
3. Produce the output the mode file requires, using its template in `assets/`.

## Mode selection

| Request signal | Mode | Read |
| --- | --- | --- |
| Test cases, edge cases, negative tests, or a test plan from a spec, API doc, schema, README, user story, or code behavior; audit existing tests against documented behavior | case-design | `references/mode-case-design.md` |
| A bug report, issue, incident, stack trace, log, production error, or failing input that needs a minimal reproduction, failing test, regression test, or fix acceptance criteria | regression-design | `references/mode-regression-design.md` |
| Fuzz or property-based testing, fault injection, I/O or network failures, timeouts, partial writes, crashes, corrupt files, resource exhaustion, cleanup or recovery testing | robustness-planning | `references/mode-robustness-planning.md` |
| Coverage reports, branch gaps, mutation results, surviving mutants, flaky tests, CI failures, slow or skipped tests; "high coverage but low confidence" | suite-diagnostics | `references/mode-suite-diagnostics.md` |
| Project-level test strategy, test portfolio, CI test layering, harness independence, or a roadmap for improving test confidence | strategy-review | `references/mode-strategy-review.md` |
| Release readiness review, pre-release checklist, quality gate, risk-based go/no-go, or manual verification plan before shipping | release-gate | `references/mode-release-gate.md` |

Boundary rules:

- A concrete failure beats a clean spec. When the input is a bug, incident, or
  fuzz-discovered failing input, use regression-design even if the user says
  "test cases".
- Harness planning without a specific known bug is robustness-planning;
  converting one specific discovered failure into a deterministic test is
  regression-design.
- Evidence about existing tests (coverage, mutation, flaky, CI data) is
  suite-diagnostics; project-wide direction without such data is
  strategy-review.
- Release-gate decides whether to ship: it verifies readiness of work that is
  already built and tested. Deciding what testing to build, run, or improve —
  even in preparation for an upcoming release — is strategy-review. A
  deadline alone does not make a request release-gate.

## Shared rules (all modes)

- Do not invent expected behavior. If the source material is underspecified,
  mark it `ambiguous` and propose the smallest clarification or assumption
  needed.
- Prefer public behavior, external contracts, and user-visible invariants over
  implementation details.
- Do not optimize for coverage numbers alone. A test without an effective
  oracle can increase coverage while leaving behavior unverified.
- Keep outputs language-neutral unless the user explicitly asks for
  framework-specific implementation.
- Preserve reproducibility: include setup, trigger, expected observation,
  cleanup, and replay notes.
- Answer in the user's language when possible.

## Shared references

- Read `references/oracle-patterns.md` whenever choosing an oracle,
  strengthening weak assertions, or the expected result is unclear; it is the
  single home for oracle types, weak-oracle patterns, and the oracle strength
  checklist.
- Read `references/high-reliability-testing-principles.md` when the request
  is about overall testing direction or rigor rather than a specific
  artifact; strategy-review always reads it.
- Read `references/prioritization-rules.md` whenever ranking cases, findings,
  or roadmap items P0/P1/P2; it is the single home for the priority criteria
  and tie breakers.
