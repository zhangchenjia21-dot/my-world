# G4-07B — Playable UI Integration Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-08-31
Task packet: `docs/tasks/G4-07B_PLAYABLE_UI_INTEGRATION_TASK.md`（packet commit `064ae8b27d2169f8399e81a36a7d7624efe45fdd`）
Formal Code Base: `fdb6a30ad138c332837f17af1d8c74b5643db44b`
START_HEAD: `1e3db26bcf17956d6f03cc57f5f6c130108b0cb1`
Pre-implementation matrix: `docs/tasks/G4-07B_UI_STATE_FAILURE_MATRIX.md`

> 本任务只证明 UI/接线垂直。**不声明 G4-07 Product PASS**；G4-07 仍需 Owner UAT。
> Production SQLite schema 保持 v4；backend 只读约束全程遵守（见 §6 改动清单）。

---

## 1. 范围与改动

允许范围内改动（`src/应用壳.gd`、`src/main.tscn`、`src/ui/**` + 测试/文档）：

| 文件 | 改动 |
| --- | --- |
| `src/ui/新游戏向导.gd` / `.tscn` | `CreatePlaceholderButton` → `FinalCreateButton`（真实创建动作）；新增 `final_create_requested(creation_id, composition)` 信号；一次 frozen Review attempt 固定一个 `creation_id`（Crypto 16 字节随机），双击/失败重试复用，payload key 变更（返回修改）才铸新 attempt；`_create_in_progress` 防重入 + `_create_completed` 成功后锁定；失败回填玩家语言重试态。`_clear_choices` 改为 remove_child + queue_free（同帧重建不占用旧节点名）。 |
| `src/应用壳.gd` | `_on_final_create_requested`：用 G4-06 `FinalCreate.create_or_resume` 创建；成功 → `open_registered_game(game_id)`（**existing-only**，复用 G4-04 既有 seam）；创建失败 → Wizard 玩家语言重试；打开失败 → Game 保留 + 主菜单提示「继续游戏」重试。`_prepare_opening_after_activation`：`world_state.schema_version == game_local_setup.v0.1` 时挂载 G4-07A `FirstOpening`（含玩家回合 continuation seam）；durable accepted = 0 时锁输入并自动开始第一幕；已 accepted 绝不自动二次开场。Opening banner 状态机（streaming / failed / cancelled / accepted，幂等终态处理）。`_creation_root()`：`--creation-root=` / `MY_WORLD_TEST_CREATION_ROOT` / 固定 `user://my-world/creation-protocol`。 |
| `src/main.tscn` | 新增 `OpeningBanner`（TopBar 与 HostLayout 之间）：说明 label + 取消第一幕 / 重试第一幕。 |
| `src/ui/叙事对话视图.gd` | `bind_opening_runtime()` + `_opening_gate`（opening-pending 锁输入）；GM-only Opening 渲染：`attempt_started` 在 `_current_gm_content == null` 时建「GM · 开场」块，empty `pending_player_text` 永不渲染玩家气泡；恢复重建同样跳过空气泡；`_start_request` 在 opening_runtime 注入时走 `assemble_continuation_messages()`（durable Game-local World + durable Conversation），组装失败 fail-loud 不回退；取消路由到 opening adapter；Opening turn 不显示「重新生成」（重试归 banner），失败 marker/错误文案指向「重试第一幕」。 |

新增测试：

- `tests/g4_07b/可玩界面整合测试.gd`（headless，stub Provider，61 断言）
- `tests/g4_07b/可玩界面窗口布局测试.gd`（三窗口尺寸 × 四 UI 状态截图）
- `tests/g4_07b/真实可玩垂直测试.gd` + `运行真实DeepSeek可玩垂直验证.ps1`（真实 DeepSeek，Han + Afterglow）

## 2. 粘接决策（提请 Independent Review 注意）

1. **Shell 以 `world_state.schema_version == "game_local_setup.v0.1"` 字面量路由是否挂载 opening runtime**。该 schema 由 durable setup 自声明，Shell 不解析 Source/Wizard。Legacy（G3）Game 不匹配字面量，行为不变。
2. **测试专用 seam**：`MY_WORLD_TEST_CREATION_ROOT` env + `--creation-root=`（与既有 library/games/source root 约定一致）；`shell.test_opening_adapter_override` 在激活前注入桩/受控 adapter，production 恒为 `null`。
3. **payload 变更检测**：Wizard 用 frozen snapshot 的 JSON 序列化作 payload key，仅用于检测「返回修改后再提交」需换 attempt；不作为 Game 唯一性来源（唯一性归 G4-06 creation_id 幂等）。

## 3. 自动化矩阵结果（headless，stub Provider）

`tests/g4_07b/可玩界面整合测试.gd`：**61 PASS / 0 FAIL**（`--root` 含 `g4_07b`，task-owned）。

覆盖矩阵案例：

