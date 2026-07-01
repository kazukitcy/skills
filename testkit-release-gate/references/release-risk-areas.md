# Release risk areas

Use this list to identify what the release gate must cover.

## User-visible behavior

- changed workflows
- changed errors
- changed compatibility
- changed defaults

## Data and persistence

- migration
- irreversible write
- data loss
- data corruption
- backup and restore

## Security and access control

- authentication
- authorization
- tenant isolation
- credential handling
- audit logging

## Reliability

- retry behavior
- idempotency
- timeout handling
- resource exhaustion
- degradation mode

## Performance

- latency
- throughput
- memory or resource usage
- startup time
- slow path introduced by feature flags

## Operability

- logs
- metrics
- alerts
- dashboards
- rollback plan
- feature flag control

## Compatibility

- client versions
- API changes
- file or protocol format
- platform/configuration matrix
- dependency versions
