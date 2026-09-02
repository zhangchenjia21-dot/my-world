# G4-09R1B1 — Model Settings UI / Interaction Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-02
Task packet: `docs/tasks/G4-09R1B1_MODEL_SETTINGS_UI_TASK.md`
Canonical decision: `Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`
Accepted backend review: `docs/g4_09r1/G4-09R1M1C01_INDEPENDENT_REVIEW.md`
Pre-implementation matrix: `docs/tasks/G4-09R1B1_UI_STATE_FAILURE_MATRIX.md`

> 本任务只证明 UI/交互垂直。**不声明 G4-09R1/G4-09/G4-08 PASS**；不恢复 G4-09UATB。

---

## 1. 范围与改动

| 文件 | 改动 |
| --- | --- |
| `src/main.tscn` | Main Menu 新增「模型设置」按钮；新增 `ModelSettingsOverlay` 常驻隐藏面板（与 StartupFailureOverlay 同层）：模型/上下文上限/思考强度三个 OptionButton、说明 note、凭证状态 label、实际配置摘要 label、结果 label、保存/取消按钮。 |
| `src/应用壳.gd` | 设置面板全部逻辑：`_show_model_settings`（加载 persisted validated selection；invalid persisted 以冻结默认作编辑起点 + 可恢复玩家可读状态）；`_refresh_settings_projection`（**只走 backend `inspect_candidate`**，不复制 provider 政策）；`_on_settings_save_pressed` / `_on_settings_cancel_pressed`；`_model_settings_path()`（`--settings-path=` / `MY_WORLD_TEST_SETTINGS_PATH` / 默认空 = backend 默认路径）。 |

新增测试：

- `tests/g4_09r1b1/模型设置界面整合测试.gd`（headless，task-owned settings path，**44 PASS / 0 FAIL**）
- `tests/g4_09r1b1/模型设置界面窗口布局测试.gd`（三窗口尺寸 × 四 UI 状态截图，**0 FAIL**）
- `tests/g4_09r1b1/真实模型设置界面验证.gd` + `运行真实模型设置验证.ps1`（真实 DeepSeek + Kimi，**0 FAIL**）

## 2. inspect_candidate 消费（UI 唯一真相来源）

UI 预览未保存候选**只**调 `model_settings.inspect_candidate(candidate)`；返回的投影驱动：

| 投影字段 | UI 消费 |
| --- | --- |
| `display_name` | 模型行标题 / 摘要 |
| `allowed_context_limits` | 上下文 OptionButton 禁用集（K2.7 = `["256k"]` → 1M 禁用） |
| `reasoning_requested` / `reasoning_effective` | Medium 时摘要显示「Medium（实际 High）」；不一致才披露 |
| `graded_reasoning` / `fixed_thinking` | K2.7 思考强度控件禁用 + 「固定 Thinking ON」说明 + 摘要「固定思考」 |
| `credential_configured` | 选中 provider 凭证缺失时显示「保存后生成将失败」警告 |
| inspect 失败（`incompatible_context_limit` 等） | 禁 Save + 玩家可读说明 + 按 catalog 允许集禁用 context 选项 |

UI **不**自行推导 endpoint / model_id / request payload / 兼容性 / requested→effective 映射。

## 3. 自动化矩阵结果（headless，task-owned settings path）

`tests/g4_09r1b1/模型设置界面整合测试.gd`：**44 PASS / 0 FAIL**。

