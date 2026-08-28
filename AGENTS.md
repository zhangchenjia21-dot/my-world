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
- G3-01 Persistence Domain Architecture — **PASS — Independent Review**
- G3-02 Durable World Mutation Path — **PASS — Independent Review**
- G3-03 Game Reopen / Resume — **PASS — Owner UAT**
- G3-04 Explicit Save / Load / Restore + Context Rebuild — **PASS — Owner UAT**
- G3-05 Recovery / Timeline Foundation — **PASS — Owner UAT**
- G3-06 Crash / Interrupted Write Recovery — **PASS — Owner UAT**

G3 implementation line:

```text
1fc1cba76ade63a05e4b7ba9009264696ad45b1a  G3-01 SQLite route
bda2a8877297c51365cd6581536875b68c81cb85  G3-02 durable World mutation
ee768ca6ec8abdb2d65c994da4e7287886153bff  G3-02 IR-01 query failure repair
929f4ff1e1253a808522d8f559a3cadd01b8d5db  G3-03 current Game resume
618fa0f2238114cbe4fc0fe790a1d60c43e99b45  G3-04 Save / Load / Restore + Context rebuild
bf8c35fdf76c4ea3b8ad2560d93c89c2f84c07b0  G3-05 Recovery / Timeline Foundation
7e2e622f03782a1d66f5f8837d739f900615b775  G3-06 crash / interrupted-write recovery
```

Current phase:

> **G3 — Persistent Game / Save / Timeline Foundation**

Current task:

> **G3-07 — Persistence Reality Test**

G3-GATE and G4 are not authorized until G3-07 Engineering + Independent Review + Owner UAT closes.

Current execution owner for G3-07: **KimiCode K3**. User explicitly authorized KimiCode or Grok Build because the current Codex 5-hour quota is exhausted. Do not silently switch acceptance standards because the implementation agent changes.

## 4. Core product/runtime invariants

- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- UI projects authoritative game truth; it is not a second durable truth.
- **Model freedom first. Reversibility over prevention.**
- **Narrative richness over artificial brevity.** No arbitrary output-length caps or convenience `max_tokens` limits.
- **Model authors the world; Runtime makes it durable; Player owns the timeline.**
- **Reversibility != frictionless arbitrary rewind.**
- **Save Point != Timeline Node.**
- **Recovery Checkpoint != Save Point.**
- **Physical Backup != Save Point / Recovery Checkpoint.**
- **Source provides inertia; actors create history.**
- **Off-screen != Inactive.**
- **World Truth != NPC Knowledge != Player Knowledge.**
- **Context stays bounded, not starved.**

Hard boundaries remain: secrets/OS/filesystem authority, physical save corruption, non-atomic authoritative writes, unsafe concurrent writer ambiguity, arbitrary Mod execution and unrecoverable external side effects.

## 5. Current persistence baseline

```text
Host                         Godot 4.7.2
Distribution                 Standard / non-.NET Windows x64
Language                     GDScript
Runtime                      same-process Godot Runtime
Provider                     DeepSeek deepseek-v4-pro
Persistence                  SQLite — ACCEPTED for G3 v0.1
SQLite binding               2shady4u/godot-sqlite v4.9
Production schema            v4
Product DB                    user://my-world/current-game.sqlite
```

Established production capabilities:

- atomic Game/World/Timeline mutation + expected-head/replay protection;
- durable accepted Conversation + reopen/resume;
- immutable named Save Points + atomic World/head/Conversation Restore;
- Context rebuild + future-memory isolation;
- automatic Recovery Checkpoint + reciprocal Recover;
- immutable internal Timeline branch correctness;
- single-writer process safety through dedicated sibling SQLite coordination DB;
- SQLite-native verified whole-DB backup (`backup_to` / `restore_from`);
- latest/previous/staging backup publication;
- pre-migration verified backup gate;
- staged corruption recovery with corrupt-original quarantine;
- normal SQLite crash distinct from physical corruption recovery.

Current live DB remains the only authoritative live truth. Backup/quarantine/staging are recovery material only.

