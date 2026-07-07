# Mode: strategy-review

Design or review a project-level testing strategy: a test portfolio, CI
layering plan, release testing roadmap, or risk-based test investment plan
rather than individual test cases.

## Workflow

1. Identify the product risk profile: data loss, security boundary, financial
   impact, concurrency, parser/input complexity, platform diversity, and
   release cadence.
2. Inventory current tests by harness and layer: unit, integration, public
   API, CLI, end-to-end, differential, property-based, fuzz, fault injection,
   performance, and release manual checks.
3. Identify independence gaps: tests sharing the same assumptions, fixtures,
   mocks, helper libraries, or weak oracle.
4. Define test layers by execution cost:
   - local fast path
   - PR or merge gate
   - nightly or deep checks
   - release candidate matrix
   - soak, fuzz, or chaos lanes
5. Assign oracle types for each layer (see `oracle-patterns.md`).
6. Define traceability expectations: which user-visible requirements should
   be linked to tests, which risks need checklist review, and which gaps are
   acceptable.
7. Produce a prioritized roadmap with P0/P1/P2 improvements.

## Output format

Use `assets/test-strategy-template.md`. Include:

- Current-state summary
- Risk profile
- Recommended test portfolio
- CI/release layering
- Harness independence review
- Oracle strategy
- Coverage/mutation/fuzz/release gate plan
- P0/P1/P2 roadmap

## Mode references

- Read `high-reliability-testing-principles.md` for the generalized
  principles to preserve.
- Read `test-portfolio-and-layering.md` for test type selection and
  local/PR/nightly/release lane design.
- Read `harness-independence-checks.md` when evaluating whether multiple
  harnesses really reduce shared blind spots.
- Read `prioritization-rules.md` when ranking roadmap items P0/P1/P2.

## Quality bar

A good strategy names specific risks and assigns each risk to at least one
appropriate test layer and oracle. It does not merely recommend more tests.
It distinguishes fast feedback from deep confidence and explicitly says what
should not block everyday development.

## Mode gotchas

- Do not require every project to adopt maximum rigor. Scale test depth to
  risk, usage, impact, and maintenance cost.
- Do not treat a single green CI pipeline as independent evidence if all
  tests share the same mocks and expected values.
