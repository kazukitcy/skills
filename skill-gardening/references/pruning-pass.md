# Pruning Pass

Run the per-skill pass on every file of the skill - SKILL.md, references,
scripts - and the portfolio pass across the collection. The per-skill pass
is ordered: each test assumes the previous one already ran, and each
pathology has a different cure, so a mislabeled line gets the wrong
treatment.

## Per-skill line pass

### 1. Duplication -> collapse to one source

Find the same meaning stated in more than one place: SKILL.md repeating a
reference file, two sections restating one rule, synonym triggers in the
description. Duplication is not emphasis - it inflates a meaning's
prominence past its real rank and makes every future edit a multi-place
edit. Cure: keep one authoritative statement where the hierarchy says it
belongs; replace the others with the concept's leading word (a repeated
token raises attention on purpose; a repeated meaning is the accident) or
delete them.

### 2. Relevance -> delete or rewrite what no longer bears

For each surviving line: does it still bear on what the skill does? Lines
lose relevance three ways - they never bore on the task (background,
marketing, reassurance) or the world drifted (renamed tools, removed
steps, changed runtimes), or a project-level skill's line contradicts its
host project's observable conventions, often because a generic skill was
copied into the project and never adapted. Verify named files, flags, and
skills still exist before keeping a line that depends on them.

For a project-level skill, verify every rule against the project's
observable reality - code, tests, configuration, and the project
instruction file (`CLAUDE.md`, `AGENTS.md`, or the runtime's equivalent)
- and require an established convention, not a lone occurrence. Rewrite
a conflicting line in this pass to state the project's actual
convention. If the project documents the opposite intent, such as its
instruction file recording a migration away from the current pattern,
keep the line.

### 3. No-op test -> delete sentences that change nothing

For each relevant sentence: does it change what the agent does versus its
default? "Be careful", "make sure to be thorough", "use best practices" -
the agent already intends all of it; the line pays load to say nothing.

- Test sentence by sentence, and delete the failing sentence whole -
  prose that fails should go, not be rewritten shorter.
- The test is model-relative, not reader-relative: a line that looks
  obviously useful can still be a no-op on the current model. Contested
  lines are settled by a forward-test (Protocol D in
  verification-protocol.md), not by debate.
- A weak leading word is a no-op with a different cure: replace it with a
  stronger word ("relentless" for "thorough") rather than deleting the
  technique.

### 4. Sediment -> core down through the layers

Sediment is what accumulates when every past incident added a line and
none removed one: old workarounds for fixed bugs, notes for retired
runtimes, three generations of the same instruction in different words.
It survives because adding feels safe and removing feels risky - which is
exactly why this pass exists on a schedule rather than waiting for a
failure. Read the file as strata: for each layer, ask what incident
deposited it and whether that incident can still occur.

### 5. Sprawl -> restructure, do not delete

After duplication, dead lines, and sediment are gone, the file may still
be too long - every line live and unique, attention thinning across the
excess. Sprawl's cure is structural, not deletion: move branch-specific
material behind a context pointer whose wording carries the reading
condition, or split by branch (independent trigger) or by sequence
(across a real context boundary). Splitting inline-called content clears
nothing.

### The description last, and hardest

A model-invoked skill's description is loaded every turn of every session,
so it earns the harshest pass: triggers only, one per branch, no workflow
summary, no identity prose the body already carries. Then re-run
invocation checks (Protocol A) - description pruning is an invocation
change. A user-invoked skill (`disable-model-invocation: true`) is the one
exception: its description is a human-facing one-line summary, so prune
trigger lists from it and skip Protocol A - there is no routing to test.

## Portfolio pass

Across all skills in scope, record a result per check:

- **Description collisions.** Compare model-invoked descriptions
  pairwise. A collision is concrete, not aesthetic: two descriptions
  claim the same user intent, share trigger phrases, or a Protocol A
  routing probe selects both for the same prompt (failure-taxonomy
  class 1). Sharpen both colliding descriptions or merge the skills.
- **Dead cross-references.** Every skill named by another skill still
  exists under that name; every pointed-to reference file exists at that
  path.
- **Unreachable reference files.** There is no cross-session read
  telemetry, so test reachability directly: run the skill's realistic
  prompts fresh and grade the trace - the actual file reads in the run's
  tool calls, not the run's narration - for which reference files were
  opened. For each bundled file never reached, find the branch whose
  condition should trigger it. A file whose pointer never fires has a
  broken pointer (fix the wording, taxonomy class 6); a file whose
  branch no longer exists is deleted.
- **Retire-or-merge candidates.** Skills whose triggers no longer occur,
  whose runtime or tool was retired, or which duplicate a newer skill.
  Retiring is a full change: delete the directory, update the repository
  index (README or equivalent), and re-sync any router skill that names
  it - a router that routes to a dead skill, or omits a live one, lies to
  every future session.
- **Index sync.** The repository's skill list matches the directories
  present, including install paths.

## After the pass

Every deletion and relocation goes through Protocol D in
verification-protocol.md, and rejected deletions go into the rejection
ledger there so next season's pass does not re-litigate them.
