# Failure Taxonomy

Classify an observed skill failure into exactly one primary class, then
apply that class's fix form. The form matters as much as the content: a
form that cures one class measurably worsens another. When a failure seems
to span classes, fix the earliest class in this table first (invocation
before compliance, compliance before shape) and re-run before touching the
next.

## Class 1: Never fires, or fires at the wrong time

**Symptoms:** realistic prompts do not invoke the skill; the skill fires on
requests it should ignore; two skills contend for the same prompts.

**Diagnosis questions:**

- Does the description name the triggers users actually say - symptoms,
  error messages, tool names - or only the author's abstractions?
- Is each trigger a distinct branch of use, or a synonym restating one
  branch (duplication that adds load without adding reach)?
- Does another skill's description overlap this one's? Colliding
  descriptions split invocations between the skills so both fire
  unreliably.
- Does the description summarize the skill's workflow? A workflow summary
  invites a worse failure than non-invocation: the agent follows the
  summary and skips the body.

**Fix form:** rewrite the description around distinct trigger branches
using the vocabulary of real requests; front-load the strongest trigger
word; collapse synonyms; strip workflow. For collisions, sharpen both
descriptions until realistic prompts route unambiguously, or merge the
skills. Fix the description, never the test prompts.

**Wrong form:** adding more synonym triggers (louder, not clearer);
summarizing the process; renaming the skill without touching triggers.

## Class 2: Fires, but the agent violates its rules

**Symptoms:** the agent knows the rule and skips it under pressure - time,
sunk cost, authority, exhaustion - usually with an articulate
rationalization ("too simple to need it", "the spirit is satisfied").

**Diagnosis questions:**

- What rationalization did the agent use, verbatim? The fix must counter
  those exact words.
- Is the violation a loophole ("kept the code as reference" after being
  told to delete it) or a spirit-versus-letter argument?

**Fix form:** discipline bulletproofing - explicit prohibition plus, for
each observed rationalization: a counter in a rationalization table
(excuse | reality), a red-flag entry the agent can self-check, and named
loophole closures ("delete means delete - don't keep it as reference,
don't adapt it"). A foundational line such as "violating the letter is
violating the spirit" cuts off that argument class. This is the one class
where prohibition is the right tool.

**Wrong form:** soft guidance ("prefer", "consider") - it reads as
negotiable and loses under the same pressure that caused the violation.

## Class 3: Complies, but the output has the wrong shape

**Symptoms:** the agent follows the skill and produces the artifact, but
bloated, buried, mis-ordered, or padded - a dispatch prompt that restates
the spec, a report whose verdict is on page three.

**Fix form:** a positive recipe or contract - state what the output IS:
its parts, in order, and what each contains. A recipe leaves nothing to
negotiate; the output matches the stated shape or it does not.

**Wrong form:** prohibitions ("don't restate", "never narrate"). Under a
competing incentive, prohibition arms produce more of the unwanted content
than a no-guidance control: the negation names the behavior, activates it,
and invites negotiation. Two corollaries observed in wording tests:

- **No nuance clauses.** Appending "unless it matters" to a winning recipe
  degrades it from consistent to noisy. A real exception becomes its own
  conditional on an observable predicate ("if the brief exists, reference
  it by path").
- **Exemption clauses do not scope.** "This limit does not apply to code
  blocks" still suppresses code blocks. If part of the output must be
  exempt, restructure so the rule cannot reach it.

## Class 4: Omits a required element

**Symptoms:** the agent produces the right artifact but drops one part -
the frontmatter field, the verification command, the status line.

**Fix form:** structural - a REQUIRED slot in the template the agent
fills in, so the omission becomes visibly incomplete rather than silently
absent.

**Wrong form:** a prose reminder near the template ("remember to include
X") - it competes for attention with the template instead of being part of
it.

## Class 5: Stops early or digs too little

**Symptoms:** a step is declared done before its real work is - three
findings reported when ten exist, one file read where the criterion needed
all of them (premature completion); or the whole run is shallow
(thin legwork).

**Diagnosis questions:**

- Can the agent tell done from not-done? Vague verbs ("review",
  "consider", "understand") have no observable done state.
- Does the criterion demand the work that matters ("every modified module
  accounted for") or accept a summary ("produce a change list")?
- Are later steps visible and pulling attention toward being finished?

**Fix form, in order:**

1. Sharpen the completion criterion - cheap and local. Make it checkable
   (done vs not-done is observable) and demanding ("every X", "all N
   kinds recorded as hit, no hit, or absent").
2. Raise the legwork with a stronger leading word. Grade it with the
   no-op test: "be thorough" changes nothing on an already-thorough-ish
   model; "relentless" or "exhaustive - every occurrence, not a sample"
   does. A weak word is replaced by a stronger one, not deleted.
3. Only if the criterion is irreducibly fuzzy AND the rush is actually
   observed: split the sequence so later steps sit behind a real context
   boundary - a user-invoked hand-off or a subagent dispatch. An inline
   call clears nothing; the later steps remain in context and keep
   pulling.

**Wrong form:** splitting first (structural surgery for a wording bug), or
adding "do not stop early" (a negation that names the failure).

## Class 6: Misses material behind a pointer

**Symptoms:** the agent skips a referenced file it needed, or reads
references it did not need on every run.

**Fix form:** fix the pointer's wording first - it must encode the
condition for reading ("read X before writing the first plan", "when the
destination is a lint rule, read Y"), not just name a file. Inline the
material only if sharpening the pointer fails on re-test. For the inverse
(always-read references), inline what every branch needs and keep only
branch-specific material disclosed.

**Wrong form:** inlining everything back at the first miss (destroys the
hierarchy that keeps steps attended to), or bolding the link without
adding the condition.

## Cross-class note: fix one class at a time

A skill that misroutes AND has weak criteria tempts a rewrite. Resist:
change one class, re-run, then reclassify. A rewrite mixes fixes whose
forms conflict and makes the verifying re-run uninterpretable.
