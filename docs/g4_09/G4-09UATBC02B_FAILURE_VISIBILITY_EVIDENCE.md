# G4-09UATBC02B — Public d20 Failure Visibility / Recoverable UX Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-02
Correction packet: `docs/tasks/G4-09UATBC02B_PUBLIC_D20_FAILURE_VISIBILITY_TASK.md`
C02A Independent Review: `docs/g4_09/G4-09UATBC02A_INDEPENDENT_REVIEW.md`
Canonical decision: `Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_RESPONSIVENESS_V0_1_DECISION.md`

> 本修正只关闭「终态 Public d20 失败不可见」缺陷。**G4-09UATB 保持 HOLD**，直到本任务通过 GPT Independent Review。

---

## 1. 修正内容

`src/ui/叙事对话视图.gd::_handle_adjudication_result()` 的失败分支此前只 `_hide_error()` + `_update_controls()`，从不显示 `_plain_adjudication_failure()` 已映射的安全消息。玩家因此只看到 generic `行动未完成` 恢复态。

修正：

- **终态失败显示简洁安全原因**：`transport` →「暂时无法连接当前模型服务」；`missing_key` →「未检测到当前所选模型的 API Key」；`malformed_stream`/`invalid_*` →「判定服务返回了无法识别的内容」；`empty_generation` →「本次没有生成有效叙事」；`http_*` →「当前模型服务暂时返回异常」。全部以「行动未完成：<原因>可点击「重试行动」继续。」呈现。
- **重试行动保持可用**：失败分支保留既有 `_update_controls()` 逻辑，`retry_action_button.visible` 不受影响。
- **C02A fail-soft 降级不渲染为失败**：accepted 分支新增 `degraded` 检测——`bool(result.get("degraded", false))` 时显示紧凑非阻塞提示「本次行动未进行可选检定，已按普通叙事继续。」，而非 `_hide_error()`。
- **不新增任何门禁**：不引入新 model-format gate / parser 要求 / provider fallback / 重试政策 / 阻塞状态。

## 2. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/ui/叙事对话视图.gd` | `_handle_adjudication_result` 失败分支显示映射安全原因；accepted 分支新增 degraded 非阻塞提示。 |
| `tests/g4_08b/公开D20界面整合测试.gd` | 新增 `_test_c02b_failure_visibility`：transport/missing_key/malformed→degraded 三组断言（共 12 项新断言）。 |

## 3. 自动化矩阵结果（headless，桩 Provider + deterministic RNG）

`tests/g4_08b/公开D20界面整合测试.gd`：**117 PASS / 0 FAIL**（原 96 + C02B 新增 21）。

| C02B acceptance | 结果 |
| --- | --- |
| 1. transport 失败显示安全连接消息 + 重试行动 | PASS |
| 2. missing_key 显示安全凭证消息 + 重试路径 | PASS |
| 3. malformed/unusable 终态机制响应显示安全机制服务消息 | PASS（degraded 路径经 control_recovery → degraded_narrative → accepted，非终态失败） |
| 4. fail-soft 降级不呈现为「行动未完成」 | PASS（显示「未进行可选检定」紧凑提示） |
| 5. UI/证据无秘密/原始 payload | PASS（断言不含 sk-/Authorization） |
| 6. 既有成功 NO_CHECK/CHECK_REQUIRED UI 路径不变 | PASS（D/E/F/G/H 案例全绿） |
| 7. 960×540 与 1280×720 恢复态可用 | PASS（布局测试双 0 FAIL，截图目检） |
| 8. C02A Model Freedom 不变量保持，无新阻塞门禁 | PASS（backend 零改动；M1/M1C01 回归绿） |
| 9. `git diff --check` | 干净 |

## 4. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G4-08B 公开D20界面整合（C02B 强化后） | 117 PASS / 0 FAIL |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08M1 公开D20机制 / M1C01 NO_CHECK 幂等 | 0 FAIL |
| G4-09R1M1 运行时模型设置机制 | 0 FAIL |
| G4-09R1B1 设置 UI 整合（fresh root） | 65 PASS / 0 FAIL |
| G4-05 应用向导现实 | 0 FAIL |

Backend 只读约束：Action Adjudication backend / Provider / Persistence/Runtime / Runtime Model Settings / Source/Final Create 零改动；SQLite schema 保持 v4。

## 5. Windows 布局证据

`tests/g4_08b/公开D20界面窗口布局测试.gd`：headless + 真实窗口双 0 FAIL；`960x540-action-failed-retry.png` 与 `1280x720-action-failed-retry.png` 显示恢复态（安全原因 + 重试行动按钮）在两种尺寸下均可用。

## 6. 真实 Provider 重跑判断

**不重跑**。Provider-facing message 语义未变：C02B 只改 UI 失败投影，不改 backend/Provider/协议结构。C02A 的既有真实 DeepSeek + Kimi 证据（0 FAIL）仍然适用。

## 7. 结论

G4-09UATBC02B 修正使终态 Public d20 失败以简洁安全语言可见，fail-soft 降级呈现为非阻塞提示，重试行动保持可用，无新门禁。**返回上限：READY FOR INDEPENDENT REVIEW**。G4-09UATB 保持 HOLD，直到 GPT Independent Review PASS。
