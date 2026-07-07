# Coverage interpretation rules

## Line or statement coverage

Shows that a line executed. It can be high even when important branch sides and assertions are missing.

## Branch coverage

Shows whether decision outcomes were exercised. Stronger than line coverage for conditional logic.

Review questions:

- Which branch side is missing?
- What input or state should take that side?
- Is the missing side reachable through public behavior?
- Is there an oracle for the result after that side runs?

## Condition and decision coverage

Useful when multiple conditions combine to decide behavior.

Review questions:

- Can each condition independently affect the decision?
- Are short-circuit paths covered?
- Are important flag combinations covered?
- Is a truth table or table-driven test clearer?

## MC/DC-style reasoning

For high-risk decisions, each condition should be shown to independently affect the outcome. Apply when failures are costly, not to every trivial branch.

## Boundary coverage

Coverage tools may show a comparison executed but not whether both sides
around the boundary were meaningful. Add explicit cases just below, at, and
just above the boundary, plus invalid or overflow-adjacent values when
applicable; the full boundary taxonomy is in `test-case-derivation-rules.md`.

## Instrumented vs delivered configuration

Instrumentation, debug flags, or test-only hooks can change behavior. When
feasible, compare important outputs or smoke tests across:

- instrumented vs delivered configuration
- debug vs release configuration
- feature flag on/off when semantics should match
- optimized vs baseline path

Unexpected differences deserve investigation.

## Defensive branch classification

Classify before acting:

- missing test
- unreachable by public contract
- intentional defensive code
- compatibility path
- error path only reachable through injected dependency failure
- dead code

Do not delete defensive code solely to improve coverage.
