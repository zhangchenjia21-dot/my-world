# my world

`my world` is a standalone, local-first, single-player 2D conversational AI RPG project.

This repository contains implementation truth: code, tests, build/runtime configuration, and project-local agent instructions. Long-lived product/governance decisions live in `zhangchenjia21-dot/Vibe-Coding` under `my world/`.

## Current status

- Phase: `G1 — Foundation & Project Bootstrap`
- Current task: `G1-04 — Real Provider Streaming / Cancel Foundation Spike`
- `G1-01 — Repository Bootstrap`: **PASS**
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS**
- `G1-03 — 2D Chinese Long Text / Input Foundation Spike`: **PASS** based on real Windows manual UAT
- Foundation candidate: Godot `v4.7.2`
- Local project directory: `D:\AI\Projects\my-world`
- Local engine directory: `D:\AI\Engine`

## Verified Foundation evidence

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

G1-01 runtime proof confirmed normal Windows PowerShell write access to Git metadata and Godot `user://`, successful launch/exit, expected window contents, and a clean working tree.

G1-03 manual UAT confirmed Chinese rendering, long-text scrolling, bulk append, continuous append responsiveness, Chinese input, selection/copy, normal exit, and clean Git state. The local simulated append used by G1-03 is not Provider evidence; G1-04 now replaces it with a real network stream.

## Authority

Before implementation work, read current GitHub `main` in this order:

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

## G1-04 exploratory provider choice

G1-04 needs one real Provider, not a multi-provider platform. For this Foundation Spike the concrete exploratory Provider is **DeepSeek Chat Completions**:

```text
POST https://api.deepseek.com/chat/completions
stream = true
model = deepseek-v4-pro   # default; locally overridable for the spike
```

This is an execution choice for G1-04, **not** the final product Provider decision. G1-06 still owns the broader Foundation Architecture Decision.

The current surface is intentionally narrow:

- `src/main.tscn`
- `src/g1_04_provider_stream_spike.gd`
- Godot `HTTPClient` in its default non-blocking mode
- `poll()` on the main loop and incremental `read_response_body_chunk()` reads
- SSE parsing for `data: {...}` and `data: [DONE]`
- real streamed text appended into the existing Godot reading surface
- explicit Cancel by closing the active transport
- UI heartbeat + manual response counter during network activity
- deterministic connection-failure path using `127.0.0.1:1` with **no credentials**

This is not a production Provider abstraction, retry platform, routing layer, or final Runtime boundary.

## Secrets

Never commit or paste API keys into repository files. G1-04 reads the key only from the process environment:

```text
DEEPSEEK_API_KEY
```

Optional spike-only model override:

```text
MY_WORLD_G1_04_MODEL
```

The UI reports only whether the key exists; it never displays the key value.

## Local G1-04 validation

Use ordinary Windows PowerShell. Do **not** send the API key in chat.

```powershell
Set-Location 'D:\AI\Projects\my-world'
git pull --ff-only origin main
git rev-parse HEAD
git status --short

$env:DEEPSEEK_API_KEY = '<your key locally>'
# Optional; the default is deepseek-v4-pro
# $env:MY_WORLD_G1_04_MODEL = 'deepseek-v4-pro'

& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --path 'D:\AI\Projects\my-world'
```

Manual PASS evidence required before G1-04 can close:

1. The UI reports `DEEPSEEK_API_KEY: 已设置` without displaying its value.
2. `发送真实请求` reaches the real Provider and HTTP 2xx is observed.
3. GM text appears incrementally while generation is still in progress, not only as one final body.
4. While streaming, the `UI heartbeat` keeps increasing and `UI 响应 +1` remains clickable.
5. `Cancel` stops an in-progress generation promptly and the UI remains usable.
6. A new real request can be started after cancellation.
7. `连接失败测试` produces a clear handled failure message and does not freeze the UI.
8. Provider/API failures are surfaced as readable errors rather than silently hanging.
9. Closing the window exits normally.
10. `git status --short` is clean afterward (`.godot/` remains ignored).

Do not mark G1-04 PASS from repository structure or simulated data. A real Provider request and real cancel observation are required.

## Later G1 boundaries

- G1-05 owns local IO, dynamic portrait/scene/map-style image loading, and functional Windows export proof.
- G1-06 owns the final first-generation Host/toolchain/language/runtime-boundary decision.
- Same-process Godot networking in this spike is evidence, not a final same-process Runtime commitment.
