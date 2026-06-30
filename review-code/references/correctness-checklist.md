# Review Code: Correctness

## Scope rules

- Review only correctness.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Look for

- logic errors; incorrect conditionals; missing branches; wrong default behavior
- broken invariants; boundary value errors; off-by-one errors
- null, undefined, nil, empty, or absent value handling
- exception and error path bugs; incorrect state transitions
- async ordering bugs that change behavior
- incorrect parsing, serialization, or validation behavior
- behavior inconsistent with the apparent intent; regressions in existing behavior
- incorrect use of framework/library APIs

## Shared rubric

Read `references/shared-rubric.md` and apply its required-evidence checklist,
severity scale, confidence rule, calibration, final check, and output format.
In the empty-findings form, name this checklist: "No concrete correctness findings found."
