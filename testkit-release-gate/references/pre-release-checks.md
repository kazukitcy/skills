# Pre-release checks

## Automated evidence

- unit tests passed
- integration tests passed
- critical end-to-end flows passed
- focused regression tests added for fixed bugs
- coverage and mutation gaps reviewed for changed areas
- robustness/fuzz evidence reviewed where applicable
- performance checks passed or changes accepted

## Negative evidence review

- skipped tests
- flaky tests
- new warnings
- ignored static analysis reports
- failing non-blocking jobs
- stale known issues
- unverified rollback

## Platform/configuration matrix

Review the supported matrix:

- operating environment
- runtime version
- feature flag combinations
- debug/release or instrumented/delivered configuration
- dependency versions
- deployment topology

## Documentation and compatibility

- public docs updated
- migration notes written
- changelog updated
- compatibility risks named
- deprecated behavior documented

## Rollback and monitoring

- rollback path tested or reviewed
- monitoring dashboard ready
- alert thresholds known
- owner on call
- post-release verification steps defined
