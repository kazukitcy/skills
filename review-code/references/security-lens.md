# Review Code: Security & Privacy

> Authentication, authorization, tenant isolation, secret/PII handling, and the
> untrusted-input boundaries the change crosses. Severity, confidence, evidence,
> and output format live in references/shared-rubric.md — read it too.

## Scope

- Whether the change preserves who-can-do-what and keeps untrusted input,
  secrets, and personal data inside their boundaries.
- Adjacent lenses (route there, don't double-report): retry/idempotency/partial
  failure → reliability; a pure logic bug with no trust boundary → correctness;
  constructing a concrete exploit on a high-risk change → adversarial; missing
  security tests → tests.

Handling rule: never copy a secret value into a finding. Reference `file:line`
and the credential type only ("Stripe live key at `config.ts:12`"), and always
recommend rotation, not just removal — a committed secret is burned even after
deletion.

## What to look for

- Authentication: a route/handler/server-action reachable without a server-side identity check; auth enforced only in the client or by a hidden UI; a token accepted without signature/expiry/audience verification.
- Authorization & ownership: object access by user-supplied ID without an ownership or tenant check (IDOR); a role/permission check missing on a state-changing path; authorization decided before, but not re-checked after, a redirect or indirect call (confused deputy).
- Tenant isolation: a query or cache lookup missing its tenant/org scope; a shared cache key, file path, or signed URL that can cross tenants; a background job that loses the requester's scope.
- Injection sinks: SQL/NoSQL/ORM-raw fragments, shell commands, template/HTML, or eval-like APIs assembled from request data; a filesystem path built from input (traversal); a server-side request to a user-controlled URL (SSRF).
- Input contracts: request bodies, query params, or headers trusted without schema validation; mass assignment of request fields into a persistence model; file uploads without type/size/content-type/storage-location limits; unsafe deserialization of untrusted bytes.
- Secrets & credentials: hardcoded keys/tokens/passwords; credentials read from or written to logs, error payloads, or event/history stores; a secret added to a committed `.env`, fixture, or sample file.
- PII & data exposure: personal or sensitive data logged, returned in errors, or over-fetched into a response that does not need it; stack traces or internal identifiers leaked to clients.
- Web/transport hardening: missing CSRF protection on a cookie-authenticated state-changing route; overly broad CORS combined with credentials; cookies missing `HttpOnly`/`Secure`/`SameSite`; missing webhook signature or replay (timestamp/nonce) verification.
- Surface & dependency changes: a new dependency, scope, or permission that widens the attack surface; a previously internal endpoint newly exposed; auth or crypto downgraded (weaker algorithm, disabled verification).

## High-signal locations

- New or changed route, handler, middleware, or server-action entry points and their guard clauses.
- Any string interpolation or concatenation flowing into a query, shell, filesystem path, URL, or HTML sink.
- Logging, error construction, or serialization added near tokens, request bodies, or user/PII records.
- Dependency manifests, IAM/policy/scope files, CORS/cookie/header configuration, and crypto or verification calls.

## Common false positives

Do not report these:

- Standard platform conventions: honoring `https_proxy`/`NO_PROXY`, reading `~/.netrc`, a local dev tool shelling out to configured package managers.
- Access already enforced by middleware, a framework policy, or a route guard that applies to this path — confirm it is genuinely absent before reporting.
- Server-trusted internal calls and server-only values that never cross a user trust boundary.
- A pattern settled by a documented decision (ADR) — unless the code has drifted from it, in which case report the drift.

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P0/P1: authentication or authorization bypass; cross-tenant data access; injection reachable from untrusted input; a live credential committed to the repo; PII exposed to the wrong user.
- P2: missing hardening (CSRF, CORS, cookie flags) where exploitation needs an unlikely precondition; PII written to internal logs with limited exposure.
- P3: a defense-in-depth improvement with no concrete exploit path under the current code.

## No findings

- If clean: "No concrete security findings found." (use the shared-rubric empty form).
