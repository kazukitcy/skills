# Verification Protocol

Every gardening change ends with a re-run. Pick the protocol by change
type; the pass condition is stated per protocol. Run tests in a fresh
context - a subagent or headless run that has not seen this conversation -
because the author's own session mentally fills gaps a cold agent will
fall into.

## Controls come first

Before authoring any new guidance (Branch 1) and before fixing a
"failure" reported second-hand, run the control: the tempting task, fresh
context, without the proposed guidance.

The control is always the current state before the change:

- For a proposed brand-new skill, any fresh subagent - the guidance does
  not exist yet; just keep it out of the dispatch prompt.
- For a proposed extension, a fresh run with the current catalog as it
  stands (the existing skill loaded, the extension absent), and record
  which skills and instructions were active in the baseline.
- For an edit to an existing skill, the pre-edit version: run it from git
  (the last committed copy, via a worktree or a temporary checkout), not
  from memory of what it used to say.

Sample bar:
- One failing control run is evidence enough to proceed. Stopping
  ("nothing to fix") requires three or more clean control runs - skill
  failures are stochastic, and a single clean run proves nothing.
- The recorded control behavior becomes the baseline the fixed skill is
  compared against.

## Protocol A: Invocation changes (descriptions, triggers)

For description or trigger edits (taxonomy class 1):

1. Write 3+ positive prompts - paraphrases of real user speech, not the
   description's own words. Copying description phrasing into the test
   prompt is gaming the eval.
2. Write 2+ negative prompts that a *specific other* skill should win;
   name that owner skill. A negative without an owner is vacuous.
3. Run the routing check. Most runtimes expose no routing harness, so
   simulate one: give a fresh subagent the catalog's skill names and
   descriptions (with the revised description in place) plus one test
   prompt, and ask which skill, if any, it would invoke - one subagent
   per prompt, no explanation of which answer is hoped for. Where a real
   harness exists (headless runs that log skill invocation), grade the
   invocation in the trace instead. If the runtime offers neither
   subagents nor headless runs, record the routing check as blocked - a
   blocked check is not a pass, and the change is not complete until it
   runs.
4. Check the new description against the rest of the catalog for
   collisions - substantial phrase overlap with another description is a
   failure even if the prompts pass today, because collisions decay
   routing as the catalog grows.

Pass: every positive prompt selects the skill, every negative selects its
owner, no collision. On failure, fix the description - never the prompts.

## Protocol B: Wording changes (rules, recipes, criteria)

For body edits whose effect depends on phrasing (classes 3-6):

1. One sample per rep, fresh context each time; system context = the full
   realistic skill, not the changed sentence in isolation; user message =
   a task that tempts the original failure.
2. Scale reps to blast radius, and always include the control (the old
   wording): 2-3 reps for a single-sentence fix inside one step; 5+ reps
   for a new or rewritten recipe, rule, criterion, or anything the whole
   skill routes through. Single samples lie at every size.
3. Read every flagged output manually. Template echoes and quoted
   counter-examples masquerade as hits; automated counts overstate both
   failure and success.
4. Treat variance as a metric: when wording binds, reps converge on one
   shape. Five different interpretations across five reps means the form
   is wrong - tighten the form (recipe, slot, conditional), do not add
   words.

Pass: the failing scenario now passes, reps converge, and the control
still fails (proving the change, not chance, made the difference).

## Protocol C: Discipline changes (rules agents skip under pressure)

For class-2 fixes, wording reps are necessary but not sufficient - the
rule must survive pressure:

1. Build a scenario combining 3+ pressures: time ("demo in 20 minutes"),
   sunk cost ("you already wrote 200 lines"), authority ("the lead said
   skip it"), exhaustion, social ("don't be dogmatic").
2. Force a concrete A/B/C choice with real stakes and no easy out - "what
   do you DO?", not "what should you do?", and no deferring to asking the
   user.
3. Run without the skill (baseline), then with it.

Pass: the agent makes the correct choice under maximum pressure and cites
the skill. Not passing: fresh rationalizations, "hybrid approaches",
arguing the rule is wrong, or asking permission while arguing to violate.
Each new rationalization goes back into the skill (table + red flag) and
the scenario re-runs.

When a run is judged, grade the trace, not the narration: what the agent
did (tools called, order, files touched), not what it claimed. Narrated
compliance over a non-compliant trace is a failure.

## Protocol D: Deletions and pruning

Deletions are edits. After a pruning pass:

1. Re-run the skill's realistic prompts (the positive prompts from
   Protocol A double as this regression set) and compare behavior to
   before the pass.
2. A contested line - author defends, pruner doubts - is settled by
   forward-testing with and without it. The no-op test is model-relative,
   not reader-relative: debate cannot settle it; a run can.

Pass: behavior on the regression prompts is unchanged or improved, and
every contested deletion has a with/without run behind it.

## Recording

Record what was verified in the change itself - the commit message or PR
body; when the change has no commit to attach to, a dated note in the
skill's directory or the location the user designates. Contents: the
failure reproduced, the class assigned, the protocol run, rep counts, and
the result. A protocol may be skipped only for changes that cannot alter
behavior - typo fixes, link-path corrections, formatting - and the skip is
named with that reason; "too expensive" is not a skip reason, it is a
reason to use the low end of the rep scale. Rejected fixes and rejected
deletions are recorded too - a rejection ledger prevents the same non-fix
from being proposed again next season.
