# my world — Repository Agent Rules

Status: current repository instruction
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` explicitly narrows a subtree.

## 1. Authority and freshness

For every new formal task, resolve current authority from GitHub `main` in this order:

1. The user's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_G2_CURRENT_STATUS.md` for current G2 task / PASS / UAT status only.
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
7. `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`.
8. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`.
9. `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`.
10. This repository's current implementation, tests, and HEAD.

Repository-local `docs/CORE_DESIGN_PRINCIPLES.md` is the implementation-facing projection of the canonical core-design document. It does not create a second authority source.

If a current decision changes stage, task, prerequisite, architecture boundary, contract timing, ownership, task validity, or the task DAG, propagate that decision before continuing old work.

Before authoritative `main` writes, re-check current HEAD. Do not silently overwrite changes made after the task base.

## 2. Current stage boundary

Current phase: `G2 — AI Conversation Spine`.

Current task: `G2-02 — Provider Adapter v0.1`.

Completed:

- `G1-01 — Repository Bootstrap`: **PASS**.
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS**.
- `G1-03 — 2D Chinese Long Text / Input Foundation Spike`: **PASS** based on real Windows manual UAT.
- `G1-04 — Real Provider Streaming / Cancel Foundation Spike`: **PASS** based on real Windows Owner UAT.
- `G1-05 — Local IO / Image / Windows Export Foundation Spike`: **PASS** based on real exported-executable Owner UAT.
- `G1-06 — Foundation Architecture Decision`: **PASS**.
- `G1-GATE — Foundation Gate`: **PASS**.
- `G2-01 — Application / Game Shell`: **PASS** based on real exported-executable Owner UAT at `4a13deb29a2e9c354530843d23eb48422957033c`.

G2-01 Owner observation: the shell is functionally acceptable but still visually rough. This is **deferred visual polish / non-blocking** and must not delay the G2 Conversation Spine. A later explicit UI-polish task may assign this work to KimiCode.

G1-04 proved **DeepSeek + Kimi Code** real HTTP success, incremental streaming, active cancellation, successful post-cancel requests, idle Provider switching, explicit deterministic failure handling, and UI responsiveness.

G1-05 proved a tiny cross-launch `user://` probe, real filesystem image loading for portrait/scene/map roles, Windows export, direct exported-executable execution, and persistence across exported-app relaunch. It did not define the production persistence architecture, asset pipeline, World Pack schema, or Save system.

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
- Real secret leakage, OS/filesystem authority leakage, physical save/database corruption, non-atomic partial writes, and unrecoverable external side effects remain hard boundaries.

## 4. DSH migration prohibition

Do not directly copy or recreate as new-project architecture:

- DSH Session workarounds;
- fresh-session restore seams;
- `fs.watch` restore workarounds;
- periodic model consolidation as the primary state-consistency mechanism;
- DELTAS plus bulk Markdown edits as the runtime state database;
- Markdown as the authoritative gameplay database by default;
- DSH plugin lifecycle assumptions;
- UI/ownership structures designed around a generic Agent Workspace host.

The World / DSH and SillyTavern may be consulted for product evidence and lessons only when relevant. Inherit validated semantics, not their host-specific TypeScript/Web/Workspace implementation shapes.

## 5. Verified Foundation facts

Verified Windows-local evidence as of 2026-08-25:

- Godot `4.7.2.stable.official.ed1daf0bf`
- Standard / non-.NET Windows x64
- Vulkan / Forward+
- NVIDIA GeForce RTX 4070 Laptop GPU
- Git `2.54.0.windows.1`
- Windows x86_64 export templates installed and verified
- ICU Data installed and verified

G1-01 proved normal Windows-local Git/Godot writes, launch, exit, and clean Git state. Earlier Codex write failures were sandbox-only.

G1-03 manual UAT proved Chinese rendering, long scrolling, bulk/continuous append, Chinese input, selection/copy, UI responsiveness, normal exit, and clean Git state.

## 6. G1-04 proven implementation boundary

G1-04 exists only to prove:

- real Provider requests from the Godot Foundation surface;
- real incremental output;
- cancel during generation;
- explicit network/API failure states;
- UI main-loop responsiveness during network activity;
- the same narrow seam can support both required Providers without becoming a generic AI platform.

