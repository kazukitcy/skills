# Release readiness review

Risk categories, checklist items, and human review prompts for the
release-gate mode. Use the risk taxonomy to decide what the gate must cover,
the pre-release checks to collect evidence, and the manual review prompts to
complement automated evidence.

## Risk taxonomy

### User-visible behavior

- changed workflows
- changed errors
- changed compatibility
- changed defaults

### Data and persistence

- migration
- irreversible write
- data loss
- data corruption
- backup and restore

### Security and access control

- authentication
- authorization
- tenant isolation
- credential handling
- audit logging

### Reliability

- retry behavior
- idempotency
- timeout handling
- resource exhaustion
- degradation mode

### Performance

- latency
- throughput
- memory or resource usage
- startup time
- slow path introduced by feature flags

### Operability

- logs
- metrics
- alerts
- dashboards
- rollback plan
- feature flag control

### Compatibility

- client versions
- API changes
- file or protocol format
- platform/configuration matrix
- dependency versions

## Pre-release checks

### Automated evidence

- unit tests passed
- integration tests passed
- critical end-to-end flows passed
- focused regression tests added for fixed bugs
- coverage and mutation gaps reviewed for changed areas
- robustness/fuzz evidence reviewed where applicable
- performance checks passed or changes accepted

### Negative evidence review

- skipped tests
- flaky tests
- new warnings
- ignored static analysis reports
- failing non-blocking jobs
- stale known issues
- unverified rollback

### Platform/configuration matrix

Review the supported matrix:

- operating environment
- runtime version
- feature flag combinations
- debug/release or instrumented/delivered configuration
- dependency versions
- deployment topology

### Documentation and compatibility

- public docs updated
- migration notes written
- changelog updated
- compatibility risks named
- deprecated behavior documented

### Rollback and monitoring

- rollback path tested or reviewed
- monitoring dashboard ready
- alert thresholds known
- owner on call
- post-release verification steps defined

## Manual review prompts

### Scope

- What changed in user-visible behavior?
- What did not change but could be affected indirectly?
- Which assumptions are not tested automatically?

### Evidence

- Which critical paths have independent evidence?
- Which tests are new for this release?
- Which failures were waived and why?
- Which test results are stale?

### Risk

- What is the worst plausible failure?
- How quickly would we detect it?
- How quickly could we roll back or mitigate?
- What risk is accepted under conditional-go?

### Ambiguity

- Which expected behaviors remain unclear?
- Are we accidentally locking in behavior that was never intended?
- Are release notes and docs aligned with test expectations?

### Decision

- What would make this a no-go?
- Who owns each accepted risk?
- What post-release checks must happen?
