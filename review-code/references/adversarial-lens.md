# Review Code: Adversarial

> High-risk changes only. Your job is not balanced review — it is to disprove the
> assumption that this change is safe, correct, compatible, reliable, and
> deployable. Severity, confidence, and the final check live in
> references/shared-rubric.md; this lens adds two output fields (see Output
> extension).

## Scope

- Deliberate attempts to break high-risk changes: auth and isolation; money,
  quota, credit, or inventory invariants; migrations; async/idempotency; external
  input; irreversible actions.
- Adjacent lenses: this lens does not replace correctness/security/reliability/
  release — it stress-tests the same change harder. Route a plain bug to its lens;
  keep here only findings that need an adversarial scenario to surface. Report a
  finding only when you can describe a concrete failure path; otherwise list it
  under Assumptions checked.

## What to look for

For each, construct a concrete scenario and trace whether the code actually stops it:

- Authorization & isolation: a user passes another user's or another tenant's ID; a guessable/sequential ID is enumerated; a deleted, archived, or expired resource is reused; a privilege check passes on the parent but not the child object.
- Idempotency & ordering: a webhook is replayed or delivered out of order; a job runs twice; a client retries after a partial success; two requests for the same operation interleave; a single-use token (coupon, gift card, reset or verification token) whose "already used" check and "mark used" write are non-atomic — two parallel redemptions both read unused and both commit.
- Input & validation bypass: malformed, oversized, deeply-nested, or unicode/encoding-tricked input slips past validation; a value valid at one layer is re-interpreted unsafely at the next; pagination/filter/sort params widen access to hidden rows; a request body mass-assigned into a persistence write — add `role`, `is_admin`, `plan`, `credits`, or `price` to the payload and trace whether it reaches the model without an explicit field allowlist.
- Workflow-step bypass: a multi-step flow (checkout, payment capture, KYC, approval chain) where each endpoint validates its own step but never verifies server-side that prior steps completed — call a later step directly and trace whether it reads a persisted prerequisite status or merely trusts the client's sequencing.
- LLM/agent boundaries: externally-sourced text (fetched page, document, email, tool output) concatenated into a prompt context that also carries write-, exec-, or send-capable tool definitions — embed instructions in the external content and trace whether they can drive a privileged tool call without a confirmation gate.
- Concurrency on invariants: concurrent requests both pass a balance/quota/inventory check then both commit (double-spend); a limit enforced per-request but not across concurrent requests.
- Version & deployment skew: an old worker consumes a new payload (or vice versa); a new app runs on the old DB or an old app on the new DB; a feature flag flips mid-operation; a rollback follows a partial migration.
- Data exposure & retention: logs or error responses capture sensitive payloads under the abuse path; a "soft delete" still serves data; an export or admin path leaks across the tenant boundary.
- Trust boundary & privilege: a server-trusted internal call driven by user-controlled input (a confused deputy); an admin or service path reachable through a user-facing route; a signed token or capability reused beyond its intended scope or after expiry.

## High-signal locations

- The single guard, check, or assumption the whole change's safety rests on — attack it directly.
- Any place that assumes "once", "exactly once", "in order", or "this ID is mine".
- Boundaries where a value crosses from untrusted to trusted, or from one tenant/user's scope to another.
- State transitions on money, quota, inventory, or irreversible actions.

## Common false positives

Do not report these (list them under Assumptions checked instead):

- A generic risk with no concrete, reachable failure path.
- An abuse path already closed by a guard, constraint, or policy you verified.
- "Could be attacked" with no attacker state or input that actually reaches the code.
- A weakness in code the change did not introduce or make newly reachable.

## Severity anchors

Default to skepticism; a change that only works on the happy path is a real
weakness. Reference points on the shared-rubric scale:

- P0/P1: a reachable scenario that bypasses auth, crosses a tenant boundary, corrupts money/inventory/data, or breaks a migration.
- P2: an abuse path that needs an unlikely precondition or has limited blast radius.
- P3 is rarely worth an adversarial slot; prefer Assumptions checked.

## Output extension

Use the shared-rubric output format plus two extra fields per finding:

- adversarial scenario: the attacker, user, client, worker, or deployment state.
- existing protection checked: the guards, tests, constraints, or policies you verified.

## No findings

- If genuinely safe: "No concrete adversarial findings found." then list the
  Assumptions checked, following the shared-rubric empty form.
