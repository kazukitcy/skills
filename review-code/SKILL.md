---
name: review-code
description: Orchestrates high-signal, tool-neutral code review by risk-routing a diff to specialist review checklists and consolidating their findings. Use to review a working tree, staged diff, branch, PR, or commit range and get severity-ranked findings instead of generic approval.
---

# Review Code: Orchestrator

Use this tool-neutral skill to coordinate a high-signal review of code changes.
The active tool performs the work with the capabilities available in its
environment. This skill is read-only: do not edit files, apply patches, commit,
or produce generic approval language. For non-trivial changes, review through the
relevant review checklists rather than giving a single undifferentiated opinion.

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
4. Select only the relevant checklists (see Routing).
5. Run each selected checklist as a subagent (see Execution).
6. Wait for all selected checklist results.
7. Deduplicate findings.
8. Drop speculative findings that lack concrete code evidence.
9. Reclassify severity where the checklist over- or under-rated it.
10. Run the verification pass over only the important candidates: P0/P1 candidates,
    security findings, adversarial findings, or conflicting checklist conclusions.
11. Produce one concise consolidated review.

## Execution

This skill bundles every review checklist as a reference file under `references/`.
Run each selected checklist as its own subagent review when your environment
supports subagents or parallel task spawning, so the reviews stay independent
and do not contaminate each other's reasoning. For each selected checklist:

1. Spawn one subagent with a focused task prompt naming the review target and scope.
2. Instruct it to read this skill's `references/<topic>-checklist.md` **and**
   `references/shared-rubric.md`, and to follow them as its review instructions.
3. Instruct it to return concrete findings only, in the rubric's output format.

Wait for all subagents, then consolidate.

Some environments only spawn subagents when explicitly asked — in that case,
explicitly request subagent spawning per selected checklist.

Fallback when subagents are unavailable: if your environment cannot spawn
subagents, run the selected checklists yourself, sequentially — read
`references/<topic>-checklist.md` and `references/shared-rubric.md` for each and apply
them in turn, keeping each review's reasoning separate, before consolidating. This
is lower-throughput but still covers every selected checklist at full depth,
because the reference files travel with this skill.

If a `references/<topic>-checklist.md` or `references/shared-rubric.md` file cannot be read,
the skill is installed incompletely: record the checklist under `## Review scope` →
Checklists unavailable, recommend reinstalling `review-code`
(`apm install -g kazukitcy/skills/review-code`), and do not claim that checklist was
covered.

## Available checklists

Each checklist is a reference file under this skill's `references/` directory:

- `references/correctness-checklist.md`
- `references/security-checklist.md`
- `references/tests-checklist.md`
- `references/design-checklist.md`
- `references/performance-checklist.md`
- `references/reliability-checklist.md`
- `references/release-checklist.md`
- `references/adversarial-checklist.md`

Every checklist also reads `references/shared-rubric.md` for the severity scale,
evidence checklist, and output format.

## Routing rules

Do not run all checklists by default. Select by the kind of change:

- docs/comment-only with no contract impact: no checklist.
- docs that change a public contract, API surface, or developer workflow
  (README, API docs, upgrade/migration guide): `release`, `tests`.
- generated docs or API reference docs: `release`.
- security docs or operational runbooks: `security` and/or `reliability` as the
  content warrants.
- test-only: `tests`.
- small pure logic change: `correctness`, `tests`.
- normal application change: `correctness`, `tests`, `design`.
- public API, SDK, schema, or event contract: add `release`.
- auth, authorization, role, permission, or tenant boundary:
  `correctness`, `security`, `tests`, `adversarial`.
- PII, secrets, unsafe logs, data export, audit, retention, deletion:
  `security`, `tests`, `adversarial`.
- billing, payment, credits, quota, inventory, irreversible user actions:
  `correctness`, `security`, `reliability`, `tests`, `adversarial`.
- external input, upload, webhook, callback, parser, deserialization:
  `correctness`, `security`, `tests`, `adversarial`.
- database schema, migration, data backfill:
  `correctness`, `release`, `reliability`, `tests`, `adversarial`.
- async job, queue, retry, timeout, lock, idempotency, concurrency:
  `correctness`, `reliability`, `tests`, `adversarial`.
- hot path, query, cache, pagination, memory, algorithm:
  `correctness`, `performance`, `tests`.
- config, feature flag, deploy order, rollback, observability:
  `release`, `reliability`, `tests`.
- large cross-module change: `correctness`, `tests`, `design`, plus
  risk-specific checklists.

Augment by signal: even when a change looks like a normal application change, if
the diff touches external input, persistence (DB/storage/migration), async or
concurrency, or auth/permissions, add the matching checklist (`security`,
`reliability`, `release`, or `adversarial`) for that signal.

Run the verification pass only after checklist results exist and only when needed.

## Checklist budget

- trivial changes: 0 checklists
- small code changes: ~2 checklists
- normal code changes: ~3 checklists
- high-risk changes: 4–5 checklists
- critical or very large changes: up to 7 checklists, plus the verification pass when needed

Do not launch checklists whose focus does not match the diff.

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
checklist conclusions. Skip the pass entirely when no candidate meets that bar.
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
metadata after. Each finding uses the per-finding schema defined in
`references/shared-rubric.md` (the `## Output` block): severity, confidence,
location, claim, evidence, path, impact, fix, test.

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
- Checklists run:
- Checklists skipped:
- Checklists unavailable:

## Verification
- Checks performed:
- Checks recommended:
- Findings verified:
- Findings dropped or downgraded:
- needs-info items:
- Fallback mode used:

## Notes
Assumptions, unreviewed areas, or limitations.
