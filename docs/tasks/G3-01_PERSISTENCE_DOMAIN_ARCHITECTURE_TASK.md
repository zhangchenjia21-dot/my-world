---
title: my world｜G3-01 Persistence Domain Architecture Task Packet
status: current-task-packet
task_id: G3-01
type: architecture-technical-spike
owner: Codex
created: 2026-08-26
updated: 2026-08-26
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 9c577811fd71d19f514ca4e9455e02321f0aa34d
stage_rules_base: 65de46e58d35630be99089bd641f156da2514b15
local_project: D:\AI\Projects\my-world
---

# TASK｜G3-01｜Persistence Domain Architecture

Type: `architecture-technical-spike`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

## 1. Outcome

用**真实 Godot 4.7.2 Standard / non-.NET Windows x64 证据 + 小型隔离 fixture**，冻结 G3 第一代 Persistence Domain 的最小架构边界，为 G3-02～G3-06 提供可实现基础。

本任务必须回答：

```text
什么是 authoritative durable truth？
哪些对象属于哪个 owner？
一次 durable mutation 的 atomic boundary 是什么？
SQLite 在当前 Foundation 下是否真实可用？
Timeline Node / Save Point / Snapshot / Checkpoint 分别是什么？
Migration / crash / interrupted write 如何避免物理损坏或半提交？
Restore future isolation 需要哪些 durable references？
```

本任务不是最终 Persistence feature implementation。最高状态：

> **READY FOR INDEPENDENT REVIEW**

不得自行开始 G3-02。

---

## 2. Why Now

G2-GATE 已通过。当前产品已经有稳定 Conversation / Context Spine，但一旦进程退出，Game/World/Conversation/Timeline 尚没有正式 durable backbone。

路线图下一条真实产品脊柱是：

```text
AI GM 游玩
→ durable change
→ 退出 / 重开仍是同一 Game
→ explicit Save
→ 继续未来
→ Load / Restore
→ World + Context 一致恢复
→ 被回滚未来不泄漏
```

在开始写 G3-02 durable mutation path 前，必须先冻结存储与 ownership 边界，否则 Save/Timeline/Conversation 很容易混成第二 truth、文件 dump 或不可恢复历史。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `Vibe-Coding/AGENTS.md` — current governance / freshness / lifecycle。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — Product Purpose / durable world promise。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md` — `Runtime makes it durable`、recovery-first、Model freedom。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — current architecture map。
6. `Vibe-Coding/my world/architecture/persistence/时间线存档与可逆性设计.md` — Save/Timeline/Restore semantics。
7. `Vibe-Coding/my world/architecture/foundation/Foundation架构决策_v1.0_2026-08-26.md` — Godot/GDScript/same-process + SQLite evaluation candidate。
8. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` / `MY_WORLD_CURRENT_STATUS.md` — G3-01 current stage/task。
9. 本仓库 `AGENTS.md`、current code/tests/HEAD。
10. Current `agent-task-packet` / `lifecycle-dev-process` Skills only as execution method; they do not override project decisions.

Not authoritative:

- old SillyTavern/The World/DSH persistence implementation；
- Markdown Runtime DB / periodic consolidation patterns；
- historical chat summaries；
- arbitrary per-turn rewind designs；
- model memory about old project schemas。

---

## 4. Read First

开始前：

1. fetch / fast-forward 最新 `origin/main`；
2. 记录 start HEAD 与 `git status --short`；
3. 确认本 packet 是 current G3-01；
4. 初始只读：

```text
AGENTS.md
本 Task Packet
src/domain/会话.gd
src/domain/对话回合.gd
src/context/上下文组装器.gd
project.godot
export_presets.cfg
```

然后读取上述 Source Manifest 中**Persistence / Foundation 直接相关 current sources**。

只有为 SQLite binding、Windows export、已有测试基线或真实 spike 所需时扩大仓库读取；Final Report 说明原因。

---

## 5. Pre-implementation Ownership Matrix｜先定义再 spike

编码前先在 working notes / Final Report 中完成此矩阵；不要先写数据库再让 schema 反向决定产品语义。

至少分类：

```text
Game
World State
Timeline
Timeline Node
Save Point
Conversation
Agent Context
UI Preference
Source / World Pack material
Derived UI / Transcript / Cache
```

每项回答：

```text
Canonical owner
Authoritative / Derived / Cache / Reference
Durable? yes/no/conditional
Timeline-scoped? yes/no
Restore 时如何处理
谁可写
谁只读
```

必须体现：

- `Conversation != Timeline`；
- `Save Point != Timeline Node`；
- UI Preference 不应随 Game Restore 回滚；
- Context Assembly messages 不是 durable truth；
- future Context material 必须可按 restored head 重建/隔离；
- Source 是 reusable reference，开局后的 game-local reality 才是本局 authoritative truth。

