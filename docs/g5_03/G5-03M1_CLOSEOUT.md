# G5-03M1 — Multi-Actor Agency Engineering Closeout

Status: **PASS / CLOSED**  
Date: 2026-09-04

## Accepted implementation

G5-03M1 now implements the v0.3 Agency architecture:

```text
accepted ordinary turn
→ semantic changes + knowledge lane
→ one dirty Agency opportunity
→ semantic settles
→ standalone Agency selector over current post-semantic world
→ 0..4 selected stable NPCs
→ separate concurrent actor-scoped executions
→ 0..N serialized durable actor actions
```

Protected behavior:

- player foreground never waits for Agency;
- selector and semantic materialization are separate Provider requests/lifecycles;
- selector may use bounded GM-level world context, but actor execution remains private to that actor's Source/Knowledge/history;
- several selected actors can be active concurrently;
- sibling durable commits progress the cycle-owned head without staling siblings;
- unrelated foreground/Restore/timeline changes invalidate remaining uncommitted work;
- committed actions remain durable;
- no same-opportunity automatic retry;
- replay/reopen does not duplicate committed actor work.

## Correction history

Historical v0.2 piggyback selection was superseded after repeated currentness coupling. v0.3 kept the working downstream multi-actor execution and replaced only upstream scheduling.

R01C01 and R01C02 closed Scheduler lifecycle/currentness defects. R02 simplified wake ownership to:

```text
generation_completed → mark_dirty only
semantic finished     → consider_agency
```

## Reality proof

Deterministic/integration Engineering proof is complete. Parent real Provider validation remains `PENDING / EXTERNAL PROVIDER UNAVAILABLE`; no fallback or synthetic PASS was used.

## Product checkpoint

No standalone Owner UAT is inserted here. M1's current actor pool is intentionally incomplete. G5-03M2 is the next materially informative product slice because it lets important non-Guaranteed NPCs enter the same Agency contract.
