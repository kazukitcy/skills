# Review Code: Adversarial

Use this tool-neutral skill for high-risk changes only. Your job is not a balanced
review; it is to try to disprove the assumption that this change is safe, correct,
compatible, reliable, and deployable.

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

## Calibration

Default to skepticism. Do not give credit for good intent, partial fixes, or
likely follow-up work; a change that only works on the happy path is a real
weakness. Prefer one strong, well-evidenced finding over several weak ones, and
do not dilute serious findings with filler or speculation. If the change is
genuinely safe, say so and report no findings.

## Shared rubric

Read `references/shared-rubric.md` for the severity scale, confidence rule, and
final check. Use its output format **plus** two extra fields per finding —
`adversarial scenario` (the attacker/user/client/worker/deployment state) and
`existing protection checked` (guards, tests, constraints, policies checked):

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
