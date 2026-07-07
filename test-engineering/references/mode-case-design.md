# Mode: case-design

Create implementation-ready, language-neutral test cases from specifications,
API docs, README files, schemas, user stories, code behavior, and existing
tests. This mode combines requirements extraction, oracle design, boundary
analysis, negative-case design, and prioritization in one workflow.

## Workflow

1. Classify source material: source code, public APIs, CLI behavior,
   specification, API docs, schema, README, issue, acceptance criteria, code
   behavior, existing tests.
2. Extract only testable external behavioral statements as requirements. When
   inferring from code, prefer exported APIs, CLI behavior, return values,
   errors, side effects, persistence, and externally visible invariants. Do
   not turn incidental implementation details into requirements.
3. Assign stable requirement IDs using local, human-readable IDs such as
   `R-001`, unless the project already has IDs.
4. For each requirement, choose an oracle (see `oracle-patterns.md` for the
   oracle types and when each applies).
5. Generate cases across categories:
   - normal behavior
   - boundary and limits
   - invalid or malformed input
   - permissions and authentication
   - state transitions
   - concurrency and idempotency when relevant
   - configuration or feature flag differences when relevant
6. Map existing tests if provided: `covered`, `partial`, `missing`, or
   `ambiguous`.
7. Prioritize cases as P0/P1/P2 based on user impact, risk, regression
   likelihood, and implementation cost.
8. Output a structured plan using the template.

## Output format

Use `assets/test-plan-template.md` for a readable report and
`assets/test-case-template.yaml` for implementation-ready cases.

Required fields for each case:

- `id`
- `requirement_id`
- `category`
- `behavior_under_test`
- `setup`
- `input_or_action`
- `expected`
- `oracle`
- `priority`
- `ambiguities`
- `implementation_notes`

## Mode references

- Read `test-case-derivation-rules.md` for requirement extraction, the
  boundary taxonomy, and the failure taxonomy.
- Read `prioritization-rules.md` when ranking cases.

## Quality bar

A good output connects every test case to a requirement or explicit risk,
names the oracle, includes expected results, and calls out ambiguity. It
should be possible for a language adapter or human engineer to implement the
test without redoing the design work.

## Mode gotchas

- Do not let boundary cases float without oracles. Every generated boundary
  must say what should happen or say the expected behavior is ambiguous.
- Do not overfit to a product family, storage model, protocol, or programming
  language. Use the underlying patterns: requirements, oracles, boundaries,
  negative cases, and configuration equivalence.
