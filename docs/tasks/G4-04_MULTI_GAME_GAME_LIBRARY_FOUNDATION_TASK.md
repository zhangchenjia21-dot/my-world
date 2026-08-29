---
title: my world｜G4-04 Multi-Game Lifecycle / Game Library Foundation Task Packet
status: current-task-packet
task_id: G4-04
type: implementation
owner: Codex
created: 2026-08-29
updated: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: b227ff9043a25b3ebf7581eb340f3e2f9006a919
governance_base: 2126b0b0bbc2a30cf5dabd862356bb919b9d91d8
local_project: D:\AI\Projects\my-world
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
---

# TASK｜G4-04｜Multi-Game Lifecycle / Game Library Foundation

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `b227ff9043a25b3ebf7581eb340f3e2f9006a919`

> 本任务在已冻结的 **One Game = One SQLite** 拓扑上建立 Game Library foundation。不要重新讨论 shared SQLite，不要提前做 New Game Wizard / Final Create。

## 1. Outcome

完成后，Application 不再把唯一固定 `current-game.sqlite` 当成“所有游戏”的产品模型，而是：

```text
Application / Main Menu
→ Game Library current/latest record
→ exact existing Game database path
→ open one Game Session
→ close / return
→ select another Game record
→ open that independent Game Session
```

并证明：

```text
multiple independent Games coexist
+ one writable Game Session at a time inside one Application
+ each Game has its own SQLite / writer lock / backup / recovery blast radius
+ legacy G3 current-game.sqlite can be adopted non-destructively
+ missing/corrupt/mismatched Game never becomes a silent replacement Game
```

实现 Agent 最高返回：

```text
READY FOR INDEPENDENT REVIEW
```

不得开始 G4-05。

---

## 2. Why Now / Product Value

G4-01 已建立 `Application Lifetime != Game Session Lifetime`；G3 已证明单局 persistence/recovery；G4-03 已建立独立 Source Library。

现在必须让多个长期 Game 可以安全共存，否则后续正式 New Game 仍可能覆盖旧局。

本任务直接服务 Primary Purpose 中的“长期持续、可保存、可恢复”的世界：

> 一个玩家可以拥有不止一个长期世界，而进入/切换某局不会让其它局的 durable truth、备份或恢复链受到隐式影响。

当前增量仍是 foundation；正式资产建局与第一次真实 World+Character 产品试玩在 G4-05/06/07，因此本任务 `owner_uat_required: false`。但真实 GUI / Windows lifecycle evidence 仍是 Engineering Gate。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `zhangchenjia21-dot/Vibe-Coding/main/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/architecture/persistence/G4-04_MULTI_GAME_STORAGE_TOPOLOGY_DECISION.md` — **current canonical G4-04 storage decision**。
6. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — Application/Game Library ownership map。
7. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G4-04/G4-05 sequencing。
8. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`。
9. repository `AGENTS.md`。
10. current G3/G4-01 Runtime/Persistence implementation and tests。
11. `Vibe-Coding/skill/gpt/lifecycle-dev-process/SKILL.md`。
12. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md`。

Governance base at issuance preparation:

`2126b0b0bbc2a30cf5dabd862356bb919b9d91d8`

Formal implementation base:

`b227ff9043a25b3ebf7581eb340f3e2f9006a919`

Storage decision commit ancestry includes:

`15118de0edd2d6a179c047d2c409c9819be29924`

Not authoritative unless explicitly used as historical evidence:

- old shared-DB ideas；
- legacy SillyTavern / The World storage layouts；
- superseded G4 packets；
- chat summaries；
- model memory。

The supporting architecture decision explicitly supersedes the unresolved per-Game-vs-shared choice still described generically in the root architecture map.

---

## 4. Start / Freshness Gate

开始前：

```powershell
Set-Location 'D:\AI\Projects\my-world'
git status --short
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
git status -sb
```

要求：

- 不覆盖未知 dirty worktree；
- fast-forward 到包含本 Task Packet 的最新 `origin/main`；
- 记录 `START_HEAD`；
- audit `Formal Code Base → START_HEAD`，确认只有 G4-04 packet / governance projection 等已知文档增量；
- 若出现未知 multi-Game implementation、改变 storage decision 的新 current architecture，或并行修改 Application/Runtime/Persistence 同一 seam，先 audit；无法安全吸收则 `BLOCKED`；
- push 前再次 fetch/revalidate。

