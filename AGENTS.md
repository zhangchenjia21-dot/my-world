# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and current task packet.
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

### Temporary routing through 2026-09-06 23:59 (+08:00)

```text
GPT        → semantics / architecture / governance / final Independent Review
Kimi       → all code-changing implementation tasks, temporarily substituting for Codex
Grok Build → external research / evidence support / secondary cross-check
Owner      → Product UAT / verdict
```

Auto-expiry: 2026-09-07 00:00 (+08:00). Correct in-flight Kimi work may finish under its issued packet.

## 2. Standing authorization for bounded real Provider validation

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

If an approved Task Packet explicitly requires bounded real selected-Provider validation, it is already Owner-authorized within the packet's exact attempt/call ceiling. Do not pause to ask Owner again.

No open-ended loops, hidden Provider/model switching, billing/account changes, secret disclosure or new external services.

If bounded attempts are exhausted by external Provider timeout/unavailability and offline/integration gates are green, commit/push reviewable work, mark real proof pending, and return for Independent Review. Provider availability may block reality proof; it does not block code review.

## 3. Current state

```text
G1 Foundation                              PASS / CLOSED
G2 AI Conversation Spine                   PASS / CLOSED
G3 Persistence / Save / Timeline           PASS / CLOSED
G4 Primary Source Assets & Local Game      PASS / CLOSED
G4-10 Runtime Asset Resolution             DEFERRED / MOVED TO G6

G5 World Semantics & GM Runtime            ACTIVE
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                 PASS / CLOSED
G5-02 real feature vertical                HISTORICAL GAP / Provider unavailable
G5-03 NPC / Faction Agency                 ACTIVE
G5-03M1 old single-NPC packet              SUPERSEDED / DO NOT EXECUTE
G5-03M1 Multi-Actor Agency Cycle           ACTIVE — KIMI
G5-03M2 Stable Actor Materialization       NEXT AFTER M1 REVIEW
G5-04 Event / Priority Evolution           NOT YET
```

Do not execute `G5-03M1_STABLE_NPC_INDEPENDENT_AGENCY_TASK.md`.

## 4. Current execution task

Task packet:

`docs/tasks/G5-03M1_MULTI_ACTOR_AGENCY_CYCLE_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`

Owner: **KIMI** under temporary routing. Reviewer / semantic owner: **GPT**.

Owner product correction:

> One player/world turn may plausibly contain several independent NPC actions. Do not collapse agency to one-NPC-per-turn round-robin for implementation convenience.

Current cycle:

```text
accepted ordinary turn
→ existing semantic-analysis request also performs Agency Selection
→ optional agency_candidates = 0..4 stable NPC IDs
→ separate actor-scoped execution request for every selected actor
→ selected requests may progress concurrently
→ 0..N valid acts may durably commit during the same Agency Cycle
```

No mandatory extra selector Provider call.

## 5. Selection / failure isolation

Extend the existing G5-01/G5-02 semantic response with optional `agency_candidates`.

Bad/absent selection must not invalidate:

- valid `changes`;
- valid `knowledge_events`;
- accepted Narrative.

For M1, eligible agency actors are stable `guaranteed_npcs[*].local_character_id`. Player Character is not eligible.

Selection cap: **4** actors per Agency Cycle. No round-robin fallback and no retry-until-nonempty.

Provide bounded actor-local selection material and instruct the selector to judge each actor only from that actor's own Source/knowledge/history.

## 6. Per-actor execution / knowledge boundary

Every selected actor gets its own request containing only:

- exact actor ID/display name;
- that actor's Game-local Character Source/T0 material;
- that actor's own G5-02 durable knowledge;
- that actor's own recent agency history;
- minimal cycle/source identity.

Do not generate several actors' actions in one shared private-knowledge prompt.

Do not expose Player-only or another NPC's private knowledge merely because the GM knows it.

Protected principle:

> **GM omniscience must not become actor omniscience.**

## 7. Concurrent background agency

Selected actor requests must be able to progress concurrently, bounded by selected count (max 4). Do not use a sequential queue that systematically privileges the first actor.

Agency is background/fail-soft and never a Turn Finalize Barrier.

If the player starts the next Conversation attempt, Restore/Recovery changes progress, source version changes, unrelated world head changes, or session closes:

- invalidate remaining uncommitted agency work;
- best-effort cancel transports;
- late callbacks cannot commit;
- already committed actor actions remain durable.

Foreground player freedom always wins.

## 8. Durable semantics

Several actors may act from the same Agency Cycle/source turn.

Use stable cycle + actor identities and existing `commit_world_mutation_durably(...)` only. No new SQLite table/schema.

Provider calls may finish concurrently; durable commits must be serialized. A successful sibling agency commit in the same cycle is allowed cycle-owned head progression and must not automatically stale other sibling results. Any unrelated head change invalidates remaining results.

`hold`, malformed/wrong actor/provider failure creates no fake mutation and never changes Narrative acceptance.

No hidden d20/check logic; G5-05 owns mechanics.

## 9. Context

Committed actor actions may enter bounded later omniscient GM Context as world truth.

They are not automatically:

- Player knowledge/disclosure;
- another actor's knowledge;
- universal G5-02 provenance.

The acting actor may see its own prior agency history later.

## 10. Actor-pool boundary

M1 proves the Agency Cycle using the stable Guaranteed-NPC pool because those actors already have durable local IDs and exact Game-local Character Source.

Guaranteed NPC is **not** the permanent product boundary. Owner's Cao Cao / Sun Quan / Zhuge Liang example establishes the need for G5-03M2 minimal stable actor materialization/registry so important non-Guaranteed named actors can later enter the same selector/execution contract.

Do not improvise M2 inside M1 by free-form name matching or silently importing mutable external Source into an existing Game.

## 11. Real Provider proof

After deterministic/integration gates are green, M1 may use at most:

```text
1 real combined semantic-selection request
+
up to 2 real selected actor execution requests
```

Maximum 3 feature-owned real model requests. Already authorized. No retries/fallback/hidden model switch.

If inconclusive/unavailable, push reviewable work with real proof pending.

## 12. Protected scope

Do not change without a returned blocker + GPT decision:

- `src/domain/会话.gd` semantics;
- `src/ui/**`;
- persistence schema/migrations;
- Source schema/generation;
- Runtime Model Settings;
- Public d20;
- arbitrary emergent actor identity / M2;
- Faction agency;
- G5-04 general event/priority scheduler;
- G5-05 mechanics;
- G6/G7.

No generic universe/actor simulator.

## 13. Completion

Kimi commits/pushes implementation/tests/evidence and returns:

```text
READY FOR INDEPENDENT REVIEW
```

or, if bounded real proof is pending:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

GPT owns Independent Review and then shapes G5-03M2. Do not start M2/G5-04 early.
