# MW-007 Mechanics Consequence Timeline Continuity — Implementation Evidence

Status: **READY FOR INDEPENDENT REVIEW（候选）**
Implementation Owner: Zcode + GLM-5.3-Flash（Owner weekend routing override）
Reviewer: GPT
Formal Task: `docs/tasks/MW-007_MECHANICS_CONSEQUENCE_TIMELINE_CONTINUITY_TASK.md`
Task Branch: `mw-007-mechanics-consequence-timeline-continuity`

## 0. Implementation SHA / base / diff

```text
production code unchanged（零 production GDScript diff）
Implementation Base: origin/main @ 4e2c467（含 MW-006 已合并产物与 MW-005 R2 correction）
Deliverable: tests/mw007/机制后果时间线连续性测试.gd + 本证据文档
SQLite schema/table/migration diff: empty（persistence 层零改动）
Real Provider calls: 0（全部 stub adapter / 受控 RNG）
git diff --check: clean
Windows export validation: 未执行（packet §13：仅 production GDScript 变化时要求）
```

## 1. Pass A — lifecycle / ownership trace（真实 production seams）

| 环节 | Owner 与真实路径 |
|---|---|
| action identity + CHECK_REQUIRED persistence | `公开D20行动判定流程`：caller-owned `action_id` → `check_id = check-SHA256(game_id+U+001F+action_id)`；`_roll_and_persist` 在任何 narrative 之前把完整 check（proposal+RNG 结果+marker 字段）写入 `world_state.expansion_runtime.public_d20_checks[]`，经 `commit_world_mutation_durably`（mutation_id = `public-d20-<check_id>`）CAS 进 Timeline |
| Narrative acceptance + marker | `complete_active_generation_durably`（conversation_materializations COMMIT）→ `complete_generation()` 同步 emit → `_mark_narrative_accepted` 在 deferred 语义 drain 前同步 durable 写 `narrative_accepted + accepted_turn_index` |
| MW-006 lookup + semantic request | `公开D20判定规则.matching_accepted_check_for_turn`（narrative_accepted ∧ accepted_turn_index ∧ player_text 全等；0/>1 fail-soft）→ `语义物化流程._analysis_messages` 附加有界 grounding block |
| G5-01 world mutation / Timeline commit | `语义物化流程._on_completed` → `Rules.build_world_candidate_with_actors`（current world_state 深拷贝 + living_world additions）→ deterministic `mutation_id = semantic-turn-<hash>` → `commit_world_mutation_durably`（Timeline node + world_materialization CAS + head CAS，同一事务） |
| named Save snapshot | `世界持久化流程.create_save_point`：单事务读取 `games.active_head_id` + `conversation_materializations.accepted_turns_json`，写入 immutable `save_points` 行（锚定 Timeline node，**不拷贝** world snapshot） |
| close/reopen | `close`：cancel active generation → backup refresh → close DB → release writer。`open_existing_game/open_current_game`：writer lock → schema/inspection → `get_current_game`（active head == world head 校验）→ `get_current_conversation` → Domain rehydrate |
| Restore | `restore_save_point`：单事务内读 anchor node 的 `world_snapshot_json`（**完整 World document**）→ 写 recovery checkpoint → 原子切换 `world_materializations` + `games.active_head_id` + `conversation_materializations` → Runtime `_apply_committed_progress_switch` |
| continuation Context projection | `世界回合上下文投影器.project`：只投影 current world snapshot 中 committed 且与 current accepted hash 匹配的 `living_world` records（changes/knowledge/agency/evolution）；不读 `expansion_runtime` |

**关键所有权结论（packet Pass A 明确要求证明而非推断）**：d20 check records 与 living_world semantic consequences **不存在独立持久化**——两者都是 World document（`world_snapshot_json`）的成员，由 Timeline node snapshot 统一拥有；Conversation 在独立表中，但 Restore 在**同一事务**内与其同步切换。因此"三者一起回滚"不是推断，而是 restore 事务的实际写入路径。

## 2. Pass B — ghost-state audit

```text
A. d20 record survives Restore while Narrative/consequence gone → 不可能：三者同一 world snapshot/同一 restore 事务原子切换（V2 实证）
B. consequence survives while d20/Conversation gone → 同上（V2 实证）
C. close/reopen causes reroll/duplicate semantic materialization → 不可能：reopen 只读 current head；start_action 先查 durable check（accepted → already_accepted，无 Provider/RNG）；semantic 无自动 wake，durable replay 信号（matching_record 等）使显式 replay 幂等（V1 实证）
D. later continuation sees restored-away consequence → 双重防护：record 已随 snapshot 回滚 + projector 的 accepted-hash 匹配过滤（V2 实证）
E. later continuation loses valid post-Save consequence → 不可能：reopen projection 读 current snapshot（V1 实证）
F. semantic materialization rewrites mechanics truth → 不可能：candidate 为 current world_state 深拷贝 + living_world additions，expansion_runtime 原样通过；V1 断言 reopen 前后 check JSON 逐字段一致
```

无任何一项需要 production 修正；canonical semantics 已完整覆盖 → 按 packet Preferred outcome 交付（production diff = 0）。

## 3. V1 proof（post-consequence Save → close → reopen → Continue）

