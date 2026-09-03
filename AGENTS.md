# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and current task packet.
6. verifiable implementation/tests/current HEAD.

Before authoritative work, refresh both `main`s; never overwrite unknown dirty/newer work.

Long-term execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

### Temporary execution routing｜effective through 2026-09-06

Canonical temporary Owner decision:

`Vibe-Coding/my world/architecture/foundation/TEMPORARY_EXECUTION_ROUTING_2026-09-03_TO_2026-09-06.md`

Because Codex weekly quota is exhausted until 2026-09-07, the following override applies through 2026-09-06 23:59 (+08:00):

```text
GPT        → Meaning / architecture / governance / task shaping / final Independent Review
Kimi       → primary owner for all code-changing implementation tasks, including temporary Codex substitution
Grok Build → external research / evidence discovery / Provider-reality support / secondary technical cross-check
Owner      → Product UAT / explicit product verdict
```

Prefer `Kimi implementation + Grok evidence/research when useful → GPT Independent Review`. Do not create artificial multi-agent work merely to use both.

The temporary override auto-expires at 2026-09-07 00:00 (+08:00), after which the long-term routing resumes absent a newer Owner instruction. Correct in-flight Kimi work may finish under its issued packet rather than being interrupted solely by expiry.

## 2. Standing authorization for required real Provider validation

Canonical Owner decision:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

For this project, bounded real Provider validation is **pre-authorized** when the approved Task Packet explicitly requires it and the run remains inside the packet's stated scenario/call/turn/attempt ceiling using the current approved runtime Provider/profile.

Do **not** stop mid-task to ask the Owner again merely because required evidence will make the already-specified model API call.

The authorization removes a repeated permission gate; it does not authorize scope expansion. It does not permit open-ended benchmark loops, hidden Provider/model switching, billing/account changes, sending secrets/credentials/unrelated private data, or new external services outside the approved task.

Future Task Packets that require real Provider proof should cite the standing authorization and state the smallest reasonable call/turn/attempt ceiling.

### Provider outage / reviewability

External Provider availability may block reality proof; it does **not** block code review.

If the Task Packet's bounded real attempts are honestly exhausted because the current Provider times out or is unavailable before the feature-specific real vertical can be exercised, and all required offline/integration gates are green:

```text
commit + push implementation/tests/evidence
→ mark real Provider proof PENDING / EXTERNAL PROVIDER UNAVAILABLE
→ return READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not switch Provider, add fallback, exceed the bounded attempt ceiling, or keep reviewable work uncommitted merely because external reality proof is unavailable.

GPT may review engineering evidence but must not falsely claim the missing real Provider vertical passed. Product/reality acceptance remains pending until a later successful real run or Owner UAT supplies it.

## 3. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4 Primary Source Assets & Local Game Creation
                                      PASS / CLOSED
G4-10 Runtime Asset Resolution        DEFERRED / MOVED TO G6
G4-11 Two Primary Asset Families      PASS / CLOSED
G4-11C01 Narrative Voice Soft Prompt  PASS / CLOSED
G4-GATE                               PASS

G5 World Semantics & GM Runtime       ACTIVE
G5-01 Minimum Playable T0 + World Turn / Semantic Materialization
                                      ACTIVE
G5-01M1 Semantic Materialization Spine IMPLEMENTED / INDEPENDENT REVIEW ACTIVE — GPT
G5-01 real Provider vertical          PENDING / EXTERNAL PROVIDER UNAVAILABLE
G5-02 Knowledge Provenance            NOT YET
G5-03 NPC / Faction Agency            NOT YET
G5-04 Event / Priority Evolution      NOT YET
G5-GATE                               NOT YET
```

Do not start G5-02 before G5-01M1 Independent Review + G5-01 Owner/product checkpoint.

## 4. Current review target — G5-01M1

Implementation head:

`eb171a19dd0b4eeb134392128fb8df7fd5b104cb`

Evidence head:

`f9b1be01bd102f3bb1ae6b0b762a6b97d3a5b6f1`

Evidence:

`docs/g5_01/G5-01M1_WORLD_TURN_SEMANTIC_MATERIALIZATION_EVIDENCE.md`

Canonical semantic decision:

`Vibe-Coding/my world/architecture/world/G5_WORLD_TURN_SEMANTIC_MATERIALIZATION_V0_1_DECISION.md`

Current owner/reviewer: **GPT**.

