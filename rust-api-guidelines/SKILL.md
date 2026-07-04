---
name: rust-api-guidelines
description: Applies the Rust API Guidelines to review, design, document, and refactor Rust API surfaces. Use when reviewing the API surface of a Rust crate — library, application, or workspace-internal crate — or of a PR, assessing semver or breaking-change risk, preparing a crate for publishing to crates.io, designing or naming public types, module boundaries, conversions, trait impls, error types, constructors, builders, rustdoc, Cargo metadata, or public macros, or when guideline IDs like C-GETTER, C-GOOD-ERR, or C-BUILDER are cited. Do not use for general Rust debugging, private implementation cleanup, or performance work with no API-surface change.
---

# Rust API Guidelines

## Purpose

Use this skill to evaluate public Rust APIs against the Rust API Guidelines.

The Rust API Guidelines are recommendations for designing and presenting Rust APIs, not as a mandate. They are most useful for public library APIs where caller ergonomics, interoperability, documentation, and semver stability matter. They also apply to application and workspace-internal crates at their crate and module boundaries: any items consumed across a boundary count as API surface, though semver and publishing guidance carries less weight there.

The upstream material is organized as a checklist of individual guidelines plus topical chapters with detailed explanations. Use the vendored files under `references/` as the working source of truth.

## Activation Rules

Use this skill when the task includes at least one of these:

- Reviewing or designing Rust API surfaces: public crate APIs, public modules, public types, public traits, public functions, public macros, or the crate and module boundaries of application or workspace-internal crates.
- Reviewing a Rust PR for API ergonomics, semver risk, documentation quality, or crate publishability.
- Improving Rust API naming, conversion methods, trait implementations, error types, constructors, builders, rustdoc, Cargo metadata, feature names, or public dependency exposure.
- Citing Rust API Guidelines IDs such as `C-GETTER`, `C-GOOD-ERR`, or `C-BUILDER`.

Do not use this skill when the task is only about:

- Debugging private implementation code.
- Runtime performance tuning with no public API change.
- Formatting, lint cleanup, dependency updates, or internal refactoring with no public API surface.
- Explaining Rust syntax or compiler errors unrelated to API design.

## Workflow

1. Identify the API surface first. Inspect exported modules, `pub` items, public traits, public macros, public re-exports, `Cargo.toml`, crate docs, README, changelog, and release notes as applicable. In application or workspace crates, the surface is the set of items consumed across crate or module boundaries.
2. If no API surface is involved — nothing is consumed across a crate or module boundary — stop using this skill and continue with normal Rust engineering guidance.
3. Read [references/checklist.md](references/checklist.md). Assign each relevant guideline one status: `PASS`, `FAIL`, `N/A`, or `INFER`.
4. Load deeper category chapters only for categories that are relevant to the inspected API surface.
5. Check semver impact before recommending a change. For already-published stable APIs, prefer additive or documentation-only fixes unless the user explicitly requests a breaking redesign.
6. Report only guideline issues that are supported by code, docs, metadata, tests, or clearly labeled inference.

## Reference Loading Rules

- Always start with `references/checklist.md` for review work.
- Do not load every reference file.
- Load a category file only when the checklist item is applicable and you need exact wording, rationale, or examples.
- Load `references/external-links.md` only when an upstream external source named by the guideline text matters to the answer.
- Do not read `LICENSE-APACHE` or `LICENSE-MIT` unless the user asks for exact licensing text.

## Decision Rules

- Mark a guideline `PASS` only when the repository evidence directly satisfies it.
- Mark a guideline `FAIL` only when the public API conflicts with the guideline and caller impact is real enough to mention.
- Mark a guideline `N/A` when the API surface does not include the relevant construct, for example no public macros for the Macros category.
- Mark a guideline `INFER` when the likely result depends on behavior not verified by code, rustdoc, tests, metadata, or compile-time checks.
- Do not invent domain defaults, policy choices, or behavioral contracts that are not present in the code or request.
- Treat stable public API breakage as a harder constraint than guideline preference.
- Treat hidden allocation, cloning, locking, blocking, panics, or thread-safety limits as findings only when they are surprising under the documented contract or affect caller control.

## Inspection Targets

