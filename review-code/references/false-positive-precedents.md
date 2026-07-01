# Shared false-positive precedents

Every `review-code` lens reads this file in addition to
`references/shared-rubric.md` and its own `references/<topic>-lens.md`. These are
cross-lens precedents: patterns that repeatedly produce noisy, low-value findings.
Do not report a finding that a precedent here already settles — **unless the diff
shows the code deviating from the safe pattern the precedent assumes**, in which
case report the deviation.

Precedents override a generic suspicion, not concrete evidence. If you have a
specific, reachable failure/exploit path with code evidence, a precedent does not
silence it — reconcile the two in the finding. Each lens's own
`## Common false positives` still applies on top of this list.

## Hard exclusions

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

## Trust & identity precedents

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

## Framework & platform precedents

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

## Scope precedents

- Report only what **this change** introduces or makes newly reachable. A
  pre-existing issue in code the diff did not touch is out of scope (note it at
  most under Notes). When reviewing a branch, a pre-existing issue in a *touched*
  file may be noted but must be tagged as pre-existing, not blamed on the change.
- Behavior the diff intentionally changes, consistent with its stated purpose, is
  not a finding.
- A path already made impossible by an upstream guard, type, framework-validated
  input, or documented decision (ADR) — confirm the guard exists before reporting.
- Do not demand extra hardening, abstraction, indirection, or tests for cases that
  cannot occur. A reviewer prompted to find gaps will find some even when the work
  is sound; chasing them causes over-engineering. Report gaps that affect
  correctness or the change's stated intent; treat optional improvements as P3 or
  Notes.
