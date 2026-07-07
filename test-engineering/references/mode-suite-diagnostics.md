# Mode: suite-diagnostics

Diagnose the quality of an existing test suite. Treat coverage and mutation
results as evidence about the tests, not as direct proof of product quality.

## Workflow

1. Classify the input: coverage, mutation, flaky, CI failure, slow test,
   skipped test, weak assertion, or mixed.
2. Identify what is actually unverified: path not executed, branch side not
   taken, condition interaction missing, behavior touched but not asserted,
   mutant survived, nondeterministic setup, or environment instability.
3. Classify findings:
   - missing behavior check
   - weak oracle
   - unreachable code
   - defensive branch
   - equivalent mutant
   - optimization-only branch
   - flaky infrastructure
   - slow or oversized test
   - skipped or quarantined risk
4. Recommend the smallest high-signal improvement: add assertion, add
   boundary case, add invariant, add differential oracle, split a test,
   delete dead code, mark intentional defensive branch, or move slow work to
   a deeper lane.
5. Prioritize findings P0/P1/P2 and identify which should block release.

## Output format

Use `assets/diagnostics-report-template.md`.

Include:

- executive summary
- evidence reviewed
- finding table with classification
- recommended tests or assertions
- coverage/mutation interpretation
- flaky/CI recommendations when applicable
- release risk if relevant

## Mode references

- Read `coverage-interpretation-rules.md` for branch, MC/DC, defensive, and
  boundary coverage interpretation and instrumented-vs-delivered
  configuration checks.
- Read `mutation-taxonomy.md` for surviving mutant triage.
- Read `flaky-test-triage-rules.md` for nondeterminism and CI issues.
- Read `oracle-patterns.md` (weak oracle patterns and strength checklist) for
  assertion improvements.
- Read `prioritization-rules.md` when ranking findings P0/P1/P2.

## Quality bar

A good diagnostic report explains why a number or mutant matters. It does not
say "increase coverage" without naming the missing behavior and oracle. It
distinguishes unreachable or defensive code from genuinely untested behavior.

## Mode gotchas

- Do not mechanically require 100% coverage for every project. Scale coverage
  targets to risk, maintenance cost, and expected confidence.
- Do not treat static analyzer warnings as automatically correct. Classify
  them and decide whether code, tests, or documentation should change.
- Do not accept a killed mutant as strong evidence if the failure was a
  timeout or unrelated crash unless that is the intended oracle.
