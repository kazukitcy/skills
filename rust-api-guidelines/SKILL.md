---
name: rust-api-guidelines
description: Applies the Rust API Guidelines to review, design, document, and refactor Rust API surfaces. Use when reviewing the API surface of a Rust crate — library, application, or workspace-internal crate — or of a PR, assessing semver or breaking-change risk, preparing a crate for publishing to crates.io, designing or naming public types, module boundaries, conversions, trait impls, error types, constructors, builders, rustdoc, Cargo metadata, or public macros, or when guideline IDs like C-GETTER, C-GOOD-ERR, or C-BUILDER are cited. Do not use for general Rust debugging, private implementation cleanup, or performance work with no API-surface change.
---

# Rust API Guidelines

## Scope

The Rust API Guidelines are recommendations, not a mandate. They are most useful for public library APIs where caller ergonomics, interoperability, documentation, and semver stability matter. They also apply to application and workspace-internal crates at their crate and module boundaries: any items consumed across a boundary count as API surface, though semver and publishing guidance carries less weight there.

## Workflow

1. Identify the API surface first. Inspect exported modules, `pub` items, public traits, public macros, public re-exports, `Cargo.toml`, crate docs, README, changelog, and release notes as applicable. In application or workspace crates, the surface is the set of items consumed across crate or module boundaries.
2. If no API surface is involved — nothing is consumed across a crate or module boundary — stop using this skill and continue with normal Rust engineering guidance.
3. Read [references/checklist.md](references/checklist.md) and follow its usage rules and per-category `Applies when` notes. Assign each applicable guideline one status: `PASS`, `FAIL`, `N/A`, or `INFER`.
4. Load a deep category chapter only when a checklist item is applicable and you need exact upstream wording, rationale, or examples. Load `references/external-links.md` only when an upstream external source named by the guideline text matters to the answer.
5. Check semver impact before recommending a change. For already-published stable APIs, prefer additive or documentation-only fixes unless the user explicitly requests a breaking redesign.
6. Report only guideline issues that are supported by code, docs, metadata, tests, or clearly labeled inference.

## Decision Rules

- Mark a guideline `PASS` only when the repository evidence directly satisfies it.
- Mark a guideline `FAIL` only when the public API conflicts with the guideline and caller impact is real enough to mention.
- Mark a guideline `N/A` when the API surface does not include the relevant construct, for example no public macros for the Macros category.
- Mark a guideline `INFER` when the likely result depends on behavior not verified by code, rustdoc, tests, metadata, or compile-time checks.
- Do not invent domain defaults, policy choices, or behavioral contracts that are not present in the code or request.
- Treat stable public API breakage as a harder constraint than guideline preference.
- Treat hidden allocation, cloning, locking, blocking, panics, or thread-safety limits as findings only when they are surprising under the documented contract or affect caller control.

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
- `references/checklist.md` is an AI review checklist derived from the upstream checklist text. It is the single source of truth for mapping guideline IDs to category files and for per-category applicability.
- `references/external-links.md` contains upstream external references used by the guideline text.
