# G5-03M1R01C01 — Scheduler Production Lifecycle + Current Snapshot Correction Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Date: 2026-09-03
Correction packet: `docs/tasks/G5-03M1R01C01_SCHEDULER_PRODUCTION_LIFECYCLE_CURRENT_SNAPSHOT_CORRECTION_TASK.md`
Parent IR: `docs/g5_03/G5-03M1R01_INDEPENDENT_REVIEW.md`
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

> 本修正只关闭 GPT IR 指出的 production Scheduler lifecycle/current-snapshot 缺陷。**保留 v0.3 架构**；不重新把 Agency Selection 塞回 semantic request；不开始 G5-03M2/G5-04。**未执行任何真实 Provider 调用**。

---

## 1. 交付标识

- START_HEAD：`46f8bd34875a55de7c26a1b9ebc5f11312a9f582`（G5-03M1R01 已评审实现）
- 实现/证据 HEAD：见 FINAL HEAD（push 后回填）
- 证据文档：本文件

## 2. 修正内容（对应 IR 三个 findings + lifecycle hygiene）

### 修正 A — production dirty wiring

- `src/应用壳.gd::_connect_save_runtime()` 新增 `conversation.generation_completed.connect(_on_ordinary_turn_accepted_for_agency)`；
- `_on_ordinary_turn_accepted_for_agency()`：ordinary durable accepted player turn（非 Opening-only GM generation）自动 `agency_scheduler.mark_dirty()` + `consider_agency()`；不阻塞 Narrative；Opening-only GM turn（empty player_text）不标记。

### 修正 B — cycle terminal cleanup + re-arm

- `src/世界回合/L2_流程层/行动代理调度流程.gd::_on_selector_completed()` 启动 cycle 时连接 `cycle_finished`；
- `_on_agency_cycle_finished()`：terminal 后安全 detach/free 并 `agency_cycle_runtime = null`；已 committed durable actions 保持；late callback 不影响新 cycle；后续新 dirty 机会可再次启动 cycle（不自动 retry 同一机会）。

### 修正 C — selector 只读 current accepted-hash-matching semantic consequences

- `src/世界回合/L2_流程层/行动代理调度流程.gd::_selector_request()` 的 `Recent World Changes` 现在用 `_current_accepted_hashes()` 过滤：只含 `source_turn_index` 在当前 accepted Conversation 且 `source_gm_sha256` 匹配当前 accepted GM hash 的 durable 记录；
- 复用既有 current-hash 投影原则，不发明平行 truth 定义。

### 修正 D — lifecycle hygiene

- `_on_selector_completed()` / `_on_selector_cancelled()` / `_on_selector_failed()` 现在调用 `_cleanup_selector_adapter()` 清理 adapter；
- selector completion/failure/cancellation 不 strand Scheduler 于 active 状态；
- failure/no-actors/hold terminal 后不自动 retry 同一机会；后续新 accepted turn 可再次 mark_dirty。

## 3. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/应用壳.gd` | 新增 `_on_ordinary_turn_accepted_for_agency` 连接 `generation_completed`；ordinary durable accepted turn 自动 mark dirty + consider_agency。 |
| `src/世界回合/L2_流程层/行动代理调度流程.gd` | `_on_selector_completed` 启动 cycle 时连接 `cycle_finished`；新增 `_on_agency_cycle_finished`（terminal 后 detach/free + re-arm）；`_selector_request` 加 current-hash 过滤；新增 `_cleanup_selector_adapter`；selector terminal 后清理 adapter。 |
| `tests/g5_03/多角色行动代理循环测试.gd` | 新增 R01C01-A/B/C/D 四组断言（共 9 项新断言）；适配新架构的 A/I 测试。 |

未改动：`src/domain/会话.gd`、`src/ui/**`、persistence schema/migrations、Source schema/generation、Runtime Model Settings、Public d20、G5-03M2/G5-04/G6/G7。

## 4. 自动化矩阵结果（headless）

`tests/g5_03/多角色行动代理循环测试.gd`：**65 PASS / 0 FAIL**（R01 56 + R01C01 新增 9）。

| C01 packet 断言 | 结果 |
| --- | --- |
| A production dirty wiring | PASS（ordinary accepted turn 自动 mark dirty + selector 启动） |
| B sequential Cycle A→Cycle B re-arm | PASS（Cycle A terminal 清理 → Cycle B 启动） |
| C stale semantic consequence filtering | PASS（selector 含 current 不含 stale） |
| D no-auto-retry | PASS（failure/no-actors 后不 strand、不 auto-retry） |
| E 保留 R01 既有行为 | PASS（A–I + C01-A/B/C/D/E/F 全绿） |

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G5-03 多角色行动代理循环（R01C01 强化后） | 65 PASS / 0 FAIL |
| G5-02 已知角色知识溯源（含 C01 roster/recency） | 40 PASS / 0 FAIL |
| G5-01 世界回合语义物化 | 0 FAIL |
| G5-01 世界回合时间线恢复（fresh root） | 0 FAIL |
| G2-05 上下文组装离线 | 0 FAIL |
| G2-04 会话域离线 | 0 FAIL |
| G3-03 会话恢复与候选 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08B 公开D20界面整合（fresh root） | 127 PASS / 0 FAIL |

`git diff --check` 干净。

## 6. 真实 Provider 调用声明

**本次修正未执行任何真实 Provider 调用。** 父任务 G5-03M1R01 的 real proof 保持 `PENDING / EXTERNAL PROVIDER UNAVAILABLE`；本修正只改 production wiring/lifecycle，不需要真实 Provider。

## 7. 结论

G5-03M1R01C01 修正关闭了 GPT IR 指出的三个 production Scheduler lifecycle/current-snapshot 缺陷：production dirty wiring、cycle terminal cleanup + re-arm、selector 只读 current accepted-hash-matching semantic consequences；并保证 lifecycle hygiene（failure/no-actors/hold 后不 strand、不 auto-retry）。**返回上限：READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**。GPT 拥有 Independent Review。