---

## 6. Pre-implementation Failure Matrix

至少分析并为 spike 选择可验证项：

```text
normal commit
transaction rollback
process dies before COMMIT
process dies after COMMIT
DB reopen
schema migration success
schema migration fails midway
DB file missing
DB file unreadable/corrupt
Save points to valid old timeline node
active head moves after old Save restore
```

区分：

```text
Logical game mistake
!=
Persistence integrity failure
```

普通模型/Narrative错误不由 Persistence validator 审查；Persistence 只保护 durable integrity / recoverability。

---

## 7. Decision Digest / Required Architecture

### DEC-01｜Game is durable aggregate identity, not a file dump

第一代必须有稳定 `game_id` / equivalent durable identity。Game 是长期游玩实例的生命周期根，不等于当前 SceneTree，也不等于一个导出的 JSON snapshot 文件。

G3-01 不需要冻结完整 Game schema，但必须证明 identity 在 reopen 后稳定。

### DEC-02｜World State is authoritative game-local state

`World State` 表示某个 active timeline head 下的当前 game-local authoritative state。G3-01 用**最小 fixture state**验证事务，不提前设计 NPC/Faction/Item 等 G5 schema。

可使用类似：

```text
fixture key/value facts
fixture counter/status
```

只为证明 durable semantics，不宣布为 production World schema。

### DEC-03｜Timeline owns durable history/recovery anchors

Timeline 首先是 Runtime capability。

`Timeline Node` 至少需要能表达：

```text
stable node identity
parent / prior durable head relationship
Game association
commit/checkpoint timestamp or sequence
optional reason/kind metadata
```

不要因为可以记录每 Turn 就默认把每个 Turn 暴露为玩家 Load 点。

### DEC-04｜Save Point is named reference, not duplicate truth

第一代 Save Point 应建模为：

```text
player-visible metadata
+ reference to a durable restorable timeline node/head
```

而不是另外复制一套平行 World truth。

G3-01 只冻结关系与最小字段方向，不实现最终 Save UI。

### DEC-05｜Restore must preserve recoverability of current future

架构必须允许未来 G3-04/G3-05 实现：

```text
current head = H5
Save points to H2
Load H2
→ active head changes
→ H3..H5 不立即物理删除
→ old future 仍有可恢复 reference
```

G3-01 不要求完整 branch UI，但不得选择一种会迫使 Load 立即 destructive overwrite 的架构。

### DEC-06｜Conversation persistence is associated gameplay history, not World truth or Timeline identity

当前 G2 `Conversation` 是正式 Domain。G3 后需要 resume 与 restore 对齐，但：

- Conversation row/record != Timeline Node；
- Transcript text 不得成为 World authoritative database；
- restore 到旧 head 时，未来 Conversation/Context 不得泄漏；
- G3-01 只冻结关联方式/ownership方向，G3-02+ 才逐步 materialize production path。

### DEC-07｜Agent Context is rebuildable/derived with head binding

当前 Context Assembly output 是 derived request material，不持久化为 truth。

若未来为了性能持久化 Agent Context summary/cache，它必须：

- 明确绑定 Game/timeline head或有效范围；
- Restore 后能 invalid/rebuild；
- 不让被回滚 future summary 泄漏。

G3-01 不建设 summary/memory platform。

### DEC-08｜UI Preference is outside gameplay timeline

字体大小、窗口/UI偏好等不应随 Save/Restore 回滚。G3-01 在 ownership matrix 中明确分离，不需要现在实现 Settings persistence framework。

### DEC-09｜SQLite is preferred evaluation candidate, not dogma

必须在当前实际 Foundation 上验证可行性：

```text
Godot 4.7.2 Standard / non-.NET Windows x64
GDScript
same-process
Windows export
```

评估实际 binding / addon / GDExtension 时至少检查：

- 当前仍维护/可用于 Godot 4.x；
- Windows x64 compatibility；
- license / provenance 可记录；
- transaction BEGIN/COMMIT/ROLLBACK；
- parameter binding / escaping；
- reopen；
- exported EXE packaging；
- failure/error visibility；
- 不要求切 .NET 或外部 server/runtime。

若 SQLite 真实 spike FAIL：

> 不要用 mock 宣布 PASS；返回明确 blocker/evidence，并提出最小候选替代路线及 trade-off。

### DEC-10｜No full event sourcing by default

Event Log / mutation records / Snapshot 可以组合，但 G3-01 不默认选择“所有 World 状态只能从全量事件重放得到”。

优先评估简单模型：

```text
transactional authoritative current state
+ durable timeline/head metadata
+ append-only-ish mutation/timeline records where useful
+ periodic/explicit snapshot or checkpoint where useful
```

Snapshot / checkpoint 是恢复/性能 anchor，不自动等于 player Save Point。

