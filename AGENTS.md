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
- G2-06 First Owner Playtest: **PASS — Owner UAT**.
- G2-GATE: **PASS**.

Current phase:

> **G3 — Persistent Game / Save / Timeline Foundation**

Current task:

> **G3-01 — Persistence Domain Architecture**

G3-02+ are not authorized until G3-01 Independent Review closes.

G2 established the current conversation backbone: real DeepSeek streaming, Turn/Conversation Domain, Context Assembly, Cancel/Retry/Regenerate/latest-turn correction, bounded recent-12 working set, responsive Narrative UI and medium-readable typography. Do not regress or redesign those foundations during G3-01.

## 4. Core product/runtime invariants

- Migrate validated experience from SillyTavern / The World / DSH; do not migrate host debt.
- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- `Game`, `World`, `Timeline`, `Save Point`, `Agent Context`, `Conversation`, `Turn`, `NPC`, `Knowledge`, `Relationship`, `Faction`, `World Event`, `World Pack` are product/domain concepts, not aliases for Godot Scene/Node/Resource.
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
- **Host capability first; external asset protocol second.**
- Real secret leakage, OS/filesystem authority leakage, physical DB/save corruption, non-atomic writes, arbitrary Mod execution and unrecoverable external side effects remain hard boundaries.

## 5. Foundation baseline

Current first-generation baseline:

```text
Host                         Godot 4.7.2
Distribution                 Standard / non-.NET Windows x64
Language                     GDScript
Runtime                      same-process Godot Runtime
Provider                     DeepSeek deepseek-v4-pro
Config/source                JSON/files where appropriate
Persistence candidate        SQLite evaluation + Event Log/Snapshot semantics
```

SQLite is a **G3 preferred evaluation candidate**, not a mandatory conclusion. G3-01 may reject it if real Windows/Godot evidence proves an unacceptable binding, packaging, transaction, backup or recovery cost.

Do not silently switch to .NET/C#, an external process, a server, or a generic persistence platform merely because a library is easier there. If the current Foundation becomes a real blocker, return evidence and reopen the architecture decision explicitly.

## 6. Established G2 boundaries

Conversation Domain owns:

```text
Turn ordering / identity
accepted player + GM truth
Generation State
Retry / Regenerate / latest-turn correction
atomic accepted replacement / rollback semantics
```

Context Assembly owns:

```text
GM/system instructions
bounded recent Conversation working set
optional derived Game Context material
Provider request messages
```

Provider Adapter remains transport-only.

Closed invariants:

- Regenerate/correction keep old accepted truth until a non-empty replacement succeeds.
- Current Turn's old assistant is excluded from replacement requests.
- zero/whitespace-only completion is `empty_generation`, not accepted truth; any non-whitespace output is allowed.
- UI does not own a second conversation/context truth.
- `Conversation.get_context_projection()` and Context messages are derived read material.

G3-01 must not move these semantics into Persistence or redefine Conversation as Timeline.

## 7. G3 persistence/reversibility boundary

G3 must distinguish at minimum:

```text
Game
World State
Timeline
Save Point
Conversation
Agent Context
UI Preference
```

Product semantics already frozen:

```text
Cancel / Regenerate / latest correction
= local, low-friction recovery

Save Point
= explicit player-named long-term recovery intent

Load / Restore
= explicit high-impact operation that changes active future

Timeline Node
= finer Runtime durable anchor; not automatically player-facing
```

Do not expose every historical Turn as `回到这里`. Arbitrary per-turn rewind remains Deferred.

Restore direction:

> Loading an old Save should not immediately and irreversibly destroy the current future.

G3-01 chooses architecture boundaries needed to make that possible; it does not build the final Save UI or arbitrary branching UX.

## 8. G3-01 specific boundary

G3-01 is **architecture + real technical spike**, not production feature completion.

It must establish evidence for:

```text
Authoritative ownership
→ what is durable truth vs projection/cache

Durable mutation transaction
→ what changes atomically together

Storage route
→ real SQLite path on current Godot/Windows Foundation, or evidence-backed alternative

Timeline/checkpoint/snapshot role
→ minimum semantics, not full event sourcing by default

Migration/version boundary
→ how persisted structure evolves safely

Interrupted-write/recovery boundary
→ what failure modes are detected and how last good state survives

Future integration seams
→ enough for G3-02..G3-06 without speculative framework forests
```

Use small realistic fixtures. Do not invent the full World/NPC schema before G5.

G3-01 must not implement:

- full durable World mutation runtime;
- reopen/resume product flow;
- Save/Load/Restore UI;
- arbitrary Timeline browser/rewind;
- World Pack;
- NPC/Faction/World semantics;
- generic repository/ORM/DI/EventBus/service framework.

A minimal spike implementation, test database and focused recovery fixtures are allowed when necessary to prove architecture.

## 9. Persistence hard boundaries

Persistence engineering is a hard-integrity area. Required principles:

- authoritative writes must be atomic at the chosen persistence boundary;
- crash/interruption must not silently leave half-new/half-old accepted game state;
- migration failure must not silently corrupt the only copy;
- cache/projection/transcript/UI cannot become fallback authoritative truth;
- stable identities must survive persistence/reopen once introduced;
- recovery design must distinguish logical game mistakes from physical storage corruption;
- tests may intentionally simulate failures, but never destroy unrelated user files or existing real games.

Use isolated test paths under safe project/user test locations. Never experiment against an unknown real player database.

## 10. Evidence / execution discipline

Never claim Windows-local, Godot, SQLite, export, filesystem or crash-recovery success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.

GUI automation safety: identify exact Godot/game executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.
