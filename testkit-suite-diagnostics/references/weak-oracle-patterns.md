# Weak oracle patterns

## Only checks success/no-throw

Risk: wrong result or side effect can pass.

Improve by asserting returned data, state change, emitted event, or invariant.

## Only checks status or error class

Risk: wrong body, wrong durable state, or duplicate side effect can pass.

Improve by asserting state and side effects.

## Reuses production logic to compute expected result

Risk: the same bug exists in the implementation and expected-value helper.

Improve by using a simpler independent model, table of examples, invariant, or differential oracle.

## Ignores negative side effects

Risk: rejected operation still changes state.

Improve by asserting no side effect or unchanged snapshot.

## Ignores cleanup

Risk: tests pass but resources leak.

Improve by checking resource lifecycle after success, failure, cancellation, and retry.

## Ambiguous expected behavior

Risk: tests encode accidental behavior.

Improve by marking ambiguity and requesting contract clarification before locking it in.

## Oracle improvement checklist

- What behavior would a user or integrator notice?
- What state must be true after the action?
- What must not happen?
- What invariant should always hold?
- What prior bug would this fail for?
- Can the assertion be independent from implementation details?