---

## 5. Read First｜最小充分工作集

按顺序读取：

1. `AGENTS.md`
2. `docs/tasks/G4-04_MULTI_GAME_GAME_LIBRARY_FOUNDATION_TASK.md`
3. current supporting decision `G4-04_MULTI_GAME_STORAGE_TOPOLOGY_DECISION.md`
4. `src/runtime/当前游戏会话运行时.gd`
5. `src/应用壳.gd`
6. `src/persistence/L3_外交层/数据库安全公开接口.gd` + directly needed safety flow only
7. `tests/g4_01/` lifecycle tests and relevant G3 reopen/recovery/single-writer tests

再读取 current Roadmap/Architecture 中 G4-04/G4-05 直接相关段落。

只有证据不足时才扩大读取范围；不要默认读整个 repo / 全部 G3 history。

---

## 6. Frozen Architecture Decision｜不得重新选择

### DEC-GAME-STORE-01｜One Game = One SQLite

第一代正式拓扑：

```text
Game A → SQLite A
Game B → SQLite B
Game C → SQLite C
```

不采用 shared SQLite + `game_id`。

原因已经由 canonical architecture decision 冻结：

- `CurrentGameRuntime.open_current_game(path)` 已接受 explicit path；
- Runtime 当前 one-Game-per-DB semantics 已通过 G3；
- writer lock / recovery root / physical backup 都按 DB path 派生；
- per-Game SQLite 最大化复用 G3 evidence，并隔离 corruption/recovery blast radius；
- shared DB 会迫使 G3 persistence ownership redesign，当前无必要。

若实现发现 per-Game SQLite 无法在不修改 production schema 的前提下成立，返回 `BLOCKED`；不得自行切换 shared DB。

### DEC-GAME-STORE-02｜Legacy G3 Game adopt in place

现有 production legacy path：

```text
user://my-world/current-game.sqlite
```

G4-04 优先 non-destructive adopt in place，不为了目录统一搬迁 DB/recovery evidence。

新 Games 的目标 managed path：

```text
user://my-world/games/<game_id>/game.sqlite
```

本任务不通过玩家 New Game 创建它们；测试可创建 task-owned Game fixtures。

---

## 7. Pre-implementation Game Library State / Failure Matrix｜编码前必须完成

先形成：

`docs/tasks/G4-04_实现前GameLibrary生命周期与失败矩阵.md`

至少覆盖：

```text
Case
→ Game Library durable metadata
→ resolved database path
→ DB physical state
→ Session state
→ current/latest pointer
→ writer ownership
→ player/application visible result
→ durable side effects
→ retry/restart behavior
```

至少分析：

A. fresh Application，无 Game Library record、无 legacy DB；  
B. 无 record，但 legacy `current-game.sqlite` 存在；  
C. Continue legacy healthy → open → adopt；  
D. legacy corruption / recovery required；  
E. 两个 independent managed Game records / DBs；  
F. Continue current Game A；  
G. Game A → Main Menu → select/open Game B；  
H. selected DB missing；  
I. Game Library record `game_id` 与 DB internal identity mismatch；  
J. Game B corrupt while Game A healthy；  
K. same Game writer already owned by another process；  
L. Application restart → same current/latest selection；  
M. Game Library record/current metadata publish failure；  
N. current pointer references missing/invalid record；  
O. Windows close while Game active；  
P. Continue with no existing Game must not create empty DB；  
Q. adopted legacy Game Save/backup/recovery remains functional；  
R. task-owned multi-Game fixtures must not touch Owner real Game or Source Library。

如果需要 production SQLite schema change 才能完成，返回 `BLOCKED`。

---

## 8. Decision Digest / Invariants

### INV-GAME-LIB-01｜Game Library != Game truth

Game Library 可拥有 Application 层 durable index/projection：

```text
Game record identity
player-safe display metadata
storage kind / exact resolved database location
current/latest selection intent
legacy adoption bookkeeping
```

它不拥有：

```text
World state
Timeline head
Save Points
Conversation
Recovery checkpoints
Source materialization
```

