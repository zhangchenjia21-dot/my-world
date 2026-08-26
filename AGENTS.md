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

Current phase: `G2 — AI Conversation Spine`.

Completed:

- G1-01...G1-06 and G1-GATE: **PASS**.
- G2-01 Application / Game Shell: **PASS — Owner UAT**.
- G2-02 Provider Adapter v0.1: **ENGINEERING PASS**.
- G2-03 Narrative Conversation View: **PASS — Owner UAT**.
- G2-04 Turn / Conversation Domain v0.1: **PASS — Independent Review**.

G2-04 final implementation line:

```text
0bf1f012366db7271664a192c1c30e60947cc5c9  base Turn/Conversation Domain

d0d5d47f487fdb75f31de5349894517a830a51e8  IR-03 regenerate request-context repair

d1acd2a58e00fd99b73ab98bc3ccdc3c79762951  IR-04 empty-completion integrity repair
```

Current task:

> **G2-05 — Context Assembly v0.1**

G2-06 Owner Playtest and G3+ are not authorized until G2-05 Independent Review closes.

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

Legacy wording such as `Program owns facts; Model writes prose`, `Model authors candidates; Program commits reality`, or `No Phantom World Change` must not be interpreted as global Narrative censorship.

## 5. Foundation / Provider boundary

Current baseline:

```text
Godot 4.7.2 Standard / non-.NET Windows x64
GDScript
same-process Godot Runtime
DeepSeek deepseek-v4-pro
JSON/files for config/source
SQLite = G3 preferred persistence evaluation candidate
```

Current Provider Adapter remains thin:

```text
start_stream(messages)
text_delta(text)
completed()
cancel() / cancelled()
failed(code, message)
is_busy()
```

Provider Adapter receives already-assembled request messages. Do not put Turn/Conversation/World semantics, retrieval or Context Assembly inside it.

Never commit/display/log provider secrets or Authorization values.

## 6. UI / typography boundary

Long-term skeleton remains:

```text
Left   Player Host
Center Narrative Host
Right  World Surface Host
```

Wide/maximized first-pass layout remains approximately `18 / 60 / 22`; narrow windows collapse side Hosts. Desktop player launch remains Maximized Window. G2-04 established the medium-readable typography baseline; player-selectable font size is deferred to later UI Preference work.

Do not turn G2-05 into UI redesign.

## 7. G2-04 Conversation boundary — now established

Conversation Domain owns:

```text
Turn ordering / identity
accepted player + GM truth
Generation State
Retry / Regenerate / latest-turn correction
atomic accepted replacement / rollback semantics
```

Important closed invariants that G2-05 must preserve:

- `Transcript != Timeline`.
- Regenerate/correction keep old accepted truth until a non-empty replacement succeeds.
- Current Turn's old assistant is excluded from Regenerate replacement requests.
- zero/whitespace-only completion is `empty_generation`, not accepted truth; any non-whitespace content remains allowed.
- UI does not own a second conversation history truth.

Do not move these semantics back into UI or Provider.

## 8. G2-05 Context Assembly boundary

G2-05 exists to remove the remaining provisional request-assembly responsibility from Conversation and establish a small, explicit Context Assembly owner.

Required ownership split:

```text
Conversation Domain
→ authoritative in-memory Turn / accepted truth
→ exposes read-only derived context projection

Context Assembly
→ system / GM instructions composition
→ bounded Conversation working-set selection
→ current minimal Game Context material inclusion
→ produces Provider messages

Narrative UI
→ player input + rendering + action dispatch

Provider Adapter
→ transport only
```

Rules:

- Context/Provider messages are **derived request material**, never canonical World or Conversation truth.
- `Context stays bounded, not starved.` First G2 policy should be simple and explicit (recent complete Turns + current attempt), not unbounded full transcript and not complex retrieval.
- Preserve whole Turn boundaries; do not truncate individual player/GM text merely to hit an arbitrary character target in G2-05.
- Do not build summarization, embeddings, vector search, semantic retrieval, token-budget platform or long-memory infrastructure; G7 owns that evolution.
- Current Game Context input may be an honest small text/projection seam plus deterministic fixtures. Do not invent fake authoritative Character/World/NPC state just to populate Context before those domains exist.
- Game Context input is data/material supplied to Context Assembly; Context Assembly does not become its canonical owner.
- Regenerate/correction request semantics from G2-04 must remain correct after migration.
- `Narrative richness over artificial brevity` remains independent from input-context boundedness. Do not add output-length caps.

Do not introduce EventBus/DI/service forests, generic command frameworks or speculative context-provider plugin systems.

## 9. Save / Timeline boundary

Current priority after G2 is still:

```text
reliable current persistence / resume
→ explicit Save
→ explicit Load / Restore
→ Context future isolation
→ recovery
```

No Persistence / Save / Timeline / Branch is authorized in G2-05. Arbitrary per-turn rewind remains Deferred.

## 10. Evidence / execution discipline

Never claim Windows-local, Godot, Provider, export, network or UI success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.

GUI automation safety: identify exact Godot/game executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.
