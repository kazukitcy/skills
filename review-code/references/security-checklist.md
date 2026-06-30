# Review Code: Security & Privacy

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

## Shared rubric

Read `references/shared-rubric.md` and apply its required-evidence checklist,
severity scale, confidence rule, calibration, final check, and output format.
In the empty-findings form, name this checklist: "No concrete security findings found."
