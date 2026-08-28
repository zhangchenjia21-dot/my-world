---
title: my world｜G4-01 Application Shell / Main Menu + Game Session Lifecycle Task Packet
status: current-task-packet
task_id: G4-01
type: implementation
owner: Codex
created: 2026-08-28
updated: 2026-08-28
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 2d0b20c68ad0e0111274c4bc62b969cfb196fb22
governance_base: b43328e4ddd1a69834a95ee31c64f025834041e2
local_project: D:\AI\Projects\my-world
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: true
---

# TASK｜G4-01｜Application Shell / Main Menu + Game Session Lifecycle

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Local project: `D:\AI\Projects\my-world`  
Formal Code Base SHA: `2d0b20c68ad0e0111274c4bc62b969cfb196fb22`

> 本 Task Packet 是当前 G4-01 的唯一正式执行包。旧 `G4-01 World Pack` packet、Main-Menu-only handoff 与任何以旧 G4 顺序为前提的指令均已在执行前 supersede，不得恢复执行。

## 1. Outcome

把当前“应用启动即自动打开 current Game”的产品壳升级为真正的两层生命周期：

```text
Application Lifetime
!=
Game Session Lifetime
```

完成后，真实产品路径应为：

```text
Launch EXE / project
→ Application READY
→ Main Menu
   ├─ Continue
   ├─ New Game
   └─ Quit

Continue
→ open current Game Session through existing G3 production Runtime
→ enter existing in-game UI

Return to Main Menu
→ safely stop/cancel Game-owned transient work
→ close Game Session resources
→ Application remains READY

Continue again
→ reopen the same durable current Game
→ same accepted Conversation / World / Save / Recovery truth
```

本任务不是“给现有 Game UI 盖一层菜单”。**Application 启动时不得为了显示 Main Menu 而先打开、创建或锁住 Game SQLite。**

实现 Agent 的最高返回状态：

```text
READY FOR INDEPENDENT REVIEW
```

不得自行宣布 Product PASS，不得开始 G4-02。

---

## 2. Why Now

G1–G3 已关闭，当前产品已经有：

- AI Conversation / real streaming / cancel / regenerate / retry；
- current Game durable reopen/resume；
- SQLite authoritative persistence；
- Save / Load / Restore；
- Recovery Checkpoint；
- single-writer；
- verified physical backup 与 corruption recovery；
- exported Windows product path。

但当前 composition root `src/应用壳.gd` 仍在 `_enter_tree()` 中直接创建 `CurrentGameRuntime` 并调用 `open_current_game()`。因此当前事实仍是：

```text
Application boot
=
Game DB boot
=
Game Session boot
```

这会直接阻塞后续 G4 的 Source Library、Multi-Game、New Game Wizard 与 Game Library，因为这些能力都需要玩家先处于独立的 Application / Main Menu，再显式选择进入或创建某一 Game。

G4-01 必须先建立稳定产品入口与 session lifecycle；G4-02 才开始 Source contracts。

---

## 3. Authority / Source Manifest

冲突时严格按以下顺序：

