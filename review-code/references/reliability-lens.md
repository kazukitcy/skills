# Review Code: Reliability

> How the change behaves under concurrency, retries, partial failure, and
> timeouts — the failure modes that only appear in production. Severity,
> confidence, evidence, and output format live in references/shared-rubric.md —
> read it too.

## Scope

- Correct behavior when operations run concurrently, retry, time out, arrive out
  of order, or fail halfway.
- Adjacent lenses (route there, don't double-report): single-flow logic bugs →
  correctness; migration safety and deploy ordering → release; deliberate abuse of
  these weaknesses → adversarial.

## What to look for

- Race conditions: check-then-act on shared state (read-modify-write without a lock or atomic op); a TOCTOU gap between validation and use; an unsafe concurrent update to the same row/key/file; a read-after-write that can observe stale state.
- Idempotency: a non-idempotent side effect (charge, email, insert, increment) on a path that can be retried (webhook, queue consumer, job, client retry); duplicate processing of the same message with no dedup key; an "exactly once" assumption the infrastructure does not guarantee; an idempotency key whose side effect executes before the key is persisted (a crash between them re-executes on retry), whose TTL is shorter than the caller's retry window, or whose in-progress lock has no expiry.
- Retries & backpressure: a retry with no backoff/jitter or no cap (retry storm); a retry added around a client or SDK that already retries at its own layer, multiplying attempts (N×M) against a failing dependency; retrying a non-retryable error; no circuit breaker or bound on in-flight work; a failure that re-enqueues forever (poison message); fixed-interval polling, cron, or reconnect delays identical across all instances with no jitter, so the whole fleet fires at once — worst exactly while a dependency is recovering.
- Timeouts & resource limits: a network/DB/RPC call with no timeout, or an unbounded wait; a connection/handle/subscription not released on the error path; an unbounded queue or buffer; a downstream call given a fresh full timeout or no cancellation from its caller, so work and retries continue after the caller has already timed out and given up (report only where a deadline/cancellation mechanism already exists in the call path — Go `context`, gRPC deadline, `AbortSignal` — and the diff drops it).
- Transactions & partial failure: a multi-step write (multiple tables/stores/services) with no transaction or saga, leaving inconsistent state if a later step fails; missing compensation/rollback; a database commit and a message publish as two separate writes with no outbox or equivalent, so a crash between them silently drops the event (dual-write); an event or message published inside an open transaction before commit, so a rollback leaves consumers holding a ghost event for a write that never happened.
- Locks & ordering: a missing lock where concurrent callers collide, or an over-broad lock risking deadlock/starvation; reliance on queue or event ordering that is not guaranteed; a TTL/lease lock (e.g. Redis `SET NX EX`) guarding a correctness-critical write with no fencing token or conditional-write/version check enforced by the guarded resource, so a holder stalled past the TTL (GC pause, slow I/O) resumes and writes concurrently with the new holder; lease expiry, dedup windows, or cross-node ordering computed from wall-clock time that can step or differ between machines (only when the computed duration gates a correctness decision, not metrics/logging).
- Version & schema skew: a background worker or consumer that can receive a payload from a newer or older producer than itself; an enqueued job whose code shape changed between enqueue and run.
- Shutdown & draining: a worker loop, server, or consumer with no termination handling, so a routine deploy kills it mid-message with in-flight work neither completed nor nacked; buffered in-memory state (batches, pending acks, write-behind queues) with no flush on shutdown.
- Health checks: a health/readiness endpoint that fails when an external dependency check fails, so a shared-dependency outage marks every instance unhealthy at once and the whole fleet is deregistered or restarted together; a dependency check wired to a liveness/restart probe rather than readiness — confirm the endpoint is actually on a removal/restart path before reporting.
- Fallback paths: a new alternate mechanism (secondary store, cached copy, degraded code path) that runs only when the primary fails, so its first real execution happens during an outage — flag only a fallback with its own I/O or nontrivial logic that can violate consistency, freshness, or timeout expectations when it engages, not a constant default value (whether it is tested routes to tests).
- Failure visibility: a swallowed failure (empty catch, ignored rejected promise) on an operation that matters; success returned or logged after a step actually failed.

## High-signal locations

- Handlers for webhooks, queue/stream messages, and scheduled or background jobs.
- Multi-step writes that span more than one table, store, or external service.
- External calls (HTTP/DB/RPC) and whether each has an explicit timeout and bounded retry.
- Shared mutable resources updated by more than one request/worker (counters, balances, status fields, files).
- Queue/stream consumer registrations and their retry configuration: max attempts/`maxReceiveCount`, dead-letter binding, and any catch-all that re-enqueues unconditionally.

## Common false positives

Do not report these:

- Single-threaded, request-scoped code with no shared mutable state and no retry path.
- Idempotency already enforced by a unique key, constraint, or upsert — confirm it before reporting (a DB constraint settles it; a TTL'd cache key does not — check the TTL against the retry window).
- Operations a framework, transaction, or atomic DB feature already makes safe.
- A timeout/retry already provided by a layer the call goes through (client, gateway, framework default) — verify the layer actually retries in this configuration; an assumed-but-disabled SDK default is the original missing-timeout/retry finding, and an SDK retry plus a newly added wrapper retry is the N×M finding — neither is a false positive.
- A shutdown or drain the platform already performs (a framework graceful-shutdown default, broker redelivery after visibility timeout that an idempotent handler tolerates).
- A TTL lock that only avoids redundant work (efficiency, not correctness) — fencing matters only when the guarded write must not run concurrently.

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P1: partial failure that corrupts or desynchronizes persisted state; a non-idempotent money/data mutation on a retried path; a deadlock or unbounded resource leak reachable in normal operation.
- P2: a race or missing timeout that degrades service but recovers; a retry without backoff that adds load under failure.
- P3: defensive hardening with no demonstrated failure path under the current code.

## No findings

- If clean: "No concrete reliability findings found." (use the shared-rubric empty form).
