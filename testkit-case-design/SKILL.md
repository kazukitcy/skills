---
name: testkit-case-design
description: Use this skill when the user wants to infer behavioral specifications from source code, create, audit, expand, or prioritize test cases from code, specifications, API docs, README files, user stories, schemas, code behavior, or existing tests. Produce a language-neutral test plan with inferred requirements, explicit ambiguities, oracles, normal cases, boundary cases, negative cases, and implementation-ready scenarios.
metadata:
  suite: testkit
  principle_lineage: high-reliability-testing-principles
---


## Purpose

Create implementation-ready, language-neutral test cases from specifications, API docs, README files, schemas, user stories, code behavior, and existing tests.


This skill combines requirements extraction, oracle design, boundary analysis, negative-case design, and prioritization in one workflow so a normal test-design request can complete with one skill.

## Use this skill when

- The user asks to infer behavioral specifications from source code and turn them into testable requirements.
- The user asks for test cases, edge cases, negative tests, acceptance tests, or a test plan from a spec or API.
- The user wants to audit existing tests against documented behavior.
- The user asks what behavior is untested or ambiguous.
- The user wants implementation-ready scenarios but not framework-specific code.

## Do not use this skill when

- The input is a production bug, stack trace, or incident; use `testkit-regression-design`.
- The input is coverage, mutation, flaky, or CI diagnostics; use `testkit-suite-diagnostics`.
- The user asks specifically for fuzz, fault injection, crash recovery, corrupt input, or resource exhaustion testing; use `testkit-robustness-planning`.
- The user wants release go/no-go; use `testkit-release-gate`.

## Workflow

1. Classify source material: source code, public APIs, CLI behavior, specification, API docs, schema, README, issue, acceptance criteria, code behavior, existing tests.
2. Extract only testable external behavioral statements as requirements. When inferring from code, prefer exported APIs, CLI behavior, return values, errors, side effects, persistence, and externally visible invariants. Do not turn incidental implementation details into requirements.
3. Assign stable requirement IDs using local, human-readable IDs such as `R-001`, unless the project already has IDs.
4. For each requirement, choose an oracle:
   - explicit expected value
   - differential comparison
   - metamorphic property
   - invariant
   - round-trip
   - configuration equivalence
   - runtime instrumentation oracle
5. Generate cases across categories:
   - normal behavior
   - boundary and limits
   - invalid or malformed input
   - permissions and authentication
   - state transitions
   - concurrency and idempotency when relevant
   - configuration or feature flag differences when relevant
6. Map existing tests if provided: `covered`, `partial`, `missing`, or `ambiguous`.
7. Prioritize cases as P0/P1/P2 based on user impact, risk, regression likelihood, and implementation cost.
8. Output a structured plan using the template. Mark unspecified expected behavior as `ambiguous` rather than inventing it.

## Output format

Use `assets/test-plan-template.md` for a readable report and `assets/test-case-template.yaml` for implementation-ready cases.

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

## Additional resources

- Read `references/requirement-extraction.md` when extracting or auditing requirements.
- Read `references/oracle-patterns.md` when the expected result is unclear or multiple oracle styles are possible.
- Read `references/boundary-taxonomy.md` for boundary, limit, and boolean-vector cases.
- Read `references/failure-taxonomy.md` for negative and failure cases.
- Read `references/prioritization-rules.md` when ranking cases.

## Quality bar

A good output connects every test case to a requirement or explicit risk, names the oracle, includes expected results, and calls out ambiguity. It should be possible for a language adapter or human engineer to implement the test without redoing the design work.

## Gotchas

- Do not invent expected behavior. If the source material is underspecified, mark it `ambiguous` and propose the smallest clarification or assumption needed.
- Prefer public behavior, external contracts, and user-visible invariants over implementation details.
- Do not optimize for coverage numbers alone. A test without an effective oracle can increase coverage while leaving behavior unverified.
- Keep outputs language-neutral unless the user explicitly asks for framework-specific implementation.
- Preserve reproducibility: include setup, trigger, expected observation, cleanup, and replay notes.
- Answer in the user's language when possible.

- Do not let boundary cases float without oracles. Every generated boundary must say what should happen or say the expected behavior is ambiguous.
- Do not overfit to a product family, storage model, protocol, or programming language. Use the underlying patterns: requirements, oracles, boundaries, negative cases, and configuration equivalence.