真实链条：real Managed Library（2 World + 6 Character + 公开d20 Expansion fixture）→ real Final Create materialization → real Runtime open → real `公开D20行动判定流程`（stub provider + DeterministicRng[15]，dc12+mod2 → total17 success）→ durable check → accepted free-form Narrative → normal G5-01 机会收到 MW-006 grounding（恰一次、exact facts）→ stub 语义输出（模型 authored）经既有 mutation 提交 → **Save AFTER consequence** → close → reopen：

- Conversation 恰好一次（action/Narrative）；
- durable check 逐字段一致（JSON 深比较，含同一 check_id/raw_rolls/total/outcome + acceptance marker）；
- semantic consequence 恰好一次；
- reopen 本身零 semantic request；显式 replay → `already_materialized`，零 duplicate mutation；
- 同 action_id 重新提交 → `already_accepted`，零 Provider、零 RNG（**no reroll**）；
- continuation Context（production `assemble_continuation_messages` + World Turn context seam）包含 committed consequence（`## Materialized World Changes`），且**不含** `Durable Mechanical Resolution` block 或 check_id —— 无第二 mechanics truth。

## 4. V2 proof（pre-action Save → action/consequence → Restore）

pre-action Save 前：baseline 普通回合 + 语义 consequence（turn 0）。之后 CHECK_REQUIRED action（turn 1，RNG[7] → total9 failure）→ Narrative → grounding → V2_CONSEQUENCE 提交。Restore 回行动前 Save：

- later action/Narrative 从 Conversation 消失（entries 2→1）；
- later semantic consequence 消失（records 2→1）；
- **later d20 check 一并消失**（同一 world snapshot 所有权，Pass A 已证路径，V2 实证）；
- `matching_accepted_check_for_turn(restored_world_state, 1, action_text) == {}` —— 无 ghost mechanics grounding；
- continuation Context 含 baseline、不含 V2_CONSEQUENCE / restored-away Narrative / grounding marker / future_check_id；
- **同 action_id 重放**：既有 identity 规则 fail-loud——control 正常启动 → proposal → RNG 触碰 → `_roll_and_persist` 命中 timeline 中既有 mutation_id 且 fingerprint 不同 → `MUTATION_CONFLICT` → `check_persistence_failed`，零新 truth、零 Narrative（不静默复用 restored-away future truth，符合现有 caller-owned identity 语义）；
- **新 action_id**：按既有 RNG/identity 规则全新判定（RNG[20]，新 check_id ≠ 旧 check_id），grounding 只绑定新 check（不含 ghost check_id），语义 consequence 经正常 seam 恰好一次提交。

未发现"Public d20 records 与 World State 有不同 Restore 所有权"的合同 → 不触发 packet V2 的 STOP 分支。

## 5. Regression matrix（Godot 4.7.2 headless，全部 task-owned fresh roots）

```text
tests/mw007/机制后果时间线连续性测试.gd        failures=0（35 断言）
tests/mw006/机制锚定世界后果垂直测试.gd        failures=0
tests/g5_01/世界回合语义物化测试.gd            failures=0
tests/g5_01/世界回合时间线恢复测试.gd          failures=0
tests/g4_08m1/公开D20机制测试.gd               failures=0   ← 直接 retry/no-reroll 覆盖（含 restart skips RNG、already_accepted）
tests/g4_08m1/NO_CHECK行动幂等修复测试.gd      failures=0
git diff --check                               clean
```

注意事项：同一 root 复用第二次运行会因夹具/library 残留状态失败（测试均假定 task-owned fresh root）；本任务矩阵每条均为 fresh root 单次运行。另有一个测试自身 bug 在开发中发现并修正（V1 saved_check 原在 acceptance marker 写入前捕获，导致 reopen 对比假阴性），不影响 production。

## 6. Parallel / collision status（MW-005 R2 / Kimi）

- MW-005 R2 已合入 main（583dde4：`_control_messages` 以 `include_style=false` 投影 + projector/L3 透传 + 排除测试）。与 MW-007 零交集——MW-007 production diff 为 0，未触碰任何 Kimi 文件/Primer bytes/correction。
- 本任务未修改 shared projector / Public-d20 request seam → 无 collision。
- final handoff 前重新 fetch main 并 rebase，重跑 focused matrix（见最终报告）。

## 7. Remaining risks / notes for GPT

1. 同 action_id 在 Restore 后重放的 `MUTATION_CONFLICT` fail-loud 是**现有** caller-owned identity 语义（timeline UNIQUE(game_id, mutation_id) + fingerprint CAS）。产品语义上意味着"Restore 后用同一 action_id 重做同一行动"会失败而非重掷——现有 canonical 行为，未在本任务改变；若 Owner UAT 认为需要更友好语义，那是新的 product decision，不是本任务范围。
2. Restore 后 in-process semantic worker 的 `_attempted_versions` 保留旧 version key；只有 byte-identical GM narrative 复现同一 turn index 时才会抑制重分析——即 G5-01M1C02 已知 deferred edge（本任务无具体复现，按 packet Stop Conditions 不触碰）。
3. 测试依赖 fixtures（g4_02r1/g4_05/g4_08m1）与 fresh root 假设，root 复用会误报。
