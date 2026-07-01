# Skill Rubric

Use this rubric to evaluate agent skills. The goal is not to make a skill short.
The goal is to make the skill predictable: the agent should follow the same
process across runs, even when the exact output changes.

This model adapts concepts from Matt Pocock's `writing-great-skills` skill and
glossary:

- https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-great-skills
- MIT License, Copyright (c) 2026 Matt Pocock

Do not copy the source by shortening it. Translate its concepts and relationships
into criteria that can diagnose a concrete skill.

## Concept Coverage

The evaluation model must preserve these concepts and relationships:

- Predictability: the agent follows the same process, not the same output.
- Invocation: the skill must be reached by the right prompts or explicit user
  action.
- Description: for model-invoked skills, the description is both trigger and
  context pointer.
- Context load: model-visible descriptions spend attention on every turn.
- Cognitive load: user-invoked skills make the human remember when to use them.
- Branch: a distinct way the skill can be used.
- Leading word: a compact concept that anchors invocation or execution.
- Information hierarchy: steps and reference must sit at the right level.
- Steps: ordered actions that carry the main workflow.
- Reference: material consulted on demand.
- Context pointer: wording that tells the agent when to load hidden material.
- Progressive disclosure: material moves behind pointers because only some
  branches need it.
- Completion criterion: an observable condition that tells the agent a step is
  done.
- Legwork: the effort a step requires before it can honestly complete.
- Premature completion: stopping a step before its real work is done.
- Single source of truth: each behavioral rule has one authoritative home.
- Duplication: the same meaning appears in more than one place.
- Relevance: each line still bears on what the skill does.
- Sediment: stale layers remain because adding felt safer than removing.
- No-op: a relevant instruction does not change behavior versus the default.
- Sprawl: the skill is too long to read and maintain well, even if every line is
  live.

## Evaluation Criteria

### 1. Source-Model Integrity

Pass when source material is converted into an evaluation model, not shortened
into a weaker summary.

Check:

- Are source concepts preserved with the relationships that make them useful?
- Does each source concept become a criterion, diagnostic question, failure mode,
  remedy, or explicit non-applicability note?
- Are source examples and terminology retained only when they change evaluation
  behavior?
- Is attribution or license information retained when the skill adapts external
  material?
- Can the reviewer trace a finding back to a model relationship, not just a
  preference for shorter prose?

Fail when the skill compresses a source into generic advice, keeps only a concept
list without operational checks, or removes relationships such as description to
context pointer, completion criterion to premature completion, or progressive
disclosure to branch.

Remedy:

- Restore the missing relationship as a pass/fail criterion.
- Convert examples into diagnostic questions when the example itself is not
  needed.
- Keep source-model attribution near the adapted rubric.

### 2. Invocation Fit

Pass when the skill can be reached at the right time without crowding the agent's
context unnecessarily.

Check:

- Does the description say what the skill does and name concrete trigger
  contexts?
- Is each trigger a distinct branch rather than a synonym for the same branch?
- Does the description front-load the skill's leading word or strongest trigger?
- If the skill will only be used explicitly, does the target runtime support a
  user-invoked or disabled-implicit-invocation mode?
- Is the context load worth paying for autonomous model invocation?
- If invocation is manual, is the cognitive load acceptable, or should a router
  skill mention it?

Fail when the description is mostly identity, marketing, background, or repeated
body content.

Remedy:

- Rewrite the description around distinct triggers.
- Collapse synonym triggers.
- Split only when a branch needs independent invocation or another skill must
  reach it.

### 3. Skill Contract

Pass when the agent can tell what task the skill covers, where it belongs, what
files it may create or edit, and how success will be checked.

Check:

- Are the target runtime and placement explicit?
- Are at least two realistic user requests known?
- Are expected outputs and non-goals clear?
- Are repository policies, validation commands, and documentation updates named
  when applicable?

Fail when the skill could be interpreted as several unrelated tools or when
placement depends on hidden user preference.

Remedy:

- Ask for missing placement or scope decisions before writing files.
- Narrow the skill to one reusable capability or split distinct capabilities.

### 4. Information Hierarchy

Pass when the agent sees the workflow first and reads deeper material only when
the current branch needs it.

Check:

- Are core steps in `SKILL.md`?
- Is reference material secondary to the workflow?
- Is branch-specific material moved to `references/`?
- Does each reference have a context pointer that says when to read it?
- Are scripts used for fragile or repeated operations that prose would make
  unreliable?