1. 用户当前明确指令：本任务由 **Codex** 执行。
2. `zhangchenjia21-dot/Vibe-Coding/main/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` 及本任务真实涉及的 supporting architecture。
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — v3.0 current roadmap。
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — v5.0 current execution status。
8. 本仓库 `AGENTS.md`。
9. 本仓库当前代码、测试与可复现 Windows/Godot 运行事实。
10. `Vibe-Coding/skill/gpt/lifecycle-dev-process/SKILL.md` — current v2.3 execution method。
11. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md` — current v1.2 task method。

Governance freshness baseline at issuance:

```text
Vibe-Coding/main
b43328e4ddd1a69834a95ee31c64f025834041e2
```

Implementation formal code base:

```text
my-world/main
2d0b20c68ad0e0111274c4bc62b969cfb196fb22
```

Not authoritative unless this packet explicitly cites them:

- old G4-01 World Pack task packet；
- Main-Menu-only handoff；
- SillyTavern / The World implementation shape；
- archive / superseded docs；
- old chat summaries；
- model memory。

旧项目可作为 evidence，但不得直接迁移 Web/TypeScript/DSH implementation。

---

## 4. Start / Freshness Gate

开始前：

```powershell
Set-Location 'D:\AI\Projects\my-world'
git status --short
git rev-parse HEAD
git fetch origin
git status -sb
```

要求：

1. 不覆盖未知 dirty worktree；
2. fast-forward 到包含本 Task Packet 的最新 `origin/main`；
3. 记录 `START_HEAD`；
4. 确认 `Formal Code Base SHA = 2d0b20...` 之后到 `START_HEAD` 的增量仅为 task/governance/navigation 类变更，若包含未知 production implementation，先 audit 再继续；
5. 写回前再次 fetch/revalidate HEAD。

若当前 HEAD 中出现改变 G4-01 Outcome、Application/Game ownership、G3 persistence contract 或目标文件的未知并行实现，返回 `BLOCKED`，不要自行融合。

---

## 5. Read First｜最小充分工作集

先按顺序读取：

```text
1. AGENTS.md
2. docs/tasks/G4-01_APPLICATION_SHELL_GAME_SESSION_LIFECYCLE_TASK.md
3. src/应用壳.gd
4. src/main.tscn
5. src/runtime/当前游戏会话运行时.gd
6. src/ui/叙事对话视图.gd
7. 与 G3-03 / G3-04 / G3-06 / G3-07 直接相关的 session/reopen/recovery tests
```

然后按 Source Manifest 读取 current Roadmap / Status / Architecture 中与 Application / Game Session 生命周期直接相关的段落。

只有现有证据不足时才扩大读取范围；Final Report 说明为什么扩大。不要默认读取整个仓库或全部历史 Task Packet。

---

## 6. Pre-implementation Lifecycle / Failure Matrix｜编码前必须完成

**生产代码前先完成矩阵。** 建议落为：

`docs/tasks/G4-01_实现前生命周期矩阵.md`

这是 task-scoped engineering evidence，不成为新的 project CURRENT。

至少覆盖以下状态 / 序列：

```text
A. Application launch, valid existing current Game
B. Application launch, current Game DB absent
C. Main Menu → Continue → Game READY
D. Main Menu → New Game → back to Main Menu
E. Main Menu → Quit
F. Game READY → Return to Main Menu
G. Game → Menu → Continue again
H. Game with generation in progress → Return to Main Menu
I. Game after Save / Load / Recover → Return → Continue
J. Continue when DB is physically corrupt and verified backup exists
K. Continue when DB is corrupt and no verified recovery is available
L. Continue when single-writer lock says already running
M. Application window close while on Main Menu
N. Application window close while Game Session is open
O. test/headless `--script` paths must not touch real user:// current Game
```

每项至少回答：

- Application state；
- Game Session state；
- SQLite 是否应该打开/锁住；
- Conversation/generation 状态；
- UI surface；
- player-visible result；
- cleanup；
- durable side effects；
- forbidden side effects；
- retry/reopen behavior。

如果矩阵发现当前 G3 Runtime 缺少**最小必要**的 clean open/close/cancel seam，可以在本任务内做窄修复；若需要改 production schema、重写 G3 ownership 或决定 multi-Game storage topology，立即 `BLOCKED`，不要把 G4-04 偷做进来。

---

## 7. Decision Digest / Invariants

### INV-PRODUCT-01｜Main Menu 是真实产品入口

启动后首先出现 Main Menu，而不是已经运行的 Game UI。

第一版最低产品 affordance：

```text
my world