Game gameplay truth 仍在对应 Game SQLite / Domain owners。

### INV-GAME-LIB-02｜Game record 必须与 DB identity 交叉验证

打开 record 时：

```text
resolve safe existing DB path
→ open existing Game Runtime
→ require runtime.game_id == record.game_id
→ only then accept Session / update current pointer
```

若 mismatch：close runtime + fail-loud；不得“修 metadata 就算了”，也不得猜另一个 Game。

### INV-GAME-LIB-03｜Continue/Switch 不得创建 Game

当前 `CurrentGameRuntime` 对 missing explicit path 仍具有 historical first-run creation seam。

G4-04 Application/Game Library 必须在调用 Runtime 前验证所选 record 指向的是**已存在** Game DB。

因此：

> Continue / Select / Switch missing DB → fail-loud; never mint replacement Game.

正式 Game 创建只属于 G4-06 Atomic Final Create。

### INV-GAME-LIB-04｜一个 Application 同时只有一个 writable Game Session

Switch ordering：

```text
active Game A
→ cancel/cleanup A using G4-01 close seam
→ writer/SQLite/provider/view ownership released
→ resolve B
→ open B
```

不得在同一个 Application 中同时保留两个 writable Runtime。

### INV-GAME-LIB-05｜Per-Game safety evidence 必须保持

每个 DB 独立拥有：

- writer lock；
- backup/recovery root；
- corruption classification；
- Save/Restore/Recovery semantics。

Game B corruption 不得让 Game A 失去可打开性；Game A 的 recovery 不得替换 Game B。

### INV-GAME-LIB-06｜current/latest 是显式 Application state

Continue 使用 Game Library 明确持久化的 current/latest selection，不根据：

- filesystem mtime；
- directory order；
- filename lexical order；
- DB 内最近一条 Timeline

自动猜测。

current pointer 只在 selected Game 成功打开并通过 identity verification 后切换。

### INV-GAME-LIB-07｜Library metadata publish 必须 crash-safe / fail-loud

Game Library record/current pointer 属于 Application durable metadata，至少使用 complete-temp + same-volume atomic rename 或等价安全策略。

record/current publish failure：

- 不破坏旧 current；
- 不改变 Game DB truth；
- retry 可安全收敛；
- restart 不读取 partial metadata。

### INV-GAME-LIB-08｜Legacy adoption non-destructive

第一次显式 Continue / equivalent adoption action 可以：

```text
existing legacy DB
→ normal G3 open/recovery path
→ obtain verified runtime.game_id
→ create Game Library record pointing to legacy path
→ set current after successful open
```

Application boot 只为显示 Main Menu 时不得打开 legacy DB。

不得移动、重写、复制或删除 Owner legacy DB/recovery artifacts 作为 adoption 前置条件。

### INV-GAME-LIB-09｜No G4-05 leakage

本任务不得实现：

- Source selection UI；
- Game Creation Composition；
- real New Game Wizard；
- Atomic Final Create；
- Source pin/materialization；
- Expansion；
- Player/Guaranteed NPC creation。

可以提供后续 Final Create 需要的 narrow registration seam，但它必须只注册**已经存在且 identity 验证通过**的 independent Game storage；不能偷偷承担创建。

### INV-GAME-LIB-10｜Source Library completely separate

G4-03 Source Library 不参与 Game Library startup truth，不把 Source inventory 塞进 Game records，也不因 Game switch 扫描/修改 Source Library。

### INV-GAME-LIB-11｜Historical real-asset pressure is not this task

G4-04 不需要再创建 synthetic World/Character fixtures；Source content 不在本任务变量中。

根据 Owner 对真实资产验证的最新方向：后续 G4-05/06 应开始引入由历史真实资产内容按新 contract 重新封装的 packages，G4-07 First Playable A 必须以真实有产品价值的 World/Character 为主要 Reality/UAT 输入，而不是继续只靠 Agent 自创 compact fixtures。

### INV-TEST-01｜Owner real data isolation

Automated tests 必须使用 task-owned roots / DBs，例如 `build/g4_04_*`。

不得创建、移动、删除、注册、恢复或故障注入 Owner 的：

- `user://my-world/current-game.sqlite`；
- real Game Library；
- real Source Library。

---

## 9. Suggested first-generation Game Library metadata model

