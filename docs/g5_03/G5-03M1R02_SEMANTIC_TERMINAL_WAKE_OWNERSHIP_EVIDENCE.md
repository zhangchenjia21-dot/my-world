# G5-03M1R02 Semantic-Terminal Wake Ownership Simplification — Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Task: `docs/tasks/G5-03M1R02_SEMANTIC_TERMINAL_WAKE_OWNERSHIP_SIMPLIFICATION_TASK.md`
Review: `docs/g5_03/G5-03M1R01C02_INDEPENDENT_REVIEW.md`

- START_HEAD: `9f5928c`
- FINAL_HEAD: `d56ff09`（implementation）+ 本 evidence 提交

## 1. 改动范围（最小 wake-ownership 修正，无 Scheduler/AgencyCycle 重构）

| 文件 | 改动 |
| --- | --- |
| `src/应用壳.gd` | `_on_ordinary_turn_accepted_for_agency` 移除正常路径的即时 `consider_agency()`；只保留 `mark_dirty()`。正常 selector wake 只属于 `world_turn_runtime.finished → _on_world_turn_finished_for_scheduler → consider_agency()`。无 timer/polling/retry/新状态变量。 |
| `tests/g5_03/多角色行动代理循环测试.gd` | R01C02-D wiring proof 重写为 R02 wake-ownership proof（三个 ordinary turn：no-change / durable change / malformed semantic）；`_run` 入口与 fixture 注释同步。 |

未改动：`行动代理调度流程.gd`（dirty consumption/no-auto-retry 保持 C02）、`行动代理循环流程.gd`、`语义物化流程.gd`、persistence schema、Source、UI、Runtime Model Settings、G5-03M2/G5-04。

## 2. 真实 Application 排序证明（real `main.tscn` Shell harness，无 test-side mark_dirty/consider_agency）

Turn A ordinary accepted（真实 View send → durable accepted → 真实 `generation_completed` wiring）：

- `dirty=true` 且 selector request count == 0，同时 semantic stub request active（`R02 Turn A real generation_completed wiring marks dirty only` / `R02 semantic request active after Turn A accepted` / `R02 zero selector while semantic is active`）；
- semantic stub 完成（valid no-change）→ `finished → consider_agency` → selector request count == 1、dirty 消费为 false（`R02 semantic terminal wake starts exactly one selector` / `R02 wake-started selector consumes the dirty opportunity`）。

## 3. Post-semantic snapshot 证明

Turn B semantic 返回 durable change（`江防哨所已增设。`）：

- materialization commit 前进 world head（`R02 Turn B semantic materialization commits durable current world change`）；
- selector 只在 commit 后启动（`R02 Turn B selector starts only after post-semantic commit`）；
- selector request 含已提交的 current consequence（`R02 selector request includes committed current consequence`）；
- selector snapshot `cycle_base_head_id` == post-semantic head（`R02 selector snapshot anchors post-semantic head`）。

## 4. Semantic terminal fail-soft wake 证明

- Turn A valid no-change terminal 释放 scheduler 一次（见 §2）；
- Turn C malformed semantic terminal 仍释放 scheduler 恰好一次，dirty 消费、无 retry loop，Narrative 保持 accepted（`R02 malformed semantic terminal still releases scheduler exactly once` / `R02 malformed-terminal wake consumes dirty; no retry loop` / `R02 malformed semantic leaves Narrative accepted`）。

## 5. C02 保留

Opening 不 dirty（`R02 Opening completion does not dirty Agency through real Application wiring`）；既有 C02 断言全部保留并通过：selector 启动即消费机会、terminal 后无 selector A2/no auto-retry、later Turn B fresh opportunity（R01C02-A/B/C 组全绿）。

## 6. 自动化结果（headless，真实 Provider 调用 = 0）

| 套件 | 结果 |
| --- | --- |
| G5-03 focused `tests/g5_03/多角色行动代理循环测试.gd` | **135 PASS / 0 FAIL** |
| G5-01 世界回合语义物化 | 22 PASS / 0 FAIL |
| G5-01 世界回合时间线恢复（fresh root `build/g5_01_r02_regress`） | 0 FAIL |
| G4-01 应用会话生命周期（task-owned db） | 0 FAIL |
| G4-07B 可玩界面整合（fresh root `build/g4_07b_r02_regress`） | 0 FAIL |
| G4-08B 公开D20界面整合（fresh root `build/g4_08b_r02_regress`） | 0 FAIL |

未重跑无关 G2/G3/G5-02 全套（无具体失败理由）。`git diff --check` 干净。

## 7. Provider

真实 Provider 调用 = 0。Parent G5-03 real Provider proof 保持 pending。
