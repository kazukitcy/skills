---
name: skill-gardening
description: Maintain and grow an agent skill portfolio over its lifecycle. Use when a skill never fires or fires at the wrong time, an agent ignores or half-follows a skill's rules, a skill's output has the wrong shape, skill descriptions overlap or collide, a skill has grown stale or bloated, a periodic portfolio cleanup is due, or when deciding whether a proposed capability belongs in the skill portfolio at all. Do not use for drafting or revising SKILL.md text once the change is decided - that is skill-writer's job.
---

# Skill Gardening

The rule that governs every branch below: **no new guidance without an
observed failure, and no change of any kind without a verifying re-run.**
Guidance justified by "this could confuse the agent" rather than "this did
confuse the agent" is how sediment forms - and sediment is the default fate
of any skill nobody prunes, which is why Branch 3 recurs on a schedule
instead of waiting for a failure.

Before any edit, resolve the editing source: change the authoritative copy
(the skill's repository when it has one), then sync runtime installs. A fix
applied only to a runtime copy evaporates on the next install.

## Route the request

Pick the branch by what is observed. A request can chain branches: a
creation gate that ends in "extend an existing skill" continues as an
improvement, and an improvement often exposes pruning targets.

| Observed situation | Branch |
| --- | --- |
| A lesson, technique, or capability might deserve a new skill | 1. Creation gate |
| A specific skill exists and its behavior is wrong - wrong invocation, ignored rules, wrong-shaped output, stopping early | 2. Improvement |
| A skill or the whole collection needs review with no single failure in hand - bloat, overlap, staleness, periodic cleanup | 3. Pruning pass |

## Branch 1: Creation gate

Decide whether the capability should become a skill, extend one, or not be
prose at all. Run all three checks; each produces recorded evidence.

1. **Control check.** Establish that the failure exists without the
   proposed guidance. The control is the current state before the change:
   for a brand-new skill, a fresh subagent given the tempting task with no
   mention of the proposal; for an extension, a fresh run with the current
   catalog as it stands. Cite an already observed failure from a real
   session, or run controls against the sample bar in
   [references/verification-protocol.md](references/verification-protocol.md).
   On a stop, there is nothing to fix: guidance written anyway is a no-op
   that costs context forever. Done when there is either recorded failing behavior or
   a stop decision meeting the protocol's clean-run bar.
2. **Tier check.** Prefer machine enforcement over prose: a lint rule,
   hook, permission gate, or checked-in script is obeyed reliably; a skill
   only usually; an instruction-file sentence only sometimes. If the lesson
   is mechanically checkable, route it to that tier instead of a skill.
   When the `codify-lessons` skill is installed, consult the destination
   table in its SKILL.md as reference material - do not run its user-gated
   workflow; otherwise ask "could a validator or script enforce this
   without judgment?" and route accordingly. Done when the chosen tier and
   its enforcement mechanism are written into the decision record.
3. **Extend-before-add.** Search the existing catalog (skill names and
   descriptions) for the proposed triggers. A near-duplicate description is
   the primary catalog failure mode (failure-taxonomy class 1: collisions
   split invocations). Prefer adding a branch to an existing skill over
   adding a directory. Done when the search terms, hits, and extend-or-add
   decision are recorded.

Output a decision - new skill, extend named skill, or non-skill tier - with
the evidence from all three checks. For writing the new or extended skill,
hand off to `skill-writer`, which owns drafting and text-level validation;
return here afterward for the behavioral half - verifying the control
failure is now fixed, per
[references/verification-protocol.md](references/verification-protocol.md).

## Branch 2: Improvement

Fix a skill against a failure you can point at.

1. **Reproduce.** Obtain the failing behavior: the transcript where it
   happened, or a fresh re-run of the triggering prompt. Record verbatim
   what the agent did and - for ignored rules - the rationalization it
   used; the fix must quote reality, not a paraphrase. Done when the
   failure is captured in a form a re-run can be compared against.
2. **Classify.** Read
   [references/failure-taxonomy.md](references/failure-taxonomy.md) and
   match the failure to one row. The taxonomy pairs each failure class
   with the form of fix that works and the form that backfires - a
   prohibition cures a discipline violation but worsens a shaping problem,
   so classifying wrong makes the skill worse. Done when one class is
   named with the evidence that selected it.
3. **Fix minimally.** Apply the matched form to the observed failure only.
   Add nothing for hypothetical failures, and follow the taxonomy's fix-form
   corollaries (no nuance clauses, no exemption clauses). Done when every
   changed line traces to the reproduced failure.
4. **Verify.** Re-run per
   [references/verification-protocol.md](references/verification-protocol.md):
   the original scenario must now pass, wording-sensitive changes need
   multiple fresh-context reps against a control, and invocation changes
   are tested with realistic prompts, not the description's own words.
   Done when the protocol's pass condition for the change type is met, or
   the fix is reverted and reclassified.

## Branch 3: Pruning pass

Review without a failure in hand, on a recurring schedule. Scope first: one
skill, or the portfolio. This branch prunes and reconciles; a text-level
rubric review of one skill's draft quality is `skill-writer`'s job, not a
pruning pass.

1. **Per-skill line pass.** For each skill in scope, run the ordered pass
   in [references/pruning-pass.md](references/pruning-pass.md):
   duplication, relevance, no-op test, sediment, sprawl - in that order,
   because each pathology has a different cure and the later tests only
   make sense on lines that survived the earlier ones. The description
   gets the harshest pass of all: it is loaded every turn. Done when a
   written pass record lists, per file, every deletion and relocation with
   its reason, and a keep verdict per surviving section naming which test
   cleared it - a bare "rest judged keep" is a skimmed pass, not a done one.
2. **Portfolio pass.** Run the checks in the reference's portfolio
   section: description collisions, dead cross-references, unreachable
   reference files, retire-or-merge candidates, index sync. Any router or
   index that names skills is re-synced in the same change - a router
   that lies misroutes every future session. Done when each check records
   a result.
3. **Verify deletions.** Deletions are edits: after pruning, re-run the
   skill's realistic prompts and confirm behavior is unchanged (or
   improved). A contested deletion is settled by forward-test (Protocol D),
   not by debate. Done when every deletion is covered by a re-run or
   explicitly reverted.

