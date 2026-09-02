# G4-09UATB Owner 产品验收说明

Status: **HOLD — correction-02（Model Freedom / Protocol Decoupling）**

你已经完成过真实 Public d20 试玩，并确认：**“判定与检定：公开 d20”本身没有明显玩法问题。** 这个产品结论继续保留。

Focused responsiveness retest 又暴露了一个新的真实问题：输入行动后，产品可能进入“行动未完成”而不返回正文。Independent diagnosis 认为，C01 为了实现一-call NO_CHECK streaming，把模型要求成“同一响应里先精确 control JSON，再按约定输出 narrative body”，这把模型排版/格式变成了玩家能否继续游戏的 blocking gate。

这个方向已经被废弃。

当前 correction-02 原则：

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

新的工程方向是：

- d20 的机械判定 control lane 与玩家可见 GM narrative lane 分离；
- GM narrative 恢复为完全自由的自然语言流，不要求 JSON/header/sentinel/精确换行；
- 旧的 `NO_CHECK 必须只用 1 次 Provider call` 优化不再是硬要求；
- control lane 如果一次有限自动恢复后仍不可用，本行动透明降级为普通自然语言叙事，而不是把玩家卡死；
- CHECK_REQUIRED 一旦有有效 proposal，仍保持 Program-owned d20 先 durable、后结果叙事、且绝不 reroll。

当前任务：

`docs/tasks/G4-09UATBC02A_D20_PROTOCOL_DECOUPLING_TASK.md`

后续 UI failure visibility：

`docs/tasks/G4-09UATBC02B_PUBLIC_D20_FAILURE_VISIBILITY_TASK.md`

## 当前不要继续复测

在 C02A + C02B 通过 GPT Independent Review 前，不需要继续重复输入行动，也不要返回最终 PASS/FAIL。

修正完成后，Owner 只需要做一次很短的可靠性/响应性复测，不会重新从零验收 d20 玩法。
