# Failure taxonomy

Use this taxonomy for negative and failure cases in normal test design. For deep fault injection, fuzzing, or crash recovery, use `testkit-robustness-planning`.

## Input failures

- missing required value
- null or equivalent absence marker
- wrong type
- malformed structure
- out-of-range value
- duplicate value
- unsupported version
- conflicting fields
- unexpected extra field when strictness matters

## Permission and identity failures

- unauthenticated caller
- expired credential
- insufficient permission
- wrong tenant or scope
- revoked access
- confused-deputy path
- privilege escalation attempt

## State failures

- action before setup
- action after completion
- duplicate action
- retry after timeout
- update stale version
- concurrent modification
- cancelled operation reused

## Dependency failures

- external dependency returns error
- dependency times out
- dependency returns malformed response
- dependency is slow
- dependency succeeds but local commit fails

## Recovery and cleanup failures

- error occurs after partial side effect
- cleanup fails after primary failure
- retry encounters changed state
- cancellation happens during commit window

## Expected behavior rules

For each failure case, specify:

- error class or status
- user-visible message category when part of contract
- side effects that must not happen
- durable state that must remain unchanged or consistent
- retry behavior
- logging/monitoring only if part of the requirement