最终文件命名可由实现前矩阵细化，但语义需保持最小：

```text
GameLibraryRecord
- schema_version
- game_id
- display_name
- storage_kind: managed | legacy_g3
- safe storage reference / derived database path

CurrentSelection
- schema_version
- game_id
```

建议：

- managed Game path 由 `game_id` 派生，不接受任意 absolute external DB path；
- legacy path 是唯一显式 special case；
- record filename/path 与 `game_id` 互相校验；
- display metadata 可由后续 Final Create 更新/写入，但不能反向拥有 gameplay truth。

不要建立通用 ORM / repository framework / database service。

---

## 10. Scope

### Allowed

- minimal `src/game_library/` 或语义等价 Application-domain module；
- Game Library record/current metadata storage；
- safe per-Game path resolver；
- legacy G3 adoption seam；
- exact existing Game registration seam for later Final Create；
- Application Continue integration with Game Library；
- narrow select/open/switch seam；
- necessary small `CurrentGameRuntime` open-existing helper/guard if matrix proves useful, without persistence semantic rewrite；
- minimal Main Menu/Game Library host adaptation only as necessary to prove lifecycle；
- focused task-owned tests；
- real Windows-local GUI/filesystem evidence；
- `docs/tasks/G4-04_实现前GameLibrary生命周期与失败矩阵.md`；
- necessary Game Library contract doc。

### Prohibited

- shared SQLite multi-tenant design；
- production SQLite schema migration；
- real New Game Wizard / Source chooser；
- Game creation from UI；
- Atomic Final Create/materialization；
- Source pin registry；
- Expansion；
- Runtime Asset Resolution；
- G5 semantics；
- account/cloud/server/multiplayer；
- generic DB service/repository/DI/EventBus/navigation framework；
- destructive legacy DB relocation。

---

## 11. Required Deliverables

1. pre-implementation lifecycle/failure matrix；
2. Game Library durable metadata contract；
3. per-Game path resolver + safe record/current storage；
4. legacy G3 adoption in place；
5. existing managed Game registration seam；
6. current/latest resolution；
7. Continue through Game Library, no missing-DB creation；
8. select/open/switch lifecycle using G4-01 close seam；
9. identity mismatch fail-loud；
10. per-Game single-writer/backup/recovery isolation proof；
11. restart-stable Game Library metadata；
12. focused failure tests；
13. relevant G3/G4-01 regression；
14. real Windows-local GUI/filesystem evidence；
15. implementation commit(s) + push main；
16. Final Report max `READY FOR INDEPENDENT REVIEW`。

---

## 12. Acceptance Gates

### AC-01｜Two independent Games coexist

Task-owned Game A / Game B 使用两个独立 SQLite，具有不同 `game_id`、Conversation/head/world truth，互不覆盖。

### AC-02｜Continue resolves explicit current Game

Application Continue 从 Game Library current selection 解析 exact existing DB path；不使用 mtime/目录顺序猜测。

### AC-03｜Switch closes before open

A → Menu/select B：A Runtime/SQLite/writer/provider/view 完整关闭后才打开 B。切回 A 仍恢复 A 自己的 durable truth。

### AC-04｜No accidental creation

record DB missing、current record missing、fresh Application without Games 均不得因 Continue/Select 创建空 SQLite/Game。

### AC-05｜Identity mismatch fails loud

record `game_id` 与 DB internal identity 不一致时，所开 Runtime 被关闭，current pointer 不切换，玩家/调用方收到明确 failure。

### AC-06｜Legacy adoption preserves G3 truth

健康 legacy `current-game.sqlite` 可在显式 Continue/adoption path 被登记，不移动 DB；same `game_id`/head/Conversation/Save/Recovery truth 保持。

### AC-07｜Legacy corruption still uses G3 recovery

legacy DB 损坏时不先伪造 Game Library record、不创建新 Game；原有 safe-backup recovery UX/semantics 仍可达。

### AC-08｜Per-Game recovery isolation

Game B corruption/backup/recovery 不修改 Game A DB/backup/current truth；A 仍可独立打开。

### AC-09｜Restart stability

新 Godot process 从 Game Library durable metadata 恢复相同 record set + current selection，不打开所有 Game DB 作为 Main Menu boot 前置条件。

