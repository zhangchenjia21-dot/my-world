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

G3 closeout line:

```text
7e2e622f03782a1d66f5f8837d739f900615b775  G3-06 crash / interrupted-write recovery
4529338728e7db91a2ce73b4dc8eec21c5530d0e  G3-07 persistence reality test + central recovery action
dbc6167598ecbde3578778e638e2494bffc48244  G3-07 IR-01 real Provider B-marker evidence repair
```

Current phase:

> **G4 — World Pack & Local Content Foundation**

Current task:

> **G4-01 — Product Entry Shell / Main Menu**

The previous `docs/tasks/G4-01_WORLD_PACK_V0_1_TASK.md` was superseded **before execution** by the Owner-approved G4 route revision. Do not execute it. World Pack Source work is now G4-02.

Recommended implementation owner for current G4-01: **KimiCode K3**, because the work is Godot UI + Windows local lifecycle/navigation. Grok Build remains suitable for G4-02 Source contract/cross-module semantics. Agent choice never lowers acceptance standards.

## 4. Current G4 sequence

```text
G4-01 Product Entry Shell / Main Menu
→ G4-02 World Pack Source v0.1 + Contract Reality Check
→ G4-03 Game Creation Composition v0.1 + New Game Flow
→ G4-04 Source → Game-local Instance
→ G4-05 Local Pack Library + Minimal Game Library
→ G4-06 Asset Resolution
→ G4-07 Two-Pack Playable Reality Test
→ G4-GATE
```

Do not start G4-02+ until the current G4-01 task is formally issued and closed through its required review/UAT path.

## 5. Core product/runtime invariants

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

Hard boundaries remain: secrets/OS/filesystem authority, physical save corruption, non-atomic authoritative writes, unsafe concurrent writer ambiguity, arbitrary Mod execution and unrecoverable external side effects.

## 6. Accepted technical / persistence baseline

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

G3 is closed. Established production capabilities include atomic durable mutation, accepted Conversation durability, reopen/resume, named Save, atomic Load/Restore, future-memory isolation, Recovery Checkpoints, single-writer process safety, SQLite-native verified backup and staged physical-corruption recovery.

Do not rewrite G3 persistence merely because G4 eventually needs multiple Games. G4-05 will decide the simplest multi-Game physical storage/lifecycle shape when there is a real product consumer.

## 7. G4 canonical Source / Composition boundary

```text
Reusable World Pack Source Generation
+ Game Creation Composition
↓ new-game materialization
Game-local Canonical Reality
↓ Runtime
Current World State
```

Formal rule:

> **World Pack Source != Game Creation Composition != Game-local Reality != Runtime State.**

Source generation must ultimately be identifiable by stable pack identity + author version + exact fingerprint/generation. Source updates may not silently rewrite existing Games.

Runtime-generated NPC / Place / Item may have only game-local stable identity and `runtime_generated` provenance. A Source character existing/materializing does not automatically mean the player knows that character.

## 8. G4-01 specific boundary — Product Entry Shell / Main Menu

G4-01 exists because Pack choice / New Game / multi-Game need a stable product entry surface. Do not build a disposable Pack selector first.

First-generation desired flow:

```text
Application Launch
→ Main Menu
├─ Continue current Game
├─ New Game → stable creation surface/host
└─ Quit
```

Also provide safe in-game return to Main Menu and re-entry via Continue.

G4-01 must preserve:

- existing G3 reopen/resume truth;
- current Game persistence and Save/Load/Recovery behavior;
- startup physical-corruption / safe-backup recovery discoverability;
- single-writer discipline and graceful cleanup;
- in-game `Player Host | Narrative Host | World Surface Host` behavior;
- Windows maximized / 1280×720 / 960×540 usability.

G4-01 must **not** implement:

- World Pack Source contract/loader (G4-02);
- real Pack discovery/selection (G4-03/G4-05);
- multi-Game storage migration/library (G4-05);
- Asset Resolution (G4-06);
- G5 world semantics or G6 declarative UI platform;
- Settings framework, account, cloud, store or online services.

The New Game surface may initially be a real stable product host with later content wiring, not a fake second product or task-only popup.

## 9. UI architecture

Application-level surfaces:

```text
Main Menu
New Game flow
Continue / Game Library (later G4)
```

In-game surface remains:

```text
Player Host | Narrative Host | World Surface Host
```

Main Menu owns navigation/lifecycle intent only. It must not hold a second copy of Game/Save/Pack truth.

## 10. Evidence / execution discipline

Never claim Windows-local, Godot, filesystem, export or runtime compatibility without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for genuine product UAT, secrets and irreducible product/architecture decisions.
