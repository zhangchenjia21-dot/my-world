# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

For every formal task, resolve current authority from GitHub `main` in this order:

1. User's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` and relevant supporting architecture.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
8. This repository's current implementation/tests/HEAD.

For stage planning, task-order audits, Source/Game Creation design, or future-project reuse, also read:

`Vibe-Coding/my world/experience/AI_RPG开发路径与阶段设计经验_v1.0_2026-08-28.md`.

If a current decision changes stage, task, prerequisite, architecture boundary, owner or Task DAG, perform Decision Propagation before continuing old work. Before authoritative writes/pushes, fetch/re-check HEAD and audit any Task Base → Current HEAD increment. Never overwrite unknown dirty or newer work.

## 2. Documentation shape

Project governance follows **Root is map; subfolders are depth.** Current state stays in the fixed governance status file; repository-native execution packets stay under `docs/tasks/`. Do not create new top-level `*_CURRENT.md` files for every task.

## 3. Current stage

Completed:

- G1 Foundation & Project Bootstrap — **PASS / CLOSED**
- G2 AI Conversation Spine — **PASS / CLOSED**
- G2-GATE — **PASS**
- G3 Persistent Game / Save / Timeline Foundation — **PASS / CLOSED**
- G3-GATE — **PASS**
- G4-01 Application Shell / Main Menu + Game Session Lifecycle — **PASS / CLOSED**

Current phase:

> **G4 — Primary Source Assets & Local Game Creation**

Current task:

> **G4-02 — World Pack + Character Card Source Contracts v0.1**

Current formal Task Packet:

`docs/tasks/G4-02_WORLD_CHARACTER_SOURCE_CONTRACTS_TASK.md`

Implementation owner: **Codex**. Task Packet commit: `60a0139c8e7facc019fc63bd6593ef2000261284`.

Current state: **ISSUED — waiting Codex implementation → READY FOR INDEPENDENT REVIEW**.

All older G4-01 World Pack task packets and Main-Menu-only handoffs remain superseded. Do not revive them.

Do not start G4-03+ until G4-02 is formally closed.

## 4. Current G4 sequence

```text
G4-01 Application Shell / Main Menu + Game Session Lifecycle — CLOSED
→ G4-02 World Pack + Character Card Source Contracts v0.1 — CURRENT
→ G4-03 Managed Local Source Library v0.1
→ G4-04 Multi-Game Lifecycle / Game Library Foundation
→ G4-05 Asset-only New Game Wizard v0.1
→ G4-06 Atomic Final Create + World/Character Materialization
→ G4-07 First Playable A — World + Character Owner UAT
→ G4-08 Expansion Pack v0.1 + First Real Runtime Vertical
→ G4-09 First Playable B — Expansion Owner UAT
→ G4-10 Runtime Asset Resolution
→ G4-11 Two Primary Asset Families Reality Test
→ G4-GATE
```

## 5. First-generation New Game product lock

The first generation supports **one formal asset-driven creation path only**:

```text
Main Menu
→ New Game
→ Exactly 1 World Pack
→ Entry / T0
→ Expansion Pack 0..N, explicit none allowed
→ Exactly 1 Player Character Card
→ 0..N Guaranteed NPC Character Cards
→ minimal settings
→ Compatibility Review
→ Atomic Final Create
```

Minimal settings currently include:

- Game display name;
- Protagonist Control Mode: `Full | Light | Narrative`;
- optional opening supplement.

Do not add in G4:

- no-World creation;
- no-Character local-player fallback;
- AI blank-world direct creation;
- Draft/arbitrary external file direct-to-Game;
- Final Create auto-publish;
- historical Source version picker;
- complex Expansion feature/module chooser;
- Creator product path.

These are deferred product directions, not forgotten requirements.

## 6. Primary Source Trio

First-generation Primary Source Assets:

```text
World Pack
Character Card
Expansion Pack
```

They may share only the minimal identity seam:

```text
asset_id
asset_type
version
exact immutable generation / content fingerprint
```

Do not create a universal giant asset schema merely because the three are Source Assets.

### Character Card

Character Card is reusable Character Source, not a player-only card.

First-generation creation roles:

```text
Exactly 1 Player Character
0..N Guaranteed NPC Characters
```

Guaranteed NPC means the exact selected Character Source is materialized into this Game's canonical cast at Final Create.

It does **not** mean:

```text
opening appearance
same scene
player-known
relationship
automatic current Context inclusion
```

Do not reintroduce `bound_only | opening_character | player_character` as the first-generation player-facing role taxonomy unless a later Owner-approved task explicitly does so.

### Expansion Pack

First generation allows `0..N` Expansion Packs.

G4 sequencing is intentionally staged:

```text
First Playable A: World + Character only
→ Owner UAT
then
Expansion Source + exact binding + real observable Runtime effect
→ First Playable B
→ Owner UAT
```

`manifest/binding exists` is not sufficient proof that an Expansion works.

