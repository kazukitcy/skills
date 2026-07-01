# Regression acceptance criteria

Use these checks before calling a regression test complete.

## Required

- Fails before the fix or clearly documents the pre-fix failure signal.
- Passes after the fix.
- Targets the behavior that broke, not a broad unrelated workflow.
- Has a strong oracle that would catch the same class of bug again.
- Includes setup, trigger, expected observation, and cleanup.
- Is deterministic or has a controlled replay path.

## Good additions

- Links to issue or incident ID.
- Preserves minimized failing input.
- Asserts state and side effects.
- Covers retry, cleanup, or idempotency if relevant.
- Uses public behavior unless internal behavior is the intended contract.

## Avoid

- Asserting only that no exception was thrown.
- Asserting only a log line unless logs are part of the contract.
- Depending on real time sleeps when deterministic synchronization is possible.
- Keeping a full production dataset when a minimized case is sufficient.
