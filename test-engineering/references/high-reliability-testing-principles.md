# High-reliability testing principles

Use these principles as design guidance, not as a mandate to copy any
particular project's tools or rigor.

- **Independent evidence beats one large monoculture suite.** A single suite
  shares fixtures, mocks, generated data, and one mental model; one flawed
  assumption can hide a defect everywhere. Independence dimensions and red
  flags are in `harness-independence-checks.md`.
- **Execution cost should be layered.** Separate fast feedback from deep
  confidence instead of putting every expensive test in the PR lane or
  omitting deep tests entirely. The lane definitions are in
  `test-portfolio-and-layering.md`.
- **Requirements should be traceable to tests.** Extract testable statements
  from specs, docs, schemas, and public contracts, and map each to tests or
  mark it missing, partial, or ambiguous.
- **Robustness is part of correctness.** A system is not only correct when
  the machine and inputs are friendly: test dependency failure, partial
  operations, interruption, malformed inputs, limits, retries, and cleanup.
- **Coverage is a meta-test of the tests.** Coverage shows what the tests
  executed, not product quality; a high-coverage test with weak assertions
  may still verify little.
- **Every discovered bug should become a deterministic regression test.** A
  fix is not complete until a focused test would have failed before it and
  passes after it, with the trigger preserved and minimized.
- **Human review should remain in the release loop.** Automation gathers
  evidence; humans review unexpected warnings, skipped tests, newly accepted
  risk, ambiguous behavior, and rollback readiness.
