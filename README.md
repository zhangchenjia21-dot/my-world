# my world

`my world` is a standalone, local-first, single-player 2D conversational AI RPG project.

This repository contains implementation truth: code, tests, build/runtime configuration, and project-local agent instructions. Long-lived product/governance decisions live in `zhangchenjia21-dot/Vibe-Coding` under `my world/`.

## Current status

- Phase: `G1 — Foundation & Project Bootstrap`
- Current task: `G1-01 — Repository Bootstrap`
- Foundation candidate: Godot `v4.7.2`
- Local project directory: `D:\AI\Projects\my world`
- Local engine directory: `D:\AI\Engine`
- Repository bootstrap started from an empty GitHub repository on 2026-08-25.

Godot `v4.7.2` is the current project-level Foundation candidate. The actual local executable path and Standard vs .NET distribution still require direct Windows verification before this repository adds a committed `project.godot` or chooses GDScript/C# boundaries.

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

The initial GitHub-side bootstrap intentionally contains only the files needed to establish repository governance and hygiene. `project.godot`, source directories, test directories, and build/export structure are added only when supported by real Foundation Spike evidence.

Immediate local verification still required:

1. Locate the actual Godot executable under `D:\AI\Engine`.
2. Run it to confirm version `4.7.2`.
3. Determine Standard vs .NET distribution.
4. Record the executable/CLI command and basic Windows environment facts needed by G1.
5. Only then create and run the minimal Godot project for the next Foundation step.

Do not mark local runtime or export checks as passed without real execution evidence.
