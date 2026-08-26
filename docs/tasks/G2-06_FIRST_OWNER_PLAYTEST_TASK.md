---
title: my world｜G2-06 First Owner Playtest
task_id: G2-06
type: owner-uat
owner: Product Owner
status: current-owner-playtest
created: 2026-08-26
implementation_base: 9c577811fd71d19f514ca4e9455e02321f0aa34d
repository: zhangchenjia21-dot/my-world
---

# TASK｜G2-06｜First Owner Playtest

## 1. Purpose

真实体验当前完整 G2 Conversation Spine：自然语言输入 → AI GM streaming → 多回合 → Cancel / Regenerate / Retry，以及已经建立的 Conversation / Context ownership 在产品体验上的结果。

这不是工程测试，也不是要求 Owner 检查日志、Git、Provider messages 或内部 state。

最高结论由 Owner 给出：

```text
PASS
或
FEEDBACK / FAIL
```

## 2. 当前已经存在的能力

- DeepSeek `deepseek-v4-pro` real streaming；
- 自然语言多行输入；
- Cancel / Regenerate / Retry；
- Conversation / Turn Domain；
- bounded Context Assembly：最近 12 个完整 accepted Turn + 当前 attempt；
- medium typography、响应式 Composer、三 Host 布局；
- Narrative 不设人为固定输出长度。

## 3. 当前明确不存在的能力

不要因为以下能力尚未出现而判 G2-06 失败：

- 正式 World / Character / NPC / Faction state；
- Save / Load / Timeline / Persistence；
- World Pack；
- 长局 retrieval / summarization；
- 完整 RPG mechanics；
- 自动场景图 / 立绘 / 地图；
- “已经像完成版 AI RPG”。

production 当前 `game_context_text` 仍为空；G2-05 建立的是未来 Game/World material 的 Context seam，不伪造尚未实现的世界状态。

## 4. Owner Playtest Entry

双击：

```text
D:\AI\Projects\my-world\run-game.cmd
```

正常情况下直接以 Maximized Window 启动。

## 5. 建议试玩方式

不需要逐条照脚本机械执行。正常玩 5–10 分钟即可，建议自然做这些动作：

1. 用一段有场景感、行动和态度的中文自然语言开始，例如进入一个危险地点、调查、交涉或采取行动。
2. 连续玩至少 3–5 个 Turn，观察 GM 是否能记住刚发生的短期前文并自然承接。
3. 至少一次让生成完整结束后点击 Regenerate，感受是否像“重新给同一行动一个新结果”，而不是续写旧答案。
4. 至少一次在生成中 Cancel，再决定 Retry/Regenerate 或直接输入下一步，感受恢复成本。
5. 正常阅读一段较长 Narrative，并按自己的真实习惯输入多行行动。

不要为了证明 recent-12 policy 人工发送 13+ 条消息；12-Turn 边界已经由自动化验证，Owner 只评价真实体验。

## 6. Owner 重点判断

请按真实感觉判断：

### A. 输入与交互

- 输入一整段行动/对白/计划是否舒服；
- Ctrl+Enter、发送、Cancel、Regenerate 是否自然；
- Composer、字号和布局是否适合持续阅读/输入。

### B. Narrative

- streaming 是否舒服；
- 文本是否愿意充分展开，而不是机械短答；
- 长度是否自然，既不明显被压短，也不大量灌水；
- 内容是否有环境、人物、行动后果与继续玩的钩子。

### C. 短局 Continuity

当前没有正式 World Context，但 Conversation working set 已存在。请观察 3–5 Turn 内：

- 模型是否记得刚发生的重要事实；
- 人物/地点/行动是否明显无故断裂；
- Regenerate 后继续下一轮是否自然。

### D. Conversation Spine 产品方向

不是问“现在是不是完整 AI RPG”，而是问：

> 这套 Narrative + natural-language input + streaming + reversibility 的交互骨架，是否值得作为后续长期 AI RPG 的核心对话主循环继续建设？

## 7. PASS 标准

Owner 可以 PASS，如果整体体验已经足以确认：

- Conversation Spine 的主交互方向正确；
- 没有明显阻碍持续游玩的输入/阅读/恢复问题；
- 短局 continuity 至少可接受；
- Narrative 基础体验值得进入下一阶段继续加入 Persistence / World semantics，而不是需要推翻当前交互骨架。

小型视觉、美术、功能缺失可以记录为 carry-forward，不要求 G2 一次完成。

## 8. 返回格式

Owner 不需要写正式报告。直接用自然语言告诉项目：

```text
PASS
```

或者说明哪里不舒服，例如：

```text
整体可以，但……
```

只需要描述真实体验和产品判断，不需要提供工程证据。
