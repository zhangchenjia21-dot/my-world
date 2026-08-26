---
title: my world｜核心设计原则（实现仓库导读）
status: current-repository-reference
version: 1.0
created: 2026-08-26
updated: 2026-08-26
canonical_source: Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md
---

# my world｜核心设计原则

这份文件是实现仓库中的**核心设计导读与开发投影**。

完整 canonical 产品 / Runtime 原则位于：

`zhangchenjia21-dot/Vibe-Coding/main/my world/MY_WORLD_核心设计原则_CURRENT.md`

本文件不建立第二套产品真相；发生冲突时，以用户当前指令和上述 canonical 文件为准。

它汇总了 SillyTavern 新版主体时期的 World OS / FC2 / Context / Save-Restore / Runtime World Materialization、The World / DSH 长局经验，以及当前 `my world` Owner 裁定中真正要继承的设计。

## 1. 五条最高层原则

> **Model freedom first.**
>
> **Runtime owns durability.**
>
> **Source provides inertia; actors create history.**
>
> **Context stays bounded.**
>
> **Player owns the timeline.**

中文：

> **模型尽可能自由地创造世界。**
>
> **Runtime 负责让世界可靠持续，而不是审查创作。**
>
> **史料提供惯性，玩家、NPC 与势力共同创造历史。**
>
> **世界可以不断增长，但单轮模型工作集必须保持有界。**
>
> **玩家拥有时间线的最终决定权。**

## 2. Reversibility over Prevention

`my world` 不以“让模型永不犯错”为架构目标。

允许出现可逆的游戏内错误，例如：

- 模型误解一句玩家输入；
- NPC 偶尔出现知识 / 性格偏差；
- Narrative 补写了玩家未逐字说明的微小动作；
- 世界设定或规则偶发不一致；
- 玩家单纯不喜欢这一轮的发展。

优先解决方式：

```text
regenerate / retry
撤回最近一轮
edit-and-retry
rewind
restore
branch
```

不要默认走：

```text
发现一种错误
→ 新增 Regex
→ 新增 Confirmation
→ 新增 Narrative whitelist / validator
→ Prompt 与状态机继续膨胀
```

只有真实高频、严重破坏产品价值的问题，才值得增加专门限制。

## 3. Narrative 默认自由

Narrative 不应被程序压成只能复述已批准结果的模板层。

默认禁止建设：

- 普通叙事动作白名单；
- “玩家没逐字授权一个小动作就整轮失败”的硬 Gate；
- 每个自然语言歧义都弹 Confirmation；
- 为了防止偶发知识错误不断增加全局 Prompt 规则；
- 只允许程序预枚举行为的隐藏菜单式输入体系。

Player Agency 的最高保护不是“模型一句都不能替玩家补”，而是：

> **玩家可以决定最终保留哪条 Timeline。**

## 4. 修正旧的 Program / Model 边界

旧式口号：

> `Program owns facts; Model writes prose.`

不再作为全局创作限制。

当前边界：

> **Model authors the world; Runtime makes it durable; Player owns the timeline.**

模型可以广泛 author：

- Narrative；
- NPC 行为、目标、反应；
- 新人物 / 地点 / 物品；
- 世界事件；
- game-local 定义演化；
- 开放式后果与语义裁定。

Runtime / Program 重点负责：

- stable identity / refs；
- 原子事务；
- persistence；
- Save / Restore / Timeline 技术正确性；
- 文件和数据库完整性；
- Secret 与系统权限；
- 避免半新半旧和物理损坏。

Runtime 是 durability boundary，不是 narrative censorship layer。

## 5. 错误的硬边界

以下内容不能用“模型自由”解释掉：

- API Key / credential 泄露；
- 任意 OS / filesystem 执行权限；
- 数据库 / 存档物理损坏；
- 非原子半提交；
- Restore 后半旧半新；
- 无法恢复的删除；
- 真实外部系统未经授权的不可逆副作用。

这些是基础设施与安全问题，不是游戏语义自由问题。

## 6. 三层世界事实

