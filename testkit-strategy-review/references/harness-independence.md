# Harness independence

Independent harnesses reduce shared blind spots. Independence is not just a different filename or test framework.

## Independence dimensions

- different entry point: public API vs internal module
- different data source: curated examples vs generated cases
- different oracle: expected value vs invariant vs differential
- different environment: debug vs release, feature flag on/off, cache on/off
- different implementation path: old path vs new path, optimized vs baseline
- different authoring style: hand-written tests vs property tests vs scenario traces

## Red flags

- all tests use the same factory that encodes the same bad assumption
- tests assert only a status code or no-throw condition
- mocks reproduce the implementation instead of the contract
- high-level tests call the same helper as unit tests to compute expected values
- randomized tests have no replay path
- deep tests run only when someone remembers to run them

## Review questions

- What independent evidence would catch this if the main test helper were wrong?
- Which behavior is only verified by one style of test?
- Which public contracts are never exercised through the public surface?
- Which risks have only coverage evidence but no behavioral oracle?
