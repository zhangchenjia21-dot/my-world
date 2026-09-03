# G5-03M1 — Multi-Actor Agency Cycle Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Date: 2026-09-03
Task packet: `docs/tasks/G5-03M1_MULTI_ACTOR_AGENCY_CYCLE_TASK.md`
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`
G5-02 decision: `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`

> 本任务实现 G5-03M1 多角色行动代理循环：一个 accepted ordinary turn 可产生 0..4 个 stable NPC 的独立 durable 行动。**不声明 G5-03 PASS**；不开始 G5-03M2/G5-04。

---

## 1. 交付标识

- START_HEAD：`405ebafee7d428c4303d4599e78d508130757da5`（packet Code Base SHA）
- 实现/证据 HEAD：见 FINAL HEAD（push 后回填）
- 证据文档：本文件

## 2. 改动路径

| 文件 | 改动 |
| --- | --- |
| `src/世界回合/L0_公理层/世界回合规则.gd` | 新增 G5-03M1 有界形状：`AGENCY_CYCLE_MAX_ACTORS=4` / intent/action/effects 上限；`agency_cycle_identities`（`game_id + turn_index + GM hash + cycle_base_head_id` → stable `agency_cycle_id`）；`agency_action_identities`（`game_id + agency_cycle_id + actor_id` → stable `agency_action_id`/`mutation_id`/`node_id`）；`agency_action_is_valid` / `agency_cycle_is_valid`；`build_agency_cycle` / `build_agency_action`；`build_agency_candidate`（同一 candidate snapshot 并入 sibling 行动，不覆盖其它 actor）；`matching_agency_cycle`。 |
| `src/世界回合/L1_器件层/语义变更响应解析器.gd` | `parse()` 扩展返回 `agency_candidates` + `agency_dropped`；新增 `parse_agency_candidates()`——与 changes/knowledge 完全隔离：absent/invalid/oversized 均 fail-soft 为空。 |
| `src/世界回合/L2_流程层/语义物化流程.gd` | `ANALYSIS_INSTRUCTIONS` 扩展为三类 durable 事实（changes + knowledge_events + agency_candidates），明确 selection 指令（只从 Eligible Agency Actors 选择、只根据该 actor 自己的 Source/知识/历史判断、不选 Player、不编造 ID）；`_agency_selection_block()` 给 selector 每 eligible NPC 的 bounded actor-local 材料（Source sections / own knowledge / own agency history）；`validated_agency_candidates()` 验证 eligible stable NPC roster、deduplicate、cap 4、丢弃 unknown/Player/empty；`finished` 结果暴露 `agency_candidates` 给 Application。 |
| `src/世界回合/L2_流程层/行动代理循环流程.gd` | 新增 `AgencyCycleRuntimeProcess`：每 selected actor 一个隔离 execution request（只含该 actor 的 Source/knowledge/history + 最小 cycle identity）；并发进行（bounded 4）；serialized durable commit 经 `commit_world_mutation_durably`；cycle-owned head progression 允许 sibling 已提交的 head 前进；`invalidate_remaining()` 在 foreground attempt/Restore/close 时使剩余 uncommitted 失效；`shutdown()` 清理所有 transports。 |
| `src/世界回合/L3_外交层/行动代理循环公开接口.gd` | 新增 `AgencyCyclePublicInterface`（extends L2 流程）——唯一有状态外交入口。 |
| `src/世界回合/L1_器件层/世界回合上下文投影器.gd` | 新增 `_project_agency`：committed + hash-matching 的 agency cycle 投影 `## Independent Actor Actions`（omniscient GM world reference only；不自动成为 Player/其它 actor 知识）；bounded 最近一个 matching cycle。 |
| `src/应用壳.gd` | `_prepare_world_turn_after_activation` 连接 `world_turn_runtime.finished` → `_on_world_turn_finished`：有 validated `agency_candidates` 时启动 Agency Cycle；`_teardown_agency_cycle` 随 Session 拆除；`_on_foreground_attempt_started` 在 `attempt_started` 时 invalidate 剩余 uncommitted agency（foreground 永远优先）。 |
| `tests/g5_03/多角色行动代理循环测试.gd` | 新增 focused deterministic 证明（A–I）。 |
| `tests/g5_03/真实Provider行动代理验证.gd` + `运行真实Provider行动代理验证.ps1` | 新增真实 selected-Provider 验证 harness（上限 3 次调用）。 |

