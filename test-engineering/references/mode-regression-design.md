# Mode: regression-design

Turn a real failure into a minimal reproduction and regression test design.
The core rule: a bug is not fixed until there is a test that would have
exposed it before the fix and passes after the fix.

## Workflow

1. Capture the evidence (report, stack trace, log excerpt, failing input,
   affected version, environment; redact secrets) and summarize the failure
   in one sentence.
2. Separate observed behavior, expected behavior, and unknowns.
3. Extract the smallest known trigger: input, state, configuration, timing,
   platform, dependency response, or sequence of events.
4. Remove incidental details that are not needed for reproduction.
5. Define the before-fix failure signal and after-fix acceptance criteria.
6. Choose an oracle strong enough to detect the bug, not just the crash or
   status code (see `oracle-patterns.md`).
7. Add assertions for state, side effects, resource cleanup, idempotency, and
   invariants when relevant.
8. Define replay instructions and how the case should be added to the
   project's test suite.

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

## Minimal reproduction rules

A regression test should be small enough to fail for one clear reason.

Keep:

- the smallest input that triggers the failure
- the minimum state needed before the action
- required configuration, timing, platform, or dependency behavior
- the observed failure signal
- the expected behavior after the fix

Remove:

- unrelated log lines
- unrelated setup data
- timing noise that can be replaced with deterministic synchronization
- production-only identifiers
- broad workflows when a focused lower-level contract test is enough

Do not minimize away the bug. After every simplification, check whether the
failure would still occur before the fix.

Preserve replay. Record:

- exact input or reduced input
- setup state
- action sequence
- clock or timing assumptions
- dependency responses
- configuration flags
- expected failure before fix

## Acceptance criteria

Use these checks before calling a regression test complete.

Required:

- Fails before the fix or clearly documents the pre-fix failure signal.
- Passes after the fix.
- Targets the behavior that broke, not a broad unrelated workflow.
- Has a strong oracle that would catch the same class of bug again.
- Includes setup, trigger, expected observation, and cleanup.
- Is deterministic or has a controlled replay path.

Good additions:

- Links to issue or incident ID.
- Preserves minimized failing input.
- Asserts state and side effects.
- Covers retry, cleanup, or idempotency if relevant.
- Uses public behavior unless internal behavior is the intended contract.
- Runs in the fast or PR lane; an expensive full reproduction can stay as
  deep-lane or release-lane evidence.

Avoid:

- Asserting only that no exception was thrown.
- Asserting only a log line unless logs are part of the contract.
- Depending on real time sleeps when deterministic synchronization is possible.
- Keeping a full production dataset when a minimized case is sufficient.

## Quality bar

A good regression design fails for the old bug, passes after the fix, and is
narrow enough that future failures point back to the same behavior. It should
avoid brittle log-message-only assertions unless log output is the public
contract.

## Mode gotchas

- Do not treat a broad end-to-end reproduction as sufficient if a smaller
  deterministic test can be created.
- Do not lose the original failing input. Preserve it, minimize it, and
  explain how to replay it.
- Do not hide ambiguous expected behavior. If product intent is unclear,
  propose acceptance criteria that must be confirmed.
