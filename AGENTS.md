# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

For every new formal task, resolve current authority from GitHub `main` in this order:

1. User's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` and only the relevant supporting architecture it points to.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
8. This repository's current implementation, tests and HEAD.

Repository-local `docs/CORE_DESIGN_PRINCIPLES.md` is an implementation-facing projection, not a second authority source.

If a current decision changes stage, task, prerequisite, architecture boundary, owner, contract timing or Task DAG, perform Decision Propagation before continuing old work.

Before authoritative writes/pushes, fetch/re-check HEAD and audit any `Task Base → Current HEAD` increment. Never silently overwrite newer current work.

## 2. Documentation shape

Project governance follows:

> **Root is map; subfolders are depth.**

Do not create new top-level `*_CURRENT.md` files for every phase or observation. Current task state stays in the fixed governance `MY_WORLD_CURRENT_STATUS.md`; deep architecture belongs under existing `architecture/`; repository-native execution packets belong under `docs/tasks/`.

## 3. Current stage

Completed:

- G1 Foundation & Project Bootstrap: **PASS / CLOSED**.
- G2 AI Conversation Spine: **PASS / CLOSED**.
- G2-GATE: **PASS**.
- G3-01 Persistence Domain Architecture: **PASS — Independent Review**.
- G3-02 Durable World Mutation Path: **PASS — Independent Review**.
- G3-03 Game Reopen / Resume: **PASS — Owner UAT**.
- G3-04 Explicit Save / Load / Restore + Context Rebuild: **PASS — Owner UAT**.
- G3-05 Recovery / Timeline Foundation: **PASS — Owner UAT**.

G3 implementation line:

```text
1fc1cba76ade63a05e4b7ba9009264696ad45b1a  G3-01 SQLite route
bda2a8877297c51365cd6581536875b68c81cb85  G3-02 durable World mutation
ee768ca6ec8abdb2d65c994da4e7287886153bff  G3-02 IR-01 query failure repair
929f4ff1e1253a808522d8f559a3cadd01b8d5db  G3-03 current Game resume
618fa0f2238114cbe4fc0fe790a1d60c43e99b45  G3-04 Save / Load / Restore + Context rebuild
bf8c35fdf76c4ea3b8ad2560d93c89c2f84c07b0  G3-05 Recovery / Timeline Foundation
```

Current phase:

> **G3 — Persistent Game / Save / Timeline Foundation**

Current task:

> **G3-06 — Crash / Interrupted Write Recovery**

G3-07 is not authorized until G3-06 Engineering + Independent Review + Owner UAT closes.

## 4. Core product/runtime invariants

- Migrate validated experience from SillyTavern / The World / DSH; do not migrate host debt.
- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- `Game`, `World`, `Timeline`, `Save Point`, `Recovery Checkpoint`, `Agent Context`, `Conversation`, `Turn`, `NPC`, `Knowledge`, `Relationship`, `Faction`, `World Event`, `World Pack` are product/domain concepts, not aliases for Godot Scene/Node/Resource or SQLite rows/tables.
- UI is a projection of authoritative game truth, not a second durable truth source.
- **Model freedom first. Reversibility over prevention.**
- **Narrative richness over artificial brevity.** Do not add arbitrary fixed output length, short-answer instructions or convenience `max_tokens` caps.
- **Model authors the world; Runtime makes it durable; Player owns the timeline.**
- **Reversibility != frictionless arbitrary rewind.**
- **Save Point != Timeline Node.**
- **Recovery Checkpoint != Save Point.**
- **Physical Backup != Save Point / Recovery Checkpoint.**
- **Source provides inertia; actors create history.**
- **Off-screen != Inactive.**
- **World Truth != NPC Knowledge != Player Knowledge.**
- **Context stays bounded, not starved.**
- Real secret leakage, OS/filesystem authority leakage, physical DB/save corruption, non-atomic writes, arbitrary Mod execution and unrecoverable external side effects remain hard boundaries.

