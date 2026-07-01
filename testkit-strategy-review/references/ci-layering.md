# CI layering

Use test layers to balance feedback speed and confidence.

## Local fast path

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

## PR or merge gate

Target: reliable enough to block shared branches.

Include:

- local fast path
- integration checks for changed surfaces
- representative end-to-end checks
- critical security/permission checks
- smoke tests for packaging or deployment shape

## Nightly or deep checks

Target: confidence beyond PR latency.

Include:

- broad platform/configuration matrix
- mutation or condition coverage reviews
- long randomized/property/fuzz runs
- slow compatibility tests
- performance and resource lifecycle checks

## Release candidate gate

Target: shipping decision.

Include:

- clean PR and nightly evidence
- known issue review
- rollback validation
- manual review prompts
- platform/configuration sign-off
- skipped/flaky test review

## Soak or continuous lanes

Target: rare failures and drift.

Include:

- long-running fuzzers
- repeated flaky detection
- stability and resource leak monitoring
- performance trend detection
