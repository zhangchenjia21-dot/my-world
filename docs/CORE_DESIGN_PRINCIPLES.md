---
title: my world｜核心设计原则（实现仓库导读）
status: current-repository-reference
version: 1.3
created: 2026-08-26
updated: 2026-08-26
canonical_core: Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md
canonical_architecture: Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md
---

# my world｜核心设计原则（实现导读）

本文件只给实现 Agent 一个短版执行投影，不建立第二套产品真相。

完整 current source：

```text
Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md
Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md
Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md
Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md
Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md
```

专题设计不要默认全部读取；从 `MY_WORLD_架构_CURRENT.md` 按当前任务导航。

## 1. 最高原则

> **Model freedom first.**
>
> **Narrative richness over artificial brevity.**
>
> **Runtime owns durability.**
>
> **Source provides inertia; actors create history.**
>
> **Context stays bounded, not starved.**
>
> **Player owns the timeline.**
>
> **Reversibility != frictionless arbitrary rewind.**

中文执行含义：

- 模型尽可能自由地创造 Narrative 与世界；
- Narrative 是主要游戏内容之一，不为了 UI / latency /工程方便默认压短；
- Runtime 负责 stable identity、原子持久化、恢复与安全，不当 Narrative 审查器；
- 玩家、NPC、Faction 共同创造历史；
- 世界可以无限增长，单轮模型 working set 不能线性增长，但必须提供当前场景足够丰富的相关 Context；
- 局部错误低成本纠正，重大历史恢复必须有明确玩家意图。

## 1A. Narrative Quality / Length

正式目标：

> **丰富而不灌水；篇幅由模型、场景与相关 Context 自然决定。**

不要默认新增：

```text
固定每 Turn 字数
固定最低字数
固定最高字数
“请简短回答”默认 prompt
为了 UI 方便截断 Narrative
无真实必要的 max_tokens hard cap
```

同样不要用“至少 N 字”制造假丰富。

质量优先看：

- 环境 / 感官是否具体；
- NPC 动作、声音、态度和对白是否有个体性；
- 行动后果与世界变化是否有因果；
- 是否带来值得玩家继续追踪的新信息；
- 人物 / 地点 / 关系 / 前文是否连续；
- 节奏是否匹配场景；
- 真正需要重大选择时是否给玩家行动空间。

```text
Richness
= useful information density
+ immersion
+ character specificity
+ causality
+ world movement

Richness
!= filler / repetition / forced verbosity
```

如果输出持续过短、泛化或缺少世界细节，先检查 Context starvation、GM prompt、模型选择与 Runtime 可用世界材料；不要先用固定字数补丁。

UI / Runtime 必须能够承受长 Narrative：真实 streaming、滚动、readable width、Cancel、长期 Context 管理；不能靠把模型输出变短解决这些工程问题。

Narrative 质量最终是 Owner gameplay Gate，自动化不能证明“沉浸”“值得继续读”或“没有明显弱于直接优秀模型 RPG 对话”。

## 2. Reversibility over Prevention

普通可逆错误优先：

```text
active generation → Cancel
latest generation → Regenerate / Retry
latest-turn correction → 正式 Domain 成立后再支持
important history recovery → explicit Save / Load / Restore
```

不要默认：

```text
发现错误
→ Regex
→ Confirmation
→ Narrative whitelist / validator
→ Prompt / state machine 持续膨胀
```

也不要把每个历史 Turn 变成一键 `回到这里`。

## 3. Model / Runtime 边界

旧式：

`Program owns facts; Model writes prose.`

不再作为全局创作限制。

当前：

> **Model authors the world; Runtime makes it durable; Player owns the timeline.**

模型可以广泛 author Narrative、NPC 行为、新人物/地点/物品、世界事件、game-local 演化和开放式后果。

Runtime 重点负责：

- stable identity / refs；
- atomic transactions / persistence；
- Save / Restore / Timeline 技术正确性；
- filesystem / database integrity；
- secrets / OS authority；
- 避免半新半旧和物理损坏。

