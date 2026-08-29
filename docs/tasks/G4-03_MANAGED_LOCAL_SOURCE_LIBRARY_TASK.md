---
title: my world｜G4-03 Managed Local Source Library v0.1 Task Packet
status: current-task-packet
task_id: G4-03
type: implementation
owner: Codex
created: 2026-08-29
updated: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: d8405e046ee2134361ec7ab1257f98c7a86c24a8
governance_base: 867071525d58ad68b689ff1074243ac164f3212e
local_project: D:\AI\Projects\my-world
highest_implementation_status: READY FOR INDEPENDENT REVIEW
owner_uat_required: false
---

# TASK｜G4-03｜Managed Local Source Library v0.1

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `d8405e046ee2134361ec7ab1257f98c7a86c24a8`

> 本任务把 G4-02 已成立的 World Pack / Character Card contract 接入一个 Program 管理的本地 Source Library。目标是 **immutable generation publication + current inventory + restart truth**，不是 New Game UI、Game Library 或 Creator。

## 1. Outcome

完成后，项目应拥有一个最小但真实的 Managed Local Source Library：

```text
explicit local Source package
→ G4-02 production contract validate/load
→ stage contract-owned package content
→ revalidate exact generation
→ publish immutable generation into managed library
→ set current installed generation for that Source identity
→ inventory/reload after process restart
```

同时证明：

```text
external mutable package
!= managed immutable generation

stable Source identity
!= exact generation

Source Library
!= Game Library
```

实现 Agent 最高返回：

```text
READY FOR INDEPENDENT REVIEW
```

不得开始 G4-04。

---

## 2. Why Now

G4-02 已通过 Engineering + Independent Review 并正式 **PASS / CLOSED**。

当前 DAG：

```text
G4-02 Source Contracts CLOSED
→ G4-03 Managed Local Source Library
→ G4-04 Multi-Game / Game Library
→ G4-05 New Game Wizard
```

New Game 不能直接消费任意 mutable external folder；后续选择必须来自 Program 已验证、可重复定位的 exact Source generation。因此 Library 必须先于 Wizard 成立。

本任务是 local infrastructure / source-management foundation，不直接改变玩家主路径，`owner_uat_required: false`。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `zhangchenjia21-dot/Vibe-Coding/main/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — Primary Source / Managed Source Library / exact generation boundaries。
6. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G4-03 / G4-04 / G4-05 sequencing。
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — G4-02 CLOSED / G4-03 current。
8. repository `AGENTS.md`。
9. G4-02 production Source contract implementation/tests at current repo HEAD。
10. `Vibe-Coding/skill/gpt/lifecycle-dev-process/SKILL.md`。
11. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md`。

Governance base at issuance:

`867071525d58ad68b689ff1074243ac164f3212e`

Formal implementation base:

`d8405e046ee2134361ec7ab1257f98c7a86c24a8`

Not authoritative unless explicitly used as historical evidence:

- old G4 Source Library drafts / superseded packets；
- legacy SillyTavern / The World / DSH storage layout；
- chat summaries；
- model memory。

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
- audit `Formal Code Base → START_HEAD`，确认只有 G4-03 packet / current-status projection 等已知文档增量；
- 若出现未知 Source Library production implementation、改变 G4-03 topology/ownership 的新决策或并行修改同一 seam，先 audit；无法安全吸收则 `BLOCKED`；
- authoritative push 前再次 fetch/revalidate。

---

## 5. Read First｜最小充分工作集

按顺序读取：

1. `AGENTS.md`
2. `docs/tasks/G4-03_MANAGED_LOCAL_SOURCE_LIBRARY_TASK.md`
3. `docs/source/World Pack与Character Card合同v0.1.md`
4. `src/source/L3_外交层/Source合同公开接口.gd`
5. `src/source/L2_流程层/世界包加载流程.gd`
6. `src/source/L2_流程层/角色卡加载流程.gd`
7. `tests/g4_02/` 中 reality / negative tests

再读取 current Architecture / Roadmap 中 Managed Source Library、exact generation、G4-03～G4-05 直接相关段落。