## 5. Foundation / persistence baseline

Current first-generation baseline:

```text
Host                         Godot 4.7.2
Distribution                 Standard / non-.NET Windows x64
Language                     GDScript
Runtime                      same-process Godot Runtime
Provider                     DeepSeek deepseek-v4-pro
Config/source                JSON/files where appropriate
Persistence                  SQLite — ACCEPTED for G3 v0.1
SQLite binding               2shady4u/godot-sqlite v4.9
Production schema            v4 at G3-05 closeout
Product DB                    user://my-world/current-game.sqlite
```

G3-01 proved the SQLite route. G3-02 established atomic Game/World/Timeline mutation, expected-head CAS, replay-safe mutation identity, immutable Timeline snapshots and failure propagation. G3-03 added current Conversation durability and cross-process resume. G3-04 added immutable named Save Points, atomic World/head/Conversation Restore and Context future-memory isolation. G3-05 added internal Recovery Checkpoints, protected Load/Recover switching, reciprocal recovery and immutable internal branch correctness.

The accepted `godot-sqlite v4.9` binding exposes SQLite online `backup_to` / `restore_from`. G3-06 must validate and use SQLite-native consistency mechanisms rather than ordinary file-copying an open WAL database.

Vendored Windows x86_64 debug/release binaries, MIT license and provenance are under `addons/godot-sqlite/`.

Do not switch to .NET/C#, external process/server, another DB or a generic persistence platform without explicit evidence-backed architecture re-open.

## 6. Canonical ownership != storage ownership

Formal split:

```text
Game Domain / lifecycle
→ Game identity / active-game semantics

World Domain
→ game-local authoritative World meaning/state

Timeline / Save / Recovery Domain
→ Timeline Node / Save Point / Recovery Checkpoint / restore-recover semantics

Conversation Domain
→ accepted conversation truth

Context Assembly
→ derived model request material

Persistence
→ SQLite durable representation
→ transaction / schema version / migration / physical backup / corruption recovery mechanics
```

**Persisted by SQLite does not make Persistence the business-semantic owner.**

A physical whole-database backup is a disaster-recovery copy, not an alternative live Game truth and not a player Save Point.

## 7. Established Conversation / Context boundaries

Conversation Domain owns Turn ordering/identity, accepted player+GM truth, Generation State, Retry/Regenerate/latest correction, rehydration, prospective completion and accepted recovery-material validation.

Context Assembly owns GM/system instructions, bounded recent Conversation working set, optional derived Game Context material and Provider request messages.

Provider Adapter remains transport-only.

Closed invariants:

- Regenerate/correction keep old accepted truth until a non-empty replacement succeeds.
- Current Turn's old assistant is excluded from replacement requests.
- zero/whitespace-only completion is `empty_generation`, not accepted truth; any non-whitespace output remains allowed.
- durable completion order is candidate → SQLite COMMIT → Domain accept.
- only accepted Conversation truth resumes/saves/restores/recovers; partial stream/cancelled/failed attempts do not.
- UI does not own a second conversation/context truth.
- Context/messages are derived and rebuildable, not persistence truth.
- Restore and Recover future-memory isolation are Owner-UAT closed.

## 8. Established Save / Recovery boundary

G3 distinguishes at minimum:

```text
Game
World State
Timeline
Save Point
Recovery Checkpoint
Physical Backup
Conversation
Agent Context
UI Preference
```

Product semantics:

```text
Cancel / Regenerate / latest correction
= local low-friction recovery

Save Point
= explicit player-named long-term recovery reference

Load / Restore Save
= explicit high-impact progress switch

Recovery Checkpoint
= Runtime-created safety material preserving displaced current progress

Physical Backup
= whole-database disaster-recovery copy for storage failure; not ordinary timeline UX

Timeline Node
= Runtime durable recovery anchor, not automatically player-facing
```

