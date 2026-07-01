# Crash and interruption recovery patterns

Use these patterns for systems with persistent state, external side effects, or multi-step workflows.

## Interruption points

Identify critical windows:

- after validation but before side effect
- after first side effect but before commit marker
- during commit
- after commit but before response
- during cleanup
- during retry or recovery

## Recovery oracles

After restart or retry, verify:

- all-or-nothing state when promised
- no duplicated side effect
- idempotent retry
- invariant preserved
- pending work is either resumed or safely abandoned
- user-visible result is consistent with durable state

## Snapshot model

When possible, compare state before, during, and after interruption:

- pre-action snapshot
- interrupted snapshot
- recovered snapshot
- post-retry snapshot

## Stable failure signal

The test should define what counts as success:

- operation fully applied
- operation fully rolled back
- operation marked pending with safe resume
- operation returns a documented recovery error

## Avoid

- checking only that restart succeeds
- ignoring duplicate side effects
- relying on uncontrolled process timing when deterministic interruption hooks are available
- leaving the recovery state uninspected
