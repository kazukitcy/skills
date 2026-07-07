# Mode: robustness-planning

Plan robustness tests for systems that must behave correctly under invalid
inputs, resource failures, crashes, corruption, concurrency, retries, and
recovery.

## Workflow

1. Identify the robustness surface: parser, file format, storage, network,
   queue, job worker, transaction, cache, auth/session, import/export,
   migration, or concurrency boundary.
2. Identify state and resource lifecycles: allocation/acquisition, partial
   progress, commit point, cleanup, retry, recovery.
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
5. For fuzz/property tests, define structured inputs, seed corpus, mutation
   strategy, oracle, crash capture, minimization, and regressionization path.
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

## Mode references

- Read `robustness-patterns.md` for fault injection, fuzzing, corrupt-input,
  crash-recovery, and resource lifecycle patterns; each section maps to a
  required output section.

## Quality bar

A good robustness plan says exactly where faults are injected, what must
remain true after failure, how failures are replayed, and how discovered
cases become deterministic regression tests.

## Mode gotchas

- Do not propose random fuzzing without an oracle and replay path.
- Do not stop at "should not crash" if state corruption, leaks, duplicate
  side effects, or retry behavior matter.
- Do not assume language-specific mechanisms. Express the harness in terms of
  wrappers, fakes, adapters, dependency injection, runtime instrumentation,
  or environment controls.