继续游戏
新游戏
退出游戏
```

视觉可以克制，不要求最终美术首页；但不得显示 Task ID、Stage、engineering diagnostics 或测试按钮。

Main Menu 本身不得成为第二份 Game truth owner。

### INV-LIFE-01｜Application boot 不得自动打开 Game

正式产品路径必须退休当前等价行为：

```text
Application _enter_tree
→ CurrentGameRuntime.new()
→ open_current_game(...)
```

Main Menu READY 时，不应因为“以后可能 Continue”就预先：

- 创建 Game DB；
- 打开 SQLite connection；
- 获取 Game single-writer lock；
- rehydrate Conversation；
- 建立 Game-owned Provider/session state。

**无 current DB 时启动 Main Menu 不得顺手创建一局空 Game。**

### INV-LIFE-02｜Session 只能由显式 Continue 打开

`Continue` 是当前 G4-01 唯一正式 Game Session open action。

当前仍是 G3 one-current-Game；G4-01 不做 game picker。

Continue 必须复用现有 production `CurrentGameRuntime.open_current_game()` 或语义等价正式 seam，不复制第二套 reopen逻辑。

### INV-LIFE-03｜Return to Main Menu 必须真的关闭 Session

从 Game 返回 Main Menu 后：

```text
Game Session = CLOSED / absent
Application = READY
```

不得只是把 Game UI `visible=false`，同时让：

- SQLite connection；
- writer lock；
- Conversation callback；
- Provider generation；
- Game-owned signals/resources

继续在后台存活。

### INV-LIFE-04｜Durability 不依赖 Return/Exit 时最后保存

G3 已冻结 accepted truth 的 durable ordering。Return to Menu / Quit 的责任是 cleanup，不是“最后一秒把所有正式现实 flush”。

不得新增 whole-session shutdown save 作为 correctness 前提。

### INV-LIFE-05｜生成中返回必须安全

如果玩家在 generation/streaming 期间返回 Main Menu：

- 请求当前 Generation 的正式 cancel/abandon；
- 未 accepted partial 不得变成 durable Conversation；
- 不得释放 UI/runtime 后继续收到回调写已销毁节点；
- Session close 必须最终完成；
- 返回 Main Menu 后应用仍可再次 Continue。

不要通过粗暴 kill process 解决。

### INV-LIFE-06｜Window close 与 App Quit 是 Application exit

Main Menu 的“退出游戏”和 Windows close 都应退出 Application。

若 Game Session 当前打开，应先走同一安全 session cleanup，再退出 App。

不要存在两套互相矛盾的 close path。

### INV-UI-01｜New Game 是稳定 host，不是假功能

G4-01 必须给后续 New Game 留一个真实产品 surface，但**不实现 Source selection**。

允许的第一版行为：

```text
Main Menu
→ New Game
→ stable New Game surface
→ 明确显示当前版本尚未开放创建流程
→ Back
```

或语义等价、诚实的 disabled/placeholder UX，只要：

- 玩家不会误以为已经选择/创建 World；
- 不写 fake Source metadata；
- 不创建 Game/DB；
- 不实现 G4-02+。

不得在用户界面写 `G4-05` 等工程 Task 编号。

### INV-UI-02｜现有 in-game 三 Host 不退化

进入 Game 后继续保留并正确工作：

```text
Player Host | Narrative Host | World Surface Host
```

Narrative、Save/Load/Recovery、响应式布局不因 Application 层拆分而退化。

### INV-UI-03｜明确的 Return to Main Menu

Game 内提供清晰的“返回主菜单”入口。

可以重构/替换当前最适合的 application chrome 控件，但不要把 Save/Recovery controls 混成应用导航状态。

### INV-RECOVERY-01｜Recovery 不能被菜单隐藏

Application boot 不打开 Game，因此 corruption detection 可以延迟到用户点击 Continue。

当 Continue 的 startup 结果为现有 G3 corruption/recovery failure 时：

- 玩家必须在 Application 内看到明确的 continue/startup failure；
- 若 verified backup 可用，唯一 `恢复最近安全备份` action 仍应在失败说明附近明显可发现；
- 不得静默新建 Game；
- 不得要求玩家手工修 SQLite/WAL；
- 恢复成功若现有 contract 要求 reopen，则回到可理解的 Application state，再允许 Continue/reopen。

保留 G3-07 已接受的“中央失败说明 + 紧邻恢复动作”产品语义。

### INV-PERSIST-01｜不改 G3 persistence ownership

本任务不得：

- 改 SQLite production schema；
- 建 multi-Game schema；
- 改 Save/Restore/Timeline semantics；
- 让 Main Menu 保存 game_id/history 的第二副本；
- 用 UI metadata 替代 Runtime/Persistence truth。

### INV-ARCH-01｜Composition root 可以变，但不要造 Application Framework

可以把 `src/应用壳.gd` 从“单 Game 壳”重构为真正 Application composition root；可以新增极少量 application/session coordinator 或 UI script。

禁止为了两个生命周期状态引入：

- Service Locator；
- DI container；
- generic Event Bus；
- universal router；
- scene/navigation framework；
- plugin system；
- speculative state-machine framework。

最小明确 seam 优先。

### INV-ARCH-02｜建议状态语义，而非强制类名

至少需要可区分等价状态：

```text
Application:
BOOTING / MENU_READY / OPENING_GAME / GAME_ACTIVE / EXITING