只有现有证据不足时才扩大读取范围；不要默认读整个仓库或 legacy implementation。

---

## 6. Pre-implementation Publish / Failure Matrix｜编码前必须完成

在 production Library code 前先形成：

`docs/tasks/G4-03_实现前SourceLibrary发布与失败矩阵.md`

至少覆盖：

```text
Case
→ external package state
→ G4-02 validation result / fingerprint
→ staging state
→ managed generation state
→ current pointer/inventory state
→ durable side effects
→ failure cleanup
→ retry behavior
→ restart behavior
```

至少分析：

A. 第一次安装合法 World；  
B. 第一次安装合法 Character；  
C. 同一 exact generation 重复安装；  
D. 同一 stable identity 安装不同 generation；  
E. 同一 authored version 但 content/fingerprint 不同；  
F. external package 在安装后被修改/删除；  
G. invalid package / unsafe reference；  
H. staging copy 中途失败；  
I. staged content 与初次 validation fingerprint 不一致；  
J. final generation 已存在；  
K. current metadata/pointer publish 失败；  
L. restart 后 inventory reload；  
M. managed current generation 被手工篡改/缺文件；  
N. stale/incomplete staging residue；  
O. task-owned test library 与 Owner real library 隔离。

如果必须先决定 Game Library / multi-Game topology 才能完成，返回 `BLOCKED`；不要偷做 G4-04。

---

## 7. Decision Digest / Invariants

### INV-LIB-01｜Source Library != Game Library

Managed Source Library 只拥有：

```text
installed Source inventory
managed immutable Source generations
current installed generation per stable Source identity
Source validation/publication metadata
```

它不拥有：

```text
Game identity
active Game
Continue/switch
Save/Timeline
Game-local World/Character reality
```

不得为了“以后 New Game 会用”提前实现 Game Library。

### INV-LIB-02｜External package 不是已发布 generation

任意 external/local authored package 在安装前仍是 mutable input。

正式链路必须是：

```text
external package
→ G4-02 production validation
→ managed staging
→ verify staged exact generation
→ publish immutable generation
```

后续 inventory / exact-generation lookup 只能指向 managed generation，不得继续实时读取外部目录作为已安装 Source authority。

外部 package 安装后被编辑、移动或删除，不得改变已经发布的 managed generation。

### INV-LIB-03｜Published generation append-only / immutable

Managed generation 的业务 identity 至少包含：

```text
asset_type
asset_id
version
exact generation_fingerprint
```

不同 fingerprint 必须是不同 generation。

第一代最安全策略：**不提供 generation 删除/uninstall pruning**。安装新 generation 只新增，不覆盖旧 generation。

这天然满足后续：

> Existing Game pin old generation → installing newer Source cannot silently mutate it.

真正的 Game pin registry 留到后续 Game materialization / lifecycle 需要时再接；本任务不要伪造 Game references。

### INV-LIB-04｜Current installed generation 是 Library state，不是版本排序猜测

第一代 current generation 表示：

> 某 stable Source identity 最近一次**成功发布并提交为 current**的 exact generation。

不要对作者 `version` 字符串做 semver/latest 自动猜测，也不要因目录名或 mtime 自动切换 current。

同一 `asset_id + version` 也可能因内容改变形成不同 exact generation；successful install 可以将新的 generation 设为 current，同时保留旧 generation。

### INV-LIB-05｜Duplicate exact install 必须 idempotent

重复安装相同 exact generation：

- 不复制第二份 generation；
- 不制造重复 inventory row/entry；
- 返回明确 `already_installed` / replay-safe 等价结果；
- current 指向该 generation 时不产生无意义 churn；
- 若 generation 已存在但尚不是 current，可按明确 install intent 原子设为 current。

不要用随机 install ID 让相同 package 重复膨胀。

### INV-LIB-06｜Publish 必须 staged + verified + atomic-visible

不要直接把 external files 逐个写进 final generation directory。

推荐最小顺序：

