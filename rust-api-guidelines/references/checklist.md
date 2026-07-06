# Rust API Guidelines AI Review Checklist

This checklist covers two guideline sets: the rust-lang Rust API Guidelines (`C-*`, first section) and the Microsoft Rust Guidelines (`M-*`, sections suffixed `(Microsoft)`). Where both sets cover the same concern — `Debug`, `Display`, builders, error types, newtypes, collections, docs, `Send` — cite both IDs only when the distinction matters.

## How to use this checklist

1. For `C-*` categories, review only public Rust API surface: exported modules, `pub` items, public traits, public macros, crate docs, Cargo metadata, and release-facing docs. `M-*` categories may reach beyond `pub` items — into CI, workspace layout, logging, panics, and unsafe code — as their `Applies when` notes state.
2. Apply every category to every public crate unless its `Applies when` note excludes it; mark excluded categories or items `N/A`.
3. For each applicable item, record one status: `PASS`, `FAIL`, `N/A`, or `INFER`.
4. Use `INFER` only when the likely conclusion is not directly verified by code, rustdoc, tests, metadata, or compile-time checks.
5. For every `FAIL` or material `INFER`, cite the guideline ID, the code evidence, caller impact, semver risk, and the smallest viable fix.
6. Read the listed Deep reference only when exact upstream wording, rationale, or examples are needed.

## Naming

