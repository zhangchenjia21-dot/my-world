# MW-002 Selective World Evolution Evaluator — Implementation Evidence

- Work Item ID: **MW-002**
- Capability Anchor: **G5-04**
- Revision: **2** / Review-Round: **1**
- Triggered-By: **MW-002 IR#1**（CORRECTION REQUIRED → F01–F04）
- Correction Base: `d42477c45d4699c91ec0e40124ced374101135b9`
- Owner: Kimi / Reviewer: GPT
- Task Packet: `docs/tasks/MW-002_SELECTIVE_WORLD_EVOLUTION_EVALUATOR_TASK.md`
- Canonical: `Vibe-Coding/my world/architecture/world/G5_SELECTIVE_WORLD_EVOLUTION_V0_1_DECISION.md`
- Depends-On: G5-03 Agency — ENGINEERING PASS / CLOSED

- R2 START_HEAD: `d4332dd4233fd90a3dbbae382ba199c5fedc2535`（两个 `main` 已刷新核验；Vibe-Coding `fd7f86d62537ed1a8afc95edcbeae472c647a31f`）
- R2 FINAL_HEAD: `5459c4f8a1d92928129c1d3217a40c6622522496`（implementation）+ evidence commit（见 git log）
- R1（保留记录）：START `0d06365c…` / FINAL `97a874377bc7b25a8e9b7b7b1c2439928ba3429e` + evidence `d42477c4…`

## Revision 2 scope（只修 IR#1 F01–F04，架构不重开）

Revision 1 已成立的 hold / one-event ceiling / deterministic Program identity / durable event / hash-current Context / no-auto-Knowledge / no mutable Source lookup 全部保护，未改动。

### Changed files（R2）

- `src/应用壳.gd` — **F01**：`_prepare_action_adjudication_after_activation()` 连接既有 `action_adjudication.request_assembled` → 新 `_on_adjudication_request_assembled()`，对任一 stage 执行与 `_on_foreground_attempt_started` 相同的 background invalidation（`agency_scheduler.invalidate_remaining()` + `world_evolution_evaluator.invalidate()`；幂等）。d20 流程/协议/骰子/Narrative 语义/UI 零改动。
- `src/世界回合/L2_流程层/行动代理调度流程.gd` — **F02**：`_on_selector_completed` 中 `start_cycle` 返回 `already_committed`（actor_count=0）时立即 terminal：detach/free 刚创建的 cycle runtime、`agency_cycle_runtime = null`、`selector_finished` + 恰好一次 `_emit_opportunity_finished`（payload 带 frozen turn/hash）。dirty consumption / selector 0..4 / concurrency / retry 语义零改动。
- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd` — **F03**：`project_world_only()` 不再复用 `_append_game()`；改用最小中性 Game-local authority header（`_append_world_only_game_header`：仅 Game ID + Selected Entry）。排除 `opening_supplement` / `control_mode` / display_name 等 Game settings 与一切 Player/Character 私有材料；World / exact selected Entry / world+GM instructions / World semantic sections 保留；MAX_CONTEXT_CHARS fail-soft 不变。
- `tests/g5_04/选择性世界演化评估测试.gd` — **F01–F04 focused proofs**（见下）。

只读未改：`src/ui/叙事对话视图.gd`、`src/行动判定/L2_流程层/公开D20行动判定流程.gd`、`src/世界回合/L2_流程层/行动代理循环流程.gd`（既有 seam 足够，无需改动）。

### F01–F04 → proof 映射

- **F01 Public-d20 foreground**（`_test_d20_foreground_invalidation`，真实 `main.tscn` Shell + d20 capability mounted）：Turn A 走真实 production d20 NO_CHECK 路径（control → narrative → durable accepted）→ semantic → selector `no_actors` → evolution evaluation active；Player 再发送冒险行动，`start_action` 的 control `request_assembled` **同步**触发 invalidation——断言在 `_on_send_pressed()` 返回后立即成立（`evaluation_cancelled`）；late evolution completion → 0 commit、head 不变；dirty/selector/cycle 语义不变。
- **F02 already_committed immediate terminal**（`_test_already_committed_terminal`）：预置 matching durable cycle（`Rules.build_agency_cycle` + `actions_by_actor` 覆盖全部 selected actors、hash 匹配 current accepted）→ selector 选出该 actor → 零 actor request、cycle runtime 立即清理、恰好一次 `opportunity_finished`（status `already_committed`、actor_count=0、frozen turn/hash）→ World Evolution 恰好 wake 一次并 hold 收尾（无 fake mutation）→ 后续新 dirty opportunity 正常启动 selector 并正常 terminal（scheduler 未 strand）。
- **F03 真 World-only baseline**（`_setup_world` + `_test_input_composition_and_privacy`）：setup 的 `opening_supplement = "PRIVATE_OPENING_SUPPLEMENT_MARKER"`、`control_mode = "PRIVATE_CONTROL_MODE_MARKER"`；断言 evaluator request 不含两个 marker、不含 `Control mode:` 标签，同时 World markers（`WORLD_ONLY_BASELINE_MARKER` / `WORLD_INSTRUCTION_MARKER`）、Entry markers（`ENTRY_DISPLAY_MARKER` / `ENTRY_SEED_MARKER` / `entry-t0-marker`）与 Game ID 仍存在。既有 Knowledge/Character-private 排除断言保持。
- **F04 production Restore-active proof**（`_test_restore_active_invalidation`，真实 Shell）：baseline Save → Turn A 跑到 evolution evaluation active → production `restore_save_point` → `evaluation_cancelled` 立即成立、restored head 不变、restored world 无 event、无多余 `opportunity_finished`、无存活/新增 evolution request → late callback → 0 commit、head 仍不变 → scheduler 未 strand。Restore 路径上 Agency invalidation（此时 selector 已 terminal、无 cycle）不产生任何新 evolution request/commit。

## R1 保留的 Invariant → implementation mapping

- **INV-01 opportunity ≠ causation**：evaluator 只由 ordinary accepted turn 的 Agency terminal 唤醒；`player_text` 为空（Opening-only）→ `opening_skipped`，无请求；无 offline/wall-clock 路径。
- **INV-02 exact ordering**：唯一 wake 是 `agency_scheduler.opportunity_finished`（`应用壳._on_agency_opportunity_finished`）；focused 生产接线证明 `semantic → selector → (cycle terminal) → evaluation` 的实际顺序，且 selector/cycle active 期间 evaluation 请求为 0。
- **INV-03 hold first-class**：`hold` → 无 mutation、无 fake marker、内存 attempted 防同机会自动重试、非失败结果（生产接线证明 head 不变）。无 cadence/priority/pressure queue。
- **INV-04 one-event ceiling**：一次评估结构性至多提交一条 `world_evolution_events_by_turn` 记录。
- **INV-05 event vs Agency**：evaluator instructions 限定世界层面过程并排除 stable NPC intentional 行动；无 Faction identity/Knowledge/agency。
- **INV-06 dedicated evaluator request**：一条独立轻量请求；永不 gate Narrative acceptance 或 Agency completion。
- **INV-07 model-owned priority**：Program 只做 bounded machine contract/currentness/integrity 校验，无 keyword gate/score/cadence。
- **INV-08 Program-owned durable identity**：`living_world.v0.1` additive collection；`world_evolution_id`/`mutation_id`/`node_id` 由 `game_id + opportunity turn/hash + base head` SHA-256 派生；无 SQLite 变更。
- **INV-09 replay/currentness**：durable matching event + 内存 `_attempted_opportunities`；fresh-worker/reopen 再进入同一机会零请求零重复。
- **INV-10 foreground wins**：启动冻结 turn/hash/accepted count/base head；commit 前 `_opportunity_still_current` 复核 + foreground idle；foreground（含 **R2 F01** 的 d20 control request 开始）/Restore/session close 立即 `invalidate()`；late callback inert。
- **INV-11 minimal observability**：只加 `opportunity_finished` 信号（**R2 F02** 补齐 already_committed 立即 terminal）；dirty ownership/consumption、semantic-terminal wake、selector cap/concurrency、retry policy 零改动。
- **INV-12 world-level input**：`_evaluation_messages` = `project_world_only`（**R2 F03** 起为真 World-only：排除 Game settings）+ latest accepted 行动/叙事 + recent current-hash semantic changes + Agency actions/effects + prior evolution events；无 Actor Knowledge Provenance、无 Character 私有材料、无 mutable Source lookup。
- **INV-13 next GM consumer**：`世界回合上下文投影器._project_evolution` 只投影 committed + accepted-hash-matching 事件，附 GM-only / non-auto-knowledge 指引；不自动创建 G5-02 Knowledge；不注入 actor execution 请求。

## Focused results（R2）

`tests/g5_04/选择性世界演化评估测试.gd`：

```
"D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe" --headless --path "D:/AI/Projects/my-world" \
  --script "res://tests/g5_04/选择性世界演化评估测试.gd" -- --root="D:/AI/Projects/my-world/build/g5_04_focused"
