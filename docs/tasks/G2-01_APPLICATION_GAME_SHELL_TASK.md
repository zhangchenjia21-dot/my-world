---
title: my world｜G2-01 Application / Game Shell Task Packet
status: current-task-packet
task_id: G2-01
type: implementation
owner: KimiCode K3
created: 2026-08-26
updated: 2026-08-26
formal_code_base: 0cd40fbbde89d3da18bdf4ba1bc37e46b3f4b401
governance_base: 21c2bd9eb3ed61faacada86dee50a89137a02e3a
skill_base: a82966b8f07a18b2eb4c633a413dbb39936f2df8
---

# TASK｜G2-01｜Application / Game Shell

Type: `implementation`  
Owner: `KimiCode K3`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Local project: `D:\AI\Projects\my-world`  
Formal Code Base SHA: `0cd40fbbde89d3da18bdf4ba1bc37e46b3f4b401`

## 1. Outcome

把当前以 `G1-05` 工程探针为主界面的 Godot 工程，收口成第一版**正式产品 Application / Game Shell**。

完成后，玩家启动 `my world` 时看到的应当是一个干净、可读、可缩放、像正式游戏而不是测试工具的应用壳；应用可以稳定进入 ready 状态并正常退出，且为后续 G2-02～G2-05 留出自然承载位置，但**本任务不接 AI、不实现 Conversation、不实现持久世界**。

最高可宣布状态：`READY FOR OWNER UAT`。本任务不得自行宣布 Product PASS。

## 2. Why Now

`G1-01...G1-06` 与 `G1-GATE` 已 PASS。Godot、中文文本、Provider stream/cancel、本地 IO、图片和 Windows export 已有真实 Windows 证据。

G2 的目标是从 Foundation Probe 进入真正可玩的 AI Conversation Spine。G2-01 先退休测试壳，建立正式应用入口；G2-02 才接 Provider，G2-03 才实现 Narrative Conversation View。

## 3. Authority / Source Manifest

发生冲突时按以下顺序处理：

