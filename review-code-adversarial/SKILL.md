---
name: review-code-adversarial
description: Specialist adversarial review lens that tries to break safety, correctness, compatibility, reliability, security, and rollout assumptions on high-risk changes. Use as a focused lens, usually routed by the review-code orchestrator, only for high-risk changes: auth, money, migrations, async/idempotency, external input, or irreversible actions.
---

# Review Code: Adversarial

Use this tool-neutral skill for high-risk changes only. Your job is not a balanced
review; it is to try to disprove the assumption that this change is safe, correct,
compatible, reliable, and deployable. The active tool performs the work in its
environment. Read-only: do not edit files, apply patches, or commit.

Review target and context: the change and scope the user asked you to review
(e.g. working tree, staged diff, branch, commit, or named files).

Do not report generic risks. Do not report any issue unless you can describe a
concrete failure path.

## Attack the assumptions

Try to break: authorization; tenant isolation; input validity; ordering; retry and
idempotency; transactions; migration compatibility; old-client/new-server
compatibility; feature flags; rollback; logging and privacy; data retention or
deletion; public API compatibility; queue or worker version skew; money, quota,
credit, inventory, or irreversible-action invariants.

## Adversarial scenarios

user passes another user's ID; tenant A accesses tenant B; deleted/archived
resource reused; webhook replayed or out of order; job runs twice; retry after
partial success; old worker consumes new payload; new app on old DB or old app on
new DB; feature flag flips mid-operation; rollback after partial migration;
malformed input bypasses validation; pagination/filters reveal hidden data; logging
captures sensitive payloads; concurrent requests update the same resource.

## Finding threshold

Every finding must include: adversarial scenario, failure path, code evidence,
existing protection checked, and a minimal failing test idea. If any of those is
missing, do not report it as a finding — list it under Assumptions checked. Report
confidence high or medium only; a low-confidence hypothesis goes under Assumptions
checked.

## Severity

- P0: immediate production outage, critical data loss, or critical security breach.
- P1: blocking. Likely serious regression, auth bypass, data exposure, irreversible bad state, or unsafe migration.
- P2: important but non-blocking.
- P3: minor suggestion. Report only when unusually high-value.

## Output

Return only concrete findings, using this format:

```text
## Findings

### <severity>: <claim>

- severity: P0 | P1 | P2 | P3
- confidence: high | medium
- location: `<file>:<line>` or `<file>::<function>`
- claim: <one sentence>
- adversarial scenario: <attacker, user, client, worker, or deployment state>
- evidence: <specific code behavior or diff evidence>
- path: <step-by-step failure or abuse path>
- existing protection checked: <guards, tests, constraints, policies checked>
- impact: <security/data/reliability/release impact>
- fix: <minimal remediation>
- test: <minimal failing test or reproduction>
```

If there are no concrete findings, return this instead:

```text
## Findings

No concrete adversarial findings found.

## Assumptions checked

- <assumption>
```
