# Review Code: Design & Maintainability

## Scope rules

- Review only design and maintainability.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Look for

- misplaced responsibility; layering or dependency-direction violations
- domain model inconsistencies; duplicated business logic
- unclear or unstable API contracts; accidental public API changes
- backward compatibility risks; tight coupling introduced by the change
- configuration or policy logic embedded in the wrong layer
- abstractions that hide important failure modes
- unnecessary generalization that obscures behavior; insufficient encapsulation of invariants
- naming that materially misleads about behavior
- code structure likely to cause future unsafe edits

## Shared rubric

Read `references/shared-rubric.md` and apply its required-evidence checklist,
severity scale, confidence rule, calibration, final check, and output format.
In the empty-findings form, name this checklist: "No concrete design findings found."
