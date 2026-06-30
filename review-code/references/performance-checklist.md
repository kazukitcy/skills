# Review Code: Performance

## Scope rules

- Review only performance.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Look for

- N+1 database queries; unbounded loops over user-controlled or large data
- inefficient algorithms; unnecessary repeated (de)serialization or network calls
- missing pagination or batching; cache invalidation bugs or cache key mistakes
- memory growth or retention; loading full records when partial fields suffice
- blocking synchronous work in latency-sensitive paths; repeated expensive computation
- excessive logging in hot paths; performance-sensitive dependency changes
- query filters that defeat indexes

## Shared rubric

Read `references/shared-rubric.md` and apply its required-evidence checklist,
severity scale, confidence rule, calibration, final check, and output format.
In the empty-findings form, name this checklist: "No concrete performance findings found."
