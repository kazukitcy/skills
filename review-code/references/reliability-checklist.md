# Review Code: Reliability

## Scope rules

- Review only reliability.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Look for

- race conditions; non-idempotent retry behavior; duplicate job processing
- missing or ineffective timeouts; retry storms
- partial failure leaving inconsistent state; transaction boundary mistakes
- lock misuse or missing locks; deadlock or starvation risk
- queue ordering assumptions; eventual consistency gaps; missing compensation after failure
- background job version skew; unsafe concurrent updates; read-after-write assumptions
- failure swallowing or misleading success states

## Shared rubric

Read `references/shared-rubric.md` and apply its required-evidence checklist,
severity scale, confidence rule, calibration, final check, and output format.
In the empty-findings form, name this checklist: "No concrete reliability findings found."
