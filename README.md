# my world

`my world` 是一个独立、本地优先、长期单人游玩的 2D 对话式 AI RPG 项目。

这个仓库保存项目的**实现事实**：代码、测试、构建 / 运行配置，以及项目本地的 Agent 开发规则。长期产品定义、路线图和治理决策位于 `zhangchenjia21-dot/Vibe-Coding` 的 `my world/` 目录。

项目不是把前代 SillyTavern / The World / DSH 原样搬进 Godot，而是继承多轮开发与长期试玩已经验证的产品设计，并重新实现真正属于独立游戏的世界状态、时间线、存档、AI GM、NPC、World Pack 与 RPG 表现层。

> **迁移经验，不迁移宿主债务。**

## 当前状态

- 当前阶段：`G2 — AI Conversation Spine（AI 对话主干）`
- 当前任务：`G2-01 — Application / Game Shell`
- `G1-01 — 实现仓库初始化`：**PASS**
- `G1-02 — Godot 4.7.2 工具链与语言确认`：**PASS**
- `G1-03 — 中文长文本 / 输入 Foundation Spike`：**PASS**，已通过真实 Windows 人工 UAT
- `G1-04 — 真实 Provider Streaming / Cancel Foundation Spike`：**PASS**，已通过真实 Windows Owner UAT
- `G1-05 — 本地 IO / 动态图片 / Windows Export Foundation Spike`：**PASS**，已通过导出 EXE 的真实 Windows Owner UAT
- `G1-06 — Foundation Architecture Decision`：**PASS**
- `G1-GATE — Foundation Gate`：**PASS**
- 第一代 Host：Godot `v4.7.2`
- 本地项目目录：`D:\AI\Projects\my-world`
- 本地引擎目录：`D:\AI\Engine`

## 面向人的文档导航

如果是为了理解项目，而不是执行代码任务，建议优先阅读：

- **本 README**：项目定位、当前进展、关键原则和运行方式。
- [`docs/CORE_DESIGN_PRINCIPLES.md`](docs/CORE_DESIGN_PRINCIPLES.md)：SillyTavern / World OS / FC2、The World / DSH 与当前 Owner 裁定汇总出的核心设计导读，重点解释模型自由、可逆性、世界事实、Context、Timeline 与 NPC 自主性。
- [`docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`](docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md)：前代 The World / DSH 长局测试留下的经验、失败模式，以及 `my world` 在 G1–G9 必须承接的跨阶段要求。
- `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`：当前产品定义与核心原则。
- `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`：**canonical 核心设计原则**；当旧项目规则、旧经验文档与当前方向冲突时，以这里的最新裁定为准。
- `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`：G1–G9 总体开发路径、阶段目标和 Gate。
- `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`：第一代 Host、语言、Runtime、Persistence、Provider 与工程路径的 canonical 技术决策。
- `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`：哪些经验应继承、哪些 DSH 宿主实现明确不应迁移。

`AGENTS.md` 属于 AI / Agent 的项目开发与执行规则，不是面向普通读者的项目介绍，因此保留为开发指令文件。

## 已验证的 Foundation 环境

截至 2026-08-25，Windows 本机已经验证：

- Godot：`4.7.2.stable.official.ed1daf0bf`
- 发行版：Standard / 非 .NET Windows x64
- 渲染器：Vulkan / Forward+
- GPU：NVIDIA GeForce RTX 4070 Laptop GPU
- Git：`2.54.0.windows.1`
- Windows x86_64 Export Templates：已安装并验证
- ICU Data：已安装并验证

G1-01 已证明普通 Windows 环境中的 Git / Godot 写入、启动和正常退出没有项目级权限问题。早期 Codex 遇到的写入失败属于执行 sandbox 限制，不是 Windows ACL 或 Godot blocker。

G1-03 已通过真实 Windows UAT，证明中文显示、长文本滚动、大量文本追加、持续追加期间 UI 响应、中文输入、文本选择 / 复制和正常退出可用。

## 项目权威来源

正式开发任务开始前，以 GitHub `main` 的 current 文件为准。默认权威顺序：

