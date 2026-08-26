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

Do not create new top-level `*_CURRENT.md` files for every phase or observation. Current task state stays in the fixed governance `MY_WORLD_CURRENT_STATUS.md`; deep architecture belongs under existing `architecture/`; repository-native execution/UAT packets belong under `docs/tasks/`.

## 3. Current stage

Current phase: `G2 — AI Conversation Spine`.

Completed:

- G1-01...G1-06 and G1-GATE: **PASS**.
- G2-01 Application / Game Shell: **PASS — Owner UAT**.
- G2-02 Provider Adapter v0.1: **ENGINEERING PASS**.
- G2-03 Narrative Conversation View: **PASS — Owner UAT**.
- G2-04 Turn / Conversation Domain v0.1: **PASS — Independent Review**.
- G2-05 Context Assembly v0.1: **PASS — Independent Review**.

G2-04 final implementation line:

```text
0bf1f012366db7271664a192c1c30e60947cc5c9  base Turn/Conversation Domain

d0d5d47f487fdb75f31de5349894517a830a51e8  IR-03 regenerate request-context repair

d1acd2a58e00fd99b73ab98bc3ccdc3c79762951  IR-04 empty-completion integrity repair
```

G2-05 implementation:

```text
9c577811fd71d19f514ca4e9455e02321f0aa34d  bounded Context Assembly v0.1
```

Current task:

> **G2-06 — First Owner Playtest**

This is a product reality check, not an engineering implementation task. Do not begin G3+ until G2-06 / G2-GATE close.

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

Provider Adapter receives already-assembled request messages. Never move Conversation, World, retrieval or Context semantics into it.

Never commit/display/log provider secrets or Authorization values.

## 6. UI / typography boundary

Long-term skeleton remains:

```text
Left   Player Host
Center Narrative Host
Right  World Surface Host
```

Wide/maximized first-pass layout remains approximately `18 / 60 / 22`; narrow windows collapse side Hosts. Desktop player launch remains Maximized Window. Medium-readable typography baseline is established; player-selectable font size is deferred to later UI Preference work.

## 7. Conversation boundary — established

Conversation Domain owns:

```text
Turn ordering / identity
accepted player + GM truth
Generation State
Retry / Regenerate / latest-turn correction
atomic accepted replacement / rollback semantics
```

Closed invariants:

- `Transcript != Timeline`.
- Regenerate/correction keep old accepted truth until a non-empty replacement succeeds.
- Current Turn's old assistant is excluded from Regenerate replacement requests.
- zero/whitespace-only completion is `empty_generation`, not accepted truth; any non-whitespace content remains allowed.
- UI does not own a second conversation history truth.

## 8. Context Assembly boundary — established

G2-05 established:

```text
Conversation Domain
→ authoritative Turn / accepted truth
→ get_context_projection() derived read model

Context Assembly
→ owns GM/system instructions composition
→ owns bounded recent working-set selection
→ accepts optional derived Game Context material
→ produces Provider messages

Narrative UI
→ passes projection/material and dispatches request

Provider Adapter
→ transport only
```

Current first-pass policy:

```text
recent 12 complete accepted Turns
+ current active attempt
```

Rules:

- whole Turn boundaries only; no per-entry truncation in G2;
- current attempt is never dropped;
- Regenerate/Correction exclude current old accepted pair and end request with current user;
- cancelled/failed drafts do not enter Context;
- optional `game_context_text` is derived material, not World truth;
- production currently has no formal World/NPC state and therefore honestly passes empty Game Context;
- no retrieval, embeddings, summarization, vector search or long-memory platform before evidence justifies G7 work;
- bounded input Context does not imply short output Narrative.

## 9. G2-06 Owner Playtest boundary

G2-06 asks the Product Owner to play the exported game and judge the current **Conversation Spine**, not future World/Persistence capabilities.

Owner should evaluate:

- natural-language input comfort;
- multi-turn continuity over a short play session;
- streaming readability and Narrative quality/length;
- Cancel / Regenerate / Retry friction;
- medium typography / Composer / three-Host usability;
- whether this is a sound interaction foundation for the later AI RPG.

Owner should **not** be asked to judge features that do not exist yet:

- durable World / Save / Timeline;
- formal Character/NPC/Faction state;
- World Pack;
- long-session retrieval;
- complete RPG mechanics;
- whether the game already feels like a finished AI RPG.

Routine tests, logs, Git checks and engineering verification remain Agent work.

## 10. Save / Timeline boundary

Current priority after G2 remains:

```text
reliable current persistence / resume
→ explicit Save
→ explicit Load / Restore
→ Context future isolation
→ recovery
```

No Persistence / Save / Timeline / Branch is authorized until G2 closes and the roadmap advances. Arbitrary per-turn rewind remains Deferred.

## 11. Evidence / execution discipline

Never claim Windows-local, Godot, Provider, export, network or UI success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.

GUI automation safety: identify exact Godot/game executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.
