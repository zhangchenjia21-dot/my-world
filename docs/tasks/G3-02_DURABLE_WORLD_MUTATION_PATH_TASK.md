---
title: my world｜G3-02 Durable World Mutation Path Task Packet
status: current-task-packet
task_id: G3-02
type: implementation
owner: Codex
created: 2026-08-26
updated: 2026-08-26
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 1fc1cba76ade63a05e4b7ba9009264696ad45b1a
agent_rules_base: df0aafa9a4191f07222d4933256c2afdc1593752
local_project: D:\AI\Projects\my-world
---

# TASK｜G3-02｜Durable World Mutation Path

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

## 1. Outcome

把 G3-01 已证明的 SQLite / transaction 能力变成第一条**正式 production durable mutation kernel**：一个 game-local World materialization、对应的新 Timeline Node 与 Game active head 必须在同一 SQLite transaction 中原子提交，并且对 stale writer 与 crash-after-COMMIT replay 有明确、可测试的处理。

完成后应存在一条不依赖 UI / Provider / SceneTree 的正式路径：

```text
current Game + expected head
+ stable mutation identity
+ next game-local World materialization
→ one SQLite transaction
→ new Timeline Node
→ current World materialization
→ Game.active_head
→ COMMIT
→ publish committed result
```

本任务最高状态：`READY FOR INDEPENDENT REVIEW`。不得开始 G3-03。

---

## 2. Why Now

G3-01 已通过 Independent Review，并冻结：

- SQLite + `2shady4u/godot-sqlite v4.9` = G3 v0.1 accepted storage route；
- transaction / rollback / pre-COMMIT crash / migration / export packaging 已有真实 Windows evidence；
- Save Point != Timeline Node；
- storage responsibility != business semantic ownership。

但当前仓库只有 `g3_fixture_*` spike，没有 production Game/World/Timeline persistence path。G3-03 Reopen/Resume 不能建立在 fixture 或 UI dump 上，因此必须先建立最小 production kernel。

---

## 3. Authority / Source Manifest

冲突时：

1. 用户当前明确指令。
2. `Vibe-Coding/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`。
6. `Vibe-Coding/my world/architecture/persistence/时间线存档与可逆性设计.md`。
7. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` / `MY_WORLD_CURRENT_STATUS.md`。
8. 本仓库 `AGENTS.md`、current code/tests/HEAD。
9. Current `agent-task-packet` v1.2 / `lifecycle-dev-process` v2.2 只作为执行方法。

Not authoritative:

- `tests/g3_01/g3_fixture_*` schema 作为 production schema；
- DSH / The World / Markdown DB implementation；
- historical chat / old task status；
- G5 future NPC/Faction/Item schema guesses。

---

## 4. Read First

开始先 fetch / fast-forward 最新 `origin/main`，记录 start HEAD 与 `git status --short`，确认包含本 Task Packet。

初始工作集：

```text
AGENTS.md
本 Task Packet
addons/godot-sqlite/THIRD_PARTY.md
tests/g3_01/持久化夹具.gd
tests/g3_01/持久化离线测试.gd
src/domain/会话.gd
src/context/上下文组装器.gd
```

然后按 Source Manifest 读取当前 Persistence supporting design。只有证据不足时扩大读取，Final Report 说明原因。

---

## 5. Pre-implementation State / Failure Matrix

编码前先在 working notes 中明确，Final Report 给简表；不要让 schema 偶然决定语义。

至少覆盖：

```text
create initial Game/root head
normal mutation commit
same mutation replay after successful commit
same mutation replay after simulated caller lost ACK
same mutation_id with conflicting intent
new mutation with stale expected_head
SQL failure at late transaction step
reopen after committed mutations
invalid/non-serializable World materialization input
```

逐项回答：

- active head before / after；
- World materialization before / after；
- Timeline Node count；
- caller receives success / replay-success / conflict / stale-head / storage-failure；
- transaction 是否有任何 partial durable visibility。

---

## 6. Decision Digest / Invariants

### DEC-01｜Production persistence kernel，not fixture promotion

新增最小 production code，推荐在 `src/persistence/`；plain GDScript / RefCounted 或等价轻量边界，不依赖 Control、Provider、SceneTree 生命周期。

不得把 `g3_fixture_*` 表名/代码直接改名后宣布 production。可以继承被 spike 证明的 transaction 技术，但 production schema/API 必须按本任务最小需求重新设计。

### DEC-02｜Business owner 与 storage owner 分离

Persistence 接受 Game/World/Timeline owner 提供的 identity/material，负责 durable representation 和 transaction；它不判断 Narrative 是否“合理”，也不拥有未来 NPC/Faction 语义。

当前尚无完整 World Domain，因此 G3-02 可把 `world_state` 当作**opaque game-local materialization document**；Persistence 只验证可持久化结构和 identity/integrity，不建立 lore whitelist / gameplay validator。

### DEC-03｜Minimal production durable objects

生产 schema/API 至少需要表达：

```text
schema version
Game stable identity
Game active_head_id
current authoritative World materialization
Timeline Node stable identity / parent / sequence
stable mutation identity
immutable historical recovery material sufficient for later Restore
```

不建立 Save Point table/UI（G3-04），不建立 Conversation persistence（G3-03），不建立 NPC/Faction/Item tables（G5）。

### DEC-04｜World materialization v0.1 = opaque structured document

为避免 G3 提前冻结 G5 schema，第一版允许把当前 game-local World materialization 持久化为一个 JSON-serializable `Dictionary` / equivalent opaque document。

要求：

- Persistence 不解析其中 NPC/Faction/Item 业务意义；
- document 必须能 round-trip exact semantic content；
- schema/version for storage envelope 与 future World semantic schema 不要混为一个概念；
- 不把 Markdown / Transcript 作为 authoritative document。

这是 G3 v0.1 最小 materialization seam，后续可在真实 G5/G7 evidence 下 normalize/migrate。

### DEC-05｜Historical anchor must be restorable, not second live truth

G3-04 未来要能 Restore 到旧 Timeline Node，因此 G3-02 创建的 durable node 必须拥有足以恢复该节点 World state 的 immutable recovery anchor。

第一代允许每个 committed node 保存完整 `world_snapshot_json`，因为它最简单、可验证且不预设 mutation-delta schema；但必须明确：

```text
current World materialization
= only live authoritative current state

