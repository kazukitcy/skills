# Review Code: Design & Maintainability

> Where logic lives, which way dependencies point, the stability of contracts,
> and whether the change is safe to build on later. Severity, confidence,
> evidence, and output format live in references/shared-rubric.md — read it too.

## Scope

- Module boundaries, responsibility placement, dependency direction, public API
  contracts, and the future-change safety of the diff.
- Adjacent lenses (route there, don't double-report): a contract or data-shape
  change that affects deploy/rollout/migration → release; a behavior bug →
  correctness. Design owns structure and contracts, not runtime behavior.

## What to look for

- Responsibility & layering: business logic placed in a controller/view/handler instead of the domain layer; a UI or transport layer reaching into data-layer internals; a dependency pointing the wrong direction; a new import that creates a cycle; a shared or general-purpose module growing a branch keyed on which caller it serves (a flag parameter, a caller-identity enum) instead of pushing the specialization to the call site.
- Duplication & drift: business logic or a validation rule re-implemented instead of reused; a near-identical copy of existing logic that will drift; a magic constant duplicated rather than shared; knowledge of a serialized format, wire protocol, or schema (key names, field offsets, format strings, magic bytes) hand-written into a second module instead of shared with the existing reader/writer counterpart — the two sides need not be textually identical to break together on the next format change.
- API contracts: an accidental change to a public/exported surface; a breaking change for existing callers — a renamed/removed field, a new required field or parameter on an existing request or function, a narrowed type or newly tightened validation that rejects previously-accepted input, a changed default or default-serialization behavior; an enum/union extended without updating exhaustive handling; a new consumer of an externally versioned API that fails closed on inputs the provider may extend — rejecting unknown response fields or throwing on an unrecognized enum/event type in a default branch — so the provider's next additive release breaks the integration (fine when the payload is an internal contract this repo owns end to end).
- Backward compatibility: a change that silently alters the meaning of an existing field or response, or the format or derivation of its value (ID scheme, timestamp unit or zone, hash algorithm) while the type stays the same; a serialized/persisted shape changed without a versioning or compatibility story; observable behavior changed outside the type or schema — collection sort order, null vs. empty on zero results, error message structure, pagination defaults — that callers at scale depend on regardless of the documented contract (Hyrum's law); weigh by how widely the surface is consumed.
- Coupling & abstraction: tight coupling introduced (a module that now must change in lockstep with another); a leaky abstraction that hides an important failure mode; premature generalization with a single caller that obscures behavior; an invariant left unencapsulated where any caller can violate it; a new API decomposed by execution order rather than information hiding, forcing callers to hold intermediate state or call methods in a sequence nothing enforces (fine for genuine pipelines and state machines; a defect when the order is an internal detail).
- Change amplification: one logical change implemented by repeating the same non-mechanical edit across several modules with no shared home for the rule — the next such change needs the same fan-out and a missed site fails silently (not a finding when tooling guarantees the sweep or this change is the consolidation); a new public method that only forwards to another public method with an unchanged signature and no added abstraction, error translation, or narrowing, so every future signature change forces lockstep edits in both layers (fine for interface conformance, a deliberate facade over an unstable dependency, or a documented test seam).
- Configuration & policy placement: environment, feature-flag, or policy logic embedded in the wrong layer; an environment- or deployment-varying value (endpoint URL, region, tenant, a limit ops must tune) hard-coded where deployments differ; a cross-cutting concern scattered instead of centralized.
- Clarity & future safety: naming that materially misleads about behavior or units; a structure that invites a future unsafe edit (e.g. parallel arrays that must stay in sync); dead or unreachable code introduced by the change.

## High-signal locations

- Exported signatures, interfaces, types, public routes, and event/DTO shapes the diff changes.
- New imports that cross a layer or module boundary, or that point "upward".
- A rule, constant, or validation that already exists elsewhere in the repo and is now duplicated.
- `switch`/match statements over an enum or union that the change extended.

## Common false positives

Do not report these:

- Subjective style or naming with no concrete mislead, unit ambiguity, or maintenance hazard.
- A single duplication with no divergence risk and no third call site (premature DRY).
- Pre-existing design debt the diff merely sits next to but does not worsen.
- Structure consistent with a documented architecture decision (ADR) or the repo's established, prevailing pattern.

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P1: a backward-incompatible change to a public contract that will break existing callers or persisted data.
- P2: coupling, duplication, or a leaky abstraction that will reliably cause a future bug or force repeated lockstep edits.
- P3: a maintainability or naming nit worth noting, with no near-term functional cost.

## No findings

- If clean: "No concrete design findings found." (use the shared-rubric empty form).
