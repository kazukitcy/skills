# Review Checklist

Use this checklist for the final review of a new or revised skill. Read
`references/skill-rubric.md` first when the evaluation model is not already in
context.

Return concrete findings, not generic approval. A finding needs evidence, impact,
and a minimal remedy.

## 1. Resolve Scope

- Identify the skill directory, target runtime, and source-of-truth location.
- Confirm the directory name matches the `name` value in `SKILL.md`.
- Confirm the skill belongs in this repository, a project-specific skills
  directory, or a global/user skills directory.
- Confirm repository documentation requirements such as `README.md` updates.

Completion criterion: the review target and placement contract are explicit.

## 2. Review Source-Model Integrity

- Identify any external source model the skill adapts.
- Confirm the source is treated as a model of concepts, relationships, failure
  modes, and remedies rather than text to summarize.
- Check that each important source relationship appears as a criterion,
  diagnostic question, or explicit non-applicability note.
- Confirm attribution or license notes are present when the skill adapts external
  material.

Completion criterion: the adapted source can drive concrete findings without
requiring the reviewer to reread or summarize the original source.

## 3. Review Invocation

- Read the frontmatter description.
- List each distinct trigger branch it names.
- Mark synonym triggers as duplication.
- Mark missing trigger branches when realistic user requests would not invoke the
  skill.
- Confirm the invocation mode matches reach: model-invoked when the agent or
  another skill must fire it and the context load is worth paying; user-invoked
  when only the human will, where the runtime supports that mode.
- For a user-invoked skill, confirm the description is a human-facing one-line
  summary, check whether a router skill should name it, and treat deliberate
  manual invocation as cognitive load spent on purpose, not a defect.

Completion criterion: every intended branch is either triggerable or explicitly
manual.

## 4. Review the Skill Contract

- Extract the target runtime, placement, expected outputs, non-goals, and
  validation method from the skill.
- Check whether at least two realistic user requests are covered.
- Mark hidden assumptions about placement, generated files, external tools, or
  validation as blockers when they could change the implementation.

Completion criterion: a new agent could create or revise the skill without
guessing the user's intent.

## 5. Review Workflow Steps

- Read the body of `SKILL.md` from top to bottom.
- For each important step, identify the action and completion criterion.
- Mark vague steps that can finish without observable evidence.
- Check whether later steps could pull the agent into premature completion.
- Check whether steps are written as actions rather than background explanation.
- If the skill is all reference, check for a stated exhaustiveness bar instead
  of step criteria; do not mark the absence of steps as a defect.

Completion criterion: each important step has an observable done condition and
requires enough legwork, or, for a reference-only skill, the reference states
its exhaustiveness bar.

## 6. Review Information Hierarchy

- Separate content into steps, in-skill reference, disclosed reference, scripts,
  and assets.
- Confirm the core workflow, or the core rule set of a reference-only skill,
  stays in `SKILL.md`.
- Confirm branch-specific or bulky reference lives in `references/`.
- Confirm each reference file has a context pointer in `SKILL.md` that says when
  to read it.
- Confirm each concept's definition, rules, and caveats are co-located under
  one heading rather than scattered across the file.
- Confirm scripts and assets exist only when they improve repeatability,
  determinism, or reuse.

Completion criterion: each file has one role and each reference is reachable at
the right time.

## 7. Review Progressive Disclosure

- For each reference file, name the branch or condition that needs it.
- Mark references that are hidden only because they are long.
- Mark required references whose pointers are too vague.
- Check whether must-read material should be inline.

Completion criterion: material is disclosed by branch need, not by a simple wish
to shorten `SKILL.md`.

## 8. Review Leading Words

- Identify the main words or phrases used to anchor invocation or execution.
- Check whether they are existing domain words or clearly defined local terms.
- Mark invented terms that cost more explanation than they save.
- Mark repeated explanations that a leading word should collapse.
- Grade each leading word with the no-op test; replace a weak word with a
  stronger one instead of dropping the technique.

Completion criterion: leading words sharpen behavior and do not create new
jargon debt.

## 9. Prune

- Search for duplicated rules across `SKILL.md` and `references/`.
- Remove or flag no-op sentences that do not change behavior versus the default.
- Settle contested no-ops by forward-testing the skill, not by debate.
- Flag sediment: stale setup, old process notes, or obsolete runtime mechanics.
- Flag sprawl after duplication and sediment are removed.
- Keep attribution or license notes only when they carry legal or source-model
  value.

Completion criterion: every remaining line has a current behavioral,
operational, or attribution job.

## 10. Validate

- Run the target runtime or repository validator when available.
- Check links from `SKILL.md` to references.
- Check frontmatter syntax and required fields.
- Check README or package index entries for added, renamed, or removed skills.
- Forward-test with a realistic prompt when the skill is complex or
  behavior-sensitive.

Completion criterion: structural validation passes, repository docs are aligned,
and any skipped forward-test has a stated reason.

## Output Format

Use this format:

```text
Findings
- [Severity] [Criterion] File:line or section - Evidence. Impact. Remedy.

Open Questions
- ...

Validation
- ...
```

Field meanings:

- Severity: Blocker, Major, Minor, or Note.
- Criterion: the rubric section violated.
- Evidence: exact file and text or structure causing the problem.
- Impact: how the issue affects invocation, execution, validation, or
  maintenance.
- Remedy: the smallest change that fixes the model failure.

If there are no findings, say so and list remaining validation gaps or residual
risk.