node snapshot
= immutable historical recovery anchor
!= second writable live state
```

如果执行 Agent提出更简单且同等可恢复的方案，可以采用，但不得引入 full event sourcing/replay platform。

### DEC-06｜Atomic mutation boundary

一次 successful mutation 必须在**同一 SQLite transaction**中至少完成：

```text
insert durable Timeline Node / mutation record
write next current World materialization
update Game.active_head_id
```

若采用 node snapshot，也必须与同一 transaction 对齐。

只有 COMMIT 成功后才能返回/publish committed success。

### DEC-07｜Expected head / stale writer protection

每次 mutation 必须带 `expected_head_id` 或等价前置条件。

若 DB current head != expected head：

```text
reject stale_head
→ no World change
→ no Timeline Node
→ no head movement
```

不要自动 rebase/merge/stitch 到最新 head。

### DEC-08｜Stable mutation identity + replay-safe commit

每个 durable intent 必须有稳定 `mutation_id` / equivalent，数据库层对同一 Game 内保持唯一。

目标是解决：

```text
COMMIT succeeded
→ process/caller dies before receiving ACK
→ caller later retries same durable intent
```

正确结果：

```text
same mutation identity
→ return/recover the previously committed result
→ do NOT create second Timeline Node
→ do NOT apply effect twice
```

至少区分：

- exact replay：同 game + same mutation identity + same expected parent + same intended materialization → replay-success / existing committed result；
- conflicting reuse：same mutation identity 但 intent/material differs → explicit conflict，no write。

不要依赖“调用方应该永远不会重复”作为完整性策略。

### DEC-09｜Mutation fingerprint can be minimal, but must detect conflict

为了区分 exact replay 与 mutation-id reuse，允许存储一个 deterministic intent fingerprint。

不要引入通用 hashing framework。可采用：

- stable/canonical serialization + SHA-256；或
- 等价最小 deterministic representation。

如果 JSON Dictionary 序列化顺序不稳定，必须先 canonicalize recursive keys，而不是把 insertion order 当 identity。

Fingerprint 只用于 durable intent identity/integrity，不用于 Narrative judging。

### DEC-10｜Late-step rollback must be demonstrated on production path

除了 G3-01 generic transaction proof，G3-02 必须证明 production mutation path 在**至少一个后段 SQL failure**下整体 rollback。

推荐 test：在 isolated test DB 安装 test-only SQLite trigger，使 `Game.active_head` 最后一步 UPDATE abort；随后调用正常 production mutation API，并证明：

```text
current World unchanged
new Timeline Node absent
active head unchanged
mutation not reported committed
```

不要为了 failure injection 在 production code 加宽泛 debug backdoor。

### DEC-11｜Post-COMMIT lost-ACK replay evidence

用隔离 helper process 调用 production mutation API：

```text
commit returns success
→ helper writes deterministic post-COMMIT marker
→ helper waits before any external ACK
→ harness verifies exact executable/PID
→ terminate helper
→ reopen in new process
→ retry same mutation_id
→ same committed node returned / no duplicate effect
```

这不是证明 SQLite ACID；是证明我们的 mutation identity + replay semantics。

### DEC-12｜Schema/version boundary remains explicit

Production DB schema 使用单一明确 schema version source。G3-02 只需要建立 initial production version；不要顺手建设 ORM/migration framework。

SQLite WAL / synchronous / foreign-key policy可以复用 G3-01 已证明的基础，但要在 production owner 中集中、可测试。

### DEC-13｜Explicit database path for G3-02

G3-02 production kernel 接收明确 DB path / equivalent composition input；测试使用隔离目录。

**不要在本任务自动扫描 `user://`、选择最近 Game、创建 resume UX 或猜测玩家数据库。** 正式 Game discovery/reopen 属于 G3-03。

