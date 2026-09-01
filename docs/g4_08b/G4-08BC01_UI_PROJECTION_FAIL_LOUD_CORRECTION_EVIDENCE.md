# G4-08BC01 — Public d20 UI Projection / Fail-Loud Correction Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-01
Correction packet: `docs/tasks/G4-08BC01_UI_PROJECTION_FAIL_LOUD_CORRECTION_TASK.md`
Formal Code Base: `3a20234d06c10904c220cd1a49bf29f6ad6769e7`
Independent Review finding: `docs/g4_08b/G4-08B_INDEPENDENT_REVIEW.md`
Correction budget: **correction-01**

> 本修正只关闭 GPT IR 指出的有界 UI 集成缺陷。**不声明 G4-08B PASS**；G4-09 与 G4-GATE 仍需后续门禁。

---

## 1. 修正范围

| IR finding | 修正 |
| --- | --- |
| **A — mechanic card 生命周期/顺序不稳定** | `_append_mechanic_card` 改为以 `check_id` 为只读投影 guard：同 id 已存在则 `_update_mechanic_card` 复用节点，不追加第二张；`_on_turn_started` 在 Host 调 `begin_turn` 时把 transient 卡移到 Player 之后、GM 之前，冻结 **Player → card → GM**；`_render_restored_entries` 历史重建用同一顺序；accepted 后 transient 卡 meta 转非 transient（不重绘）。 |
| **B — 未知 action_resolution capability 静默降级** | Shell `_prepare_action_adjudication_after_activation` 遇到 `capability_slot == action_resolution` 但 `capability_id != action_check.public_d20.v1` 时调用 `narrative_view.show_unsupported_capability()`；View 锁输入、显示玩家可读失败、不走 legacy Provider 路径、不挂载 Host。Game 数据保持完整。 |
| **C — explicit-none 证据空缺** | 填补 `_test_wizard_expansion_none_projection()`：Wizard 拓展步 → 显式「本局不使用拓展」→ step 完成 → 往返保留 → Review 含「拓展 / 无」→ frozen payload `expansions=[]` 且 `expansion_none_confirmed=true`。 |
| **D — production UI 含 PROBE 输出** | `src/ui/叙事对话视图.gd` 与 `src/ui/新游戏向导.gd` 的 `print("PROBE …")` 全部移除；`grep` 可证零残留。 |

## 2. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/ui/叙事对话视图.gd` | 卡生命周期去重/顺序/更新；`show_unsupported_capability()`；`_unsupported_capability` 门控；`_update_controls` 在 unsupported 时锁输入/隐藏 Regenerate；`shutdown_session` 重置 unsupported。 |
| `src/应用壳.gd` | unknown capability 时 `show_unsupported_capability()` 而非 push_error；`_teardown_action_adjudication` 加 `is_instance_valid` 防御；`_prepare_opening_after_activation` 用 `is_instance_valid` 保护 adapter override。 |
| `tests/g4_08b/公开D20界面整合测试.gd` | 填补 explicit-none 测试；新增 `_test_unsupported_capability_fail_loud`；强化卡顺序断言。 |

## 3. 卡生命周期（冻结语义）

```text
resolution_narrative 开始
→ Host 已 durable check
→ View._on_adjudication_stage_started / _handle_adjudication_result
→ _append_mechanic_card(check, transient=true)
→ 若同 check_id 已存在：_update_mechanic_card 复用节点，不追加

Host 调 conversation.begin_turn(player_text)
→ View._on_turn_started
→ _append_player_entry(player_text)
→ move_child(transient_card, Player 之后)
→ _begin_gm_entry()

accepted / already_accepted
→ transient 卡 meta 转非 transient
→ 历史重建（Continue/Load/full redraw）按 Player → card → GM 从 durable 重建
```

**去重规则**：同一 durable `check_id` 在 Entries 中至多一张可见投影；`check_id` 是唯一投影 identity。

**顺序冻结**：live accepted 与 Continue/Load/full redraw 均为 **Player action → mechanic card → GM narrative**。

## 4. 未知 capability fail-loud

