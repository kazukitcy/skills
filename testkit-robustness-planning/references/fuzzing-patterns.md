# Fuzzing patterns

Fuzz the structured state of the system, not only one flat string.

## Identify input structure

Examples of multi-part input states:

- request body + authentication state + existing persisted state
- file contents + format version + import options
- event sequence + current time + previously processed events
- command arguments + environment variables + working directory contents
- message payload + schema version + consumer offset

## Seed corpus

Include:

- small valid examples
- known edge cases
- previous regressions
- boundary values
- malformed examples that should be rejected cleanly
- compatibility examples from older versions

## Mutation strategy

Mutate at the level of structure when possible:

- add/remove fields
- reorder items
- duplicate entries
- corrupt length or count fields
- change version markers
- truncate input
- insert invalid encoding
- combine valid pieces in unusual order
- alter timing or event sequence

## Oracles

Choose at least one:

- no unexpected crash or unhandled exception
- invariant preserved
- controlled rejection
- semantic equivalence across implementations or modes
- round-trip preservation
- no leak or unbounded growth
- replayable failure capture

## Replay and minimization

Every failure should record:

- seed
- mutated input
- configuration
- generated sequence
- random seed
- reduced/minimized reproduction
- regression test location

## Avoid

- random generation with no oracle
- failures that cannot be replayed
- corpora that only contain happy-path examples
- fuzzing only the easiest input while ignoring related state