### INV-PERSIST-01｜No partial durable truth

任何 failure / stale-head / conflict / replay 处理都不能留下 half-new/half-old state。

### INV-PRODUCT-01｜Durability must not become Narrative censorship

Persistence 保护 identity / transaction / recovery；不因开放式模型 authoring 增加 Narrative whitelist、Regex、minimum content rules 或“世界事实必须预先批准”的平台。

### INV-SCOPE-01｜G3-03+ / G5 not authorized

本任务不做 Resume、Save/Load UI、Restore product flow、Conversation persistence、World Pack、NPC/Faction semantics、Timeline browser、arbitrary rewind。

---

## 7. Suggested Minimal Production Shape

这是语义参考，不要求 exact names：

```text
schema_meta
- schema_version

games
- game_id
- active_head_id
- created_at / updated_at

world_state
- game_id
- head_id
- state_json

timeline_nodes
- node_id
- game_id
- parent_node_id
- sequence
- mutation_id
- intent_fingerprint
- world_snapshot_json
- created_at
```

允许把 mutation metadata 拆为单独 table，如果更清楚；不要因此创建 repository/service forests。

ID generation 不属于 SQLite storage 的业务语义。G3-02 API可以接受由上层提供的 deterministic test IDs / future Domain IDs，并在 DB enforce uniqueness；不要为了一个 ID helper 建通用 identity framework。

---

## 8. Required Deliverables

1. 最小 production persistence owner/kernel under `src/persistence/`。
2. Production schema v1 + explicit schema version。
3. Initial Game/root-head creation path（无 UI），使用明确 supplied identities/materialization。
4. Atomic durable mutation API/path。
5. Expected-head stale-write rejection。
6. Stable mutation identity / exact replay / conflicting reuse semantics。
7. Immutable historical recovery anchor sufficient for later Restore。
8. Focused deterministic tests using isolated DBs。
9. Exact-PID post-COMMIT lost-ACK/replay helper test。
10. Existing G3-01 SQLite provenance/binaries reused; no second DB dependency。
11. G2 regression + Windows export/run smoke。

---

## 9. Engineering Acceptance

### AC-01｜Production owner separation

Static review proves production persistence code lives outside UI/Provider/Conversation and does not promote G3 fixture schema to authority.

### AC-02｜Create initial Game

Given explicit `game_id`, root node identity and initial World materialization:

```text
create
→ current head == root
→ current World exact
→ root recovery anchor exact
→ reopen exact
```

Duplicate game identity must fail clearly or return an explicit already-exists result; never overwrite silently.

### AC-03｜Normal durable mutation

Mutation M1 from H0 to H1 atomically commits World + node + active head. Reopen returns H1 and exact World.

