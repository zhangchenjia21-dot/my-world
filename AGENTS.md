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

G3-01 implementation/spike:

```text
1fc1cba76ade63a05e4b7ba9009264696ad45b1a
```

Current phase:

> **G3 — Persistent Game / Save / Timeline Foundation**

Current task:

> **G3-02 — Durable World Mutation Path**

G3-03+ are not authorized until G3-02 Independent Review closes.

## 4. Core product/runtime invariants

- Migrate validated experience from SillyTavern / The World / DSH; do not migrate host debt.
- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- `Game`, `World`, `Timeline`, `Save Point`, `Agent Context`, `Conversation`, `Turn`, `NPC`, `Knowledge`, `Relationship`, `Faction`, `World Event`, `World Pack` are product/domain concepts, not aliases for Godot Scene/Node/Resource or SQLite rows/tables.
- UI is a projection of authoritative game truth, not a second durable truth source.
- **Model freedom first. Reversibility over prevention.**
- **Narrative richness over artificial brevity.** Do not add arbitrary fixed output length, short-answer instructions or convenience `max_tokens` caps.
- **Model authors the world; Runtime makes it durable; Player owns the timeline.**
- **Reversibility != frictionless arbitrary rewind.**
- **Save Point != Timeline Node.**
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
```

G3-01 proved the current route on real Windows/Godot/exported EXE evidence: open/reopen, parameter bindings, COMMIT/ROLLBACK, pre-COMMIT process termination/reopen, migration success/failure rollback, corrupt fail-loud and packaged GDExtension operation.

Vendored Windows x86_64 debug/release binaries, MIT license and provenance are under `addons/godot-sqlite/`.

Do not switch to .NET/C#, external process/server, another DB or a generic persistence platform without explicit evidence-backed architecture re-open.

## 6. Canonical ownership != storage ownership

Formal split:

```text
Game Domain / lifecycle
→ Game identity / active-game semantics

World Domain
→ game-local authoritative World meaning/state

Timeline / Save Domain
→ Timeline Node / Save Point / restore semantics

Conversation Domain
→ accepted conversation truth

Context Assembly
→ derived model request material

Persistence
→ SQLite representation
→ transaction / schema version / migration / backup / corruption recovery mechanics
```

**Persisted by SQLite does not make Persistence the business-semantic owner.**

Do not let tables, repository objects, SQLite rows or migration code redefine Game/World/Conversation semantics.

## 7. Established G2 boundaries

Conversation Domain owns Turn ordering/identity, accepted player+GM truth, Generation State, Retry/Regenerate/latest correction and atomic accepted replacement/rollback semantics.

Context Assembly owns GM/system instructions, bounded recent Conversation working set, optional derived Game Context material and Provider request messages.

Provider Adapter remains transport-only.

Closed invariants:

- Regenerate/correction keep old accepted truth until a non-empty replacement succeeds.
- Current Turn's old assistant is excluded from replacement requests.
- zero/whitespace-only completion is `empty_generation`, not accepted truth; any non-whitespace output remains allowed.
- UI does not own a second conversation/context truth.
- Context/messages are derived and rebuildable.

G3-02 must not persist Context messages as authoritative truth or redefine Conversation as Timeline.

## 8. G3 persistence / reversibility boundary

G3 distinguishes at minimum:

```text
Game
World State
Timeline
Save Point
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

Load / Restore
= explicit high-impact operation that changes active future

Timeline Node
= Runtime durable recovery anchor, not automatically player-facing
```

Load old Save should not immediately and irreversibly destroy current future. Arbitrary per-turn rewind remains Deferred.

## 9. G3-02 specific boundary

G3-02 turns the proven SQLite route into the first production durable mutation kernel.

Required direction:

```text
Game-local World mutation input
→ stable mutation identity
→ authoritative current World materialization change
→ new Timeline Node
→ Game.active_head change
→ one SQLite transaction
→ publish success only after COMMIT
```

Critical invariants:

- no half-new/half-old visible state;
- caller supplies/derives an expected current head so stale writes cannot silently attach to the wrong future;
- crash-after-COMMIT but before caller receives success must be replay-safe: the same durable mutation identity cannot create a duplicate Timeline Node/effect;
- Snapshot/checkpoint remains recovery/performance material, not second live truth;
- production schema stays minimal and generic enough not to pre-freeze G5 NPC/Faction/Item semantics;
- G3-01 `g3_fixture_*` schema is spike-only and must not be copied blindly into production;
- no Resume, Save UI, Restore flow, Timeline browser or Conversation persistence yet.

Do not introduce ORM, EventBus, DI/service locator, generic repository forest or full event sourcing.

## 10. Persistence hard boundaries

- authoritative durable writes must be atomic;
- stable identities survive reopen once introduced;
- transaction failure or interruption cannot silently leave partial accepted game state;
- migration failure cannot silently corrupt the only copy;
- cache/projection/transcript/UI cannot become fallback authoritative truth;
- test failure injection uses isolated paths only and never unknown player data;
- logical game/Narrative mistakes are not persistence-integrity failures and must not trigger global Narrative validators.

## 11. Evidence / execution discipline

Never claim Windows-local, Godot, SQLite, export, filesystem or crash-recovery success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.

GUI automation safety: identify exact Godot/game executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.