```text
validate external package
→ obtain expected fingerprint
→ stage under managed library root / same volume
→ copy only contract-owned package content
→ run G4-02 production loader on staged package
→ require staged fingerprint == expected fingerprint
→ publish stage to exact final generation location
→ atomically publish/update current pointer metadata
```

具体文件布局由实现前矩阵决定，但必须满足：

- incomplete stage 不得出现在 inventory；
- current pointer 不能先于 generation 可用；
- current metadata 更新失败时，旧 current 保持有效；
- final generation 已存在时必须验证其 exact content，不得盲信目录名；
- retry 可安全收敛。

### INV-LIB-07｜只复制 contract-owned content

Managed generation 至少包含可由 G4-02 loader 完整重放的：

- `source.json`；
- World `authored_assets[]` 声明文件；
- Character portrait 声明文件；
- 未来 contract 明确拥有的其它 referenced files。

未声明草稿、编辑器缓存、临时文件、`.import` 等不因位于 external package 目录就自动进入 managed generation。

G4-02 generation fingerprint 仍是 exact-generation authority；Library 不发明第二套 content hash。

### INV-LIB-08｜Inventory 必须 restart-stable 且 fail-loud

Library 不能只靠内存列表。

新进程/reload 后必须从 managed storage 恢复：

```text
stable Source identity
current exact generation
version/display metadata needed for future chooser
exact-generation lookup capability
```

如果 current pointer 指向 missing/corrupt/tampered generation：

- fail-loud；
- 不 silent fallback 到另一个 generation；
- 不从 external source 自动修复；
- 不凭 mtime/目录排序猜一个新的 current。

Stale staging residue 不能出现在 inventory；可安全忽略或 task-scoped cleanup，但不能误发布。

### INV-LIB-09｜Managed tamper 必须可发现

从 managed generation 读取/恢复 inventory 时，必须复用 G4-02 production contract 验证 exact fingerprint。

测试至少证明：

- external package 安装后修改 → managed generation 不变；
- managed published file 被篡改 → exact lookup/current inventory fail-loud 或标记 invalid，不静默接受；
- generation directory 名称中的 fingerprint 不能替代内容验证。

### INV-LIB-10｜Public seam 服务后续 consumer，但不预做 Wizard

最小 public seam 应足以支持后续 G4-05/G4-06，例如语义等价于：

```text
install explicit package
list current installed World/Character Sources
get current exact generation for stable Source identity
get exact retained generation by identity + fingerprint
```

接口具体命名由实现决定。

本任务不得实现：

- chooser UI；
- selection state；
- compatibility review；
- Game pin；
- Final Create。

### INV-TEST-01｜测试不得碰 Owner real Source Library

所有 automated tests 必须使用 task-owned library root，例如参数/注入路径。

测试不得创建、修改、清理 Owner production：

`user://my-world/source-library`（若最终采用该默认位置或语义等价 production root）。

Production default root 可以在本任务明确，但 test path 必须显式隔离。

### INV-PRODUCT-01｜当前增量的产品价值

本任务不直接做 UI，但它必须保证后续玩家看到的 Source 选择是可重复、不会被外部文件静默改变的：

> **玩家选择的是 Program 管理的 exact Source generation，而不是当时碰巧存在的可变文件夹。**

这是后续 New Game reproducibility、旧 Game isolation 与 Runtime Asset Resolution 的基础。

---

## 8. Scope

### Allowed

- 在现有 `src/source/` 下新增最小 Library-specific L0/L1/L2/L3 组件；
- managed generation filesystem layout；
- task-owned / injectable library root；
- staging + publish + current metadata；
- inventory/reload；
- exact generation lookup；
- World/Character install using G4-02 production contract；
- task-scoped filesystem failure/restart/tamper tests；
- `docs/tasks/G4-03_实现前SourceLibrary发布与失败矩阵.md`；
- 必要的 source/library contract doc；
- 与 G4-03 直接相关的 G4-02 regression adaptation（不得削弱断言）。

### Prohibited