1. 用户当前明确指令；
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`；
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`；
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`；
5. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`；
6. `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`；
7. `Vibe-Coding/my world/MY_WORLD_独立版Preflight与第一阶段计划_v1.0_2026-08-25.md`；
8. `Vibe-Coding/my world/MY_WORLD_DSH经验继承矩阵_v1.0_2026-08-25.md`；
9. 本仓库当前实现、测试与 HEAD。

SillyTavern / The World / DSH 是设计证据、踩坑经验和参考实现，不是代码迁移模板。

## 核心设计原则

### 成熟基础能力优先，游戏语义自己掌握

> **Commodity Foundation, Owned Game Semantics.**

窗口、2D、字体、输入、音频、动画、资源管线、平台打包等通用能力优先使用成熟方案；但以下产品概念由 `my world` 自己定义：

- Game
- World
- Timeline
- Save Point
- Agent Context
- Conversation
- NPC
- Knowledge
- Relationship
- Faction
- World Event
- World Pack / Mod

这些概念不能因为使用 Godot，就被直接等同为 Scene / Node / Resource。

### UI 只投影游戏真相

> **UI 是游戏权威状态的投影，不是第二份真相。**

未来的人物、关系、任务、物品、地图和机制 UI 都只能展示或通过正式 mutation path 改变游戏状态，不能自行拥有另一份互相冲突的 gameplay state。

### Source 定义起点，本局创造历史

World Pack / Source 提供开局前的世界参考、人物、历史和惯性。

游戏开始之后：

> **game-local reality > source default trajectory**

Source 的后续更新不能静默覆盖已经发生的本局历史。

### 模型自由优先，可逆性优先于预防

> **Model freedom first. Reversibility over prevention.**

`my world` 不以“让模型永不犯错”为架构目标。普通游戏语义错误、Narrative 偏差、偶发知识错误、低风险的玩家动作补写或玩家单纯不喜欢这一轮结果，优先通过：

```text
regenerate / retry
撤回最近一轮
edit-and-retry
rewind
restore
branch
```

解决，而不是每发现一种错误就增加 Regex、Confirmation、Narrative whitelist 或全局 Validator。

旧式的：

> `Program owns facts; Model writes prose.`

不再作为全局创作限制。当前更准确的边界是：

> **Model authors the world; Runtime makes it durable; Player owns the timeline.**

模型可以广泛参与 Narrative、NPC / Faction 行动、世界事件、新人物地点物品与 game-local 世界演化；Runtime / Program 的硬职责集中在 stable identity、原子持久化、Save / Restore / Timeline 技术正确性、Secret、文件 / 数据库完整性和不可逆外部副作用边界。

模型自由不意味着允许 API Key 泄露、任意 OS / filesystem 权限、物理存档损坏或半提交。

