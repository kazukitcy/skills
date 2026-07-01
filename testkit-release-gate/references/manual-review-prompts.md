# Manual review prompts

Use these prompts to complement automated evidence.

## Scope

- What changed in user-visible behavior?
- What did not change but could be affected indirectly?
- Which assumptions are not tested automatically?

## Evidence

- Which critical paths have independent evidence?
- Which tests are new for this release?
- Which failures were waived and why?
- Which test results are stale?

## Risk

- What is the worst plausible failure?
- How quickly would we detect it?
- How quickly could we roll back or mitigate?
- What risk is accepted under conditional-go?

## Ambiguity

- Which expected behaviors remain unclear?
- Are we accidentally locking in behavior that was never intended?
- Are release notes and docs aligned with test expectations?

## Decision

- What would make this a no-go?
- Who owns each accepted risk?
- What post-release checks must happen?
