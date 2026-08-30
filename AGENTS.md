# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve current authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and current formal Task Packet.
6. verifiable implementation/tests/current HEAD.

Before authoritative work, refresh `main`; never overwrite unknown dirty/newer work.

Execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
```

Task fit comes before quota availability.

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
G4-07 First Playable A                ACTIVE — OWNER UAT GATE
G4-07A Opening Runtime                ACTIVE — CODEX
G4-07B Playable UI Integration        HOLD — KIMI AFTER G4-07A
G4-GATE                               NOT YET
```

G4-06 accepted implementation/evidence:

```text
implementation 1457ca18c4ef19fd5757844820630649ea85fe6b
evidence       383481631cd3de3c4b9fd2cc47eef911961d8373
IR01 process   39d7300790b2b067b12630f4d1efd4fd51b6d126
```

GPT Independent Review: **PASS**.

IR01 proved actual distinct Godot/OS process restart convergence across:

- after intent publish;
- after DB commit;
- after Game Library record publish;
- after current publish.

No production code/schema change was needed for IR01.

---

## 3. Current execution task

> **G4-07A — First Playable Opening Runtime**

Formal packet:

`docs/tasks/G4-07A_FIRST_PLAYABLE_OPENING_RUNTIME_TASK.md`

Packet commit:

`8d3bc6e7557c9687141e02a5e554ee90959c2a68`

Formal Code Base:

`39d7300790b2b067b12630f4d1efd4fd51b6d126`

Primary execution owner: **Codex**.  
Semantic + Independent Review owner: **GPT**.  
Parent Product gate: **G4-07 First Playable A — Owner UAT required**.

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Codex must not declare G4-07 Product PASS.

---

## 4. G4-07A product/runtime boundary

G4-06 terminal state was `created`.

G4-07A must prove:

```text
created durable Game
→ existing-only open
→ durable Game-local setup/current truth
→ bounded-but-rich Opening Context
→ real DeepSeek GM Opening
→ accepted Conversation durable exactly once
→ close / reopen same Game
→ continue from durable history
```

The first AI Opening must come from the **durable Game**, not from Wizard memory and not from mutable Source current.

Do not re-materialize Source after create just to build runtime context.

---

## 5. Source / temporal truth remains frozen

Current Source contract is v0.2-r2:

```text
thin identity/catalog metadata
+ ordered rich semantic_sections
+ disclosure = gm_reference | gm_private
+ package-local UTF-8 Markdown/TXT
+ optional Entry-scoped World semantics
+ optional Character T0 profiles
+ exact immutable fingerprint over every declared byte
```

Temporal quarantine is optional authored capability.

For G4-06-created Game truth:

```text
selected Entry
→ World top-level + exact Entry
→ Character top-level + exact matching profile when authored

no Entry
→ World top-level only
→ Character top-level only
```

Never fallback latest/nearest/later/full-life. Never infer hidden historical mode.

The Game-local materialized projection is now runtime truth; newer Source current generations cannot rewrite it.

---

## 6. G4-06 frozen creation guarantees

Do not regress:

- One Game = One SQLite;
- immutable creating intent precedes Game DB side effects;
- one `creation_id` + same payload converges to one fixed Game/local identities;
- same `creation_id` + altered payload conflicts;
- exact Source pins survive current-generation drift;
- DB identity is verified before Game Library registration;
- valid DB is repaired forward, never destructively rolled back because later metadata publication failed;
- Source asset IDs are provenance, not Game-local identity;
- Guaranteed NPC is canonical cast only, not opening presence/location/player-known/relationship;
- production SQLite schema remains v4 unless a task explicitly returns `BLOCKED` before migration.

---

## 7. G4-07A constraints

G4-07A must reuse existing G2/G3 ownership:

- existing Provider adapter/streaming/cancel/failure behavior;
- existing Conversation domain/durability;
- existing Persistence/session lifecycle;
- existing Context Assembly ownership, extended narrowly where required by the created Game setup envelope.

Do not build a second Provider stack, second transcript store, universal Living World ontology, G7 context platform, Expansion, map/travel system, or G4-07B UI.

First Opening must not invent a synthetic persisted Player action merely to trigger the GM.

Once an accepted Opening is durable, reopen must not auto-generate a second first Opening.

Provider failure/cancel before acceptance must leave zero accepted Opening and allow clean retry.

---

## 8. G4-07 execution decomposition

```text
G4-07A Codex
backend/runtime/context/provider Opening vertical
↓ GPT Independent Review
G4-07B Kimi
Wizard Final Create → playable Narrative UI integration
↓ GPT Independent Review
G4-07 Owner UAT
real Han + Afterglow play, narrative richness, individuality, anti-convergence, Context sufficiency
```

Engineering PASS for A/B cannot substitute for Owner Product PASS.

---

## 9. Technical baseline

```text
Host              Godot 4.7.2 Standard / non-.NET Windows x64
Language          GDScript
Runtime           same-process Godot Runtime
Provider          DeepSeek deepseek-v4-pro
Persistence       SQLite via godot-sqlite v4.9
Production schema v4
Game topology     One Game = One SQLite
Source Library    managed immutable filesystem generations
```

Routine Git/Godot/build/test/failure-injection work belongs to execution agents. Owner handles irreducible product judgment and G4-07 UAT.
