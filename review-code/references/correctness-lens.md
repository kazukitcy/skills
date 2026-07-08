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

- Conditionals & logic: inverted conditions, including a dropped or extra `!`/negation; wrong comparison or boolean operator (`&&`/`||`, `<`/`<=`); operator-precedence mistakes; a correct-looking expression using a closely-named wrong operand (`width * width` for `width * height`, `start` where `end` was intended, a copy-pasted expression with one operand left unedited); a `switch`/match missing a case or `default`, or a new case that falls through to the next without a `break`/terminator (skip in languages or lint setups where fallthrough must be explicit); an early `return`/`continue`/`break` that skips required work.
- Call sites: a similarly-named sibling function called instead of the intended one (`min` for `max`, a getter for a setter, `encodeX` for `decodeX`); two same-type arguments passed in swapped order so the call still compiles (`copy(dst, src)`, `(height, width)` for `(width, height)`); an argument added or dropped so the call silently resolves to a different overload or is absorbed by a default/varargs parameter — compare argument names and units against the parameter list, not just the arity.
- Missing precondition on a parallel path: a new branch, handler, or case added alongside peers that each guard with a null, bounds, or permission check — and the new one omits the guard its siblings all have; compare the new path laterally against its peers in the diff.
- Default & fallback behavior: the wrong value returned when a lookup misses; a fallback that masks an error instead of handling it; a new branch that changes the result on an existing path the diff did not intend to touch.
- Null / undefined / empty / absent: a non-null assertion or unchecked dereference on a value that can be absent; optional chaining that swallows a value which must exist; an empty collection treated as "all", as zero, or as an error inconsistently across call sites.
- Equality semantics: identity comparison where value equality is intended (Java `==` on strings or boxed primitives, Python `is` on strings or numbers) — passes tests on small interned/cached values, then mismatches on real data; `==`/`!=` between computed floating-point values, or a NaN operand silently deciding comparisons (`==`/`<`/`>` all false, `!=` true), breaking range checks, dedup, or sort order (exact comparison against a sentinel constant assigned verbatim is fine).
- Boundaries & ranges: off-by-one in slicing, pagination, indexing, or loop bounds; inclusive/exclusive end confusion; first/last/single-element edge cases; numeric overflow, truncation, or float-precision loss in counters, money, or IDs; intermediate-step overflow or truncation in fixed-width integer arithmetic even when the result fits (`(a + b) / 2` near the type max, unsigned subtraction in the wrong order, division before multiplication discarding the fraction — fixed-width languages only).
- Invariants & state: an invariant the rest of the code relies on, silently broken by the change; a previously-impossible state now representable; an incorrect or skipped state transition; mutation of shared or aliased data the caller still uses.
- Collection mutated while iterated: elements added or removed inside a loop over the same collection (`remove` inside a foreach, a dict/map resized mid-iteration) — throws at runtime or silently skips elements (mutating through the iterator itself, or iterating over a copy/snapshot, is fine).
- Async ordering (single flow): a missing `await` so a later step reads not-yet-ready state; a promise created but never awaited on a path that must observe its result or error; cleanup or cancellation skipped on an early-return path.
- Parsing / serialization / validation: a round-trip mismatch (parse then re-emit differs); validation that accepts what it must reject or rejects what it must accept; an encoding/locale/timezone assumption; silent type coercion that changes meaning.
- Time & text identity: a naive (timezone-less) datetime later compared or used in timezone-sensitive arithmetic; a UTC offset taken from `now()` applied to a historical or future timestamp; local-time arithmetic that crosses a DST transition; user-supplied strings stored in one Unicode normalization form and compared or looked up in another (NFC vs NFD), so visually identical inputs silently mismatch — confirm normalization is not already applied upstream.
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
