---
name: testkit-regression-design
description: Use this skill when the user provides a bug report, issue, incident, stack trace, log, failing input, production error, or unexpected behavior and wants a minimal reproduction, failing test scenario, regression test, or acceptance criteria for the fix.
metadata:
  suite: testkit
  principle_lineage: high-reliability-testing-principles
---


## Purpose

Turn a real failure into a minimal reproduction and regression test design. The core rule is: a bug is not fixed until there is a test that would have exposed it before the fix and passes after the fix.


## Use this skill when

- The user provides a bug report, issue, stack trace, log, incident, production error, customer report, failing input, or unexpected behavior.
- The user asks for a minimal reproduction, failing test, regression test, acceptance criteria, or fix validation plan.
- A fuzz or robustness failure needs to be converted into a deterministic regression case.

## Do not use this skill when

- The user is designing tests from a clean spec; use `testkit-case-design`.
- The user is diagnosing coverage or mutation reports; use `testkit-suite-diagnostics`.
- The user is planning broad fault injection or fuzzing; use `testkit-robustness-planning`.

## Workflow

1. Summarize the failure in one sentence.
2. Separate observed behavior, expected behavior, and unknowns.
3. Extract the smallest known trigger: input, state, configuration, timing, platform, dependency response, or sequence of events.
4. Remove incidental details that are not needed for reproduction.
5. Define the before-fix failure signal and after-fix acceptance criteria.
6. Choose an oracle strong enough to detect the bug, not just the crash or status code.
7. Add assertions for state, side effects, resource cleanup, idempotency, and invariants when relevant.
8. Define replay instructions and how the case should be added to the project's test suite.

## Output format

Use `assets/regression-test-template.yaml`.

Required fields:

- `bug_summary`
- `evidence`
- `minimal_reproduction`
- `before_fix_failure`
- `after_fix_expected_behavior`
- `oracle`
- `regression_test`
- `implementation_notes`
- `clarifications_needed`

## Additional resources

- Read `references/minimal-reproduction-rules.md` to reduce a bug to its essential trigger.
- Read `references/bug-to-test-workflow.md` for the full failure-to-regression process.
- Read `references/regression-acceptance-criteria.md` for after-fix validation.
- Read `references/regression-discipline-principles.md` for the generalized regression discipline.

## Quality bar

A good regression design fails for the old bug, passes after the fix, and is narrow enough that future failures point back to the same behavior. It should avoid brittle log-message-only assertions unless log output is the public contract.

## Gotchas

- Do not invent expected behavior. If the source material is underspecified, mark it `ambiguous` and propose the smallest clarification or assumption needed.
- Prefer public behavior, external contracts, and user-visible invariants over implementation details.
- Do not optimize for coverage numbers alone. A test without an effective oracle can increase coverage while leaving behavior unverified.
- Keep outputs language-neutral unless the user explicitly asks for framework-specific implementation.
- Preserve reproducibility: include setup, trigger, expected observation, cleanup, and replay notes.
- Answer in the user's language when possible.

- Do not treat a broad end-to-end reproduction as sufficient if a smaller deterministic test can be created.
- Do not lose the original failing input. Preserve it, minimize it, and explain how to replay it.
- Do not hide ambiguous expected behavior. If product intent is unclear, propose acceptance criteria that must be confirmed.
