# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

For every new formal task, resolve current authority from GitHub `main` in this order:

1. User's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — product definition.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md` — cross-stage product/runtime principles.
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — architecture map and supporting-design navigation.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — stage/task DAG.
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — current task/PASS/UAT/blocker only.
8. This repository's current implementation, tests and HEAD.

Do **not** read every governance document by default. If the current task touches a deep architecture domain, follow `MY_WORLD_架构_CURRENT.md` to the relevant `architecture/` or `experience/` supporting file only.

Repository-local `docs/CORE_DESIGN_PRINCIPLES.md` is an implementation-facing projection, not a second authority source.

If a new decision changes stage, task, prerequisite, architecture boundary, ownership, contract timing or Task DAG, perform Decision Propagation before continuing old work.

Before authoritative writes/pushes, fetch/re-check HEAD. Never overwrite changes made after the task base without auditing the increment.

## 2. Documentation shape

Project governance follows:

> **Root is map; subfolders are depth.**

Default behavior is to update existing canonical documents rather than create another top-level `*_CURRENT.md`.

The stable governance root is intentionally small:

```text
README.md
MY_WORLD_项目启动总纲_CURRENT.md
MY_WORLD_核心设计原则_CURRENT.md
MY_WORLD_架构_CURRENT.md
MY_WORLD_总体规划路线图_CURRENT.md
MY_WORLD_CURRENT_STATUS.md
```

Deep architecture belongs under `architecture/`; experience under `experience/`; closed process/history under `99_归档/` in the governance repository.

Do not create per-stage status files such as `G3_CURRENT_STATUS.md`; update the fixed `MY_WORLD_CURRENT_STATUS.md`.

## 3. Current stage

Current phase: `G2 — AI Conversation Spine`.

Current task: `G2-03 — Narrative Conversation View` until explicit Owner UAT closeout and governance propagation.

Completed:

- G1-01...G1-06: **PASS**.
- G1-GATE: **PASS**.
- G2-01 Application / Game Shell: **PASS — Owner UAT**, implementation `4a13deb29a2e9c354530843d23eb48422957033c`.
- G2-02 Provider Adapter v0.1: **ENGINEERING PASS**, implementation `ec0617195cbd71ba49e9c3e4ff834aee83e82fd3`.

G2-03 implementation history:

- initial implementation `d736ac9389c2bf23f7f71b0270d6fd8f72db8461`;
- IR-01 completed-regenerate duplicate-player repair `774ab522e48ef1026d622f89e7903e9cb7bab64c` — **PASS** on independent re-review;
- current task remains **RETURNED**, not Product PASS.

Current blockers/returns are owned by `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`:

1. **IR-02** — completed-turn Regenerate followed by Cancel/Fail and then direct new Send can leave provisional history/context inconsistent because the old assistant is removed before successful replacement.
2. **Owner UAT layout return** — default/maximized wide-screen behavior gives almost all new horizontal space to Narrative while side Hosts remain too narrow; side text can become cramped/overflow-prone.

Owner should not be asked to repeat UAT until these repairs are complete.

Do not implement later G2 tasks or G3–G9 early without their current Task Packet.

## 4. Core product/runtime invariants

