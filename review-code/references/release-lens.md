# Review Code: Release & Operability

> Whether the change deploys, rolls back, and operates safely — migrations,
> config, feature flags, deploy ordering, and observability. Severity, confidence,
> evidence, and output format live in references/shared-rubric.md — read it too.

## Scope

- Safe rollout and operation of the change: schema/data migrations, config and
  flags, deploy sequencing, rollback, and the signals to run it in production.
- Adjacent lenses (route there, don't double-report): runtime concurrency/retry
  behavior → reliability; the data-shape or API contract's design quality →
  design (a contract that breaks consumers at deploy time stays here).

## What to look for

- Migration safety under traffic: a schema change that locks a large table, rewrites it, or blocks reads/writes during deploy; a `NOT NULL`/type change/`DROP`/rename applied in one step instead of expand-then-contract; DDL with no `lock_timeout`/`statement_timeout` guard, which queues behind any long-running query and freezes the table even when the DDL itself is fast; `CREATE INDEX` without `CONCURRENTLY`; `ADD FOREIGN KEY`/`CHECK` without `NOT VALID` plus a later `VALIDATE CONSTRAINT`; `CONCURRENTLY` inside a wrapping transaction, which fails at deploy time (safe when the table is empty or created in the same migration).
- Rollout compatibility: old-app/new-DB or new-app/old-DB incompatibility during the window when both run; a column/field read by the old code removed too early; a new required field the old writer cannot populate; a field removed, renamed, or type-changed in a response consumed by clients that do not deploy atomically with this change (mobile apps, third parties, other teams' services) with no version bump or deprecation window.
- Backfills: a backfill that is not restartable or idempotent (re-running double-counts or fails); one large transaction instead of batches; a backfill holding locks or saturating the DB.
- Rollback: no rollback path; an irreversible action (delete, destructive migration, external side effect) without a guard or dry-run; a forward-only migration paired with code that can be rolled back, leaving them inconsistent.
- Config & feature flags: a default config value changed with production impact; a new required env var/secret with no default and no rollout note; a config read with a silent fallback that disables a protection (`ENV["TIMEOUT_MS"] || 0` → no timeout) instead of failing fast when missing; a feature flag whose flip mid-operation leaves work half-done; flag logic that fails open or closed the wrong way.
- Deploy ordering & coupling: a change that must ship before/after another service or migration to be correct; a producer/consumer or client/server pair whose deploy order matters; background worker version skew.
- Observability for new failure modes: a new failure path with no metric, log, or alert; an error message not actionable in production (no IDs/context); poor failure classification (everything at the same level); a silent fallback that hides a degraded state.

## High-signal locations

- Migration/DDL files, and any backfill or data-fix script.
- Config defaults, env-var reads, secret references, and feature-flag checks the change adds or alters.
- Code that must ship in a specific order relative to another deploy, migration, or service.
- New `catch`/fallback branches and the logging/metrics (or absence) around them.

## Common false positives

Do not report these:

- A migration already done expand/contract-safe (additive, nullable, backfill, then later contract).
- Adding a column with a constant `DEFAULT` on PostgreSQL ≥ 11 or MySQL 8 `INSTANT` — metadata-only, no table rewrite; volatile defaults (`now()`, `gen_random_uuid()`, `nextval()`) still rewrite. Do not apply the carve-out if the project pins an older engine.
- A config change gated behind a flag defaulted off, or with a documented rollout note.
- Observability gaps on a path that introduces no new failure mode.
- An irreversible action that is the intended, guarded behavior with a clear confirmation or precondition.

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P0/P1: a migration or deploy step that breaks running production, locks a hot table, or has no rollback; data loss on a destructive migration without a guard.
- P2: a rollout-order or config risk that is safe only if a specific (currently undocumented) sequence is followed.
- P3: a missing-but-nice metric, log field, or alert.

## No findings

- If clean: "No concrete release findings found." (use the shared-rubric empty form).
