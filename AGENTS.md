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

G2-03 final implementation line includes `81e7ce0dc7e60094f65b09c428649f49446cb49a` and proves the real DeepSeek Narrative UI, Cancel/Regenerate/failure recovery, wide/narrow Host layout, responsive Composer and Narrative-richness baseline.

Current task:

> **G2-04 — Turn / Conversation Domain v0.1**

G2-05 Context Assembly and G3+ are not authorized until G2-04 review closes.

Known non-blocking carry-forward from G2-03 Owner UAT: the whole page typography is still too small. G2-04 must make one bounded adjustment to a medium-readable default font baseline. Do not turn this into a Settings/Theme framework; player-selectable font size is deferred to the later RPG Experience / UI Preference stage.

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

Domain stays independent from Scene/Node/Resource lifecycles where practical: use plain GDScript data/domain objects rather than making game semantics depend on SceneTree lifetime.

Current Provider Adapter remains thin:

```text
start_stream(messages)
text_delta(text)
completed()
cancel() / cancelled()
failed(code, message)
is_busy()
```

Do not put Turn/Conversation/World semantics or Context Assembly inside the Provider Adapter.

Never commit/display/log provider secrets or Authorization values.

## 6. UI Host / typography boundary

Long-term skeleton:

```text
Left   Player Host
Center Narrative Host
Right  World Surface Host
```

Wide/maximized first-pass layout remains approximately `18 / 60 / 22`, with usable side minimum widths; narrow windows collapse side Hosts rather than squeezing them into unusable strips. Desktop player launch remains Maximized Window, not Exclusive Fullscreen.

G2-04 typography carry-forward:

- raise the overall default to a medium-readable desktop baseline;
- keep hierarchy between title/body/secondary text/buttons;
- validate maximized, 1280×720 and 960×540 without overflow/regression;
- no font-size selector, persistence, custom-font manager or broad Theme rewrite now.

Future supported font-size/UI-scale choice is a UI Preference, not World/Timeline state.

## 7. G2-04 domain boundary

G2-04 exists because G2-03 interaction truth is still largely maintained by UI-local provisional arrays/flags. G2-05 must not depend on UI-private truth.

G2-04 must establish a minimal formal in-memory Conversation Domain that owns:

```text
Player Turn
GM generation / accepted response
Conversation ordering / entry projection
Generation State
Retry
Regenerate
latest-turn correction semantics
```

Required ownership split:

```text
Conversation Domain → conversation/turn truth and generation lifecycle semantics
Narrative UI        → input + rendering/projection + player actions
Provider Adapter    → HTTP/SSE transport only
G2-05               → system instructions + Context Assembly + working-set selection
```

Important semantics:

- `Transcript != Timeline`.
- No Persistence / Save / Branch / arbitrary historical rewind.
- Completed Regenerate keeps the previous accepted result stable until replacement succeeds; cancel/fail must preserve the previous stable result.
- Latest-turn correction is limited to the latest logical turn; it must not silently become arbitrary historical editing. A corrected completed latest turn should follow the same atomic replacement principle: old accepted pair remains stable until corrected generation succeeds; cancel/fail rolls back to it.
- UI must not retain a second authoritative `_history`/generation truth after migration; rendering references are fine, duplicated semantic state is not.
- Domain does not choose system prompts, trim context, retrieve world facts or build a long-memory platform. G2-05 owns those concerns.

Do not introduce EventBus/DI/service forests, generic command frameworks, persistence abstractions or speculative interfaces merely to make the module look complete.

## 8. Save / Timeline boundary

Current priority after G2 is still:

```text
reliable current persistence / resume
→ explicit Save
→ explicit Load / Restore
→ Context future isolation
→ recovery
```

Do not expose every historical Turn as `回到这里` by default. Arbitrary per-turn rewind is Deferred.

## 9. Evidence / execution discipline

Never claim Windows-local, Godot, Provider, export, network or UI success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.

GUI automation safety: identify exact Godot/game executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.
