# Test portfolio and CI layering

Choose test types by risk, then place each type in a CI lane by execution
cost. The portfolio decides what evidence exists; the layering decides when
each piece of evidence arrives.

## Test portfolio patterns

Choose a portfolio based on risk, not fashion. Each test type should have a
job.

### Unit-level checks

Best for pure logic, small state transitions, error handling, and fast
feedback. Weak for integration contracts and real dependency behavior.

### Public contract checks

Exercise the externally supported API, CLI, protocol, UI, or library surface.
These should avoid privileged internal hooks unless the product contract
includes them.

### Integration checks

Verify that major components communicate correctly. Keep them fewer and
higher-signal than unit tests.

### End-to-end checks

Exercise user-visible workflows. Use for critical journeys and compatibility,
not every edge case.

### Differential checks

Compare two independent implementations, old vs new behavior, optimized vs
unoptimized behavior, or model vs implementation. Use when expected outputs
are hard to enumerate manually.

### Metamorphic and invariant checks

Use when exact expected values are hard but relations are known: reordering
inputs should preserve a total, encode/decode should round-trip, repeated
idempotent operations should not duplicate effects.

### Robustness checks

Fault injection, malformed inputs, randomized generation, recovery, and
resource lifecycle checks belong here.

### Release checks

Combine automated evidence with manual review, platform/configuration matrix,
known issue review, and rollback readiness.

## CI layering

Use test layers to balance feedback speed and confidence. Every portfolio
entry above should land in at least one lane below; a test type with no lane
is a recommendation nobody runs.

### Local fast path

Target: seconds to a few minutes.

Include:

- deterministic unit tests
- small contract tests
- focused regression tests for recently changed areas
- quick static checks when they are reliable

Avoid:

- long randomized runs
- broad matrix builds
- external services that frequently flake

### PR or merge gate

Target: reliable enough to block shared branches.

Include:

- local fast path
- integration checks for changed surfaces
- representative end-to-end checks
- critical security/permission checks
- smoke tests for packaging or deployment shape

### Nightly or deep checks

Target: confidence beyond PR latency.

Include:

- broad platform/configuration matrix
- mutation or condition coverage reviews
- long randomized/property/fuzz runs
- slow compatibility tests
- performance and resource lifecycle checks

### Release candidate gate

Target: shipping decision.

Include:

- clean PR and nightly evidence
- known issue review
- rollback validation
- manual review prompts
- platform/configuration sign-off
- skipped/flaky test review

### Soak or continuous lanes

Target: rare failures and drift.

Include:

- long-running fuzzers
- repeated flaky detection
- stability and resource leak monitoring
- performance trend detection

After assigning types to lanes, audit the result with
`harness-independence-checks.md`: a portfolio whose harnesses share the same
fixtures, mocks, or expected-value helpers is one suite wearing several
names.
