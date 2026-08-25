# my world — Repository Agent Rules

Status: current repository instruction
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` explicitly narrows a subtree.

## 1. Authority and freshness

For every new formal task, do not rely on chat memory or stale local copies. Resolve current authority from GitHub `main` in this order:

1. The user's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`.
6. `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`.
7. This repository's current implementation, tests, and HEAD.

If a new current decision changes the stage, task, prerequisite, architecture boundary, contract timing, or task DAG, propagate that decision before continuing old work.

Before writing authoritative `main`, re-check current HEAD. Do not silently overwrite changes made after the task base.

## 2. Current stage boundary

Current phase: `G1 — Foundation & Project Bootstrap`.

Current task: `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`.

`G1-01 — Repository Bootstrap` is **PASS** based on real Windows runtime evidence.

G1 is a Foundation Spike stage. Prefer:

```text
focused exploration
→ real executable proof
→ architecture decision
→ small commit
→ reality check
→ next task
```

Do not implement large portions of G2–G9 early merely to make the repository look complete.

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

## 5. G1 implementation discipline

Until Foundation Spike evidence exists:

- do not freeze the long-term persistence schema;
- do not freeze the full World Pack schema;
- do not freeze NPC Runtime architecture;
- do not freeze the full RPG UI architecture;
- do not build multiplayer, server backend, cloud accounts/saves, 3D free movement, automatic map generation, universal ECS, whole-world tick simulation, Steam Workshop, local LLM hosting, TTS/STT, a complex script sandbox, or a multi-provider routing platform;
- do not create speculative empty module trees or universal abstractions.

Verified Windows-local toolchain evidence as of 2026-08-25:

- Godot: `4.7.2.stable.official.ed1daf0bf`
- Distribution: Standard / non-.NET Windows x64 package
- GUI executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64.exe`
- Console executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe`
- Git: `2.54.0.windows.1`
- OS architecture: `X64`
- Renderer: Vulkan / Forward+
- GPU: NVIDIA GeForce RTX 4070 Laptop GPU

G1-01 runtime proof also confirmed normal PowerShell write access to Git metadata and Godot `user://`, successful minimal-project launch, expected window contents, exit code `0`, and a clean Git working tree after exit.

Earlier write failures observed under Codex were caused by Codex execution sandbox boundaries. Do not modify Windows ACLs or application architecture to work around those sandbox-only errors.

## 6. G1-02 toolchain boundary

Current G1-02 facts and provisional decisions:

- The installed Godot is Standard / non-.NET.
- The installed Standard build is the current Foundation Spike host.
- GDScript is the lowest-dependency language candidate for immediate G1 spikes.
- This is **not** the final GDScript/C#/mixed architecture decision; G1-06 owns that decision.
- Do not install .NET-enabled Godot or a .NET SDK only for hypothetical future use.
- If C# becomes a real candidate, introduce the required .NET-enabled Godot editor and .NET SDK explicitly and document the evidence motivating it.
- Windows Export final functionality belongs to G1-05; G1-02 only verifies that local export templates / CLI tooling are available.
- An external local runtime process is not a prerequisite for G1-03. Same-process vs local-runtime-process remains open until G1-04/G1-05 evidence and G1-06.

Do not start G1-03 implementation until G1-02's export-tooling check is recorded PASS or a concrete blocker is identified.

## 7. Repository shape

Create only files and directories that have immediate use:

- `README.md`
- `AGENTS.md`
- `.gitignore`
- `project.godot`
- `src/` only for immediately runnable Foundation content
- `tests/` and `docs/` only when real validation or implementation needs them

Do not add placeholder directories solely for future architecture.

The initial `src/main.tscn` is a language-neutral bootstrap scene. Its presence is not approval to build G2+ application architecture during G1.

## 8. Validation and evidence

Never claim Windows-local, Godot, export, or Provider success without real execution evidence.

For changes that require local Godot validation, report separately:

- what GitHub-side work is complete;
- what exact local command or action must run;
- expected observable evidence;
- whether the result is PASS, FAIL, or NOT VERIFIED.

G1-GATE cannot pass from repository structure alone. It requires real executable proof for Godot runtime, long Chinese text/input, real provider streaming/cancel, non-freezing background work, local IO, dynamic images, Windows export, and the Runtime boundary decision.

## 9. Security and secrets

Never commit provider API keys, tokens, credentials, local secrets, or `.env` files containing secrets. Prefer environment variables or local untracked configuration, with sanitized examples where needed.