### Required Provider A — DeepSeek

```text
host = api.deepseek.com
path = /chat/completions
default model = deepseek-v4-pro
key env = DEEPSEEK_API_KEY
optional model override = MY_WORLD_G1_04_DEEPSEEK_MODEL
```

### Required Provider B — Kimi Code API

```text
host = api.kimi.com
path = /coding/v1/chat/completions
default model = k3
key env = KIMI_CODE_API_KEY
optional model override = MY_WORLD_G1_04_KIMI_MODEL
```

Both are OpenAI-compatible chat-completions/SSE shapes for this spike, so reuse the small common HTTP/SSE parsing path where reality permits. Keep provider-specific host/path/key/model explicit. Kimi Code replaces the superseded Kimi configuration; do not retain a compatibility fallback.

Do **not** expand this into:

- automatic provider routing;
- fallback meshes;
- load balancing;
- account systems;
- generic provider registries/plugin frameworks;
- retry orchestration platforms;
- product-level model selection architecture.

Implementation constraints:

- use provisional GDScript because it remains the lowest-dependency spike language;
- use Godot `HTTPClient` in non-blocking mode with main-loop `poll()`;
- read response bodies incrementally;
- parse only the SSE/OpenAI-compatible shape required by the two current Providers;
- cancellation may close the active transport; do not invent final Turn/Cancel domain semantics;
- use a UI heartbeat/manual response counter to prove non-freezing behavior;
- deterministic connection-failure test must not transmit Provider credentials;
- same-process networking is evidence only, not the G1-06 Runtime-boundary decision.

Owner Windows UAT closed this boundary as PASS on 2026-08-26. Both Providers passed full generation, cancel, and post-cancel request; heartbeat/manual UI response remained active; idle switching, deterministic connection failure, normal exit, and clean Git state also passed. The observed roughly 30-second complete long-output duration is not a G1-04 blocker; later performance work must separate TTFT from generation throughput in G2.

## 7. Security and secrets

Never commit provider API keys, tokens, credentials, cookies, or local secrets.

For G1-04:

- DeepSeek key comes only from `DEEPSEEK_API_KEY`;
- Kimi Code key comes only from `KIMI_CODE_API_KEY`;
- UI may show only whether each variable is set;
- never display/log either key value;
- never place keys in `.gd`, `.tscn`, `project.godot`, README examples, screenshots, commits, or chat;
- deterministic failure testing must not carry `Authorization` headers.

Model-freedom principles never authorize access to secrets, arbitrary OS/filesystem execution, or irreversible external effects.

## 8. G1-04 validation record

Real Windows-local observation proved:

- DeepSeek real HTTP 2xx + incremental stream;
- Kimi Code real HTTP 2xx + incremental stream;
- UI heartbeat/manual interaction continue during each Provider request;
- a real active generation can be cancelled and UI promptly recovers;
- at least one real request succeeds after cancellation;
- Provider can be switched while idle without app restart;
- deterministic connection failure is explicit and non-freezing;
- Provider/API errors are readable, not silent hangs;
- normal exit;
- clean Git state.

G1-04 is therefore PASS. Repository structure, static code review, mocked chunks, or G1-03 timer append were not used as substitutes for the real Provider evidence.

## 9. First-generation Foundation architecture

The canonical record is `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`.

- Host: Godot `4.7.2`.
- Distribution: Standard / non-.NET Windows x64.
- Language: GDScript for the first generation. Domain code must remain independent from Scene/Node/Resource lifecycles. Revisit C#/.NET or mixed only when G3/G5/G7 produces concrete testability, performance, or mature-library evidence.
- Runtime: same-process Godot Runtime for the first generation. Keep Domain, Provider, and Persistence boundaries explicit so a later local process extraction remains possible; do not build IPC now.
- Persistence candidate range: JSON/files for configuration, small local metadata, and portable Source inputs; SQLite is the preferred G3 evaluation candidate for authoritative World/Timeline state; Event Log/Snapshot are semantic patterns that may be combined with it. Do not treat Markdown, transcript, UI state, or Godot Resource as the authoritative gameplay database.
- Provider/config: keep a thin `send / stream / cancel` adapter; separate endpoint/model configuration from secrets; keep secrets local and out of Git/log/UI. G2 begins with one concrete Provider, DeepSeek `deepseek-v4-pro`; Kimi Code remains a verified Foundation alternate, not an automatic fallback.
- Engineering path: headless parse plus the smallest focused automated test form needed by real deterministic logic; bounded redacted local logs under `user://logs/`; tracked `export_presets.cfg`; ignored `build/`; Agent-owned routine build/Git/debug/QA and Owner-owned final product UAT.

