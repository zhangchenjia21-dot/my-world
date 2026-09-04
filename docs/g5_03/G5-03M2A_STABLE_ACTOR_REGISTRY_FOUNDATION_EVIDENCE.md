# G5-03M2A Stable Actor Registry Foundation — Evidence

Status: **READY FOR INDEPENDENT REVIEW**（Revision 2 / IR#1 correction）
Task: `docs/tasks/G5-03M2A_STABLE_ACTOR_REGISTRY_FOUNDATION_TASK.md`
Canonical: `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`
Review: `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR1.md`

- START_HEAD: `c12913bb86bd07ccf23fec2f10fbaad85291a310`（Vibe-Coding 基线 `3deff5d9`）
- Revision 1 implementation: `34d4316`
- Revision 2 base: `61a3f182907d28b46e50150aed97a1f162b9fb25`（Vibe-Coding `9b71680b`）
- FINAL_HEAD: `e0f4b9a`（Revision 2 implementation）+ 本 evidence 更新提交

## Revision 2 — IR#1 focused correction

| Finding | 修正 |
| --- | --- |
| IR1-F01 string contract | `_canonicalize_game_local_npcs`：raw `display_name`/`profile_text` 先确证 `TYPE_STRING`，非字符串直接 `invalid_composition` 拒绝；之后才 trim/非空/长度校验；不再 `String(...)` coerce 任意值。 |
| IR1-F02 Restore proof | focused 证明 9 改走 production Restore path：`create_save_point`（含 creation-time registry 的 snapshot）→ durable mutation 前进 head → `restore_save_point` → 断言 `stable_npcs` records 与 Program-owned ID 原样保持、head 回到 snapshot、close/reopen 后仍保持。未暴露 persistence defect，未加任何 registry-specific persistence/schema/migration。 |

Revision 2 改动文件：`src/最终建局/L0_公理层/最终建局规则.gd`、`tests/g5_03m2a/稳定演员注册表基础测试.gd`（新增 2 条 non-string 拒绝断言 + Restore 路径 5 条断言）。

Revision 2 验证：

- `tests/g5_03m2a/稳定演员注册表基础测试.gd`：**68 PASS / 0 FAIL**（含 non-string `display_name`/`profile_text` 分别拒绝、production Restore 后 registry/ID 原样保持）；
- 最小 affected regression：G4-06 原子最终建局现实 **0 FAIL**；G3-04 存档恢复持久化 **PASS**；
- `git diff --check` 干净；real Provider calls = 0；
- 未触碰 v0.3 scheduling / M2B / G5-04 / UI / SQLite schema / Public d20。

以下为 Revision 1 evidence（保持原样）。


## 1. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/最终建局/L0_公理层/最终建局规则.gd` | optional `game_local_npcs` canonicalize（missing→[]，bounded 非空 display_name/profile_text，上限 8/64/1024，无 display-name dedupe）；`validate_intent` 对 optional `stable_npcs` 做形状/identity 一致性校验（缺失合法、非空唯一 local ID、不与 Player/Guaranteed 冲突）。 |
| `src/最终建局/L2_流程层/原子最终建局流程.gd` | 首次 intent 构建时一次扫描 validated current Character inventory：仅 `exact_profile`、排除 Player/Guaranteed asset_id、按 exact Source identity 排序、冻结 exact pin + T0 projection；creation-authored 记录只带 `game_local_material`；两者写入 `initial_setup.stable_npcs[]`（`guaranteed_npcs[]` 保持 distinct）。resume 路径不重扫。 |
| `src/建局/L1_器件层/建局Composition状态器.gd` / `src/建局/L3_外交层/建局公开接口.gd` | optional additive `game_local_npcs` 输入入口（无 UI）。 |
| `src/世界回合/L0_公理层/世界回合规则.gd` | 统一 helper：`stable_npc_records(world_state, accepted_hashes)`（Guaranteed + creation stable + `runtime_narrative` currentness 契约预留；空/重复 local ID deterministic fail-soft）、`stable_actor_material(record)`（source_projection ↔ game_local_material 两 family）、`actor_roster` 扩展签名（旧单参调用保持有效）。 |
| `src/世界回合/L2_流程层/行动代理调度流程.gd` | selector roster/eligibility 改用 `stable_npc_records` + `stable_actor_material`（Player 永不 eligible）。v0.3 scheduling 语义未动。 |
| `src/世界回合/L2_流程层/行动代理循环流程.gd` | `_npc_for` 按 exact local ID 在统一 registry 解析；`_actor_request` 经 `stable_actor_material` 支持两种 material family（Source sections 或 Game-local profile_text）；Knowledge/Agency history 隔离不变。 |
| `tests/g5_03m2a/稳定演员注册表基础测试.gd` | 新 focused suite（9 组证明，61 断言）。 |

