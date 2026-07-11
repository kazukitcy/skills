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
- Check that engine-, version-, or API-specific behavior claims taken from
  research are verified against primary documentation or an adversarial
  fact-check before adoption (researched sources return plausible but wrong
  specifics).
- Confirm attribution or license notes are present when the skill adapts external
  material.

Completion criterion: the adapted source can drive concrete findings without
requiring the reviewer to reread or summarize the original source.

## 3. Review Invocation

- Read the frontmatter description.
- List each distinct trigger branch it names.
- Mark any workflow or process summary in the description as a defect.
- Mark synonym triggers as duplication.
- Mark missing trigger branches when realistic user requests would not invoke the
  skill.
- Check triggers against realistic user vocabulary, not the skill body's own
  terminology.
- Compare sibling skills' descriptions and mark collisions.
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
- Check execution-context preconditions such as live-user requirements or bans on
  CI and scheduled invocation.
- When the skill ingests external content, confirm it marks that content as data,
  not instructions, and says what to do with instruction-like content found in
  it.
- Mark hidden assumptions about placement, generated files, external tools, or
  validation as blockers when they could change the implementation.

Completion criterion: a new agent could create or revise the skill without
guessing the user's intent.

## 5. Review Rule Form

- List every prohibition and negation.
- Confirm each negation is positively rephrased or kept as a hard guardrail with
  inlined exceptions and a positive target.
- Check that wrong-shaped output gets a recipe or template, discipline failures
  get a scoped prohibition, and condition-dependent behavior gets an observable
  predicate.
- Where rules branch on the same observable state, check the set resolves
  every reachable state deterministically — mutually exclusive and
  exhaustive predicates, or an ordered first-match list with a default —
  and apply step 11's negative-space test to any unmapped state.
- Check that replacement or retry rules cannot create effects conflicting
  with the attempt they replace: proof of termination, or another
  exclusivity guarantee such as cancellation, fencing, or idempotency.
- Check that automatically triggered destructive or irreversible recovery
  actions are keyed to predicates that exclude healthy states, or routed
  through a stop-gate.
- Flag nuance clauses and exemption clauses.
- Check refusals for predictable off-contract requests are scripted with
  legitimate alternatives.
- Check imperative intensity matches skill type: strong commitment devices for
  discipline skills, plain clarity for reference skills.

Completion criterion: every rule has a form verdict, and every negation a
rewrite-or-guardrail verdict.

## 6. Review Workflow Steps

- Read the body of `SKILL.md` from top to bottom.
- For each important step, identify the action and completion criterion.
- Mark vague steps that can finish without observable evidence.
- Mark human-judgment criteria that are self-assessed instead of written as
  stop-gates.
- Mark workflow steps that restate procedures the model already holds instead of
  naming the leading word and local divergence.
- Check whether later steps could pull the agent into premature completion.
- Check whether steps are written as actions rather than background explanation.
- If the skill is all reference, check for a stated exhaustiveness bar instead
  of step criteria; do not mark the absence of steps as a defect.

Completion criterion: each important step has an observable done condition and
requires enough legwork, or, for a reference-only skill, the reference states
its exhaustiveness bar.

## 7. Review Information Hierarchy

- Separate content into steps, in-skill reference, disclosed reference, scripts,
  and assets.
- Confirm the core workflow, or the core rule set of a reference-only skill,
  stays in `SKILL.md`.
- Confirm branch-specific or bulky reference lives in `references/`.
- Confirm each reference file has a context pointer in `SKILL.md` that says when
  to read it.
- Confirm each concept's definition, rules, and caveats are co-located under
  one heading rather than scattered across the file.
- Confirm shared reference lives in a home the intended readers can reach.
- Confirm cross-skill dependencies are prose invocations by name, not deep
  `../other-skill/file.md` paths.
- Confirm reference chains stay one level deep.
- Check script-vs-inline-code token accounting: executing a script costs no
  context except its output; inline code is paid on every load.
- Confirm scripts and assets exist only when they improve repeatability,
  determinism, or reuse.

Completion criterion: each file has one role and each reference is reachable at
the right time.

## 8. Review Progressive Disclosure

- For each reference file, name the branch or condition that needs it.
- Mark references that are hidden only because they are long.
- Mark required references whose pointers are too vague.
- Check whether must-read material should be inline.

Completion criterion: material is disclosed by branch need, not by a simple wish
to shorten `SKILL.md`.

## 9. Review Cross-Context Artifacts

- Identify artifacts the skill has the agent produce for another context:
  subagent prompts, plans, handoff documents, or later-session notes.
- Check that each artifact inlines everything its reader needs.
- Check that subagent prompts restate verbatim every safety or scope rule the
  subagent must obey.
- Check templates for a quality bar the agent applies before finishing.
- Check long-running or risky delegated work for task-specific STOP conditions.
- Check staleable artifacts for their own staleness marker.

Completion criterion: no artifact depends on the writer's context.

## 10. Review Leading Words

- Identify the main words or phrases used to anchor invocation or execution.
- Check whether they are existing domain words or clearly defined local terms.
- Mark invented terms that cost more explanation than they save.
- Mark repeated explanations that a leading word should collapse.
- Grade each leading word with the no-op test; replace a weak word with a
  stronger one instead of dropping the technique.

Completion criterion: leading words sharpen behavior and do not create new
jargon debt.

## 11. Prune

This is the drafting-time pass over the text in hand; the ordered line tests —
duplication, relevance, no-op, sediment, sprawl — are defined, with their
cures, in `skill-gardening`'s pruning-pass reference, which also owns
lifecycle and portfolio pruning.

- Run the ordered line tests across `SKILL.md` and `references/`; remove or
  flag failing lines.
- Read the draft for negative space; mark omissions never decided as filled or
  explicitly open.
- Settle contested no-ops by forward-test, not debate, under step 12's
  behavioral-verification rule.
- Apply a load-frequency-tiered sprawl bar: always-loaded descriptions harshest,
  every-run `SKILL.md` next, on-demand references loosest.
- Flag mandated template sections kept thin or empty as boilerplate.
- Keep attribution or license notes only when they carry legal or source-model
  value.

Completion criterion: every remaining line has a current behavioral,
operational, or attribution job.

## 12. Validate

- Run the target runtime or repository validator when available.
- Check links from `SKILL.md` to references.
- Check frontmatter syntax and required fields.
- Check README or package index entries for added, renamed, or removed skills.
- For behavioral verification, including forward-tests and fresh-context
  re-runs against a control, hand off to `skill-gardening` when it is available;
  when it is absent, forward-test realistic prompts here and record that
  absence.

Completion criterion: structural validation passes, repository docs are aligned,
any local prompt test records why it stayed here, and any skipped check has a
stated reason.

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
