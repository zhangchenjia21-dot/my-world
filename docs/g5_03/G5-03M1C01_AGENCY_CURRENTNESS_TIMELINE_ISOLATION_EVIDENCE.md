# G5-03M1C01 — Agency Currentness + Timeline Isolation Correction Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Date: 2026-09-03
Correction packet: `docs/tasks/G5-03M1C01_AGENCY_CURRENTNESS_TIMELINE_ISOLATION_CORRECTION_TASK.md`
Parent IR: `docs/g5_03/G5-03M1_INDEPENDENT_REVIEW.md`
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`

> 本修正只关闭 GPT IR 指出的 current-version/timeline isolation 缺陷。**保留现有 Multi-Actor Agency Cycle 架构**；不重做 selection/concurrency；不退回 round-robin；不开始 G5-03M2/G5-04。**未执行任何真实 Provider 调用**。

---

## 1. 交付标识

- START_HEAD：`3b5d104682f33f594cf72178a754ef044ff97469`（G5-03M1 已评审实现）
- 实现/证据 HEAD：见 FINAL HEAD（push 后回填）
- 证据文档：本文件

## 2. 修正内容（对应 IR 六个 findings）

### 修正 A — stale semantic handoff 不启动 Agency

- `src/世界回合/L2_流程层/语义物化流程.gd::_accepted_version_still_current()` 现在要求：source turn 仍是 latest accepted ordinary turn（`index == entries.size() - 1`）且 foreground 未在生成（`not conversation.is_generating()`）且 source GM hash 匹配；
- stale 检测先于 `no_changes` 分支——agency_candidates 存在时也检查 currentness，stale 时暴露空 `agency_candidates`；
- `src/应用壳.gd::_on_world_turn_finished()` 在启动 Agency Cycle 前再校验：source turn 仍 latest、source GM hash 仍匹配、Conversation 空闲。

### 修正 B — production Restore wiring 自动 invalidate Agency

- `src/应用壳.gd::_on_restore_completed()` 现在调用 `agency_cycle_runtime.invalidate_remaining()`——production Restore/Recovery progress-switch 自动使剩余 uncommitted agency 失效，不依赖测试手动调用。

### 修正 C — commit-time currentness + cycle-owned head progression

- `src/世界回合/L2_流程层/行动代理循环流程.gd` 新增 `_expected_head_id` + `_source_accepted_count` 跟踪；
- `_on_actor_completed()` 在 commit 前调用 `_cycle_still_current()`：当前 head 必须等于 cycle-owned expected head、source GM hash 仍匹配、accepted Conversation 未前进、无更新 foreground generation active；
- sibling commit 成功后 `_expected_head_id` 前进到该 committed head；unrelated head change 使剩余 uncommitted 失效。

### 修正 D — stale Knowledge/Agency History 按 current hash 过滤

- `src/世界回合/L2_流程层/语义物化流程.gd::_agency_selection_block()` 与 `src/世界回合/L2_流程层/行动代理循环流程.gd::_actor_request()` 都新增 `_current_accepted_hashes()` 过滤：Knowledge/Agency History 只含 `source_turn_index` 在当前 accepted Conversation 且 `source_gm_sha256` 匹配当前 accepted GM hash 的 durable 记录；
- Program 在发送 request 前过滤 stale 记录，不依赖 prose 指令。

### 修正 E — 同 turn-index stale cycle 替换而非合并

- `src/世界回合/L0_公理层/世界回合规则.gd::build_agency_candidate()` 现在只有 `source_gm_sha256` 与 `agency_cycle_id` 都匹配才合并 sibling；stale 同 turn-index cycle 被替换而非合并。

### 修正 F — replay 不重复执行已 committed actor

- `src/世界回合/L2_流程层/行动代理循环流程.gd::start_cycle()` 现在用 `Rules.matching_agency_cycle()` 检查已 committed cycle；已 committed 的 actor 从 `selected_actors` 中移除，不再执行；全部已 committed 时返回 `already_committed`。

## 3. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/世界回合/L2_流程层/语义物化流程.gd` | `_accepted_version_still_current` 加 latest-turn/foreground 校验；stale 检测先于 no_changes；`_agency_selection_block` 加 current-hash 过滤。 |
| `src/世界回合/L2_流程层/行动代理循环流程.gd` | `_expected_head_id`/`_source_accepted_count` 跟踪；`_cycle_still_current()` commit-time guard；`start_cycle` 加 already_committed 跳过；`_actor_request` 加 current-hash 过滤。 |
| `src/世界回合/L0_公理层/世界回合规则.gd` | `build_agency_candidate` 加 stale cycle 替换而非合并。 |
| `src/应用壳.gd` | `_on_world_turn_finished` 加 stale handoff 校验；`_on_restore_completed` 加 agency invalidation；新增 `WorldTurnRules` import。 |
| `tests/g5_03/多角色行动代理循环测试.gd` | 新增 C01-A/B/C/D/E/F 六组断言（共 21 项新断言）。 |

未改动：`src/domain/会话.gd`、`src/ui/**`、persistence schema/migrations、Source schema/generation、Runtime Model Settings、Public d20、G5-03M2/G5-04/G6/G7。

## 4. 自动化矩阵结果（headless）

`tests/g5_03/多角色行动代理循环测试.gd`：**52 PASS / 0 FAIL**（原 31 + C01 新增 21）。

| C01 packet 断言 | 结果 |
| --- | --- |
| A stale semantic handoff 不启动 Agency | PASS（stale_analysis + 零 Agency Cycle） |
| B production Restore wiring 自动 invalidate | PASS（Restore 后 invalidate + late completion 不 commit） |
| C sibling commit 前进 expected head；unrelated head change 失效 | PASS（A 先 commit → B 后 commit；unrelated mutation → B 不 commit） |
| D stale Knowledge/Agency History 按 current hash 过滤 | PASS（selector/executor 输入不含 stale 记录） |
| E 同 turn-index stale cycle 替换而非合并 | PASS（新 cycle 替换旧 cycle；旧 action 不合并） |
| F replay 不重复执行已 committed actor | PASS（already_committed + 无新 execution + 无第二 mutation） |

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G5-03 多角色行动代理循环（C01 强化后） | 52 PASS / 0 FAIL |
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

## 6. 真实 Provider 调用声明

**本次修正未执行任何真实 Provider 调用。** 父任务 G5-03M1 的一次 bounded real selected-Provider attempt 已在 2026-09-03 消耗并于 ordinary Narrative 超时；real G5-03 vertical 保持 `PENDING / EXTERNAL PROVIDER UNAVAILABLE`。未切换 Provider、未加 fallback、未做第二次 attempt。

## 7. 结论

G5-03M1C01 修正关闭了 GPT IR 指出的六个 current-version/timeline isolation 缺陷：stale semantic handoff 不启动 Agency、production Restore wiring 自动 invalidate、commit-time currentness + cycle-owned head progression、stale Knowledge/Agency History 过滤、同 turn-index stale cycle 替换、replay 不重复执行。**返回上限：READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**。GPT 拥有 Independent Review。
