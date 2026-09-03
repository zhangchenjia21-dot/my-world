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

Bounded real Provider validation is pre-authorized when the approved Task Packet explicitly requires it and the run remains inside the packet's stated scenario/call/turn/attempt ceiling using the current approved runtime Provider/profile.

Do **not** pause mid-task to ask Owner again merely because required evidence makes the already-specified model API call.

The authorization does not permit open-ended benchmark loops, hidden Provider/model switching, billing/account changes, sending secrets/credentials/unrelated private data, or new external services outside approved scope.

If bounded attempts are exhausted by external Provider timeout/unavailability and offline/integration gates are green:

```text
commit + push implementation/tests/evidence
→ mark real Provider proof PENDING / EXTERNAL PROVIDER UNAVAILABLE
→ return READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

External Provider availability may block reality proof; it does not block code review.

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
G5-02M1 Known-Actor Knowledge Spine   ACTIVE — KIMI
G5-03 NPC / Faction Agency            NOT YET
G5-04 Event / Priority Evolution      NOT YET
G5-GATE                               NOT YET
```

Do not start G5-03 before G5-02M1 Independent Review and G5-02 closeout.

## 4. Current execution task — G5-02M1

Task packet:

`docs/tasks/G5-02M1_KNOWN_ACTOR_KNOWLEDGE_PROVENANCE_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`

Owner: **KIMI** under temporary routing. Reviewer / semantic owner: **GPT**.

Core product distinction:

```text
Game / World Truth
!= actor knowledge
!= human-player disclosure
!= omniscient GM model context
```

Protected principle:

> **GM omniscience must not become actor omniscience.**

Current Source `disclosure: gm_reference` remains GM/reference metadata. Do not reinterpret it as “all actors know this.”

## 5. G5-02M1 actor scope

Track only post-T0 knowledge acquisition for existing stable Game-local actor IDs:

```text
player_character.local_character_id
+
guaranteed_npcs[*].local_character_id
```

No durable identity for incidental/emergent NPCs, Factions, groups or arbitrary entities in this task.

Do not convert all T0 Source into a knowledge graph.

## 6. One auxiliary request, not two

Extend the existing G5-01 semantic-analysis request; do not add a second Provider request per ordinary accepted turn.

Conceptual response:

```json
{
  "changes": ["durable world consequence"],
  "knowledge_events": [
    {
      "knower_id": "stable-local-id",
      "fact": "post-T0 fact this actor now has grounds to know",
      "basis": "witnessed|told|discovered|participated"
    }
  ]
}
```

Knowledge parsing/validation failure must not invalidate an otherwise valid G5-01 `changes` result.

Unknown/non-roster `knower_id` must never become durable authority.

## 7. Durable semantics

Knowledge provenance belongs inside the existing game-local `world_state.living_world`, adjacent to G5-01 semantic turn records. Do not add a SQLite schema/table or second persistence owner.

One accepted semantic result may produce:

- changes only;
- knowledge only;
- both;
- neither.

If durable material exists, at most one `commit_world_mutation_durably(...)` call for that accepted turn version.

Persist only bounded validated provenance records tied to the accepted source turn + GM hash. Never persist raw Provider prompt/response/reasoning.

## 8. Context consumer

The first consumer is later ordinary GM Context.

GM may still receive broad Game-local World/Source truth. Add a bounded actor-knowledge provenance projection that communicates which stable actors have durable post-T0 grounds to know which facts.

The semantic guidance is:

> A post-T0 fact present in World/GM context is not automatically actor knowledge. Let an actor speak, plan, react or decide from it only when durable provenance below or the current scene supports awareness.

This is soft model guidance, not an output gate.

Do not add keyword validators, “omniscience” classifiers, retry-on-style logic, or mandatory Narrative format.

## 9. G5-01 remains protected

G5-01 is PASS/CLOSED. Do not reopen it absent concrete regression.

Core ordering remains:

```text
free-form visible Narrative
→ durable Conversation acceptance
→ separate best-effort semantic analysis
→ optional atomic world semantic mutation
```

Narrative acceptance remains independent of semantic-analysis success.

`G5-01M1C02` is cancelled/do-not-execute. Do not implement speculative Restore exact-replay infrastructure.

## 10. First G5-02 proof

At minimum prove with task-owned state:

```text
Player Character + Guaranteed NPC A
→ Player alone discovers private fact F
→ Player gets durable knowledge provenance
→ NPC A does not
→ later Context preserves asymmetry
→ later accepted Narrative explicitly tells NPC A
→ NPC A gains provenance
→ Save/reopen preserves the boundary
```

Also prove:

- unknown actor IDs rejected;
- knowledge parse failure does not break valid G5-01 changes;
- knowledge-only result can make one atomic mutation;
- stale GM-hash knowledge does not project;
- replay/reopen does not duplicate knowledge.

## 11. Provider proof

After offline/integration gates are green, at most **one** task-owned real selected-Provider attempt is authorized by the standing decision.

No fallback, hidden model switch or second attempt.

If Provider is externally unavailable, push reviewable work/evidence and mark real proof pending.

## 12. Protected scope

Expected code scope is bounded around `src/世界回合/**` and the existing continuation Context projection seam.

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

Do not build:

- generic Entity/Knowledge Graph;
- false-belief/inference engine;
- rumor network;
- confidence/reliability scoring;
- Faction knowledge;
- emergent NPC identity platform.

## 13. Completion

Kimi commits/pushes implementation/tests/evidence and returns:

```text
READY FOR INDEPENDENT REVIEW
```

or, only if bounded real proof is unavailable:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

GPT owns Independent Review and G5-02 closeout. Do not start G5-03 early.
