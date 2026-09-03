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

Owner has temporarily declined Gemini adversarial review. `docs/tasks/G5-03M1R01_GEMINI_ADVERSARIAL_REVIEW_TASK.md` is CANCELLED / DO NOT EXECUTE. Review flow remains Kimi implementation → GPT Independent Review.

## 2. Standing Provider rule

Canonical: `Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`.

No fallback, hidden Provider/model switch, open-ended retry or repeated Owner confirmation. External Provider outage may leave reality proof pending without blocking reviewable code.

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
G5-03M1R01 Agency Scheduler v0.3            CORRECTION REQUIRED
G5-03M1R01C01 Scheduler Lifecycle/Snapshot  CORRECTION REQUIRED / CLOSED INTO C02
G5-03M1R01C02 Dirty Opportunity Consumption ACTIVE — KIMI
G5-03M2 Stable Actor Materialization        NOT YET
G5-04 Event / Priority Evolution            NOT YET
```

Do not execute old C02 or Gemini review packets. Do not start M2/G5-04 before R01C02 Independent Review PASS.

## 4. Current execution task

Review:

`docs/g5_03/G5-03M1R01C01_INDEPENDENT_REVIEW.md`

Current correction:

`docs/tasks/G5-03M1R01C02_DIRTY_OPPORTUNITY_CONSUMPTION_CORRECTION_TASK.md`

Canonical decision remains:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## 5. Accepted v0.3 architecture

Do not redesign:

```text
ordinary durable accepted turn
→ semantic lane handles changes + knowledge only
→ standalone Scheduler marks one Agency opportunity dirty
→ safe standalone selector over latest current world snapshot
→ validated 0..4 stable actors
→ existing concurrent actor-scoped Agency Cycle
```

Preserve multi-actor concurrency, actor-private Knowledge/History, sibling durable commits/head progression, foreground/Restore cancellation, current-hash selector material and replay no duplicate.

## 6. Current correction seam

C01 fixed production wiring/current snapshot, but failed to consume `dirty` when a selector starts. The same accepted turn can therefore immediately start another selector when its cycle finishes.

C02 must enforce:

```text
one dirty opportunity
→ one selector attempt
→ dirty=false once selector starts
→ every terminal outcome consumes that opportunity
→ no automatic/manual re-consider retry without a later newly accepted ordinary turn
```

Also replace the current false “production dirty” test that directly calls `mark_dirty()` with a real Application/production callback proof, and bind cycle terminal cleanup to the exact finished cycle where practical.

## 7. Provider rule

**Zero real Provider calls in C02.** Parent G5-03 feature proof remains pending honestly.

## 8. Scope ceiling

Do not implement M2 actor registry, Faction agency, G5-04 scheduler, generic polling, new SQLite schema/table, UI, Source changes, mechanics/d20 changes, G6 or G7.

## 9. Completion

Kimi runs focused + regression tests, `git diff --check`, writes evidence, commits/pushes and returns:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```
