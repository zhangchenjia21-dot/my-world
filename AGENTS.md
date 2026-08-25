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

Current task: `G1-03 — 2D Chinese Long Text / Input Foundation Spike`.

Completed:

- `G1-01 — Repository Bootstrap`: **PASS** based on real Windows runtime evidence.
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS** based on local CLI/export-template/ICU verification.

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

## 5. Verified Foundation facts

Verified Windows-local toolchain evidence as of 2026-08-25:

- Godot: `4.7.2.stable.official.ed1daf0bf`
- Distribution: Standard / non-.NET Windows x64 package
- GUI executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64.exe`
- Console executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe`
- Git: `2.54.0.windows.1`
- OS architecture: `X64`
- Renderer: Vulkan / Forward+
- GPU: NVIDIA GeForce RTX 4070 Laptop GPU
- CLI export commands: present
- Windows x86_64 export templates: installed and verified
- ICU Data: installed and verified

G1-01 runtime proof confirmed normal PowerShell write access to Git metadata and Godot `user://`, successful minimal-project launch, expected window contents, exit code `0`, and a clean working tree after exit.

Earlier write failures observed under Codex were caused by Codex execution sandbox boundaries. Do not modify Windows ACLs or application architecture to work around those sandbox-only errors.

## 6. G1-03 implementation boundary

G1-03 exists only to prove these Host seams:

- Chinese text rendering;
- long transcript scrolling;
- incremental append behavior;
- player text input;
- text selection / copy;
- usable UI under materially larger text volume.

The current implementation may use GDScript because it is the lowest-dependency provisional spike language. This is **not** the final GDScript/C#/mixed decision; G1-06 owns that decision.

For this spike:

- `SystemFont` may prefer Windows CJK fonts such as Microsoft YaHei to test the local Host seam;
- this does not define the final shipping-font/asset strategy;
- timer-driven local append may simulate continuous text growth;
- simulated append does **not** count as Provider streaming evidence;
- do not add API clients, secrets, Provider abstractions, persistence, World Pack schema, domain architecture, or formal RPG UI architecture;
- do not create `export_presets.cfg` or perform the G1-05 Windows functional-export proof early unless a new current decision explicitly moves it forward.

G1-03 is not PASS until real Windows-local manual evidence covers rendering, scrolling, append, Chinese input, selection/copy, responsiveness, normal exit, and clean Git state.

## 7. Future G1 boundaries

- G1-04 owns the real Provider stream / cancel / non-freezing network proof.
- G1-05 owns local IO, dynamic images, and functional Windows export proof.
- G1-06 owns Godot Host, Standard/.NET, GDScript/C#/mixed, and same-process vs local-runtime-process architecture decisions.

Do not pull these decisions forward merely because G1-03 uses one convenient implementation technique.

## 8. Repository shape

Create only files and directories that have immediate use:

- `README.md`
- `AGENTS.md`
- `.gitignore`
- `project.godot`
- `src/` only for immediately runnable Foundation content
- `tests/` and `docs/` only when real validation or implementation needs them

Do not add placeholder directories solely for future architecture.

## 9. Validation and evidence

Never claim Windows-local, Godot, export, or Provider success without real execution evidence.

For changes that require local Godot validation, report separately:

- what GitHub-side work is complete;
- what exact local command or action must run;
- expected observable evidence;
- whether the result is PASS, FAIL, or NOT VERIFIED.

G1-GATE cannot pass from repository structure alone. It requires real executable proof for Godot runtime, long Chinese text/input, real provider streaming/cancel, non-freezing background work, local IO, dynamic images, Windows export, and the Runtime boundary decision.

## 10. Security and secrets

Never commit provider API keys, tokens, credentials, local secrets, or `.env` files containing secrets. Prefer environment variables or local untracked configuration, with sanitized examples where needed.
