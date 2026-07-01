---
name: testkit-robustness-planning
description: Use this skill when the user wants to test robustness under fuzz inputs, property-based inputs, resource exhaustion, I/O errors, network failures, timeouts, partial writes, retries, crashes, corrupt files, cleanup failures, or recovery scenarios. Produce a language-neutral robustness test plan and harness design.
metadata:
  suite: testkit
  principle_lineage: high-reliability-testing-principles
---


## Purpose

Plan robustness tests for systems that must behave correctly under invalid inputs, resource failures, crashes, corruption, concurrency, retries, and recovery.


This skill applies generalized anomaly-testing principles: resource failure injection, structured fuzzing, malformed input tests, crash/interruption simulation, compound failure tests, and resource lifecycle checks.

## Use this skill when

- The user asks for fuzz testing, property-based testing, corpus design, minimization, or replay.
- The user asks for fault injection: resource exhaustion, I/O errors, network errors, partial writes, timeouts, cancellations, retries, crashes, or cleanup failures.
- The system processes untrusted inputs, files, protocols, parsers, imports, messages, jobs, transactions, or persistent state.
- The user needs all-or-nothing recovery, idempotency, no-corruption, no-leak, or retry-safety tests.

## Do not use this skill when

- The user only wants normal and boundary test cases from a spec; use `testkit-case-design`.
- The user has a specific bug to regressionize; use `testkit-regression-design`.
- The user provides coverage or mutation reports; use `testkit-suite-diagnostics`.
- The user wants a release checklist; use `testkit-release-gate`.

## Workflow

1. Identify the robustness surface: parser, file format, storage, network, queue, job worker, transaction, cache, auth/session, import/export, migration, or concurrency boundary.
2. Identify state and resource lifecycles: allocation/acquisition, partial progress, commit point, cleanup, retry, recovery.
3. Choose fault models:
   - Nth failure injection
   - single failure
   - persistent failure after first failure
   - partial read/write
   - timeout
   - cancellation
   - crash or interruption during state transition
   - corrupt or malicious input
   - compound failure during recovery
4. Define recovery oracles:
   - no corruption
   - all-or-nothing state
   - idempotent retry
   - no resource leak
   - stable error type
   - invariant preserved
   - replayable minimized failure
5. For fuzz/property tests, define structured inputs, seed corpus, mutation strategy, oracle, crash capture, minimization, and regressionization path.
6. Produce a language-neutral harness design and priority plan.

## Output format

Use `assets/robustness-plan-template.yaml`.

Required sections:

- `risk_surface`
- `fault_models`
- `fuzz_plan`
- `crash_recovery_plan`
- `corrupt_input_plan`
- `resource_lifecycle_checks`
- `oracles`
- `replay_and_regressionization`
- `priorities`

## Additional resources

- Read `references/anomaly-testing-principles.md` for the generalized robustness model.
- Read `references/fault-injection-patterns.md` for Nth failure, single failure, persistent failure, partial write, and compound failure patterns.
- Read `references/fuzzing-patterns.md` for structured fuzzing and corpus management.
- Read `references/crash-recovery-patterns.md` for interruption and all-or-nothing recovery.
- Read `references/corrupt-input-patterns.md` for malformed data handling.
- Read `references/resource-lifecycle-checks.md` for leak and cleanup checks.

## Quality bar

A good robustness plan says exactly where faults are injected, what must remain true after failure, how failures are replayed, and how discovered cases become deterministic regression tests.

## Gotchas

- Do not invent expected behavior. If the source material is underspecified, mark it `ambiguous` and propose the smallest clarification or assumption needed.
- Prefer public behavior, external contracts, and user-visible invariants over implementation details.
- Do not optimize for coverage numbers alone. A test without an effective oracle can increase coverage while leaving behavior unverified.
- Keep outputs language-neutral unless the user explicitly asks for framework-specific implementation.
- Preserve reproducibility: include setup, trigger, expected observation, cleanup, and replay notes.
- Answer in the user's language when possible.

- Do not propose random fuzzing without an oracle and replay path.
- Do not stop at "should not crash" if state corruption, leaks, duplicate side effects, or retry behavior matter.
- Do not assume language-specific mechanisms. Express the harness in terms of wrappers, fakes, adapters, dependency injection, runtime instrumentation, or environment controls.
