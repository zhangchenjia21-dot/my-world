# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and the current task/UAT packet.
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
G4-07 First Playable A                READY FOR OWNER UAT
G4-07A Opening Runtime                PASS / CLOSED
G4-07B Playable UI Integration        PASS / CLOSED
G4-GATE                               NOT YET
```

G4-07B accepted implementation/evidence:

```text
implementation  e13099384c12090197822d1d504089decc1f893b
evidence / HEAD 2f45614baa0a3c38dac3439934122084817d4602
GPT IR record   docs/g4_07b/G4-07B_INDEPENDENT_REVIEW.md
```

GPT Independent Review: **PASS**.

Confirmed:

- production changes stayed inside application/UI scope;
- one frozen Review attempt owns one stable `creation_id`; duplicate submit/retry cannot mint a second Game for the same attempt;
- Final Create success opens the exact registered Game through existing-only semantics;
- a created Game with accepted Conversation = 0 is a legal opening-pending state;
- Opening failure/cancel preserves the Game and retries on the same Game;
- exit after create but before accepted Opening returns through Continue to the same Game;
- GM-only Opening renders without an empty/fake Player bubble;
- accepted Opening is not generated twice after Continue;
- normal Player continuation uses G4-07A durable Game-local World + Conversation context;
- Save / Main Menu / Continue restores the same Game and history;
- Han and Afterglow real DeepSeek UI verticals pass through the same family-agnostic application path;
- no-Entry remains explicit;
- 1280×720 / 960×540 / maximized layout evidence passes;
- production SQLite schema remains v4; frozen fixtures and protected backend modules are unchanged.

Do not reopen G4-07A or G4-07B absent new P0 evidence or Owner UAT evidence proving a concrete defect.

---

## 3. Current gate — G4-07 First Playable A Owner UAT

Current UAT packet:

`docs/tasks/G4-07_FIRST_PLAYABLE_A_OWNER_UAT.md`

Execution owner: **Owner / User**.  
Semantic/Product decision owner after UAT: **GPT**.

No Codex/Kimi implementation task is active right now.

Required product route:

```text
real Source
→ New Game Wizard / Review
→ Atomic Final Create
→ real DeepSeek GM Opening
→ several free-form Player actions
→ durable GM continuation
→ Save
→ Main Menu / reopen
→ Continue same Game
```

Owner UAT judges what engineering evidence cannot:

- Narrative richness;
- Character individuality;
- Han vs Afterglow distinctness;
- anti-convergence of Guaranteed NPCs;
- Context sufficiency / immediate continuity;
- temporal/future leakage in early Han;
- whether the interface feels like playing an AI RPG rather than operating an engineering demo.

Engineering PASS does not close G4-07.

---

## 4. Frozen integration semantics

### Game creation

- one frozen Review create attempt → one stable `creation_id`;
- same attempt retry/double-submit converges to one Game;
- materially edited Review before successful create → new attempt identity;
- successful create ends the Wizard create path.

### Created Game / Opening

- created Game exists independently before AI Opening acceptance;
- accepted Conversation = 0 is legal opening-pending;
- Provider failure/cancel never rolls back Game creation;
- Continue returns to the same Game and retries Opening;
- accepted first Opening exists exactly once.

### GM-only Opening

The v4 empty Player compatibility slot is not Player speech and must not render as an empty/fake Player bubble.

### Durable continuation

After Opening, Player actions use the reviewed G4-07A durable continuation context from Game-local World truth + accepted Conversation. Never reconstruct runtime semantics from Wizard memory or mutable Source current.

### Source / temporal truth

Source v0.2-r2 remains frozen. G4-06 Game-local materialization is runtime truth.

```text
selected Entry
→ World top-level + exact Entry
→ Character top-level + exact matching profile when authored

no Entry
→ World top-level only
→ Character top-level only
```

Never fallback latest/nearest/later/full-life. Never infer hidden historical mode.

Guaranteed NPC = canonical cast member only, not automatic opening presence/location/player-known/relationship.

---

## 5. Next decision

After Owner UAT, GPT must decide exactly one:

```text
G4-07 PASS / CLOSED
```

or

```text
G4-07 Product Correction ACTIVE
```

If correction is required, shape the smallest evidence-driven forward task and route it by ownership. Do not reopen closed engineering work generically.

Do **not** start G4-08 Expansion before G4-07 Product PASS.

---

## 6. Technical baseline

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
