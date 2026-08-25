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

Current task: `G1-04 — Real Provider Streaming / Cancel Foundation Spike`.

Completed:

- `G1-01 — Repository Bootstrap`: **PASS**.
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS**.
- `G1-03 — 2D Chinese Long Text / Input Foundation Spike`: **PASS** based on real Windows manual UAT.

Current G1-04 scope is explicitly **DeepSeek + Kimi**. Both real Provider paths must be proven before G1-04 can PASS.

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

## 6. G1-04 implementation boundary

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

### Required Provider B — Kimi / Moonshot AI

```text
host = api.moonshot.ai
path = /v1/chat/completions
default model = kimi-k3
key env = MOONSHOT_API_KEY
optional model override = MY_WORLD_G1_04_KIMI_MODEL
```

Both are OpenAI-compatible chat-completions/SSE shapes for this spike, so reuse the small common HTTP/SSE parsing path where reality permits. Keep provider-specific host/path/key/model explicit.

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

## 7. Security and secrets

Never commit provider API keys, tokens, credentials, cookies, or local secrets.

For G1-04:

- DeepSeek key comes only from `DEEPSEEK_API_KEY`;
- Kimi key comes only from `MOONSHOT_API_KEY`;
- UI may show only whether each variable is set;
- never display/log either key value;
- never place keys in `.gd`, `.tscn`, `project.godot`, README examples, screenshots, commits, or chat;
- deterministic failure testing must not carry `Authorization` headers.

## 8. Validation boundary

G1-04 is not PASS until real Windows-local observation proves:

- DeepSeek real HTTP 2xx + incremental stream;
- Kimi real HTTP 2xx + incremental stream;
- UI heartbeat/manual interaction continue during each Provider request;
- a real active generation can be cancelled and UI promptly recovers;
- at least one real request succeeds after cancellation;
- Provider can be switched while idle without app restart;
- deterministic connection failure is explicit and non-freezing;
- Provider/API errors are readable, not silent hangs;
- normal exit;
- clean Git state.

Repository structure, static code review, mocked chunks, or G1-03 timer append cannot substitute for the real Provider evidence.

## 9. Later G1 boundaries

- G1-05 owns local IO, dynamic images, and functional Windows export proof.
- G1-06 owns Godot Host, Standard/.NET, GDScript/C#/mixed, persistence candidate range, Provider/product configuration boundary, and same-process vs local-runtime-process architecture decisions.

Do not pull those decisions into G1-04.

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