### AC-10｜Metadata failure safety

record/current atomic publish failure 不破坏旧 current，不修改 Game DB truth；partial temp 不进入 inventory；retry 收敛。

### AC-11｜Scope discipline

No G4-05 Source chooser/composition/create；No SQLite schema migration；No shared DB；No Provider requirement；No real Owner data touched by automated tests。

### AC-12｜Windows/Application reality

真实 Godot 4.7.2 Windows-local 环境证明：

```text
Launch → Main Menu without Game DB open
Continue current Game A
→ Return
→ select/open B via task-approved product/internal seam
→ Return
→ reopen A
```

如果 production Main Menu/scene 被修改，必须同时做真实 GUI sizing smoke（maximized、1280×720、960×540）并确认 G4-01 navigation/recovery controls 不退化。

---

## 13. Validation Plan

先从 repo current tests 推导 exact commands；不要发明不存在的 runner。

至少覆盖：

- Game Library record/current metadata positive + negative；
- two per-Game SQLite reality；
- missing DB no-create；
- game_id mismatch；
- current publish interruption/retry；
- restart independent process；
- A/B switching same durable truth；
- per-Game writer lock isolation；
- corrupt B / healthy A；
- legacy adoption；
- legacy G3 recovery path；
- G4-01 Application lifecycle regression；
- G3 reopen/Save/Recovery/single-writer directly impacted suites。

Provider call = **not required**。

Windows export：如果 Application/main scene production path 改动影响 packaged behavior，则 rerun Windows Desktop export + executable smoke；若仅 internal foundation and GUI current path unchanged，可在 Final Report 解释为何 real Godot GUI evidence 足够。不要无证据宣称 export PASS。

---

## 14. Git / Integration

Codex 负责 routine Git：

1. fetch + fast-forward；
2. record start HEAD/status；
3. matrix → implementation → focused tests；
4. relevant G3/G4-01 regression；
5. Windows reality；
6. pre-push：

```text
git fetch origin
git rev-parse HEAD
git rev-parse origin/main
git status --short
```

7. 若 `origin/main` 前进：
   - unrelated docs/scope：安全吸收并重跑 impacted gates；
   - Application/Runtime/Persistence/Game Library seam 或 architecture decision 变化：`BLOCKED`；
8. commit + push `main`；
9. final clean tracked worktree。

禁止：`reset --hard`、`clean -fd`、force push、覆盖未知 dirty worktree。

Task Packet commit 不是 implementation evidence。

---

## 15. Stop Conditions

返回 `BLOCKED` 而不是扩 scope，如果：

- current authority 推翻 per-Game SQLite decision；
- production schema migration 才能实现；
- legacy adoption 必须 destructive move 才能成立；
- G3 Runtime cannot open selected per-Game path without persistence redesign；
- Game Library metadata 必须拥有 gameplay truth 才能继续；
- concurrent production implementation 修改同一 seam；
- required Windows/Godot reality 无法执行；
- 实现需要 G4-05+。

---

## 16. Final Report

```markdown
## Result
READY FOR INDEPENDENT REVIEW | BLOCKED

## Base / Freshness
- Formal Code Base:
- Start HEAD:
- Final HEAD:
- origin/main revalidation:

## Storage Topology
- per-Game SQLite confirmation:
- Game Library metadata shape:
- legacy adoption shape:

## Changed
- file → behavior

## Lifecycle / Failure Matrix
- path:
- key decisions/findings:

## Evidence
- two-Game reality:
- missing/mismatch/failure:
- restart:
- writer/recovery isolation:
- legacy adoption/recovery:
- G3/G4-01 regression:
- GUI / Windows:

## Product Path Now
Launch
→ ...

## Git
- commits:
- pushed:
- final status:

## Scope Check
- shared SQLite? NO
- SQLite schema changed? NO
- G4-05 started? NO
- Source pin/materialization? NO
- Provider called? NO

## Remaining / Risks
- ...
```

---

## 17. Completion Rule

```text
Implementation
→ READY FOR INDEPENDENT REVIEW
→ Independent Review
→ G4-04 PASS / CLOSED
→ G4-05
```

Owner UAT is not required for this foundation task; G4-07 remains the next mandatory real World+Character Owner UAT gate.
