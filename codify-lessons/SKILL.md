---
name: codify-lessons
description: Pair what failed first with what finally worked in a session or transcript, then codify the insight as a lint rule, runtime enforcement, skill, memory note, or agent instruction rule. Use only when the user explicitly invokes it or asks to codify lessons; never fire it automatically.
disable-model-invocation: true
---

# Codify Lessons

Extract the "if only I had known this first" insight from a task that
required trial and error, and pin it down in the most machine-enforced form
available. Never write anything out without explicit user approval: the flow
is always propose, then approve, then write.

This skill is user-invoked only. Do not fire it automatically at task
completion; the human decides when a session is worth codifying.

## Resolve inputs

Before the workflow, resolve two things:

- **Target session.** If an argument names a transcript file or session log,
  read that file and treat it as the session under review. Otherwise, review
  the current conversation.
- **Runtime reference.** Read the reference matching the environment you are
  running in — it defines the concrete destination locations (skills
  directories, instruction files, enforcement config, memory notes, lint
  rules) and the dedup search commands the steps below refer to:
  - Claude Code: [references/runtime-claude-code.md](references/runtime-claude-code.md)
  - Codex: [references/runtime-codex.md](references/runtime-codex.md)
  - Any other runtime: pick the closer of the two, substitute that runtime's
    equivalent locations, and confirm the substituted locations with the user
    before running the dedup search or writing anything.

## Workflow

1. **Enumerate abandoned approaches.** Scan the whole session and list every
   point where an approach was abandoned, reverted, or retried — not just the
   most recent one — and every place essentially the same improvised snippet
   or command was re-derived. Re-deriving something a second time is as
   strong a signal as a failure: it marks a lesson whose current form (prose
   or memory) is the wrong tier. The step is done when the list covers the
   full session and each entry names what was tried and why it was dropped
   or re-derived. From this list, select the entries worth codifying;
   discard first-try successes.
2. **Pair failure with success.** For each selected entry write three points:
   the first attempt (what was done and how it failed), the final solution
   (what worked), and the bridging insight (why the first attempt could not
   get there). A lesson missing its failure side is incomplete — without it
   the next reader falls into the same trap.
3. **Verbalize the instruction.** Compress each insight into 1-3 imperative
   sentences addressed to a future agent ("do not do X", "check Y before Z"),
   each with a parenthesized reason. Abstract one level above the incident:
   codify "what to check", not the one-off file name or version number.
4. **Dedup check (mandatory).** Extract 2-3 search keys per lesson (tool
   names, API names, symptom words) and run the runtime reference's dedup
   search commands against all six destination kinds: skills, instruction
   files, lint rules, enforcement config, repository scripts, and memory
   notes. Do not skip a kind because a hit already turned up in another. Any
   searched path may be absent — that is "checked, absent", not a failure.
   The step is done when each of the six kinds is recorded as hit, no hit,
   or location absent.

   Classify each lesson: **new** (no hits), **append to existing** (related
   entry exists, new info is complementary), **duplicate** (fully covered —
   no proposal, but report it with the covering file and section as
   evidence), or **undecidable** (show the hits and ask the user). A
   memory-note hit means the lesson has recurred: propose promotion per the
   table below.
