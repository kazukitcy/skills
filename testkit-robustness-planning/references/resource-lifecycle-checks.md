# Resource lifecycle checks

Resources should be released on success, failure, cancellation, timeout, retry, and recovery.

## Resource types

- memory or object handles
- file handles
- sockets or streams
- persistent connections
- locks
- temporary files or directories
- worker tasks
- timers
- subscriptions
- transactions or units of work
- external resources created during tests

## Lifecycle points

For each resource, identify:

- acquisition
- ownership transfer
- normal release
- release after failure
- release after cancellation
- release after timeout
- release after retry
- release after crash/recovery if applicable

## Test patterns

- success path leaves no extra resources
- validation failure releases resources acquired before validation completed
- dependency failure releases resources acquired earlier
- cancellation releases resources promptly
- retry does not leak one resource per attempt
- repeated operation has stable resource usage
- cleanup failure is surfaced or handled according to contract

## Oracle

Use a project-appropriate mechanism to verify:

- no leaked handle or connection
- no unbounded memory growth
- no orphaned background work
- no leftover temporary artifact
- no lock held after completion
- no dangling subscription or timer

## Output requirement

A robustness plan should name the resource, lifecycle path, failure mode, and observation method. Do not merely say "check for leaks".
