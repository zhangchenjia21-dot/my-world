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
- G4-04 Multi-Game Lifecycle / Game Library Foundation — **PASS / CLOSED**

Current phase:

> **G4 — Primary Source Assets & Local Game Creation**

Current task:

> **G4-05 — Asset-only New Game Wizard v0.1 — REWORK**

Original Task Packet:

`docs/tasks/G4-05_ASSET_ONLY_NEW_GAME_WIZARD_TASK.md`

Active correction packet:

`docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md`

Implementation owner: **Codex**. Current correction base: `145c3e1192b443f6284da7f36aee74619adad5bf`.

Current state: **INDEPENDENT REVIEW REWORK — P1 historical real-asset fidelity; waiting G4-05R1 correction → READY FOR INDEPENDENT REVIEW**.

Do not start G4-06+ until G4-05 is formally closed.

## 4. Current G4 sequence

```text
G4-01 Application Shell / Main Menu + Game Session Lifecycle — CLOSED
→ G4-02 World Pack + Character Card Source Contracts v0.1 — CLOSED
→ G4-03 Managed Local Source Library v0.1 — CLOSED
→ G4-04 Multi-Game Lifecycle / Game Library Foundation — CLOSED
→ G4-05 Asset-only New Game Wizard v0.1 — REWORK / G4-05R1 ACTIVE
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
→ Entry / T0: 0..1 from chosen World
→ Expansion Pack 0..N, explicit none allowed
→ Exactly 1 Player Character Card
→ 0..N Guaranteed NPC Character Cards
→ Game display name
→ Protagonist Control Mode: Full | Light | Narrative
→ optional opening supplement
→ Compatibility Review
→ Atomic Final Create (G4-06)
```

Do not add in G4:

- no-World creation;
- no-Character local-player fallback;
- AI blank-world direct creation;
- Draft/arbitrary external file direct-to-Game;
- Final Create auto-publish;
- historical Source version picker;
- complex Expansion feature/module chooser;
- Creator product path.

Selection authority is frozen:

> **Chooser/list visibility/mode != authoritative selection. Only explicit click on a concrete Source item selects its exact generation.**

## 6. Primary Source / Composition boundaries

Formal boundaries:

```text
Managed Source Library != Game Library
Source stable identity != exact immutable generation
Source Generation != Game Creation Composition != Game-local Reality != Runtime State
Game Library metadata != gameplay truth
```

Character Card is reusable Character Source, not player-only. First-generation creation roles are exactly one Player Character plus 0..N Guaranteed NPC Characters. Guaranteed NPC does not imply opening appearance, same scene, player-known state, relationship, or automatic Context inclusion.

Existing Game must pin exact immutable Source generation. Source update must not silently change old Game content. Managed Source Library can retain historical generations internally, but first-generation UI does not expose a historical-version picker.

## 7. Application / Game Session / Game Library lifecycle

G4-01 established:

```text
Application Lifetime != Game Session Lifetime
```

G4-04 established:

> **One Game = One SQLite database.**

New managed Game target path:

```text
user://my-world/games/<game_id>/game.sqlite
```

Legacy G3 DB remains:

```text
user://my-world/current-game.sqlite
```

and is adopted in place.

Continue/Select resolves an existing Game record/path, opens one Runtime, cross-checks database internal `game_id`, and only then commits current selection. Missing DB never creates a replacement Game. Switch ordering is close/release A before open B.

G4-05 must preserve all of this. Entering New Game must not open or create a Game Session/SQLite.

## 8. G4-05 specific boundary

Current G4-05 must establish only:

```text
Managed Source Library current inventory
→ explicit exact Source selection
→ Application-owned Game Creation Composition
→ deterministic Compatibility Review
```

Required semantics:

