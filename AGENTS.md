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
G4-07A Opening Runtime                PASS / CLOSED
G4-07B Playable UI Integration        ACTIVE — KIMI
G4-GATE                               NOT YET
```

G4-07A accepted implementation/evidence:

```text
implementation  dac0e8e4bf655a234ca5b8d0952f6a199373b4af
continuation    221710941950198c4fced9c30991bd295fea39ef
evidence / HEAD fdb6a30ad138c332837f17af1d8c74b5643db44b
```

GPT Independent Review: **PASS**.

Confirmed:

- real Han + Afterglow Provider routes use production G4-06 Final Create and existing-only Game open;
- first Opening Context is projected from durable Game-local `game_local_setup.v0.1`, not Wizard state or mutable Source current;
- G4-07A public seam structurally receives no Source Library;
- early Han Provider context contains selected early semantics and excludes known later/future markers;
- no-Entry remains explicit no-Entry with no runtime default Entry/profile/year;
- Guaranteed NPC material is canonical GM knowledge only and carries an explicit non-convergence directive;
- first Opening is GM-only with no fake Provider-visible Player message;
- Provider failure/cancel leaves zero durable accepted Opening and retries cleanly;
- one successful Opening becomes durable exactly once;
- fresh process reopen restores the exact Opening and rejects a second first Opening;
- continuation context rebuilds from durable Game-local World truth + durable Conversation + the next real Player action;
- production schema remains v4 and frozen full-fidelity fixtures remain unchanged.

Do not reopen G4-07A absent new P0 evidence or a concrete G4-07B integration defect that proves the reviewed backend seam insufficient.

---

## 3. Current execution task

> **G4-07B — Playable UI Integration**

Formal packet:

`docs/tasks/G4-07B_PLAYABLE_UI_INTEGRATION_TASK.md`

Packet commit:

`064ae8b27d2169f8399e81a36a7d7624efe45fdd`

Formal Code Base:

`fdb6a30ad138c332837f17af1d8c74b5643db44b`

Primary execution owner: **Kimi**.  
Semantic + Independent Review owner: **GPT**.  
Parent Product gate: **G4-07 First Playable A — Owner UAT required**.

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Kimi must not declare G4-07 Product PASS.

---

## 4. G4-07B product/application boundary

G4-07B integrates already-reviewed seams:

```text
Main Menu
→ G4-05 Wizard / Review
→ G4-06 Atomic Final Create
→ exact existing-only Game open
→ G4-07A first GM Opening
→ Narrative UI streaming
→ first real Player action / continuation
→ Save / exit / reopen / Continue
```

The backend semantics are already owned by G4-06/G4-07A. This task owns frontend/application state, presentation, retry/navigation behavior and Windows interaction quality.

Expected production scope is primarily:

- `src/应用壳.gd`
- `src/main.tscn`
- `src/ui/**`
- narrow application-facing presentation/glue only where necessary

Protected backend modules should remain unchanged. If integration proves a backend seam is missing, return `BLOCKED` rather than redesigning backend code inside the Kimi task.

---

## 5. Frozen create/opening integration semantics

Do not regress:

### Final Create attempt identity

- one frozen Review create attempt gets one fixed `creation_id`;
- retry/repeated click for that same attempt reuses it;
- creating UI must debounce/disable duplicate submit;
- materially edited/re-reviewed Composition before successful create starts a new attempt identity;
- after successful create the Wizard cannot create a second Game from the same completed Review.

### Created Game is durable before Opening

Provider failure/cancel does not roll back a successfully created Game.

A valid Game with accepted Conversation = 0 is an `opening-pending` Game. It must be recoverable through Continue without creating another Game.

### Existing-only open

After create, and on Continue, use existing-only Game/session open. Missing/corrupt/wrong state fails loud; never silently mint a replacement Game.

### First Opening exactly once

- accepted Conversation = 0 + valid setup → eligible for first Opening;
- accepted Conversation >= 1 → do not generate another first Opening;
- failure/cancel leaves zero accepted and permits retry on the same created Game.

### GM-only Opening presentation

The v4 empty `player_text` compatibility slot is not a Player utterance. Narrative UI must not render an empty/fake Player bubble for the Opening.

### Durable continuation

Normal Player actions after Opening must use the reviewed G4-07A continuation context assembled from durable Game-local World truth + accepted Conversation. Never rebuild from Wizard or mutable Source current.

---

## 6. Source / temporal truth remains frozen

Current Source contract is v0.2-r2. Game-local materialization from G4-06 is runtime truth.

```text
selected Entry
→ World top-level + exact Entry
→ Character top-level + exact matching profile when authored

no Entry
→ World top-level only
→ Character top-level only
```

Never fallback latest/nearest/later/full-life. Never infer hidden historical mode.

Newer Source current generations cannot rewrite an existing created Game.

Guaranteed NPC = canonical cast member only, not opening presence/location/player-known/relationship.

---

## 7. G4-07 execution decomposition

```text
G4-07A Codex
backend/runtime/context/provider Opening vertical
PASS / CLOSED
↓
G4-07B Kimi
Wizard Final Create → playable Narrative UI integration
ACTIVE
↓ GPT Independent Review
G4-07 Owner UAT
real Han + Afterglow play, narrative richness, individuality, anti-convergence, Context sufficiency
```

Engineering PASS for G4-07B cannot substitute for Owner Product PASS.

---

## 8. No scope leakage

G4-07B must not:

- redesign Source contracts or frozen fixtures;
- redesign G4-06 creation protocol;
- redesign G4-07A Provider/context/durability ownership;
- add Expansion;
- start G5 Living World broad architecture;
- start G7 long-session retrieval/summarization platform;
- hardcode family-specific narrative scripts;
- expose API keys or auth data in UI/evidence;
- declare Product PASS.

Production SQLite schema remains v4 unless a separately routed backend task returns `BLOCKED` before migration.

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

Routine implementation/test/evidence belongs to execution agents. Owner handles irreducible product judgment and G4-07 UAT.
