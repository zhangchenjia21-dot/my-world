# G4-09UATBC02BC01 — Persistence Failure Visibility Completion Evidence

Status: **READY FOR INDEPENDENT REVIEW**
Date: 2026-09-02
Correction packet: `docs/tasks/G4-09UATBC02BC01_PERSISTENCE_FAILURE_VISIBILITY_CORRECTION_TASK.md`
C02B Independent Review: `docs/g4_09/G4-09UATBC02B_INDEPENDENT_REVIEW.md`

> 本修正只关闭「persistence/finalize 硬失败仍回落到 generic 行动未完成」缺陷。**不恢复 Owner UAT**；不开始 G4-10/G5。

---

## 1. 修正内容

`src/ui/叙事对话视图.gd::_plain_adjudication_failure()` 新增 Public d20 durable/finalize 失败家族映射：

```text
persistence_failure
check_persistence_failed
no_check_persistence_failed
check_acceptance_marker_failed
no_check_acceptance_marker_failed
→ 「本次结果未能安全保存，请重试。」
```

这明确传达 **safe-save/persistence failure**，不是模型/网络失败，也不是 generic unknown failure。重试行动保持可用；稳定 action identity / no-reroll 语义不变。

## 2. 改动文件

| 文件 | 改动 |
| --- | --- |
| `src/ui/叙事对话视图.gd` | `_plain_adjudication_failure` 新增 5 个 persistence 失败码 → 安全保存类别映射。 |
| `tests/g4_08b/公开D20界面整合测试.gd` | 新增 `_test_c02bc01_persistence_failure_visibility`：check_persistence_failed / persistence_failure / check_acceptance_marker_failed 三组断言（共 10 项新断言）。 |

## 3. 自动化矩阵结果（headless，桩 Provider + deterministic RNG）

`tests/g4_08b/公开D20界面整合测试.gd`：**127 PASS / 0 FAIL**（C02B 117 + C02BC01 新增 10）。

| C02BC01 acceptance | 结果 |
| --- | --- |
| 1. pre-Conversation durable write 失败（`check_persistence_failed`）显示安全保存类别 + 重试行动 | PASS |
| 2. Conversation/finalize 失败（`persistence_failure`）显示安全保存类别 + 恢复 | PASS |
| 3. acceptance-marker 失败（`check_acceptance_marker_failed`）显示安全保存类别 + 恢复 | PASS |
| 4. 无原始 SQLite/SQL/path/内部存储错误文本 | PASS（断言不含 SQL/sqlite/user://） |
| 5. transport/missing_key/degraded 行为不变 | PASS（C02B 断言全绿） |
| 6. 成功 NO_CHECK/CHECK_REQUIRED 行为不变 | PASS（D/E/F/G/H 案例全绿） |
| 7. 无 backend/Provider/Persistence/Runtime/协议/重试政策变更 | PASS（git diff 仅 UI + 测试） |
| 8. 无新 parser/model-format gate/fallback/阻塞状态 | PASS |
| 9. `git diff --check` | 干净 |

## 4. 回归地板（全部 0 FAIL）

| 套件 | 结果 |
| --- | --- |
| G4-08B 公开D20界面整合（C02BC01 强化后） | 127 PASS / 0 FAIL |
| G4-07B 可玩界面整合 | 61 PASS / 0 FAIL |
| G4-08M1 公开D20机制 / M1C01 NO_CHECK 幂等 | 0 FAIL |
| G4-09R1M1 运行时模型设置机制 | 0 FAIL |
| G4-09R1B1 设置 UI 整合 | 65 PASS / 0 FAIL |
| G4-05 应用向导现实 | 0 FAIL |
| G4-06 原子建局 | 0 FAIL |
| G4-07A 首次开场聚焦 | 0 FAIL |
| G3-03 会话恢复与候选 | 0 FAIL |
| G4-04 多游戏生命周期 | 0 FAIL |

G2-03 视图离线 T3（真实 adapter DNS `.invalid` 确定性失败）在 headless 环境因无 DNS 解析报 transport 类别差异——这是环境限制，与本修正无关（本修正不改 `_friendly_error` legacy 路径；T3 在非 headless 环境保持既有行为）。

Backend 只读约束：`src/行动判定/**`、`src/provider/**`、`src/persistence/**`、`src/runtime/**`、Runtime Model Settings、Source/Final Create/Game Library 零改动；SQLite schema 保持 v4。

## 5. 真实 Provider 重跑判断

**不重跑**。本任务只改 UI 对既有终态 code 的投影；Provider-facing message 语义、协议结构、重试政策均未变。C02A/C02B 的既有真实 DeepSeek + Kimi 证据仍然适用。

## 6. 结论

G4-09UATBC02BC01 修正使 persistence/finalize 硬失败以简洁安全保存类别可见，重试行动保持可用，无新门禁。**返回上限：READY FOR INDEPENDENT REVIEW**。G4-09UATB 保持 HOLD，直到 GPT Independent Review PASS。
