# G5-03M1R01C02 — Dirty Opportunity Consumption + Lifecycle Proof Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Date: 2026-09-04
Correction packet: `docs/tasks/G5-03M1R01C02_DIRTY_OPPORTUNITY_CONSUMPTION_CORRECTION_TASK.md`
Parent IR: `docs/g5_03/G5-03M1R01C01_INDEPENDENT_REVIEW.md`
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

> 本修正只关闭 dirty opportunity lifecycle 缺陷。**保留 v0.3 架构**；不重新耦合 semantic/Agency；不开始 G5-03M2/G5-04。**未执行任何真实 Provider 调用**。

---

## 1. 交付标识

- START_HEAD：`c08358de7db619916e450b6ed5020b85cae34e3a`（G5-03M1R01C01 已评审实现）
- 实现/证据 HEAD：`2c24381`（fix(g5_03): consume dirty opportunity at selector start, no terminal auto-retry）
- 证据文档：本文件

## 2. 修正内容（dirty opportunity lifecycle）

### 修正 A — selector 真正启动时消费 dirty opportunity

- `src/世界回合/L2_流程层/行动代理调度流程.gd::_start_selector()` 在 empty-entries guard 之后立即 `dirty = false`：一个 accepted-turn dirty opportunity 在 selector 真正启动时被消费；
- malformed / provider failure / no-actors / hold / failure / normal cycle completion 之后 `dirty` 保持 `false`，同一 opportunity 不再可用。

### 修正 B — terminal 后不自动 retry 同一 opportunity

- `_on_agency_cycle_finished()` 移除了尾部的 `if dirty and not selector_active: consider_agency()`：cycle terminal cleanup 只 detach/free completed cycle，不再对同一机会重新 `consider_agency()`；
- 只有 later newly durable accepted ordinary player turn 重新 `mark_dirty()` 后，才允许 fresh dirty → selector B。

## 3. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/世界回合/L2_流程层/行动代理调度流程.gd` | `_start_selector()` 消费 dirty（`dirty = false`）；`_on_agency_cycle_finished()` 移除 terminal 后的自动 `consider_agency()`。production 改动仅 2 处（+2/−3 行）。 |
| `tests/g5_03/多角色行动代理循环测试.gd` | 新增 R01C02-A/B/C/D 四组断言；强化 R01C01-B/D 的 fresh-selector 证明；R01C02-D 用真实 Application seam 替换直接 `mark_dirty()` 的伪 wiring 证明。 |

未改动：`src/应用壳.gd`（C01 wiring 保持不变）、`src/domain/会话.gd`、`src/ui/**`、persistence schema/migrations、Source schema/generation、Runtime Model Settings、Public d20、G5-03M2/G5-04/G6/G7。

## 4. 自动化矩阵结果（headless）

`tests/g5_03/多角色行动代理循环测试.gd`：**116 PASS / 0 FAIL**。

| C02 packet 断言 | 结果 |
| --- | --- |
| A completed cycle 消费 opportunity | PASS（selector request count 恒为 1；`dirty=false`；再次 `consider_agency()` → `not_ready`） |
| B malformed/provider-failure/no-actors 消费 opportunity | PASS（三种 terminal class 均 `dirty=false` + `selector_active=false` + adapter 清理；不 auto-retry；later accepted turn → fresh selector + live adapter） |
| C sequential A → B | PASS（Cycle A terminal 后零 selector request 增长直到 Turn B acceptance；Turn B production acceptance 后 fresh dirty → selector B 用 B snapshot） |
| D production wiring | PASS（真实 main.tscn Shell：Continue → 自动第一幕 → ordinary player turn；`generation_completed → _on_ordinary_turn_accepted_for_agency → mark_dirty → consider_agency` 真实发生——ordinary accepted turn 未经任何测试侧 `mark_dirty()` 即启动 exactly one selector 并消费 dirty；Opening-only GM completion 不 dirty、零 selector request） |
| E 保留 C01/R01 既有行为 | PASS（A–I + C01-A..F + R01C01-A/C/D 全绿：current-hash filtering、coalescing、foreground/Restore、多 NPC 并发、actor 知识隔离、sibling head、replay no-duplicate） |

### Production wiring proof 说明（R01C02-D）

测试加载真实 `src/main.tscn` Shell，Provider 边界全部使用 production 自带 test seam（`test_opening_adapter_override` / `test_world_turn_adapter_override` / `agency_scheduler.test_selector_adapter_override` / View adapter 换桩），不改任何 production 架构：

1. task-owned created-schema Game 经 production Runtime durable 提交 setup；
2. Continue → `_activate_game_surface()` → `_connect_save_runtime()`（真实连接 `generation_completed → _on_ordinary_turn_accepted_for_agency`）+ `_prepare_world_turn_after_activation()`（真实挂载 Agency Scheduler）；
3. Opening 自动开始并接受：断言 `dirty == false` 且 selector 零 request（Opening-only GM turn 不 dirty）；
4. 真实 View send → durable accepted ordinary player turn：断言 selector stub 恰好 1 个 request 且 `dirty == false`——selector 只在 dirty 时启动，这证明真实 signal wiring 调用了 `mark_dirty()` 且启动即消费。

### Harness 修正说明（非 production 改动）

- sequential/no-auto-retry 测试中，第一个 selector stub 完成/terminal 后会被 Scheduler 的 `_cleanup_selector_adapter()` 正确释放；新 Turn B 机会现在显式赋予 fresh `StubAdapter.new()`，不再复用已释放节点；
- selector request count 一律在 `simulate_completed()` 之前保存，不再读取 terminal 后已释放的 adapter；
- `_test_selection_bound()` 使用 5 个 distinct eligible NPC IDs 并配置 `test_actor_adapter_factory`，证明只保留前 4 个且保持顺序。

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G5-03 多角色行动代理循环（R01C02 强化后） | 116 PASS / 0 FAIL |
| G5-02 已知角色知识溯源 | 40 PASS / 0 FAIL |
| G5-01 世界回合语义物化 | 0 FAIL |
| G5-01 世界回合时间线恢复（fresh root） | 0 FAIL |
| G2-04 会话域离线 | 0 FAIL |
| G2-05 上下文组装离线 | 0 FAIL |
| G3-03 会话恢复与候选 | 0 FAIL |
| G4-01 应用会话生命周期（Application integration） | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G4-07B 可玩界面整合（fresh root） | 61 PASS / 0 FAIL |
| G4-08B 公开D20界面整合（fresh root） | 127 PASS / 0 FAIL |

`git diff --check` 干净。

## 6. 真实 Provider 调用声明

**本次修正未执行任何真实 Provider 调用。** 父任务 G5-03M1R01 的 real proof 保持 `PENDING / EXTERNAL PROVIDER UNAVAILABLE`；本修正只改 production dirty-consumption/lifecycle，不需要真实 Provider。

## 7. 结论

G5-03M1R01C02 修正关闭了 dirty opportunity lifecycle 缺陷：selector 真正启动时消费 dirty opportunity；malformed/provider-failure/no-actors/hold/failure/normal completion 后不对同一 opportunity 自动 retry；只有 later newly durable accepted ordinary player turn 才能重新 mark_dirty；production dirty wiring 经真实 Application `generation_completed → _on_ordinary_turn_accepted_for_agency` seam 证明，Opening 不 dirty。**返回上限：READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**。GPT 拥有 Independent Review。
