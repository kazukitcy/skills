# Prioritization rules

Use P0/P1/P2 so the output is actionable.

## P0

Tests that should be implemented first or block release when missing:

- data loss or corruption risk
- security or authorization boundary
- money, billing, irreversible side effects, or legal/compliance impact
- public contract compatibility
- previous regression
- high-frequency critical path
- ambiguous behavior that affects users or integrators

## P1

Important but not always release-blocking:

- common negative cases
- important boundary conditions
- idempotency or retry behavior for important workflows
- platform/configuration difference likely to be encountered
- performance or resource behavior with clear acceptance criteria

## P2

Useful but lower urgency:

- rare edge cases with limited impact
- cosmetic or low-risk behavior
- exploratory cases without clear oracle yet
- broad matrix expansion after core cases exist

## Tie breakers

Prefer tests that are:

- high signal
- deterministic
- cheap to run in the intended lane
- tied to a clear requirement or risk
- likely to catch future regressions
- independent from existing tests' assumptions
