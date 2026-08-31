---
title: my world｜G4-07B UI State / Failure Matrix
status: current-task-working-document
task_id: G4-07B
owner: Kimi
created: 2026-08-31
updated: 2026-08-31
packet: docs/tasks/G4-07B_PLAYABLE_UI_INTEGRATION_TASK.md
---

# G4-07B｜UI State / Failure Matrix

本矩阵在 production 改动前冻结 G4-07B 的 application/presentation 行为。backend 语义以 G4-06/G4-07A 已审查实现为权威；本文件只分配 **UI 归属、状态呈现与重试/导航行为**。

## 1. UI-owned state vocabulary

```text
Reviewing            Wizard step 7，Review 成功但尚未提交创建
Creating             Final Create 调用进行中（同步调用，按钮禁用防双击）
CreateFailed         创建在 Game 出现前失败；同一 create attempt 可安全重试
OpeningStreaming     Game 已创建并打开；第一幕正在流式生成
OpeningFailed        第一幕失败/取消；Game 保留；可重试或回主菜单
OpeningPending       created Game 且 accepted Conversation = 0（含 Continue 进入）
Playing              accepted Conversation >= 1；正常玩家输入
```

Presentation 归属：

- Wizard 拥有 Review 页与 create attempt 身份（`creation_id` 的 mint/reuse/invalidate）。
- Application Shell 拥有 create 调用、existing-only open、Opening 状态机与 banner。
- Narrative View 拥有 Opening/continuation 的渲染与输入门。

## 2. Case matrix

| Case | 触发 | creation_id / Game 语义 | UI 行为与终态 |
|---|---|---|---|
| A | Review → 首次点击创建 → Opening 成功 | 首次提交 mint 一个 `creation_id`；G4-06 收敛出恰好一个 Game | Creating → existing-only open → OpeningStreaming → Playing；Opening 只 accepted 一次 |
| B | 创建中双击/连点 Final Create | 按钮在调用期间禁用 + `_create_in_progress` 守卫；不产生第二次调用 | 仍只有一个 Game；幂等 |
| C | Game 出现前的瞬时创建失败（如 exact Source 暂不可复核） | 同一 attempt 重试复用同一 `creation_id`；G4-06 `create_or_resume` 收敛到同一 Game | CreateFailed：白话错误 + 「重试创建」；重试成功后仍只有一局 |
| D | 创建成功但进入游戏/开场启动失败 | Game 已 durable 且已登记为 current；绝不重建 | 回主菜单 + 白话提示「游戏已创建，可继续游戏」；Continue 走 OpeningPending |
| E | 创建后、Opening accepted 前退出应用（含 streaming 中关窗） | close 只放弃未 accepted attempt；Game/current 保持 | 下次 Continue → 同一 Game → OpeningPending → 自动重新进入第一幕 |
| F | Continue 打开 accepted = 0 的 created Game | 不新建 Game；不 mint 新 creation_id | OpeningPending：自动调用 G4-07A first-Opening seam；失败则 OpeningFailed 可重试 |
| G | Opening Provider 失败（含 partial stream 后失败） | durable accepted 保持 0；Game 不回滚 | OpeningFailed banner：白话原因 + 「重试第一幕」+「返回主菜单」；partial 不 durable |
| H | Opening 取消（含 partial 后取消） | 同上 | 同上，文案为「已取消」；retry 清洁 |
| I | 失败/取消后重试 Opening | 同一 Game、同一 opening seam；不 rerun Final Create、不换 creation_id | 重试成功后恰好一条 accepted Opening → Playing |
| J | 已有 accepted Opening 时 Continue/进入 | shell 检查 accepted > 0，不调用 first-Opening；backend `already_opened` 兜底 | 直接 Playing，渲染 durable history；无第二条 first Opening |
| K | Opening 后第一条真实玩家行动 | Narrative View 经 G4-07A `assemble_continuation_messages()`（durable Game-local World + durable Conversation） | 正常 Player → GM 呈现；roles `[system, assistant, user]`；不读 Wizard / mutable Source current |
| L | 至少一回合后 Save / 退出 / 重开 / Continue | Save 走既有 G3 seam；Continue existing-only | 同一 Game、同一 durable history；继续可玩 |
| M | no-Entry 路线 | durable `selected_entry_id = null` 保持显式空 | UI 全程显示「不指定开局」；不补默认 Entry/profile/year；Opening context 明示 `Selected Entry: none` |
| N | 汉早期 Entry 路线（184/208 等） | Game-local 只含 exact 早期投影 | Opening/continuation context 不含后期 marker（UI 不引入任何 fallback） |
| O | 埃瑟维亚路线 | 与 Han 完全同一 UI 路径 | 无 family 分支代码；幻想语义正常到达 |
| P | Continue 遇到 missing/corrupt Game | existing-only open fail-loud；绝不创建替代局 | 既有 startup failure surface（白话 + 可选安全备份恢复） |
| Q | durable create 前返回修改 Composition | 返回编辑后 payload 变化 → 下一次提交 mint 新 `creation_id`；旧 attempt 若从未成功则无 Game 残留 | Review 重新渲染；创建按钮状态随 Review 结果刷新 |
| R | Windows 1280×720 / 960×540 / maximized | — | 各状态 banner/按钮/输入区无裁剪、无重叠、无 focus 陷阱、无意外双击提交 |

