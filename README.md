# my world

`my world` 是一个独立、本地优先、长期单人游玩的 **2D 自然语言 AI RPG / 互动小说**。

这个仓库保存**实现事实**：Godot 工程、代码、测试、构建与本地启动方式。长期产品定义、架构、路线图和当前项目状态由 `zhangchenjia21-dot/Vibe-Coding/my world/` 维护。

> **迁移经验，不迁移宿主债务。**

## 当前状态

当前阶段是 `G2 — AI Conversation Spine`；当前 Task 为 `G2-03 — Narrative Conversation View`，已经出现实现 commit，但 Product PASS 仍等待工程 closeout / Owner UAT。

**不要把 README 当 current task 数据库。** 最新状态只看：

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

## 面向人的五份核心治理文档

```text
MY_WORLD_项目启动总纲_CURRENT.md   产品是什么 / 为什么做
MY_WORLD_核心设计原则_CURRENT.md   跨阶段不能丢失的原则
MY_WORLD_架构_CURRENT.md           当前系统架构地图 + 专题导航
MY_WORLD_总体规划路线图_CURRENT.md G1–G9 顺序 / Task DAG / Gate
MY_WORLD_CURRENT_STATUS.md         现在做到哪里 / PASS / UAT / blocker
```

治理目录 README：

`Vibe-Coding/my world/README.md`

专题架构不再平铺在顶层；从 `MY_WORLD_架构_CURRENT.md` 进入 `architecture/`。历史经验从其导航进入 `experience/`。

实现仓库中的 [`docs/CORE_DESIGN_PRINCIPLES.md`](docs/CORE_DESIGN_PRINCIPLES.md) 是给开发 Agent 的短版投影，不建立第二套产品真相。

## 第一代技术基线

```text
Host          Godot 4.7.2
Distribution  Standard / non-.NET Windows x64
Language      GDScript
Runtime       same-process Godot Runtime
Provider      DeepSeek deepseek-v4-pro
```

Godot 负责窗口、2D、UI、输入、字体、图片、音频、资源和 Windows packaging 等成熟通用能力。

`my world` 自己拥有 Game / World / Timeline / Save / Conversation / NPC / Faction / Knowledge / Relationship / Agent Context / World Pack 等游戏语义。

> **Engine-native, not engine-semantic-coupled.**

## 产品 UI 方向

长期桌面骨架：

```text
Player Host | Narrative Host | World Surface Host
左主角信息  | 中央叙事与输入 | 右世界信息
```

Narrative 是视觉与交互重心；窄窗口优先保留中央阅读/输入空间。

当前 G2 使用固定 Godot UI + stable Host Slots。Internal Declarative UI Host 留到 G6；外部 World Pack / Mod UI Contract 留到 G8。

## 核心原则速览

> **Model freedom first. Reversibility over prevention.**
>
> **Model authors the world; Runtime makes it durable; Player owns the timeline.**
>
> **Reversibility != frictionless arbitrary rewind.**
>
> **Save Point != Timeline Node.**
>
> **Source provides inertia; actors create history.**
>
> **Off-screen != Inactive.**
>
> **Context stays bounded.**

普通可逆模型/游戏错误优先靠 Cancel、Regenerate/Retry、更好 Context 和明确 Save/Restore 修复，而不是无限增加 Narrative whitelist / Regex / Confirmation / Validator。

## API Key

真实 Provider Secret 只保存在本地 `.env.local`，不得提交 Git、粘贴到聊天、日志或截图。

从 `.env.example` 创建 `.env.local`：

```text
DEEPSEEK_API_KEY=<local secret>
# optional
MY_WORLD_DEEPSEEK_MODEL=deepseek-v4-pro
```

`.env.local` 已被 Git 忽略。

## 运行游戏｜Owner / 玩家路径

当前导出程序：

`build\windows\my-world.exe`

正常情况下直接双击：

`run-game.cmd`

它会读取本机 `.env.local`，临时注入允许的 Provider 环境变量，并启动导出的游戏；不会打印 Secret。

PowerShell 等价：

```powershell
Set-Location 'D:\AI\Projects\my-world'
.\run-game.ps1
```

如果 EXE 尚未构建，应由开发 Agent 完成 export，不要求 Owner 打开 Godot Editor 或自己排查构建。

## 开发者路径

需要打开 Godot Editor 时：

```powershell
.\run-local.ps1
```

或双击：

`run-local.cmd`

本地 Godot：

```text
D:\AI\Engine\Godot_v4.7.2-stable_win64.exe
D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe
```

## 仓库规则

开发 Agent 先读 [`AGENTS.md`](AGENTS.md)。它已经把默认 Authority 收敛到治理侧五份核心文档，并要求只在当前任务真实触及某个领域时继续读取专题架构。

Routine Git / Godot / build / automated QA 由 AI Agent 完成；Owner 只负责真实产品体验、Secrets 与不可替代的产品裁定。
