---
name: review-code
description: Orchestrates high-signal, tool-neutral code review by risk-routing a diff to specialist review lenses and consolidating their findings. Use to review a working tree, staged diff, branch, PR, or commit range and get severity-ranked findings instead of generic approval.
---

# Review Code: Orchestrator

Use this tool-neutral skill to coordinate a high-signal review of code changes.
The active tool performs the work with the capabilities available in its
environment. This skill is read-only: do not edit files, apply patches, commit,
or produce generic approval language. For non-trivial changes, review through the
relevant review lenses rather than giving a single undifferentiated opinion.

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
2. Establish the change's stated intent — the task the user gave, the PR/issue/
   plan text, or the commit messages (see `references/intent-lens.md` →
   "Establishing intent") — and inspect changed files and enough nearby code to
   understand it. If no stated intent exists, infer it from the diff and note that.
3. Build a risk profile of the change.
4. Select only the relevant lenses (see Routing).
5. Run each selected lens as a subagent (see Execution).
6. Wait for all selected lens results.
7. Deduplicate findings.
8. Drop speculative findings that lack concrete code evidence.
9. Reclassify severity where the lens over- or under-rated it.
10. Run the independent refutation pass over only the important candidates: P0/P1
    candidates, security findings, adversarial findings, or conflicting lens
    conclusions (see "Verifying important findings").
11. Produce one concise consolidated review.

## Execution

This skill bundles every review lens as a reference file under `references/`.
Run each selected lens as its own subagent review when your environment
supports subagents or parallel task spawning, so the reviews stay independent
and do not contaminate each other's reasoning. For each selected lens:

1. Spawn one subagent with a focused task prompt naming the review target and scope.
2. Instruct it to read this skill's `references/<topic>-lens.md`,
   `references/shared-rubric.md`, **and**
   `references/false-positive-precedents.md`, and to follow them as its review
   instructions.
3. Instruct it to return concrete findings only, in the rubric's output format.

Wait for all subagents, then consolidate.

Some environments only spawn subagents when explicitly asked — in that case,
explicitly request subagent spawning per selected lens.

Fallback when subagents are unavailable: if your environment cannot spawn
subagents, run the selected lenses yourself, sequentially — read
`references/<topic>-lens.md`, `references/shared-rubric.md`, and
`references/false-positive-precedents.md` for each and apply them in turn, keeping
each review's reasoning separate, before consolidating. This
is lower-throughput but still covers every selected lens at full depth,
because the reference files travel with this skill.

If a `references/<topic>-lens.md` or `references/shared-rubric.md` file cannot be read,
the skill is installed incompletely: record the lens under `## Review scope` →
Lenses unavailable, recommend reinstalling `review-code`
(`apm install -g kazukitcy/skills/review-code`), and do not claim that lens was
covered.

## Available lenses

Each lens is a reference file under this skill's `references/` directory:

- `references/correctness-lens.md`
- `references/security-lens.md`
- `references/tests-lens.md`
- `references/design-lens.md`
- `references/performance-lens.md`
- `references/reliability-lens.md`
- `references/release-lens.md`
- `references/adversarial-lens.md`
- `references/intent-lens.md`

Every lens also reads `references/shared-rubric.md` for the scope discipline,
severity scale, evidence requirements, and output format, and
`references/false-positive-precedents.md` for the cross-lens exclusions and
precedents that keep findings high-signal.

## Routing rules

Do not run all lenses by default. Select by the kind of change:

- docs/comment-only with no contract impact: no lens.
- docs that change a public contract, API surface, or developer workflow
  (README, API docs, upgrade/migration guide): `release`, `tests`.
- generated docs or API reference docs: `release`.
- security docs or operational runbooks: `security` and/or `reliability` as the
  content warrants.
- test-only: `tests`.
- small pure logic change: `correctness`, `tests`.
- normal application change: `correctness`, `tests`, `design`, `intent`.
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
  risk-specific lenses.

Augment by signal: even when a change looks like a normal application change, if
the diff touches external input, persistence (DB/storage/migration), async or
concurrency, or auth/permissions, add the matching lens (`security`,
`reliability`, `release`, or `adversarial`) for that signal.

Run the `intent` lens for any change that has a stated purpose (a review task, a
PR/issue/plan, or commit messages), so unimplemented requirements and scope creep
are caught. Skip it only for trivial docs- or comment-only changes, or when no
stated intent exists and one cannot be inferred.

Run the verification pass only after lens results exist and only when needed.

## Lens budget

- trivial changes: 0 lenses
- small code changes: ~2 lenses
- normal code changes: ~3 lenses
- high-risk changes: 4–5 lenses
- critical or very large changes: up to 8 lenses, plus the verification pass when needed

The `intent` lens is low-cost and commonly runs alongside the others; count it
within these budgets rather than on top of them.

Do not launch lenses whose focus does not match the diff.

## Severity

The severity scale (P0–P3) is defined once in `references/shared-rubric.md` and
used by every lens and by this orchestrator. In short: P0 stops merge/deploy
(outage, critical data loss, critical breach); P1 blocks (serious regression,
auth bypass, data exposure, irreversible bad state, unsafe migration); P2 is
important but non-blocking; P3 is a minor, unusually-high-value suggestion only.

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
lens conclusions. Skip the pass entirely when no candidate meets that bar.

Run this pass as an **independent refutation**, not a self-check. The lens (or the
orchestrator) that produced a finding is biased toward confirming it, so verify it
from fresh eyes whose job is to disprove it:

- When your environment supports subagents, spawn one verification subagent per
  important candidate, in parallel. Give each only the finding's claim, severity,
  and the cited `file:line` — **not** the lens's reasoning. Instruct it to try to
  refute the finding and to default to "rejected" when it cannot substantiate a
  concrete, reachable path. Have it return a verdict (below) with a one-line
  justification.
- When subagents are unavailable, perform the same refutation yourself, candidate
  by candidate, explicitly arguing against each finding before you keep it.

For each candidate, the refutation checks:

- Does the cited code exist at the cited location? (If the location is wrong, the
  finding is rejected — a misattributed finding is not actionable.)
- Is the failure, exploit, regression, or rollout path plausible and reachable?
- Is the stated impact accurate, or over- or under-stated?
- Do existing guards, tests, constraints, middleware, policies, feature flags,
  framework behavior, or a `references/false-positive-precedents.md` precedent
  already prevent or settle it?
- Is the severity appropriate?
- Is it duplicated by another finding?
- Is there a smaller, more precise claim?
- Does the finding imply second-order failures — empty-state behavior, retries,
  stale state, or rollback paths — that a fix must also address?

Classify each verified candidate as one of:

- confirmed: evidence and path survive the refutation.
- downgraded: the issue is real but severity or confidence is lower.
- rejected: speculative, prevented, misattributed, settled by a precedent, not
  caused by the diff, or unsupported.
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
- Intent conformance: fulfilled | partial | diverged | unknown — one line on the
  basis (the stated intent used, or that it was inferred from the diff).
- 2 to 5 sentences.

## Missing tests
Only tests tied to changed behavior or reported findings.

## Review scope
- Target:
- Changed areas:
- Lenses run:
- Lenses skipped:
- Lenses unavailable:

## Verification
- Checks performed:
- Checks recommended:
- Findings verified:
- Findings dropped or downgraded:
- needs-info items:
- Fallback mode used:

## Notes
Assumptions, unreviewed areas, or limitations.
