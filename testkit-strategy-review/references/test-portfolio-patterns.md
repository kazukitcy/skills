# Test portfolio patterns

Choose a portfolio based on risk, not fashion. Each test type should have a job.

## Unit-level checks

Best for pure logic, small state transitions, error handling, and fast feedback. Weak for integration contracts and real dependency behavior.

## Public contract checks

Exercise the externally supported API, CLI, protocol, UI, or library surface. These should avoid privileged internal hooks unless the product contract includes them.

## Integration checks

Verify that major components communicate correctly. Keep them fewer and higher-signal than unit tests.

## End-to-end checks

Exercise user-visible workflows. Use for critical journeys and compatibility, not every edge case.

## Differential checks

Compare two independent implementations, old vs new behavior, optimized vs unoptimized behavior, or model vs implementation. Use when expected outputs are hard to enumerate manually.

## Metamorphic and invariant checks

Use when exact expected values are hard but relations are known: reordering inputs should preserve a total, encode/decode should round-trip, repeated idempotent operations should not duplicate effects.

## Robustness checks

Fault injection, malformed inputs, randomized generation, recovery, and resource lifecycle checks belong here.

## Release checks

Combine automated evidence with manual review, platform/configuration matrix, known issue review, and rollback readiness.
