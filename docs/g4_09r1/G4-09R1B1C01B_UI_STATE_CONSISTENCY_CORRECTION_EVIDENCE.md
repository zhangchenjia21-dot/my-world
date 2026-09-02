# G4-09R1B1C01B — Settings UI State Consistency Correction Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-02
Correction packet: `docs/tasks/G4-09R1B1C01B_UI_STATE_CONSISTENCY_CORRECTION_TASK.md`
Parent IR: `docs/g4_09r1/G4-09R1B1_INDEPENDENT_REVIEW.md`
Accepted C01A prerequisite: `docs/g4_09r1/G4-09R1B1C01A_INDEPENDENT_REVIEW.md`
Accepted C01A evidence HEAD: `bb3c16b392887a4649f32e23348067c70a3e7a1c`

> 本修正只关闭 C01B 的三个有界 UI 一致性缺陷。**不声明 G4-09R1/G4-09/G4-08 PASS**；不恢复 Owner UAT。

---

## 1. 修正内容

### 修正 1 — 移除 UI → Runtime Settings L0 依赖

- `src/应用壳.gd` 不再 preload `src/运行时设置/L0_公理层/**`；
- invalid persisted 的编辑起点改用 C01A 提供的 `ModelRuntimeSettingsPublicInterface.validated_default_settings()`；
- 保留既有 UX：可见可恢复警告、默认仅作编辑起点、不静默保存。

**证明**：`grep "运行时设置/L0_公理层" src/应用壳.gd` 零命中；`grep "ModelRuntimeSettingsRules" src/应用壳.gd` 零命中；`C01B-1` 测试直接断言源码无 L0 引用且 L3 `validated_default_settings()` 返回精确冻结默认。

### 修正 2 — K2.7 非法 context 中间态保留 capability truth

C01A 让 `inspect_candidate()` 在 `incompatible_context_limit` 时返回 `success=false` + safe partial `candidate`。Shell 现在消费该 partial：

```text
K3/1M 持久化 → 打开设置 → 切 Kimi K2.7（context 保持 1M）
→ inspect 返回 incompatible_context_limit + partial candidate
→ UI：1M 保持可见但禁用；Save 禁用；思考强度控件禁用；
  固定 Thinking ON 说明可见；无伪造 graded effective；玩家可读「不支持」提示
→ 切 256K：候选合法，Save 启用，固定思考保留
→ 切回 DeepSeek：graded reasoning 恢复
```

所有兼容性/固定思考/有效值真相来自 L3；UI 无 Kimi 硬编码政策。

### 修正 3 — Escape / ui_cancel = Cancel

`_unhandled_input` 在设置面板可见时捕获 `ui_cancel`：关闭面板、回 Main Menu、不保存、不退出应用、焦点回「模型设置」。

## 2. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/应用壳.gd` | 移除 L0 preload；invalid persisted 用 L3 `validated_default_settings()`；`_refresh_settings_projection` 在 inspect 失败时消费 partial candidate 保留 capability truth；新增 `_unhandled_input` 处理 Escape。 |
| `tests/g4_09r1b1/模型设置界面整合测试.gd` | 新增 C01B-1/2/3/4/5/6 六组直接断言（共 20 项新断言）。 |

`src/main.tscn` 未改（焦点/输入行为无需场景变更）。

## 3. 自动化矩阵结果（headless，task-owned settings path）

`tests/g4_09r1b1/模型设置界面整合测试.gd`：**65 PASS / 0 FAIL**（B1 原 44 + C01B 新增 21）。

| C01B packet 断言 | 结果 |
| --- | --- |
| 1. Shell 无 `运行时设置/L0_公理层` 依赖 | PASS（源码 grep + L3 default 可用） |
| 2. invalid persisted 用 L3 default 且不静默写 | PASS（B1 既有 S4-invalid + C01B-1） |
| 3. K3/1M → K2.7 显示 invalid-context + fixed-thinking truth | PASS（1M 禁用/Save 禁/思考禁/固定思考说明/无伪造 graded/玩家可读） |
| 4. 切 256K 恢复 Save-valid 且固定思考保留 | PASS |
| 5. 切回 DeepSeek 恢复 graded reasoning | PASS |
| 6. Escape 关闭面板不保存不退出 | PASS |
| 7. B1 既有套件保持绿 | PASS（44 项原断言） |
| 8. G4-07B / G4-08B 回归 | PASS（61 + 96） |
| 9. 1280×720 / 960×540 / maximized 可用 | PASS（12 张截图） |
| 10. `git diff --check` | 干净 |

## 4. 真实 Provider 重跑判断

**不重跑**。正常 Save/Provider 路由未变：C01B 只改 UI 状态一致性与 L0 依赖移除，不改 `save_settings` 调用形状、不改 Provider adapter 的 `request_snapshot()` 消费、不改 request 语义。G4-09R1B1 的既有真实 DeepSeek + Kimi UI 生成证据（`build/g4_09r1b1/real-settings/real-settings-evidence.json`，0 FAIL）仍然适用。

## 5. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G4-09R1B1 设置 UI 整合（C01B 强化后） | 65 PASS / 0 FAIL |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08B 公开D20界面整合 | 96 PASS / 0 FAIL |
| G4-09R1M1 运行时模型设置机制 | 0 FAIL |
| G4-08M1 公开D20机制 / M1C01 NO_CHECK 幂等 | 0 FAIL |
| G4-05 应用向导现实 / 建局Composition / 全保真现实 | 0 FAIL |
| G4-06 原子建局 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G2-03 视图离线 / G2-04 域 / G2-05 上下文 | 0 FAIL |

Backend 只读约束：`src/运行时设置/**`、`src/provider/**`、`src/source/**`、`src/最终建局/**`、`src/persistence/**`、`src/行动判定/**` 零改动（git diff 可证）。Production schema 保持 v4。`git diff --check` 干净。

## 6. 结论

G4-09R1B1C01B 修正关闭了三个有界 UI 一致性缺陷：Shell 不再依赖 Runtime Settings L0、K2.7 非法 context 中间态保留 backend capability truth、Escape/ui_cancel = Cancel。**返回上限：READY FOR INDEPENDENT REVIEW**。G4-09R1B1 PASS 仍需 GPT Independent Review。
