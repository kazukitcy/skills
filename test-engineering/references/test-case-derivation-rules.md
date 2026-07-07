# Test case derivation rules

Requirement extraction, boundary taxonomy, and failure taxonomy for the
case-design mode: extract testable requirements from source material, then
derive boundary and failure cases from them.

## Requirement extraction

Extract testable behavioral statements from project artifacts and map them to
tests.

### Source artifacts

Use public, user-visible, or externally meaningful sources first:

- product specs
- API docs
- protocol or schema definitions
- README and user guides
- acceptance criteria
- issue descriptions
- source comments only when they define intended behavior
- existing tests only as evidence, not as the source of truth

### Testable requirement shape

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

### Classification

Mark each extracted statement as:

- `covered`: existing tests verify it with a meaningful oracle
- `partial`: tests touch it but miss an important branch, state, or assertion
- `missing`: no test evidence found
- `ambiguous`: expected behavior cannot be determined from supplied artifacts
- `not-testable-as-written`: needs measurable acceptance criteria

### Requirement IDs

Use stable local IDs if the project has no existing IDs:

- `R-001`, `R-002`, ... for requirements
- `TC-001`, `TC-002`, ... for test cases

Do not create heavyweight traceability machinery unless the project already
needs it.

### Extraction rules

- Extract behavior, not implementation details.
- Split compound statements into separate requirements.
- Keep negative and recovery behavior as first-class requirements.
- Record the source location when available.
- Preserve ambiguity rather than inventing expected behavior.

### Code-to-spec extraction

When source code is the primary artifact, infer specifications conservatively:

- Prefer externally observable behavior: public APIs, CLI output, return
  values, error values, persisted state, emitted events, and documented side
  effects.
- Treat private helper structure, temporary variables, branch order, caching
  choices, and incidental logging as implementation details unless users can
  observe them or the project documents them.
- Separate `observed behavior` from `intended requirement`. If the code
  appears buggy, preserve both: what the code currently does and what the
  surrounding docs or tests imply it should do.
- Mark behavior as `ambiguous` when source code alone does not reveal whether
  the behavior is intentional.
- Use existing tests as evidence, but do not assume existing tests cover the
  complete intended specification.
- For each inferred requirement, include evidence: file/function/test/doc
  section, observed inputs, observed outputs, and uncertainty.

## Boundary taxonomy

For every bounded input, state, and configuration, test inside the boundary,
exactly at the boundary, and just outside the boundary.

### Size boundaries

- absent value
- empty value
- one item
- typical value
- maximum allowed value
- maximum plus one
- very large value that should be rejected or handled gracefully

### Numeric boundaries

- zero
- one
- negative one
- minimum allowed value
- maximum allowed value
- just below minimum
- just above maximum
- overflow-adjacent values when applicable
- fractional values when integer-only behavior is expected
- non-finite values when the domain can express them

### Text boundaries

- empty string
- whitespace only
- leading/trailing whitespace
- maximum length
- maximum plus one
- mixed case
- normalization-equivalent forms
- invalid encoding or replacement characters when the boundary accepts bytes
  or external text
- control characters
- separators and escape characters

### Time boundaries

- exact start and end time
- just before and after expiry
- month end
- leap year
- timezone conversion
- clock moving backward or forward
- stale timestamp
- duplicate timestamp

### State boundaries

- uninitialized
- already initialized
- completed
- cancelled
- failed then retried
- partially completed
- repeated idempotent action
- conflicting concurrent action

### Boolean vectors and flags

When multiple flags or conditions influence behavior, cover meaningful
combinations, not only each flag independently.

Look for:

- every condition can independently affect the decision
- both true and false sides of important checks
- conflicting flags
- default vs explicit flag
- feature on/off with same semantic result when equivalence is expected

Generate many boundaries, then rank them with `prioritization-rules.md`.

## Failure taxonomy

Use this taxonomy for negative and failure cases in normal test design. For
deep fault injection, fuzzing, or crash recovery, use the robustness-planning
mode (`mode-robustness-planning.md`).

### Input failures

- missing required value
- null or equivalent absence marker
- wrong type
- malformed structure
- out-of-range value
- duplicate value
- unsupported version
- conflicting fields
- unexpected extra field when strictness matters

### Permission and identity failures

- unauthenticated caller
- expired credential
- insufficient permission
- wrong tenant or scope
- revoked access
- confused-deputy path
- privilege escalation attempt

### State failures

- action before setup
- action after completion
- duplicate action
- retry after timeout
- update stale version
- concurrent modification
- cancelled operation reused

### Dependency failures

- external dependency returns error
- dependency times out
- dependency returns malformed response
- dependency is slow
- dependency succeeds but local commit fails

### Recovery and cleanup failures

- error occurs after partial side effect
- cleanup fails after primary failure
- retry encounters changed state
- cancellation happens during commit window

### Expected behavior rules

For each failure case, specify:

- error class or status
- user-visible message category when part of contract
- side effects that must not happen
- durable state that must remain unchanged or consistent
- retry behavior
- logging/monitoring only if part of the requirement