未来正式世界模型应保持：

```text
Reusable Source Assets
(World Pack / Character Card / Expansion)
↓
Game-local Canonical Assets
↓
Runtime State
```

Source 定义 T0 前的可复用世界和历史惯性。

开局后，模型可以在本局创造新 NPC、地点、物品和长期事实；一旦成为 durable game-local reality，就应获得稳定 identity / provenance，并参与 Save / Restore / Timeline。

Runtime State 回答“现在是什么状态”，不能和 Source 定义混为一体。

## 7. 世界必须自己行动

> **Off-screen != Inactive.**

NPC / Faction 不应只在玩家接触时才存在。

但：

```text
Persistent world
!= every NPC every tick model call
```

G5 应使用事件 / 优先级驱动的有限世界演化，避免前代的 **Protagonist Causal Monopoly｜主角因果垄断**。

## 8. Knowledge Boundary

继续保留：

```text
World Truth != NPC Knowledge != Player Knowledge
```

但一次普通游戏世界中的 knowledge mistake 不应自动变成新的全局禁止规则。

先改善 Context / provenance / model input，再使用可逆 UX；只有真实高频严重问题才增加机制。

真实 Secret 泄露仍然是硬失败。

## 9. Context 必须保持有界

```text
Asset Library
!= Game Enabled Set
!= Runtime Relevant Set
!= Model Visible Working Set
```

```text
Runtime Relevant != Model Visible
```

世界数据库、历史和 Mod 数量可以持续增长，但 ordinary Turn 的 Prompt 不应跟着线性增长。

目标：

```text
Game State / Event History ↑↑↑
ordinary Turn Context ≈ bounded
```

Dependency Graph 也不能被直接展开成 Prompt Inclusion Graph。

## 10. Background progression 不等于模型调用

Timer、cooldown、简单资源变化、确定性 bookkeeping 等，能由 Runtime 安全推进就不需要调用模型。

把模型能力留给真正需要开放语义、人物选择、世界创造和 Narrative 的地方。

## 11. Timeline 是 AI 游戏的容错基础设施

Save / Restore / Timeline 不只是传统存档功能。

它们要支持：

- retry；
- rewind；
- edit-and-retry；
- restore；
- branch；
- future-memory isolation。

Save 捕获 stable committed world，而不是半执行 Provider 请求。

Restore 应由 Runtime 原子恢复世界，并重建对应 Agent Context；不能靠“把旧聊天重发给模型”猜回来。

## 12. No Phantom 的新定位

`No Phantom World Change` 仍可作为 Narrative / state 一致性的质量观测，但不再是默认 Narrative hard gate。

出现偶发偏差时：

```text
reconcile / retry / rewind
```

优先于：

```text
增加更多创作限制
```

真正持久化的 Turn 仍必须由 Runtime 保证原子与可恢复，不能留下物理半提交。

## 13. UI 与 Godot 的边界

UI 继续只是世界事实的 projection，不能拥有第二套 Relationship / Inventory / Location / Quest / Save truth。

宏观产品架构：

```text
RPG Experience Layer
↓
The World Runtime
↓
Engine Adapter
↓
Godot / Mature Game Foundation
```

业务模块内部的 `L3 -> L2 -> L1 -> L0` 是另一套依赖分层。

两者都用于约束 ownership，不要求创建大量空目录、空 interface 或物理进程。

## 14. 对当前阶段的直接影响

G2 开始后：

- 优先保护真实模型输出质量；
- streaming / cancel / retry 要自然；
- 不因 prevention-first 规则把 GM 变得机械；
- regenerate / retry 是最早的可逆能力；
- G3 再把 rewind / restore / branch 建成正式 Timeline 能力；
- G5 让 NPC / Faction 成为真正独立历史行动者；
- G7 保证长期世界增长时模型 working set 仍有界。

任何 Agent 如果想新增全局 Narrative 限制、Confirmation 层、Regex 授权表或大型 Validator，必须先证明存在一个真实、高频、不可通过可逆 UX 或更好 Context 解决的产品问题。