```text
world_state.expansions[] 含 capability_slot == action_resolution
且 capability_id != action_check.public_d20.v1
→ Shell 调 narrative_view.show_unsupported_capability()
→ View 锁输入（send disabled + player_input not editable）
→ 玩家可读失败：「本局包含当前版本不支持的行动判定规则…」
→ 不挂载 Host、不走 legacy Provider、不掷骰
→ Game 数据保持完整，未来支持该能力的 build 可重新打开
```

## 5. 自动化矩阵结果（headless，桩 Provider + deterministic RNG）

`tests/g4_08b/公开D20界面整合测试.gd`：**96 PASS / 0 FAIL / 0 SCRIPT ERROR**。

| 证据 | 结果 |
| --- | --- |
| A 首次受检行动：transient 先于 GM 完成、同 check_id 恰一张、accepted 后 Player→card→GM | PASS |
| B durable-check 重试：同 action_id、无 RNG、重试前后卡数≤1、accepted 历史 Player→card→GM | PASS |
| C 重开未完成重试：exact action_id、无重掷、signal+同步返回不重复追加、accepted 恰一张 | PASS |
| D Continue/Load：Continue 重建同顺序、Load 回 check 前移除卡 | PASS |
| E NO_CHECK：零骰卡 | PASS |
| F 未知 capability：玩家可见、锁输入、无 legacy 调用、无 RNG、Game 数据完整 | PASS |
| G explicit none：Wizard→Review 直接断言、frozen payload `expansions=[]` + `expansion_none_confirmed` | PASS |
| H 回归：G4-08B 原套件、G4-07B、M1/M1C01、G4-05/G4-06/G4-07A、G2/G3/G4-01/G4-04 全绿 | PASS |

## 6. 真实 Provider 重跑判断

**不重跑**。Provider-facing message 语义未变：本次修正只改 UI 投影生命周期、卡顺序、去重与未知能力 fail-loud，不改 Host 发给 Provider 的 adjudication/resolution messages。G4-08B 的既有真实 DeepSeek Han d20 垂直证据（`build/g4_08b/real-vertical/real-vertical-evidence.json`，0 FAIL）仍然适用。

## 7. Windows 多尺寸 UI 证据

`tests/g4_08b/公开D20界面窗口布局测试.gd`：headless **0 FAIL**；真实窗口 **0 FAIL**，15 张截图（`build/g4_08b/layout-real2/shots/`）：

- 1280×720 / 960×540 / 最大化 × 拓展步/Review/transient 卡/Playing 含 accepted 卡/失败重试 banner。
- 逐张目检：卡顺序 Player→card→GM 在 live 与重建中一致；960×540 按钮可达；最大化正文限宽居中。

## 8. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G4-08B 公开D20界面整合（强化后） | 96 PASS / 0 FAIL |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08M1 公开D20机制 / M1C01 NO_CHECK 幂等 | 0 FAIL |
| G4-05 建局Composition / 应用向导现实 / 全保真现实 / 历史 v0.1 锚点 | 0 FAIL |
| G4-05 向导窗口布局 | headless + 真实窗口 0 FAIL |
| G4-06 原子建局 / 冲突与发布失败 / 失败窗口重启 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G2-03 视图离线 / G2-04 域 / G2-05 上下文 | 0 FAIL |
| G3-03 会话恢复与候选 | 0 FAIL |
| G4-01 生命周期 / 入口布局 | 0 FAIL |
| G4-04 多游戏生命周期 / 游戏库元数据 / Legacy 采用与恢复隔离 | 0 FAIL |

Backend 只读约束：`src/source/**`、`src/最终建局/**`、`src/persistence/**`、`src/行动判定/L0_公理层/**`、`src/行动判定/L1_器件层/**`、`src/行动判定/L2_流程层/**` 零改动（git diff 可证）。Production schema 保持 v4。`git diff --check` 干净。

## 9. 结论

G4-08BC01 修正关闭了 GPT IR 指出的三个阻塞缺陷与一个证据空缺：mechanic card 生命周期/顺序稳定且去重、未知 action_resolution capability fail-loud、explicit-none 直接证据、production UI 零 PROBE 残留。**返回上限：READY FOR INDEPENDENT REVIEW**。G4-08B PASS 仍需 GPT Independent Review。