### AC-04｜Stale expected head

After H1 committed, new M2 declaring expected H0 is rejected with no new node/state/head changes.

### AC-05｜Exact replay

Re-invoking already committed M1 with same mutation identity + intent returns existing committed result; node count/effect count do not increase.

### AC-06｜Conflicting mutation-id reuse

Same mutation identity with changed parent/materialization/fingerprint returns explicit conflict and writes nothing.

### AC-07｜Late transaction failure

Test-only DB trigger or equivalent late SQL failure proves production mutation transaction fully rolls back.

### AC-08｜Lost-ACK process replay

Exact-PID helper terminates after COMMIT marker; new process reopens and repeats same mutation. Result resolves to the same node/effect with no duplicate.

### AC-09｜Recovery anchor is immutable history

After H0 → H1 → H2, historical snapshot H0/H1 remains exact while current materialization == H2. No API silently mutates old node snapshots.

### AC-10｜No G5 schema freeze

Production World materialization remains opaque structured data; no character/faction/item/quest business columns/platform appear.

### AC-11｜Regression / packaging

- Godot headless parse PASS；
- G3-02 focused suite PASS；
- G3-01 persistence suite PASS；
- G2-05 / G2-04 / G2-03 offline regressions PASS；
- Windows Desktop export PASS；
- `run-game.ps1` / normal launcher smoke PASS；
- no secret/Authorization leakage；
- `git diff --check` clean。

Real DeepSeek call is not required unless Provider/UI code is unexpectedly touched; if touched, explain and run relevant real regression.

### AC-12｜Scope

No G3-03+, G4/G5/G7 implementation; no ORM/DI/EventBus/full event sourcing; no Save UI.

---

## 10. Allowed / Prohibited Scope

Allowed:

- `src/persistence/` production kernel；
- focused `tests/g3_02/` scripts/helpers；
- minimal shared ID/fingerprint utility only if directly necessary；
- necessary project/export/test harness updates；
- direct G3-01 test adaptation if production code supersedes a duplicated helper, provided spike evidence remains reproducible。

Prohibited:

- Provider/Context redesign；
- Conversation persistence/resume；
- Save/Load/Restore UI；
- Game discovery/recent-save UX；
- G5 entity schemas；
- generic repository/ORM/service framework；
- external DB/server/.NET switch；
- player real database destructive tests。

---

## 11. Validation Order

按 focused → full：

1. headless parse / GDExtension load；
2. G3-02 deterministic production-path tests；
3. late-failure atomicity test；
4. post-COMMIT exact-PID lost-ACK/replay test；
5. G3-01 full real persistence harness；
6. G2 offline regressions；
7. Windows Desktop export + launcher smoke；
8. `git diff --check` / dependency/secret hygiene / clean status。

所有 destructive tests 只作用于经过 absolute-path/identity 验证的 task-owned DB。

---

## 12. Git / Freshness

- 开始记录 start HEAD/status；
- 不覆盖 unknown dirty worktree；
- authoritative write/push 前 fetch 并审计 task base → current origin/main；
- fast-forward push only；
- no force push；
- final local HEAD == origin/main、working tree clean。

---

## 13. Stop / Return Conditions

返回 `BLOCKED` 而不是绕过，如果：

- replay-safe semantics 只能通过新增未经批准的 G3-03/G5 owner 才能成立；
- current SQLite binding 出现新的 deterministic integrity/package blocker；
- production schema 必须预先冻结 NPC/Faction/Item business model 才能继续；
- 发现 canonical persistence decision 与 current sources 冲突；
- 需要接触未知 player DB 才能证明行为。

---

## 14. Final Report

```text
Result
READY FOR INDEPENDENT REVIEW | BLOCKED

Freshness
- start HEAD/status
- final HEAD/origin

Production Shape
- files/API
- production schema v1
- Game/World/Timeline ownership separation

State / Failure Matrix
- normal
- stale head
- exact replay
- conflict reuse
- late rollback
- lost-ACK replay

Durable Evidence
- create/reopen
- M1/M2 head/world/node values
- historical recovery anchors

Scope Check
- no G3-03+/G5
- no framework expansion

Validation
- focused
- G3-01 regression
- G2 regression
- export/launcher

Git
- implementation commit
- push
- clean status
```
