# G5-02M1 — Known-Actor Knowledge Provenance Spine Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Date: 2026-09-03
Task packet: `docs/tasks/G5-02M1_KNOWN_ACTOR_KNOWLEDGE_PROVENANCE_TASK.md`
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`
G5-01 decision: `Vibe-Coding/my world/architecture/world/G5_WORLD_TURN_SEMANTIC_MATERIALIZATION_V0_1_DECISION.md`

> 本任务实现 G5-02M1 最小 durable 边界：GM 可拥有广博世界真相，但 stable Game-local actor 不因事实存在于 GM/world Context 就自动继承。**不声明 G5-02 PASS**；不开始 G5-03。

---

## 1. 交付标识

- START_HEAD：`1de7082d85a659e3f01fad3c946ccfe0b56b1592`（packet Code Base SHA）
- 实现/证据 HEAD：见 FINAL HEAD（push 后回填）
- 证据文档：本文件

## 2. 改动路径

| 文件 | 改动 |
| --- | --- |
| `src/世界回合/L0_公理层/世界回合规则.gd` | 新增 G5-02M1 有界形状：`MAX_KNOWLEDGE_EVENTS_PER_TURN=4` / `MAX_KNOWLEDGE_FACT_CHARS=256` / `KNOWLEDGE_BASES`；`actor_roster()`（只读 Game-local setup 的 `player_character.local_character_id` + `guaranteed_npcs[*].local_character_id`）；`knowledge_event_is_valid` / `knowledge_record_is_valid`；`knowledge_identities`（`game_id + turn_index + GM hash` → stable `knowledge_turn_id`）；`build_knowledge_record`；`build_world_candidate_with_knowledge`（同一 candidate snapshot 可同时承载 changes 与 knowledge）；`matching_knowledge_record`。 |
| `src/世界回合/L1_器件层/语义变更响应解析器.gd` | `parse()` 扩展返回 `knowledge_events` + `knowledge_dropped`；新增 `parse_knowledge_events()`——与 changes 完全隔离：absent/invalid/oversized 均 fail-soft 为空，绝不 invalidate otherwise valid 的 changes。 |
| `src/世界回合/L2_流程层/语义物化流程.gd` | `ANALYSIS_INSTRUCTIONS` 扩展为联合响应（changes + knowledge_events），明确语义指令：只提取该 accepted turn 新建立给 stable actor 的知识、不因事实为真就授予、不因 NPC 在阵容就推断知情、不编造未知 actor/ID、不输出推理；`_on_completed` 处理联合响应：roster 校验丢弃 unknown/non-roster knower_id；changes 与 knowledge 同时进入**至多一次** `commit_world_mutation_durably`；`_consider_entry` replay 同时查 changes 与 knowledge 记录（同 accepted 版本不重复提交）。 |
| `src/世界回合/L1_器件层/世界回合上下文投影器.gd` | 新增 `_project_knowledge`：committed + hash-matching 的 durable provenance 按 actor 聚合，bounded（8 actor / 8 event）；输出 `## Actor Knowledge Provenance` 软模型引导（GM 有更广 reference；post-T0 事实不自动成为 actor 知识）；不做关键词/分类器检查。 |
| `tests/g5_02/已知角色知识溯源测试.gd` | 新增 focused deterministic 证明（A–F）。 |
| `tests/g5_02/真实Provider知识溯源验证.gd` + `运行真实Provider知识溯源验证.ps1` | 新增真实 selected-Provider 验证（一次 bounded attempt）。 |

未改动：`src/domain/会话.gd`、`src/ui/**`、persistence schema/migrations、Source schema/generation、Runtime Model Settings、Public d20、G5-03/G5-04/G6/G7。

## 3. Durable shape（实际实现）

```text
living_world
  schema_version = living_world.v0.1
  semantic_turns_by_index          # 既有 G5-01
    <turn_index> { world_turn_id, source_turn_index, source_gm_sha256, materialized_at, changes[] }
  knowledge_turns_by_index         # 新增 G5-02M1
    <turn_index>
      knowledge_turn_id            # knowledge-turn-<sha256(game_id|turn_index|gm_hash)>
      source_turn_index
      source_gm_sha256
      materialized_at
      events[] { knower_id, fact, basis }
```

无 SQLite schema/table；复用既有 world snapshot 与 `commit_world_mutation_durably` seam。

## 4. Deterministic 证明（A–F）

`tests/g5_02/已知角色知识溯源测试.gd`：**24 PASS / 0 FAIL**。

| 案例 | 结果 |
| --- | --- |
| **A 私有获取不对称** | Player 单独发现私有事实 F → 一次原子 mutation 只含 Player 的 provenance；Context 显示 Player 知道 F；NPC A 无 provenance。 |
| **B 后续披露** | 后续 accepted Narrative 明确告诉 NPC A → NPC A 获得 provenance；Context 现在显示 NPC A 知道 F（`[told]`）。 |
| **C 未知 actor 拒绝** | non-roster `knower_id` 被丢弃且计数；不成为 durable authority；roster 事件仍提交。 |
| **D 解析隔离** | valid changes + invalid/oversized/malformed knowledge_events → changes 仍提交；无无效 knowledge 记录；accepted Narrative 不受影响；全部 invalid 事件丢弃计数。 |
| **E 仅知识 mutation** | 无 durable world changes 但有有效知识获取 → 一次原子 mutation 只含知识记录；无 consequence 记录。 |
| **F replay/reopen/hash** | 同一 accepted 版本 replay 不重复知识（`already_materialized`）；Save/reopen 保留知识记录于 Context；stale GM-hash 知识不投影。 |

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
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
- **一次 bounded attempt 已执行**：`tests/g5_02/真实Provider知识溯源验证.gd` + `运行真实Provider知识溯源验证.ps1`。
- **当前 approved profile**：`kimi_k3 / 256k / high`（`build/g502/world-turn-real.json` 记录，无 credential）。
- **结果**：真实 narrative 请求在 420s 内未完成（Provider 外部超时）；offline/integration 门禁全绿。
- **按 standing outage rule**：commit/push reviewable implementation/tests/evidence；real G5-02 vertical 标记 PENDING。

## 7. Owner production 安全

真实验证全程 task-owned `build/g502/state`；Owner production settings/Source/Games/current DB 未触碰（runner 的 fingerprint 保护因 production Source Library 缺失而跳过；直接调用不读 Owner 数据）。

## 8. 结论

G5-02M1 工程垂直（联合语义响应 → actor allowlist 校验 → 单原子 mutation → durable provenance → 后续 Context 软引导边界）在 deterministic 轨道上全部通过。**返回上限：READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**。GPT 拥有 Independent Review 与 G5-02 closeout。
