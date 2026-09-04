# MW-001 Runtime Narrative Actor Materialization — Implementation Evidence

- Work Item ID: **MW-001**
- Capability Anchor: **G5-03**
- Legacy Planning Ref: **G5-03M2B**
- Revision: **1** / Review-Round: **0**
- Owner: Kimi / Reviewer: GPT
- Task Packet: `docs/tasks/G5-03M2B_RUNTIME_NARRATIVE_ACTOR_MATERIALIZATION_TASK.md`
- Canonical: `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`
- Depends-On: G5-03M2A — IR#2 PASS / CLOSED (`docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR2.md`)

- START_HEAD: `c3f17803e4039226249b454ba3fa4e44b17b9d4d`（两个 `main` 已刷新核验；Vibe-Coding `a9161955d919c27b31484ef849a6427b7e6cbc8c`）
- FINAL_HEAD: `306fe2e9b69b20dc916014583d924e73b16186c0`（implementation）+ evidence commit（见 git log）

## Changed files

- `src/世界回合/L1_器件层/语义变更响应解析器.gd` — optional `new_actor_candidates` 独立 fail-soft 解析。
- `src/世界回合/L0_公理层/世界回合规则.gd` — MW-001 常量与 runtime actor identity/record/replay-signal/candidate helper。
- `src/世界回合/L2_流程层/语义物化流程.gd` — analysis instructions/roster currentness、actor-only commit、durable replay marker。
- `tests/g5_03m2b/运行时叙事演员物化测试.gd` — 新建 focused deterministic suite。

无 Agency Scheduler/Cycle 生产代码改动；无 UI/SQLite schema/Public d20/Provider 配置改动。

## Requirement → implementation mapping

- **INV-01 既有 semantic lane only**：只扩展 `_on_completed` 的解析与候选构造；Provider 请求数不变（focused 断言 accepted 后 `requests.size() == 1`）。
- **INV-02 optional fail-soft 字段**：`SemanticChangeResponseParser.parse_new_actor_candidates`；absent → `[]`/`dropped=0`；non-array/坏条目只计入 `actors_dropped`，绝不 invalidate changes/knowledge；extraction 上限 `MAX_NEW_ACTOR_CANDIDATES_PER_TURN = 8`。
- **INV-03 candidate material only**：parser 只构造干净 `{display_name, profile_text}`；raw 值必须 `TYPE_STRING`（无 coercion），trim/非空/长度上限 64/1024（与 M2A creation-authored bounds 对齐）；模型给的 `local_character_id`/`asset_id`/`provenance`/`origin` 全部剥离；仅完全相同 material fail-soft dedupe，同名不同 profile 保持 distinct。
- **INV-04 选择语义归模型**：无 keyword gate/阈值/本体；instructions 只要求「叙事明确确立身份且有可信持续相关性的独立个体」。
- **INV-05 current roster in request**：`_analysis_messages` 改用 `Rules.actor_roster(world_state, _current_accepted_hashes())`；instructions 明确「不要提议已在 Allowed Stable Actors 列表中的人」；stale runtime actor 不进入 roster。
- **INV-06 Program-owned deterministic identity**：`Rules.runtime_actor_identities` 以 `runtime-actor|game_id|turn|hash|ordinal|display_name|profile_text` 的 SHA-256 派生 `character-runtime-<digest>`；无墙钟/随机；`build_runtime_actor_record` 产出 `{local_character_id, role:"stable_npc", origin:{kind:"runtime_narrative", source_turn_index, source_gm_sha256}, game_local_material}`，无任何 Source 字段。
- **INV-07 atomic semantic commit**：`Rules.build_world_candidate_with_actors` 把 actor records 追加进同一 semantic candidate；`commit_world_mutation_durably` 单一 mutation seam；actor-only 合法（record/knowledge_record 为 `{}` 时不伪造 changes）。
- **INV-08 failure isolation**：三类输出独立；全无有效 material 才走原 `no_changes`。
- **INV-09 replay/idempotence**：`_consider_entry` 新增 durable marker——`Rules.runtime_actor_ids_for_version` 发现同 accepted turn+hash 的 runtime actor 即返回 `already_materialized`（不依赖内存 `_attempted_versions`）；commit 前对同版本已存在的 deterministic ID 逐 candidate skip。focused 证明 fresh-worker（reopen-like）replay 零新请求、零第二身份。
- **INV-10 regenerate currentness**：stale 记录物理保留；roster/Knowledge allowlist/Agency eligibility/semantic request 全部走 accepted-hash 过滤（`_on_completed` 的 knowledge roster 校验同步改用 current hashes）。
- **INV-11 Knowledge boundary**：materialization 不产生任何 knowledge record；roster 校验在 commit 前的 world_state 上执行，不 guess/backfill 指向新 actor 的 knowledge；私有 Knowledge 不泄漏（focused 断言）。
- **INV-12 same-turn Agency visibility**：Scheduler/Cycle 零生产改动——M2A 已把 selector/eligibility/execution 接到 `stable_npc_records(world_state, accepted_hashes)`；focused 证明 semantic commit 后同一 dirty 机会 `_selector_request()` 含新 ID、`_validate_candidates([新ID])` 通过、`_actor_request(新ID)` 解析 `game_local_material`。
- **INV-13 no runtime Source lookup**：runtime ingress 为 Game-local；focused ControlledRuntime 不含任何 Source 对象；production diff `grep 游戏库|source_library|SourceLibrary` 零匹配。

