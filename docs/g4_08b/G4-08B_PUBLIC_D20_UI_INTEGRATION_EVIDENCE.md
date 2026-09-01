# G4-08B — Public d20 UI / Interaction Integration Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-01
Task packet: `docs/tasks/G4-08B_PUBLIC_D20_UI_INTEGRATION_TASK.md`（packet commit `72da819`）
Formal Code Base: `d646427dfe3c4c6328809384e482cd1fdd2204a0`
Mechanism authority: `docs/g4_08m1/G4-08M1_INDEPENDENT_REVIEW.md` + `G4-08M1C01_INDEPENDENT_REVIEW.md` + `src/行动判定/L3_外交层/行动判定公开接口.gd`
Pre-implementation matrix: `docs/tasks/G4-08B_UI_STATE_FAILURE_MATRIX.md`

> 本任务只证明 UI/交互垂直。**不声明 G4-08 PASS**；G4-09 与 G4-GATE 仍需后续门禁。
> Backend 只读约束全程遵守（见 §6 改动清单）。

---

## 1. 范围与改动

允许范围内改动（`src/ui/新游戏向导.gd`、`src/ui/叙事对话视图.gd`、`src/main.tscn`、`src/应用壳.gd` + 测试/文档）：

| 文件 | 改动 |
| --- | --- |
| `src/ui/新游戏向导.gd` | 拓展步从 `none only` 占位改为真实库存投影：`expansions` 独立存储、0..N 显式选择（CheckButton）、无 auto-select；`set_expansion()` 权威 + slot 冲突拒绝时 toggle 回滚 + 玩家可读失败；`confirm_expansion_none()` 为显式 none；Review 投影显示 `• 判定与检定：公开 d20（0.1.0）` 或 `无`。 |
| `src/ui/叙事对话视图.gd` | 新增 `action_adjudication` Host 注入 + `bind_action_adjudication()`；`_on_send_pressed` 在 capability 存在时路由 Host（不先调 `conversation.begin_turn`）；stable `action-<128bit hex>` 铸造一次，失败/取消/重开重试复用，编辑替换才铸新 id；`_on_adjudication_stage_started` 捕获 `resolution_narrative` 并立即公开 transient 卡；`_handle_adjudication_result` 统一处理终态（accepted/already_accepted/failure）；`_recover_pending_d20_action` 重开门控（恰好一个未完成 → 锁输入 + 「重试行动」；>1 → 显式失败）；`_append_mechanic_card` 只读投影 durable check；`_render_restored_entries` 按 `accepted_turn_index` 重建历史卡；`_update_controls` 在 d20 会话禁用 legacy Regenerate、失败时只显示「重试行动」；`shutdown_session` 拆除 Host 连接。 |
| `src/main.tscn` | 新增 `ActionStatusPanel`（NarrativeColumn 内）：行动状态 label + 「重试行动」按钮。 |
| `src/应用壳.gd` | `_prepare_action_adjudication_after_activation`：只读 `world_state.expansions[]` 的 `capability_slot/capability_id`，匹配 `action_check.public_d20.v1` 时挂载 Host 并注入 View；`_teardown_action_adjudication` 随 Session 拆除；测试 seam `test_adjudication_adapter_override` / `test_adjudication_rng_override`（production 恒 null）。 |

新增测试：

- `tests/g4_08b/公开D20界面整合测试.gd`（headless，桩 Provider + deterministic RNG，**78 断言 / 0 FAIL**）
- `tests/g4_08b/公开D20界面窗口布局测试.gd`（三窗口尺寸 × 五 UI 状态截图，**0 FAIL**）
- `tests/g4_08b/真实公开D20界面垂直测试.gd` + `运行真实DeepSeek公开D20验证.ps1`（真实 DeepSeek Han d20 垂直，**0 FAIL**）

## 2. 粘接决策（提请 GPT Independent Review 注意）

1. **能力路由只读 Game-local**：Shell 激活时检查 `world_state.expansions[]` 的 `capability_slot == "action_resolution"` 且 `capability_id == "action_check.public_d20.v1"`；永不读 `SourceLibrary.current`。Legacy（无 Expansion）Game 不匹配，行为不变。
2. **测试 seam 复用 G4-07B 形状**：`test_adjudication_adapter_override` + `test_adjudication_rng_override` 在激活前注入桩/受控 adapter；production 恒 `null`。
3. **transient 卡与历史卡同源**：两者都从 `world_state.expansion_runtime.public_d20_checks` 的 durable record 投影；transient 仅在 `resolution_narrative` 阶段额外渲染，accepted 后由 `_render_restored_entries` 按 `accepted_turn_index` 重建接管。
4. **重开恢复边界**：UI 只读 `narrative_accepted == false` 的记录数与 `action_id/player_text`；不读取、不修改其它字段。
5. **玩家可读失败码映射**：`capability_slot_conflict` →「两个拓展占用同一判定位置」；判定失败 →「行动未完成」+「重试行动」；原始 code 不进 UI 文本。

## 3. 自动化矩阵结果（headless，桩 Provider + deterministic RNG）

`tests/g4_08b/公开D20界面整合测试.gd`：**0 FAIL**（`--root` 含 `g4_08b`，task-owned）。