Session:
ABSENT / OPENING / READY / CLOSING / FAILED
```

具体 enum/类/节点结构由实现决定。不要为了匹配字面名称创建多余层。

### INV-TEST-01｜自动测试不得碰 Owner real current DB

新增 lifecycle tests 必须使用 task-owned temp/test DB path 或 injected runtime。

`--script` 测试继续禁止无意打开 `user://my-world/current-game.sqlite`。

### INV-PRODUCT-02｜服务后续资产建局，但不提前实现

G4-01 的产品价值是给后续：

```text
Source Library
Game Library
New Game Wizard
```

提供正确入口与生命周期承载层。

它不应提前实现这些 Domain。

### INV-PRODUCT-03｜工程正确不能替代 Owner UAT

本任务直接改变玩家启动/导航主路径。Automated/Windows evidence 通过后最高到：

```text
READY FOR INDEPENDENT REVIEW
```

Independent Review PASS 后再进入：

```text
READY FOR OWNER UAT
```

只有 Owner 可以判产品 PASS。

---

## 8. Scope

### Allowed

- `src/应用壳.gd` 的必要重构；
- `src/main.tscn` Application/Main Menu/Game host 结构；
- 新增少量 `src/ui/` 或 `src/runtime/` task-specific application/session lifecycle helper；
- `src/ui/叙事对话视图.gd` 的最小 bind/unbind/cleanup 修正；
- `src/runtime/当前游戏会话运行时.gd` 的最小 lifecycle/cancel/close seam 修正，仅当矩阵证明现有接口不足；
- 与 G4-01 直接相关的 focused tests；
- 必要的 existing G2/G3 regression test adaptation；
- task-scoped `docs/tasks/G4-01_实现前生命周期矩阵.md`；
- Windows export/run scripts 的最小修正，仅当 Main Menu product path 真需要；
- 实现级 README 的必要导航修正，但 README 不维护第二份滚动 task 状态。

### Prohibited

- G4-02 World Pack / Character Card contracts；
- Source loader / validation；
- Managed Source Library；
- multi-Game storage / Game Library；
- real Source selector；
- Game Creation Composition；
- Atomic Final Create；
- Expansion Pack；
- Asset Resolution；
- G5 NPC/Faction/Knowledge/World Evolution；
- G6 Declarative UI Host；
- Settings framework / account / cloud / store / network services；
- persistence schema migration；
- arbitrary Mod code；
- destructive Git operations。

---

## 9. Expected Product Shape｜不冻结最终美术

建议第一版信息架构：

```text
Application Root
├─ Main Menu Surface
│  ├─ Product title
│  ├─ Continue
│  ├─ New Game
│  └─ Quit
├─ New Game Placeholder / Host
└─ Game Surface
   └─ existing Player/Narrative/World hosts + Save/Recovery
```