```

**144 PASS / 0 FAIL**（R1 112 + R2 新增 32）。覆盖 task §9 全部 15 项 + IR#1 F01–F04 proof（映射见上）。

## Minimal affected regressions（R2 focused 绿后一次性）

- G5-03 `多角色行动代理循环测试.gd`（Scheduler/Cycle 保护：`--root=build/g5_03_recheck`）：**0 FAIL**；
- G4-08M1 `公开D20机制测试.gd`（Public-d20 保护：`--root=build/g4_08m1_recheck`）：**0 FAIL**；
- G4-07A `首次开场运行时聚焦测试.gd`（continuation/context：`--root=build/g4_07a_recheck`）：**0 FAIL**；
- G3-04 `存档恢复持久化测试.gd`（Save/Restore：`--root=build/g3_04_recheck`）：**PASS**；
- `git diff --check`：clean。

## Hygiene / boundaries

- Real Provider calls：**0**（全部 deterministic stub / Shell test seam）。
- 无 UI、无 SQLite schema/table/migration、无 Public d20 mechanics/protocol/dice/Narrative 改动、未进入 G5-05。
- 无 numeric priority / pressure queue / every-N-turn cadence / random-event engine / Quest/Thread/Faction platform。
- G5-03 protected semantics 未重开（C02 dirty consumption / no-auto-retry 保留并有 focused 断言）；semantic `agency_candidates` 未恢复；MW-001 行为未触碰。

## Status

**READY FOR INDEPENDENT REVIEW**（MW-002 Revision 2 / Review-Round 1；GPT 将基于 correction base `d42477c4…` 做 IR#2）

G5-04 是核心世界节奏/产品体感变更：即使 Engineering PASS，也必须经 Owner UAT 后才可关闭 G5-04；本 evidence 不构成 Product PASS 主张。
