# MW-002 Selective World Evolution Evaluator — Implementation Evidence

- Work Item ID: **MW-002**
- Capability Anchor: **G5-04**
- Revision: **1** / Review-Round: **0**
- Owner: Kimi / Reviewer: GPT
- Task Packet: `docs/tasks/MW-002_SELECTIVE_WORLD_EVOLUTION_EVALUATOR_TASK.md`
- Canonical: `Vibe-Coding/my world/architecture/world/G5_SELECTIVE_WORLD_EVOLUTION_V0_1_DECISION.md`
- Depends-On: G5-03 Agency — ENGINEERING PASS / CLOSED

- START_HEAD: `0d06365ce25af45a61602227ba5208d7a0fe3cfe`（两个 `main` 已刷新核验；Vibe-Coding `ed768d0e0ad912ff9e8f1bcdb439ad3b767b08c1`）
- FINAL_HEAD: `97a874377bc7b25a8e9b7b7b1c2439928ba3429e`（implementation）+ evidence commit（见 git log）

## Changed files

- `src/世界回合/L0_公理层/世界回合规则.gd` — MW-002 常量、`world_evolution_identities` / `build_world_evolution_event` / `world_evolution_event_is_valid` / `matching_world_evolution_event` / `build_world_candidate_with_evolution`。
- `src/世界回合/L1_器件层/世界演化响应解析器.gd` — 新建：evaluator 响应解析（exact `hold|advance`、raw string 不 coerce、event ≤512、effects 1..4 各 ≤512、未知/伪造身份字段忽略、fail-soft）。
- `src/世界回合/L2_流程层/世界演化评估流程.gd` — 新建：World Evolution evaluator runtime process。
- `src/世界回合/L3_外交层/世界演化评估公开接口.gd` — 新建：L3 外交入口。
- `src/世界回合/L2_流程层/行动代理调度流程.gd` — 只加 observability-only `opportunity_finished(result)` 信号（携带 frozen opportunity turn/hash），在 selector 终态（no_actors / malformed / stale / cancel / provider failure）与 actor cycle 终态各恰好发一次。
- `src/应用壳.gd` — evaluator 生命周期挂载/拆除、`opportunity_finished → consider_opportunity` wake、foreground/Restore invalidation。
- `src/世界回合/L1_器件层/世界回合上下文投影器.gd` — `## World Evolution Events` current 投影段（真实 GM consumer）。
- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd` — `project_world_only()`：frozen Game-local World-only T0 baseline。
- `tests/g5_04/选择性世界演化评估测试.gd` — 新建 focused deterministic suite。

无 UI / SQLite schema/table/migration / Public d20 / Faction platform / G5-05 改动。

## Invariant → implementation mapping

- **INV-01 opportunity ≠ causation**：evaluator 只由 ordinary accepted turn 的 Agency terminal 唤醒；`player_text` 为空（Opening-only）→ `opening_skipped`，无请求；无 offline/wall-clock 路径。
- **INV-02 exact ordering**：唯一 wake 是 `agency_scheduler.opportunity_finished`（`应用壳._on_agency_opportunity_finished`）；focused 生产接线证明 `semantic → selector → (cycle terminal) → evaluation` 的实际顺序，且 selector/cycle active 期间 evaluation 请求为 0。
- **INV-03 hold first-class**：`hold` → 无 mutation、无 fake marker、内存 attempted 防同机会自动重试、非失败结果（生产接线证明 head 不变）。无 cadence/priority/pressure queue。
- **INV-04 one-event ceiling**：一次评估结构性至多提交一条 `world_evolution_events_by_turn` 记录（focused 断言 collection size == 1；顺序机会各至多一条）。
- **INV-05 event vs Agency**：evaluator instructions 限定世界层面过程并排除 stable NPC intentional 行动；无 Faction identity/Knowledge/agency。
- **INV-06 dedicated evaluator request**：一条独立轻量请求，解析契约见 parser；永不 gate Narrative acceptance 或 Agency completion（失败隔离 focused 证明 accepted Narrative/prior truth 不变）。
- **INV-07 model-owned priority**：`EVALUATOR_INSTRUCTIONS` 显式声明非随机事件生成器、不因被请求而制造事件、保留 Life Loop、不重复 durable 事实、至多选一个；Program 只做 bounded machine contract/currentness/integrity 校验，无 keyword gate/score/cadence。
- **INV-08 Program-owned durable identity**：`living_world.v0.1` additive collection `world_evolution_events_by_turn`；`world_evolution_id`/`mutation_id`/`node_id` 由 `game_id + opportunity turn/hash + base head` SHA-256 派生，无墙钟/随机；无 SQLite 变更。
- **INV-09 replay/currentness**：`matching_world_evolution_event` durable 信号使 fresh-worker/reopen 再进入同一机会零请求零重复；内存 `_attempted_opportunities` 防同 runtime 重试；不回溯评估历史 turn。
- **INV-10 foreground wins**：启动时冻结 turn/hash/accepted count/base head；commit 前 `_opportunity_still_current` 全部复核 + foreground idle；Shell foreground attempt/Restore/session close 调 `invalidate()` 立即取消；late callback inert（focused 11a/11b 证明）。
- **INV-11 minimal observability**：只加 `opportunity_finished` 信号；dirty ownership/consumption、semantic-terminal wake、selector cap/concurrency、retry policy 零改动（G5-03 回归 0 FAIL + focused §14 断言）。
- **INV-12 world-level input**：`_evaluation_messages` = `project_world_only`（World identity/instructions/selected Entry/World semantic sections）+ latest accepted 行动/叙事 + recent current-hash semantic changes + Agency actions/effects + prior evolution events；无 Actor Knowledge Provenance、无 Character 私有材料、无 mutable Source lookup；baseline 超限 fail-soft 为 hold。
- **INV-13 next GM consumer**：`世界回合上下文投影器._project_evolution` 只投影 committed + accepted-hash-matching 事件（最近 ≤4，既有字符预算内），附 GM-only / non-auto-knowledge 指引；不自动创建 G5-02 Knowledge；不注入 actor execution 请求；production `assemble_continuation_messages()` focused 证明。

## Focused results

`tests/g5_04/选择性世界演化评估测试.gd`（`--root=build/g5_04_focused`）：**112 PASS / 0 FAIL**。

覆盖 task §9 全部 15 项：

1. hold：一次请求、零 mutation、同机会不重试（单元 + 生产接线 head 不变）；
2. advance：恰好一条 Program-owned durable event，bounded event/effects；
3. malformed/invalid/provider failure fail-soft，accepted Narrative 与既有 truth 不变（parser 级 + 流程级）；
4. Opening-only 不产生机会（单元 `opening_skipped` + 真实 Shell 接线零请求）；
5. 生产顺序：真实 `main.tscn` Shell 接线下 `semantic → selector → (cycle terminal) → evaluation`，selector/cycle active 期间零 evaluation 请求；
6. 输入构成：World-only T0 baseline + latest accepted + current semantic changes + 同机会 Agency action/effects + prior current evolution events（单元标记 + 生产接线 Turn B 真实链路）；
7. 输入无 Actor Knowledge / Character 私有材料；ControlledRuntime 结构性无 Source；
8. Program identity：exact opportunity turn/hash + base head 参与 deterministic 派生，base head 变化则 ID 变化，模型给的 ID 被忽略；
9. replay：same-worker 与 reopen-like fresh worker 均 `already_evaluated`，零第二请求、零重复事件；
10. regenerate：stale 事件物理保留，current GM Context 按 hash 排除；
11. foreground invalidate 立即取消 + late completion 不能 commit；head change → `stale_evaluation` 零提交；
12. production Save/reopen/Restore：含事件快照 Restore/reopen 保留 exact 记录与 ID；更早快照 Restore 正常移除；
13. production `assemble_continuation_messages()` 含 `## World Evolution Events` + event/effects + GM-only 指引；
14. 每个 started opportunity 恰好一次 terminal 信号且携带 frozen turn/hash；dirty/selector 语义不变；
15. one-event ceiling 结构性成立；diff 无 priority/pressure/cadence/random 机制（仅否定性注释与 `queue_free` 误报）。

