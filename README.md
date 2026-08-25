# my world

`my world` is a standalone, local-first, single-player 2D conversational AI RPG project.

This repository contains implementation truth: code, tests, build/runtime configuration, and project-local agent instructions. Long-lived product/governance decisions live in `zhangchenjia21-dot/Vibe-Coding` under `my world/`.

## Current status

- Phase: `G1 — Foundation & Project Bootstrap`
- Current task: `G1-03 — 2D Chinese Long Text / Input Foundation Spike`
- `G1-01 — Repository Bootstrap`: **PASS**
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS**
- Foundation candidate: Godot `v4.7.2`
- Local project directory: `D:\AI\Projects\my-world`
- Local engine directory: `D:\AI\Engine`

## Verified local toolchain evidence

Windows-local evidence confirmed on 2026-08-25:

- Godot version: `4.7.2.stable.official.ed1daf0bf`
- Godot distribution: Standard / non-.NET Windows x64 package
- GUI executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64.exe`
- Console executable: `D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe`
- Git: `git version 2.54.0.windows.1`
- OS architecture: `X64`
- Renderer: Vulkan / Forward+
- GPU: NVIDIA GeForce RTX 4070 Laptop GPU
- CLI export commands: `--export-release`, `--export-debug`, `--export-pack`
- Godot 4.7.2 Windows x86_64 export templates: installed and locally verified
- ICU Data: installed and locally verified

G1-01 runtime verification confirmed normal Windows PowerShell write access to Git metadata and Godot `user://`, successful minimal-project launch, expected window contents, exit code `0`, and a clean Git working tree after exit. Earlier write failures under Codex were isolated to the Codex execution sandbox, not Windows ACLs or the project.

## Authority

Before implementation work, read the current sources on GitHub `main` in this order:

1. The user's current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`.
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`.
5. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`.
6. `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`.
7. This repository's current implementation, tests, and HEAD.

The World / DSH is a reference implementation and evidence source, not a code migration template.

## Foundation rules

- Migrate product experience, not DSH host debt.
- Prefer mature commodity foundation capabilities; own game semantics explicitly.
- Be engine-native without coupling `Game`, `World`, `Timeline`, `Save`, `NPC`, `Agent Context`, or `World Pack` semantics to Godot Scene/Node/Resource concepts.
- UI projects game truth; it does not become a second truth source.
- Do not prebuild G2–G9 architecture during G1.

## G1-02 result

G1-02 is complete and passed.

The immediate Foundation Spike language candidate is **GDScript** because the installed host is Standard / non-.NET Godot and GDScript adds no extra toolchain dependency. This is provisional only: G1-06 still owns the final GDScript / C# / mixed decision.

Do not install .NET-enabled Godot or a .NET SDK merely for hypothetical future needs. If C# becomes a real comparison candidate, add that toolchain deliberately and record the evidence motivating it.

Windows export tooling/templates are ready, but the actual functional Windows build proof remains G1-05.

## G1-03 spike surface

G1-03 adds only the minimum executable surface needed to test text/input Host seams:

- `src/main.tscn`
- `src/g1_03_text_input_spike.gd`

The scene provides:

- Windows system-font lookup preferring Microsoft YaHei / CJK fonts for this local spike;
- a `RichTextLabel` with scrolling, selection, context menu, and `Ctrl+C` support;
- seeded Chinese long-form text;
- one-paragraph and 300-paragraph append controls;
- timer-driven simulated incremental append to stress continuous text updates;
- a multiline player `TextEdit` with Chinese input and `Ctrl+Enter` submission;
- live character / paragraph counts.

The system-font choice is **not** the final shipping font strategy. The timer-driven append is **not** evidence for real Provider streaming; G1-04 owns that proof.

## Local G1-03 validation

Sync and launch in ordinary Windows PowerShell:

```powershell
Set-Location 'D:\AI\Projects\my-world'
git pull --ff-only origin main
git rev-parse HEAD
git status --short

& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --path 'D:\AI\Projects\my-world'
```

Manual PASS evidence required before G1-03 can close:

1. Chinese title, seeded paragraphs, buttons, placeholder, and status text render without obvious missing-glyph boxes or corruption.
2. The seeded transcript scrolls normally.
3. `追加 300 段` materially increases the transcript and scrolling remains usable.
4. `开始模拟持续追加` continuously appends text while the window remains responsive; it can also be stopped.
5. Chinese text can be entered into the player input area and appended with the button or `Ctrl+Enter`.
6. Transcript text can be selected with the mouse and copied with `Ctrl+C` into another app.
7. Repeated burst/stream operations do not cause obvious layout collapse, lock-up, or severe interaction failure.
8. Closing the window exits normally.
9. `git status --short` is clean afterward (`.godot/` remains ignored).

Do not mark G1-03 PASS from repository structure alone. Real local observation is required.
