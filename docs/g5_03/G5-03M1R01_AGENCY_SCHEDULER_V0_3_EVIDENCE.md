# G5-03M1R01 — Agency Scheduler v0.3 Simplification Redesign Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Date: 2026-09-03
Task packet: `docs/tasks/G5-03M1R01_AGENCY_SCHEDULER_V0_3_SIMPLIFICATION_REDESIGN_TASK.md`
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

> 本重构只替换上游 semantic-selection 耦合；**保留现有下游 multi-actor 能力**（per-actor concurrent execution、actor-private Source/Knowledge/history、sibling durable commit、foreground/Restore cancellation、replay）。不开始 G5-03M2/G5-04。**未执行任何真实 Provider 调用**。

---

## 1. 交付标识

- START_HEAD：`3b5d104682f33f594cf72178a754ef044ff97469`（G5-03M1 已评审实现）
- 实现/证据 HEAD：见 FINAL HEAD（push 后回填）
- 证据文档：本文件

## 2. 移除 v0.2 耦合

| 文件 | 改动 |
| --- | --- |
| `src/世界回合/L2_流程层/语义物化流程.gd` | `ANALYSIS_INSTRUCTIONS` 恢复为 changes + knowledge only（移除 agency_candidates 指令）；`_analysis_messages` 移除 `_agency_selection_block`；移除 `validated_agency_candidates`；`_accepted_version_still_current` 恢复纯 accepted source-version 语义（不加 foreground 检测）；`finished` 结果不再暴露 `agency_candidates`/`agency_dropped`。 |
| `src/应用壳.gd` | 移除 `world_turn_runtime.finished → candidates → start Agency Cycle` 耦合；新增 `_on_world_turn_finished_for_scheduler`（仅作 scheduling wake-up，不消费 semantic result）；`agency_scheduler` 替代 `agency_cycle_runtime`；`_teardown_agency_scheduler` 随 Session 拆除。 |

## 3. 新增 standalone Agency Scheduler/Selector

| 文件 | 改动 |
| --- | --- |
| `src/世界回合/L2_流程层/行动代理调度流程.gd` | 新增 `AgencySchedulerProcess`：accepted ordinary turn 只标记 `dirty`；`consider_agency()` 在 foreground idle + semantic worker 无 active/queued + 无 selector/cycle active 时启动一次 standalone selector；`_selector_request()` 构建 bounded GM-level 输入（latest accepted player/GM + eligible roster + recent world changes）；`_selector_still_current()` 校验 latest turn/hash + world head + foreground idle；`_validate_candidates()` 验证 eligible stable NPC roster、deduplicate、cap 4；`invalidate_remaining()` 在 foreground attempt/Restore/close 时取消 selector 与剩余 uncommitted actor work；`shutdown()` 清理所有 transports。 |
| `src/世界回合/L3_外交层/行动代理调度公开接口.gd` | 新增 `AgencySchedulerPublicInterface`（extends L2 流程）——唯一有状态外交入口。 |

## 4. 保留下游能力（复用现有 AgencyCycleRuntimeProcess）

`src/世界回合/L2_流程层/行动代理循环流程.gd` 与 `src/世界回合/L3_外交层/行动代理循环公开接口.gd` 未改动，保留：

- multi-actor per-actor execution；
- 并发 selected actor requests（max 4）；
- actor-private Source/current-hash-matching Knowledge/own history；
- serialized durable commits；
- same-cycle sibling expected-head progression；
- foreground/Restore cancellation；
- stale Knowledge/Agency History filtering；
- same-version replay no duplicate；
- bounded Independent Actor Actions GM Context projection。

## 5. Deterministic 证明（A–I）

`tests/g5_03/多角色行动代理循环测试.gd`：**56 PASS / 0 FAIL**。

| 案例 | 结果 |
| --- | --- |
| **A 多选** | 一次 standalone selector 请求；selection 验证 A+B；无 round-robin 额外 C；两个 agency execution 启动；Player/unknown 被拒绝。 |
| **B selector 失败隔离** | valid changes + valid knowledge + malformed agency_candidates → changes/knowledge 仍提交；无 agency cycle；Narrative 不变。 |
| **C 每 actor 知识隔离** | A 的 execution request 含 F 不含 G/P；B 含 G 不含 F/P；不共享 Player 私有知识。 |
| **D 同 cycle 多 act** | A 与 B 并发 active；任意完成顺序都 act → 两条 durable action；serialized commit 经 cycle-owned head progression；后到者不因此 stale；后续 GM Context 含两者。 |
| **E 混合结果** | A=act、B=hold、C=provider failure → 只有 A durable；foreground 不受影响。 |
| **F 前台竞争** | A 在下一玩家 attempt 前 commit；B 仍 active；玩家开始下一回合后 B 完成 → A 保持 durable；B 不能 late-commit；玩家回合不被阻塞。 |
| **G Restore 竞争** | 多个 actor request active；Restore 后 late completion 不产生新 agency action。 |
| **H replay** | committed cycle/action identity 不重复；Save/reopen 保留多 actor 行动于后续 GM Context。 |
| **I 上限** | selector 返回 >4 valid IDs → 只有前 4 个执行；无隐藏 fallback loop。 |

新增 C01 修正案例（保留原 C01 语义，适配新架构）：
- C01-A semantic lane 独立于 Agency：foreground 前进不丢弃 otherwise-valid truth；semantic 不启动 Agency；
- C01-B production Restore wiring 自动 invalidate；
- C01-C commit-time currentness + cycle-owned head progression；
- C01-D stale Knowledge/Agency History 按 current hash 过滤（selector/executor 输入均过滤）；
- C01-E 同 turn-index stale cycle 替换而非合并；
- C01-F replay 不重复执行已 committed actor。

## 6. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G5-03 多角色行动代理循环（R01 重构后） | 56 PASS / 0 FAIL |
| G5-02 已知角色知识溯源（含 C01 roster/recency） | 40 PASS / 0 FAIL |
| G5-01 世界回合语义物化 | 0 FAIL |
| G5-01 世界回合时间线恢复（fresh root） | 0 FAIL |
| G2-05 上下文组装离线 | 0 FAIL |
| G2-04 会话域离线 | 0 FAIL |
| G3-03 会话恢复与候选 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08B 公开D20界面整合 | 127 PASS / 0 FAIL |

`git diff --check` 干净。

## 7. 真实 Provider 调用声明

**本次重构未执行任何真实 Provider 调用。** 父任务 G5-03M1 的一次 bounded real selected-Provider attempt 已在 2026-09-03 消耗并于 ordinary Narrative 超时；real G5-03 vertical 保持 `PENDING / EXTERNAL PROVIDER UNAVAILABLE`。未切换 Provider、未加 fallback、未做第二次 attempt。

## 8. 结论

G5-03M1R01 重构关闭了上游 semantic-selection 耦合：semantic lane 恢复为 changes + knowledge only；新增 standalone Agency Scheduler/Selector（dirty/coalesce/safe start/snapshot/currentness）；保留下游 multi-actor 能力。**返回上限：READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**。GPT 拥有 Independent Review，随后塑造 G5-03M2 stable actor materialization。
