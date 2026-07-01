# Fault injection patterns

## Nth failure

Inject failure at the Nth relevant operation.

Plan:

- identify operation sequence
- choose failure type
- run N from 1 until the operation completes
- record failing N values and observed behavior

Oracle:

- controlled error
- no partial invalid state
- no resource leak
- retry safety if required

## Persistent failure

After the first injected failure, all later operations of that class fail.

Oracle:

- graceful degradation
- stable error reporting
- bounded retries
- cleanup still attempted

## Partial operation

An operation reports partial progress.

Examples:

- partial read
- partial write
- partial response
- partial batch completion

Oracle:

- documented partial behavior or rollback
- no duplicated side effects on retry
- progress is observable if the contract promises it

## Timeout

Dependency or operation does not complete within the allowed window.

Oracle:

- cancellation or timeout result
- no orphaned in-flight work if contract requires cancellation
- retry behavior is safe

## Cancellation

Caller cancels during work.

Oracle:

- cleanup occurs
- no invalid partial state
- cancellation is distinguishable from other errors if required

## Compound failure

Primary operation fails, then cleanup, rollback, notification, or retry also fails.

Oracle:

- highest-priority invariant is preserved
- error reporting does not hide critical state
- no infinite retry loop
- no unbounded resource growth
