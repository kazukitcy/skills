# Review Code: Performance

> Algorithmic and architectural performance risk the change introduces — the
> wins that matter at real data sizes and traffic, not micro-optimizations.
> Severity, confidence, evidence, and output format live in
> references/shared-rubric.md — read it too.

## Scope

- Work whose cost grows badly with data size, list length, or request volume
  because of this change.
- Adjacent lenses (route there, don't double-report): the correctness of a cached
  or batched result → correctness; timeout, backpressure, or load-shedding
  behavior under failure → reliability.

## What to look for

- N+1 and per-item I/O: a query, fetch, or RPC issued per item inside a loop or per list/rendered row; a missing batch, join, `IN`-query, or dataloader where the access pattern plainly calls for one.
- ORM lazy loading: a relation attribute read per item in a loop, template, or serializer with no eager load (`select_related`/`prefetch_related`, `includes`, `joinedload`) on the query the diff builds — each access is a hidden per-row query even though no explicit fetch appears in the loop.
- Algorithmic complexity: nested scans over the same collection (O(n²)); a `find`/`filter`/`includes` inside a hot loop where a `Map`/`Set` keyed lookup belongs; sorting or de-duping repeatedly instead of once; growth driven by user-controlled size.
- Repeated work: an identical expensive computation, fetch, or (de)serialization repeated per request/render instead of computed once and reused; a connection pool, DB/HTTP/SDK client constructed per request or per call instead of once at process init (the error-path *leak* of a pooled connection belongs to reliability).
- Caching mistakes: a wrong or overly-broad cache key; a cache never invalidated when its source changes (staleness) or invalidated too aggressively (thrash); user-specific data cached under a shared key; a get→miss→expensive-recompute→set fill on a hot path with no coalescing (singleflight, fill lock, stale-while-revalidate), so expiry makes every concurrent request recompute at once — report only with evidence the path is hot and the fill expensive.
- Payload & data shape: over-fetching full rows/objects when IDs or a few fields suffice (`SELECT *`); missing pagination or limits on an unbounded list/scan; large JSON or blobs shipped to the client; unbounded in-memory accumulation.
- Database access: a query filter or sort that cannot use an index (leading wildcard, function on the column, or a comparison that forces an implicit cast of the indexed column itself — a cast on the literal side does not defeat the index) — flag for verification with schema evidence, don't assert; a transaction held open across slow work; a new cache, shard, or partition key that is constant or low-cardinality under high volume (a global counter key, one dominant tenant), funneling all traffic to one node or slot — needs a stated traffic path, not just the key shape.
- Missing index for a same-diff query: a migration adding a column that queries in the same diff filter, join, or sort on, with no index added alongside — the migration is the schema evidence, so assert rather than flag; for a new foreign key, flag for verification instead (MySQL auto-indexes FK columns, and an existing index may already cover it).
- Offset pagination: `OFFSET`/skip-based paging added on a list that grows with data — cost grows linearly with page depth; prefer keyset (seek) pagination, and report only when page depth is user-controlled or the table plausibly grows large.
- Latency-path hazards: blocking synchronous or CPU-heavy work on a request/render path (in Node: `fs`/`zlib`/`crypto` `*Sync` calls, or `JSON.parse`/`JSON.stringify` of large payloads — O(n) on the event loop, so a large payload stalls all concurrent requests); excessive logging or serialization in a hot path; an added await that serializes calls which could run concurrently.
- Frontend (if applicable): a heavyweight dependency pulled in for trivial use; client-side fetching of data available at render time; a render path that recomputes or re-fetches on every keystroke/scroll; `loading="lazy"` or IntersectionObserver deferral added to an above-the-fold, LCP-candidate image (report only when the image is plausibly in the initial viewport); a new synchronous `<script>` in `<head>` without `defer`/`async`, or a blocking stylesheet for non-critical content, on a user-facing entry page.

## High-signal locations

- Loops, `map`/`forEach`, and list/row renders in the diff that contain a query, fetch, RPC, or otherwise expensive call.
- New list, search, export, or report endpoints/handlers without a `LIMIT` or pagination.
- Cache `get`/`set` pairs and how their keys are constructed and invalidated.
- Query builders and ORM calls whose `WHERE`/`ORDER BY`/`SELECT` the change touched.

## Common false positives

Do not report these:

- Micro-optimizations with no measurable impact on a realistic workload.
- "Could be faster" with no evidence the path is hot, the data large, or the call frequent.
- An index claim without schema evidence — flag it for verification instead of asserting it as a finding.
- Work already bounded by pagination, a small fixed N, an existing cache, or a guard.
- Sequential `await`s where the later call consumes the earlier call's result — a data dependency, not unnecessary serialization; confirm the calls are independent before flagging.

## Severity anchors

Reference points on the shared-rubric scale; these are examples, not a redefinition:

- P1: unbounded work driven by user-controlled size, or an N+1 / O(n²) on a core, high-traffic path that will degrade production.
- P2: a clear inefficiency on a real but lower-traffic or bounded path.
- P3: a small, safe optimization worth noting with limited impact.

## No findings

- If clean: "No concrete performance findings found." (use the shared-rubric empty form).
