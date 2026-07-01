# Minimal reproduction rules

A regression test should be small enough to fail for one clear reason.

## Keep

- the smallest input that triggers the failure
- the minimum state needed before the action
- required configuration, timing, platform, or dependency behavior
- the observed failure signal
- the expected behavior after the fix

## Remove

- unrelated log lines
- unrelated setup data
- timing noise that can be replaced with deterministic synchronization
- production-only identifiers
- broad workflows when a focused lower-level contract test is enough

## Minimize carefully

Do not minimize away the bug. After every simplification, check whether the failure would still occur before the fix.

## Preserve replay

Record:

- exact input or reduced input
- setup state
- action sequence
- clock or timing assumptions
- dependency responses
- configuration flags
- expected failure before fix
