# Mode: release-gate

Build a release readiness checklist and quality gate. Make go/no-go or
conditional-go decisions based on automated evidence, manual review, known
risks, rollback readiness, and accepted gaps.

## Workflow

1. Identify release scope, changed areas, public contracts, and affected
   users.
2. Classify risks: data loss, security, compatibility, migration,
   performance, concurrency, observability, rollback,
   platform/configuration.
3. Collect evidence: automated tests, regression tests, coverage/mutation,
   robustness/fuzz, performance, static analysis, manual checks.
4. Look for negative evidence: skipped tests, flaky tests, new warnings,
   unreviewed failures, stale known issues, unverified rollback.
5. Define quality gate criteria:
   - go
   - conditional-go with explicit accepted risk and mitigation
   - no-go
6. Produce a checklist with owner/status fields and human review prompts.
7. Name release blockers and non-blocking follow-ups separately.

## Output format

Use `assets/release-checklist-template.md`.

Required sections:

- release scope
- risk summary
- automated evidence checklist
- manual review checklist
- platform/configuration matrix
- regression and known issue review
- rollback/monitoring readiness
- decision: go, conditional-go, or no-go

## Mode references

- Read `release-readiness-review.md` for the risk taxonomy, pre-release
  checklist items, and human-in-the-loop review prompts.

## Quality bar

A good release gate separates objective evidence from judgment, names
accepted risks explicitly, and makes it clear what would change the decision
from go to no-go.

## Mode gotchas

- Do not make a release decision solely from green tests. Check skipped
  tests, flakiness, unexpected warnings, known issues, and rollback
  readiness.
- Do not let static analysis warning cleanup override behavior preservation
  without tests.
- Do not hide conditional-go risks. Write them down with mitigations and
  owners.
- Do not apply the same gate depth everywhere. Scale checklist depth to blast
  radius: a small internal tool does not need the gate of a security
  boundary, payment workflow, or data migration.