## 7. Source Library / Game Library / exact generation

Formal boundaries:

```text
Managed Source Library != Game Library
Source stable identity != exact immutable generation
Source Generation != Game-local Reality != Runtime State
```

Existing Game must pin exact immutable Source generation, including visual assets. Source update must not silently change old Game text, portrait, scene, map or Expansion declaration.

Managed Source Library may retain historical generations internally, but first-generation New Game UI defaults to the current installed version and does not expose a historical-version picker.

Drafts or arbitrary mutable external folders are not authoritative Game Source.

## 8. Application / Game Session lifecycle

G4-01 established the formal seam:

```text
Application Lifetime != Game Session Lifetime
```

Accepted behavior:

```text
Application Launch
→ Main Menu READY

Continue
→ open current/selected Game Session
→ enter in-game UI

Return to Main Menu
→ safely stop/cancel Game-owned work
→ close/cleanup Game Session resources
→ Application remains READY
```

Main Menu must not simply cover a Game that was automatically opened at application boot.

Preserve G3 reopen/resume, Save/Load/Recovery, single-writer and corruption-recovery semantics.

## 9. Final Create principles for later G4 tasks

When G4-05/06 arrive, enforce:

> **Chooser/list visibility/mode != authoritative selection.**

Only an explicit click on a concrete Source item selects it.

Final Create must be explicit and replay-safe:

```text
editing composition
→ Compatibility Review
→ Program-derived create identity/fingerprint
→ creating
→ pin exact Source generations
→ materialize/bind
→ created
```

Must handle double-click, response loss, retry and crash without duplicate Games. Same exact create identity may replay same Game; mismatched intent fails closed.

Provider calls during deterministic Final Create should be zero. Real Provider begins at playable Opening/Session, not as a hidden dependency of database creation.

## 10. Core product/runtime invariants

- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- UI projects authoritative game truth; it is not a second durable truth.
- **Model freedom first. Reversibility over prevention.**
- **Narrative richness over artificial brevity.** No arbitrary output-length caps or convenience `max_tokens` limits.
- **Model authors the world; Runtime makes it durable; Player owns the timeline.**
- **Source provides inertia; actors create history.**
- **Off-screen != Inactive.**
- **World Truth != NPC Knowledge != Player Knowledge.**
- **Context stays bounded, not starved.**
- **Vertical before platform. Consumer before creator. Reality gate before abstraction.**

Hard boundaries remain: secrets/OS/filesystem authority, physical save corruption, non-atomic authoritative writes, unsafe concurrent writer ambiguity, arbitrary Mod execution and unrecoverable external side effects.

## 11. Accepted technical / persistence baseline

```text
Host                         Godot 4.7.2
Distribution                 Standard / non-.NET Windows x64
Language                     GDScript
Runtime                      same-process Godot Runtime
Provider                     DeepSeek deepseek-v4-pro
Persistence                  SQLite — ACCEPTED
SQLite binding               2shady4u/godot-sqlite v4.9
Production schema            v4
Current G3 product DB         user://my-world/current-game.sqlite
```

G3 is closed. Do not rewrite G3 persistence merely because G4 needs multiple Games. G4-04 will formally decide the simplest multi-Game physical shape, explicitly checking legacy adoption, single-writer, backup and corruption recovery.

## 12. G4-02 specific boundary

Current G4-02 must establish only World Pack + Character Card v0.1 Source contracts and real contract proof.

World Pack must minimally support:

- stable identity / schema version;
- world / GM instructions;
- ordered Source Lore;
- `0..N` lightweight Entry / T0 seeds;
- authored portrait / scene / map declarations;
- pre-game Source material.

Character Card must minimally support:

- stable/display identity;
- public profile;
- GM/private Source profile;
- portrait reference;
- player-character eligibility.

Character Source must not own live location, current relationship, current injury/condition, current knowledge, current inventory or player-known state.

Exact Source generation must be content-sensitive, including declared visual/file bytes; stable identity/version alone is insufficient.

G4-02 must **not** implement:

- Managed Source Library / install / publish / inventory (G4-03);
- multi-Game storage/library (G4-04);
- real New Game selector/composition (G4-05);
- Final Create/materialization (G4-06);
- Expansion Pack contract/runtime (G4-08);
- Runtime Asset Resolution (G4-10);
- G5 world semantics or G6/G8 declarative UI/Mod platform;
- production SQLite schema changes or Provider calls.

The contract reality check must use real filesystem fixtures through the production loader/validator seam, not only hand-built Dictionaries or docs.

## 13. Evidence / execution discipline

Never claim Windows-local, Godot, filesystem, export or runtime compatibility without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for genuine product UAT, secrets and irreducible product/architecture decisions.

For product-facing stages, automated PASS does not replace Owner UAT. For model-semantic stages, deterministic harness does not replace required real Provider proof. Independent Review must check for vacuous assertions, mock-only paths and proof-only bindings, not merely rerun tests.