## 4. Hard Boundaries

模型自由不能覆盖：

- credential 泄露；
- 任意 OS/filesystem 执行；
- DB/save 物理损坏；
- 非原子半提交；
- Restore 后半旧半新；
- 不可恢复删除；
- 未授权不可逆外部副作用；
- UI/Cache/Transcript 成为第二 live truth。

## 5. 世界事实

```text
Reusable Source Assets
↓
Game-local Canonical Assets
↓
Runtime State
```

Source 定义 T0 前的参考和惯性。开局后模型可以创造本局 NPC、地点、物品与长期事实；一旦 durable，需要 stable identity / provenance。

## 6. World Agency / Knowledge

> **Off-screen != Inactive.**

Persistent world 不等于 every-NPC every-tick model call。G5 用事件/优先级驱动演化，避免 **Protagonist Causal Monopoly**。

```text
World Truth != NPC Knowledge != Player Knowledge
```

Knowledge mistake 优先改善 Context / provenance / retry，而不是无限增加审查规则。

## 7. Context

```text
Asset Library
!= Game Enabled Set
!= Runtime Relevant Set
!= Model Visible Working Set
```

```text
Runtime Relevant != Model Visible
```

目标：

```text
Game State / History ↑↑↑
ordinary Turn Context ≈ bounded
```

但：

```text
bounded != starved
```

Context optimization 去掉不相关信息，不得把当前场景、人物、关系、近期事件和冲突饿掉到 Narrative 泛化。

Timer/cooldown/simple bookkeeping 能由 Runtime 确定处理时，不消耗模型调用。

## 8. Save / Timeline

> **Save Point != Timeline Node.**

Timeline 首先是 persistence/recovery infrastructure，不是公开 debugger。

玩家高频直接操作：Cancel、Regenerate/Retry latest generation。

玩家明确历史恢复：Save important progress、Load/Restore chosen Save。

内部 Timeline 可以有更细 commit/checkpoint/snapshot anchors，但不自动公开成 Load Point。

当前 Deferred：

- 每个历史 Turn 一个 `回到这里`；
- arbitrary per-turn rewind；
- 任意历史节点无成本切换。

读取旧 Save 时，G3 应尽量保留可恢复的旧 current future。

深入设计从治理 `MY_WORLD_架构_CURRENT.md` → `architecture/persistence/时间线存档与可逆性设计.md`。

## 9. UI / Godot

```text
RPG Experience Layer
↓
The World Runtime
↓
Engine Adapter
↓
Godot / Mature Game Foundation
```

UI 是 Runtime truth projection。

长期产品骨架：

```text
Player Host | Narrative Host | World Surface Host
```

G2 固定 UI + Host Slots；G6 Internal Declarative Host；G8 再 externalize 给 World Pack / Mod。

Narrative Host 必须为长篇实时文本提供合理阅读空间；Composer 必须支持多行自然语言行动。不要为了小控件尺寸限制模型或玩家表达。

业务模块内部 `L3 -> L2 -> L1 -> L0` 是另一套依赖分层，不要求大量空目录或 interface。

## 10. 当前开发直接约束

- G2-03：真实 Narrative/input/stream/cancel/regenerate + 三 Host Slots；不做历史 Rewind；不得默认压短模型输出；
- G2-04：正式 Turn / Conversation 与 latest-turn retry 语义；
- G2-05：Context Assembly 必须 bounded but not starved，并开始真正评估带世界材料后的 Narrative richness；
- G3：reliable persistence → resume → explicit Save/Load → Context rebuild → recovery；
- G5：NPC/Faction 真正成为独立历史行动者，并为 Narrative 提供有生命力的世界因果；
- G7：长期世界增长时 model working set 保持有界，同时不能让 Narrative 随长局逐渐失去人物/世界细节。

任何 Agent 想新增全局 Narrative 限制、默认短答、固定字数、Confirmation、Regex 授权表或大型 Validator，都必须先证明存在真实、高频、无法通过更好 Context、可逆 UX 或正常性能工程解决的产品问题。
