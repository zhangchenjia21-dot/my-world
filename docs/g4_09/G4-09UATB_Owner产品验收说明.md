# G4-09UATB Owner 产品验收说明

Status: **HOLD — 等待 G4-09R1P1 GPT Independent Review**

本轮最终仍只判断一件事：**“判定与检定：公开 d20”是否为实际游玩增加了值得保留的乐趣。**

> 当前说明已按模型设置 v0.1 刷新，但在 G4-09R1P1 通过 GPT Independent Review 前仍不得执行，也不得提前返回 Owner PASS / FAIL。

## 验收路径

1. 通过仓库根目录的 `run-game.cmd` 启动当前 Windows build。
2. 在 Main Menu 打开【模型设置】。
3. 为本次试玩选择你希望使用的模型、上下文上限和思考强度，然后点击【保存】。
4. 再次打开【模型设置】，确认页面显示的“实际配置摘要”与预期一致；尤其注意 Medium 在支持的模型上会显示实际 High，Kimi K2.7 为固定 Thinking ON。
5. 回到 Main Menu，进入【新游戏】，选择：
   - World：天下未定；
   - Entry：208 赤壁前夜；
   - Character：刘备；
   - Expansion：判定与检定：公开 d20。
6. 完成建局并进入对话，确认首次 GM Opening 正常生成。
7. 输入一个明确具有风险且结果不确定的行动，确认界面出现可见的 d20 判定卡，并能读懂投骰、修正、DC 与结果。
8. 再输入一个普通、无明显风险的行动，确认不会无必要地出现 d20 判定卡。
9. 执行【保存】→ 返回 Main Menu →【继续游戏】，确认仍是同一个 Game，既有对话历史与已经接受的判定结果均保持不变。
10. 给出最终产品判断：**公开 d20 是否为实际游玩增加了值得保留的乐趣？**

## 验收边界

- 本轮不是 DeepSeek/Kimi 模型横向比较；请选择你希望用于试玩的一套配置即可。
- 不要求测试全部模型、上下文或思考强度组合。
- 不修改 API key，不测试自定义 endpoint/model id，不切换到未冻结的 Provider。
- 如果设置摘要、首次 Opening、d20 卡或 Continue 持久化出现异常，记录可复现步骤并停止给出产品 PASS。

## Owner 返回格式

```text
所选模型 / 上下文 / 思考强度：
重新打开设置后的实际配置摘要：
风险行动与 d20 卡观察：
普通行动是否避免无必要判定：
Save -> Main Menu -> Continue 是否保持同一 Game / 历史 / 判定：
最终产品判断（公开 d20 是否增加值得保留的乐趣）：PASS / FAIL
备注：
```

G4-09R1P1 通过 GPT Independent Review 后，治理侧才能将本说明从 HOLD 恢复为 ACTIVE；Codex 不自行恢复 Owner UAT。
