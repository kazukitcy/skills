---
name: review-code
description: Orchestrates high-signal, tool-neutral code review by risk-routing a diff to review-code-* specialist skills and consolidating their findings. Use to review a working tree, staged diff, branch, PR, or commit range and get severity-ranked findings instead of generic approval.
---

# Review Code: Orchestrator

Use this tool-neutral skill to coordinate a high-signal review of code changes.
The active tool performs the work with the capabilities available in its
environment. This skill is read-only: do not edit files, apply patches, commit,
or produce generic approval language. For non-trivial changes, review through the
relevant specialist lenses rather than giving a single undifferentiated opinion.

Review target: the change the user asked you to review. If the user named none,
resolve it as described under "Review target resolution".

## Review target resolution

If the target is missing or ambiguous, infer the most likely one from repository
state, in this order, using the matching read-only command:

1. working-tree changes — start with `git status --short` to inventory modified,
   staged, deleted, renamed, and untracked files. Then inspect all applicable
   read-only views: `git diff` for unstaged tracked changes, `git diff --cached`
   for staged changes, and `git ls-files --others --exclude-standard` plus file
   reads for untracked files. Do not stop after the first non-empty diff; a
   working-tree review covers all three categories when they coexist.
2. current branch vs. its base — `git diff $(git merge-base HEAD <default-base>)..HEAD`
   (resolve `<default-base>` from the repo, e.g. `origin/main` or `origin/master`)
3. an explicitly mentioned commit or PR — `git show <ref>` / `git diff <base>..<ref>`

Use version-control commands for **inspection only** — never stage, commit, stash,
checkout, or otherwise mutate the tree.

## Orchestrator responsibilities

1. Identify the review target.
2. Inspect changed files and enough nearby code to infer intent.
3. Build a risk profile of the change.
4. Select only the relevant `review-code-*` specialists (see Routing).
5. Run each selected specialist as a subagent (see Execution).
6. Wait for all selected specialist results.
7. Deduplicate findings.
8. Drop speculative findings that lack concrete code evidence.
9. Reclassify severity where the specialist over- or under-rated it.
10. Run the verification pass over only the important candidates: P0/P1 candidates,
    security findings, adversarial findings, or conflicting specialist conclusions.
11. Produce one concise consolidated review.

## Execution

Run each selected specialist in an isolated subagent context when your environment
supports subagents or parallel task spawning, so specialists do not contaminate
each other's reasoning. Spawn one subagent per selected specialist, pass it a
focused task prompt, and instruct it to use the corresponding `review-code-*` skill
as its review instructions. Wait for all subagents, then consolidate.

Some environments only spawn subagents when explicitly asked — in that case,
explicitly request subagent spawning per selected specialist.

Fallback when a specialist is unavailable: if a selected `review-code-*` skill is
not installed or cannot be invoked from inside a child subagent, **do not claim
its lens was covered at specialist quality** — this orchestrator does not carry the
specialist's detailed checklist, so a direct pass here is best-effort only, not
equivalent. Handle it as follows:

1. Record the lens as **not reviewed at full depth** under
   `## Review scope` → Specialists unavailable, and recommend installing the
   specialist (`apm install -g kazukitcy/skills/review-code-<s>`) for a complete
   review of that dimension.
2. You may still do a brief best-effort pass on that dimension using this skill's
   `## Severity` scale and `## Finding quality bar`, but cap any finding it
   produces at `confidence: medium` and note in the finding that it came from a
   fallback pass without the specialist checklist.
3. Do not create custom subagent definition files.
4. Set `## Verification` → Fallback mode used to the list of lenses handled this
   way, so the consumer can see exactly which dimensions are under-covered.

The point is honesty about coverage: an uninstalled lens is a gap to surface, not
a gap to paper over with a full-confidence verdict.

## Available specialists

- `review-code-correctness`
- `review-code-security`
- `review-code-tests`
- `review-code-design`
- `review-code-performance`
- `review-code-reliability`
- `review-code-release`
- `review-code-adversarial`

## Routing rules

Do not run all specialists by default. Select by the kind of change:

- docs/comment-only with no contract impact: no specialist.
- docs that change a public contract, API surface, or developer workflow
  (README, API docs, upgrade/migration guide): `review-code-release`, `review-code-tests`.
- generated docs or API reference docs: `review-code-release`.
- security docs or operational runbooks: `review-code-security` and/or
  `review-code-reliability` as the content warrants.
- test-only: `review-code-tests`.
- small pure logic change: `review-code-correctness`, `review-code-tests`.
- normal application change: `review-code-correctness`, `review-code-tests`, `review-code-design`.
- public API, SDK, schema, or event contract: add `review-code-release`.
- auth, authorization, role, permission, or tenant boundary:
  `review-code-correctness`, `review-code-security`, `review-code-tests`, `review-code-adversarial`.
- PII, secrets, unsafe logs, data export, audit, retention, deletion:
  `review-code-security`, `review-code-tests`, `review-code-adversarial`.
- billing, payment, credits, quota, inventory, irreversible user actions:
  `review-code-correctness`, `review-code-security`, `review-code-reliability`, `review-code-tests`, `review-code-adversarial`.
- external input, upload, webhook, callback, parser, deserialization:
  `review-code-correctness`, `review-code-security`, `review-code-tests`, `review-code-adversarial`.
