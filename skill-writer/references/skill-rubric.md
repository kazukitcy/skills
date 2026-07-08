# Skill Rubric

Use this rubric to evaluate agent skills. The goal is not to make a skill short.
The goal is to make the skill predictable: the agent should follow the same
process across runs, even when the exact output changes.

This model adapts concepts from four MIT-licensed sources:

- `mattpocock/skills` `writing-great-skills` and glossary:
  https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-great-skills
  and
  https://github.com/mattpocock/skills/blob/main/skills/productivity/writing-great-skills/GLOSSARY.md
  MIT License, Copyright (c) 2026 Matt Pocock.
- `obra/superpowers` `writing-skills`:
  https://github.com/obra/superpowers/tree/main/skills/writing-skills
  MIT License, Copyright (c) 2025 Jesse Vincent.
- `addyosmani/agent-skills` skill anatomy and routing evals:
  https://github.com/addyosmani/agent-skills/blob/main/docs/skill-anatomy.md
  and https://github.com/addyosmani/agent-skills/tree/main/evals
  MIT License, Copyright (c) 2025 Addy Osmani.
- `shadcn/improve` handoff-artifact design:
  https://github.com/shadcn/improve/tree/main/skills/improve
  MIT License, Copyright (c) 2026 shadcn.

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
  Not a cost to always minimize: it is the price of human agency, spent on
  purpose where human judgment should gate the run.
- Router skill: one user-invoked skill that names the other user-invoked skills
  and when to reach for each.
- Granularity: how finely capability is divided into skills; each extra skill
  spends context load or cognitive load.
- Branch: a distinct way the skill can be used.
- Leading word: a compact concept that anchors invocation or execution.
- Information hierarchy: steps and reference must sit at the right level.
- Steps: ordered actions that carry the main workflow. A skill can be all
  steps, all reference, or both; a reference-only skill is a flat peer-set of
  rules, not a defect.
- Reference: material consulted on demand.
- External reference: shared reference that lives outside any skill and that
  several skills reach by pointer.
- Context pointer: wording that tells the agent when to load hidden material.
- Progressive disclosure: material moves behind pointers because only some
  branches need it.
- Co-location: a concept's definition, rules, and caveats sit together under
  one heading instead of scattered across the file.
- Completion criterion: an observable condition that tells the agent a unit of
  work is done. Its clarity resists premature completion; its demand sets
  legwork and binds flat reference through an exhaustiveness bar.
- Legwork: the effort a step requires before it can honestly complete.
- Post-completion steps: the visible later steps that pull attention toward
  being done.
- Premature completion: stopping a step before its real work is done.
- Single source of truth: each behavioral rule has one authoritative home.
- Duplication: the same meaning appears in more than one place, inflating its
  prominence past its real rank.
- Relevance: each line still bears on what the skill does; a line loses it by
  never bearing on the task or by going stale.
- Sediment: stale layers remain because adding felt safer than removing.
- No-op: a relevant instruction does not change behavior versus the default.
- Sprawl: the skill is too long to read and maintain well, even if every line is
  live.
- Negation: steering by prohibition activates the forbidden concept; a ban
  half-reads as an instruction to do the thing.
- Negative space: what a skill leaves unsaid delegates the decision to the
  agent's priors, so omissions are filled, or left open as an explicit branch.
- Rule form: the rhetorical form of a rule must match the failure it prevents;
  prohibitions cure discipline violations and worsen shaping problems.
- Cross-context artifact: output produced for a reader outside the current
  context must be self-contained because pointers only work for readers who
  share the writer's context.
- Stop-gate: a completion criterion that needs human judgment must be an
  explicit confirmation gate, not a self-assessed state.
- Load frequency: context budgets are tiered by how often material is loaded:
  always-loaded descriptions harshest, every-run `SKILL.md` next, on-demand
  references loosest.
- Reachability: shared reference homes are determined by invocation modes; a
  model-invoked reference skill can be fired by other skills, an external
  reference file is the only shared home two user-invoked skills can use, and a
  router can only hint.
- Trust boundary: content a skill has the agent ingest from outside is data, not
  instructions.

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

The description is the invocation axis. Keeping a model-facing description makes
the skill model-invoked: the agent, other skills, and the user can all reach it,
at a permanent context load. Disabling model invocation (for example
`disable-model-invocation: true`, where the runtime supports it) makes the skill
user-invoked: zero context load, but only the human can fire it — no other skill
can — and the description becomes a human-facing one-line summary with trigger
lists stripped.

Check:

- Does the description say what the skill does and name concrete trigger
  contexts?
- Does the description avoid summarizing the skill's workflow or process steps?
  A workflow-summary description becomes a shortcut the agent follows instead
  of reading the body.
- Is each trigger a distinct branch rather than a synonym for the same branch?
- Are triggers phrased in the vocabulary users actually use, not in the body's
  own terminology?