- Are assets limited to reusable output materials?

Fail when `SKILL.md` is a glossary, archive, or background essay instead of an
action surface, or when required material is hidden behind a weak pointer.

Remedy:

- Inline material every branch needs.
- Move branch-specific reference behind a stronger pointer.
- Add scripts only where deterministic execution matters.

### 5. Completion Criteria

Pass when each important step has an observable done condition that demands
enough legwork.

Check:

- Can the agent tell whether the step is done?
- Does the criterion require the work that matters, not just a summary?
- Could the agent stop early and still appear compliant?
- Are later steps pulling attention away from the current step?

Fail when steps end with vague verbs such as "consider", "understand", "review",
or "improve" without a checkable result.

Remedy:

- Sharpen the completion criterion first.
- If the criterion cannot be made sharp and premature completion is observed,
  split the sequence so later work is hidden behind a real context boundary.

### 6. Progressive Disclosure

Pass when disclosure follows branches, not a desire to make the top file look
short.

Check:

- Does every branch need the material kept in `SKILL.md`?
- Is branch-only material behind a pointer?
- Does the pointer contain the condition for reading, not just a filename?
- Would missing the referenced material cause an incorrect result?

Fail when material is moved out only because it is long, or when a must-read file
is reachable only through vague wording.

Remedy:

- Keep must-read material inline.
- Strengthen the pointer before inlining everything back.
- Split by branch when separate branches make the top-level workflow unstable.

### 7. Leading Words

Pass when compact concepts anchor behavior without repeating the same meaning in
many places.

Check:

- Is there a short word or phrase the user, repo, or domain already uses?
- Does repeating that word help invocation or execution?
- Does the word replace several sentences of duplicated explanation?
- Is the word strong enough to change behavior versus the default?

Fail when the skill invents jargon that needs more explanation than it saves, or
when a repeated word is just decoration.

Remedy:

- Prefer existing domain language.
- Define a coined term only if it becomes shorter and sharper after definition.
- Delete repeated explanations once the leading word carries them.

### 8. Pruning

Pass when every line has a current job and every behavior has one source of
truth.

Check:

- Does the line change what the agent does?
- Is the line still relevant to the current skill?
- Is the same rule stated elsewhere?
- Is the line a no-op because the agent would already do it?
- Has old process sediment remained after the workflow changed?
- Is the file sprawling even after duplication and sediment are removed?

Fail when background, reassurance, generic best practice, or stale process text
survives because removing it feels risky.

Remedy:

- Delete no-op sentences instead of polishing them.
- Keep one authoritative location for each rule.
- Move live but branch-specific material behind pointers.
- Split by invocation or sequence only when the split reduces context or
  premature-completion risk.

### 9. Runtime Fit

Pass when the skill follows the target runtime's required structure while
preserving the agreed source of truth.

Check:

- Does the frontmatter match the runtime's required fields?
- Does the directory name match the skill name?
- Are runtime-specific metadata files present only when useful or required?
- Is the source-of-truth location identified before editing or synchronizing
  files?
- Are repository docs updated when a skill is added, renamed, or removed?

Fail when a skill mixes runtime conventions without naming the target runtime or
when useful changes exist outside the agreed source of truth.

Remedy:

- Use the target runtime's default creator first.
- Keep runtime mechanics in the workflow or a small runtime note.
- Reflect fixes back to the agreed source-of-truth location.

## Red Cases

The rubric must catch these failures:

- A description that says "helps with skills" but gives no trigger branches.
- A workflow step that says "review the skill" without a completion criterion.
- A large glossary placed in `SKILL.md` even though only one branch needs it.
- A reference file named from `SKILL.md` without saying when to read it.
- The same placement rule in both `SKILL.md` and a reference file.
- Generic instructions such as "be clear and thorough" that do not change
  behavior.
- Stale setup text left after the workflow changed.
- A correct but oversized skill that should be split or disclosed by branch.

## Finding Format

When applying this rubric, report findings in this shape:

- Severity: Blocker, Major, Minor, or Note.
- Criterion: the rubric section violated.
- Evidence: exact file and text or structure causing the problem.
- Impact: how the issue affects invocation, execution, validation, or
  maintenance.
- Remedy: the smallest change that fixes the model failure.