- database schema, migration, data backfill:
  `review-code-correctness`, `review-code-release`, `review-code-reliability`, `review-code-tests`, `review-code-adversarial`.
- async job, queue, retry, timeout, lock, idempotency, concurrency:
  `review-code-correctness`, `review-code-reliability`, `review-code-tests`, `review-code-adversarial`.
- hot path, query, cache, pagination, memory, algorithm:
  `review-code-correctness`, `review-code-performance`, `review-code-tests`.
- config, feature flag, deploy order, rollback, observability:
  `review-code-release`, `review-code-reliability`, `review-code-tests`.
- large cross-module change: `review-code-correctness`, `review-code-tests`,
  `review-code-design`, plus risk-specific specialists.

Augment by signal: even when a change looks like a normal application change, if
the diff touches external input, persistence (DB/storage/migration), async or
concurrency, or auth/permissions, add the matching specialist (`-security`,
`-reliability`, `-release`, or `-adversarial`) for that signal.

Run the verification pass only after specialist results exist and only when needed.

## Subagent budget

- trivial changes: 0 specialists
- small code changes: ~2 specialists
- normal code changes: ~3 specialists
- high-risk changes: 4–5 specialists
- critical or very large changes: up to 7 specialists, plus the verification pass when needed

Do not launch specialists whose lens does not match the diff.

## Severity

- P0: immediate production outage, critical data loss, or critical security breach. Stop merge/deploy.
- P1: blocking. Likely serious regression, auth bypass, data exposure, irreversible bad state, or unsafe migration.
- P2: important but non-blocking. Fix before or shortly after merge.
- P3: minor suggestion. Optional hardening, maintainability, or low-risk clarification.

## Finding quality bar

A final finding must have: location, code evidence, a failure/exploit/regression/
rollout path, impact, and a minimal fix or test idea. Drop or downgrade findings
that are: generic best practices; style-only; speculative without code evidence;
already prevented by existing guards, tests, constraints, or framework behavior; or
outside the actual diff risk.

Before keeping any finding, confirm: (1) caused by the diff, (2) has a concrete
runtime path, (3) has code evidence, (4) has meaningful impact, (5) is not already
prevented, (6) a human reviewer would plausibly block or request changes. If 1–4
are not all yes, do not make it a final finding. If 5 is no, reject or downgrade. If
6 is no, demote to P3 or Notes.

## Calibration

Prefer one strong, well-evidenced finding over several weak ones. Do not dilute a
P0/P1 finding by surrounding it with low-value P3s or restated framework
guarantees. A short, high-signal review beats a long one: when a lens is clean,
say so rather than manufacturing findings to fill a section.

## Verifying important findings

Before finalizing, run a verification pass over the important candidate findings
only — P0/P1 candidates, security findings, adversarial findings, or conflicting
specialist conclusions. Skip the pass entirely when no candidate meets that bar.
This is an internal step of the orchestrator, not a separate skill: it always has
the candidate findings in hand, so it needs no standalone input contract.

For each such candidate, check:

- Does the cited code exist at the cited location?
- Is the failure, exploit, regression, or rollout path plausible?
- Is the stated impact accurate, or over- or under-stated?
- Do existing guards, tests, constraints, middleware, policies, feature flags, or
  framework behavior already prevent it?
- Is the severity appropriate?
- Is it duplicated by another finding?
- Is there a smaller, more precise claim?
- Is the suggested fix appropriate?
- Does the finding imply second-order failures — empty-state behavior, retries,
  stale state, or rollback paths — that a fix must also address?

Classify each verified candidate as one of:

- confirmed: evidence and path support the claim.
- downgraded: the issue is real but severity or confidence is lower.
- rejected: speculative, prevented, not caused by the diff, or unsupported.
- needs-info: plausible but unverifiable from available context.

Only confirmed and downgraded candidates appear in the findings sections below
(apply the downgraded severity). Drop rejected candidates entirely. Do **not** list
needs-info items among the findings — they are unverified and would read as real
findings; record them under `## Verification` (or `## Notes`) instead.

## Final output format

Lead with the findings, ordered by severity; put the summary and operational
metadata after. Each finding uses this schema:

- severity: P0 | P1 | P2 | P3
- confidence: high | medium
- location: `<file>:<line>` or `<file>::<function>`
- claim: <one sentence>
- evidence: <specific code behavior or diff evidence>
- path: <failure, exploit, regression, rollout, or verification path>
- impact: <user/system/security/business impact>
- fix: <minimal remediation>
- test: <suggested test or verification>

Return exactly these sections, in this order:

# Code Review

## P0/P1 blocking findings
Concrete blocking findings, each with the finding schema above. If none, write `None`.

## P2 important findings
Important non-blocking findings. If none, write `None`.

## P3 minor suggestions
At most three, only unusually high-value ones. If none, write `None`.

## Summary
- Verdict: approve | needs-attention | block
- 2 to 5 sentences.

## Missing tests
Only tests tied to changed behavior or reported findings.

## Review scope
- Target:
- Changed areas:
- Specialists run:
- Specialists skipped:
- Specialists unavailable:

## Verification
- Checks performed:
- Checks recommended:
- Findings verified:
- Findings dropped or downgraded:
- needs-info items:
- Fallback mode used:

## Notes
Assumptions, unreviewed areas, or limitations.
