# G5-02M1C01 — Actor Roster + Recent Knowledge Projection Correction Evidence

Status: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**
Date: 2026-09-03
Correction packet: `docs/tasks/G5-02M1C01_ACTOR_ROSTER_RECENCY_CORRECTION_TASK.md`
Parent IR: `docs/g5_02/G5-02M1_INDEPENDENT_REVIEW.md`
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`

> 本修正只关闭 GPT IR 指出的三个具体缺陷。**不声明 G5-02 PASS**；不开始 G5-03。**未执行任何真实 Provider 调用**——父任务的一次 bounded attempt 已消耗且超时，real vertical 保持 PENDING。

---

## 1. 交付标识

- START_HEAD：`492815aefd127c20bd17fbda892aad8d41279dcb`（G5-02M1 已评审实现）
- 实现/证据 HEAD：见 FINAL HEAD（push 后回填）
- 证据文档：本文件

## 2. 修正内容（对应 IR 三个 findings）

### 修正 1 — 语义请求提供 stable actor roster

`src/世界回合/L2_流程层/语义物化流程.gd::_analysis_messages()` 现在把当前 Game-local roster 加入**同一次** semantic-analysis request（不新增第二次 Provider 调用）：

```text
Allowed Stable Actors
- 刘备 | char-player-001
- 孙权 | char-npc-002
```

- roster 来自既有 `Rules.actor_roster(session_runtime.world_state)` seam（只读 `player_character.local_character_id` + `guaranteed_npcs[*].local_character_id` 及其 display name）；
- `ANALYSIS_INSTRUCTIONS` 明确：`knower_id` 必须且只能来自 Allowed Stable Actors 列表；不推断阵容成员知情；不编造 ID；不输出推理；
- 不发送整个 Source/Game Context 来解决 ID 解析。

### 修正 2 — bounded 知识投影保留最新事件

`src/世界回合/L1_器件层/世界回合上下文投影器.gd::_project_knowledge()` 改为 newest-first 选择：从最新 matching 记录向前消费 `MAX_KNOWLEDGE_EVENTS_PROJECTED`（8），淘汰 bounded-old 事件；渲染时按 `turn_index` 升序保持同 actor 内时间序可读。actor 上限（8）与字符上限（16000）不变；不构建 G7 检索。

### 修正 3 — real-provider harness 真实性

`tests/g5_02/真实Provider知识溯源验证.gd` 现在结构性要求 feature-specific PASS 必须满足：

- ordinary Narrative accepted；
- semantic analysis terminal success（`committed`，不再接受 `no_changes`）；
- 至少一个 committed 有效 knowledge event 且 `knower_id` 属于 stable roster；
- 后续 assembled Context 包含 `Actor Knowledge Provenance` 且包含已提交 fact。

**未执行**该 harness——父任务的一次真实 attempt 已消耗且超时。

## 3. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/世界回合/L2_流程层/语义物化流程.gd` | `_analysis_messages` 加 roster block；`ANALYSIS_INSTRUCTIONS` 加 roster 约束。 |
| `src/世界回合/L1_器件层/世界回合上下文投影器.gd` | `_project_knowledge` 改为 newest-first 选择 + 渲染时时间序。 |
| `tests/g5_02/已知角色知识溯源测试.gd` | 新增 C01-1/2/3/7 四组断言（共 16 项新断言）。 |
| `tests/g5_02/真实Provider知识溯源验证.gd` | 收紧：要求 committed + 非空 roster 知识事件 + Context 含 provenance section 与 fact；不再接受 no_changes/空知识/仅组装成功。 |

未改动：`src/domain/会话.gd`、`src/ui/**`、persistence schema/migrations、Source schema/generation、Runtime Model Settings、Public d20、G5-03/G5-04/G6/G7。

## 4. 自动化矩阵结果（headless）

`tests/g5_02/已知角色知识溯源测试.gd`：**40 PASS / 0 FAIL**（原 24 + C01 新增 16）。

| C01 packet 断言 | 结果 |
| --- | --- |
| 1. 语义请求含 exact Player + Guaranteed NPC display-name/local-ID roster | PASS |
| 2. 不加入 incidental/unknown actor | PASS |
| 3. >8 matching 事件选择最新并淘汰 bounded-old | PASS（最新事件在、最老两个不在、恰好 8 个、渲染时间序） |
| 4. 既有 G5-02 A–F focused 保持绿 | PASS |
| 5. G5-01 focused + Timeline 回归保持绿 | PASS |
| 6. 直接受影响 continuation Context 回归保持绿 | PASS（G2-05 / G4-07A / G4-07B / G4-08B） |
| 7. real harness 结构性要求非空有效知识证明（未执行） | PASS（源码断言证明） |
| 8. `git diff --check` | 干净 |

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G5-02 已知角色知识溯源（C01 强化后） | 40 PASS / 0 FAIL |
| G5-01 世界回合语义物化 | 0 FAIL |
| G5-01 世界回合时间线恢复（fresh root） | 0 FAIL |
| G2-05 上下文组装离线 | 0 FAIL |
| G2-04 会话域离线 | 0 FAIL |
| G3-03 会话恢复与候选 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08B 公开D20界面整合 | 127 PASS / 0 FAIL |

Backend 只读约束：`src/domain/会话.gd`、`src/ui/**`、persistence schema/migrations、Source schema/generation、Runtime Model Settings、Public d20、G5-03+ 零改动；SQLite schema 保持 v4。

## 6. 真实 Provider 调用声明

**本次修正未执行任何真实 Provider 调用。** 父任务 G5-02M1 的一次 bounded real selected-Provider attempt 已在 2026-09-03 消耗并于 ordinary Narrative 超时；real G5-02 vertical 保持 `PENDING / EXTERNAL PROVIDER UNAVAILABLE`。未切换 Provider、未加 fallback、未做第二次 attempt。

## 7. 结论

G5-02M1C01 修正关闭了 GPT IR 指出的三个缺陷：语义请求提供 stable actor roster、bounded 知识投影保留最新事件、real harness 结构性要求非空有效知识证明。**返回上限：READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**。GPT 拥有 Independent Review 与 G5-02 closeout。
