---
name: skill-writer
description: Write and evaluate agent skill text against a rubric covering invocation, skill contracts, rule form, information hierarchy, completion criteria, progressive disclosure, cross-context artifacts, and pruning. Use when drafting a new skill, applying a decided revision to a SKILL.md, or running a text-level rubric review of a skill before distribution. For diagnosing a skill that misbehaves in practice, gating whether something should become a skill, or pruning a skill portfolio, use skill-gardening instead.
---

# Skill Writer

Use this skill to create, revise, and evaluate agent skills. It does not replace
runtime-specific creators: prefer the target runtime's default creator for
baseline structure, then apply this skill as the judgment layer — whether the
resulting skill will be invoked correctly, guide the agent through the right
process, disclose information at the right time, and avoid stale or no-op
instructions.

## Workflow

1. Resolve the work mode and baseline.
   - For a new skill, use the runtime's default creator first. In Codex, use
     `skill-creator`. In Claude Code, use the local or built-in skill creation
     guidance when present.
   - For an existing skill, load the current `SKILL.md`, references, runtime
     metadata, and repository documentation before proposing changes.
   - For an existing skill, run the evaluation first: apply the rubric (step 3)
     and the checklist (step 6) to the current skill and report findings before
     revising (step 5) and validating (step 7).
   - If no default creator exists for a new skill, create only the minimal
     structure required by the target runtime.
   - Continue when a baseline skill directory exists or the existing skill has
     been loaded for revision or review.

2. Define the skill contract.
   - Identify the skill name, target runtime, placement, intended triggers,
     concrete user requests, required outputs, and validation method.
   - Decide whether the skill is repository-managed, project-specific, or
     global/user-level. If placement is unclear, ask before creating files.
   - Treat the contract as incomplete until at least two realistic user requests
     can be named.

3. Apply the evaluation model.
   - Read `references/skill-rubric.md`.
   - Map the proposed skill to the rubric's concepts, relationships, failure
     modes, and remedies.
   - When the skill adapts external source material, convert its concepts into
     evaluable criteria instead of compressing the text into a summary.
   - Continue when every relevant failure mode has either a prevention strategy
     or an explicit reason it does not apply.

4. Design the information hierarchy.
   - Keep the core workflow in `SKILL.md`. A skill can be all steps, all
     reference, or both; a reference-only skill keeps its rule set there
     instead.
   - Move bulky, branch-specific, or rarely needed material into `references/`.
   - Add `scripts/` only when deterministic execution or repeated validation is
     more reliable than prose.
   - Add `assets/` only when the skill needs reusable templates or output files.
   - Continue when each file has a distinct role and each reference has a clear
     context pointer from `SKILL.md`.

5. Write or revise the skill.
   - When revising an existing skill, report findings first and apply fixes
     only after the user confirms direction, unless the request already asked
     for fixes to be applied.
   - Make the description trigger-oriented when the runtime supports
     model-invoked skills.
   - Write steps as actions with checkable completion criteria.
   - State rules positively. Keep a prohibition only as a hard guardrail with
     its exceptions decided and inlined, paired with what to do instead.
   - Match each rule's form to the failure it prevents: recipe for shape,
     prohibition for discipline, predicate for conditions.
   - Make anything the skill hands to another context self-contained: subagent
     prompts restate rules verbatim; plans inline what they need.
   - Read the draft for negative space: decide each omission — fill it, or
     leave it open as an explicit branch.
   - When adding a new branch, shape, or category to an existing rule
     document, enumerate every rule keyed on its sibling values — routing
     predicates, prompt or output contracts, acceptance rules, and
     cross-referenced files — and decide each surface in the same revision
     (review catches stranded surfaces only one round at a time).
   - Keep one source of truth for each rule or concept.
   - Remove background explanation unless it changes agent behavior.
   - Continue when the draft can be reviewed without relying on unstated intent.

6. Review with the checklist.
   - Read `references/review-checklist.md`.
   - Apply the checklist in order and record blocking issues before polishing.
   - Fix blocking findings in every checklist area before calling the skill
     complete.
   - Continue when every finding is fixed or explicitly accepted.

7. Validate in the target runtime.
   - Run available validators or repository checks.
   - Update repository documentation such as `README.md` when the repository
     requires it.
   - For behavioral verification, including forward-tests and fresh-context
     re-runs against a control, hand off to `skill-gardening` when available;
     when it is absent, forward-test realistic prompts here and record that
     `skill-gardening` was absent.
   - Preserve the source-of-truth location resolved in the skill contract.
   - Continue when validation passes and any skipped check has a stated reason.