Codex's provider-outage correction is complete and pushed. Do not ask Kimi to redo G5-01M1 from scratch.

If GPT finds a focused implementation correction before 2026-09-07, assign it to **Kimi** under the temporary routing decision; Grok may assist with evidence/research if useful.

## 5. G5-01 core ordering

```text
Player action
→ free-form visible GM Narrative streaming
→ durable Conversation acceptance
→ separate best-effort Semantic Materialization Lane
→ optional Program-owned World Turn
→ existing atomic world mutation / Timeline
→ committed matching changes may re-enter later Context
```

Protected distinction:

> **Narrative acceptance != semantic-analysis success.**

Semantic extraction failure must not convert an already accepted player action into a failed action.

## 6. World Turn v0.1

Conceptual durable namespace:

```text
living_world
  schema_version = living_world.v0.1
  semantic_turns_by_index
    <turn_index>
      world_turn_id
      source_turn_index
      source_gm_sha256
      materialized_at
      changes[]
```

This is a turn-level durable consequence ledger only.

Do not turn it into a universal fact/entity ontology or prematurely implement Knowledge/Relationship/Location/Inventory/NPC/Faction/Event domains.

## 7. Semantic analysis lane

- trigger only from a **durably accepted** ordinary player/GM turn;
- GM-only Opening is skipped in v0.1;
- use current selected Runtime Model Settings provider/profile through existing adapter;
- no cross-provider fallback or hidden model switch;
- exactly one semantic-analysis attempt per new accepted turn in v0.1;
- small machine data such as `{"changes":[...]}` is allowed because this is a separate analysis lane, not visible prose;
- malformed/transport/missing-key/empty analysis fails soft: no fake mutation, no action failure, no automatic recovery loop;
- never persist raw prompts/payload/reasoning/credentials.

## 8. Model Freedom / narrative protection

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind durable infrastructure boundaries
```

Do not add:

- JSON/header/sentinel requirements to player-visible Narrative;
- mandatory prose structure;
- genre/style keyword gates;
- output classifiers that block acceptance;
- semantic-analysis success as a prerequisite to Conversation acceptance;
- per-token world persistence.

The G4-11C01 soft narrative-voice guidance is PASS/CLOSED. Do not reopen it absent a concrete regression; its product effect will be observed opportunistically in the next Owner UAT.

## 9. Replay / correction / Restore

Same accepted content must not duplicate a World Turn.

After regenerate/latest-turn correction, a semantic record whose `source_gm_sha256` does not match the currently accepted GM text at that turn index must never be projected into Context.

Successful rematerialization may replace the record for that turn in a new world snapshot. Existing Timeline/Save/Restore owns historical reversal.

## 10. Existing seams to reuse

Current implementation already has:

- T0-scoped exact Source materialization;
- durable Conversation;
- `src/runtime/当前游戏会话运行时.gd::commit_world_mutation_durably(...)`;
- current Timeline head/world snapshot;
- Save/Restore/Recovery;
- One Game = One SQLite.

Extend these seams. Do not create a second persistence owner or schema forest.

## 11. Protected scope

Focused backend integration may touch current Game Runtime / Application Shell / existing Game-context projection seams when required.

Protected unless GPT has approved a returned blocker:

- `src/domain/会话.gd` semantics;
- `src/ui/**` unless a UI-owned task explicitly opens them;
- Persistence schema/migrations;
- Source package/schema/generation;
- Runtime Model Settings;
- Public d20;
- G6 visuals.

If a SQLite schema migration or unrelated scope expansion appears necessary, STOP and return the boundary finding instead of silently expanding scope.

## 12. G5-01 non-scope

Do not implement early:

- G5-02 Knowledge Provenance;
- G5-03 NPC/Faction Agency;
- G5-04 Event/Priority-driven World Evolution;
- generic world graph/platform;
- G6 RPG/visual UI;
- G7 long-session retrieval architecture.

## 13. Visual deferral remains protected

```text
G4-10 Runtime Asset Resolution = DEFERRED / MOVED TO G6
```

Do not implement portrait / scene / authored-map runtime during G5-01.

## 14. After G5-01M1

If GPT Independent Review passes the engineering implementation while real Provider proof remains pending, G5-01 product/reality acceptance remains open. A later successful real Provider run or short Owner checkpoint must still prove one simple lived consequence survives later play/reopen while Narrative remains free-form.

Only after Owner/Product PASS may GPT close G5-01 and shape G5-02 Knowledge Provenance.
