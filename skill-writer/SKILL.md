---
name: skill-writer
description: Create, revise, and evaluate agent skills by resolving whether the work is new-skill creation or existing-skill review, using the target runtime's default creator for new skills, then applying an evaluation model for predictable invocation, clear skill contracts, information hierarchy, completion criteria, progressive disclosure, pruning, and runtime validation. Use when designing a new skill, improving an existing SKILL.md, or reviewing a skill before distribution.
---

# Skill Writer

Use this skill to create, revise, and evaluate agent skills. Prefer the target
runtime's default skill-creation workflow for baseline structure, then use this
skill to shape the skill contract, evaluation model, and review discipline.

This skill does not replace runtime-specific creators. It adds the judgment layer:
whether the resulting skill will be invoked correctly, guide the agent through the
right process, disclose information at the right time, and avoid stale or no-op
instructions.

## Workflow

1. Resolve the work mode and baseline.
   - For a new skill, use the runtime's default creator first. In Codex, use
     `skill-creator`. In Claude Code, use the local or built-in skill creation
     guidance when present.
   - For an existing skill, load the current `SKILL.md`, references, runtime
     metadata, and repository documentation before proposing changes.
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

3. Apply the source-model evaluation model.
   - Read `references/skill-rubric.md`.
   - Map the proposed skill to the rubric's concepts, relationships, failure
     modes, and remedies.
   - Do not treat source material such as `writing-great-skills` as text to
     compress. Convert its concepts into evaluable criteria for this skill.
   - Continue when every relevant failure mode has either a prevention strategy
     or an explicit reason it does not apply.

4. Design the information hierarchy.
   - Keep the core workflow in `SKILL.md`.
   - Move bulky, branch-specific, or rarely needed material into `references/`.
   - Add `scripts/` only when deterministic execution or repeated validation is
     more reliable than prose.
   - Add `assets/` only when the skill needs reusable templates or output files.
   - Continue when each file has a distinct role and each reference has a clear
     context pointer from `SKILL.md`.

5. Write or revise the skill.
   - Make the description trigger-oriented when the runtime supports
     model-invoked skills.
   - Write steps as actions with checkable completion criteria.
   - Keep one source of truth for each rule or concept.
   - Remove background explanation unless it changes agent behavior.
   - Continue when the draft can be reviewed without relying on unstated intent.

6. Review with the checklist.
   - Read `references/review-checklist.md`.
   - Apply the checklist in order and record blocking issues before polishing.
   - Fix weak invocation, missing completion criteria, unreliable pointers,
     duplication, no-op prose, sediment, and sprawl before calling the skill
     complete.

7. Validate in the target runtime.
   - Run available validators or repository checks.
   - Update repository documentation such as `README.md` when the repository
     requires it.
   - Forward-test on realistic prompts when the skill is complex,
     behavior-sensitive, or intended for repeated use.
   - Preserve the source-of-truth location resolved in the skill contract.

## Reference Use

Read `references/skill-rubric.md` when creating, revising, or evaluating a skill.
It defines the evaluation model and the source concepts that must be preserved.

Read `references/review-checklist.md` for a final review of an existing skill or
proposed skill change. It turns the rubric into an ordered inspection pass.
