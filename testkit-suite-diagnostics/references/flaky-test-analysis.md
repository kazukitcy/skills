# Flaky test analysis

A flaky test is not only annoying; it weakens release evidence.

## Common causes

- real time sleeps instead of synchronization
- shared mutable state between tests
- order dependence
- external dependency instability
- resource leaks
- concurrency races
- random data without seed logging
- platform or timezone assumptions
- insufficient cleanup

## Triage fields

For each flaky test, capture:

- failure signature
- frequency
- affected environment
- changed code area, if any
- whether failure indicates product risk or test infrastructure risk
- whether the test is quarantined or still blocking

## Recommendations

- replace sleeps with deterministic waits or fake clocks
- isolate shared state
- log random seeds and inputs
- split oversized tests
- move slow nondeterministic checks to a deeper lane only if fast evidence remains
- add resource cleanup checks

## Release handling

Do not silently ignore flaky tests. A release gate should show whether flakiness is accepted risk, a blocker, or an infrastructure follow-up.