完整原则见 [`docs/CORE_DESIGN_PRINCIPLES.md`](docs/CORE_DESIGN_PRINCIPLES.md) 与 canonical `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。

## G1-04 已完成的真实 Provider 验证

G1-04 使用两个真实 Provider，只为了证明 Godot Foundation surface 能稳定支持联网请求、增量输出、Cancel、错误处理以及 UI 非冻结；这不代表第一代产品已经冻结最终 Provider 架构。

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

两条路径尽量复用同一个很薄的 OpenAI-compatible HTTP / SSE seam，但 host / path / key / model 明确分离。

真实 Windows Owner UAT 已证明：

- 两个 Provider 都能获得真实 HTTP 成功响应；
- 文本会增量流式进入 UI；
- 活动生成可以 Cancel；
- Cancel 后可以再次成功请求；
- 空闲时可切换 Provider；
- deterministic 连接失败能够明确处理；
- 生成期间 heartbeat 和手动 UI 响应仍然工作；
- 正常退出；
- Git 状态干净。

两家在本轮长输出测试中的完整生成时间都约为 30 秒。这个现象不阻塞 G1-04；后续在 G2 再分别测量 TTFT（首字延迟）和生成吞吐，不在 Foundation 阶段提前优化 Provider 性能。

G1-04 的 same-process networking 是后来 G1-06 选择第一代 same-process Runtime 的一项正向证据；它不把 Runtime 永久绑定在 Godot 进程中。

## API Key 与本地启动

真实 Provider Key 只保存在本地，不得提交 Git，也不要粘贴到聊天、Issue、截图或日志中。

G2 起正式产品路径只需要 DeepSeek（默认模型 `deepseek-v4-pro`）。本地 `.env.local` 使用：

```text
DEEPSEEK_API_KEY
```

可选模型覆盖：

```text
MY_WORLD_DEEPSEEK_MODEL
```

G1-04 时期的 `KIMI_CODE_API_KEY` 与 `MY_WORLD_G1_04_*` 已退休，当前启动路径不再读取。

第一次配置时：

1. 复制 `.env.example` 为 `.env.local`；
2. 只在本机填写真实 Key；
3. 双击 `run-local.cmd`，或在 PowerShell 中运行 `.\run-local.ps1`。

`.env.local` 已被 Git 忽略。启动脚本只把变量临时注入 Godot 子进程，不会把 Key 写入项目文件。

PowerShell 启动示例：

```powershell
Set-Location 'D:\AI\Projects\my-world'
.\run-local.ps1
```

## G1-05 Closeout

G1-05 的真实 Windows Owner UAT 已证明：

- 一个极小的本地 probe 可以写入、关闭、重新启动后读回，并跨应用启动保留；
- portrait / scene / map 三类图片能从真实 filesystem 文件中动态解码并显示；
- Windows Export 成功；
- 导出的 EXE 不依赖 Godot Editor 即可直接启动；
- 导出程序中本地 IO 和三类动态图片仍然正常；
- 导出程序关闭再打开后，本地 probe 仍然存在。

G1-05 因此为 **PASS**。该证据只证明 Host 的 IO / image / export seam，不是正式 Save Schema、持久化架构、最终 Asset Pipeline、World Pack Schema 或 Mod Loader。

## 第一代 Foundation Architecture

G1-06 已完成并使 G1-GATE **PASS**。Canonical 决策位于 `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md`：

- **Host**：Godot `4.7.2`；
- **Distribution**：Standard / non-.NET Windows x64；
- **Language**：第一代使用 GDScript；Domain 不得依赖 Scene / Node / Resource 生命周期，只有 G3/G5/G7 的真实证据才能触发 C#/.NET/mixed 重审；
- **Runtime**：第一代采用 Godot same-process Runtime，但 Domain / Provider / Persistence 保持显式边界；当前不实现 IPC；
- **Persistence candidate**：JSON/files 用于配置、少量本地元数据与可移植 Source；SQLite 是 G3 authoritative World/Timeline 的首选评估候选；Event Log/Snapshot 是可组合的语义模式，不默认全量 event sourcing；
- **Authority prohibition**：Markdown、Transcript、UI state、Godot Resource 不得成为 authoritative gameplay database；
- **Provider/config**：保持极薄 `send / stream / cancel` adapter，endpoint/model 与 key 分离；G2 初始只运行 DeepSeek `deepseek-v4-pro`，Kimi Code 是已验证 alternate，不是自动 fallback；
- **Engineering**：Godot headless parse、按真实确定性逻辑增加最小 focused tests、`user://logs/` 有界脱敏日志、tracked `export_presets.cfg`、ignored `build/`、Agent 承担 routine build/Git/debug/QA，Owner 只做最终产品 UAT。

G1-06 文档中较早的“模型候选 / Program 提交现实”措辞，只在它被解释为普通 Narrative / 游戏语义的硬审查机制时被新的核心设计原则修正；Godot、GDScript、same-process、Persistence、Provider、安全、事务与工程路径等技术裁定继续有效。

G2-01 只能按新的 current Task Packet 开始；G1-06 closeout 本身没有实现任何 G2 功能。

## 前代 SillyTavern / The World / DSH 设计与长局经验

前代资产不仅包含 DSH 长局总结。SillyTavern 新版主体时期已经积累了 World OS、FC2、Canonical Ownership、Context Orchestration、Save / Restore、Branch、Game-local World Materialization 等大量核心设计；`my world` 继承这些**经过验证的语义**，但不迁移旧 TypeScript / Web / SillyTavern Host 实现。