Business modules follow `L3 -> L2 -> L1 -> L0`; downward layer skips are allowed, upward dependencies are not. Cross-module calls must use the other module's L3 public boundary. Bootstrap remains the composition root. Do not create empty layers or speculative wrappers.

The Foundation decision's older candidate/commit wording is superseded **only where it would be used to restrict ordinary model-authored game semantics or Narrative**. Its technical integrity, persistence, Host, language, process, Provider, logging, and packaging decisions remain current.

## 10. Current G2 boundary

G2-02 owns only **Provider Adapter v0.1**. It may implement the production-facing DeepSeek transport seam and focused test/harness evidence needed to prove `send / stream / cancel / explicit failure`, but it must not implement the G2-03 Narrative Conversation View, G2-04 Turn / Conversation Domain, G2-05 Context Assembly, persistence, World Pack, NPC/world simulation, generic provider routing, or UI visual polish.

G1-04 Provider code is legacy implementation evidence, not current product code. Reuse proven narrow HTTP/SSE techniques where useful, but do not restore the old spike UI or dual-provider selector. G2-02 product-facing Provider is DeepSeek `deepseek-v4-pro`; Kimi Code remains only a verified alternate unless a later explicit decision promotes it.

When G2 Conversation/Turn work begins, protect model output quality and natural-language freedom. `regenerate / retry` are the earliest reversibility primitives; do not prebuild G3 Timeline, but do not introduce prevention-first Narrative restrictions that would conflict with it.

## 11. Repository shape

Create only files/directories with immediate use. Keep each stage small:

- `README.md`
- `AGENTS.md`
- `.gitignore`
- `project.godot`
- `src/` for current runnable product work
- `tests/` / `docs/` only when a real validation need exists

Do not create speculative empty module trees.

## 12. Evidence discipline

Never claim Windows-local, Godot, Provider, export, or network success without real execution evidence.

For local validation, separate:

- GitHub-side implementation complete;
- exact local command/action;
- expected observable evidence;
- PASS / FAIL / NOT VERIFIED.

G1-GATE passed only because all G1 real-execution seams had evidence. Future gates retain the same evidence standard.

Product-value evidence must not be replaced by safety-rule counts or validator coverage. If new guardrails make the AI RPG materially more mechanical, slower, or less expressive, treat that as a product regression even when engineering checks pass.

## 13. Long-play and predecessor carry-forward references

Canonical cross-stage core design:

`Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`

Repository-local implementation projection:

`docs/CORE_DESIGN_PRINCIPLES.md`

DSH long-play cross-stage findings:

`docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`

Underlying DSH experiment closure reference:

`zhangchenjia21-dot/the-world/docs/DSH_GAME_TEST_LESSONS_CORE.md`

The repository-local DSH carry-forward document is **not** a Task Packet and does not authorize prebuilding later stages. It becomes mandatory reading whenever a task touches:

- G3 persistence / Timeline / Save / Restore;
- G4 World Pack / Source / local reality;
- G5 NPC / Faction / GM Runtime / World Evolution;
- G6 RPG UI / map / presentation truth projection;
- G7 long-session context / performance;
- G8 Mod / authoring semantics;
- G9 long-play Product Value UAT.

The most important confirmed DSH failure to avoid is **Protagonist Causal Monopoly**: a persistent world can still feel dead if Source history and player actions are the only real causes of new history while NPCs/factions mainly react. Future world semantics must preserve:

> **Source provides inertia, actors create history.**

> **Off-screen != Inactive.**

> **Players may change history, but they are not the only creators of history.**

Do not solve this by building a universal per-NPC tick simulator or by mechanically increasing DCs. G5 must find a bounded, event/priority-driven autonomous world-evolution approach and prove it with Player Absence, Counterfactual Propagation, and Independent Actor tests.