- Public item names, constructor names, conversion names, getter names, iterator methods, and feature names.
- Trait impl coverage: common standard traits, conversion traits, `Send` / `Sync`, Serde support, and collection traits.
- Public error types and their `Display`, `Error`, `Send`, and `Sync` behavior.
- Ownership choices in functions and builders.
- Use of `Deref`, object safety, and hidden implementation details.
- Rustdoc examples, `Errors` / `Panics` / `Safety` sections, links, metadata, and release notes.
- README, changelog, GitHub releases, and crate-level docs when checking documentation and release-process guidance.
- Public fields, public dependencies, stability, and licensing.

## Applicability Rules

- Apply Naming, Interoperability, Predictability, Flexibility, Type Safety, Dependability, Debuggability, and Future Proofing to every public crate unless the category is clearly irrelevant.
- Apply Macros only when the crate exposes public macros.
- Apply Serde guidance only when public data structures are plausibly serialized or deserialized by users.
- Apply object-safety guidance only when a trait could realistically be used as `dyn Trait`.
- Apply Necessities, Cargo metadata, release notes, and licensing checks only for publishable crates, release reviews, or repository-readiness tasks.
- For APIs that cross threads, tasks, callbacks, FFI, or async runtimes, explicitly check `Send` / `Sync`, unwind and panic behavior, reentrancy, cancellation or drop semantics, and whether those contracts are documented or compile-time tested.

## Output Contract

- Lead with concrete findings, ordered by severity.
- Cite the guideline ID in every substantive finding, for example `C-GOOD-ERR`.
- Explain why the current API is problematic for callers, not just that it differs from the guideline.
- State whether each finding is a breaking API risk, correctness or ergonomics issue, documentation gap, or optional improvement.
- Include the smallest viable fix for each finding.
- If a fix would be breaking, say so explicitly and give a non-breaking alternative when one exists.
- If no guideline issue exists, say that the checked guideline is satisfied or not applicable.

## Upstream Sources

- The Rust API Guidelines book text from <https://github.com/rust-lang/api-guidelines> is integrated directly in `references/` at commit `97a0969cb07fe4cabb0eed8a56234053f47d83dc`.
- Upstream repository maintenance files such as deployment workflow, `.gitignore`, mdBook build config, README, and contribution guide are intentionally not included.
- `LICENSE-APACHE` and `LICENSE-MIT` preserve the upstream licensing at the skill root so agents do not need to load license text from `references/`.
- `references/checklist.md` is an AI review checklist derived from the upstream checklist text.
- `references/external-links.md` contains upstream external references used by the guideline text.

## Category Map

- Naming and Interoperability:
  `references/naming.md` and `references/interoperability.md`.
  Covers `C-CASE`, `C-CONV`, `C-GETTER`, `C-ITER`, `C-ITER-TY`, `C-FEATURE`, `C-WORD-ORDER`, `C-COMMON-TRAITS`, `C-CONV-TRAITS`, `C-COLLECT`, `C-SERDE`, `C-SEND-SYNC`, `C-GOOD-ERR`, `C-NUM-FMT`, `C-RW-VALUE`.
- Macros and Documentation:
  `references/macros.md` and `references/documentation.md`.
  Covers `C-EVOCATIVE`, `C-MACRO-ATTR`, `C-ANYWHERE`, `C-MACRO-VIS`, `C-MACRO-TY`, `C-CRATE-DOC`, `C-EXAMPLE`, `C-QUESTION-MARK`, `C-FAILURE`, `C-LINK`, `C-METADATA`, `C-RELNOTES`, `C-HIDDEN`.
- Predictability, Flexibility, and Type Safety:
  `references/predictability.md`, `references/flexibility.md`, and `references/type-safety.md`.
  Covers `C-SMART-PTR`, `C-CONV-SPECIFIC`, `C-METHOD`, `C-NO-OUT`, `C-OVERLOAD`, `C-DEREF`, `C-CTOR`, `C-INTERMEDIATE`, `C-CALLER-CONTROL`, `C-GENERIC`, `C-OBJECT`, `C-NEWTYPE`, `C-CUSTOM-TYPE`, `C-BITFLAG`, `C-BUILDER`.
- Dependability, Debuggability, Future Proofing, and Necessities:
  `references/dependability.md`, `references/debuggability.md`, `references/future-proofing.md`, and `references/necessities.md`.
  Covers `C-VALIDATE`, `C-DTOR-FAIL`, `C-DTOR-BLOCK`, `C-DEBUG`, `C-DEBUG-NONEMPTY`, `C-SEALED`, `C-STRUCT-PRIVATE`, `C-NEWTYPE-HIDE`, `C-STRUCT-BOUNDS`, `C-STABLE`, `C-PERMISSIVE`.