设计要求：

- Main Menu 是应用级 Surface，不嵌在 Narrative transcript 中；
- 使用 Godot `Control` / `Container` 响应式布局，不堆固定像素坐标；
- 默认 maximized；
- 1280×720 与 960×540 可用；
- 当前不是最终视觉 polish task，不建设完整 Design System；
- 不展示内部数据库路径、Task 状态、Provider diagnostics；
- 无 current Game / Continue failure 时必须诚实、可理解，而不是假装成功。

具体视觉由 Codex 在现有产品风格内做最小高质量实现。

---

## 10. Required Deliverables

1. `Application Lifetime != Game Session Lifetime` 的 production implementation；
2. 真正 Main Menu；
3. Continue → current Game Session production vertical；
4. in-game Return to Main Menu → real session cleanup；
5. New Game stable honest host/placeholder；
6. Quit / Windows close unified safe exit；
7. corruption / verified-backup recovery 在 Continue path 中保持可发现；
8. `docs/tasks/G4-01_实现前生命周期矩阵.md`；
9. focused automated lifecycle tests；
10. relevant existing G2/G3 regression PASS；
11. real Godot GUI / Windows export / exported EXE evidence；
12. implementation commit(s) + push to `main`；
13. Final Report，最高 `READY FOR INDEPENDENT REVIEW`。

---

## 11. Acceptance Gates

### 11.1 Engineering Acceptance

**AC-ENG-01｜Boot is Application-only**  
启动项目/EXE 后进入 Main Menu；在 Main Menu READY 前/期间没有自动创建/open/lock current Game DB。用 task-owned DB absence/existence evidence 证明，而不是只看 UI。

**AC-ENG-02｜Absent DB does not auto-create Game**  
在 task-owned product DB path 不存在时启动 Application，Main Menu 可正常 READY，且 DB 仍不存在。只有显式 Continue 才允许现有 G3 current-game opener决定结果。

**AC-ENG-03｜Continue real vertical**  
对一个 task-owned、合法已有 Game：Main Menu → Continue → Game UI；Game identity、accepted Conversation、World/head 与 G3 reopen truth 一致。

**AC-ENG-04｜Return really closes Session**  
Game → Return to Main Menu 后，Session runtime/persistence 被关闭，writer lock/connection 不再由该 Application Session 占用；Application 保持运行。

**AC-ENG-05｜Continue again is same durable Game**  
Game → Menu → Continue 后恢复同一 durable truth；不得创建新 Game、清空 transcript、重复 accepted Turn 或丢 Save/Recovery state。

**AC-ENG-06｜Generation-close safety**  
生成中返回 Main Menu：未 accepted partial 不 durable；没有 stale callback/error spam/crash；再次 Continue 可继续使用。

**AC-ENG-07｜New Game no mutation**  
进入/离开 New Game surface 不创建 DB、不改当前 Game、不伪造 Source selection。

**AC-ENG-08｜Recovery discoverability**  
Continue 遇到 physical corruption/interrupted recovery：中央/明显失败说明正确；verified backup 可用时 `恢复最近安全备份` 紧邻可见；无 backup 时不提供虚假可用 action；不 silent fallback。

**AC-ENG-09｜Existing G3 product semantics regressions = 0**  
Save / Load / Recover / current resume / single-writer / corruption recovery relevant existing tests 均通过；如测试需要改造以适应“启动不再自动 open Game”，只能改 harness/composition assumptions，不能降低旧语义断言。

**AC-ENG-10｜Responsive**  
真实 GUI 至少验证：

```text
maximized
1280×720
960×540
```

Main Menu、New Game host、Game Surface 的关键操作可见可用，无主要重叠/截断。

**AC-ENG-11｜Windows exported reality**  
正式 Windows Desktop export 成功；`build/windows/my-world.exe` 真启动到 Main Menu，并能在 task-owned/安全测试条件下验证 Continue / Return lifecycle。不得只用 editor scene test 宣称 Windows PASS。