- World: exactly 1 exact generation;
- Entry: 0..1 and belongs to selected exact World; changing World clears Entry;
- Expansion: honest empty set in this vertical; do not implement Expansion contract/runtime;
- Player Character: exactly 1 and `player_character_supported == true`;
- Guaranteed NPC: 0..N exact Character generations;
- same exact Character generation cannot be both Player and Guaranteed NPC;
- Game display name required;
- control mode `Full | Light | Narrative`, default `Light`;
- optional opening supplement;
- review re-resolves exact managed generations and fails loud on missing/tamper;
- selecting generation X then installing generation Y as current must not silently drift Composition from X to Y;
- no implicit first-row/default-list selection;
- back/cancel semantics must be deterministic and clean.

G4-05 must **not** implement:

- new Game SQLite creation;
- Game Library record/current mutation from Wizard;
- Source pin/materialization;
- G4-06 Atomic Final Create;
- Provider calls / AI compatibility scoring;
- Expansion Pack contract/runtime;
- Runtime Asset Resolution/cache;
- generic legacy importer;
- generic Wizard/form framework;
- Creator/publishing UI;
- production SQLite schema changes.

## 9. Historical real-asset reality policy

Synthetic compact fixtures remain valid for deterministic contract/failure tests, but they are not sufficient as the only reality evidence.

G4-05 historical evidence is pinned to:

```text
repo: zhangchenjia21-dot/sillytavern-assets
snapshot: 4a5364a042e41f4c8a69621fc4467956a78703c0
```

Primary real families:

```text
汉末三国_天下未定
+ 人物卡/汉末三国/...

埃瑟维亚_诸界余辉
+ 人物卡/诸界余辉/...
```

Historical files are read-only semantic pressure sources. Repackage their real content through the current G4-02 Source contract and G4-03 Managed Library. Do not import old schema/storage conventions into production.

Principle:

> **Migrate real content/complexity, not legacy schema debt.**

### G4-05R1 Independent Review correction

The `145c3e1` Wizard/Composition implementation passed the reviewed identity/selection/no-side-effect boundaries, but the historical conversion packages were **too aggressively summarized**. Load/install success alone is not real-content pressure.

G4-05R1 must therefore preserve substantive GM-useful content at section/category level:

- World: real world operation/T0/history/social/institutional/geographic/material/knowledge/GM-use semantics where owned by World Source;
- Character: identity, personality contradictions, abilities/limitations, behavior logic, relationship/autonomy, language/expression, knowledge boundary, T0/historical-use guidance, and other stable authored semantics;
- dynamic live state remains prohibited;
- use current v0.1 fields faithfully first; if an important stable Source concept genuinely cannot be expressed, return `BLOCKED` with the minimal contract gap rather than summarizing it away or inventing a generic legacy schema.

The correction must include section-level mapping/omission audit and source-derived fidelity evidence. Do not treat package count, text length, or parser success as sufficient fidelity proof.

G4-07 First Playable A must primarily use real, product-valuable World/Character assets rather than only Agent-authored compact fixtures.

## 10. Final Create principles for later G4 tasks

G4-06 will own the explicit replay-safe Final Create transaction:

```text
exact Composition
→ Program-derived create identity/fingerprint
→ creating
→ independent per-Game SQLite
→ exact Source pins
→ World/Character materialization
→ created
```

Provider calls during deterministic Final Create are zero. Do not move any of this into G4-05/G4-05R1.

## 11. Core product/runtime invariants

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

## 12. Accepted technical baseline

```text
Host                         Godot 4.7.2
Distribution                 Standard / non-.NET Windows x64
Language                     GDScript
Runtime                      same-process Godot Runtime
Provider                     DeepSeek deepseek-v4-pro
Persistence                  SQLite — ACCEPTED
SQLite binding               2shady4u/godot-sqlite v4.9
Production schema            v4
G4 topology                  One Game = One SQLite
Source Library               managed immutable filesystem generations
```

## 13. Evidence / execution discipline

Never claim Windows-local, Godot, filesystem, export or runtime compatibility without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for genuine product UAT, secrets and irreducible product/architecture decisions.

G4-05 is product-facing, so implementation/review must include real GUI/value evidence, but the planned end-to-end Owner UAT remains G4-07 after G4-06 makes the flow actually create/play a Game. Independent Review must check for vacuous assertions, mock-only paths, synthetic-only reality, implicit-selection bugs and proof-only bindings, not merely rerun tests.
