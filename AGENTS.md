# my world — Repository Agent Rules

Status: current repository instruction
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` explicitly narrows a subtree.

## 1. Authority and freshness

For every new formal task, resolve current authority from GitHub `main` in this order:

1. The user's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_声明式UIHost架构_CURRENT.md` when the task touches G2-03+, RPG UI, Host Slots, UI projection, World Surface, G6, or G8 Mod UI.
6. `Vibe-Coding/my world/MY_WORLD_G2_CURRENT_STATUS.md` for current G2 task / PASS / UAT status only.
7. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
8. `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`.
9. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`.
10. `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`.
11. This repository's current implementation, tests, and HEAD.

Repository-local `docs/CORE_DESIGN_PRINCIPLES.md` is the implementation-facing projection of the canonical core-design document. It does not create a second authority source.

If a current decision changes stage, task, prerequisite, architecture boundary, contract timing, ownership, task validity, or the task DAG, propagate that decision before continuing old work.

Before authoritative `main` writes, re-check current HEAD. Do not silently overwrite changes made after the task base.

## 2. Current stage boundary

Current phase: `G2 — AI Conversation Spine`.

Current task: `G2-03 — Narrative Conversation View`.

Completed:

- `G1-01 — Repository Bootstrap`: **PASS**.
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS**.
- `G1-03 — 2D Chinese Long Text / Input Foundation Spike`: **PASS** based on real Windows manual UAT.
- `G1-04 — Real Provider Streaming / Cancel Foundation Spike`: **PASS** based on real Windows Owner UAT.
- `G1-05 — Local IO / Image / Windows Export Foundation Spike`: **PASS** based on real exported-executable Owner UAT.
- `G1-06 — Foundation Architecture Decision`: **PASS**.
- `G1-GATE — Foundation Gate`: **PASS**.
- `G2-01 — Application / Game Shell`: **PASS** based on real exported-executable Owner UAT at `4a13deb29a2e9c354530843d23eb48422957033c`.
- `G2-02 — Provider Adapter v0.1`: **ENGINEERING PASS** at `ec0617195cbd71ba49e9c3e4ff834aee83e82fd3`; Task Packet explicitly did not require Owner UAT after all engineering evidence passed.

G2-01 Owner observation: the shell is functionally acceptable but still visually rough. This is **deferred visual polish / non-blocking** and must not delay the G2 Conversation Spine. A later explicit UI-polish task may assign this work to KimiCode.

G2-02 proved the formal DeepSeek Provider Adapter seam with real incremental stream, cancel, post-cancel recovery, explicit missing-key/transport failure, non-blocking Godot main loop, current secret/config cleanup, and no Shell regression.

G1 is closed. Every G2 task requires its own current Task Packet; a passed earlier task does not authorize later G2 implementation.

The delivery rhythm remains:

```text
focused exploration
→ real executable proof
→ architecture decision
→ small commit
→ reality check
→ next task
```

Do not implement later G2 tasks or G3–G9 early.

## 3. Foundation and core-design invariants

- Migrate experience from SillyTavern / The World / DSH; do not migrate host debt.
- Prefer mature commodity foundation capabilities while keeping game semantics owned by `my world`.
- Be engine-native, not engine-semantic-coupled.
- `Game`, `World`, `Timeline`, `Save Point`, `Agent Context`, `Conversation`, `NPC`, `Knowledge`, `Relationship`, `Faction`, `World Event`, and `World Pack` are product/domain concepts, not aliases for Godot Scene/Node/Resource types.
- UI is a projection of authoritative game truth, not a second durable truth source.
- World Pack Source defines reusable starting material; after game creation, game-local reality is authoritative.
- **Model freedom first. Reversibility over prevention.** Do not add global Narrative whitelists, regex authorization tables, confirmation layers, or validators merely to prevent ordinary model/game semantic mistakes.
- **Model authors the world; Runtime makes it durable; Player owns the timeline.** Model output may broadly author Narrative, NPC/world actions, dynamic entities, semantic consequences, and game-local evolution. Runtime/Program owns stable identity, atomic durability, persistence, Save/Restore/Timeline integrity, secrets, filesystem/database safety, and irreversible external-system boundaries.
- Ordinary lore, knowledge, characterization, rule-judgment, low-risk player-action interpolation, or Narrative/state mistakes are not automatically hard failures. Prefer better context plus regenerate/retry/rewind/restore/branch over adding permanent global restrictions.
- Legacy wording such as `Program owns facts; Model writes prose`, `Model authors candidates; Program commits reality`, or `No Phantom World Change` must not be interpreted as a global Narrative censorship architecture. `No Phantom` is a consistency quality target; durable writes must remain atomic and recoverable.
- **Host capability first; external asset protocol second.** Prove real fixed UI / Host Slots and internal declarative Host capability before allowing World Pack / Mod schemas to declare it.
- Declarative UI Definition may declare information architecture, placement, safe component kinds and bounded Action Intent; it must not execute arbitrary GDScript, query arbitrary Runtime paths, or become a second state owner.
- Real secret leakage, OS/filesystem authority leakage, physical save/database corruption, non-atomic partial writes, arbitrary Mod execution, and unrecoverable external side effects remain hard boundaries.

## 4. DSH / SillyTavern migration prohibition

Do not directly copy or recreate as new-project architecture:

- DSH Session workarounds;
- fresh-session restore seams;
- `fs.watch` restore workarounds;
- periodic model consolidation as the primary state-consistency mechanism;
- DELTAS plus bulk Markdown edits as the runtime state database;
- Markdown as the authoritative gameplay database by default;
- DSH plugin lifecycle assumptions;
- UI/ownership structures designed around a generic Agent Workspace host;
- old SillyTavern React/Browser/HTTP UI Host implementation as production code.

SillyTavern's G8 Runtime-extensible UI Host is valid **historical architecture evidence**. Inherit its proven semantics — safe component vocabulary, Surface ownership/contribution, declarative structure vs live data, bounded Action Intent, source identity, Host-owned rendering — but reimplement them incrementally with Godot when the current roadmap reaches those capabilities.

## 5. Verified Foundation facts

Verified Windows-local evidence:

- Godot `4.7.2.stable.official.ed1daf0bf`
- Standard / non-.NET Windows x64
- Vulkan / Forward+
- NVIDIA GeForce RTX 4070 Laptop GPU
- Git `2.54.0.windows.1`
- Windows x86_64 export templates installed and verified
- ICU Data installed and verified

G1-01 proved normal Windows-local Git/Godot writes, launch, exit, and clean Git state. G1-03 proved Chinese rendering, long scrolling, bulk/continuous append, Chinese input, selection/copy, UI responsiveness, and normal exit.

## 6. Provider boundary

G1-04 proved:

- real Provider requests from Godot;
- real incremental output;
- active cancel and post-cancel recovery;
- explicit network/API failure states;
- UI main-loop responsiveness;
- two concrete Providers can share a narrow OpenAI-compatible HTTP/SSE seam without a generic Provider platform.

Historical Provider A — DeepSeek:

```text
host = api.deepseek.com
path = /chat/completions
default model = deepseek-v4-pro
key env = DEEPSEEK_API_KEY
```

Historical Provider B — Kimi Code:

```text
host = api.kimi.com
path = /coding/v1/chat/completions
default model = k3
key env = KIMI_CODE_API_KEY
```

G2 product-facing Provider is DeepSeek only unless a later explicit decision changes that. Do not restore Provider switching, automatic routing, fallback meshes, account systems, generic registries, or retry orchestration platforms.

Current formal adapter: `src/provider/deepseek流式适配器.gd`.

Its G2-02 public seam is intentionally thin and may be consumed directly by G2-03 as a provisional UI integration:

```text
start_stream(messages)
text_delta(text)
completed()
cancel() / cancelled()
failed(code, message)
is_busy()
```

Do not expand the Provider adapter into Turn/Conversation/World semantics.

## 7. Security and secrets

Never commit provider API keys, tokens, credentials, cookies, or local secrets.

Current G2 product launch uses:

```text
DEEPSEEK_API_KEY
optional: MY_WORLD_DEEPSEEK_MODEL
```

G1-04-only `KIMI_CODE_API_KEY` and `MY_WORLD_G1_04_*` variables are historical unless a specific historical validation needs them.

Never display/log secret values. Deterministic failure tests must not transmit credentials. Model-freedom principles never authorize access to secrets, arbitrary OS/filesystem execution, or irreversible external effects.

## 8. First-generation Foundation architecture

Canonical record: `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`.

- Host: Godot `4.7.2` Standard / non-.NET Windows x64.
- Language: GDScript first generation; Domain code stays independent from Scene/Node/Resource lifecycles.
- Runtime: same-process Godot Runtime; keep Domain / Provider / Persistence boundaries explicit, no IPC now.
- Persistence candidate range: JSON/files for config/small metadata/portable Source; SQLite preferred G3 evaluation candidate for authoritative World/Timeline state; Event Log/Snapshot are semantic patterns.
- Provider/config: thin `send / stream / cancel`; endpoint/model separate from secrets; G2 starts with DeepSeek `deepseek-v4-pro`.
- Engineering: headless parse, smallest focused tests, bounded redacted logs, tracked export preset, ignored build output, Agent-owned routine QA and Owner-owned product UAT.

Business modules follow `L3 -> L2 -> L1 -> L0`; downward skips are allowed, upward dependencies are not. Cross-module calls use the other module's L3 public boundary. Bootstrap is composition root. Do not create empty layers or speculative wrappers.

## 9. Declarative UI Host supporting architecture

Canonical record: `Vibe-Coding/my world/MY_WORLD_声明式UIHost架构_CURRENT.md`.

Long-term desktop skeleton:

```text
Left   Player Host
Center Narrative Host
Right  World Surface Host
```

Responsive rule:

```text
wide window  → three hosts visible
narrow window→ Narrative stays primary; side hosts collapse/drawer/overlay
```

Stage sequencing:

```text
G2    fixed UI + stable Host Slots
G3–G5 real Domain/player-safe projections
G6    Internal Declarative UI Host vertical proof
G8    external World Pack / Mod declarative UI contract
```

Do not build the generalized renderer or external schema early.

## 10. Current G2 boundary

Current task is **G2-03 Narrative Conversation View**.

G2-03 must establish the real product interaction:

```text
player natural-language input
→ DeepSeek real streaming
→ readable GM Narrative
→ cancel / failure recovery
→ regenerate / retry latest generation
```

It must also establish stable fixed Host Slots:

```text
PlayerPanelHost
NarrativeHost
WorldSurfaceHost
```

Rules:

- Narrative is the visual and interaction center, not a generic chat-app bubble list.
- Wide windows may show three hosts; narrow windows preserve Narrative and collapse/hide side hosts with a simple host-owned toggle/drawer/overlay behavior.
- Player/World side hosts may show only honest minimal empty states until real Character/World projections exist. Do not invent fake stats, fake world facts, fake Timeline, or dead future tabs.
- G2-03 may use explicitly provisional in-memory UI/session state and a minimal provisional GM system message only to prove the vertical product path. These do not become G2-04 Turn/Conversation Domain or G2-05 Context Assembly contracts.
- Latest GM generation may expose lightweight `regenerate / retry`; active generation exposes `cancel`.
- `rewind / 回到这里 / edit-and-retry / branch / Timeline navigation` remain G3 work; do not fake them in G2-03.
- Do not implement generalized Declarative Renderer, external World Pack UI schema, arbitrary extension scripting, Persistence, Save, Timeline, World/NPC semantics, or long-session Context.
- G2-03 is product-facing. Engineering success may report only `READY FOR OWNER UAT`; Product PASS requires real Owner use of the runnable Windows product path.

## 11. Repository shape

Create only files/directories with immediate use:

- `README.md`
- `AGENTS.md`
- `.gitignore`
- `project.godot`
- `src/` for current runnable product work
- `tests/` / `docs/` only for real validation or execution needs

Do not create speculative empty module trees.

## 12. Evidence discipline

Never claim Windows-local, Godot, Provider, export, network, or UI behavior success without real execution evidence.

Separate:

- implementation complete;
- exact validation action;
- observable evidence;
- PASS / FAIL / NOT VERIFIED.

Automated tests cannot replace Product Owner judgment for Narrative quality, UI usability, game feel, or "want to continue".

GUI automation safety: identify the exact Godot/game executable and PID. Never target a process only by fuzzy window title, and never terminate an identity-ambiguous process. The prior Chrome mis-target incident must not recur.

## 13. Cross-stage carry-forward references

Canonical core design:

`Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`

Canonical UI Host architecture:

`Vibe-Coding/my world/MY_WORLD_声明式UIHost架构_CURRENT.md`

Repository-local core-design projection:

`docs/CORE_DESIGN_PRINCIPLES.md`

DSH long-play findings:

`docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`

UI Host architecture becomes mandatory reading for:

- G2-03 Narrative Conversation View / Host Slots;
- G5 Runtime → UI Projection work;
- G6 RPG UI / Internal Declarative Host;
- G8 World Pack / Mod external UI declaration.

DSH carry-forward becomes mandatory when tasks touch:

- G3 persistence / Timeline / Save / Restore;
- G4 World Pack / Source / local reality;
- G5 NPC / Faction / GM Runtime / World Evolution;
- G6 RPG UI / map / presentation truth projection;
- G7 long-session context / performance;
- G8 Mod / authoring semantics;
- G9 long-play Product Value UAT.

The most important DSH world failure to avoid is **Protagonist Causal Monopoly**:

> **Source provides inertia, actors create history.**
>
> **Off-screen != Inactive.**
>
> **Players may change history, but they are not the only creators of history.**

Do not solve it with a universal per-NPC tick simulator or by mechanically increasing DCs.