**AC-ENG-12｜No hidden scope expansion**  
无 Source Contract、multi-Game、Creator、Settings framework、schema migration 等 G4-02+ 实现混入。

**AC-ENG-13｜Secrets / network**  
本任务本身不要求真实 Provider call。不得输出/提交 `.env.local` 或 key。若为了手工验证现有 Conversation 主路径使用真实 Provider，只能走现有安全 launcher/env path，且不是 G4-01 Engineering PASS 的必要条件。

**AC-ENG-14｜Git hygiene**  
最终 tracked worktree clean；不提交 build、Godot cache、本地 DB、日志、secret；所有 task commits push 到 main。

### 11.2 Product Value Acceptance

当前 Primary Purpose：

> 让单个玩家通过自然语言，与优秀 AI GM 在一个长期持续、可保存、可恢复、会自主演化的 2D RPG 世界中长期游玩。

G4-01 当前产品价值：

> 让这个长期游戏第一次拥有真正的应用入口和可切换 Game Session 生命周期，从而后续可以自然承载 Continue、New Game、多个 Game 与资产建局，而不是继续依赖“程序启动=自动打开唯一数据库”。

Engineering/IR 不能替 Owner 判断以下体验：

- Main Menu 是否像正式产品入口，而不是测试 overlay；
- Continue 是否自然、明确；
- Game → Main Menu → Continue 是否让人感觉是一个完整游戏应用；
- New Game 尚未开放时是否诚实而不显得像坏按钮；
- 960×540 / 1280×720 / maximized 下整体是否可用；
- Recovery 是否在需要时容易找到。

以下任一出现应视为 Product Gate failure，而不是“以后 polish”：

- 启动仍先闪进/加载 Game 再盖菜单；
- 返回主菜单后 Game 实际仍在后台占锁；
- Continue 重建/丢失当前现实；
- New Game 按钮像可用但行为是假；
- recovery 因菜单拆分变得难以找到；
- 基本窗口尺寸下主操作不可用。

Owner UAT 之前不得宣布 Product PASS。

---

## 12. Validation Plan / Commands

Codex 应先根据 current tests 确认实际可用命令，不得伪造不存在的 runner。推荐顺序：

### 12.1 Static / parse / focused

```powershell
Set-Location 'D:\AI\Projects\my-world'

# 记录环境
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --version
git status --short
git rev-parse HEAD

# 对新增 G4-01 focused tests，使用项目当前 Godot --headless --script 约定
# exact filenames 由实现落盘后执行并在 Final Report 给出。
```

Focused tests 至少应自动覆盖：

```text
boot without DB mutation
Continue opens injected/task-owned Game
Return closes runtime
Continue again rehydrates same truth
New Game surface no mutation
generation-close cleanup
corruption/recovery surface state
```

### 12.2 Relevant regression

必须运行与以下既有语义直接相关的 current tests：

```text
G2-03 Narrative UI / GUI lifecycle relevant tests
G3-03 reopen/resume
G3-04 Save/Load/Restore
G3-05 Recovery
G3-06 single-writer / corruption recovery
G3-07 persistence reality harness portions that do not require unnecessary real Provider calls
```

如果 existing test 文件名/入口与旧 Task Packet 不一致，以仓库 current 为准；Final Report 列 exact command + exit code。

### 12.3 GUI reality