DSH 长局实验的完整跨阶段要求见：

[`docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md`](docs/DSH_TEST_CARRY_FORWARD_REQUIREMENTS.md)

更完整的跨前代核心设计收口见：

[`docs/CORE_DESIGN_PRINCIPLES.md`](docs/CORE_DESIGN_PRINCIPLES.md)

最重要的新结论之一不是“世界需要记忆”，而是：

> **持久世界是必要条件，但持久世界不等于自主演化世界。**

> **史料提供惯性，行动者创造历史。**

前代测试暴露了一个必须避免的问题：**主角因果垄断（Protagonist Causal Monopoly）**。即世界虽然能长期记住状态，但如果只有 Source 历史和玩家行动会真正创造新历史，而 NPC / Faction 主要只是响应玩家，那么这个世界依然会显得“不够活”。

因此未来 G3–G9 必须逐步证明：

- Save / Restore 真正恢复同一条 Timeline，模型不会记得被回滚的未来；
- Source 只定义起点和历史惯性，不把未来变成事件时间表；
- 动态 NPC / 地点 / 物品可以成为有 stable identity 的 game-local reality；
- NPC / Faction 在玩家离屏后仍能根据自身目标行动；
- 关键历史改变会向有利益关系的远方 Actor / Faction 传播；
- 世界难度来自世界因果，而不是机械抬高 DC；
- 长局 Context 和状态维护不会再次无界膨胀；
- RPG UI、地图、立绘和场景增强游戏体验，但不成为第二状态源；
- 玩家能够通过 regenerate / rewind / restore / branch 对 AI 错误和不满意的剧情低成本恢复；
- 最终 Alpha 必须通过真实长局 Product Owner UAT，而不能只靠工程测试宣布成功。

## 明确不从前代直接迁移的实现

以下内容属于前代宿主债务、过度防错路线或 workaround，不应作为新项目架构模板直接复制：

- DSH Session workaround；
- Restore 后新建 Session 的恢复 seam；
- `fs.watch` Restore workaround；
- DSH Plugin Lifecycle；
- 周期性模型 consolidation 作为主要状态一致性机制；
- DELTAS + 批量 Markdown edit 作为 Runtime 数据库；
- Markdown 默认充当权威 gameplay DB；
- 通用 Agent Workspace 的目录结构直接决定玩家 UI；
- Active Context 长期携带 Source future-event checklist；
- “玩家改变、NPC 回应、历史继续播放”的主角因果垄断模式；
- 每发现一种自然语言误解就增加 Regex / Confirmation 的防错循环；
- 把 `No Phantom` 实现成对普通 Narrative 的硬审查器；
- 为追求模型“永不犯错”而持续扩大 Prompt / Validator / 状态机。

应该继承的是这些失败方案背后暴露出的**需求和经验**，而不是 workaround 本身。

## 总体开发路径

```text
G1  基础能力与项目启动
↓
G2  AI 对话主干
↓
G3  持久游戏与时间线
↓
G4  World Pack 与本地内容基础
↓
G5  世界语义与 GM Runtime
↓
G6  RPG 体验与 2D 表现
↓
G7  长局上下文与性能
↓
G8  Mod / 创作生态
↓
G9  独立版 Alpha / 发布验证
```

项目真正的关键路径不是“功能越来越多”，而是逐步证明：

```text
启动游戏
→ 进入一个世界
→ 与 AI GM 自然语言互动
→ 模型充分发挥叙事与世界创造能力
→ 世界产生真实、持久的变化
→ 玩家可以低成本 regenerate / retry
→ 退出并重新进入
→ Save / Restore / rewind / branch
→ 被回滚的未来不再影响 AI
→ NPC / Faction 自己创造历史
→ 长局仍然自然、快速、好玩
```

如果工程越来越复杂，但核心 AI RPG 体验反而明显弱于简单模型聊天或前代基线，就不能用“架构更完整”宣布成功。