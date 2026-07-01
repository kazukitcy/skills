# Requirement extraction

Extract testable behavioral statements from project artifacts and map them to tests.

## Source artifacts

Use public, user-visible, or externally meaningful sources first:

- product specs
- API docs
- protocol or schema definitions
- README and user guides
- acceptance criteria
- issue descriptions
- source comments only when they define intended behavior
- existing tests only as evidence, not as the source of truth

## Testable requirement shape

A good requirement is specific enough to test:

- actor or caller
- initial state
- action or input
- expected externally visible result
- error or recovery behavior when relevant

Good:

- `R-001: A missing required field is rejected with a validation error.`
- `R-002: Repeating an idempotent operation with the same key returns the same logical result.`

Weak:

- `The system should be robust.`
- `The component should be fast.`
- `The implementation uses a cache.`

## Classification

Mark each extracted statement as:

- `covered`: existing tests verify it with a meaningful oracle
- `partial`: tests touch it but miss an important branch, state, or assertion
- `missing`: no test evidence found
- `ambiguous`: expected behavior cannot be determined from supplied artifacts
- `not-testable-as-written`: needs measurable acceptance criteria

## Requirement IDs

Use stable local IDs if the project has no existing IDs:

- `R-001`, `R-002`, ... for requirements
- `TC-001`, `TC-002`, ... for test cases

Do not create heavyweight traceability machinery unless the project already needs it.

## Extraction rules

- Extract behavior, not implementation details.
- Split compound statements into separate requirements.
- Keep negative and recovery behavior as first-class requirements.
- Record the source location when available.
- Preserve ambiguity rather than inventing expected behavior.


## Code-to-spec extraction

When source code is the primary artifact, infer specifications conservatively:

- Prefer externally observable behavior: public APIs, CLI output, return values, error values, persisted state, emitted events, and documented side effects.
- Treat private helper structure, temporary variables, branch order, caching choices, and incidental logging as implementation details unless users can observe them or the project documents them.
- Separate `observed behavior` from `intended requirement`. If the code appears buggy, preserve both: what the code currently does and what the surrounding docs or tests imply it should do.
- Mark behavior as `ambiguous` when source code alone does not reveal whether the behavior is intentional.
- Use existing tests as evidence, but do not assume existing tests cover the complete intended specification.
- For each inferred requirement, include evidence: file/function/test/doc section, observed inputs, observed outputs, and uncertainty.