| 证据 | 案例 | 结果 |
| --- | --- | --- |
| **A** Wizard 库存 | 展示 Public d20 名称/版本/简介；无 auto-select；显式 none 有效；选择往返保留；Review 显示 exact 名称/版本；Final Create 收到 frozen exact identity（含 generation_fingerprint） | PASS |
| **B** 兼容性 UI | 同 slot 冲突 Expansion 被 backend 拒绝；UI toggle 回滚；玩家可读失败；原选择保留 | PASS |
| **C** 无 Expansion 回归 | 真实 UI 路径建局；无 adjudication Host；无机制卡；G4-07 单次续玩 + legacy Regenerate 保留 | PASS |
| **D** 受检行动 | 单 stable action_id；UI 不先调 begin_turn；CHECK_REQUIRED 冻结/掷骰经 M1 Host；transient 卡先于 narrative 完成出现；accepted 历史含 exact durable 卡（DC 15/骰面 7/总计 7/失败）；UI 不重算 | PASS |
| **E** NO_CHECK | 一次 Provider 调用、零 RNG、无骰卡、accepted 恰一次、普通叙事外观 | PASS |
| **F** 重试/no-reroll | durable 败检后 narrative 失败 → 仅「重试行动」+锁编辑；同 action_id/text 重试不重掷（requests=3 含 adjudication+narrative+narrative retry，rng=1）；accepted 恰一次；判定期失败可编辑替换并铸新 id | PASS |
| **G** 重开未完成行动 | 恰好一个 unresolved → 门控输入 +「上一次行动尚未完成」+「重试行动」；同 durable action_id 恢复；不重掷、无额外判定；accepted 后解锁 | PASS |
| **H** Continue/Load 卡重建 | Continue 重建 accepted 卡且数值精确；Load 回 check 前移除未来卡；restored canonical reality 无未来 check 记录 | PASS |

## 4. 真实 DeepSeek 垂直（非 headless，1280×720）

运行器：`tests/g4_08b/运行真实DeepSeek公开D20验证.ps1`（白名单加载 `.env.local` 的 `DEEPSEEK_API_KEY` / `MY_WORLD_DEEPSEEK_MODEL`，不打印、finally 恢复环境）。
测试：`tests/g4_08b/真实公开D20界面垂直测试.gd` → **0 FAIL**。
证据 JSON：`build/g4_08b/real-vertical/real-vertical-evidence.json`（不含 key）。

| 案例 | 结果 |
| --- | --- |
| Han 208｜赤壁前夕 + 刘备 + 孙权 + Public d20 | 真实 Opening accepted；风险行动自然触发 CHECK_REQUIRED（stable action_id）；Program 结果 durable（DC 24 / 总计 14 / 失败）并在 narrative 完成前 transient 公开；GM continuation 尊重 outcome；后续普通行动 NO_CHECK 无骰卡。 |

截图（`build/g4_08b/real-vertical/shots/`）：`han-d20-review / han-d20-opening / han-d20-check-transient / han-d20-check-accepted / han-d20-no-check` —— 逐张目检：Review 显示拓展、Opening streaming、受检行动后 accepted 卡、NO_CHECK 后无新卡。

## 5. Windows 多尺寸 UI 证据

`tests/g4_08b/公开D20界面窗口布局测试.gd`（桩 Provider + deterministic RNG）：headless **0 FAIL**；真实窗口运行 **0 FAIL** 并产出 15 张截图（`build/g4_08b/layout-real/shots/`）：

- 1280×720 / 960×540 / 最大化 × 拓展步选择 / Review 含拓展 / 受检 transient 卡 / Playing 含 accepted 卡 / 失败重试 banner。
- 逐张目检：卡可从叙事区分但次级、960×540 窄窗口按钮可达、最大化正文限宽居中。

## 6. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08M1 公开D20机制 | 0 FAIL |
| G4-08M1C01 NO_CHECK 幂等 | 0 FAIL |
| G4-05 建局Composition / 应用向导现实 / 全保真现实 / 历史 v0.1 锚点 | 0 FAIL |
| G4-05 向导窗口布局 | headless + 真实窗口 0 FAIL |
| G4-06 原子建局 / 冲突与发布失败 / 失败窗口重启 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G2-03 视图离线 / G2-04 域 / G2-05 上下文 | 0 FAIL |
| G3-03 会话恢复与候选 | 0 FAIL |
| G4-01 生命周期 / 入口布局 | 0 FAIL |
| G4-04 多游戏生命周期 / 游戏库元数据 / Legacy 采用与恢复隔离 | 0 FAIL |

Backend 只读约束：`src/source/**`、`src/最终建局/**`、`src/persistence/**`、`src/行动判定/L0_公理层/**`、`src/行动判定/L1_器件层/**`、`src/行动判定/L2_流程层/**` 零改动（git diff 可证）。Production schema 保持 v4，无迁移。

## 7. 已知边界（非缺陷）

- d20 会话的 accepted turn 不出现 legacy Regenerate；失败只有「重试行动」（同一 stable identity）。
- 判定期失败（无 durable resolution）允许编辑替换；编辑后铸新 action_id。
- 真实 DeepSeek 生成时长取决于网络；测试超时上限 600s/阶段。

## 8. 结论

G4-08B 工程垂直（Wizard Expansion 库存/选择 → Review 投影 → Game-local capability 路由 → stable action_id 生命周期/重试 → public mechanic-card 投影 → Continue/Load 重绘）在 stub 矩阵与真实 DeepSeek 双轨道上全部通过。**返回上限：READY FOR INDEPENDENT REVIEW**。G4-08 PASS 仍需 GPT Independent Review + G4-09 + Owner UAT B。
