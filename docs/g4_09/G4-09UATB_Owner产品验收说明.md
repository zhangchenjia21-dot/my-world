# G4-09UATB Owner 产品验收说明

Status: **ACTIVE — OWNER focused reliability/responsiveness retest**

你已经完成过真实 Public d20 试玩，并确认：**“判定与检定：公开 d20”本身没有明显玩法问题。** 这个产品结论继续保留，不需要重新评估玩法价值。

Correction-02 已完成工程闭环：

- Public d20 mechanics control 与玩家可见 GM narrative 已完全分离；
- 玩家可见正文恢复为自由自然语言，不要求 JSON/header/sentinel/精确换行；
- control 格式异常最多一次有限恢复，仍无法判断时本行动 fail-soft 为普通自然语言叙事，不再把玩家卡死；
- CHECK_REQUIRED 仍保持 Program-owned d20 先 durable、后结果叙事、且绝不 reroll；
- terminal 网络/凭证/持久化失败现在显示安全、明确原因并保留「重试行动」；
- final correction-02 Windows Owner build 已从当前 source head 重建并验证；focused integration 为 127 PASS / 0 FAIL。

当前核心原则：

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

## 现在只做一次短复测

1. 运行 `run-game.cmd`，进入你之前的 Public d20 Game，优先使用【继续游戏】。
2. 输入一个明显不需要检定的普通行动，例如：

   `我询问侍从现在是什么时辰。`

   观察：
   - 不应出现 d20 卡；
   - 行动应可靠继续，不应因为模型 control 格式问题进入死端；
   - GM 正文一旦开始产生，应逐步/流式出现，而不是等完整回答结束后一整块出现。

3. 再输入一个真正有风险且失败有代价的行动，例如：

   `趁夜亲自潜近曹军水寨，越过警戒线侦察船阵，尽量不惊动哨兵。`

   观察：
   - 如果程序判定 CHECK_REQUIRED，应先出现唯一一张 d20 结果卡；
   - 随后结果叙事应逐步/流式出现；
   - 不应重复玩家行动、重复骰卡或 reroll。

4. 如果本次 optional control 因模型格式问题无法可靠解析，允许看到类似“本次行动未进行可选检定，已按普通叙事继续”的非阻塞提示；正文仍应继续。这不是失败。
5. 如果真的发生网络/API Key/安全保存失败，应看到安全而具体的原因，并保留【重试行动】；不应只剩一个不透明的“行动未完成”。
6. 等当前生成完全结束后 Save → Main Menu → Continue，确认历史、已有 d20 结果和当前 Game 均保持。

## 你只需要返回最终产品 verdict

如果这次短复测正常，回复：

```text
PASS
```

如果仍有问题，回复：

```text
FAIL
具体发生了什么
```

可以附截图，并尽量说明：发送后大约等了多久、正文开始后是否持续流式出现、是否看到 d20 卡/错误提示。

不需要重新比较 DeepSeek 与 Kimi，也不需要重新证明 Public d20 是否值得保留。