- Migrate validated experience from SillyTavern / The World / DSH; do not migrate host debt.
- **Commodity Foundation, Owned Game Semantics.**
- **Engine-native, not engine-semantic-coupled.**
- `Game`, `World`, `Timeline`, `Save Point`, `Agent Context`, `Conversation`, `NPC`, `Knowledge`, `Relationship`, `Faction`, `World Event`, `World Pack` are product/domain concepts, not aliases for Godot Scene/Node/Resource.
- UI is a projection of authoritative game truth, not a second durable truth source.
- Source defines reusable starting material; after game creation, game-local reality is authoritative.
- **Model freedom first. Reversibility over prevention.** Do not grow Narrative whitelists, regex authorization tables, confirmations or validators merely to prevent ordinary reversible semantic mistakes.
- **Model authors the world; Runtime makes it durable; Player owns the timeline.** Runtime owns stable identity, atomic durability, persistence integrity, secrets, filesystem/database safety and irreversible external-system boundaries; it is not a Narrative censorship layer.
- **Reversibility != frictionless arbitrary rewind.** Cancel/Regenerate are low-risk nearby actions; Save/Load are explicit high-impact actions.
- **Save Point != Timeline Node.** Internal Timeline history does not automatically become a player-facing one-click rewind UI. Arbitrary per-turn rewind is currently Deferred.
- **Source provides inertia; actors create history.**
- **Off-screen != Inactive.**
- **World Truth != NPC Knowledge != Player Knowledge.**
- **Context stays bounded.**
- **Host capability first; external asset protocol second.**
- Real secret leakage, OS/filesystem authority leakage, physical DB/save corruption, non-atomic writes, arbitrary Mod execution and unrecoverable external side effects remain hard boundaries.

Legacy wording such as `Program owns facts; Model writes prose`, `Model authors candidates; Program commits reality`, or `No Phantom World Change` must not be interpreted as global Narrative censorship. Durable state still must remain atomic and recoverable.

## 5. DSH / SillyTavern migration prohibitions

Do not recreate as new-project architecture:

- DSH Session/fresh-session restore workarounds;
- `fs.watch` restore workarounds;
- periodic model consolidation as primary state consistency;
- DELTAS + bulk Markdown as runtime state database;
- Markdown as authoritative gameplay DB;
- DSH plugin lifecycle assumptions;
- generic Agent Workspace UI as the player IA;
- old React/Browser/HTTP UI Host implementation as production code.

SillyTavern G8 Runtime-extensible UI Host is valid historical architecture evidence. Inherit safe component vocabulary, Surface ownership/contribution, declarative structure vs live data, bounded Action Intent and Host-owned rendering, then reimplement incrementally in Godot according to the roadmap.

## 6. First-generation Foundation

Canonical current summary/navigation: `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`.

Current technical baseline:

```text
Godot 4.7.2 Standard / non-.NET Windows x64
GDScript
same-process Godot Runtime
DeepSeek deepseek-v4-pro
JSON/files for config/source
SQLite = G3 preferred persistence evaluation candidate
```

Domain stays independent from Scene/Node/Resource lifecycles. Keep Domain / Provider / Persistence boundaries explicit. Do not build IPC now.

Business modules may use internal `L3 -> L2 -> L1 -> L0`: downward skips allowed, upward dependencies forbidden, cross-module calls through public L3, Bootstrap as composition root. Do not create empty layers/wrappers for appearance.

## 7. Provider boundary

Current formal adapter:

`src/provider/deepseek流式适配器.gd`

Current product-facing Provider = DeepSeek only.

Provisional G2 seam:

```text
start_stream(messages)
text_delta(text)
completed()
cancel() / cancelled()
failed(code, message)
is_busy()
```

Do not expand this adapter into Turn/Conversation/World semantics or a generic Provider platform.

Current local launch config:

```text
DEEPSEEK_API_KEY
optional: MY_WORLD_DEEPSEEK_MODEL
```

Never commit/display/log provider secrets or Authorization values.

## 8. UI Host boundary

Deep design is reached through `MY_WORLD_架构_CURRENT.md` → `architecture/ui/声明式UIHost设计.md`.

Long-term skeleton:

```text
Left   Player Host
Center Narrative Host
Right  World Surface Host
```

Current wide-screen rule:

> **Narrative First != Narrative Only.**

All three Hosts participate in horizontal expansion on wide/maximized windows. First-generation tuning baseline is approximately:

```text
Player Host      ~18%
Narrative Host   ~60%
World Host       ~22%
```