### DEC-11｜Migration is explicit and transactional

至少冻结：

- persisted schema/version 有明确 version source；
- migration 必须显式、有序；
- migration failure 不得把唯一数据库留成半迁移；
- destructive migration 前的 backup/recovery strategy 在 G3 中必须可落地。

G3-01 应用小型 fixture 证明一个 migration success + one intentional migration failure/rollback path，或给出同等强度证据。

### DEC-12｜Tests use isolated persistence paths

所有 destructive / crash / migration spike：

- 使用测试专用目录/DB；
- 不扫描/猜测用户真实 Game 文件；
- 不覆盖 `user://` 中未知文件；
- 路径名明确含 `g3_01_test` / equivalent；
- 清理只删除本测试创建且 identity 明确的文件。

---

## 8. Required Real Technical Spike

如果 SQLite route 可用，至少真实证明：

### Spike A｜Basic open / schema / reopen

```text
create isolated DB
→ create minimal fixture schema
→ write game_id + fixture state + head
→ close process/connection
→ reopen
→ exact values survive
```

### Spike B｜Atomic durable mutation

构造一个 mutation 需要同时改变至少两类 fixture facts，例如：

```text
fixture world value
+ active timeline head
+ timeline node record
```

证明：

```text
COMMIT → all visible
ROLLBACK / forced failure before COMMIT → none visible
```

不能出现 half-new/half-old。

### Spike C｜Interrupted write / crash boundary

使用**隔离 helper process + exact PID / deterministic crash mechanism**，在 transaction 已写但未 COMMIT 时终止/崩溃；随后新进程 reopen，验证 last committed state 仍完整。

不得以“SQLite 理论上 ACID”替代真实 Windows evidence。

### Spike D｜Migration

最少 version N → N+1 fixture migration：

- success path；
- intentional failure path；
- failure 后旧 usable state/schema 不被静默半改。

### Spike E｜Windows export

导出后的真实 EXE 至少完成一次：

```text
open/create test DB
write
close/reopen/read
exit 0
```

若 SQLite dependency 无法随当前 export 可靠打包，G3-01 不得 PASS。

---

## 9. Minimal Fixture Shape｜不是 Production Schema

允许类似以下 spike-only schema，名称可调整：

```text
g3_fixture_games
- game_id
- active_head_id
- schema_version / created_at

g3_fixture_timeline_nodes
- node_id
- game_id
- parent_node_id
- sequence
- kind

g3_fixture_state
- game_id
- key
- value

g3_fixture_save_points (optional for relationship proof)
- save_id
- game_id
- timeline_node_id
- display_name
```

这只是验证 relationship/transaction 的 fixture。

禁止从 fixture 推导并冻结完整 World/NPC/Inventory/Faction production schema。

---

## 10. Allowed / Prohibited Scope

### Allowed

- 最小 `src/persistence/` spike/support code；
- isolated G3-01 tests / helper scripts；
- 选定 SQLite binding 所需的最小、可追溯第三方 dependency（仅当真实 spike 需要）；
- dependency license/source/version provenance note；
- Windows export preset 的**必要最小 packaging 修复**；
- existing launch/test scripts 的小型 reusable extension；
- 删除 spike-only compatibility shim if superseded before final commit。

### Prohibited

- G3-02 production durable World Mutation Path；
- G3-03 Game Resume product implementation；
- G3-04 Save/Load/Restore UI/product flow；
- G3-05 arbitrary Timeline browser/branch UX；
- G3-06 full crash recovery system；
- G4 World Pack；
- G5 Character/NPC/Faction/World schema；
- ORM / generic repository framework；
- EventBus / DI / service locator；
- database server / cloud backend；
- switch to C#/.NET/external runtime without explicit architecture return；
- full event sourcing unless evidence proves simpler design impossible；
- destructive tests on any pre-existing/unknown player data。

---

## 11. Deliverables

1. Completed ownership matrix in Final Report.
2. Completed failure matrix in Final Report.
3. Evidence-backed storage decision: `SQLite ACCEPT` or `SQLite REJECT / BLOCKED`.
4. Reproducible real persistence spike committed to repo if ACCEPT.
5. Transaction / rollback / reopen / interrupted-write evidence.
6. Migration success/failure evidence.
7. Exported EXE persistence evidence.
8. Proposed minimal architecture for:
   - Game identity;
   - authoritative current World state boundary;
   - Timeline/head/node relationship;
   - Save Point reference relationship;
   - Conversation/Context restore association;
   - UI Preference separation.
9. Explicit list of what remains G3-02..G3-06.
10. No new long-term architecture document in this repo. Canonical architecture propagation happens after Independent Review into existing Vibe-Coding core/supporting docs.

---

## 12. Engineering Acceptance

### AC-01｜Ownership classification

No object above has two live authoritative owners. UI/Transcript/Context/cache are not durable fallbacks.