- **A/B/E** Han 完整垂直：双击创建收敛同一 `creation_id` 与同一 Game（Library 恰 1 局）；创建成功结束 Wizard path 并打开 exact Game；opening-pending 锁输入；首请求单 `system` 消息且含 exact Entry/profile/canonical cast；accepted 恰好一次；不二次开场。
- **C/D/F** 创建失败（Source root 暂指向缺失 path）→ 玩家语言重试态、零 Game；重试复用同一 `creation_id`；payload 变更后铸新 attempt 并收敛到自己的 Game；完成后 Wizard 锁定。
- **H/L** Opening 失败：零 accepted、Game 保留、banner 可重试且无内部码；重试后同一 Game accepted 恰一次。
- **H/N** Opening 取消：零 accepted、Game 保留、banner 提示重试；重试 accepted 恰一次。
- **J** 创建后未 accepted 即退出（正式 close + 整个 Shell 重建）：Continue 回到 exact 同一 Game，保持 legal opening-pending，自动重试第一幕并 accepted 恰一次。
- **M/O** 无 Entry：durable `selected_entry_id == null`；Provider 可见 `Selected Entry: none` / `Exact selected profile: none`；绝不推断隐藏默认 Entry/profile/year。
- **G/I/K** 玩家行动经 durable continuation（roles `system/assistant/user`，含 durable World truth + Opening + 玩家行动）；save point；返回主菜单 → Continue 恢复 durable history、无空玩家气泡、无二次开场、输入解锁。
- **玩家 UI 洁净**：Review/banner/失败文案断言不含 `fingerprint` / 内部 id / 原始错误码。

## 4. 真实 DeepSeek 垂直（非 headless，1280×720）

运行器：`tests/g4_07b/运行真实DeepSeek可玩垂直验证.ps1`（白名单加载 `.env.local` 的 `DEEPSEEK_API_KEY` / `MY_WORLD_DEEPSEEK_MODEL`，不打印、finally 恢复环境）。
测试：`tests/g4_07b/真实可玩垂直测试.gd` → **22 PASS / 0 FAIL**。
证据 JSON：`build/g4_07b/real-vertical/real-vertical-evidence.json`（不含 key）。

| 案例 | 路线 | 结果 |
| --- | --- | --- |
| Han | 天下未定 + 208｜赤壁前夕 + 刘备 + 孙权 | 真实 Opening accepted 一次（669 字，叙事丰富）；首请求单 `system`；真实玩家行动 accepted（roles `system/assistant/user`，context 含 `e208-snapshot` + 玩家行动）；Continue 重开同一 Game、恢复 2 条 durable、**零二次开场**（重挂 opening runtime 无任何 request）。 |
| Afterglow | 埃瑟维亚 + t0-1287｜公共工程余波 + 莉维娅 + 阿德里安/杜恩 | 同一 family-agnostic UI path；真实 Opening accepted 一次（453 字）；context 含 exact Entry/主角/阵容语义且不含汉末语义。 |

截图（`build/g4_07b/real-vertical/shots/`）：`han-review / han-opening-streaming / han-opening-accepted / han-playing / han-continue-restored / afterglow-review / afterglow-opening-streaming / afterglow-opening-accepted` —— 已逐张目检：streaming 锁输入 + banner、accepted 后解锁、Continue 恢复完整叙事、无空玩家气泡、无内部 id/fingerprint。

## 5. Windows 多尺寸 UI 证据

`tests/g4_07b/可玩界面窗口布局测试.gd`（stub Provider）：headless **0 FAIL**；真实窗口运行 **0 FAIL** 并产出 12 张截图（`build/g4_07b/layout-real/shots/`）：

- 1280×720 / 960×540 / 最大化 × Review（Final Create 可用）/ Opening streaming banner / Opening 失败 banner（重试可达）/ Playing。
- 逐张目检：banner 在视口内、按钮可达、960×540 窄窗口 TopBar 折叠 toggle 正常、最大化正文限宽居中。

## 6. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G4-05 建局Composition / 应用向导现实 / 全保真现实 / 历史 v0.1 锚点 | headless 0 FAIL（按钮断言已更新为「Review 通过 → Final Create 可用」） |
| G4-05 向导窗口布局 | headless + 真实窗口 0 FAIL |
| G2-03 视图离线 / G2-04 域 / G2-05 上下文 | 0 FAIL |
| G2-03 GUI 驱动（真实窗口 + 真实 key） | 全 PASS（headless 下 Maximized/key 两项为环境限制，与本任务无关） |
| G3-03 会话恢复与候选 / 上下文恢复与界面 / 迁移与生命周期 | 0 FAIL（生命周期套件需 fresh root，与历史一致） |
| G4-01 生命周期 / 入口布局 | 0 FAIL（布局需真实窗口，与历史一致） |
| G4-04 多游戏生命周期 / 游戏库元数据 / Legacy 采用与恢复隔离 | 0 FAIL |
| G4-06 原子建局 / 冲突与发布失败 / 失败窗口重启 | 0 FAIL（冲突套件需 fresh root，与历史一致） |
| G4-07A 首次开场聚焦 | 0 FAIL |

Backend 只读约束：`src/最终建局/**`、`src/首次开场/**`、`src/persistence/**`、`src/runtime/**`、`src/provider/**`、`src/source/**`、`src/domain/**`、`src/context/**`、`src/游戏库/**`、`src/建局/**` 零改动（git diff 可证）。Production schema 保持 v4，无迁移。

## 7. 已知边界（非缺陷）

- 第一幕失败时 View 的 GM 块 marker 与错误条指向「重试第一幕」banner；玩家回合失败仍指向「重新生成」。
- G4-07B 不做 Wizard → 创建中的中间异步态（创建为同步调用）；双击由按钮禁用 + `_create_in_progress` 双重防护。
- 真实 DeepSeek 生成时长取决于网络；测试超时上限 420s/阶段。

## 8. 结论

G4-07B 工程垂直（Main Menu → Wizard → Review → Atomic Final Create → existing-only open → 真实 GM Opening → 玩家行动 → durable continuation → save/exit/reopen/Continue）在 stub 矩阵与真实 DeepSeek 双轨道上全部通过。**返回上限：READY FOR INDEPENDENT REVIEW**。G4-07 Product PASS 仍需 Owner UAT。