## 6. Ownership boundaries

```text
Game Domain / lifecycle
→ Game identity / active-game semantics

World Domain
→ game-local authoritative World meaning/state

Timeline / Save / Recovery Domain
→ Timeline Node / Save Point / Recovery Checkpoint / restore-recover semantics

Conversation Domain
→ accepted Conversation truth

Context Assembly
→ derived model request material

Persistence
→ SQLite durable representation
→ transaction / schema version / migration / physical backup / corruption recovery mechanics
```

Persisted by SQLite does not make Persistence the semantic owner.

## 7. Established Conversation / Context boundaries

- durable completion order: candidate → SQLite COMMIT → Domain accept;
- Regenerate/correction keep old accepted truth until replacement succeeds;
- only accepted truth resumes/saves/restores/recovers;
- streaming/cancelled/failed partial attempts do not become durable truth;
- Context/Provider messages are derived and rebuildable, not persistence truth;
- Restore/Recover future-memory isolation are already Owner-UAT proven;
- current bounded Context uses recent accepted working set and current user exactly once/last.

## 8. G3-07 specific boundary

G3-07 is a **reality test / closeout increment**, not a new persistence architecture stage.

Required real product spine:

```text
fresh isolated Game
→ real DeepSeek play
→ durable accepted history
→ exit/reopen same Game
→ named Save
→ continue Future A
→ Load old Save
→ rebuilt Context excludes Future A
→ continue Future B
→ Recover Previous Progress
→ exact Future A recovery
→ reciprocal recovery where useful
→ abrupt process interruption/reopen remains coherent
→ verified physical backup remains usable
```

Blocking rules:

- Real Provider continuation is required for G3-07. G3-06 observed one `transport` result; G3-07 must retry and obtain successful end-to-end evidence. Persistent external Provider unavailability means `BLOCKED`, not a fake PASS.
- Do not create a new persistence framework, schema version, branch registry, backup browser, Timeline debugger or G4/G5/G7 system unless a concrete blocking defect forces architecture re-open.
- If Reality Test finds a bounded bug, minimal repair is allowed inside G3-07 with focused regression.
- Record DB size and Save/close backup latency during the longer path; collect evidence only. Do not prematurely build G7 performance infrastructure.

### Owner-requested UI polish — REQUIRED

Owner UAT for G3-06 found the disaster-recovery button too inconspicuous at the bottom-right in fullscreen/wide layout.

G3-07 must minimally change the recovery failure layout so that when startup is blocked by `physical_corruption` / `interrupted_recovery` and a verified backup is available:

```text
central failure explanation
→ directly below it: [恢复最近安全备份]
→ confirmation dialog
```

Acceptance:

- the recovery button is visually adjacent to the central failure message, not hidden in the lower-right World Surface;
- no duplicate recovery action remains elsewhere;
- button is hidden in normal healthy READY state and when no verified backup exists;
- existing confirmation text still clearly says newer progress may be lost, corrupt original is preserved, and this is not normal Save/Load;
- verify at least fullscreen/wide, 1280×720, and 960×540 without breaking Narrative-first layout.

This is a small polish item; do not redesign the whole shell.

## 9. G3-GATE candidate criteria

G3-GATE may only be proposed after G3-07 Engineering + Independent Review + Owner UAT PASS and must establish:

- reliable persistence and reopen/resume;
- named Save / atomic Load / Restore;
- future-memory isolation;
- Recovery of displaced current future;
- crash/interrupted-write correctness;
- single-writer protection;
- physical corruption recovery;
- real Provider continuation after durable resume/restore/recover;
- player does not need to understand SQLite/WAL or manually repair files.

Arbitrary per-Turn rewind, Timeline browser and backup browser are not required.

## 10. Evidence / execution discipline

Never claim Windows-local, Godot, SQLite, export, filesystem, Provider, resume, restore, recovery, backup, single-instance or crash-recovery success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for genuine product UAT, secrets and irreducible product/architecture decisions.

GUI/process automation safety: identify exact executable + PID; never terminate by fuzzy window title.
