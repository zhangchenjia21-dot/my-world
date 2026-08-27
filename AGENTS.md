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

G3 implementation line:

```text
1fc1cba76ade63a05e4b7ba9009264696ad45b1a  G3-01 SQLite route
bda2a8877297c51365cd6581536875b68c81cb85  G3-02 durable World mutation
ee768ca6ec8abdb2d65c994da4e7287886153bff  G3-02 IR-01 query failure repair
929f4ff1e1253a808522d8f559a3cadd01b8d5db  G3-03 current Game resume
```

Current phase:

> **G3 — Persistent Game / Save / Timeline Foundation**

Current task:

> **G3-04 — Explicit Save / Load / Restore + Context Rebuild**

G3-05+ are not authorized until G3-04 Engineering + Independent Review + Owner UAT closes.

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
Production schema            v2 at G3-03 closeout
Product DB                    user://my-world/current-game.sqlite
```

G3-01 proved the SQLite route on real Windows/Godot/exported EXE evidence. G3-02 added atomic Game/World/Timeline mutation, expected-head CAS, replay-safe mutation identity, immutable historical snapshots and explicit storage failure propagation. G3-03 added transactional v1→v2 migration, one-current-Game lifecycle, current accepted Conversation durability, persist-before-accept completion and real cross-process resume.

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
→ SQLite durable representation
→ transaction / schema version / migration / backup / corruption recovery mechanics
```

**Persisted by SQLite does not make Persistence the business-semantic owner.**

Do not let tables, repository objects, SQLite rows or migration code redefine Game/World/Conversation/Save semantics.

## 7. Established Conversation / Context boundaries

Conversation Domain owns Turn ordering/identity, accepted player+GM truth, Generation State, Retry/Regenerate/latest correction, rehydration and prospective completion semantics.

Context Assembly owns GM/system instructions, bounded recent Conversation working set, optional derived Game Context material and Provider request messages.

Provider Adapter remains transport-only.

Closed invariants:

- Regenerate/correction keep old accepted truth until a non-empty replacement succeeds.
- Current Turn's old assistant is excluded from replacement requests.
- zero/whitespace-only completion is `empty_generation`, not accepted truth; any non-whitespace output remains allowed.
- durable completion order is candidate → SQLite COMMIT → Domain accept.
- only accepted Conversation truth resumes; partial stream/cancelled/failed attempts do not.
- UI does not own a second conversation/context truth.
- Context/messages are derived and rebuildable, not persistence truth.

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

Load old Save must not delete historical Timeline Nodes. Arbitrary per-turn rewind remains Deferred.

## 9. G3-04 specific boundary

G3-04 establishes the first explicit player Save / Load / Restore path.

Required product spine:

```text
current Game
→ create named Save Point S1
→ continue later World/Conversation future
→ explicitly select + Load S1
→ restore target World/head
→ restore accepted Conversation at S1
→ rebuild Context from restored truth
→ future-only Conversation does not enter next Provider request
→ continue a new current future
```

Critical invariants:

- **Save Point != Timeline Node.** A Save Point is a stable player-named recovery reference to a Timeline anchor plus the Conversation recovery material needed for exact restore; it is not a copied World database.
- World restore uses the immutable Timeline snapshot already owned by the durable kernel.
- Save must capture only accepted Conversation truth. Streaming/cancelled/failed partial material is not Save truth.
- Restore of `Game.active_head + current World materialization + current accepted Conversation` must be one declared SQLite transaction boundary; partial restore is forbidden.
- Before durable Restore, Conversation recovery material must be validated through Conversation-owned semantics or an equivalent non-mutating seam. Persistence must not invent Conversation business rules.
- COMMIT happens before in-memory/UI switch. Crash after COMMIT but before UI refresh must reopen into the restored durable state.
- Context/Provider messages are rebuilt after Restore; stored Prompt blobs are forbidden.
- Future-only accepted Conversation must be absent from restored Context. Future-memory isolation is blocking acceptance, not polish.
- Active generation cannot be silently restored underneath a running Provider request. Save/Load controls should require a stable non-generating state or an equivalently explicit safe transition.
- Load is a high-impact explicit action. The UI must make the chosen Save obvious and warn that active progress will switch; do not add per-Turn rewind affordances.
- Historical Timeline Nodes are not physically deleted by Load.
- Automatic recovery of an unsaved pre-Load current future, branch/recovery UX and old-head recovery semantics belong to G3-05. G3-04 must not claim those are solved.

First-generation storage may use a minimal `save_points` representation that stores stable Save identity/name, target Timeline Node and accepted Conversation snapshot/recovery material. Do not build a full event store, Timeline browser or duplicate World snapshot database.

## 10. Persistence hard boundaries

- authoritative durable writes must be atomic at their declared boundary;
- stable identities survive reopen once introduced;
- transaction/query failure cannot silently become normal absence or partial accepted state;
- migration failure cannot silently corrupt the only copy;
- Restore failure cannot leave head/World/Conversation half-switched;
- cache/projection/transcript/UI cannot become fallback authoritative truth;
- test failure injection uses isolated paths only and never unknown player data;
- logical game/Narrative mistakes are not persistence-integrity failures and must not trigger global Narrative validators.

Known non-blocking follow-up: double-running two product processes against the same current Game still requires an explicit single-instance/stale-session protection decision before G3-06/standalone hardening closes.

## 11. Evidence / execution discipline

Never claim Windows-local, Godot, SQLite, export, filesystem, resume, restore or crash-recovery success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.

GUI automation safety: identify exact Godot/game executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.