## Red flags

Stop and reconsider when any of these thoughts appear:

| Rationalization | Reality |
| --- | --- |
| "Add a clarifying sentence just in case" | Edits without an observed failure are how sediment forms. Reproduce first. |
| "The skill is obviously clear" | Clear to the author is not binding on a fresh agent. Verify with fresh-context runs. |
| "Keep the line - deleting feels risky" | That asymmetry is exactly why sediment is the default fate. The no-op test decides; a forward-test settles disputes. |
| "Add 'don't do X' to the rules" | Naming the forbidden behavior activates it, and prohibitions backfire on shaping failures. State what the output is instead; reserve prohibition for discipline violations. |
| "One good run proves the fix" | Single samples lie. Wording changes need multiple fresh-context reps, and non-converging reps mean the wording is not binding. |
| "The agent will find the skill when it needs it" | The description is the routing contract. If realistic prompts do not reach it, fix the description - not the prompts, not the eval. |
| "A new skill is cleaner than extending" | Every skill spends context load or the human's cognitive load, and near-duplicate descriptions split invocations. Extend before adding. |
| "Summarize the workflow in the description so it triggers better" | A workflow summary becomes a shortcut the agent follows instead of reading the body. Descriptions carry triggers, never process. |

## Related skills

Use these when available in the active runtime; each hand-off returns here
for verification.

- `skill-writer` - drafting and text-level rubric review, once the creation
  gate or an improvement has decided what to write. Rubric evaluation of a
  skill's text with no behavioral evidence in hand is skill-writer's job;
  work driven by observed behavior stays here.
- `codify-lessons` - mines a session for lessons and routes them across
  enforcement tiers; its skill-tier proposals enter at Branch 1.

## Sources

Adapts concepts from four MIT-licensed repositories:
[obra/superpowers](https://github.com/obra/superpowers) (test-first skill
editing, match the form to the failure, micro-testing),
[mattpocock/skills](https://github.com/mattpocock/skills) (no-op test,
sediment, sprawl, context/cognitive load),
[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
(description as tested routing contract, extend-before-add),
[shadcn/improve](https://github.com/shadcn/improve) (verification as
commands, rejection ledgers).