## Focused results

`tests/g5_03m2b/运行时叙事演员物化测试.gd`（`--root=build/g5_03m2b_focused`）：

- **53 PASS / 0 FAIL**，覆盖 task §8 的 1–11：

1. valid runtime actor → Program-owned deterministic ID、exact origin turn/hash、bounded `game_local_material`、无假 provenance；
2. actor-only semantic result → 恰好一个 durable mutation，无伪造 changes/knowledge record；absent 字段保持旧行为；
3. malformed/non-array/坏条目 actor 字段 → 不损伤 otherwise valid changes，registry 不变；
4. 非字符串 display/profile → 丢弃，不 coerce；
5. 同 accepted 版本 same-worker 与 reopen-like replay → 零第二请求、零第二 actor/身份（actor-only durable marker）；
6. regenerate hash mismatch → stale actor 物理保留、current registry/roster/Agency eligibility/selector request 全部失效；
7. production Save → head 前进 → Restore → close/reopen → exact runtime actor 记录与 Program-owned ID 原样保持；
8. semantic commit 后同一 dirty 机会 selector request 可见新 ID、eligibility 接受、actor execution 解析 material；
9. materialization 不自动授予 Knowledge；他者私有 Knowledge 不泄漏；
10. 无 runtime Source lookup（结构 + diff grep）；
11. request 含 current roster 与不重复提议指引；stale actor 被 accepted-hash currentness 排除。

## Minimal affected regressions（focused 绿后一次性）

- G5-01 `世界回合语义物化测试.gd`：**0 FAIL**；
- G5-01 `世界回合时间线恢复测试.gd`：**0 FAIL**；
- G5-02 `已知角色知识溯源测试.gd`：**0 FAIL**；
- G5-03 `多角色行动代理循环测试.gd`（M1 dirty/wake/selector 保护，§8-12）：**0 FAIL**；
- G3-04 `存档恢复持久化测试.gd`：**PASS**。

## Hygiene

- `git diff --check`：clean。
- Real Provider calls：**0**（全部 deterministic stub）。父级 G5-03 real Provider proof 保持 `PENDING / EXTERNAL PROVIDER UNAVAILABLE`。
- M2A 与 Multi-Actor Agency v0.3 protected behavior 未重开：无 Scheduler/Cycle/scheduling/dirty 语义改动；semantic `agency_candidates` 未恢复使用。

## Status

**READY FOR INDEPENDENT REVIEW**
