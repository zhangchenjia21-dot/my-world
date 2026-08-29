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
- G4-02 World Pack + Character Card Source Contracts v0.1 — **PASS / CLOSED**
- G4-03 Managed Local Source Library v0.1 — **PASS / CLOSED**

Current phase:

> **G4 — Primary Source Assets & Local Game Creation**

Current task:

> **G4-04 — Multi-Game Lifecycle / Game Library Foundation**

Current formal Task Packet:

`docs/tasks/G4-04_MULTI_GAME_GAME_LIBRARY_FOUNDATION_TASK.md`

Implementation owner: **Codex**. Task Packet commit: `5c5ae75a4010a3b0b420e0a8aa2f89cb43b68d0e`.

Current state: **ISSUED — waiting Codex implementation → READY FOR INDEPENDENT REVIEW**.

G4-04 storage topology is already frozen by current supporting architecture:

`Vibe-Coding/my world/architecture/persistence/G4-04_MULTI_GAME_STORAGE_TOPOLOGY_DECISION.md`

> **One Game = One SQLite database.**

Do not reopen shared SQLite + `game_id` inside implementation.

Do not start G4-05+ until G4-04 closes.

## 4. Current G4 sequence

```text
G4-01 Application Shell / Main Menu + Game Session Lifecycle — CLOSED
→ G4-02 World Pack + Character Card Source Contracts v0.1 — CLOSED
→ G4-03 Managed Local Source Library v0.1 — CLOSED
→ G4-04 Multi-Game Lifecycle / Game Library Foundation — CURRENT
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

Character Card is reusable Character Source, not player-only. First-generation creation roles are exactly one Player Character plus 0..N Guaranteed NPC Characters. Guaranteed NPC does not imply opening appearance, same scene, player-known state, relationship, or automatic Context inclusion.

Expansion first-generation count is `0..N`; binding alone is not proof of gameplay effect.

## 7. Source Library / Game Library / exact generation

Formal boundaries:

```text
Managed Source Library != Game Library
Source stable identity != exact immutable generation
Source Generation != Game-local Reality != Runtime State
Game Library metadata != gameplay truth
```

Existing Game must pin exact immutable Source generation, including visual assets. Source update must not silently change old Game text, portrait, scene, map or Expansion declaration.

Managed Source Library may retain historical generations internally, but first-generation New Game UI defaults to the current installed version and does not expose a historical-version picker.

Drafts or arbitrary mutable external folders are not authoritative Game Source.

## 8. Application / Game Session lifecycle

G4-01 established:

```text
Application Lifetime != Game Session Lifetime
```

Accepted behavior:

```text
Application Launch
→ Main Menu READY

Continue / Select Game
→ resolve exact existing Game
→ open one Game Session
→ enter in-game UI

Return to Main Menu
→ safely stop/cancel Game-owned work
→ close/cleanup Game Session resources
→ Application remains READY
```

Main Menu must not simply cover a Game that was automatically opened at application boot.

Preserve G3 reopen/resume, Save/Load/Recovery, single-writer and corruption-recovery semantics.

## 9. G4-04 physical topology and ownership

Current canonical decision:

> **One Game = One SQLite database.**

New managed Game target shape:

```text
user://my-world/games/<game_id>/game.sqlite
```

Existing G3 legacy:

```text
user://my-world/current-game.sqlite
```

must be adopted **in place** by default; do not destructively relocate it just to normalize directories.

Game Library may own Application-level durable records/current selection, but must never own World/Timeline/Save/Conversation truth. On open, Game Library record `game_id` must be cross-checked against the database/runtime internal Game identity.

Continue/Select/Switch must never create a replacement Game when a record DB is missing. Formal creation belongs to G4-06.

Inside one Application, switch ordering is always close current Session completely before opening another writable Game Session.

No production SQLite schema migration is authorized by G4-04.

## 10. Final Create principles for later G4 tasks

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

## 11. Real-asset reality policy

Synthetic compact fixtures remain valid for deterministic contract/failure testing, but they are not sufficient as the only long-term reality evidence.

G4-04 does not create new Source fixtures because Source content is not its variable.

From G4-05/06 onward, historical real asset content should be re-packaged through the new current Source contract instead of importing old schema debt. G4-07 First Playable A must primarily use real, product-valuable World/Character assets rather than only Agent-authored compact fixtures.

Principle:

> **Migrate real content/complexity, not legacy schema debt.**

## 12. Core product/runtime invariants

- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- UI projects authoritative game truth; it is not a second durable truth.
- **Model freedom first. Reversibility over prevention.**
- **Narrative richness over artificial brevity.**
- **Model authors the world; Runtime makes it durable; Player owns the timeline.**
- **Source provides inertia; actors create history.**
- **Off-screen != Inactive.**
- **World Truth != NPC Knowledge != Player Knowledge.**
- **Context stays bounded, not starved.**
- **Vertical before platform. Consumer before creator. Reality gate before abstraction.**

Hard boundaries remain: secrets/OS/filesystem authority, physical save corruption, non-atomic authoritative writes, unsafe concurrent writer ambiguity, arbitrary Mod execution and unrecoverable external side effects.

## 13. Accepted technical / persistence baseline

```text
Host                         Godot 4.7.2
Distribution                 Standard / non-.NET Windows x64
Language                     GDScript
Runtime                      same-process Godot Runtime
Provider                     DeepSeek deepseek-v4-pro
Persistence                  SQLite — ACCEPTED
SQLite binding               2shady4u/godot-sqlite v4.9
Production schema            v4
Legacy G3 product DB         user://my-world/current-game.sqlite
G4 first-generation topology One Game = One SQLite
```

Do not rewrite G3 persistence merely because G4 needs multiple Games.

## 14. G4-04 specific boundary

Current G4-04 must establish only Multi-Game / Game Library foundation over the accepted G3/G4-01 lifecycle.

Required semantics include:

- two independent Games can coexist without overwrite;
- current/latest selection is explicit durable Application state, not mtime/directory guessing;
- Continue resolves an existing Game record/path;
- missing DB never mints a replacement Game;
- record identity mismatches DB identity → fail-loud and close Runtime;
- legacy G3 Game adoption is non-destructive;
- per-Game writer/backup/recovery isolation remains true;
- restart restores Game Library metadata without opening every Game DB merely to show Main Menu;
- one Application has at most one writable Game Session at a time;
- Game Library metadata changes use crash-safe publication semantics;
- automated tests use task-owned DB/library roots only.

G4-04 must **not** implement:

- shared multi-tenant SQLite;
- production SQLite schema migration;
- Source chooser/composition/New Game Wizard (G4-05);
- Atomic Final Create/materialization (G4-06);
- Source pin registry;
- Expansion Pack;
- Runtime Asset Resolution;
- G5 world semantics;
- account/cloud/store/network/multiplayer;
- generic DB service/repository framework.

## 15. Evidence / execution discipline

Never claim Windows-local, Godot, filesystem, export or runtime compatibility without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for genuine product UAT, secrets and irreducible product/architecture decisions.

For product-facing stages, automated PASS does not replace Owner UAT. For model-semantic stages, deterministic harness does not replace required real Provider proof. Independent Review must check for vacuous assertions, mock-only paths and proof-only bindings, not merely rerun tests.
