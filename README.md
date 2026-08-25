# my world

`my world` is a standalone, local-first, single-player 2D conversational AI RPG project.

This repository contains implementation truth: code, tests, build/runtime configuration, and project-local agent instructions. Long-lived product/governance decisions live in `zhangchenjia21-dot/Vibe-Coding` under `my world/`.

## Current status

- Phase: `G1 — Foundation & Project Bootstrap`
- Current task: `G1-01 — Repository Bootstrap`
- Foundation candidate: Godot `v4.7.2`
- Local project directory: `D:\AI\Projects\my-world`
- Local engine directory: `D:\AI\Engine`
- Repository bootstrap started from an empty GitHub repository on 2026-08-25.

## Verified local toolchain evidence

The following Windows-local evidence was reported from direct Codex execution on 2026-08-25:

- Godot version: `4.7.2.stable.official.ed1daf0bf`
- Godot distribution: Standard / non-.NET Windows x64 package
- GUI executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64.exe`
- Console executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe`
- Git: `git version 2.54.0.windows.1`
- OS architecture: `X64`

This evidence is sufficient to create a minimal Godot project shape. It does **not** freeze GDScript vs C#, Runtime process boundaries, persistence technology, export behavior, or any downstream architecture decision.

## Authority

Before implementation work, read the current sources on GitHub `main` in this order:

1. The user's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`.
6. `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`.
7. This repository's current code, tests, and HEAD.

The World / DSH is a reference implementation and evidence source, not a code migration template.

## Foundation rules

- Migrate product experience, not DSH host debt.
- Prefer mature commodity foundation capabilities; own game semantics explicitly.
- Be engine-native without coupling `Game`, `World`, `Timeline`, `Save`, `NPC`, `Agent Context`, or `World Pack` semantics to Godot Scene/Node/Resource concepts.
- UI projects game truth; it does not become a second truth source.
- Do not prebuild G2–G9 architecture during G1.

## G1-01 bootstrap boundary

The repository now contains a deliberately minimal Godot project surface:

- `project.godot`
- `src/main.tscn`

The bootstrap scene contains no gameplay architecture and no script-language commitment. It exists only to prove the repository can host and launch a Godot 4.7.2 project before the later Foundation Spike tasks add real test surfaces.

No placeholder test tree, persistence layer, provider layer, World Pack schema, or future module hierarchy should be added merely for completeness.

## Local validation still required

After syncing this repository to `D:\AI\Projects\my-world`, run the minimal project with the verified executable:

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --path 'D:\AI\Projects\my-world'
```

Expected evidence for G1-01 runtime completion:

1. Godot starts the project without parse/config errors.
2. A window opens successfully.
3. The window displays `my world` and `G1 Foundation Spike`.
4. Closing the window exits normally.
5. `git status --short` is reviewed so generated `.godot/` cache files are confirmed ignored.

Current local blocker observed on 2026-08-25: the execution environment could not write `.git/FETCH_HEAD` and Godot could not create `user://logs` / `user://vulkan` cache directories. Treat this as a Windows/local execution-permission blocker until filesystem write access is verified. Do not mark the runtime check PASS before that is resolved.