5. **Classify the destination.** First route out project-specific one-offs:
   they go straight to the Not adopted row, never to a memory note. Then
   apply the confidence gate to what remains: if the lesson is a first
   occurrence with uncertain generality, propose a memory note (one entry,
   one lesson) instead of any table row. Promote it to a table row only when
   a later session shows it recurring — a memory-note hit in step 4. Skip
   the gate only when generality is already certain (documented behavior, or
   reproducible by a test).

   Split compound lessons before classifying: when a lesson mixes a
   procedure with a warning, classify each part separately — the procedure
   goes to the highest machine tier that fits, the warning becomes a prose
   rule pointing at it. Otherwise the prose half drags the whole lesson down
   the table.

   For each part, walk the table top to bottom and take the first row that
   fits. Prefer machine enforcement over prose: an agent reliably obeys a
   lint rule, enforcement gate, or script, only usually obeys a skill, and
   sometimes obeys a sentence in an instruction file.

   | Nature of the lesson | Destination |
   | --- | --- |
   | Detectable at code/config syntax level | Lint rule (ast-grep or existing linter config) |
   | Enforceable at the operation level (forbid or require a specific command or tool call) | Runtime enforcement (hooks, permission rules, command gates — per the runtime reference) |
   | Reducible to a fixed command sequence, no gate or judgment needed | Repository script (checked in, executable) plus a one-line pointer in the agent instruction file |
   | Requires a procedure, contextual judgment, or templates | Skill — new, or append to an existing one |
   | Short always-applied rule, no judgment involved | Agent instruction file (user global if cross-project, else the project's) |
   | Project-specific one-off | Not adopted — a commit message or PR description is enough |

6. **Vet, then present the proposals.** Before presenting, vet each
   adoption candidate against four failure classes, each with its own
   exit: a no-op (a future agent would already behave this way by
   default) and a dressed-up one-off (a project-specific incident phrased
   as a general rule) move to Not adopted with the class as the reason; a
   wrong tier (a different row of the step-5 table fits, or the scope is
   wrong) is reclassified per the step-5 table and vetted again; a
   duplicate that survived step 4 moves to the Duplicate detected section
   with its covering location. Attach to each surviving candidate the
   failure it prevents (from step 2) and a confidence grade with the
   evidence behind it — recurrence, documented behavior, a cold-read
   verdict, or a stated causal link to the step-2 failure; a candidate
   backed only by the causal link caps at low confidence. No vibes-only
   proposals.

   Settle a contested or uncertain no-op verdict behaviorally, not by
   self-critique — session context fills gaps a future agent will not
   have. When `skill-gardening` is available, hand the check to its
   control-check protocol by name and record the returned verdict.
   Otherwise run a cold read yourself: a fresh-context run (subagent or
   headless) given the tempting scenario without the proposed wording,
   whose prompt restates verbatim that the run is read-only — no file
   edits, no artifact writes, return the observed default behavior only.
   When the runtime offers neither, record the verdict as blocked — a
   blocked check is not a pass — and present the candidate with the open
   question flagged for the user.

   Present every lesson in the Retrospective/Proposals format — read
   [references/presentation-format.md](references/presentation-format.md)
   for the exact layout and its variants before writing the report. List
   non-adoptions and duplicates explicitly to leave a trace of the judgment;
   zero proposals is a valid outcome. This step is done when every presented
   candidate carries its prevents/confidence line, the report is shown, and
   you have stopped, with nothing written, awaiting the user's selection.
7. **Write out the adopted items.** Only after the user names items to
   adopt: generate their artifacts from
   [references/output-templates.md](references/output-templates.md),
   validate each, and show the diff. Validation is destination-specific:
   run the rule tests for lint rules (`ast-grep test`), run the enforcement
   validation the runtime reference names (e.g. `codex execpolicy check`, a
   JSON/TOML parse), and check frontmatter and reference links for skills;
   when a destination has no runnable validation, name the skipped check in
   the report. This step is done when every adopted
   item is written, validated (or its skipped check named), its diff shown,
   and nothing else was touched.

For worked end-to-end examples (one per destination tier), read
[references/examples.md](references/examples.md).

## Red flags

Stop and reconsider when any of these thoughts appear:

| Rationalization | Reality |
| --- | --- |
| "Project-specific, but let's make a skill just in case" | Skills bloat and searchability drops. First occurrences with uncertain generality go to a memory note; one-offs go in the commit message. |
| "Skip approval and write it out first" | Unapproved changes to skills or instruction files make future behavior unpredictable. Propose, approve, write — in that order. |
| "Writing it as prose is faster than a lint rule or enforcement gate" | Agents drift from prose. If a row higher in the table fits, use it. |
| "The insight is thin, but I should write something" | Zero proposals is a correct answer. |
| "Dedup is tedious; I'll clean duplicates later" | Duplicate rules split behavior. Dedup is mandatory. |
| "I'll just re-derive that snippet inline again" | Hand-writing the same snippet a second time means the lesson belongs in the script tier, not prose. |
| "Only the last lesson matters" | Step 1 requires enumerating the whole session before selecting. |

## Related skills

Use these when they are available in the active runtime; otherwise apply the
templates in `references/output-templates.md` directly.

- `skill-gardening` — when a lesson classifies to the skill tier, run its
  creation gate (control check, extend-before-add) before any drafting
- `skill-writer` — rubric and checklist when the destination is a new or revised skill
- `ast-grep-practice` — writing and testing lint rules
- The runtime configuration skill named in the runtime reference — when the destination is runtime enforcement
