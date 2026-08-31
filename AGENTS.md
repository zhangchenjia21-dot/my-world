# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and the current task packet.
6. verifiable implementation/tests/current HEAD.

Before authoritative work, refresh `main`; never overwrite unknown dirty/newer work.

Execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
```

---

## 2. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle  PASS / CLOSED
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
G4-05 New Game Wizard                 PASS / CLOSED
G4-06 Atomic Final Create             PASS / CLOSED
G4-07 First Playable A                PASS / CLOSED
G4-07A Opening Runtime                PASS / CLOSED
G4-07B Playable UI Integration        PASS / CLOSED
G4-07UAT01 Owner Launch Freshness     PASS / CLOSED
G4-08 Expansion Pack v0.1             ACTIVE
G4-08S0 Expansion Semantic Freeze     ACTIVE — GPT
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

Record:

`docs/g4_07/G4-07_OWNER_UAT_RESULT.md`

This closes First Playable A and permits progression to G4-08.

---

## 3. Current task — G4-08S0

Formal packet:

`docs/tasks/G4-08S0_EXPANSION_V0_1_SEMANTIC_PRODUCT_FREEZE_TASK.md`

Primary owner: **GPT**.  
No Codex/Kimi execution task is active yet.

Purpose:

> Freeze what Expansion Pack v0.1 means and choose one real Expansion whose effect is observable in actual play before mechanism implementation begins.

Existing frozen constraints:

- Expansion Pack is the third reusable Primary Source type.
- New Game Composition supports `0..N` exact Expansion generations.
- exact immutable Source generation and old-Game isolation remain mandatory.
- G4-08 must prove real Runtime / Context / mechanic effect; manifest/binding existence alone is insufficient.
- arbitrary code plugins, generic mod sandbox, external UI contribution schema, Creator suite and giant generic rules engines remain deferred.

G4-08S0 must define:

- minimal Expansion v0.1 package semantics;
- compatibility/selection/duplicate behavior;
- Final Create materialization/provenance boundary;
- one bounded Program-owned runtime capability;
- durable Expansion runtime state and Save/Continue behavior;
- model-visible Context boundary;
- exactly one real first Expansion and its product acceptance story.

Only after semantic freeze may GPT issue `G4-08M1` to Codex. If genuine player-facing interaction is required, UI work is split and routed to Kimi rather than hidden inside backend scope.

---

## 4. Frozen G4-07 integration semantics

- one frozen Review create attempt → one stable `creation_id`;
- successful Final Create opens exact existing-only Game;
- accepted Conversation = 0 is legal opening-pending;
- Provider failure/cancel never rolls back created Game;
- Continue returns to same Game and never creates a second accepted first Opening;
- GM-only Opening must not render an empty/fake Player bubble;
- Player continuation uses durable Game-local World truth + accepted Conversation;
- Source v0.2-r2 remains frozen; no latest/nearest/later/full-life fallback;
- Guaranteed NPC = canonical cast only, not automatic opening presence/location/player knowledge/relationship;
- production schema remains v4 until a reviewed future task explicitly changes it.

---

## 5. G4-08 acceptance direction

The first Expansion vertical must eventually prove:

```text
same playable World + Character route
+ exact selected real Expansion
→ Final Create pins/materializes it
→ real Runtime consumes it
→ player can observe a gameplay difference
→ real DeepSeek Context reflects correct Expansion state
→ Save / Continue preserves it
→ no-Expansion route remains unchanged
```

Do not claim G4-08 PASS from schema, manifest, binding, or DB evidence alone.

Do not start G4-09 Owner product vertical until G4-08 mechanism/integration passes Independent Review.
