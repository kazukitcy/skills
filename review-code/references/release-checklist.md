# Review Code: Release & Operability

## Scope rules

- Review only release and operability.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Look for

- old-app/new-DB and new-app/old-DB incompatibility; unsafe schema migrations
- non-backward-compatible data changes; backfills that are not restartable
- missing rollback path; feature flag hazards
- config/env rollout problems; default config changes with production impact
- deploy ordering dependencies; background worker version skew
- missing operational metrics, logs, or alerts for new failure modes
- error messages not actionable in production; poor failure classification
- migration not safe under traffic; irreversible production action without a guard

## Shared rubric

Read `references/shared-rubric.md` and apply its required-evidence checklist,
severity scale, confidence rule, calibration, final check, and output format.
In the empty-findings form, name this checklist: "No concrete release findings found."