Historical Timeline Nodes and internal Recovery records are retained across switches. Arbitrary per-turn rewind remains Deferred.

## 9. G3-06 specific boundary

G3-06 hardens the current one-Game persistence spine against process interruption, physical DB damage and accidental concurrent writers.

Required safety spine:

```text
acquire single-writer ownership
→ inspect current DB before trusting/migrating
→ maintain verified SQLite-native recovery backup(s)
→ run normal durable Game
→ abrupt process/write interruption still reopens coherently
→ physical current-DB corruption is detected, not treated as normal absence
→ if verified backup exists, player may explicitly recover through a staged safe path
→ corrupt original remains preserved/quarantined
→ reopen into one coherent authoritative current Game
```

Critical invariants:

- **Physical Backup != Save Point != Recovery Checkpoint.** Backup is not shown in ordinary named Save or “Recover Previous Progress” lists.
- The live current DB remains authoritative while healthy. Backup must never be queried as silent fallback truth during normal gameplay.
- A second product writer must be rejected before it can mutate or migrate the gameplay DB. Do not rely only on a PID file, wall-clock lease, or a lifetime write transaction on the gameplay DB.
- Single-writer ownership must release automatically after process death/normal exit through OS/SQLite-backed locking or an equivalently proven mechanism. Exact two-process Windows evidence is mandatory.
- Existing task/test processes may use explicit isolated DB/lock paths; tests must never seize or damage the owner's real product data.
- Before any schema-changing migration, create and verify a recovery backup first. If backup creation/verification fails, migration must not begin.
- Use SQLite online backup semantics (`backup_to`/equivalent). Do not ordinary-copy an open WAL database and call that a consistent backup.
- Backup publication must be staged: create candidate → verify integrity/schema/game readability → publish/rotate. Crash/failure during refresh must leave at least one previously verified recovery copy usable.
- First generation may keep latest + previous verified generations and a staging artifact. Do not build a backup history browser or retention platform.
- Startup must distinguish physical corruption, unsupported newer schema, normal absence and ordinary application/domain failure. Do not auto-restore backup for every error.
- Physical corruption with no verified backup is fail-loud and blocking. Never mint a blank replacement Game.
- Disaster recovery must preserve/quarantine the corrupt original before publishing the recovered current DB. Recovery uses a staged verified copy; do not overwrite the sole current file at the start of the operation.
- If recovery COMMIT/file publication succeeds but memory/UI cannot safely resume, require controlled reopen rather than continuing on stale Runtime state.
- Backup recovery may lose progress newer than the backup. Player-facing recovery UX must say so clearly.
- G3-06 does not implement cloud sync, backup encryption/compression, manual import/export platform, backup browser, multi-Game manager, G4/G5/G7 or arbitrary Timeline rewind.

## 10. Persistence hard boundaries

- authoritative durable writes must be atomic at their declared boundary;
- stable identities survive reopen once introduced;
- transaction/query failure cannot silently become normal absence or partial accepted state;
- migration failure cannot silently corrupt the only copy;
- Restore/Recover failure cannot leave head/World/Conversation half-switched;
- automatic recovery creation cannot succeed independently from the progress switch it protects;
- backup refresh/recovery failure cannot destroy the only known-good recovery copy;
- physical corruption cannot silently trigger new-game creation;
- ambiguous concurrent writer ownership is a blocking integrity failure, not a warning;
- cache/projection/transcript/UI/Prompt cannot become fallback authoritative truth;
- destructive tests use task-owned isolated paths only and never unknown player data;
- logical game/Narrative mistakes are not persistence-integrity failures and must not trigger global Narrative validators.

## 11. Evidence / execution discipline

Never claim Windows-local, Godot, SQLite, export, filesystem, resume, restore, recovery, backup, corruption handling, single-instance or crash-recovery success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.

GUI/process automation safety: identify exact executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.
