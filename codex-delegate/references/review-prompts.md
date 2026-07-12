# Review prompt templates

Two prompt shapes for delegated review runs, plus an empirical variant of
either. The standard and adversarial shapes run through the normal launch
path (step 3) with `-s read-only`; their empirical variant (last section)
runs `-s workspace-write` in a disposable worktree. Fill every `{…}` slot;
drop a block only when its condition clearly does not apply. The reviewed
target is described by scope, not by pasting the diff: the run executes
`git` itself (read-only sandbox permits it), which keeps the prompt small
and the evidence grounded in the actual tree.

## Standard code review

Correctness-first review of a change set. Use for pre-merge gates,
regression checks, and second opinions.

```
<task>
Review the following change set for defects.
Repo root: {ABSOLUTE_REPO_ROOT}
Scope: {e.g. "git diff main...HEAD plus git diff HEAD (uncommitted)",
        "commit {SHA}", "the files under {DIR}"}
Focus (optional): {USER_FOCUS}
</task>

<constraints>
READ-ONLY: do not modify, create, or delete any files. Report only.
Review the change against the surrounding code, not in isolation — read
the enclosing functions and callers of changed symbols.
</constraints>

<verification>
Ground every claim in evidence: quote the exact file:line. Verify each
candidate finding against the actual code before reporting it — no
speculation. Claims about tool or API behavior must be checked against
--help output or documentation in the tree, not memory.
</verification>

<finding_bar>
Report findings a maintainer would act on: correctness bugs, contract
violations, regressions, unhandled failure paths, real maintainability
hazards. No style-only or speculative findings without evidence.
</finding_bar>

<output_contract>
1. Verdict line: CLEAN or "N findings".
2. Findings classified Major / Minor / Nit, each with: file:line, quoted
   evidence, concrete failure scenario, and a minimal fix.
3. Coverage list: the checks performed that came back clean.
</output_contract>
```

## Adversarial review

Challenges the approach itself — design choices, assumptions, tradeoffs,
and failure modes — not just implementation defects. Use for plan/design
review and for high-stakes changes before they ship.

```
<task>
Adversarial review: try to break confidence in {TARGET — e.g. "the
working-tree changes on branch {BRANCH}", "the design in {PLAN_PATH}"}.
Your job is to find the strongest reasons this should not ship yet, not
to validate it.
Repo root: {ABSOLUTE_REPO_ROOT}
Scope: {diff commands / files / document paths}
Focus (optional): {USER_FOCUS — weight it heavily, but still report any
other material issue you can defend}
</task>

<constraints>
READ-ONLY: do not modify, create, or delete any files. Report only.
Default to skepticism: assume the change fails in subtle, high-cost, or
user-visible ways until the evidence says otherwise. Give no credit for
good intent, partial fixes, or likely follow-up work; a happy-path-only
mechanism is a real weakness.
{PINNED_DECISIONS — name any document whose recorded decisions are
intentional and therefore not findings}
</constraints>

<attack_surface>
Prioritize failures that are expensive, dangerous, or hard to detect:
trust boundaries and permission checks; data loss, corruption, and
irreversible state; retries, partial failure, and idempotency gaps;
races, ordering assumptions, and re-entrancy; empty/null/timeout and
degraded-dependency paths; version skew and migration hazards;
observability gaps that would hide failure.
{DOMAIN_SPECIFIC — add the target's own risk axes}
</attack_surface>

<verification>
Actively try to disprove the change: trace how bad inputs, retries,
concurrent actions, and partially completed operations move through the
code; look for violated invariants and assumptions that stop holding
under stress. Ground every claim: quote the exact file:line evidence.
</verification>

<finding_bar>
Material findings only. Each finding answers four questions: what can go
wrong, why this path is vulnerable, the likely impact, and the concrete
minimal change that reduces the risk. No style feedback, no speculation
without evidence.
</finding_bar>

<output_contract>
1. Verdict line: a terse ship / do-not-ship-yet assessment, one sentence.
2. Findings classified Major / Minor / Nit, each with: file:line, quoted
   evidence, failure scenario, and the minimal risk-reducing change.
3. Coverage list: the attack angles exercised that came back clean.
</output_contract>
```

## Empirical review (executes to verify)

A variant of either review above for when the strongest findings need
*running* code, not just reading it — dry-running a state machine, proving a
serde round-trip, reproducing a claimed race. Launch it with
`-s workspace-write` in a **disposable git worktree** (see SKILL.md
"Workspace isolation"), not the shared tree.

Build the prompt from the base review's `<task>`, `<attack_surface>` (if
adversarial), `<verification>`, `<finding_bar>`, and `<output_contract>`
blocks unchanged, then **replace** its `<constraints>` block with the
`<workspace>` block below (the base `READ-ONLY: do not modify …` line would
otherwise forbid the scratch tests this variant exists to run), and add the
`<execution>`, `<non_goals>`, and `<stop_conditions>` blocks — a
workspace-write prompt requires the last two (SKILL.md step 1).

Set `{ABSOLUTE_REPO_ROOT}` in the base `<task>` to the disposable worktree
path, and `<ref-under-review>` to the exact ref the worktree was created
from. A linked worktree holds only its own committed snapshot — no other
checkout's index or uncommitted files — so to review a staged or unstaged
change the orchestrator must first materialize that snapshot in the
worktree (e.g. apply the diff there before launch); otherwise the run
silently reviews the wrong target.

```
<workspace>
This workspace is a disposable copy. Nothing in it is ever merged; the
report is the only deliverable. You MAY edit files, add scratch tests, and
run the project's build and test commands to verify or refute a finding —
prefer a five-line test that settles a claim over a paragraph of argument.
Do not touch anything outside this workspace root. Git refs are off-limits
(the sandbox denies .git writes); do not commit, stage, or branch.
</workspace>

<execution>
For any finding you can settle by running code, do so and quote the command
and its actual output as the evidence. Loopback socket binds may be denied
by the sandbox; if a check needs one and it fails to bind, say so and fall
back to the strongest static argument instead of reporting the bind failure
as a defect. A compilation error in the reviewed code is always a real
finding, never a sandbox excuse.
</execution>

<non_goals>
Do not fix the code, land changes, or leave anything for a follow-up run —
scratch edits exist only to produce evidence and are discarded with the
worktree.
</non_goals>

<stop_conditions>
Stop and report if the workspace is not the intended review target (wrong
ref materialized), or if a required build fails for an environmental reason
you cannot attribute to the reviewed code.
</stop_conditions>
```

Consume it like any read-only review (step 6), with one difference: the
worktree is thrown away (`git worktree remove --force`) rather than
collected — the reviewer's scratch edits are not an artifact.

---
The adversarial contract adapts the structure of the OpenAI Codex Claude
Code plugin's adversarial-review prompt (operating stance, attack
surface, four-question finding bar).
