# Review Code: Intent Conformance

> Whether the change actually does what it set out to do: every stated
> requirement implemented, nothing beyond the stated scope, and the diff matching
> its declared purpose. Severity, confidence, evidence, and output format live in
> references/shared-rubric.md — read it too.

## Scope

- Conformance of the diff to its stated intent: the task the user gave for this
  review, the PR/MR description, a linked issue, plan, or spec, and the commit
  messages. Did the change implement what it claims — and only that?
- Adjacent lenses (route there, don't double-report): whether the implemented
  behavior is correct → correctness; whether it is tested → tests; structural
  quality and contract stability → design. This lens asks "was the right thing
  built, and did it stay in scope," not "is the built thing correct."

## Establishing intent

Before reviewing, gather the stated intent from whatever exists, in this order:

- the task or prompt the user gave for this review;
- the PR/MR title and description (`gh pr view <n>`, or the branch's cover text);
- a linked issue, plan, or spec (a `plans/*.md`, a `PLAN.md`, a tracked ticket);
- the commit messages on the change (`git log <base>..HEAD`).

If none of these exist, infer the intent from the diff itself and **say so** in
the review. An inferred intent can only surface scope creep, never an
unimplemented requirement — do not report "missing requirement X" against an
intent you inferred from the same diff.

## What to look for

- Unimplemented requirements: a requirement named in the intent with no
  corresponding code anywhere in the change.
- Partial implementation: a requirement handled on the happy path but not for the
  error or edge cases the intent explicitly calls out.
- Scope creep: changes unrelated to the stated intent — an unrelated refactor, a
  drive-by behavior change, a dependency or config added for something the intent
  did not ask for. Flag it so a reviewer can confirm it was meant to ride along.
- Contradiction: the diff does the opposite of, or something materially different
  from, what the intent describes.
- Silent scope reduction: the intent promises X, the diff quietly delivers less —
  a case stubbed, a `TODO` left, a flag left off — without saying so.
- Acceptance-criteria gaps: explicit acceptance criteria or a checklist in the
  intent with no evidence in the change that they are met (route "no test" to the
  tests lens; flag here a criterion neither implemented nor addressed).
- Blocking deferral: the intent explicitly defers work to a follow-up ("auth in
  PR 2", "validation later") but the diff already exposes the surface or writes
  the data that makes the deferred work non-optional now — a new route reachable
  before the promised auth, a field written before the promised validation, a
  half-applied data change. This overrides the "deliberately partial change"
  false positive below.
- Missing intent on a substantive change: a diff touching multiple subsystems or
  changing a data/event shape with no PR description, linked issue, or
  explanatory commit message. Report as a P3 prompting the author to add
  rationale — without stated intent, requirement conformance cannot be verified
  and this lens should say so rather than stay silent.

## High-signal locations

- The gap between the intent's list of requirements and the set of files and
  symbols the diff actually touches.
- New files or large hunks with no obvious tie to any stated requirement.
- Requirements about error handling, limits, or edge cases — easy to state in the
  intent and easy to skip in the code.
- A change labeled "refactor", "cleanup", "rename", or "no behavior change":
  verify the diff really has none — altered return values or defaults, removed
  or relaxed validation, reordered error handling, changed branching. A behavior
  change under a refactor label is a contradiction finding even when it looks
  low-risk; the label suppresses scrutiny exactly when it should trigger it.

## Common false positives

Do not report these:

- A stated requirement already implemented in an earlier commit on the same
  branch — check the whole branch range, not just the latest commit.
- Necessary incidental changes (imports, types, wiring, test scaffolding) that
  support the stated work; that is not scope creep.
- Intent inferred from the diff and then "checked" against itself — if you had to
  infer intent, do not raise unimplemented-requirement findings.
- A deliberately partial change the intent itself scopes as such ("first of N
  PRs", "wiring only, behavior in a follow-up") — unless the partial state
  already exposes an unguarded surface or irreversible effect (see "Blocking
  deferral" above, which takes precedence).

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P1: a core stated requirement is unimplemented or contradicted, so the change
  does not deliver its declared purpose.
- P2: a secondary requirement or a stated edge case is missing; unexplained scope
  creep that carries real behavior change.
- P3: minor scope creep with no behavior risk; a cosmetic mismatch between the
  description and the diff.

## No findings

- If clean: "No concrete intent-conformance findings found." (use the
  shared-rubric empty form).
