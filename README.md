# my world

`my world` 是一个独立、本地优先、长期单人游玩的 **2D 自然语言 AI RPG / 互动小说**。

本仓库保存**实现事实**：Godot 工程、代码、测试、构建与本地启动方式。长期产品定义、架构、路线图和当前项目状态由 `zhangchenjia21-dot/Vibe-Coding/my world/` 维护；跨项目可复用 Skill 已统一并入 `zhangchenjia21-dot/Vibe-Coding/skill/`。

> **迁移经验，不迁移宿主债务。**

## Start Here

开发 Agent 先读 [`AGENTS.md`](AGENTS.md)。治理侧默认从以下稳定入口按任务需要读取：

```text
Vibe-Coding/AGENTS.md
Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md
Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md
Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md
Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md
Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md
```

需要正式 Task Packet 或生命周期方法时再读：

```text
Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md
Vibe-Coding/skill/gpt/lifecycle-dev-process/SKILL.md
```

不要默认读取整个治理仓库或全部历史文档。

## 当前阶段

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistent Game / Save / Timeline PASS / CLOSED
G3-GATE                               PASS
Current Phase                         G4 — Primary Source Assets & Local Game Creation
```

**精确 Current Task、Owner UAT、blocker 与下一 Gate 只看：**

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

README 不维护第二份滚动任务状态。

G4 第一代建局已冻结为正式资产驱动路径：

```text
Main Menu
→ World Pack
→ Entry / T0
→ Expansion 0..N（可 none）
→ Exactly 1 Player Character Card
→ 0..N Guaranteed NPC Character Cards
→ minimal settings / Compatibility Review
→ Atomic Final Create
→ independent Game-local Reality
```

第一轮 First Playable 先验证 **World + Character**；通过后再加入真实 Expansion，避免第一次试玩同时叠加过多高风险变量。

## 第一代技术基线

```text
Host          Godot 4.7.2
Distribution  Standard / non-.NET Windows x64
Language      GDScript
Runtime       same-process Godot Runtime
Provider      DeepSeek deepseek-v4-pro
Persistence   SQLite via godot-sqlite v4.9
```

Godot 负责窗口、2D、UI、输入、字体、图片、音频、资源和 Windows packaging 等成熟通用能力；`my world` 自己拥有 Game / World / Timeline / Save / Conversation / NPC / Faction / Knowledge / Relationship / Agent Context / World Pack 等游戏语义。

> **Engine-native, not engine-semantic-coupled.**

## 产品与 Runtime 原则速览

> **Model freedom first. Reversibility over prevention.**
>
> **Narrative richness over artificial brevity.**
>
> **Model authors the world; Runtime makes it durable; Player owns the timeline.**
>
> **Save Point != Timeline Node.**
>
> **Source provides inertia; actors create history.**
>
> **Off-screen != Inactive.**
>
> **Context stays bounded, not starved.**
>
> **Application Lifetime != Game Session Lifetime.**
>
> **Source stable identity != exact immutable generation.**

局内 UI 长期骨架：

```text
Player Host | Narrative Host | World Surface Host
```

Narrative 是视觉与交互重心；UI 只投影 authoritative game truth，不建立第二事实源。

## API Key

真实 Provider Secret 只保存在本地 `.env.local`，不得提交 Git、粘贴到聊天、日志或截图。

```text
DEEPSEEK_API_KEY=<local secret>
# optional
MY_WORLD_DEEPSEEK_MODEL=deepseek-v4-pro
```

`.env.local` 已被 Git 忽略。

## 运行游戏｜Owner / 玩家路径

正常产品路径：

```text
run-game.cmd
```

或：

```powershell
Set-Location 'D:\AI\Projects\my-world'
.\run-game.ps1
```

导出程序位于：

`build\windows\my-world.exe`

如果 EXE 尚未构建，应由开发 Agent 完成 export，不要求 Owner 打开 Godot Editor 或自己排查构建。

## 开发者路径

需要打开 Godot Editor 时：

```powershell
.\run-local.ps1
```

本地 Godot：

```text
D:\AI\Engine\Godot_v4.7.2-stable_win64.exe
D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe
```

Routine Git / Godot / build / automated QA 由 AI Agent 完成；Owner 只负责真实产品体验、Secrets 与不可替代的产品 / 架构裁定。