- G4-04 multi-Game / Game Library / storage topology；
- G4-05 New Game UI / chooser / selection composition；
- G4-06 Final Create / Game pin / materialization；
- Expansion Pack；
- Runtime Asset Resolution / image cache；
- Creator / Draft publishing UI；
- cloud/store/network Source service；
- automatic external folder watcher；
- arbitrary code/plugin execution；
- semantic-version resolver / dependency solver；
- uninstall/pruning/history-picker product UI；
- production SQLite Game schema changes；
- Provider calls；
- generic package manager framework。

---

## 9. Required Deliverables

1. Managed Local Source Library v0.1 production implementation；
2. explicit install path for World Pack + Character Card；
3. staged + verified exact-generation publication；
4. append-only retained generations；
5. current-installed generation metadata/inventory；
6. restart/reload truth；
7. exact-generation lookup；
8. duplicate install idempotency；
9. managed tamper/missing detection；
10. task-owned library-root isolation；
11. `docs/tasks/G4-03_实现前SourceLibrary发布与失败矩阵.md`；
12. focused positive/negative/failure/restart tests；
13. relevant G4-02 contract + G4-01 boot regression；
14. real Windows-local Godot filesystem evidence；
15. implementation commit(s) + push `main`；
16. Final Report，最高 `READY FOR INDEPENDENT REVIEW`。

---

## 10. Acceptance Gates

### AC-01｜World + Character install through production contract

至少一个真实 World fixture 与一个真实 Character fixture 通过 G4-02 production L3 contract 安装进 task-owned managed library；不得 duplicate parser/validator 绕开正式 contract。

### AC-02｜Managed generation detached from external package

安装成功后修改/删除 external package，managed generation 的 exact fingerprint、可读取 Source projection 与 inventory 仍保持原值。

### AC-03｜Different generation retained

同一 stable Source identity 安装第二个不同 fingerprint generation：

- new generation 成为 current；
- old generation 仍可 exact lookup；
- old files 未被覆盖；
- 不要求 Game pin registry 才能保留。

### AC-04｜Duplicate exact install idempotent

相同 exact package 重复安装不会制造重复 generation；结果 replay-safe，inventory 唯一。

### AC-05｜Restart truth

创建新的 Library instance / 新 Godot test process 后，从 managed storage 恢复与安装前一致的 current inventory 和 retained exact-generation lookup。

### AC-06｜Atomic visibility / failure preservation

至少通过 deterministic fault fixture 或 filesystem failure case 证明：

- incomplete stage 不进入 inventory；
- publish/current metadata 失败不破坏旧 current；
- retry 后可安全成功；
- stale staging 不被误发现为 installed generation。

不要让只在 happy path 成功的 copy routine 冒充 managed publication。

### AC-07｜Tamper detection

至少证明：

- final generation missing declared file → fail-loud；
- final generation declared bytes changed → fingerprint mismatch / invalid generation；
- Library 不因目录名正确而信任损坏内容；
- 不 silent fallback 到历史 generation。

### AC-08｜Inventory semantics

current inventory 至少暴露 future chooser 所需的 player-safe Source metadata + exact generation identity；World/Character 保持类型区分；不返回 Game-local/live state。

### AC-09｜No external directory authority after publish

Library reload/get exact generation 不依赖原 external package path；external path 不作为 authoritative installed Source location。

### AC-10｜No G4-04+ leakage

无 Game identity、active Game、multi-Game DB、New Game selection/composition、Game pin、Final Create、Expansion、Runtime Asset Resolution、Creator。

### AC-11｜Regression

G4-02 positive/negative/fingerprint/path-safety tests保持通过；G4-01 Application boot 不扫描 Source Library、不自动安装 Source、不打开 Game DB。

### AC-12｜Real Windows filesystem proof

在 Godot 4.7.2 Windows-local 环境使用 task-owned directories 真实执行 install → reload → second generation → tamper/failure tests；不能只 mock filesystem 或 construct in-memory index。

---

## 11. Validation Plan

先按 current repository runner 确认 exact commands，不伪造不存在的脚本。

推荐证据顺序：