未改动：语义物化流程（`actor_roster` 自动获得新 roster）、persistence schema/SQLite、UI、Source schema、Public d20、M2B `new_actor_candidates`、G5-04。

## 2. Requirement → 实现映射

| Task §3 | 实现 |
| --- | --- |
| A optional no-Card 输入 | `最终建局规则.gd::_canonicalize_game_local_npcs`；missing→[]；bounded 校验 fail-closed |
| B automatic Source-backed snapshot | `原子最终建局流程.gd::_source_backed_stable_npcs`（仅首次 intent；exact_profile；排除 Player/Guaranteed asset；identity 排序；冻结 pin+T0） |
| C Program-owned identity | `_identity("character")` 程序铸造；两 family 记录入 `stable_npcs[]`；无 display-name identity |
| D 统一 helper | `世界回合规则.gd::stable_npc_records/stable_actor_material/actor_roster` |
| E 消费者 | Knowledge roster（`actor_roster` 自动）、selector eligibility、actor execution 均走统一 helper |
| F 旧 Game 兼容 | missing `stable_npcs`→[]；helper 只读 world_state（结构性无 Source lookup）；`validate_intent` 对缺失合法 |

## 3. Focused 结果

`tests/g5_03m2a/稳定演员注册表基础测试.gd`（`--root=build/g5_03m2a_focused`）：**61 PASS / 0 FAIL**。

关键证据点：

- identity：Source-backed 记录 = Program local ID + exact pin（4 PIN_FIELDS，含 generation_fingerprint）+ frozen T0 `source_projection.selected_profile=han-208`；no-Card 记录无 `provenance`/`source_projection` 键；同名「陈安」两条记录获得 distinct local ID；stable ID 不与 Player/Guaranteed 冲突。
- persistence：reopen 保留 registry ID；durable mutation 后 reopen 仍保留（head 正常前进到 `m2a-registry-node`）。
- Knowledge：`actor_roster` 含 Player + Guaranteed + Source-backed + creation-authored；no-Card actor 收到 own committed Knowledge，另一 actor 不可见。
- Agency：`_validate_candidates([player, source_backed, authored, unknown])` → 只余两个 stable ID；Player/unknown 被排除。
- retry authority：曹操补绑 220 + 孙权新代次成为 current 后，同 creation_id resume 仍只含冻结孙权记录（旧 fingerprint、旧 local ID）。

## 4. Affected regression（focused 绿后一次通过）

| 套件 | 命令（headless） | 结果 |
| --- | --- | --- |
| G4-06 原子最终建局现实 | `--script res://tests/g4_06/原子最终建局现实测试.gd -- --root=build/g4_06_m2a_regress` | 0 FAIL |
| G4-06 创建失败窗口重启 | `--script res://tests/g4_06/创建失败窗口重启测试.gd -- --root=build/g4_06_m2a_regress_window` | 0 FAIL |
| G4-06 创建冲突与发布失败 | `--script res://tests/g4_06/创建冲突与发布失败测试.gd -- --root=build/g4_06_m2a_regress_conflict` | 0 FAIL |
| G5-02 已知角色知识溯源 | `--script res://tests/g5_02/已知角色知识溯源测试.gd` | 0 FAIL |
| G5-03 多角色行动代理循环 | `--script res://tests/g5_03/多角色行动代理循环测试.gd` | 0 FAIL |
| G3-04 存档恢复持久化 | `--script res://tests/g3_04/存档恢复持久化测试.gd -- --root=build/g3_04_m2a_regress` | PASS |

注：首轮并行执行时 G4-06 现实测试在 fixture 安装步报了一次失败；改为顺序执行后同一命令两次全绿，判定为并行 Godot 实例争用而非代码回归。

`git diff --check` 干净。真实 Provider 调用 = 0。未执行 superseded M2 packet；未开始 M2B/G5-04。
