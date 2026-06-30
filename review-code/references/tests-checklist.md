# Review Code: Test Adequacy

## Scope rules

- Review only test adequacy.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Look for

- changed behavior without tests; missing regression, negative, or boundary tests
- missing authorization, privacy/logging, or migration compatibility tests
- missing retry, idempotency, or concurrency tests
- tests that pass while behavior is wrong; tests coupled to implementation details
- snapshot assertions without semantic checks
- flaky timing, ordering, randomness, or network assumptions
- mocks that hide integration bugs; fixtures that miss realistic data
- test names that contradict actual assertions

## Shared rubric

Read `references/shared-rubric.md` and apply its required-evidence checklist,
severity scale, confidence rule, calibration, final check, and output format.
In the empty-findings form, name this checklist: "No concrete tests findings found."