用正式 Godot GUI 验证：

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64.exe' --path 'D:\AI\Projects\my-world' --editor
```

或项目已有更安全直接的 `run-local.ps1` 产品路径；不要要求 Owner 替 Agent 操作 Editor。

捕获必要的脱敏 screenshot / observable evidence；不要提交私人数据库内容或 secret。

### 12.4 Windows export

使用 current `Windows Desktop` preset 导出正式 EXE，确认：

```text
D:\AI\Projects\my-world\build\windows\my-world.exe
```

再真实运行 exported EXE 验证 Main Menu + lifecycle vertical。

### 12.5 Real Provider

**G4-01 不需要新的 real Provider Gate。**

若 existing Game 的真实人工 smoke 需要一轮 Provider 交互，只作为附加回归证据，且必须：

- 离线/结构 Gate 先 PASS；
- 使用已有 secret-safe launcher；
- 不输出 raw prompt / raw provider response / key；
- 不把 Provider PASS 当成 Main Menu lifecycle 的替代证据。

---

## 13. Independent Review Readiness

Implementation 完成后不要自审即关闭。

返回 `READY FOR INDEPENDENT REVIEW` 前至少提供：

- start HEAD / final HEAD；
- implementation commit(s)；
- changed files；
- pre-implementation matrix path；
- focused tests exact commands/results；
- relevant G2/G3 regression results；
- Windows GUI/export evidence；
- known limitations；
- explicit confirmation `G4-02 NOT STARTED`。

Independent Reviewer 后续必须特别检查：

```text
menu hidden overlay but Game already opened?  NO
runtime.close only mocked?                  NO
lock actually released?                    PROVE
new-game surface mutates truth?             NO
corruption recovery path still production?  PROVE
regression tests weakened?                  NO
```

不要让 mock-only test / node visibility assertion 冒充 production lifecycle proof。

---

## 14. Git / Integration

Codex 负责本任务 routine Git：

1. fetch + fast-forward；
2. 记录 start HEAD/status；
3. 实现与 tests；
4. focused → regression → Windows reality；
5. **pre-push freshness revalidation**：

```powershell
git fetch origin
git rev-parse HEAD
git rev-parse origin/main
git status --short
```

6. 若 `origin/main` 前进：
   - 无关变更：fast-forward/rebase 后重跑受影响 Gate；
   - 改变目标代码/contract/owner：停止并返回 `BLOCKED`；
7. commit + push `main`；
8. 最终 `git status --short` clean。

禁止：

```text
git reset --hard
git clean -fd
force push
覆盖未知 dirty worktree
```

Task Packet commit 本身只是 execution instruction，不算 implementation evidence。

---

## 15. Stop / Return Conditions

返回 `BLOCKED`，不要继续猜测，如果出现：

- current governance 与本 Packet 发生实质冲突；
- 需要修改 production SQLite schema 才能完成；
- 必须先决定 multi-Game physical topology；
- G3 Runtime 现有 close/recovery contract 无法在窄 seam 内复用，必须重开 persistence architecture；
- 发现未知并行 production implementation 改动同一 seam；
- 无法在 Windows/Godot 环境获得真实性证据；
- 任务边界开始要求 G4-02+ 才能完成。

以下不是 blocker：

- 需要对 `应用壳.gd/main.tscn` 做合理结构重构；
- 需要给 Runtime 增加窄的 close/cancel/bind seam；
- 需要更新旧测试 harness，使它们显式 open injected Game 而不是依赖 Application auto-open。

---

## 16. Final Report Format

```markdown
## Result
READY FOR INDEPENDENT REVIEW | BLOCKED

## Base / Freshness
- Formal Code Base:
- Start HEAD:
- Final HEAD:
- origin/main revalidation:

## Changed
- file → behavior

## Lifecycle Matrix
- path:
- key decisions/findings:

## Evidence
- focused:
- G2/G3 regression:
- GUI:
- Windows export / EXE:
- provider (only if additionally run):

## Product Path Now
Launch
→ ...

## Git
- commits:
- pushed:
- final status:

## Scope Check
- G4-02 started? NO
- SQLite schema changed? NO
- multi-Game implemented? NO

## Remaining / Risks
- ...
```

不要只回复“完成”。

---

## 17. Explicit Handoff Boundary

G4-01 完成后：

```text
Implementation
→ Independent Review
→ Owner UAT
→ Decision Propagation / G4-01 CLOSE
```

只有 G4-01 正式关闭后，才允许签发：

```text
G4-02 World Pack + Character Card Source Contracts v0.1
```

Codex 不得在本任务内预做 G4-02。
