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

Through 2026-09-06 23:59 (+08:00):

```text
GPT        → Meaning / architecture / governance / task shaping / final Independent Review
Kimi       → primary owner for all code-changing implementation tasks, including temporary Codex substitution
Grok Build → external research / evidence discovery / Provider-reality support / secondary technical cross-check
Owner      → Product UAT / explicit product verdict
```

The override auto-expires at 2026-09-07 00:00 (+08:00). Correct in-flight Kimi work may finish under its issued packet.

## 2. Standing authorization for required real Provider validation

Canonical Owner decision:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

Bounded real Provider validation is pre-authorized when an approved Task Packet explicitly requires it and the run remains inside the packet's stated ceiling using the current approved runtime Provider/profile.

Do **not** pause mid-task to ask Owner again merely because the already-specified validation makes a model API call.

The authorization does not permit open-ended loops, hidden Provider/model switching, billing/account changes, sending secrets/unrelated private data, or new external services outside approved scope.

If bounded attempts are exhausted by external Provider timeout/unavailability and offline/integration gates are green, commit/push reviewable work, mark the real proof pending, and return for Independent Review. External Provider availability may block reality proof; it does not block code review.

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
G5-01 World Turn / Semantic Materialization
                                      PASS / CLOSED
G5-01M1 Semantic Materialization Spine ENGINEERING PASS / CLOSED
G5-01M1C02 Restore Timeline Isolation CANCELLED / DO NOT EXECUTE
G5-02 Knowledge Provenance            ACTIVE
G5-02M1 Known-Actor Knowledge Spine   CORRECTION REQUIRED
G5-02M1C01 Actor Roster + Recent Knowledge Projection
                                      ACTIVE — KIMI
G5-02 real Provider vertical          PENDING / EXTERNAL PROVIDER UNAVAILABLE
G5-03 NPC / Faction Agency            NOT YET
G5-04 Event / Priority Evolution      NOT YET
G5-GATE                               NOT YET
```

Do not start G5-03 before G5-02M1C01 Independent Review and G5-02 closeout.

## 4. Current execution task — G5-02M1C01

Independent Review:

`docs/g5_02/G5-02M1_INDEPENDENT_REVIEW.md`

Correction packet:

`docs/tasks/G5-02M1C01_ACTOR_ROSTER_RECENCY_CORRECTION_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`

Owner: **KIMI** under temporary routing. Reviewer / semantic owner: **GPT**.

Blocking findings:

1. the production semantic-analysis request requires exact stable `knower_id` values but currently does not provide the Player/Guaranteed-NPC local-ID roster to the model;
2. bounded knowledge Context currently consumes the oldest events first, so after the cap newer knowledge can disappear from later GM Context;
3. the real-provider harness must require actual non-empty valid knowledge provenance before a future feature-specific PASS.

Correction rules:

- add the compact stable actor roster to the **same existing** semantic-analysis request;
- keep one auxiliary Provider request per accepted turn;
- select newest matching knowledge within the existing cap;
- no additional real Provider attempt in this correction; the parent one-attempt ceiling is already consumed;
- do not redesign G5-02 or start G5-03.

## 5. G5-02 protected semantics

Core distinction:

```text
Game / World Truth
!= actor knowledge
!= human-player disclosure
!= omniscient GM model context
```

Protected principle:

> **GM omniscience must not become actor omniscience.**

Track only post-T0 knowledge acquisition for stable Game-local actor IDs:

```text
player_character.local_character_id
+
guaranteed_npcs[*].local_character_id
```

No emergent/incidental NPC identity, Faction knowledge, group knowledge or generic Entity/Knowledge Graph in G5-02M1.

Current Source `disclosure: gm_reference` remains GM/reference metadata, not automatic actor knowledge.

## 6. One auxiliary request, failure isolation

G5-02 extends the existing G5-01 semantic-analysis request. Do not add a second Provider tax.

Knowledge parsing/validation failure must not invalidate otherwise valid G5-01 `changes`.

Unknown/non-roster `knower_id` must never become durable authority.

Narrative remains free-form and accepted independently from semantic-analysis success. No JSON/header/sentinel requirement, output classifier, knowledge keyword gate, or retry-on-omniscience behavior.

## 7. Durable / Context semantics

Knowledge provenance belongs inside existing game-local `world_state.living_world`, adjacent to G5-01 turn records. No SQLite schema/table or second persistence owner.

One accepted semantic response may produce changes only, knowledge only, both, or neither. If durable material exists, at most one `commit_world_mutation_durably(...)` call for that accepted turn version.

Later ordinary GM Context may project a bounded `Actor Knowledge Provenance` section. It must use committed/current-hash-matching provenance and a recent working set; G7 owns long-session retrieval.

## 8. G5-01 remains protected

G5-01 is PASS/CLOSED. Do not reopen it absent a concrete regression.

`G5-01M1C02` is cancelled/do-not-execute. Do not implement speculative Restore exact-replay infrastructure.

## 9. Real Provider status

The G5-02M1 packet authorized at most one task-owned real selected-Provider attempt after offline gates. That attempt timed out during ordinary Narrative before feature-specific knowledge proof.

```text
G5-02M1 real selected-Provider vertical
PENDING / EXTERNAL PROVIDER UNAVAILABLE
```

Do not make another real Provider call during G5-02M1C01, do not switch Provider, and do not add fallback.

## 10. Protected scope

Expected correction scope is bounded around:

- `src/世界回合/L2_流程层/语义物化流程.gd`;
- `src/世界回合/L1_器件层/世界回合上下文投影器.gd`;
- focused G5-02 tests / real-provider harness / evidence.

Protected unless GPT approves a returned blocker first:

- `src/domain/会话.gd` acceptance semantics;
- `src/ui/**`;
- persistence schema/migrations;
- Source schema/generation;
- Runtime Model Settings;
- Public d20;
- G5-03 NPC/Faction Agency;
- G5-04 Event/Priority evolution;
- G6 visuals;
- G7 retrieval platform.

## 11. Completion

Kimi commits/pushes the focused correction and returns:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

GPT owns Independent Review and G5-02 transition. Do not start G5-03 early.
