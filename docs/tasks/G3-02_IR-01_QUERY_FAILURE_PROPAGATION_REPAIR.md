---
title: my world｜G3-02 IR-01 Query Failure Propagation Repair
status: current-repair-packet
task_id: G3-02-IR-01
type: focused-repair
owner: Codex
created: 2026-08-27
repository: zhangchenjia21-dot/my-world
branch: main
repair_base: bda2a8877297c51365cd6581536875b68c81cb85
---

# TASK｜G3-02 IR-01｜Query Failure Propagation Repair

## 1. Outcome

修复 G3-02 production Persistence kernel 的读取失败语义：**SQL/SQLite query failure 必须与“查询成功但没有记录”严格区分**，并通过 L3 公开 API 稳定返回 `storage_failure`，不得被折叠成 `not_found`、空结果或 GDScript runtime error。

完成后最高状态：`READY FOR INDEPENDENT REVIEW`。不得开始 G3-03。

## 2. Review Finding

当前 `src/persistence/L1_器件层/SQLite数据库连接器.gd::query_rows()`：

```text
query success + 0 rows -> []
query failure          -> []
```

两种结果不可区分。

因此当前 L2 至少存在这些风险：

- `get_current_game()`：SELECT failure 可能被报告为 `not_found`；
- `get_timeline_node()`：SELECT failure 可能被报告为 `not_found`；
- `commit_world_mutation()` 的 replay/game/head preflight SELECT 若失败，可能被误解为空记录并走错误业务分支；
- `timeline_node_count()` 在 query failure 返回空 Array 后直接访问 `rows[0]`，可能产生 runtime error，而不是稳定 Persistence result。

这违反现有 L0 合同：Persistence failure 必须可观察，不得用空结果隐藏。

## 3. Authority / Read First

先 fetch / fast-forward 最新 `origin/main`，记录 HEAD/status，并读取：

```text
AGENTS.md
本 repair packet
src/persistence/L0_公理层/持久化操作结果.gd
src/persistence/L1_器件层/SQLite数据库连接器.gd
src/persistence/L2_流程层/世界持久化流程.gd
src/persistence/L3_外交层/世界持久化公开接口.gd
tests/g3_02/世界持久化流程测试.gd
```

G3-02 原 Task Packet 与 current Vibe-Coding Persistence architecture 继续有效；本 packet 只 supersede 其中“当前实现已可进入 G3-03 review closeout”的假设，不改变原架构。

## 4. Required Semantics

### IR-01-DEC-01｜Query outcome must be explicit

L1 read mechanism 必须能区分：

```text
query executed successfully, rows may be empty
!=
query execution failed
```

允许最小实现之一：

- `query_rows()` 返回 `{ok, rows, error}`；或
- 提供等价明确 success/failure seam；
- 其它同等简单方案。

不要引入 Result monad/framework/ORM/repository forest。

### IR-01-DEC-02｜L2 interprets absence only after successful query

所有 production SELECT 调用必须先确认 query success，再解释 row count。

只有：

```text
SELECT succeeded
+ expected entity rows == 0
```

才允许返回 `not_found` / no-prior-replay 等业务结果。

SQL failure 必须返回 `storage_failure`，并在 transaction 内时 rollback。

### IR-01-DEC-03｜No public read crash

`get_current_game()`、`get_timeline_node()`、`timeline_node_count()` 以及 mutation preflight read failure 不得因为 empty array/indexing/type assumption 产生 runtime error。

### IR-01-DEC-04｜Do not weaken existing semantics

必须保持：

- normal commit；
- stale-head；
- exact replay；
- mutation conflict；
- late-step rollback；
- lost-ACK replay；
- immutable historical anchors；
- opaque World document semantics；
- G3-01 SQLite/provenance route。

不得改变 mutation fingerprint、schema v1、Save/Resume scope，除非修复本 finding 绝对必要；若认为必须改变，停止并返回理由。

## 5. Deterministic Repair Tests

新增 focused failure injection，必须走 **production L3 API**，使用隔离 `build/g3_02_*` DB，不碰玩家数据。

至少证明：

1. `get_current_game()` 的底层 SELECT 被确定性破坏时：`storage_failure`，不是 `not_found`，process 不崩；
2. `get_timeline_node()` 同样返回 `storage_failure`；
3. `timeline_node_count()` 同样返回 `storage_failure`，无 out-of-bounds/runtime error；
4. `commit_world_mutation()` 至少一个 preflight SELECT failure：返回 `storage_failure`、transaction rollback、World/head/node 均无 partial change；
5. 一个真实成功但 0-row 的查询路径仍正确返回 `not_found`，证明没有把正常 absence 全部升级成 storage failure。

Failure injection 优先通过 test-owned SQLite schema damage/rename/drop 或等价外部 test manipulation；不要为了测试在 production code 加通用 debug backdoor。

## 6. Scope

Allowed：

- 最小修改 `src/persistence/L1_器件层/SQLite数据库连接器.gd`；
- 必要修改 `src/persistence/L2_流程层/世界持久化流程.gd`；
- focused G3-02 tests/harness；
- 必要的小型 L0/L3 contract comment alignment。

Prohibited：

- G3-03 Resume / Conversation persistence；
- Save/Load/Restore UI；
- schema expansion for NPC/Faction/Item；
- DB dependency replacement；
- ORM/DI/EventBus/repository framework；
- Narrative/World-content validators。

## 7. Validation

按 focused → full：

1. Godot parse/headless。
2. 新 IR-01 deterministic query-failure tests。
3. G3-02 production focused suite。
4. G3-02 exact-PID lost-ACK replay。
5. G3-01 real persistence regression。
6. G2-05 / G2-04 / G2-03 relevant regressions。
7. Windows Desktop export + `run-game.ps1` exact executable/PID smoke。
8. `git diff --check`、secret/dependency hygiene。

## 8. Git / Return

Pre-push freshness revalidation；fast-forward only；不得 force push。

Final Report 至少给出：

- exact change；
- query success/empty/failure 新 contract；
- 5 条 deterministic evidence；
- G3-02/G3-01/G2 regression；
- commit SHA / push / clean status。

返回：`READY FOR INDEPENDENT REVIEW` 或 `BLOCKED`。