## Minimal affected regressions（focused 绿后一次性）

- G5-01 `世界回合语义物化测试.gd`：**0 FAIL**；
- G5-01 `世界回合时间线恢复测试.gd`：**0 FAIL**；
- G5-02 `已知角色知识溯源测试.gd`：**0 FAIL**；
- G5-03 `多角色行动代理循环测试.gd`（dirty/wake/foreground/selector/cycle 保护）：**0 FAIL**；
- G4-07A `首次开场运行时聚焦测试.gd`（continuation context 真实消费路径）：**0 FAIL**；
- G3-04 `存档恢复持久化测试.gd`：**PASS**。

## Hygiene / boundaries

- `git diff --check`：clean。
- Real Provider calls：**0**（全部 deterministic stub / Shell test seam）。
- 新增/修改生产代码 grep：无 `Source库`/`SourceLibrary`/`source_current`/`install_` 引用——无 mutable Source lookup。
- 无 numeric priority / pressure queue / every-N-turn cadence / random-event engine / event taxonomy / Quest/Thread/Faction platform。
- 无 UI、无 SQLite schema/table/migration、无 Public d20 改动、未进入 G5-05。
- G5-03 protected semantics 未重开；semantic `agency_candidates` 未恢复使用；MW-001 行为未触碰。

## Status

**READY FOR INDEPENDENT REVIEW**

G5-04 是核心世界节奏/产品体感变更：即使 Engineering PASS，也必须经 Owner UAT 后才可关闭 G5-04；本 evidence 不构成 Product PASS 主张。
