# Anomaly testing principles

Robust systems must be tested when inputs, resources, dependencies, and execution are unfriendly.

## Nth failure injection

Inject failure at the Nth resource acquisition, operation, or dependency call. Repeat with N increasing until the target operation completes without injected failure.

Use for:

- memory or resource acquisition
- file or stream operation
- network call
- persistent storage operation
- lock acquisition
- queue or message operation
- dependency request

Check both:

- single failure: only the Nth operation fails
- persistent failure: the Nth and all later operations fail

## Compound failure

Test what happens when recovery itself fails:

- cleanup operation fails
- rollback fails or is interrupted
- retry encounters changed state
- logging or notification fails after primary failure
- second dependency fails while handling the first failure

## Crash or interruption

Interrupt execution during state transitions and verify recovery:

- operation completed entirely
- operation rolled back entirely
- no partial durable state remains unless explicitly allowed
- retry is safe
- invariants hold

## Malformed or corrupt input

Start from valid structured input, corrupt targeted regions, and verify controlled rejection without unsafe behavior or persistent damage.

## Resource lifecycle

Track resources through success, failure, cancellation, retry, timeout, and recovery. No test should leave hidden resources behind.

## Replayability

Every discovered anomaly must have:

- seed or reduced input
- fault injection point
- configuration
- expected failure signal
- minimized regression path
