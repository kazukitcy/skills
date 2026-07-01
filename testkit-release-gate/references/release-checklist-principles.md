# Release checklist principles

Release readiness is not the same as a green test run. A useful release gate combines evidence, judgment, and explicit risk acceptance.

## Keep humans in the loop

Automation can show pass/fail evidence. Human review should inspect:

- unexpected warnings
- skipped or quarantined tests
- new flakiness
- known issues
- ambiguous requirements
- undocumented behavior changes
- rollback and monitoring readiness
- risks accepted under conditional-go

## Use checklists to prevent omission

A checklist should make important omissions visible:

- What changed?
- What user-visible contracts changed?
- Which tests prove the critical paths still work?
- Which regressions were added?
- Which platforms/configurations were checked?
- What is skipped, flaky, or not applicable?
- What would trigger rollback?

## Separate evidence from decision

Evidence:

- test results
- coverage/mutation/robustness status
- performance data
- manual verification
- known issue review

Decision:

- go
- conditional-go with explicit owner and mitigation
- no-go

## Scale to impact

A small internal tool does not need the same release gate as a security boundary, payment workflow, data migration, infrastructure library, or externally distributed component. Scale checklist depth to blast radius.