- Is the description distinct from sibling skills' descriptions?
- Does the description front-load the skill's leading word or strongest trigger?
- Is the context load worth paying for autonomous model invocation, or should
  the skill be user-invoked?
- If the skill is user-invoked, is it certain that no other skill must reach
  it?
- If invocation is manual, is the cognitive load acceptable, or should a router
  skill name it?
- Is manual invocation deliberate? When human judgment should gate the run,
  cognitive load is spent on purpose; do not recommend model invocation just to
  relieve it.

Fail when the description is mostly identity, marketing, background, repeated
body content, workflow summary, internal terminology, or a near-duplicate of a
sibling skill's description.

Remedy:

- Match the invocation mode to reach before polishing the description.
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
- Are execution-context preconditions stated when they exist, such as a live
  interactive user or a ban on CI or scheduled invocation?
- When the skill ingests external content, does it mark that content as data,
  not instructions, and say to surface instruction-like content rather than obey
  it?

Fail when the skill could be interpreted as several unrelated tools or when
placement depends on hidden user preference.

Remedy:

- Ask for missing placement or scope decisions before writing files.
- Narrow the skill to one reusable capability or split distinct capabilities.

### 4. Rule Form

Pass when each rule's form matches the failure it prevents.

Check:

- For wrong-shaped output, does the skill give a positive recipe or template
  stating what the output is, with required slots for omitted elements?
- For rule-skipping under pressure, is any prohibition paired with the positive
  target and the reason?
- For condition-dependent behavior, is the rule keyed to an observable
  predicate?
- Is each negation rewritten positively or kept as a hard guardrail with scoped
  exceptions and the positive target inlined?
- Are nuance clauses and exemption clauses removed so edge cases do not invite
  improvisation?
- When the skill must refuse predictable off-contract requests, is the refusal
  scripted with a legitimate alternative?
- Does imperative intensity match skill type: strong commitment devices for
  discipline skills, plain clarity for reference skills?

Fail when a shaping problem is patched with a prohibition, a prohibition stands
alone without its positive target, or nuance and exemption clauses give the
agent a negotiation opening.

Remedy:

- Restate the rule in the form matched to its failure.
- For the behavioral evidence loop that classifies an observed failure, hand
  off to `skill-gardening`.

### 5. Information Hierarchy

Pass when the agent sees the primary tier first — the workflow when the skill
has steps, the rule set when it is all reference — and reads deeper material
only when the current branch needs it.

Check:

- Are core steps, or the core rule set of a reference-only skill, in
  `SKILL.md`?
- When the skill has steps, is reference material secondary to them? In-file
  reference that buries steps turns attending to them into a coin flip.
- Is branch-specific material moved to `references/`?
- Does each reference have a context pointer that says when to read it?
- Are a concept's definition, rules, and caveats co-located under one heading
  rather than scattered across the file?
- Is reference shared by several skills kept in one home — an external
  reference file or a reference skill — instead of copied into each?
- Does shared reference live in a home the intended readers can reach?
- Are cross-skill dependencies prose invocations by name instead of deep
  `../other-skill/file.md` paths?
- Are reference chains one level deep, with `SKILL.md` pointing to a reference
  and references not chaining onward to further must-read files?
- Are scripts used for fragile or repeated operations that prose would make
  unreliable?
- Are scripts used instead of inline code when execution can avoid loading the
  code into context?
- Are assets limited to reusable output materials?

Fail when a skill with steps buries them under in-file reference, when required
material is hidden behind a weak pointer, or when one concept's rules are
scattered so reading one part misses its neighbors. Do not fail a
reference-only skill for having no steps; a flat peer-set of rules is a fine
arrangement.

Remedy:

- Inline material every branch needs.
- Move branch-specific reference behind a stronger pointer.
- Regroup scattered material under its concept's heading.
- Add scripts only where deterministic execution matters.

### 6. Completion Criteria

Pass when each important step has an observable done condition that demands
enough legwork.

A completion criterion has two axes. Clarity — can the agent tell done from
not-done? — resists premature completion, and only bites when the skill has
steps. Demand — how much the criterion requires — sets legwork and also binds
flat reference: "every rule applied" gives a reference-only skill its
exhaustiveness bar where "produce a change list" does not.

Check:

- Can the agent tell whether the step is done?
- Does the criterion require the work that matters, not just a summary?
- Could the agent stop early and still appear compliant?
- Is any criterion that needs human judgment written as an explicit stop-gate
  that waits for the human to confirm?
- Are visible post-completion steps pulling attention away from the current
  step?
- Are procedural steps the model already knows collapsed to a leading-word
  reference, with only the local divergence kept?
- If the skill is all reference, does it state an exhaustiveness bar?