Deep reference: `references/naming.md`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-CASE](naming.md#c-case) | Check that public item names follow Rust casing conventions. | `pub` items, module names, trait names, associated items. |
| [C-CONV](naming.md#c-conv) | Check ad-hoc conversions use `as_`, `to_`, and `into_` consistently. | Conversion methods and receiver ownership. |
| [C-GETTER](naming.md#c-getter) | Check getters avoid `get_` unless lookup or fallible semantics require it. | Inherent methods returning fields or cheap views. |
| [C-ITER](naming.md#c-iter) | Check collection iterator methods are named `iter`, `iter_mut`, and `into_iter`. | Collection-like public types. |
| [C-ITER-TY](naming.md#c-iter-ty) | Check iterator type names match their producer methods. | Public iterator structs and type aliases. |
| [C-FEATURE](naming.md#c-feature) | Check feature names avoid placeholder words. | `Cargo.toml` feature names and documented flags. |
| [C-WORD-ORDER](naming.md#c-word-order) | Check related names use consistent word order. | Families of functions, variants, types, and features. |

## Interoperability

Deep reference: `references/interoperability.md`.

Applies when: every public crate. `C-SERDE` applies only when public data structures are plausibly serialized or deserialized by users. For APIs that cross threads, tasks, callbacks, FFI, or async runtimes, explicitly check `Send` / `Sync`, unwind and panic behavior, reentrancy, cancellation or drop semantics, and whether those contracts are documented or compile-time tested.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-COMMON-TRAITS](interoperability.md#c-common-traits) | Check public types implement obvious common traits. | `Copy`, `Clone`, `Eq`, `PartialEq`, `Ord`, `PartialOrd`, `Hash`, `Debug`, `Display`, `Default`. |
| [C-CONV-TRAITS](interoperability.md#c-conv-traits) | Check conversions use standard traits when appropriate. | `From`, `TryFrom`, `AsRef`, `AsMut`, inherent conversion methods. |
| [C-COLLECT](interoperability.md#c-collect) | Check collection types implement `FromIterator` and `Extend`. | Collection-like public types. |
| [C-SERDE](interoperability.md#c-serde) | Check data structures support Serde when serialization is plausible. | Public data structs, feature flags, derive gates. |
| [C-SEND-SYNC](interoperability.md#c-send-sync) | Check public types are `Send` and `Sync` where possible. | Type fields, unsafe impls, compile-time assertions, async/thread APIs. |
| [C-GOOD-ERR](interoperability.md#c-good-err) | Check error types are meaningful, displayable, and composable. | Public error enums/structs, `Display`, `Error`, source chaining, `Send`/`Sync`. |
| [C-NUM-FMT](interoperability.md#c-num-fmt) | Check binary number types provide alternate formatting. | Numeric wrapper types and formatting impls. |
| [C-RW-VALUE](interoperability.md#c-rw-value) | Check generic reader/writer functions take `R: Read` and `W: Write` by value. | I/O helper signatures. |

## Macros

Deep reference: `references/macros.md`.

Applies when: the crate exposes public macros; otherwise mark the category `N/A`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-EVOCATIVE](macros.md#c-evocative) | Check macro input syntax resembles the generated output. | Public macro examples and pattern syntax. |
| [C-MACRO-ATTR](macros.md#c-macro-attr) | Check macros compose with attributes. | Macro examples using `#[...]`, generated item placement. |
| [C-ANYWHERE](macros.md#c-anywhere) | Check item macros work anywhere items are allowed. | Module, impl, and nested item use cases. |
| [C-MACRO-VIS](macros.md#c-macro-vis) | Check item macros support visibility specifiers. | `pub`, `pub(crate)`, and private generated items. |
| [C-MACRO-TY](macros.md#c-macro-ty) | Check type fragments are flexible enough for common Rust types. | Macro matchers and examples with paths, generics, and associated types. |

## Documentation

Deep reference: `references/documentation.md`.

Applies when: every public crate. `C-METADATA` and `C-RELNOTES` apply only to publishable crates, release reviews, or repository-readiness tasks.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-CRATE-DOC](documentation.md#c-crate-doc) | Check crate-level docs explain purpose and show realistic usage. | `lib.rs`, crate docs, README when used as crate docs. |
| [C-EXAMPLE](documentation.md#c-example) | Check public items have useful rustdoc examples when examples are practical. | Rustdoc for public types, functions, traits, and macros. |
| [C-QUESTION-MARK](documentation.md#c-question-mark) | Check examples prefer `?` over `unwrap` or obsolete `try!`. | Rustdoc examples and README snippets. |
| [C-FAILURE](documentation.md#c-failure) | Check docs describe errors, panics, and safety contracts. | `# Errors`, `# Panics`, `# Safety`, unsafe APIs. |
| [C-LINK](documentation.md#c-link) | Check prose links to relevant types, traits, modules, and external concepts. | Intra-doc links and external links. |
| [C-METADATA](documentation.md#c-metadata) | Check Cargo metadata is complete for publishing. | `authors`, `description`, `license`, `homepage`, `documentation`, `repository`, `keywords`, `categories`. |
| [C-RELNOTES](documentation.md#c-relnotes) | Check significant changes are documented for users. | Changelog, release notes, GitHub releases, migration notes. |
| [C-HIDDEN](documentation.md#c-hidden) | Check rustdoc hides unhelpful implementation details. | Public re-exports, sealed internals, generated docs. |

## Predictability

Deep reference: `references/predictability.md`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-SMART-PTR](predictability.md#c-smart-ptr) | Check smart pointers avoid surprising inherent methods. | Pointer-like public types and method sets. |
| [C-CONV-SPECIFIC](predictability.md#c-conv-specific) | Check conversions live on the most specific involved type. | Conversion API placement. |
| [C-METHOD](predictability.md#c-method) | Check functions with a clear receiver are methods. | Free functions and inherent impls. |
| [C-NO-OUT](predictability.md#c-no-out) | Check functions return values instead of using out-parameters. | Mutable output arguments. |
| [C-OVERLOAD](predictability.md#c-overload) | Check operator overloads match caller expectations. | `Add`, `Sub`, `Deref`, indexing, comparison impls. |
| [C-DEREF](predictability.md#c-deref) | Check only smart pointers implement `Deref` and `DerefMut`. | `Deref` impls on non-pointer types. |
| [C-CTOR](predictability.md#c-ctor) | Check constructors are static inherent methods. | `new`, `with_*`, builder entry points, free constructors. |

## Flexibility

Deep reference: `references/flexibility.md`.

Applies when: every public crate. `C-OBJECT` applies only when a trait could realistically be used as `dyn Trait`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-INTERMEDIATE](flexibility.md#c-intermediate) | Check APIs expose useful intermediate results to avoid duplicate work. | Multi-step parsing, validation, allocation, or discovery APIs. |
| [C-CALLER-CONTROL](flexibility.md#c-caller-control) | Check callers control copying, allocation, and data placement. | Borrowing vs ownership, allocation-heavy helpers, output ownership. |
| [C-GENERIC](flexibility.md#c-generic) | Check parameters use appropriate generics instead of over-specific concrete types. | `AsRef`, `IntoIterator`, `Read`, `Write`, path/string APIs. |
| [C-OBJECT](flexibility.md#c-object) | Check traits are object-safe when trait objects are plausible. | Public traits intended for callbacks, plugins, or dynamic dispatch. |

## Type safety

Deep reference: `references/type-safety.md`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-NEWTYPE](type-safety.md#c-newtype) | Check newtypes encode meaningful static distinctions. | Public primitive wrappers and domain identifiers. |
| [C-CUSTOM-TYPE](type-safety.md#c-custom-type) | Check arguments convey meaning through types instead of bare `bool` or ambiguous `Option`. | Function parameters and config structs. |
| [C-BITFLAG](type-safety.md#c-bitflag) | Check flag sets use bitflags-style types instead of enums. | Permission, mode, and option flag APIs. |
| [C-BUILDER](type-safety.md#c-builder) | Check complex construction uses builders where they improve clarity. | Constructors with many optional or ordered parameters. |

## Dependability

Deep reference: `references/dependability.md`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-VALIDATE](dependability.md#c-validate) | Check functions validate arguments and document validation behavior. | Constructors, parsers, setters, unsafe preconditions. |
| [C-DTOR-FAIL](dependability.md#c-dtor-fail) | Check destructors do not report recoverable failure only through `Drop`. | `Drop` impls, close/flush APIs. |
| [C-DTOR-BLOCK](dependability.md#c-dtor-block) | Check blocking destructors have explicit alternatives. | Resource cleanup, I/O, locks, threads, async runtimes. |

## Debuggability

Deep reference: `references/debuggability.md`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-DEBUG](debuggability.md#c-debug) | Check all public types implement `Debug` unless there is a clear reason not to. | Public structs, enums, error types, generic bounds. |
| [C-DEBUG-NONEMPTY](debuggability.md#c-debug-nonempty) | Check `Debug` output is informative and non-empty. | Manual `Debug` impls and redaction behavior. |

## Future proofing

Deep reference: `references/future-proofing.md`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-SEALED](future-proofing.md#c-sealed) | Check traits are sealed when downstream impls would block future evolution. | Public traits, blanket impls, extension traits. |
| [C-STRUCT-PRIVATE](future-proofing.md#c-struct-private) | Check structs keep fields private unless field-level construction is the API. | Public structs and documented construction patterns. |
| [C-NEWTYPE-HIDE](future-proofing.md#c-newtype-hide) | Check newtypes hide implementation details. | Tuple struct fields, repr choices, accessors. |
| [C-STRUCT-BOUNDS](future-proofing.md#c-struct-bounds) | Check data structures avoid unnecessary trait bounds on type definitions. | Generic structs and derives. |

## Necessities

Deep reference: `references/necessities.md`.

Applies when: publishable crates, release reviews, or repository-readiness tasks; otherwise mark the category `N/A`.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [C-STABLE](necessities.md#c-stable) | Check public dependencies of stable crates are stable enough for the API contract. | Public dependency types, re-exports, semver status. |
| [C-PERMISSIVE](necessities.md#c-permissive) | Check the crate and public dependencies have permissive licenses when publishability matters. | `Cargo.toml`, license files, dependency licenses. |

## Universal (Microsoft)

Deep reference: `references/ms-universal.md`.

Applies when: every Rust crate or workspace review. Mark individual items `N/A` only when the relevant surface is absent, such as no public types, no lint overrides, no logging, or no magic values.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-UPSTREAM-GUIDELINES](ms-universal.md#m-upstream-guidelines) | Check the code also follows the frequently missed upstream Rust API, style, design-pattern, and undefined-behavior guidance. | Public API names, conversion methods, getters, common trait impls, constructors, feature names. |
| [M-STATIC-VERIFICATION](ms-universal.md#m-static-verification) | Check the project runs static verification with compiler lints, Clippy, rustfmt, cargo-audit, cargo-hack, cargo-udeps, and Miri where unsafe code exists. | Workspace lints, CI jobs, justfile tasks, rustfmt config, audit and feature-check commands, Miri jobs. |
| [M-LINT-OVERRIDE-EXPECT](ms-universal.md#m-lint-override-expect) | Check local lint overrides use `#[expect]` with reasons instead of stale-prone `#[allow]`, except for generated code or macro cases. | Rust attributes, lint configuration, generated files, macro expansions. |
| [M-PUBLIC-DEBUG](ms-universal.md#m-public-debug) | Check every public type implements `Debug`, with custom redacting implementations and tests for sensitive data. | Public structs and enums, `Debug` derives and impls, redaction tests, secret-bearing types. |
| [M-PUBLIC-DISPLAY](ms-universal.md#m-public-display) | Check public types meant for developers or end users to read implement idiomatic `Display` without leaking sensitive data. | Error types, string-like wrappers, `Display` impls, formatting tests, sensitive fields. |
| [M-SMALLER-CRATES](ms-universal.md#m-smaller-crates) | Check independently usable submodules are split into crates and rejoined through umbrella crates only when that improves usability. | Workspace layout, crate boundaries, feature flags, re-exports, compile-time pressure. |
| [M-WEASEL-WORDS](ms-universal.md#m-weasel-words) | Check type and trait names avoid vague words such as `Service`, `Manager`, and `Factory` unless they add domain meaning. | Public type names, trait names, builder names, dependency-injection abstractions. |
| [M-SHORT-NAMES](ms-universal.md#m-short-names) | Check item names stay short, avoid redundant module or crate prefixes, and use abbreviations where idiomatic. | Public item names, module paths, type aliases, API examples. |
| [M-REGULAR-FN](ms-universal.md#m-regular-fn) | Check general-purpose computation is exposed as regular functions rather than associated functions unless it clearly constructs or belongs to a receiver. | `impl` blocks, free functions, associated functions, call sites, trait associated functions. |
| [M-DOCUMENTED-MAGIC](ms-universal.md#m-documented-magic) | Check hardcoded magic values are named or commented with why they were chosen, side effects of changing them, and external interactions. | Numeric literals, string constants, protocol values, timeouts, comments, named constants. |
| [M-LOG-STRUCTURED](ms-universal.md#m-log-structured) | Check logging uses structured events with message templates, named properties, event names, semantic attributes, and redaction for sensitive data. | `tracing` or logging calls, telemetry schema, message templates, OTel fields, redaction helpers. |

## Libraries: Interoperability (Microsoft)

Deep reference: `references/ms-libs-interop.md`.

Applies when: reviewing a public library crate or shared crate consumed across crate boundaries. Mark `N/A` for application-only crates with no reusable public API, or for rows whose specific surface is absent.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-TYPES-SEND](ms-libs-interop.md#m-types-send) | Check public futures are `Send` and public types are `Send` unless their default use is instantaneous and not held across `.await`. | Public types, async entry points, compile-time `Send` assertions, fields using `Rc` or `RefCell`, Tokio-facing APIs. |
| [M-ESCAPE-HATCHES](ms-libs-interop.md#m-escape-hatches) | Check types wrapping native handles provide documented `unsafe` conversion escape hatches for interop and FFI use cases. | Native-handle wrapper types, raw handle constructors, raw handle accessors, safety docs. |
| [M-DONT-LEAK-TYPES](ms-libs-interop.md#m-dont-leak-types) | Check public APIs prefer `std` or `core` types and leak third-party types only for sibling crates, feature-gated integrations, or substantial interoperability benefits. | Public signatures, re-exports, dependency types, feature gates, umbrella-crate boundaries. |
| [M-FOREIGN-REEXPORTS](ms-libs-interop.md#m-foreign-reexports) | Check third-party items are imported from their original crates rather than re-exported, except for umbrella crates, technical split crates, or macro-private stable paths. | `pub use` items, dependency APIs, umbrella exports, hidden macro modules. |
| [M-IMPL-ASREF](ms-libs-interop.md#m-impl-asref) | Check function parameters accept `impl AsRef<T>` for clear reference hierarchies when ownership is unnecessary or cheap to create. | Function signatures, path and string parameters, byte-slice parameters, public type definitions. |
| [M-IMPL-RANGEBOUNDS](ms-libs-interop.md#m-impl-rangebounds) | Check numeric range APIs use Rust range types and accept `impl RangeBounds<T>` when arbitrary bounds are supported. | Range-taking functions, start and end parameter pairs, slicing APIs, generic bounds. |
| [M-IMPL-IO](ms-libs-interop.md#m-impl-io) | Check one-shot initialization I/O is sans-IO and accepts appropriate `Read`, `Write`, or async I/O traits instead of performing concrete I/O internally. | I/O constructors, parser and loader functions, `std::io` bounds, `futures::io` bounds, runtime-specific types. |

## Libraries: UX (Microsoft)

Deep reference: `references/ms-libs-ux.md`.

Applies when: reviewing public library APIs, especially primary types, constructors, module layout, errors, and async APIs. Mark `N/A` for private implementation-only crates or rows whose API pattern is absent.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-SIMPLE-ABSTRACTIONS](ms-libs-ux.md#m-simple-abstractions) | Check primary public service-like types avoid visible nested or complex generic parameters, especially when the nested types come from the same crate. | Public type signatures, service handles, generic bounds, user-facing examples, compiler error surfaces. |
| [M-AVOID-WRAPPERS](ms-libs-ux.md#m-avoid-wrappers) | Check public APIs hide generic wrappers and smart pointers unless the wrapper is fundamental or benchmark-justified. | Public signatures, `Arc`, `Rc`, `Box`, `RefCell`, wrapper types, benchmark notes. |
| [M-DI-HIERARCHY](ms-libs-ux.md#m-di-hierarchy) | Check async dependency APIs prefer concrete types first, generics second, and `dyn Trait` only after nesting or design constraints justify it. | Dependency injection APIs, traits, generic parameters, trait objects, wrapper handles, mock implementations. |
| [M-ERRORS-CANONICAL-STRUCTS](ms-libs-ux.md#m-errors-canonical-structs) | Check library errors are situation-specific structs with backtraces, sources or causes, helper methods, `Display`, and `Error` impls. | Public error types, `Backtrace` capture, `source` chaining, `is_*` helpers, `Display` output. |
| [M-FROM-ERROR](ms-libs-ux.md#m-from-error) | Check owned error types centralize canonical upstream conversions with `From` instead of scattered `.map_err()` calls. | Error conversion impls, `?` call sites, `.map_err()` usage, contextual error paths. |
| [M-INIT-BUILDER](ms-libs-ux.md#m-init-builder) | Check types with four or more arbitrary initialization permutations provide `Foo::builder()` and a chainable `FooBuilder` ending in `.build()`. | Constructors, optional parameters, builder entry points, required deps structs, runtime-specific builder methods. |
| [M-INIT-CASCADED](ms-libs-ux.md#m-init-cascaded) | Check types requiring four or more parameters group initialization semantically through helper types instead of long ordered parameter lists. | Constructors, parameter structs, newtypes, call sites, builder dependencies. |
| [M-SERVICES-CLONE](ms-libs-ux.md#m-services-clone) | Check heavyweight service types and thread singletons implement cheap shared-ownership `Clone` semantics rather than fat copies. | Service structs, `Clone` impls, `Arc<Inner>` patterns, application initialization types, dependency handles. |
| [M-ESSENTIAL-FN-INHERENT](ms-libs-ux.md#m-essential-fn-inherent) | Check essential type functionality is implemented as inherent methods and trait impls forward to those methods. | Inherent impls, trait impls, core methods, public examples. |
| [M-BALANCED-MODULES](ms-libs-ux.md#m-balanced-modules) | Check module roots expose the most important items and subordinate modules group remaining functionality by use case. | `lib.rs`, module tree, public re-exports, root API, module docs. |
| [M-NO-PRELUDE](ms-libs-ux.md#m-no-prelude) | Check the crate does not define a prelude or namespace meant to be glob-imported. | `prelude` modules, `pub use *` APIs, README examples, import guidance. |
| [M-PARAMETER-CONSISTENCY](ms-libs-ux.md#m-parameter-consistency) | Check recurring conceptual parameters appear in a consistent order, with call-specific parameters first, ubiquitous parameters last, and closures last. | Function families, trait methods, ecosystem sibling crates, logger parameters, closure parameters. |
| [M-COLLECTION-TRAITS](ms-libs-ux.md#m-collection-traits) | Check custom collection types implement iterator-facing traits, iterator structs, `iter` methods, `FromIterator`, `Extend`, and truthful `size_hint`. | Collection types, iterator structs, `IntoIterator` impls, `FromIterator`, `Extend`, iterator tests. |
| [M-ASYNC-FN](ms-libs-ux.md#m-async-fn) | Check functions use `async fn` instead of returning `impl Future` unless traits or hot heavy async paths require explicit futures. | Async function signatures, trait APIs, future-returning functions, hot-path measurements. |

## Libraries: Resilience (Microsoft)

Deep reference: `references/ms-libs-resilience.md`.

Applies when: reviewing library crates and shared crates that may be reused, tested, or depended on by other crates. Mark rows `N/A` when the crate has no I/O, no test-only helpers, no re-exports, no global state, or no production diagnostics.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-MOCKABLE-SYSCALLS](ms-libs-resilience.md#m-mockable-syscalls) | Check user-facing types performing I/O, syscalls, time, entropy, or other fragile external operations can be mocked through a controlled core. | File and network access, clocks, random sources, constructors, test mocks, runtime abstraction enums. |
| [M-TEST-UTIL](ms-libs-resilience.md#m-test-util) | Check testing functionality is gated behind clearly named test-only features, preferably `test-util`. | Cargo features, mock APIs, fake data generators, safety overrides, sensitive-data inspection hooks. |
| [M-INTEGRATION-TESTS](ms-libs-resilience.md#m-integration-tests) | Check tests that touch only public APIs live under `tests/` instead of inside source `mod tests`. | Integration tests, source test modules, public API coverage, coverage-target code. |
| [M-STRONG-TYPES](ms-libs-resilience.md#m-strong-types) | Check APIs use the strongest appropriate standard type early, such as path types for OS paths, while preserving common Rust numeric conventions. | Public parameters, config structs, string and path usage, numeric boundary types. |
| [M-STRONG-TYPES-GUARD](ms-libs-resilience.md#m-strong-types-guard) | Check invariant-carrying newtypes enforce invariants through fallible construction and avoid infallible `From` from weaker types. | Newtypes, constructors, `TryFrom`, `FromStr`, panicking constructors, validation tests. |
| [M-BUILD-RESULT](ms-libs-resilience.md#m-build-result) | Check fallible builders accept setter input freely and perform interdependent validation only in a `Result`-returning `.build()`. | Builder setters, build methods, validation errors, strong setting types. |
| [M-NO-GLOB-REEXPORTS](ms-libs-resilience.md#m-no-glob-reexports) | Check public re-exports list items individually instead of using `pub use foo::*`, except for narrowly technical platform re-export cases. | Re-export modules, wildcard exports, platform HAL modules, public API diff. |
| [M-AVOID-STATICS](ms-libs-resilience.md#m-avoid-statics) | Check libraries avoid `static` and thread-local state when correctness depends on one consistent value across crate versions. | `static` items, thread locals, global registries, version-sensitive state, test isolation. |
| [M-LOG-NOT-PRINT](ms-libs-resilience.md#m-log-not-print) | Check production code emits diagnostics through telemetry rather than `println!` or `dbg!`, except intentional CLI stdout UI. | `println!`, `eprintln!`, `dbg!`, logging calls, CLI output paths. |

## Libraries: Building (Microsoft)

Deep reference: `references/ms-libs-building.md`.

Applies when: reviewing library crates, especially publishable crates and crates with native dependencies or feature flags. Mark `N/A` for application-only crates unless they expose reusable libraries.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-OOBE](ms-libs-building.md#m-oobe) | Check libraries build out of the box on supported platforms without prerequisites beyond Rust and Cargo unless they are explicitly platform-specific. | `build.rs`, platform cfgs, generated artifacts, external tools, environment variables, dependency build requirements. |
| [M-SYS-CRATES](ms-libs-building.md#m-sys-crates) | Check native `-sys` crates govern native builds internally, avoid required external build tools, verify embedded or downloaded sources, and support static and dynamic linking. | `foo-sys` crates, `build.rs`, `cc` usage, vendored sources, hashes, bindgen outputs, libloading paths. |
| [M-FEATURES-ADDITIVE](ms-libs-building.md#m-features-additive) | Check all library features are additive, compile in every valid combination, and never disable or mutate public items when enabled. | Cargo features, `cfg` gates, cargo-hack results, `std` feature shape, public API under feature combinations. |

## Macros (Microsoft)

Deep reference: `references/ms-macros.md`.

Applies when: the crate defines or exposes public declarative or procedural macros, or ships helper crates for macros. Mark the category `N/A` when no public macro surface exists.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-MACRO-LAST-RESORT](ms-macros.md#m-macro-last-resort) | Check macros are used only when regular Rust language constructs cannot provide a viable solution. | Macro APIs, alternative function or trait designs, generated structure, compile-time cost. |
| [M-EXAMPLE-OVER-PROC](ms-macros.md#m-example-over-proc) | Check macros by example are preferred over procedural macros whenever they can express the required expansion. | `macro_rules!` candidates, proc-macro crates, expansion requirements, inspection needs. |
| [M-MACROS-DONT-LIE](ms-macros.md#m-macros-dont-lie) | Check macros do not materially change the visible shape, signature, asyncness, or kind of user-written items. | Macro inputs, expanded output, item signatures, async transformations, generated data types. |
| [M-MACRO-MAIN-CRATE](ms-macros.md#m-macro-main-crate) | Check procedural macros assume use through the main crate and emit paths for that supported import path only. | Proc-macro emitted paths, main-crate re-exports, renamed-crate support, facade crates. |
| [M-MACRO-HELPERS](ms-macros.md#m-macro-helpers) | Check macro expansions reference third-party items through fully qualified hidden `_private` re-exports from the host crate. | Generated paths, hidden modules, third-party helper traits, macro support re-exports. |
| [M-PROC-IMPL](ms-macros.md#m-proc-impl) | Check procedural macro crates are thin shims over a regular implementation crate with unit, snapshot, and UI tests. | `*_proc` crates, `*_proc_impl` crates, token transformation tests, insta snapshots, trybuild tests. |
| [M-PROC-IMPLIED-ITEMS](ms-macros.md#m-proc-implied-items) | Check procedural macros avoid creating hidden or magic public items except for justified namespace-overload patterns. | Expanded items, generated type names, public visibility, re-export behavior, namespace collisions. |

## Applications (Microsoft)

Deep reference: `references/ms-apps.md`.

Applies when: reviewing application crates, binaries, or repository-internal crates exclusively used by an application. Mark the category `N/A` for reusable libraries.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-MIMALLOC-APPS](ms-apps.md#m-mimalloc-apps) | Check application crates set mimalloc as the global allocator unless there is a measured or platform reason not to. | Binary `main.rs`, allocator declarations, `Cargo.toml`, benchmark notes, target platform constraints. |
| [M-APP-ERROR](ms-apps.md#m-app-error) | Check application-level crates use one application error crate consistently when choosing `anyhow`, `eyre`, `ohno::AppError`, or similar, and do not mix multiple app error types. | App `Result` aliases, error imports, crate boundaries, library error types, conversion call sites. |
| [M-TARGET-CPU](ms-apps.md#m-target-cpu) | Check server applications compile for the highest `target-cpu` guaranteed by the deployment fleet. | `.cargo/config.toml`, build flags, deployment hardware, CI release profiles, container build scripts. |

## FFI (Microsoft)

Deep reference: `references/ms-ffi.md`.

Applies when: the crate imports from native libraries, exports C-style APIs, loads Rust-based dynamic libraries, or exposes any FFI boundary. Mark the category `N/A` when no FFI surface exists.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-ISOLATE-DLL-STATE](ms-ffi.md#m-isolate-dll-state) | Check Rust-based dynamic libraries share only portable `repr(C)`-style state that has no interaction with statics, thread locals, `TypeId`, or non-portable data. | FFI types, DLL boundaries, `repr` attributes, allocated values, statics, thread locals, `TypeId` usage. |
| [M-FFI-TRANSLATES](ms-ffi.md#m-ffi-translates) | Check business logic lives in safe core crates and FFI crates only translate between Rust and C data models. | Core crates, `*-ffi` crates, exported symbols, duplicated FFI signatures, safe Rust APIs. |
| [M-FFI-NAMING](ms-ffi.md#m-ffi-naming) | Check FFI crates use established `-sys` naming for imports and `-ffi` naming for exported C-style APIs. | Crate names, package names, workspace members, README descriptions. |

## Correctness (Microsoft)

Deep reference: `references/ms-correctness.md`.

Applies when: every Rust crate or workspace review. Mark individual unsafe, panic, or unwind rows `N/A` only when that construct or risk is absent.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-UNSAFE](ms-correctness.md#m-unsafe) | Check every `unsafe` use has a valid reason, is minimal and testable, documents safety reasoning, follows unsafe-code guidelines, and passes Miri where applicable. | `unsafe` blocks, `unsafe` functions, `unsafe impl`s, safety comments, benchmarks, FFI bindings, Miri tests. |
| [M-UNSOUND](ms-correctness.md#m-unsound) | Check safe APIs cannot cause undefined behavior from any safe calling pattern, and expose `unsafe` APIs instead when safety cannot be encapsulated. | Safe abstractions over raw pointers, lifetime tricks, interior unsafe code, module boundaries, adversarial tests. |
| [M-UNSAFE-IMPLIES-UB](ms-correctness.md#m-unsafe-implies-ub) | Check `unsafe` marks only functions or traits whose misuse can cause undefined behavior, not merely dangerous or destructive operations. | `unsafe fn`, `unsafe trait`, safety docs, dangerous safe APIs, deletion or external-effect APIs. |
| [M-PANIC-IS-STOP](ms-correctness.md#m-panic-is-stop) | Check panics are used only to request program termination for programming errors, const contexts, user-requested unwraps, or poison states. | `panic!`, `unwrap`, `expect`, assertions, error handling paths, `panic = abort` compatibility. |
| [M-PANIC-ON-BUG](ms-correctness.md#m-panic-on-bug) | Check detected unrecoverable programming bugs and contract violations panic instead of returning unhandleable error variants. | Invariant checks, contract validation, error enums, parser APIs, standard-library precedent. |
| [M-PANIC-CONTINUATION](ms-correctness.md#m-panic-continuation) | Check `catch_unwind` recovery is a last resort and generally leads to controlled restart rather than indefinite library execution. | `catch_unwind` usage, request isolation, restart logic, library panic handlers, unwind boundaries. |
| [M-PANIC-MESSAGE](ms-correctness.md#m-panic-message) | Check intentional production panics include helpful messages with relevant values where applicable, while not requiring such messages in tests. | `panic!`, `assert!`, `unreachable!`, `todo!`, `expect`, test-only panics. |

## Performance (Microsoft)

Deep reference: `references/ms-performance.md`.

Applies when: reviewing performance-sensitive crates, COGS-sensitive services, hot paths, or APIs whose design controls allocation, batching, or concurrency behavior. Mark the category or specific rows `N/A` when there is no plausible hot path or performance contract.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-THROUGHPUT](ms-performance.md#m-throughput) | Check throughput-sensitive code optimizes items per CPU cycle through batching, independent work partitions, sleeping or yielding when idle, and minimal shared state. | Batch APIs, work partitioning, lock usage, spin loops, task scheduling, throughput benchmarks. |
| [M-HOTPATH](ms-performance.md#m-hotpath) | Check performance-relevant crates identify hot paths early, benchmark them, profile CPU and allocations, and communicate sensitive areas. | Criterion or divan benchmarks, profiler artifacts, debug-symbol settings, performance docs, CI benchmark jobs. |
| [M-YIELD-POINTS](ms-performance.md#m-yield-points) | Check long-running async computations include cooperative yield points or runtime budget checks to avoid starving concurrent tasks. | CPU-bound futures, loops, `yield_now().await`, runtime budget APIs, latency tests. |
| [M-MEM-REUSE](ms-performance.md#m-mem-reuse) | Check hot APIs let callers reuse allocations and internal hot loops reuse buffers, collections, or arenas where appropriate. | Allocation-heavy loops, reusable state types, `.clear()` usage, arena patterns, benchmark allocation counts. |
| [M-LOG-OVERHEAD](ms-performance.md#m-log-overhead) | Check library telemetry on hot paths has reasonable volume and avoids allocations or formatting overhead that harms throughput or latency. | Logging calls, metrics emission, inner loops, allocation profiles, disabled and enabled telemetry benchmarks. |
| [M-AVOID-INDIRECTION](ms-performance.md#m-avoid-indirection) | Check hot nested type hierarchies avoid needless heap indirection and lift cacheable fields when shared ownership is not required. | Hot structs, `Arc` layers, heap boxes, pointer chasing, cache profiles, ported OO designs. |
| [M-BOX-DST](ms-performance.md#m-box-dst) | Check frequently instantiated internal immutable sequences use boxed slices or strings instead of growable collections when they will not be resized. | Internal `Vec`, `String`, `Box<[T]>`, `Arc<str>`, construction paths, memory profiles. |
| [M-SHRINK-TO-FIT](ms-performance.md#m-shrink-to-fit) | Check large long-lived growable collections built without exact reservations are shrunk before storage unless converted through boxed sequence helpers. | Collection builders, `shrink_to_fit`, long-lived structs, capacity measurements, `into_boxed_*` conversions. |
| [M-FAST-HASHER](ms-performance.md#m-fast-hasher) | Check trusted internal hash keys use a fast non-cryptographic hasher instead of the standard default when collision attacks are not relevant. | `HashMap` and `HashSet` types, key trust boundaries, hasher choices, DoS exposure, benchmarks. |
| [M-INITIAL-CAPACITY](ms-performance.md#m-initial-capacity) | Check collections are constructed with sufficient initial capacity, or via iterators with useful `size_hint`, when final or approximate size is known. | `Vec`, `String`, `HashMap`, `HashSet`, `with_capacity`, `collect`, push loops. |
| [M-ASYNC-STACK-SIZE](ms-performance.md#m-async-stack-size) | Check hot async functions track future sizes and reduce captured parameter, return, and cross-await local sizes when needed. | `async fn` hot paths, `size_of_val` tests, large locals across `.await`, `impl Future` refactors, future combinators. |

## Project Organization (Microsoft)

Deep reference: `references/ms-project.md`.

Applies when: reviewing repository or workspace structure, especially multi-crate projects and publishable crates. Mark workspace-specific rows `N/A` for a single standalone crate where no related crates exist.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-CARGO-WORKSPACE](ms-project.md#m-cargo-workspace) | Check related multi-crate repositories use a workspace root to centralize metadata, dependencies, lints, and crate-specific feature choices. | Root `Cargo.toml`, `[workspace]`, `[workspace.dependencies]`, `[workspace.lints]`, member manifests. |
| [M-CRATES-IN-WORKSPACE](ms-project.md#m-crates-in-workspace) | Check every project-produced crate is a workspace member and has a canonical version in `[workspace.dependencies]`. | Workspace members, internal dependency declarations, package versions, path dependencies. |
| [M-CRATES-FLAT-FOLDER](ms-project.md#m-crates-flat-folder) | Check crates live as siblings under one workspace folder or clear sibling hierarchy, never nested inside other crates or `src`. | Repository tree, crate `Cargo.toml` locations, `crates/` layout, nested test fixtures. |
| [M-LATEST-EDITION](ms-project.md#m-latest-edition) | Check newly created crates and workspaces use the latest stable Rust edition, at least 2024 as stated by the source guideline. | `Cargo.toml` edition fields, new crate templates, workspace package settings. |
| [M-MSRV](ms-project.md#m-msrv) | Check libraries declare an MSRV and update it conservatively a few compiler versions behind current stable when new features require it. | `rust-version`, README badges, CI toolchains, changelog, dependency MSRVs. |

## Documentation (Microsoft)

Deep reference: `references/ms-docs.md`.

Applies when: reviewing public crate, module, item, or re-export documentation. Mark individual rows `N/A` for private-only crates or surfaces without the relevant docs or re-exports.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-FIRST-DOC-SENTENCE](ms-docs.md#m-first-doc-sentence) | Check each documented item starts with a one-line summary sentence of roughly 15 words or fewer. | Rustdoc comments, module summaries, generated docs, public item docs. |
| [M-MODULE-DOCS](ms-docs.md#m-module-docs) | Check every public library module has comprehensive `//!` docs covering contents, usage, examples, side effects, guarantees, and relevant implementation details. | Public modules, `//!` comments, examples, subsystem specifications, generated rustdoc. |
| [M-CANONICAL-DOCS](ms-docs.md#m-canonical-docs) | Check public library items use canonical rustdoc sections where applicable and explain parameters in prose rather than tables. | Rustdoc summaries, examples, `# Errors`, `# Panics`, `# Safety`, parameter prose. |
| [M-DOC-INLINE](ms-docs.md#m-doc-inline) | Check crate-item re-exports use `#[doc(inline)]` when they should appear with sibling items, while third-party re-exports remain visibly external. | `pub use` items, `#[doc(inline)]`, rustdoc output, first-party and third-party re-exports. |

## AI & Code Generation (Microsoft)

Deep reference: `references/ms-ai.md`.

Applies when: reviewing AI-generated code, code likely to be maintained by agents, or APIs being designed for AI consumption. Mark the category `N/A` for reviews unrelated to generated code or agent-facing API usability.

| Guideline | AI review action | Evidence to inspect |
| --- | --- | --- |
| [M-DESIGN-FOR-AI](ms-ai.md#m-design-for-ai) | Check APIs are idiomatic, thoroughly documented, example-rich, strongly typed, testable, and covered by behavior tests so agents can use and refactor them reliably. | Public APIs, docs, examples, newtypes, mocks, test coverage, Rust API Guidelines compliance. |
| [M-SINGLE-ITEM-PATH](ms-ai.md#m-single-item-path) | Check each public item is reachable through only one user-facing path, excluding internal export construction, foreign re-exports, and hidden macro-private modules. | Public re-exports, crate root exports, module paths, rustdoc item paths, `_private` modules. |
| [M-NO-META-DESIGN-DOCUMENTATION](ms-ai.md#m-no-meta-design-documentation) | Check crate and module docs describe the end-state behavior rather than transient design journeys, agent self-reports, or process narratives. | Crate docs, module docs, README, design-principles sections, generated documentation additions. |
| [M-TAUTOLOGICAL-TESTS](ms-ai.md#m-tautological-tests) | Check tests verify meaningful behavior or properties instead of restating constants, mirror logic, or asserting values derived by the same implementation. | Unit tests, snapshot tests, mutation-test skips, property tests, branch-mirroring assertions. |
| [M-RUST-SHAPED](ms-ai.md#m-rust-shaped) | Check ported or generated Rust solves Rust problems with Rust idioms instead of copying technical patterns from C#, Java, C++, Python, or similar languages. | Ported code, error handling, task abstractions, ownership patterns, trait designs, statics, OO-shaped helpers. |
