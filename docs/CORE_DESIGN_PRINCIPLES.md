---
title: my world｜核心设计原则（实现仓库导读）
status: current-repository-reference
version: 1.2
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
> **Runtime owns durability.**
>
> **Source provides inertia; actors create history.**
>
> **Context stays bounded.**
>
> **Player owns the timeline.**
>
> **Reversibility != frictionless arbitrary rewind.**

中文执行含义：

- 模型尽可能自由地创造 Narrative 与世界；
- Runtime 负责 stable identity、原子持久化、恢复与安全，不当 Narrative 审查器；
- 玩家、NPC、Faction 共同创造历史；
- 世界可以无限增长，单轮模型 working set 不能线性增长；
- 局部错误低成本纠正，重大历史恢复必须有明确玩家意图。

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

业务模块内部 `L3 -> L2 -> L1 -> L0` 是另一套依赖分层，不要求大量空目录或 interface。

## 10. 当前开发直接约束

- G2-03：真实 Narrative/input/stream/cancel/regenerate + 三 Host Slots；不做历史 Rewind；
- G2-04：正式 Turn / Conversation 与 latest-turn retry 语义；
- G3：reliable persistence → resume → explicit Save/Load → Context rebuild → recovery；
- G5：NPC/Faction 真正成为独立历史行动者；
- G7：长期世界增长时 model working set 保持有界。

任何 Agent 想新增全局 Narrative 限制、Confirmation、Regex 授权表或大型 Validator，都必须先证明存在真实、高频、无法通过更好 Context 或可逆 UX 解决的产品问题。
