# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions.
5. this `AGENTS.md` + current Task Packet.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Long-term routing:

```text
GPT        → meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. Correct in-flight Kimi work may finish after expiry.

## 2. Standing Provider rule

Canonical: `Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`.

Bounded validation explicitly required by an approved packet is pre-authorized. No fallback, hidden Provider/model switch, open-ended retry or repeated Owner confirmation. External Provider outage may leave reality proof pending without blocking reviewable code from commit/push.

## 3. Current state

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G4-10 Runtime Asset Resolution              DEFERRED / MOVED TO G6

G5 World Semantics & GM Runtime             ACTIVE
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ACTIVE
G5-03M1 Multi-Actor Agency                  REDESIGN ACTIVE
G5-03M1C01                                  HISTORICAL PARTIAL PASS
G5-03M1C02                                  SUPERSEDED / DO NOT EXECUTE
G5-03M1R01 Agency Scheduler v0.3            ACTIVE — KIMI
G5-03M2 Stable Actor Materialization        NOT YET
G5-04 Event / Priority Evolution            NOT YET
```

Do not execute the old C02 packet. Do not start M2/G5-04 before R01 Independent Review PASS.

## 4. Current execution task

Task:

`docs/tasks/G5-03M1R01_AGENCY_SCHEDULER_V0_3_SIMPLIFICATION_REDESIGN_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

Historical v0.2 decision and C02 packet are superseded.

## 5. Redesign rule

**Do not rollback the existing G5-03 codebase.** Preserve accepted downstream behavior and replace only the upstream semantic-selection coupling.

Preserve:

- multi-actor actor-scoped execution;
- concurrent selected actor requests, max 4;
- actor-private Source/current Knowledge/own history;
- serialized atomic sibling commits;
- same-cycle sibling expected-head progression;
- foreground/Restore cancellation;
- stale actor-memory filtering;
- same-version replay no duplicate;
- bounded Independent Actor Actions GM Context projection.

Replace:

```text
semantic analysis
→ agency_candidates
→ Application starts Agency
```

with:

```text
accepted ordinary turn
→ semantic lane handles changes + knowledge only
→ scheduler marks Agency dirty
→ once foreground idle + semantic queue settled
→ standalone lightweight selector over latest current world snapshot
→ validated 0..4 stable actors
→ existing concurrent per-actor Agency Cycle execution
```

## 6. Semantic lane protection

G5-01/G5-02 semantic analysis must not depend on Agency currentness.

An older accepted turn whose GM hash is still current at that index may still materialize valid `changes` / `knowledge_events` even if the player has advanced foreground.

Remove Agency Selection from the semantic prompt/result/handoff. Do not erase accepted semantic truth merely because an Agency opportunity was missed.

## 7. Scheduler / coalescing

A durable accepted ordinary player turn marks Agency dirty.

Agency does not owe every turn a cycle. Fast A→B→C foreground may coalesce into one later selector evaluation of the latest C snapshot.

Selector may run only when Session ready, dirty=true, foreground idle, semantic worker has no active/queued work, and no selector/cycle is active.

Selector may use bounded GM-level current-world information and returns only:

```json
{"actors":["stable-id-a","stable-id-b"]}
```

Validate current Guaranteed-NPC stable IDs, dedupe, reject Player/unknown, cap 4. No round-robin fallback or retry-until-nonempty.

Selector omniscience does not grant actor knowledge.

## 8. Foreground / timeline

New foreground attempt cancels active selector and remaining uncommitted actor work; already committed actor actions remain durable. The obsolete Agency opportunity is not rescued. A later successfully accepted turn marks dirty again.

Restore/Recovery/session close cancels active background Agency and clears obsolete dirty work. Do not auto-run Agency merely because a Save was loaded.

Before selector output may start a cycle, latest accepted turn/hash + world head must still match its frozen snapshot and foreground must remain idle.

Actor execution keeps the existing sibling expected-head/source-currentness guards.

## 9. Provider proof for R01

After deterministic/integration gates are green, R01 may use at most:

```text
1 real standalone selector request
+
up to 2 real actor execution requests
```

Stub Narrative and semantic prerequisites. Do not spend real Narrative calls just to reach Agency. If Provider unavailable, push reviewable work with real proof pending.

## 10. Scope ceiling

Do not implement M2 actor registry, Faction agency, G5-04 scheduler, generic universe polling, new SQLite schema/table, UI, Source changes, mechanics/d20 changes, G6 or G7.

## 11. Completion

Kimi runs focused + regression tests, records `git diff --check`, writes R01 evidence, commits/pushes and returns:

```text
READY FOR INDEPENDENT REVIEW
```

or:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```
