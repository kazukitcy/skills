# Coverage as meta-test principles

Coverage measures test-suite reach, not product correctness. Treat coverage data as a test of the tests.

## What coverage can tell you

- which code paths were not executed
- which branches or conditions never took one side
- whether defensive or boundary paths are unobserved
- whether a release-like configuration behaves differently from an instrumented configuration

## What coverage cannot tell you

- whether expected behavior was asserted
- whether the oracle is strong
- whether the covered path handled side effects correctly
- whether random or generated inputs explored meaningful states
- whether the implementation matches user intent

## Compare instrumented and delivered configurations

Instrumentation, debug flags, or test-only hooks can change behavior. When feasible, compare important outputs or smoke tests across:

- instrumented vs delivered configuration
- debug vs release configuration
- feature flag on/off when semantics should match
- optimized vs baseline path

Unexpected differences deserve investigation.

## Defensive code handling

Not every unexecuted defensive branch is dead code. Classify it:

- unreachable by design and documented
- defensive for future change or hostile input
- reachable only through environmental failure
- reachable but missing test
- dead code that should be removed

## Coverage target rule

Coverage targets should follow risk. Maximum coverage may be justified for infrastructure, security, or data-critical components. For lower-risk areas, prioritize meaningful assertions over numeric completeness.
