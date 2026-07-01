# Regression discipline principles

## Bug fixes should leave evidence

A bug report should produce a test that would have exposed the bug before the fix and passes after the fix. Otherwise the same behavior can silently regress.

## Minimized cases are more valuable than broad reproductions

A full incident reproduction is useful for diagnosis, but the durable regression test should be as small and deterministic as possible.

## Preserve the original failing input

When an input triggers a bug, keep the original and also create a minimized form. The original helps audit whether minimization lost meaning; the reduced case keeps the regression suite maintainable.

## Regression tests should assert the repaired contract

Do not only assert that the crash is gone. Assert the expected state, side effect, error type, cleanup, retry behavior, or invariant that defines correctness.

## Regression tests belong in the right lane

A narrow regression should usually run in fast or PR lanes. Expensive reproductions can be kept as deep-lane or release-lane evidence.