未改动：`src/domain/会话.gd`、`src/ui/**`、persistence schema/migrations、Source schema/generation、Runtime Model Settings、Public d20、G5-03M2/G5-04/G6/G7。

## 3. Durable shape（实际实现）

```text
living_world
  schema_version = living_world.v0.1
  semantic_turns_by_index          # 既有 G5-01
  knowledge_turns_by_index         # 既有 G5-02
  agency_cycles_by_source_turn     # 新增 G5-03M1
    <source_turn_index>
      agency_cycle_id              # agency-cycle-<sha256(game_id|turn_index|gm_hash|base_head)>
      source_turn_index
      source_gm_sha256
      cycle_base_head_id
      materialized_at
      actions_by_actor
        <actor_id>
          agency_action_id         # agency-action-<sha256(game_id|cycle_id|actor_id)>
          actor_id
          intent
          action
          effects[]
          materialized_at
```

无 SQLite schema/table；复用既有 world snapshot 与 `commit_world_mutation_durably` seam。

## 4. Deterministic 证明（A–I）

`tests/g5_03/多角色行动代理循环测试.gd`：**31 PASS / 0 FAIL**。

| 案例 | 结果 |
| --- | --- |
| **A 多选** | 一次语义请求；selection 验证 A+B；无 round-robin 额外 C；两个 agency execution 启动；Player/unknown 被拒绝。 |
| **B selector 失败隔离** | valid changes + valid knowledge + malformed agency_candidates → changes/knowledge 仍提交；无 agency cycle；Narrative 不变。 |
| **C 每 actor 知识隔离** | A 的 execution request 含 F 不含 G/P；B 含 G 不含 F/P；不共享 Player 私有知识。 |
| **D 同 cycle 多 act** | A 与 B 并发 active；任意完成顺序都 act → 两条 durable action；serialized commit 经 cycle-owned head progression；后到者不因此 stale；后续 GM Context 含两者。 |
| **E 混合结果** | A=act、B=hold、C=provider failure → 只有 A durable；foreground 不受影响。 |
| **F 前台竞争** | A 在下一玩家 attempt 前 commit；B 仍 active；玩家开始下一回合后 B 完成 → A 保持 durable；B 不能 late-commit；玩家回合不被阻塞。 |
| **G Restore 竞争** | 多个 actor request active；Restore 后 late completion 不产生新 agency action。 |
| **H replay/reopen** | committed cycle/action identity 不重复；Save/reopen 保留多 actor 行动于后续 GM Context。 |
| **I 上限** | selector 返回 >4 valid IDs → 只有前 4 个执行；无隐藏 fallback loop。 |

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
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

## 6. 真实 selected-Provider 验证

- **状态**：`PENDING / EXTERNAL PROVIDER UNAVAILABLE`。
- **一次 bounded attempt 已执行**：`tests/g5_03/真实Provider行动代理验证.gd`（上限 1 次组合语义-selection + 至多 2 次 actor execution）。
- **当前 approved profile**：`kimi_k3 / 256k / high`（`build/g503/agency-real.json` 记录，无 credential）。
- **结果**：真实 narrative 请求在 420s 内未完成（Provider 外部超时）；offline/integration 门禁全绿。
- **按 standing outage rule**：commit/push reviewable implementation/tests/evidence；real G5-03 vertical 标记 PENDING。

## 7. Owner production 安全

真实验证全程 task-owned `build/g503/state`；Owner production settings/Source/Games/current DB 未触碰。

## 8. 结论

G5-03M1 工程垂直（组合语义-selection → validated agency_candidates → 每 actor 隔离并发 execution → serialized durable commit → 后续 GM Context 独立行动投影）在 deterministic 轨道上全部通过。**返回上限：READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**。GPT 拥有 Independent Review，随后塑造 G5-03M2 stable actor materialization。
