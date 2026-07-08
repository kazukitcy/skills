# Presentation Format

Present the retrospective in this exact structure at the end of the run.
Multiple lessons are fine. Always list duplicates and non-adoptions so the
judgment leaves a trace.

```
## Retrospective

### Lesson 1: <short label>
- First failure: <1 line>
- Final solution: <1 line>
- Insight: <1 line>

### Lesson 2: <short label>
- First failure: <1 line>
- Final solution: <1 line>
- Insight: <1 line>

## Proposals

Adoption candidates:
1. [lint] <rule name>: <1 line> (artifact: <path>, from lesson N)
   - prevents: <the step-2 failure this stops>; confidence: <high|medium|low> — <evidence: recurrence, documented behavior, cold-read verdict, or causal link to the step-2 failure (link alone caps at low)>
2. [enforce] <hook, permission rule, or command gate>: <1 line> (from lesson N)
   - prevents: ...; confidence: ...
3. [script] <script path>: <1 line> (plus instruction-file pointer, from lesson N)
   - prevents: ...; confidence: ...
4. [skill append] <existing skill name>: <1 line> (from lesson N)
   - prevents: ...; confidence: ...
5. [skill new] <skill name>: <1 line> (from lesson N)
   - prevents: ...; confidence: ...
6. [rule] instruction file (global/project): <1 line> (from lesson N)
   - prevents: ...; confidence: ...
7. [memory] <note slug>: <1 line> (first occurrence, from lesson N)
   - prevents: ...; confidence: ...

Duplicate detected (no proposal needed):
- Lesson N: fully covered by <section or line> of <skill/rule/file> -> no addition

Not adopted:
- Lesson N: <one-line reason> (e.g. project-specific / absorbed by another lesson / vetted out: <failure class>)

Please indicate which to adopt by candidate number or item name. Zero
proposals is also a valid conclusion.
```

## Format rules

- With only one lesson, drop the `### Lesson N` headings and write a single
  Retrospective block.
- Omit any of the three Proposals subsections that is empty — never write a
  "none" line.
- End every proposal line with "from lesson N" (enumerate "from lessons 1, 3"
  when a proposal spans lessons).
- Whenever Adoption candidates is empty — regardless of what else remains —
  replace the closing sentence with: "No adoption candidates. Please review
  for the record."
- A promotion proposal (memory note hit during dedup) goes under Adoption
  candidates with its target tier tag and the same sub-line, e.g.
  `[skill new] ...: promoted from memory note <slug>, recurred in this session (from lesson N)`
  `- prevents: ...; confidence: high — recurrence (memory note plus this session)`.
- Every adoption candidate carries its `prevents/confidence` sub-line (the
  step-6 vet output). Name the evidence kind; when the verdict came from a
  cold read, say so.
- Write out only items the user names. Never write silently.

## Variant: all lessons already covered

```
## Retrospective

### Lesson 1: <label>
- First failure: ...
- Final solution: ...
- Insight: ...

## Proposals

Duplicate detected (no proposal needed):
- Lesson 1: fully covered by <section> of <skill name> -> no addition

No adoption candidates. Please review for the record.
```

## Variant: partial overlap

Split the lesson: the overlapping part goes under Duplicate detected, the new
part under Adoption candidates.

```
## Proposals

Adoption candidates:
1. [skill append] <existing skill>: <new portion> (from lesson 1, complements section <name>)
   - prevents: <the step-2 failure the new portion stops>; confidence: <high|medium|low> — <evidence>

Duplicate detected (no proposal needed):
- Lesson 1 (<overlapping portion>): already covered by <file/section> -> no append needed
```
