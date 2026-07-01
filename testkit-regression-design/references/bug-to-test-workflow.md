# Bug-to-test workflow

A real failure should become a durable test asset.

## 1. Capture evidence

Collect the report, stack trace, log excerpt, failing input, affected version, environment, and observed behavior. Redact secrets.

## 2. Separate facts from guesses

Facts:

- what happened
- what input/state was involved
- what version/configuration was affected

Guesses:

- suspected root cause
- probable timing window
- inferred dependency behavior

## 3. Define the contract

State what should have happened. If the intended behavior is unclear, write explicit acceptance criteria that a product owner or maintainer must confirm.

## 4. Minimize the trigger

Reduce to the smallest deterministic setup and action sequence. Prefer direct public contracts over broad end-to-end flows unless the bug requires the whole stack.

## 5. Choose the oracle

The oracle should fail for the actual bug, not only for incidental symptoms.

Examples:

- assert durable state, not only status code
- assert idempotency, not only no exception
- assert no duplicate side effect, not only success response
- assert cleanup, not only error returned

## 6. Add replay and ownership

Record where the test belongs, why it exists, and how to replay the original reduced case.
