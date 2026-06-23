---
name: review-code-security
description: Specialist review lens for security and privacy risks: authentication, authorization, tenant isolation, PII, secrets, injection, and data exposure. Use as a focused lens, usually routed by the review-code orchestrator, when changes touch auth, permissions, tenant boundaries, PII, secrets, input handling, uploads, webhooks, or data export.
---

# Review Code: Security & Privacy

Use this tool-neutral skill to review code changes for security and privacy only. The
active tool performs the review directly with the capabilities available in its
environment. This skill is read-only: do not edit files, apply patches, or commit.

Review target and context: the change and scope the user asked you to review
(e.g. working tree, staged diff, branch, commit, or named files).

## Scope rules

- Review only security and privacy.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.

## Look for

- missing authentication or authorization checks; object-level authorization bypass
- tenant isolation failure; privilege escalation; confused deputy behavior
- insecure default-allow behavior; user-controlled ID access without ownership checks
- PII or secret exposure; unsafe logging of tokens, credentials, or sensitive payloads
- insecure error messages; input validation gaps
- SQL/command/template injection; path traversal; SSRF; XSS or HTML injection
- unsafe deserialization; unsafe file upload handling
- webhook signature or replay validation problems; callback trust boundary issues
- dependency or permission changes that expand attack surface
- test fixtures or sample data leaking secrets

## Required evidence

For each finding, identify:

- the exact changed code or nearby code that causes the issue
- a plausible runtime, exploit, regression, or rollout path
- why existing checks, tests, guards, constraints, policies, or framework behavior do not prevent it
- the expected behavior
- the likely wrong behavior or risk
- the smallest useful fix or verification

## Severity

- P0: immediate production outage, critical data loss, or critical security breach.
- P1: blocking. Likely serious regression, auth bypass, data exposure, irreversible bad state, or unsafe migration.
- P2: important but non-blocking.
- P3: minor suggestion. Report a P3 only when it is unusually high-value; otherwise omit it.

Prioritize P0–P2 findings. Report confidence high or medium only.

confidence high: code evidence and path are clear; existing protections checked.
confidence medium: evidence exists but some uncertainty in call path or runtime conditions.
A low-confidence hypothesis is not a finding: put it under Assumptions checked instead.

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

If there are no concrete findings, return this instead:

```text
## Findings

No concrete security and privacy findings found.

## Assumptions checked

- <assumption checked>
- <assumption checked>
```
