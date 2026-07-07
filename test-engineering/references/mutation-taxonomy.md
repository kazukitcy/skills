# Mutation taxonomy

Mutation testing asks whether tests detect small semantic changes. A surviving mutant needs triage, not automatic panic.

## Missing behavior check

The mutant changed behavior that should matter, but no test observes it.

Action: add a test tied to the public requirement.

## Weak oracle

The path runs, but assertions are too weak.

Action: assert state, side effects, invariants, returned data, error class, or emitted event as appropriate.

## Equivalent mutant

The changed code is semantically equivalent under the project's contract.

Action: document why equivalent, or simplify code if it improves clarity.

## Unreachable code

The mutant survives because the path cannot be reached.

Action: remove dead code, document intentional unreachable defensive code, or add a test if it is reachable through a valid failure mode.

## Defensive branch

The branch guards unexpected or hostile conditions.

Action: test through supported fault injection if practical; otherwise document the defensive intent and ensure runtime instrumentation or reviews cover it.

## Optimization-only branch

The branch affects performance or path choice but not semantic output.

Action: add performance/path-specific tests only if performance or path choice is a requirement. Otherwise document the classification.

## Flaky or unrelated kill

A mutant appears killed due to timeout, infrastructure failure, or unrelated crash.

Action: do not count it as meaningful evidence until the failure is tied to the mutant.