## 3. 固定规则（对应 Packet invariants）

1. **INV-UI-01**：`creation_id` 由 Wizard 在首次提交某份 frozen Review payload 时 mint；`_create_in_progress` + 按钮禁用防双击；payload key（snapshot 序列化，仅用于变更检测，不作为 Game 唯一性来源）变化 → 新 attempt identity；成功后 `_create_completed` 锁死本屏再次创建。
2. **INV-UI-02**：创建成功后 shell 调既有 `open_registered_game(game_id)`（内部 `runtime.open_existing_game`），绝不走 first-run `open_current_game()` 补建路径。
3. **INV-UI-03**：accepted = 0 + 合法 setup 是合法 opening-pending；进入该 Game 一律路由到 G4-07A first-Opening seam。
4. **INV-UI-04**：Opening 失败/取消不删除、不注销、不重建 Game；banner 提供安全重试与返回主菜单。
5. **INV-UI-05**：Narrative View 对空 `player_text` 的 accepted entry 不渲染玩家气泡；live streaming 的 GM-only attempt（`begin_gm_opening` 只发 `attempt_started`）建立「GM · 开场」展示块。
6. **INV-UI-06**：opening_runtime 存在时，玩家行动一律用 `assemble_continuation_messages()`；组装失败则 fail-loud（不静默退化为空 context）。
7. **INV-UI-07**：Continue 语义 = accepted count 分支；已 accepted 后永不自动生成第二条 first Opening。
8. **INV-UI-08**：玩家界面不出现 fingerprint/internal ID/schema/task ID/engineering code；Guaranteed NPC 文案沿用 G4-05R2 语义；no-Entry 保持显式「不指定开局」。
9. **INV-UI-09**：三尺寸键盘/鼠标可操作；流式状态可见；无双击提交；无模态死路。
10. **INV-UI-10**：本任务不宣布 G4-07 Product PASS。

## 4. 粘接决策（供 Independent Review 判断）

- Shell 通过 `session_runtime.world_state.schema_version == "game_local_setup.v0.1"` 判断是否为 G4-06 创建的 Game 并挂载 opening runtime。该字符串是 G4-06 冻结 durable setup contract 的自声明 schema；legacy G3 adoption 无此 document，继续走既有路径。这是 presentation 路由判断，不解释 setup 语义。
- Shell 新增测试根注入 `MY_WORLD_TEST_CREATION_ROOT` / `--creation-root=`（与既有 `MY_WORLD_TEST_*` 同 pattern），并暴露 `test_opening_adapter_override` 供 focused 测试注入桩 adapter（对应 G4-07A `adapter_override` seam）。production 默认行为不变。
- Wizard 内 create attempt 的 payload 变更检测使用 snapshot 的 JSON 序列化，仅决定「是否 mint 新 attempt id」，不参与 Game 唯一性。
