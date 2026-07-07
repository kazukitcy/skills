# Robustness patterns

Fault injection, fuzzing, corrupt-input, crash-recovery, and resource
lifecycle patterns for the robustness-planning mode. Each section maps to a
required section of the robustness plan output.

## Fault injection

### Nth failure

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

### Persistent failure

After the first injected failure, all later operations of that class fail.

Oracle:

- graceful degradation
- stable error reporting
- bounded retries
- cleanup still attempted

### Partial operation

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

### Timeout

Dependency or operation does not complete within the allowed window.

Oracle:

- cancellation or timeout result
- no orphaned in-flight work if contract requires cancellation
- retry behavior is safe

### Cancellation

Caller cancels during work.

Oracle:

- cleanup occurs
- no invalid partial state
- cancellation is distinguishable from other errors if required

### Compound failure

Primary operation fails, then cleanup, rollback, notification, or retry also
fails.

Oracle:

- highest-priority invariant is preserved
- error reporting does not hide critical state
- no infinite retry loop
- no unbounded resource growth

## Corrupt input

Use corrupt-input tests for parsers, importers, decoders, protocol handlers,
and any boundary that accepts external structured data.

### Corruption methods

- truncate input
- flip selected bytes or tokens
- corrupt length/count fields
- change version marker
- remove required section
- duplicate unique section
- reorder sections
- insert invalid encoding
- create inconsistent references
- combine valid pieces from incompatible examples

### Expected outcomes

Specify:

- controlled rejection
- stable error category
- no unsafe behavior
- no durable side effect unless explicitly allowed
- no resource leak
- no excessive runtime or memory growth

### Positive control

Start from at least one valid example so the test proves the corruption, not
the fixture, causes rejection.

### Regression path

When a corrupt input reveals a bug:

- save original input
- minimize it
- document corruption method
- add deterministic regression case

## Fuzzing

Fuzz the structured state of the system, not only one flat string.

### Identify input structure

Examples of multi-part input states:

- request body + authentication state + existing persisted state
- file contents + format version + import options
- event sequence + current time + previously processed events
- command arguments + environment variables + working directory contents
- message payload + schema version + consumer offset

### Seed corpus

Include:

- small valid examples
- known edge cases
- previous regressions
- boundary values
- malformed examples that should be rejected cleanly
- compatibility examples from older versions

### Mutation strategy

Mutate at the level of structure when possible. Use the corruption methods
above as the base mutation set, plus mutations only generation can express:

- add or remove fields
- alter timing or event sequence
- interleave concurrent operations
- grow inputs toward size and resource limits

### Oracles

Choose at least one:

- no unexpected crash or unhandled exception
- invariant preserved
- controlled rejection
- semantic equivalence across implementations or modes
- round-trip preservation
- no leak or unbounded growth
- replayable failure capture

### Replay and minimization

Every failure should record:

- seed
- mutated input
- configuration
- generated sequence
- random seed
- reduced/minimized reproduction
- regression test location

### Avoid

- random generation with no oracle
- failures that cannot be replayed
- corpora that only contain happy-path examples
- fuzzing only the easiest input while ignoring related state

## Crash and interruption recovery

Use these patterns for systems with persistent state, external side effects,
or multi-step workflows.

### Interruption points

Identify critical windows:

- after validation but before side effect
- after first side effect but before commit marker
- during commit
- after commit but before response
- during cleanup
- during retry or recovery

### Recovery oracles

After restart or retry, verify:

- all-or-nothing state when promised
- no duplicated side effect
- idempotent retry
- invariant preserved
- pending work is either resumed or safely abandoned
- user-visible result is consistent with durable state

### Snapshot model

When possible, compare state before, during, and after interruption:

- pre-action snapshot
- interrupted snapshot
- recovered snapshot
- post-retry snapshot

### Stable failure signal

The test should define what counts as success:

- operation fully applied
- operation fully rolled back
- operation marked pending with safe resume
- operation returns a documented recovery error

### Avoid

- checking only that restart succeeds
- ignoring duplicate side effects
- relying on uncontrolled process timing when deterministic interruption
  hooks are available
- leaving the recovery state uninspected

## Resource lifecycle checks

Resources should be released on success, failure, cancellation, timeout,
retry, and recovery.

### Resource types

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

### Lifecycle points

For each resource, identify:

- acquisition
- ownership transfer
- normal release
- release after failure
- release after cancellation
- release after timeout
- release after retry
- release after crash/recovery if applicable

### Test patterns

- success path leaves no extra resources
- validation failure releases resources acquired before validation completed
- dependency failure releases resources acquired earlier
- cancellation releases resources promptly
- retry does not leak one resource per attempt
- repeated operation has stable resource usage
- cleanup failure is surfaced or handled according to contract

### Oracle

Use a project-appropriate mechanism to verify:

- no leaked handle or connection
- no unbounded memory growth
- no orphaned background work
- no leftover temporary artifact
- no lock held after completion
- no dangling subscription or timer

### Output requirement

A robustness plan should name the resource, lifecycle path, failure mode, and
observation method. Do not merely say "check for leaks".
