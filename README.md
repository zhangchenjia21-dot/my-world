# my world

`my world` is a standalone, local-first, single-player 2D conversational AI RPG project.

This repository contains implementation truth: code, tests, build/runtime configuration, and project-local agent instructions. Long-lived product/governance decisions live in `zhangchenjia21-dot/Vibe-Coding` under `my world/`.

## Current status

- Phase: `G1 — Foundation & Project Bootstrap`
- Current task: `G1-05 — Local IO / Image / Windows Export Foundation Spike`
- `G1-01 — Repository Bootstrap`: **PASS**
- `G1-02 — Godot 4.7.2 Toolchain & Language Confirmation`: **PASS**
- `G1-03 — 2D Chinese Long Text / Input Foundation Spike`: **PASS** based on real Windows manual UAT
- `G1-04 — Real Provider Streaming / Cancel Foundation Spike`: **PASS** based on real Windows Owner UAT
- Foundation candidate: Godot `v4.7.2`
- Local project directory: `D:\AI\Projects\my-world`
- Local engine directory: `D:\AI\Engine`

## Verified Foundation evidence

Windows-local evidence confirmed on 2026-08-25:

- Godot version: `4.7.2.stable.official.ed1daf0bf`
- Distribution: Standard / non-.NET Windows x64
- Renderer: Vulkan / Forward+
- GPU: NVIDIA GeForce RTX 4070 Laptop GPU
- Git: `2.54.0.windows.1`
- Windows x86_64 export templates: installed and verified
- ICU Data: installed and verified

G1-01 proved normal Windows runtime/write behavior and clean exit. Earlier Codex write failures were sandbox-only.

G1-03 manual UAT proved Chinese rendering, long-text scrolling, bulk append, continuous append responsiveness, Chinese input, selection/copy, normal exit, and clean Git state.

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

## G1-04 closeout

G1-04 used **two** real Providers as a narrow Foundation Spike, not as a generic provider-platform commitment.

### DeepSeek

```text
POST https://api.deepseek.com/chat/completions
stream = true
default model = deepseek-v4-pro
API key env = DEEPSEEK_API_KEY
optional model env = MY_WORLD_G1_04_DEEPSEEK_MODEL
```

### Kimi Code API

```text
POST https://api.kimi.com/coding/v1/chat/completions
stream = true
default model = k3
API key env = KIMI_CODE_API_KEY
optional model env = MY_WORLD_G1_04_KIMI_MODEL
```

The scene exposes an explicit DeepSeek/Kimi Code selector. Both paths reuse the same small OpenAI-compatible HTTP/SSE seam where possible, but host/path/key/model remain separate. Kimi Code replaces the superseded Kimi configuration; there is no compatibility fallback, automatic routing, fallback mesh, load balancing, provider registry, or account system.

Godot uses non-blocking `HTTPClient`, main-loop `poll()`, incremental response-body reads, SSE `data:` parsing, `[DONE]` completion, explicit transport close for Cancel, a UI heartbeat/manual response counter, and a deterministic credential-free failure test against `127.0.0.1:1`.

Owner Windows UAT proved real HTTP success, incremental streaming, active cancellation, successful post-cancel requests, idle Provider switching, deterministic connection failure, UI heartbeat/manual responsiveness, normal exit, and clean Git state for the required boundary. G1-04 is **PASS**.

Both Providers took roughly 30 seconds to complete the observed long outputs. This is not a G1-04 blocker. G2 may later measure TTFT and generation throughput separately; this closeout does not optimize Provider latency. Same-process networking remains Foundation evidence only, and G1-06 still owns the Runtime-boundary decision.

## Secrets

Never commit or paste Provider API keys into repository files or chat. G1-04 reads keys only from the launching process environment:

```text
DEEPSEEK_API_KEY
KIMI_CODE_API_KEY
```

The UI may show only `已设置 / 未设置`; it must never display key values.

## Current G1-05 boundary

G1-05 is a Foundation exploration that must prove:

- a tiny local probe can be written, closed, reopened, read back, and retained across application launches;
- portrait-like, scene-like, and map-like images are decoded from real filesystem files and displayed;
- a Windows export succeeds and the exported executable launches without the Godot Editor;
- local IO and all three dynamic image roles still work in the exported executable, including after close/reopen.

This is not the production Save schema, persistence architecture, final asset pipeline, World Pack schema, or mod loader. Do not refactor the passed Provider seam.

## Later G1 boundary

- G1-06 owns the final first-generation Host/toolchain/language/runtime-boundary decision.

## DSH long-play carry-forward

The DSH long-play experiment is now substantially complete. Its actionable lessons for this project are summarized in:

[`docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`](docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md)

This is a cross-stage reference, not a current implementation task. It becomes especially important for G3–G9 and records the major proven requirements around Timeline/Restore, World Pack semantics, autonomous NPC/faction behavior, counterfactual propagation, long-session performance, authored maps, and final long-play UAT.

Key product lesson:

> **Persistent World is necessary, but Persistent World is not the same as an Autonomous Evolving World.**

> **Source provides inertia, actors create history.**
