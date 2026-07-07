# Oracle patterns

An oracle is the rule that decides whether a test passed. Weak oracles make tests look useful while verifying little.

## Explicit expected value

Use when the spec defines an exact result, error, state change, or event.

Example:

- action returns status `created`
- invalid input returns a validation error
- no side effect is persisted after rejection

## Differential oracle

Use when a reference implementation, previous version, independent model, or alternate execution path exists. Compare semantic behavior rather than incidental formatting unless formatting is part of the contract.

Examples:

- old implementation vs new implementation during a rewrite
- optimized path vs baseline path
- independently written model vs production implementation

## Metamorphic oracle

Use when exact results are hard to enumerate but relationships are known.

Examples:

- sorting input should not change a total
- adding an irrelevant field should not affect authorization
- splitting a batch into smaller batches should produce equivalent final state

## Invariant oracle

Use for stateful behavior.

Examples:

- total count never becomes negative
- rejected operations produce no durable side effects
- access control decisions never grant permissions outside policy
- cleanup leaves no open resources

## Round-trip oracle

Use for encode/decode, serialize/deserialize, import/export, migration, or transformation tasks.

Examples:

- encode then decode preserves semantic value
- export then import preserves records and relationships
- migration forward and compatibility check preserves user-visible state

## Configuration-equivalence oracle

Use when implementation mode should not alter semantics.

Examples:

- cache on/off
- feature flag old/new path
- debug/release configuration
- single-thread/multi-thread execution when semantics should match
- optimized/baseline path

## Runtime instrumentation oracle

Use when the expected result includes absence of unsafe behavior.

Examples:

- no resource leak
- no invalid access
- no data race
- no unhandled exception
- no undefined or platform-dependent result

## Weak oracle patterns

Use these when diagnosing or strengthening existing assertions.

### Only checks success/no-throw

Risk: wrong result or side effect can pass. Improve by asserting returned data, state change, emitted event, or invariant.

### Only checks status or error class

Risk: wrong body, wrong durable state, or duplicate side effect can pass. Improve by asserting state and side effects.

### Reuses production logic to compute expected result

Risk: the same bug exists in the implementation and expected-value helper. Improve by using a simpler independent model, table of examples, invariant, or differential oracle.

### Ignores negative side effects

Risk: rejected operation still changes state. Improve by asserting no side effect or unchanged snapshot.

### Ignores cleanup

Risk: tests pass but resources leak. Improve by checking resource lifecycle after success, failure, cancellation, and retry.

### Ambiguous expected behavior

Risk: tests encode accidental behavior. Improve by marking ambiguity and requesting contract clarification before locking it in.

## Oracle strength checklist

- Does the test assert the externally visible behavior a user or integrator would notice?
- Does it assert side effects and durable state when relevant?
- Does it assert what must not happen, and the invariant that should always hold?
- Does it fail for the specific bug or risk, including prior bugs?
- Could the implementation be wrong while the test still passes?
- Does the oracle rely on the same logic as the implementation?
