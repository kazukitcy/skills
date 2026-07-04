# Rust API Guidelines AI Review Checklist

## How to use this checklist

1. Review only public Rust API surface: exported modules, `pub` items, public traits, public macros, crate docs, Cargo metadata, and release-facing docs.
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