| packet §10 | 案例 | 结果 |
| --- | --- | --- |
| 1 | Main Menu 有「模型设置」，打开/关闭正确 | PASS |
| 2 | 四个精确模型名可见 | PASS |
| 3 | save/cancel 行为（Cancel 不写文件；Save 调 backend 持久化） | PASS |
| 4 | 重开/重启反映 persisted 选择（含新实例 backend 重载） | PASS |
| 5 | K2.7 从 backend 投影禁 1M | PASS |
| 6 | K2.7 固定思考 UX（控件禁用 + 说明 + 摘要「固定思考」） | PASS |
| 7 | Medium→High 披露（DeepSeek/K3 摘要「Medium（实际 High）」；Max 不披露） | PASS |
| 8 | 凭证状态无秘密（DeepSeek/Kimi 已配置/未配置；不含 key 值/KEY 字样） | PASS |
| 9 | 非法组合不可保存（K2.7+1M inspect 失败 + save 禁用 + 不覆盖 saved state） | PASS |
| 10 | 设置不改 Game/Source（Game DB 无 kimi_k3 字样；world_state 保存前后一致） | PASS |
| 11 | 设置后 Continue/New Game 可用 | PASS |
| 12 | G4-08B Public d20 UI 回归 | PASS（见 §5 回归地板） |
| 13 | 1280×720 / 960×540 / maximized 布局 | PASS（见 §4） |
| 14 | `git diff --check` | 干净 |

## 4. Windows 多尺寸 UI 证据

`tests/g4_09r1b1/模型设置界面窗口布局测试.gd`：headless **0 FAIL**；真实窗口 **0 FAIL**，12 张截图（`build/g4_09r1b1/layout-real/shots/`）：

- 1280×720 / 960×540 / 最大化 × Main Menu 入口 / 设置面板 / K2.7 固定思考态 / 保存后回 Main Menu。
- 逐张目检：面板不超视口、凭证警告换行正常、K2.7 说明可见、按钮可达。

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08B 公开D20界面整合 | 96 PASS / 0 FAIL |
| G4-08M1 公开D20机制 / M1C01 NO_CHECK 幂等 | 0 FAIL |
| G4-09R1 运行时模型设置机制 | 0 FAIL |
| G4-05 应用向导现实 / 建局Composition / 全保真现实 | 0 FAIL |
| G4-06 原子建局 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G2-03 视图离线 / G2-04 域 / G2-05 上下文 | 0 FAIL |

Backend 只读约束：`src/运行时设置/**`、`src/provider/**`、`src/source/**`、`src/最终建局/**`、`src/persistence/**`、`src/行动判定/**` 零改动（git diff 可证）。Production schema 保持 v4。

## 6. 真实集成（真实 DeepSeek + Kimi）

运行器：`tests/g4_09r1b1/运行真实模型设置验证.ps1`（白名单加载 `.env.local` 的 `DEEPSEEK_API_KEY` / `KIMI_API_KEY` / `MY_WORLD_DEEPSEEK_MODEL`，不打印、finally 恢复环境）。
测试：`tests/g4_09r1b1/真实模型设置界面验证.gd` → **0 FAIL**。
证据 JSON：`build/g4_09r1b1/real-settings/real-settings-evidence.json`（不含 key）。

| 案例 | 结果 |
| --- | --- |
| DeepSeek V4 Pro | 真实 Main Menu 设置面选择 + 持久化（profile_id = `deepseek_v4_pro`）；建局后真实 Opening 生成 492 字 accepted。 |
| Kimi K3 | 真实 Main Menu 设置面选择 + 持久化（profile_id = `kimi_k3`）；建局后真实 Opening 生成 641 字 accepted。 |

截图（`build/g4_09r1b1/real-settings/shots/`）：`settings-deepseek / generation-deepseek / settings-kimi / generation-kimi` —— 逐张目检：设置面投影正确、真实生成叙事丰富。

## 7. 已知边界（非缺陷）

- 设置只进 Main Menu；无游戏内抽屉/热键（packet §2）。
- 缺失凭证可保存但警告；不发明 fallback（packet §5）。
- 保存后下一次生成即生效（Provider adapter 每请求 `request_snapshot()`）；无需重启。

## 8. 结论

G4-09R1B1 工程垂直（Main Menu 模型设置入口 → inspect_candidate 预览 → K2.7 禁 1M/固定思考 → Medium→High 披露 → 凭证状态 → save/cancel/restart → 真实 DeepSeek + Kimi 生成）在 stub 矩阵与真实 Provider 双轨道上全部通过。**返回上限：READY FOR INDEPENDENT REVIEW**。G4-09R1 PASS 仍需 GPT Independent Review + final real Provider/freshness integration pass。
