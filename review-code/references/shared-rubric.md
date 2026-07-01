# Shared review rubric

Every `review-code` lens shares this rubric. A lens reference file
(`references/<topic>-lens.md`) defines what that lens looks for; this file defines
the scope discipline, required evidence, severity scale, confidence rule,
calibration, final check, and output format every lens uses. Read both before
reviewing.

This review is read-only: do not edit files, apply patches, or commit. Review
target and context: the change and scope the user asked you to review (e.g.
working tree, staged diff, branch, commit, or named files).

## Scope discipline

Applies to every lens:

- Review only this lens's concern; leave other concerns to their lens.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Required evidence

For each finding, identify:

- the exact changed code or nearby code that causes the issue
- a plausible runtime, exploit, regression, or rollout path
- why existing checks, tests, guards, constraints, policies, or framework behavior do not prevent it
- the expected behavior
- the likely wrong behavior or risk
- the smallest useful fix or verification

## Severity

This is the single definition of the severity scale; every lens and the
orchestrator use it.

- P0: immediate production outage, critical data loss, or critical security breach. Stop merge/deploy.
- P1: blocking. Likely serious regression, auth bypass, data exposure, irreversible bad state, or unsafe migration.
- P2: important but non-blocking. Fix before or shortly after merge.
- P3: minor suggestion. Report a P3 only when it is unusually high-value; otherwise omit it.

Prioritize P0–P2 findings. Report confidence high or medium only.

confidence high: code evidence and path are clear; existing protections checked.
confidence medium: evidence exists but some uncertainty in call path or runtime conditions.
A low-confidence hypothesis is not a finding: put it under Assumptions checked instead.

## Calibration

Prefer one strong, well-evidenced finding over several weak ones. Do not dilute
serious findings with filler, restated guards, or speculation. If the change is
clean for this lens, say so and report no findings rather than padding the list.

## Final check

Before returning, re-read each finding and confirm it is:

- tied to a concrete code location in or near the change,
- plausible under a real runtime, exploit, regression, or rollout scenario,
- not already prevented by an existing guard, test, constraint, or framework behavior,
- actionable, with a fix or test specific enough to act on.

Drop or downgrade any finding that fails a check. After the first issue, also
check for second-order failures, empty-state and boundary behavior, and follow-on
effects before finalizing.

## Output

Return only concrete findings, using this format:

```text
## Findings

### <severity>: <claim>

- severity: P0 | P1 | P2 | P3
- confidence: high | medium
- location: `<file>:<line>` or `<file>::<function>`
- claim: <one sentence>
- evidence: <specific code behavior or diff evidence>
- path: <failure, exploit, regression, rollout, or verification path>
- impact: <user/system/security/business impact>
- fix: <minimal remediation>
- test: <suggested test or verification>
```

If there are no concrete findings, return this instead (name the lens you ran):

```text
## Findings

No concrete <lens> findings found.

## Assumptions checked

- <assumption checked>
- <assumption checked>
```