1. 用户当前明确指令。
2. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — current canonical product spec。
3. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md` — current canonical core design；其中 `Model freedom first / Reversibility over prevention` supersede 旧 prevention-first Narrative 限制解释。
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — current roadmap；G2-01 = Application / Game Shell。
5. `Vibe-Coding/my world/MY_WORLD_Foundation架构决策_v1.0_2026-08-26.md` — Godot 4.7.2 / Standard / GDScript / same-process 等 G1 技术边界。
6. 本仓库 `AGENTS.md`、当前代码、测试与可复现运行事实。
7. `Skill/main/skill/gpt/agent-task-packet/SKILL.md` 与 `skill/gpt/lifecycle-dev-process/SKILL.md`。

Not authoritative unless explicitly required:

- SillyTavern / The World / DSH 旧实现代码；
- archive / superseded docs；
- 历史聊天摘要；
- 模型一般经验。

不得因旧项目曾采用某种 Web / TypeScript / Workspace 方案而迁移其实现。

## 4. Read First

开始实现前按顺序读取：

1. `AGENTS.md`
2. 本文件 `docs/tasks/G2-01_APPLICATION_GAME_SHELL_TASK.md`
3. `docs/CORE_DESIGN_PRINCIPLES.md`
4. `project.godot`
5. `src/main.tscn`
6. `src/g1_05_本地IO图片导出探针.gd`
7. `export_presets.cfg`

如现有证据不足，再扩大读取范围，并在 Final Report 说明原因。不要默认阅读整个仓库或全部历史文档。

## 5. Decision Digest / Invariants

### INV-PRODUCT-01｜必须开始像“游戏”而不是工程探针

启动后主界面不得继续展示：

- `G1-05`；
- Local IO PASS/FAIL；
- probe path / marker；
- Portrait / Scene / Map test labels；
- `Re-run IO` / `Reload Images`；
- Foundation / Spike / diagnostic 说明。

G1 证据留在 Git 历史与文档，不继续占据正式产品入口。

### INV-PRODUCT-02｜Shell 服务核心体验，不提前实现核心体验

Shell 应能自然承载未来的：

```text
Narrative / Conversation
Player input
small application/game status surfaces
future RPG presentation
```

但当前只能建立**结构与视觉容器**。不要假装已经存在 AI、World、Save、角色、任务、地图或可用按钮。

如果某个控件当前没有真实行为，优先不要显示成可点击功能；不要制造“看起来能用但实际上坏掉”的产品 affordance。

### INV-PRODUCT-03｜低操作税

当前产品价值是自然语言 AI RPG。Shell 不得为了架构感增加多层菜单、确认、启动向导或工程状态页。

Owner 第一次打开应能立即理解：这是 `my world` 的游戏主界面，而不是开发控制台。

### INV-CORE-01｜Model freedom first / Reversibility over prevention

本任务没有模型逻辑，因此**不要预建** Narrative whitelist、Regex authorization、Confirmation framework、validator pipeline 或行为菜单，为以后“防止 AI 犯错”做准备。

### INV-ARCH-01｜第一代技术边界

保持：

```text
Godot 4.7.2
Standard / non-.NET Windows x64
GDScript
Godot same-process Runtime
```

不要引入 C#/.NET、IPC、第二进程、Web UI framework 或额外依赖。

### INV-ARCH-02｜不要为四层形式创建空架构

`L3 -> L2 -> L1 -> L0` 是模块内部职责/依赖纪律，不要求每个小任务创建四层文件。

本任务不得创建空的 `world/`, `timeline/`, `provider/`, `persistence/`, `npc/` 等未来模块树。

### INV-ARCH-03｜Shell 是 Host / Experience surface，不是未来 Game Domain

Godot Scene / Node 可以拥有当前 Application Shell 生命周期与界面行为；不要因为本任务需要一个 `ApplicationState` 就把未来 `Game / World / Timeline` 定义成 Scene Tree 状态。

只实现本任务需要的最小 application lifecycle，例如语义等价于：

```text
STARTING -> READY -> EXITING
```

字段/枚举命名由实现决定，不要求通用状态机框架。

### INV-UI-01｜中文与窗口基础继续有效

继续使用已验证的中文字体 fallback。界面至少在当前 `960x540` 基线可读，并在普通窗口放大/缩小时不出现明显重叠、截断或不可操作区域。

不要为了 G2-01 建设完整 Theme System / Design System。

### INV-EXIT-01｜退出是正式生命周期

至少支持：

- Windows 窗口正常关闭；
- 一个清晰、真实可用的“退出”入口（如界面设计自然适用）；
- 不出现报错、挂起或需要 Task Manager 的退出路径。

当前没有 Save，因此退出不得假装执行存档。

## 6. Scope

### Allowed

- 修改 `src/main.tscn`；
- 新增 G2-01 所需的最小 GDScript，例如 `src/application_shell.gd`；
- 删除/退休已不再属于生产入口的 G1-05 probe script/uid；
- 修改 `project.godot` 中与正式 Shell 直接相关的窗口/应用设置；
- 修改 `export_presets.cfg`，把正式 Windows 导出目标收口为 `build/windows/my-world.exe`；
- 增加一个**最小** focused smoke/parse helper，仅在它能真实提高验证质量时；
- 必要的小型 README 实现状态修正，但不得把 G2-01 标记为 Owner PASS。

### Prohibited

- G2-02 Provider Adapter；
- 真实 API / HTTP / SSE；
- G2-03 Conversation View 的消息模型、stream、cancel、retry 实现；
- G2-04 Turn / Conversation Domain；
- G2-05 Context Assembly；
- SQLite / persistence / Save / Restore / Timeline；
- World Pack / Mod；
- NPC / Faction / Knowledge / Mechanics；
- RPG 状态面板、地图、角色系统；
- 通用路由、Event Bus、Service Locator、DI framework、Universal State Machine；
- 为以后理论需求创建空目录、空 class、空 interface；
- 迁移 SillyTavern / DSH implementation；
- destructive Git：`reset --hard`、`clean -fd`、覆盖未知 dirty worktree。

## 7. Product Shell Design Envelope

不冻结最终美术风格，但本轮至少满足以下视觉结构目标：

- 根节点全窗口自适应；
- 清楚显示产品名 `my world`；
- 主内容区占据主要视觉面积，能够在后续自然替换/承载 Narrative Conversation；
- 可以有很轻的顶部/底部应用 chrome，但不要堆功能；
- 未实现的后续能力不做可点击假按钮；
- 不展示 Task ID、阶段号、调试指标或开发说明；
- 可以使用一小段正式、克制的产品空状态文案，但不要写“G2-03 后接入”等开发者信息；
- 当前唯一必须真实工作的产品操作是正常退出；其余行为保持诚实。

布局与具体 Control 选择由 KimiCode 决定。优先使用 Godot 原生 `Control` / `Container` 体系，不手写像素坐标堆布局。

## 8. Deliverables

必须交付：

1. 正式 `Application / Game Shell` 作为 `run/main_scene` 的实际界面；
2. 最小 application lifecycle 实现；
3. G1-05 probe 不再属于当前 runnable production path；
4. Windows export 目标为：

```text
D:\AI\Projects\my-world\build\windows\my-world.exe
```

5. Godot parse / startup / export 的真实本地证据；
6. commit + push 到 `main`；
7. Final Report，状态最高 `READY FOR OWNER UAT`。

## 9. Acceptance Gates

### 9.1 Engineering Acceptance

**AC-ENG-01｜Parse / Load**  
Godot 4.7.2 console/headless 能加载项目与主场景，无 GDScript parse error、missing resource、invalid node path。

**AC-ENG-02｜Startup**  
GUI 启动进入新 Shell，不显示 G1-05 diagnostic UI。

**AC-ENG-03｜Responsive Layout**  
至少在 `960x540` 与一个更大普通窗口尺寸下，没有主要控件重叠、内容不可见或退出入口消失。

**AC-ENG-04｜Exit**  
窗口关闭路径正常；若实现界面退出按钮，该按钮真实可退出，且没有崩溃/报错。

**AC-ENG-05｜No Hidden Feature Expansion**  
没有 Provider、Conversation、Persistence、World、NPC 等 G2-02+ / G3+ 实现混入。

**AC-ENG-06｜Windows Export**  
`Windows Desktop` export 成功生成 `build/windows/my-world.exe`，导出程序可直接启动并显示同一 Shell。

**AC-ENG-07｜Secrets / Network**  
本任务不需要真实 Provider key，不得读取/显示/记录 key；启动 Shell 不应主动发网络请求。

**AC-ENG-08｜Git**  
最终 tracked worktree clean；实现 commit 已 push；不得把 `build/`、`.env.local`、Godot cache 或本地日志提交。

### 9.2 Product Value Acceptance

当前 Primary Purpose：

> 让单个玩家通过自然语言，与优秀 AI GM 在一个长期持续、可保存、可恢复、会自主演化的 2D RPG 世界中长期游玩。

G2-01 本身还不提供 AI RPG，但它必须消除工程探针对第一产品印象的干扰。

Owner UAT 只需要判断：

1. 双击 `build/windows/my-world.exe` 后，第一眼是否像一个正式 `my world` 游戏壳，而不是 G1 测试程序；
2. 中文与布局是否正常、清楚、没有明显破损或“假功能”；
3. 是否能正常退出。

只有 Owner 可以给 Product PASS。KimiCode 的最高状态是：

```text
READY FOR OWNER UAT
```

以下任一出现，不得把它归为“以后 polish”后直接宣布完成：

- 首屏仍明显是工程 diagnostic / Spike；
- 有大量不能工作的假按钮；
- 960x540 下主要布局破损；
- 正常退出失败；
- 为做 Shell 引入明显的大型未来架构。

## 10. Validation Commands / Local Reality Check

开始时先记录：

```powershell
Set-Location 'D:\AI\Projects\my-world'
git status --short
git rev-parse HEAD
git fetch origin
git status -sb
```

若存在未知 dirty worktree，停止，不覆盖；报告 blocker。

建议 focused parse/load：

```powershell
$godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path 'D:\AI\Projects\my-world' --editor --quit-after 1
```

如 Godot 4.7.2 在本机对该参数组合有差异，可使用等价的最小 headless project parse/load 命令，并在 Final Report 记录实际命令与结果；不要伪造 PASS。

GUI Reality Test：

```text
launch project
→ observe Shell
→ resize once
→ normal exit
```

Windows export：

```powershell
& $godot --headless --path 'D:\AI\Projects\my-world' --export-debug 'Windows Desktop' 'D:\AI\Projects\my-world\build\windows\my-world.exe'
```

然后直接启动导出 EXE，确认能进入同一 Shell。能由 Agent 完成的本地工程验证不得转嫁给 Owner；只有最终产品观感需要 Owner UAT。

## 11. Git / Integration

1. 以最新 `main` 开始；Task Packet 的 Formal Code Base 是 `0cd40f...`，但 Task Packet 自身的 docs commit 属正常上游，应吸收。
2. 开始实现前 `git fetch`；若 `origin/main` 有新提交，先审计是否影响本任务。
3. 不覆盖未知本地修改。
4. 实现完成、验证通过后，authoritative push 前再次 `git fetch origin` 比较 base/current HEAD。
5. 若并发提交只修改无关文件，可安全吸收并回归；若修改 `main.tscn`、`project.godot`、`export_presets.cfg`、本 Task Packet 或核心设计原则，重新审计，不静默覆盖。
6. 推荐实现 commit subject：

```text
G2-01: add application game shell
```

7. push `main`，最终 `git status --short` 应为空。

## 12. Stop / Return Conditions

仅在以下情况停止并返回 `BLOCKED` / `PARTIAL`：

- 最新 current source 与本任务发生真实冲突；
- 工作树存在无法安全归属的未知修改；
- Godot 本机出现新的可复现 Foundation blocker；
- 需要超出 G2-01 scope 才能继续；
- export / startup 真实失败且无法在本任务边界内修复。

不要因为“未来 UI 还没设计”“AI 尚未接入”“Save 尚未实现”停止；这些本来就不属于本任务。

## 13. Final Report

按以下格式返回：

```markdown
## Result
READY FOR OWNER UAT | PARTIAL | BLOCKED

## Changed
- 主要文件
- 用户可观察变化
- 退休的 G1 production path

## Evidence
- Godot parse/load
- GUI startup / resize / exit
- Windows export
- exported EXE direct launch

## Scope Check
- 确认未实现 G2-02+ / G3+

## Git
- start HEAD
- final HEAD
- commit
- push
- final status

## Owner UAT
- EXE exact path
- 最多 3 步验证

## Remaining
- 仅列真实剩余风险 / 下一 Gate
```

不要只回复“完成”。