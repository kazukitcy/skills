# Review Code: Correctness

> Behavior bugs in the changed logic itself — wrong results, broken invariants,
> mishandled inputs. Severity, confidence, evidence, and output format live in
> references/shared-rubric.md — read it too.

## Scope

- Whether the changed code computes the right result and handles every input it
  can actually receive: logic, branches, boundaries, null/empty values, error
  paths, and single-flow async ordering.
- Adjacent lenses (route there, don't double-report): cross-request or concurrent
  races, retries, and partial failure → reliability; auth/permission logic and
  trust boundaries → security; whether the behavior is tested → tests; deliberate
  attempts to break a high-risk change → adversarial.

## What to look for

- Conditionals & logic: inverted conditions; wrong comparison or boolean operator (`&&`/`||`, `<`/`<=`); operator-precedence mistakes; a `switch`/match missing a case or `default`; an early `return`/`continue`/`break` that skips required work.
- Default & fallback behavior: the wrong value returned when a lookup misses; a fallback that masks an error instead of handling it; a new branch that changes the result on an existing path the diff did not intend to touch.
- Null / undefined / empty / absent: a non-null assertion or unchecked dereference on a value that can be absent; optional chaining that swallows a value which must exist; an empty collection treated as "all", as zero, or as an error inconsistently across call sites.
- Boundaries & ranges: off-by-one in slicing, pagination, indexing, or loop bounds; inclusive/exclusive end confusion; first/last/single-element edge cases; numeric overflow, truncation, or float-precision loss in counters, money, or IDs.
- Invariants & state: an invariant the rest of the code relies on, silently broken by the change; a previously-impossible state now representable; an incorrect or skipped state transition; mutation of shared or aliased data the caller still uses.
- Async ordering (single flow): a missing `await` so a later step reads not-yet-ready state; a promise created but never awaited on a path that must observe its result or error; cleanup or cancellation skipped on an early-return path.
- Parsing / serialization / validation: a round-trip mismatch (parse then re-emit differs); validation that accepts what it must reject or rejects what it must accept; an encoding/locale/timezone assumption; silent type coercion that changes meaning.
- Error handling: an exception swallowed on a critical path; success returned after a partial failure; an error mapped to the wrong type/code so callers mishandle it; a `finally` or cleanup block that overwrites the real error or return value.

## High-signal locations

- The exact lines the diff changed inside a conditional, loop bound, comparison, or error handler.
- Functions whose return value or thrown error the diff newly ignores, or newly relies on without checking.
- Code paths reachable only when an input is empty, null, zero, negative, maximum-length, or duplicated.
- Boundary arithmetic the change introduced: index math, ranges, rounding, unit conversion, or money.

## Common false positives

Do not report these:

- Defensive null/empty checks that look redundant but guard a genuinely reachable external input.
- Behavior intentionally changed by the diff and consistent with its stated purpose.
- A path already made impossible by an upstream guard, type, or framework-validated DTO — confirm the guard exists before assuming.
- Pure style or refactor with no behavior change, and micro-precision concerns on values whose type or domain makes them irrelevant.

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P1: silently corrupts or loses persisted or user-visible data; returns a wrong result on a common path with no error surfaced; a money or quantity calculation off by a factor or a sign.
- P2: wrong behavior on a real but narrower input or path; a failure that is visible or recoverable rather than silent.
- P3: wrong only under an unlikely input combination, or cosmetic (e.g. an incorrect log message with no downstream effect).

## No findings

- If clean: "No concrete correctness findings found." (use the shared-rubric empty form).