```text
1. parse / Source module load
2. G4-03 focused happy path
3. duplicate + second-generation retention
4. restart/reload in a fresh Library instance/process
5. fault/staging/current-pointer preservation
6. tamper/missing managed generation
7. G4-02 full focused regression
8. G4-01 minimal boot/lifecycle regression
9. real Windows-local filesystem run
```

Focused tests 至少使用两类真实 G4-02 fixtures，而不是重新 construct fake dictionaries。

如果为了测试 crash-like 中断增加 fault injection seam：

- 必须 task-only / explicit；
- 不得进入普通 product behavior；
- 不要发展成通用 chaos framework。

G4-03 不要求 exported EXE Gate，也不要求 Provider call。

---

## 12. Independent Review Readiness

后续 Reviewer 重点检查：

```text
managed generation still reads external mutable path?     NO
new install overwrites old generation?                    NO
fingerprint directory trusted without revalidation?       NO
current chosen by mtime/version guess?                     NO
staging residue appears in inventory?                     NO
failure can erase previous current?                       NO
duplicate exact install creates duplicate generation?     NO
Library secretly owns Game state?                         NO
G4-02 contract duplicated/bypassed?                       NO
```

Mock-only / in-memory inventory 不能作为 PASS 证据。

---

## 13. Git / Integration

Codex 负责 routine Git：

1. fetch + fast-forward；
2. 记录 start HEAD / status；
3. implementation + tests；
4. focused → failure/restart/tamper → regression → Windows filesystem reality；
5. pre-push freshness：

```powershell
git fetch origin
git rev-parse HEAD
git rev-parse origin/main
git status --short
```

6. 若 `origin/main` 前进：
   - 无关 docs：安全吸收并重跑受影响 evidence；
   - 改变 Source contract / Library ownership / G4 DAG：停止并 `BLOCKED`；
7. commit + push `main`；
8. final tracked worktree clean。

禁止：

```text
git reset --hard
git clean -fd
force push
覆盖未知 dirty worktree
```

不要提交 build、Godot cache、task temp library、logs、Owner data 或 secrets。

---

## 14. Stop / Return Conditions

返回 `BLOCKED`，不要猜，如果：

- current governance 与本 Packet 实质冲突；
- G4-02 contract 必须重开才能定义 managed publication，且无法在窄 compatibility-free 修正内完成；
- 必须先决定 multi-Game physical topology；
- 必须建立 Game pin registry / Final Create 才能完成核心 Library truth；
- Windows filesystem 无法提供可靠 staging/publish/reload evidence；
- 任务开始要求 G4-04+ 才能成立；
- 发现未知并行 production Library implementation。

以下不是 blocker：

- 需要新增窄的 managed-library L1/L2/L3 seam；
- 需要 task-owned injectable root；
- 需要简单 atomic JSON/current metadata；
- 需要 append-only generation directory；
- 需要 task-scoped fault injection 证明失败保存旧 current。

---

## 15. Final Report Format

```markdown
## Result
READY FOR INDEPENDENT REVIEW | BLOCKED

## Base / Freshness
- Formal Code Base:
- Start HEAD:
- Final HEAD:
- origin/main revalidation:

## Library Shape
- production root / injectable test root:
- generation identity/layout:
- current metadata authority:
- exact lookup seam:

## Publish / Failure Matrix
- path:
- key decisions:

## Changed
- file → behavior

## Evidence
- install World/Character:
- duplicate / second generation:
- restart/reload:
- failure preservation:
- tamper/missing:
- G4-02 regression:
- G4-01 regression:
- Windows filesystem:

## Git
- commits:
- pushed:
- final status:

## Scope Check
- G4-04 started? NO
- Game pin implemented? NO
- SQLite Game schema changed? NO
- Provider called? NO

## Remaining / Risks
- ...
```

不要只回复“完成”。

---

## 16. Explicit Handoff Boundary

G4-03 完成后：

```text
Implementation
→ Independent Review
→ G4-03 CLOSE
```

本任务不要求 Owner UAT。

只有 G4-03 正式关闭后，才允许进入：

```text
G4-04 Multi-Game Lifecycle / Game Library Foundation
```

Codex 不得在本任务内预做 G4-04。