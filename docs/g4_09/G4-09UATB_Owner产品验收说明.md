# G4-09UATB Owner 产品验收说明

Status: **HOLD — 等待模型设置 v0.1 完成**

本轮最终仍只判断一件事：**“判定与检定：公开 d20”是否为实际游玩增加了值得保留的乐趣。**

但 Owner 已在正式试玩前要求先加入应用级模型设置，因此当前说明暂不执行。

等待以下路径完成并通过 GPT Independent Review：

```text
G4-09R1M1 后端模型/Provider机制 — Codex
→ G4-09R1B1 模型设置界面 — Kimi
→ real DeepSeek + Kimi integration
→ Windows export freshness
→ 本说明刷新
→ G4-09UATB 恢复 ACTIVE
```

新的设置将允许选择：

```text
模型：DeepSeek V4 Pro / DeepSeek V4 Flash / Kimi K3 / Kimi K2.7
上下文上限：256K / 1M（按模型能力校验）
思考强度：Low / Medium / High / Max（Kimi K2.7 为固定 Thinking ON）
```

在上述前置工作完成前，不要返回 PASS / FAIL，也不要使用旧的 DeepSeek-only 路径做正式产品验收。