# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and the current UAT packet.
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
G4-07 First Playable A                OWNER UAT ACTIVE
G4-07A Opening Runtime                PASS / CLOSED
G4-07B Playable UI Integration        PASS / CLOSED
G4-07UAT01 Owner Launch Freshness     PASS / CLOSED
G4-GATE                               NOT YET
```

G4-07UAT01 accepted implementation/evidence:

```text
implementation/evidence a250c60fa13043ed129dc68ed69048fea6abad5d
GPT IR record           docs/g4_07uat01/G4-07UAT01_INDEPENDENT_REVIEW.md
```

GPT Independent Review: **PASS / CLOSED**.

Canonical `run-game.cmd` now validates current-checkout Windows export freshness, rebuilds missing/stale export, fails loud on export failure, and never falls back to a stale executable.

---

## 3. Current gate — G4-07 Owner UAT

Formal UAT packet:

`docs/tasks/G4-07_FIRST_PLAYABLE_A_OWNER_UAT.md`

Execution owner: **Owner / User**.  
Semantic/Product decision owner after UAT: **GPT**.

No Codex/Kimi implementation task is active.

Immediate local-data precondition:

- normal `run-game.cmd` launch reaches current seven-step New Game Wizard;
- Owner production Source Library shows World `天下未定` and `埃瑟维亚`.

If Source inventory is empty, treat it as Owner-local Source installation/bootstrap, not a reason to reopen G4-07A/B/UAT01.

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

Owner judges narrative richness, Character individuality, Han vs Afterglow distinctness, anti-convergence, Context sufficiency, temporal leakage, no-Entry playability, and whether the product feels like an AI RPG rather than an engineering demo.

Engineering PASS does not close G4-07.

---

## 4. Frozen integration semantics

- one frozen Review create attempt → one stable `creation_id`;
- successful Final Create opens exact existing-only Game;
- accepted Conversation = 0 is legal opening-pending;
- Provider failure/cancel never rolls back created Game;
- Continue returns to same Game and never creates a second accepted first Opening;
- GM-only Opening must not render an empty/fake Player bubble;
- Player continuation uses durable Game-local World truth + accepted Conversation;
- Source v0.2-r2 remains frozen; no latest/nearest/later/full-life fallback;
- Guaranteed NPC = canonical cast only, not automatic opening presence/location/player knowledge/relationship;
- production schema remains v4.

---

## 5. Next decision

After Owner UAT, GPT decides exactly one:

```text
G4-07 PASS / CLOSED
```

or

```text
G4-07 Product Correction ACTIVE
```

Do not start G4-08 Expansion before G4-07 Product PASS.
