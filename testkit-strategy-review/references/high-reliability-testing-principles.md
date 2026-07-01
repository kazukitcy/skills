# High-reliability testing principles

Use these principles as design guidance, not as a mandate to copy any particular project's tools or rigor.

## Independent evidence beats one large monoculture suite

A single test suite often shares the same fixtures, helper functions, mocks, generated data, and mental model. High-confidence systems use multiple independent sources of evidence so that one flawed assumption is less likely to hide a defect.

Good independence examples:

- public API tests separate from internal unit tests
- scenario tests separate from implementation-level tests
- differential checks against an independent implementation or model
- generated/randomized checks separate from curated examples
- runtime instrumentation separate from functional assertions
- human release review separate from green automation

## Execution cost should be layered

Do not put every expensive test in the PR lane. Also do not omit deep tests entirely. Separate fast feedback from deep confidence:

- local fast path: catches common mistakes quickly
- PR gate: protects shared branches
- nightly/deep: broad configurations, slow suites, mutation, robustness, long randomized runs
- release candidate: platform/configuration matrix and manual evidence review
- soak/continuous: long-lived fuzzing, stability, performance drift, recurring flakiness

## Requirements should be traceable to tests

Extract testable statements from specifications, API docs, schemas, user stories, acceptance criteria, and public contracts. Map each requirement to tests or mark it missing, partial, or ambiguous.

## Robustness is part of correctness

A system is not only correct when the machine and inputs are friendly. Test resource exhaustion, external dependency failure, partial operations, interruption, malformed inputs, boundary limits, retry behavior, and cleanup.

## Coverage is a meta-test of the tests

Coverage does not prove product quality. It shows what the tests executed. Branch, condition, and decision coverage reveal blind spots that line coverage hides. A high-coverage test with weak assertions may still verify little.

## Every discovered bug should become a deterministic regression test

A fix is not complete until a focused test would have failed before the fix and passes after the fix. Preserve and minimize the original trigger so future failures are replayable.

## Human review should remain in the release loop

Automation should gather evidence. Humans should review unexpected warnings, skipped tests, newly accepted risk, ambiguous behavior, rollback readiness, and changes whose impact exceeds what automated tests observe.
