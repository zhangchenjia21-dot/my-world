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

If a current decision changes the stage, task, prerequisite, architecture boundary, contract timing, or task DAG, propagate that decision before continuing old work.

Before authoritative `main` writes, re-check current HEAD. Do not silently overwrite changes made after the task base.

## 2. Current stage boundary

Current phase: `G1 — Foundation & Project Bootstrap`.

Current task: `G1-04 — Real Provider Streaming / Cancel Foundation Spike`.

Completed:

- `G1-01 — Repository Bootstrap`: **PASS** based on real Windows runtime evidence.
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS** based on local CLI/export-template/ICU verification.
- `G1-03 — 2D Chinese Long Text / Input Foundation Spike`: **PASS** based on real Windows manual UAT.

G1 is a Foundation Spike stage. Prefer:

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

- Godot: `4.7.2.stable.official.ed1daf0bf`
- Distribution: Standard / non-.NET Windows x64
- GUI: `D:\AI\Engine\Godot_v4.7.2-stable_win64.exe`
- Console: `D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe`
- Git: `2.54.0.windows.1`
- OS architecture: `X64`
- Renderer: Vulkan / Forward+
- GPU: NVIDIA GeForce RTX 4070 Laptop GPU
- Windows x86_64 export templates: installed and verified
- ICU Data: installed and verified

G1-01 proved normal local write/runtime behavior. Earlier Codex write failures were sandbox-only.

G1-03 manual UAT proved Chinese rendering, long scrolling, bulk/continuous append behavior, Chinese input, selection/copy, UI responsiveness, normal exit, and clean Git state.

## 6. G1-04 implementation boundary

G1-04 exists only to prove:

- a real Provider request can be made from the Godot Foundation surface;
- real output arrives incrementally;
- cancel works during generation;
- network/API failures have explicit user-visible states;
- the UI main loop remains responsive during the request.

The concrete exploratory Provider for this spike is DeepSeek Chat Completions:

```text
POST https://api.deepseek.com/chat/completions
stream = true
```

Default model for this spike: `deepseek-v4-pro`, locally overridable through `MY_WORLD_G1_04_MODEL` if needed.

This is **not** a final Provider product decision and is **not** approval to build a multi-provider platform.

Implementation constraints:

- use the provisional GDScript surface only because it is the current lowest-dependency spike language;
- use Godot `HTTPClient` non-blocking polling and incremental response-body reads;
- parse only the SSE shape required for this concrete spike;
- cancellation may close the active HTTP transport; do not invent production turn/cancel domain semantics yet;
- same-process networking is evidence only, not the G1-06 Runtime-boundary decision;
- keep Provider logic inside the spike surface rather than creating a large adapter hierarchy;
- do not add persistence, World Pack schema, formal Game/Turn domain architecture, retry meshes, routing, fallback meshes, telemetry platforms, or account systems.

## 7. Security and secrets

Never commit provider API keys, tokens, credentials, cookies, or local secrets.

For G1-04 specifically:

- read the DeepSeek key only from `DEEPSEEK_API_KEY` in the local process environment;
- never display the key value in UI or logs;
- never add the key to `project.godot`, `.tscn`, `.gd`, README examples, screenshots, commits, or chat messages;
- the deterministic connection-failure test must not transmit credentials and currently targets `127.0.0.1:1`.

If local secret configuration is missing, report that as a local prerequisite; do not commit a workaround secret.

## 8. Validation boundary

G1-04 is not PASS until real Windows-local observation proves all of the following:

- real Provider HTTP success;
- real incremental streamed content;
- UI heartbeat/manual interaction continues while streaming;
- cancel stops a real active generation and the UI recovers;
- a subsequent request can run after cancel;
- connection/API failure states are explicit and non-freezing;
- normal exit;
- clean Git working tree.

Repository structure, mocked chunks, G1-03 timer append, or static code review cannot substitute for the real Provider evidence.

## 9. Later G1 boundaries

- G1-05 owns local IO, dynamic images, and functional Windows export proof.
- G1-06 owns Godot Host, Standard/.NET, GDScript/C#/mixed, persistence candidate range, and same-process vs local-runtime-process architecture decisions.

Do not pull those decisions into G1-04.

## 10. Repository shape

Create only files and directories with immediate use. During G1 keep the surface small:

- `README.md`
- `AGENTS.md`
- `.gitignore`
- `project.godot`
- `src/` for the current runnable Foundation spike
- `tests/` / `docs/` only when a real validation need exists

Do not create speculative empty module trees.

## 11. Evidence discipline

Never claim Windows-local, Godot, Provider, export, or network success without real execution evidence.

For local validation, always separate:

- GitHub-side implementation complete;
- exact local command/action;
- expected observable evidence;
- PASS / FAIL / NOT VERIFIED.

G1-GATE cannot pass until all G1 real-execution seams have evidence.
