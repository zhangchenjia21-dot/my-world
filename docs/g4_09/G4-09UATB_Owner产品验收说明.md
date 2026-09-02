# G4-09UATB Owner 产品验收说明

Status: **HOLD — Narrative Responsiveness Correction**

本轮 Owner 已完成一次真实试玩，并明确确认：**“判定与检定：公开 d20”本身没有明显玩法问题。** 当前剩余问题不是骰子规则，而是 Public d20 路径下可见 GM 正文被整段缓冲，导致体感明显比普通 Narrative 慢。

Owner finding：

`docs/g4_09/G4-09UATB_OWNER_FINDING_NARRATIVE_RESPONSIVENESS.md`

当前工程修正：

`docs/tasks/G4-09UATBC01_NARRATIVE_RESPONSIVENESS_STREAMING_TASK.md`

## 当前不要继续正式验收

在 G4-09UATBC01 通过 GPT Independent Review 前，不要求 Owner 继续重复试玩，也不要返回最终 PASS/FAIL。

已经接受的产品结论保留：

- 公开 d20 的玩法/语义本身值得保留；
- 当前不要求重新比较 DeepSeek/Kimi；
- 当前不要求重新从零验证全部 d20 规则。

## 修正后的重点复测

工程修正通过后，本说明会重新 ACTIVE。届时只需重点确认：

1. 普通 NO_CHECK 行动在模型开始产出正文后能逐步显示，而不是等整段完成后突然出现；
2. CHECK_REQUIRED 的 d20 卡仍先公开程序决定的判定结果，随后结果叙事逐步显示；
3. 不出现重复玩家行动、重复骰卡、重掷或结果被改写；
4. 生成完成后 Save → Main Menu → Continue 仍保持同一 Game / 历史 / 判定；
5. 整体等待与阅读节奏是否已经达到可接受的真实游玩体验。

最终关闭 G4-09UATB 仍需 Owner 明确产品 verdict，但不会要求重做已经确认无问题的部分。
