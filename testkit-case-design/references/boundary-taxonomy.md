# Boundary taxonomy

For every bounded input, state, and configuration, test inside the boundary, exactly at the boundary, and just outside the boundary.

## Size boundaries

- absent value
- empty value
- one item
- typical value
- maximum allowed value
- maximum plus one
- very large value that should be rejected or handled gracefully

## Numeric boundaries

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

## Text boundaries

- empty string
- whitespace only
- leading/trailing whitespace
- maximum length
- maximum plus one
- mixed case
- normalization-equivalent forms
- invalid encoding or replacement characters when the boundary accepts bytes or external text
- control characters
- separators and escape characters

## Time boundaries

- exact start and end time
- just before and after expiry
- month end
- leap year
- timezone conversion
- clock moving backward or forward
- stale timestamp
- duplicate timestamp

## State boundaries

- uninitialized
- already initialized
- completed
- cancelled
- failed then retried
- partially completed
- repeated idempotent action
- conflicting concurrent action

## Boolean vectors and flags

When multiple flags or conditions influence behavior, cover meaningful combinations, not only each flag independently.

Look for:

- every condition can independently affect the decision
- both true and false sides of important checks
- conflicting flags
- default vs explicit flag
- feature on/off with same semantic result when equivalence is expected

## Priority rule

Generate many boundaries, but prioritize the ones tied to public contracts, security boundaries, data loss, financial impact, compatibility, or previous regressions.
