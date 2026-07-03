# Shared review rubric

Every `review-code` lens shares this rubric. A lens reference file
(`references/<topic>-lens.md`) defines what that lens looks for; this file defines
the scope discipline, required evidence, severity scale, confidence rule,
calibration, false-positive precedents, final check, and output format every
lens uses. Read the lens file and this rubric in full before reviewing.

This review is read-only: do not edit files, apply patches, or commit. Review
target and context: the change and scope the user asked you to review (e.g.
working tree, staged diff, branch, commit, or named files).

## Scope discipline

Applies to every lens:

- Report only what **this change** introduces or makes newly reachable. A
  pre-existing issue in untouched code is out of scope; note it at most under
  Notes, never as a finding blamed on the change. When reviewing a branch, a
  pre-existing issue in a *touched* file may be noted but must be tagged as
  pre-existing.
- Behavior the diff intentionally changes, consistent with its stated purpose,
  is not a finding.
- Do not report a path already made impossible by an upstream guard, type,
  framework-validated input, or documented decision (ADR) — confirm the guard
  exists before reporting.
- Review only this lens's concern; leave other concerns to their lens.
- Do not report generic best practices.
- Do not report style-only issues unless they hide a concrete defect.
- Do not report speculative issues without a concrete path and code evidence.
- Do not demand extra hardening, abstraction, or tests for cases that cannot
  occur (over-engineering). A reviewer prompted to find gaps will report some even
  when the work is sound — report only gaps that affect correctness or the
  change's stated intent, and treat optional improvements as P3.
- Honor the "False-positive precedents" section below: do not report a finding
  a precedent there already settles unless the diff deviates from the safe
  pattern it assumes.

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

## False-positive precedents

Cross-lens precedents: patterns that repeatedly produce noisy, low-value
findings. Do not report a finding a precedent here already settles — **unless
the diff shows the code deviating from the safe pattern the precedent
assumes**, in which case report the deviation.

Precedents override a generic suspicion, not concrete evidence. If you have a
specific, reachable failure/exploit path with code evidence, a precedent does
not silence it — reconcile the two in the finding. Each lens's own
`## Common false positives` still applies on top of this list.

### Hard exclusions

Do not raise these as findings under any lens (mention at most under Notes if
genuinely relevant to the change's purpose):

- Denial of service, resource/memory/CPU exhaustion, or missing rate limiting —
  unless limiting that resource is the change's stated purpose.
- Theoretical race conditions with no concrete interleaving and no shared mutable
  state reachable by the change. A real, reachable race goes to the reliability
  lens with its interleaving path.
- Outdated third-party dependency versions, absent a known-exploitable path in the
  usage this change introduces. Dependency upgrades are their own review.
- Memory-safety issues (buffer overflow, use-after-free) in memory-safe languages.
- Log spoofing / log injection with no downstream sink that interprets the log.
- Regex denial-of-service or regex injection unless an attacker controls the
  pattern itself on a hot path.
- Findings in test-only, fixture, example, or documentation files — unless the
  change ships those artifacts to production or they encode a real credential.
- Missing audit logs, missing metrics, or generic defense-in-depth with no
  concrete exploit or failure path (at most a P3, usually Notes).

### Trust & identity precedents

- UUIDs and cryptographically random tokens are unguessable. Do not assume
  enumeration or brute force unless the identifier is sequential, short, or
  otherwise predictable.
- Environment variables, CLI flags, and operator-managed config files are trusted
  inputs (operator-controlled), not attacker-controlled input.
- Server-to-server internal calls and server-only values are not an untrusted
  boundary. A trust-boundary finding needs user/attacker-controlled data actually
  reaching the sink.
- Honoring standard platform conventions is expected behavior, not a
  vulnerability: proxy variables (`https_proxy`/`HTTP_PROXY`/`NO_PROXY`), reading
  `~/.netrc`, or a local dev tool shelling out to a configured package manager.

### Framework & platform precedents

- Auto-escaping template and view frameworks (React, Angular, Vue, and most
  server-side template engines) are XSS-safe by default. Report XSS only when the
  change uses an explicit escape hatch — `dangerouslySetInnerHTML`,
  `bypassSecurityTrustHtml`, a `| safe`/`raw` filter, or hand-built HTML strings
  — or otherwise bypasses the framework's escaping.
- A lack of authentication or authorization in client-side code is not, by
  itself, a vulnerability — enforcement belongs on the server. Report the missing
  server-side check, not the missing client-side one.
- Parameterized queries and prepared statements are injection-safe. Report
  injection only for raw or string-concatenated query fragments built from
  untrusted input.
- Framework-default protections already cover a route unless the change opts out:
  CSRF middleware, `SameSite` cookie defaults, output encoding. Confirm the change
  actually disables or bypasses the default before reporting its absence.

## Final check

Before returning, re-read each finding and confirm it is:

- tied to a concrete code location in or near the change,
- plausible under a real runtime, exploit, regression, or rollout scenario,
- not already prevented by an existing guard, test, constraint, or framework behavior,
- actionable, with a fix or test specific enough to act on,
- serious enough that a human reviewer would plausibly block or request changes
  over it — if not, demote it to P3 or Notes.

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