Side Hosts also need usable minimum widths, approximately `Player ~250px` and `World ~310px` as first-pass G2 tuning targets. If the window cannot satisfy usable widths, collapse side Hosts instead of squeezing them into informationless strips.

Current desktop player launch should default to **Maximized Window**, not Exclusive Fullscreen. Keep `1280x720` as normal-window regression and `960x540` as narrow responsive regression.

All side-host labels/content must wrap/constrain correctly and never overflow into adjacent Hosts. Narrative Host may expand, but long-form readable text should not become an arbitrarily long single-line column on ultrawide displays.

Stage sequence:

```text
G2    fixed UI + stable Host Slots
G3–G5 real player-safe Domain projections
G6    Internal Declarative UI Host
G8    external World Pack / Mod declarative UI contract
```

Do not build generalized renderer/external schema early.

## 9. Save / Timeline boundary

Deep design is reached through `MY_WORLD_架构_CURRENT.md` → `architecture/persistence/时间线存档与可逆性设计.md`.

Current priority:

```text
Cancel / Regenerate latest generation
↓
reliable current persistence / resume
↓
explicit Save
↓
explicit Load / Restore
↓
Context future isolation
↓
recoverability of the pre-load current future
```

Do not expose every historical Turn as `回到这里` by default. Arbitrary per-turn rewind is not a G3 default deliverable.

## 10. Current G2-03 boundary

G2-03 product path:

```text
player natural-language input
→ DeepSeek real streaming
→ readable GM Narrative
→ cancel / failure recovery
→ regenerate / retry latest generation
```

It establishes fixed:

```text
PlayerPanelHost
NarrativeHost
WorldSurfaceHost
```

Current repair scope must remain narrow:

### IR-02 history/context integrity

For a previously completed turn, Regenerate must not destroy the stable provisional completed pair before a replacement successfully completes in a way that makes Cancel/Fail + direct new Send inconsistent.

Required outcome:

```text
turn1 completed
→ regenerate
→ cancel/fail
→ directly send turn2 without retry
→ provider context contains turn1 exactly once and turn2 exactly once
→ no half-pair / duplicate user
→ successful turn2 ends in valid completed pairs
```

A minimal safe approach is to keep the previous completed assistant as stable active provisional context until the replacement generation completes successfully, then atomically replace it; an equivalent small implementation is allowed. Do not turn this into G2-04 Turn Domain or a generic Session framework.

### Owner UAT layout repair

- default exported-player launch = Maximized Window;
- wide/maximized three Hosts all expand horizontally;
- approximate first-pass ratio `18 / 60 / 22`;
- side Host minimum usable widths protected;
- narrow windows collapse side Hosts rather than squeeze them;
- side text wraps/constrains without overflow;
- preserve Narrative as visual/interaction center;
- no large visual-polish redesign.

Other rules:

- Side hosts use honest empty states until real Character/World projections exist; no fake stats/world/save/tabs.
- Provisional in-memory UI/session state and minimal GM system message are allowed only for this vertical proof; they are not G2-04/G2-05 contracts.
- Active generation exposes Cancel; latest generation may expose Regenerate/Retry.
- No Save/Timeline/World/NPC semantics or generalized Declarative Renderer in G2-03.
- G2-03 remains product-facing: after repair, engineering may report only `READY FOR OWNER UAT`; Product PASS requires real Owner use.

## 11. Evidence / execution discipline

Never claim Windows-local, Godot, Provider, export, network or UI success without real execution evidence.

Separate implementation, validation action, observable evidence and PASS/FAIL/NOT VERIFIED.

Automated tests cannot replace Product Owner judgment for Narrative quality, UI usability, game feel or “want to continue”.

GUI automation safety: identify exact Godot/game executable + PID. Never target processes by fuzzy window title and never terminate identity-ambiguous processes.

Routine Git/Godot/build/debug/QA is Agent work. Owner is only asked for secrets, genuine product UAT and irreducible product/architecture decisions.
