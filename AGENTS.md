# my world — Repository Agent Rules

Status: current repository instruction
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` explicitly narrows a subtree.

## 1. Authority and freshness

For every new formal task, resolve current authority from GitHub `main` in this order:

1. The user's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`.
6. `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`.
7. This repository's current implementation, tests, and HEAD.

If a current decision changes stage, task, prerequisite, architecture boundary, contract timing, ownership, task validity, or the task DAG, propagate that decision before continuing old work.

Before authoritative `main` writes, re-check current HEAD. Do not silently overwrite changes made after the task base.

## 2. Current stage boundary

Current phase: `G1 — Foundation & Project Bootstrap`.

Current task: `G1-05 — Local IO / Image / Windows Export Foundation Spike`.

Completed:

- `G1-01 — Repository Bootstrap`: **PASS**.
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS**.
- `G1-03 — 2D Chinese Long Text / Input Foundation Spike`: **PASS** based on real Windows manual UAT.
- `G1-04 — Real Provider Streaming / Cancel Foundation Spike`: **PASS** based on real Windows Owner UAT.

G1-04 proved **DeepSeek + Kimi Code** real HTTP success, incremental streaming, active cancellation, successful post-cancel requests, idle Provider switching, explicit deterministic failure handling, and UI responsiveness.

G1-05 is now unblocked and current. It is limited to local IO, a tiny cross-launch probe, real filesystem image loading for portrait/scene/map roles, Windows export, and direct exported-executable runtime proof. It must not freeze the production persistence architecture, asset pipeline, World Pack schema, or Save system.

G1 remains a Foundation Spike stage:

```text
focused exploration
→ real executable proof
→ architecture decision
→ small commit
→ reality check
→ next task
```

Do not implement large portions of G2–G9 early.

## 3. Foundation invariants

- Migrate experience from The World / DSH; do not migrate DSH host debt.
- Prefer mature commodity foundation capabilities while keeping game semantics owned by `my world`.
- Be engine-native, not engine-semantic-coupled.
- `Game`, `World`, `Timeline`, `Save Point`, `Agent Context`, `Conversation`, `NPC`, `Knowledge`, `Relationship`, `Faction`, `World Event`, and `World Pack` are product/domain concepts, not aliases for Godot Scene/Node/Resource types.
- UI is a projection of authoritative game truth, not a second durable truth source.
- World Pack Source defines reusable starting material; after game creation, game-local reality is authoritative.
- Model output may author candidates; deterministic program/domain ownership commits authoritative reality.

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

The World / DSH may be consulted for product evidence and lessons only when relevant.

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

## 9. Current and later G1 boundaries

- G1-05 is current and owns local IO, dynamic images, and functional Windows export proof.
- G1-06 owns Godot Host, Standard/.NET, GDScript/C#/mixed, persistence candidate range, Provider/product configuration boundary, and same-process vs local-runtime-process architecture decisions.

Do not pull G1-06 decisions into G1-05, and do not reopen or optimize the passed G1-04 Provider seam.

## 10. Repository shape

Create only files/directories with immediate use. Keep G1 small:

- `README.md`
- `AGENTS.md`
- `.gitignore`
- `project.godot`
- `src/` for the current runnable Foundation spike
- `tests/` / `docs/` only when a real validation need exists

Do not create speculative empty module trees.

## 11. Evidence discipline

Never claim Windows-local, Godot, Provider, export, or network success without real execution evidence.

For local validation, separate:

- GitHub-side implementation complete;
- exact local command/action;
- expected observable evidence;
- PASS / FAIL / NOT VERIFIED.

G1-GATE cannot pass until all G1 real-execution seams have evidence.

## 12. DSH long-play carry-forward reference

The DSH long-play experiment is now substantially complete. Its cross-stage findings are summarized in:

`docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`

The underlying experiment closure reference is:

`zhangchenjia21-dot/the-world/docs/DSH_GAME_TEST_LESSONS_CORE.md`

This repository-local carry-forward document is **not** a Task Packet and does not authorize prebuilding G2–G9 during G1. It becomes mandatory reading whenever a task touches:

- G3 persistence / Timeline / Save / Restore;
- G4 World Pack / Source / local reality;
- G5 NPC / Faction / GM Runtime / World Evolution;
- G6 RPG UI / map / presentation truth projection;
- G7 long-session context / performance;
- G8 Mod / authoring semantics;
- G9 long-play Product Value UAT.

The most important newly confirmed DSH failure to avoid is **Protagonist Causal Monopoly**: a persistent world can still feel dead if Source history and player actions are the only real causes of new history while NPCs/factions mainly react. Future world semantics must preserve:

> **Source provides inertia, actors create history.**

> **Off-screen != Inactive.**

> **Players may change history, but they are not the only creators of history.**

Do not solve this by building a universal per-NPC tick simulator or by mechanically increasing DCs. G5 must find a bounded, event/priority-driven autonomous world-evolution approach and prove it with Player Absence, Counterfactual Propagation, and Independent Actor tests.
