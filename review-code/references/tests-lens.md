# Review Code: Test Adequacy

> Whether the behavior this change introduces or alters is adequately and honestly
> tested. Severity, confidence, evidence, and output format live in
> references/shared-rubric.md — read it too.

## Scope

- Coverage and quality of tests for the changed behavior: do the tests exist,
  exercise the risky paths, and actually assert the contract?
- Adjacent lenses (route there, don't double-report): whether the behavior itself
  is correct → correctness (this lens assumes the intended behavior is defined and
  asks whether it is covered). The specific failure modes a test should exercise
  come from the risk lenses (security, reliability, release).

## What to look for

- Missing coverage: changed behavior with no test at all; a bug fix with no regression test pinning it; a new branch, error path, or edge case with no corresponding case.
- Silenced tests: a test deleted, skipped, or quarantined (`@Disabled`, `xit`, `.skip`, `#[ignore]`) in the same diff that changes the behavior it guarded, with no replacement or stated justification — not a finding when the diff removes that behavior itself.
- Missing negative & boundary cases: only the happy path tested; no empty/null/zero/max/duplicate inputs; no invalid-input or failure-path assertions; a new or changed encode/decode or serialize/parse pair tested only by hand-picked examples where a single round-trip property (`decode(encode(x)) == x`) would pin the contract — suggest as P3, and only when a property-testing library is already a dev dependency.
- Missing risk-specific tests: no authorization/denied-access test on a permission change; no idempotency/retry/concurrency test on async work; no old-vs-new compatibility or rollback test on a migration; no privacy/logging test where sensitive data is handled.
- Weak assertions: a test that passes while the behavior is wrong; asserting on incidental output (a log line, ordering, a whole serialized blob) instead of the contract; a snapshot accepted without a semantic check; asserting "no throw" where a value must be checked; asserting only that *some* exception escapes (`assertThrows(Exception)`, bare `pytest.raises(Exception)`) where the contract names a specific error, so an unrelated failure passes; a tautological expected value computed by calling the code under test itself or by re-implementing its logic inside the test.
- Loosened assertions: an assertion weakened in the diff — exact equality relaxed to `contains`/`assertNotNull`/truthiness, a numeric tolerance widened, a snapshot regenerated wholesale — to make a behavior change pass without pinning the new contract; fine when the old assertion over-specified incidental output.
- Unverified outcomes: a test for a side-effecting call (save, publish, invalidate, send) that asserts only the return value or "no throw", never the resulting state; a test whose only assertions are mock verifications (`verify(...)`, `assert_called_with(...)`) with no assertion on the output or downstream state. This asks for outcome assertions to be added — not for more interaction assertions (see Implementation coupling; the two point in opposite directions).
- Implementation coupling: tests asserting internal calls, private structure, or mock call-counts that break on safe refactors without catching real bugs (change-detector tests) — a behavior-preserving refactor diff forced to rewrite many tests is the diff-time signal; new UI tests selecting by DOM structure, CSS class, or child index where a user-visible role, label, or text query exists (not a finding when no accessible query can reach the element).
- Brittleness & flake: real timers, real network, real clock, or randomness without seeding; order-dependent tests or shared mutable fixtures; reliance on wall-clock sleeps instead of waiting on an explicit condition; a retry/flake annotation (`@Retry`, `retries:`) added to a test instead of removing the nondeterminism it papers over (acceptable as an explicitly temporary quarantine with a tracking reference); asserting on result order from a source whose contract guarantees none (a query without `ORDER BY`, set/map iteration, results pushed as concurrent tasks complete) — unless ordering is part of the contract.
- Misleading tests: a test name or description that contradicts what it asserts; over-mocking that tests the mock rather than the integration; fixtures missing the realistic or edge-shaped data that would actually trigger the bug; conditional test logic — an assertion inside an `if` or a loop that can run zero times, so the test passes vacuously on exactly the inputs that matter.

## High-signal locations

- The test file (or its absence) sitting next to each changed source file.
- New conditional branches, error paths, and early returns in the diff with no matching test case.
- Mocked boundaries that stand in for the exact dependency or integration the change affects.
- Assertions that changed in the diff — confirm they still pin the contract, not just the new output.

## Common false positives

Do not report these:

- Untested code the diff did not change (out of scope unless the change made it newly reachable).
- Missing tests for a trivial, behavior-preserving refactor or rename.
- A second test layer (e.g. E2E) when a unit test already covers the changed behavior adequately.
- A mock that is appropriate and clearly not hiding the integration under review.

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P1: a change to money, auth, data mutation, or a migration shipped with zero meaningful coverage; a test that asserts nothing yet guards a critical path.
- P2: a real behavior change missing its regression or boundary test; a weak assertion on an important path.
- P3: a brittle, redundant, or implementation-coupled test worth tidying, with no current correctness risk.

## No findings

- If clean: "No concrete tests findings found." (use the shared-rubric empty form).