### AC-02｜Storage viability

Real current Foundation can open/use the chosen persistence route in editor/headless and Windows exported EXE.

### AC-03｜Atomic mutation

Multi-record fixture mutation commits all-or-nothing.

### AC-04｜Interrupted write

A pre-COMMIT process crash/termination leaves last committed state readable and unchanged on reopen.

### AC-05｜Stable identity

`game_id` / timeline node identity survives close/reopen.

### AC-06｜Timeline / Save semantics

Architecture demonstrates:

```text
Save Point → references Timeline Node
Timeline Node → durable history/recovery anchor
active head → can move
old future → can remain recoverable
```

without exposing arbitrary Turn rewind.

### AC-07｜Conversation/Context isolation direction

Architecture has a non-ambiguous way for Conversation and any future Agent Context material to be associated with/restored against the active game/timeline head; future data cannot be globally reused after old-head restore.

### AC-08｜Migration

Schema/version strategy and transactional migration failure behavior are demonstrated or strongly evidenced by real fixture.

### AC-09｜No schema overreach

No production NPC/Faction/Item/World Pack schema frozen prematurely.

### AC-10｜No framework overreach

No generic ORM/repository/service/event platform introduced.

### AC-11｜G2 regression

G2 Domain/Context/Provider/UI current tests still pass after any dependency/project changes.

### AC-12｜Safety

No destructive operation targets unknown user data; test cleanup is identity-bounded.

---

## 13. Architecture Decision Return

Final Report must contain one explicit recommendation:

```text
RECOMMENDATION: ACCEPT SQLITE FOR G3 V0.1
```

or

```text
RECOMMENDATION: REJECT / REOPEN PERSISTENCE CANDIDATE
```

If ACCEPT, state the exact binding/dependency/version/license/source and why it fits current Foundation.

If REJECT, do not quietly implement a different architecture; return evidence + 1–2 smallest alternatives with trade-offs for Product/Architecture review.

---

## 14. Validation

Use focused → full:

1. Fresh Git / dependency provenance check.
2. Godot headless/editor parse.
3. G3-01 basic open/reopen fixture.
4. transaction commit + rollback tests.
5. interrupted-write/crash helper test.
6. migration success + intentional failure test.
7. stable identity/reopen test.
8. Windows export + exported EXE DB open/write/reopen/read.
9. G2-05 Context tests.
10. G2-04 Domain tests.
11. G2-03 offline/GUI smoke only if project/dependency changes can affect runtime UI.
12. G2-02 Adapter smoke if project/plugin changes can affect networking/runtime startup.
13. `git diff --check`.
14. secret/Authorization hygiene.
15. third-party license/provenance check.
16. `git status --short` clean.

Real destructive crash tests must use exact process identity and isolated test DB.

---

## 15. Git / Freshness

- Start from latest `origin/main`; record start HEAD/status.
- Do not overwrite unknown dirty worktree.
- Before authoritative commit/push, fetch and compare Task Base → current origin/main.
- If origin advanced, audit changes and Decision Propagate before integrating.
- Prefer one focused implementation/spike commit; if third-party dependency provenance requires a separate mechanical commit, explain it.
- fast-forward push only; no force push.
- Final local HEAD == origin/main; clean status.

---

## 16. Stop / Return Conditions

Return `BLOCKED` instead of guessing if:

- no maintained SQLite route works with current Godot Standard Windows export;
- only viable route requires .NET/C#/external runtime/server and would reopen Foundation;
- license/provenance of required dependency is unsuitable/unclear;
- real crash/reopen semantics cannot be verified;
- current authoritative project docs conflict on Save/Timeline semantics;
- completing the task requires production G3-02+ work or premature G5 schema.

Do not ask Owner to perform routine engineering validation.

---

## 17. Final Report

```text
Result
READY FOR INDEPENDENT REVIEW | BLOCKED

Freshness
- start HEAD
- final HEAD/origin
- dirty/clean

Ownership Matrix
- Game
- World State
- Timeline/Node
- Save Point
- Conversation
- Agent Context
- UI Preference
- Source/Derived

Failure Matrix
- commit/rollback
- crash before/after commit
- reopen
- migration failure
- corrupt/missing path policy

Storage Recommendation
- ACCEPT SQLITE | REJECT/REOPEN
- binding/version/license/source
- Foundation compatibility

Real Spike Evidence
- basic reopen
- atomic transaction
- interrupted write
- stable identity
- migration
- exported EXE

Proposed G3 Architecture
- authoritative state
- timeline/head
- save reference
- restore/future recoverability
- conversation/context isolation

Scope Check
- no G3-02+ production feature
- no G4/G5 schema
- no ORM/EventBus/DI

Regression
- G2 relevant tests

Git
- commits
- push
- clean status
```