Fail when steps end with vague verbs such as "consider", "understand", "review",
or "improve" without a checkable result, when human confirmation is self-assessed
by the agent, when a known procedure is restated as no-op workflow, or when a
reference-only skill never says how much of its reference a run must cover.

Remedy:

- Sharpen the completion criterion first; it is local and cheap.
- Turn human-judgment criteria into stop-gates.
- Collapse pretrained procedures to leading-word references and keep only what
  diverges from the default.
- Only if the criterion is irreducibly fuzzy and the rush is actually observed,
  split the sequence so later work is hidden behind a real context boundary — a
  user-invoked hand-off or a subagent dispatch; an inline call leaves the later
  steps in context and clears nothing.

### 7. Progressive Disclosure

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

### 8. Cross-Context Artifacts

Pass when material that crosses a context boundary is self-contained.

Check:

- Do outputs written for another agent or later session inline everything the
  reader needs?
- Do subagent prompts restate verbatim every safety or scope rule the subagent
  must obey?
- When output shape matters, does the skill ship a template that ends with a
  quality bar the agent checks before finishing?
- Does long-running or risky delegated work carry task-specific STOP conditions?
- Do artifacts that can go stale carry their own staleness marker, such as the
  commit they were planned against?

Fail when a handoff artifact depends on the writer's context, or a subagent
prompt assumes inherited rules.

Remedy:

- Inline what the artifact needs.
- Re-transmit rules verbatim.
- Add the template's quality bar.

### 9. Leading Words

Pass when compact concepts anchor behavior without repeating the same meaning in
many places.

A leading word recruits priors the model already holds, so an existing word is
free where a coined word pays its definition in tokens. Repeat it as a token,
never as a re-explained sentence: repeating the word raises attention on
purpose; repeating the meaning is duplication.

Check:

- Is there a short word or phrase the user, repo, or domain already uses?
- Does repeating that word help invocation or execution?
- Does the word replace several sentences of duplicated explanation?
- Is the word strong enough to change behavior versus the default? A weak
  leading word ("be thorough" when the agent is already thorough) is a no-op.
- Are there restatements elsewhere in the skill that a single leading word
  could retire?

Fail when the skill invents jargon that needs more explanation than it saves, or
when a repeated word is just decoration.

Remedy:

- Prefer existing domain language.
- Define a coined term only if it becomes shorter and sharper after definition.
- Replace a weak leading word with a stronger one ("thorough" to "relentless")
  rather than abandoning the technique.
- Delete repeated explanations once the leading word carries them.

### 10. Pruning

Pass when every line has a current job and every behavior has one source of
truth.

Check:

- Does the line change what the agent does?
- Is the line still relevant to the current skill?
- Is the same rule stated elsewhere?
- Is the line a no-op because the agent would already do it?
- Has old process sediment remained after the workflow changed?
- Is each omission deliberate: filled, or left open as an explicit branch,
  rather than silently delegated to the agent's priors?
- Is sprawl judged against load frequency, with the harshest bar for
  always-loaded descriptions and the loosest for on-demand references?
- Is a mandated template section kept thin or empty as boilerplate?
- Is the file sprawling even after duplication and sediment are removed?

Fail when background, reassurance, generic best practice, or stale process text
survives because removing it feels risky, or when undecided omissions silently
delegate decisions to the agent's priors.

Remedy:

- Run the no-op test sentence by sentence and delete the failing sentence
  whole; most prose that fails should go, not be rewritten.
- The no-op test is model-relative: settle a contested no-op by a forward-test,
  not debate — behavioral verification is owned by the review checklist's
  Validate step.
- Decide each silence: fill it or name it as an open branch.
- Keep one authoritative location for each rule.
- Delete boilerplate template sections that fail the no-op test.
- Move live but branch-specific material behind pointers.
- Split by invocation or sequence only when the split reduces context or
  premature-completion risk.

### 11. Runtime Fit

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
- A reference-only skill marked as failing because it has no steps.
- One concept's definition, rules, and caveats scattered across distant
  sections.
- A weak leading word kept because it is relevant, even though it changes
  nothing versus the default.
- A user-invoked skill converted to model invocation only to relieve cognitive
  load, removing a human gate that was there on purpose.
- A description that summarizes the workflow, letting the agent skip the body.
- A shaping problem patched with "never do X", making the output worse.
- "Don't X unless it matters" — a nuance clause that reopens negotiation.
- A subagent prompt that assumes the parent's rules are inherited.
- A handoff plan that references "the pattern discussed above".
- A mandated section kept empty to satisfy a template.
- A workflow of steps that restates a procedure the model already holds.
- A completion criterion needing human confirmation but written as
  self-assessed.
- Two sibling skills whose descriptions are near-duplicates, splitting
  invocations.

## Finding Format

Report findings in the output format defined in
`references/review-checklist.md`.
