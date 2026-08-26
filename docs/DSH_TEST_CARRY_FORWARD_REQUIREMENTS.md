---
title: my world｜DSH 测试经验继承与跨阶段要求
status: current-cross-stage-reference
version: 1.0
created: 2026-08-26
updated: 2026-08-26
source_experiment: https://github.com/zhangchenjia21-dot/the-world
source_core_lessons: the-world/docs/DSH_GAME_TEST_LESSONS_CORE.md
applies_to: G1-G9, especially G3-G9
---

# my world｜DSH 测试经验继承与跨阶段要求

## 0. 使用方式

这份文件给负责 `my world` 的 AI / Agent 使用。

它不是当前阶段 Task Packet，也不授权提前实现未来阶段；它是**跨阶段产品与架构约束**，用于防止新项目重新犯 The World / DSH 长局已经暴露的问题。

当前实现任务、阶段和 Authority 仍以：

- 用户当前指令；
- `AGENTS.md`；
- Vibe-Coding `my world` current Product Spec / Roadmap；
- 当前代码与测试；

为准。

但当工作触及 Persistence、Timeline、World Pack、NPC、Faction、GM Runtime、World Evolution、Context、Save / Restore、RPG UI、长局性能或 Alpha UAT 时，必须检查本文件。

总原则：

> **迁移经验，不迁移宿主债务。**

---

# 1. 必须保护的核心玩家价值

`my world` 的工程成功不能以牺牲 DSH 已经验证的体验为代价。

必须保护：

- 优秀 AI GM 的文本质量与临场创造力；
- 玩家自然语言自由行动；
- 长期持续的 game-local reality；
- NPC / 势力 / 地点 / 关系 / 承诺与后果持续存在；
- 世界知识边界；
- 失败产生新处境，而不是把游戏关死；
- 主角授权边界；
- 世界时间可压缩推进，但 meaningful choice 必须停下；
- Save / Restore 真正回到同一时间线；
- RPG UI、地图、立绘、场景等是游戏体验增强，不是第二状态源。

核心体验基线不是“代码能运行”，而是：

> **使用同一优秀模型时，`my world` 的 RPG 体验不能长期明显弱于 The World / DSH 或简单对话基线。**

---

# 2. 跨阶段不变量

## INV-DSH-01｜Source 只定义起点，不预写未来

World Pack / Source 可以定义：

- T0 前历史；
- 世界规则；
- 人物初始身份与关系；
- 地理、制度、文化；
- 历史惯性与参考资料。

T0 后：

> **game-local reality > source default trajectory**

Future history 不能作为 event scheduler。

禁止把“史上某年会发生什么”长期以 active next-event list 的形式塞进 GM 当前上下文。

## INV-DSH-02｜史料提供惯性，行动者创造历史

> **Source provides inertia, actors create history.**
>
> **史料提供惯性，行动者创造历史。**

重大结果必须从当前世界的 Actor、Faction、资源、制度、信息、地理和事件重新推出。

## INV-DSH-03｜玩家不是唯一历史创造源

> **玩家改变历史，但不是唯一创造历史的人。**

系统必须防止 **Protagonist Causal Monopoly / 主角因果垄断**：

```text
错误状态：
Source 推进历史
+
Player 改变历史
+
NPC 只回应 Player

目标状态：
Player / NPC / Faction / Institutions / Resources
互相作用
→ New History
```

## INV-DSH-04｜Off-screen != Inactive

> **离开镜头，不等于停止行动。**

重要 Actor / Faction 在玩家不接触时仍可以推进自己的目标。

但这不要求全世界逐 tick 模拟。

## INV-DSH-05｜Persistent != Fully Simulated

不要实现“每个 NPC 每回合跑一次模型”。

世界演化应按：

- 时间推进；
- 重大事件；
- 当前高影响 Actor / Faction / Front；
- 与玩家和世界的因果相关性；

选择性运行。

## INV-DSH-06｜Dice 决定不确定性，不抹除人物

> **Dice decides uncertainty. Dice does not erase character.**

人物底线、已成立事实和物理不可能不能因为一次高骰自动失效。

## INV-DSH-07｜Meaningful Choice 要有不同 Risk Profile

不要让不同方案只是换一段文案以后都变成相同 `d20 vs DC15`。

风险至少可在以下轴变化：

- 是否需要检定；
- DC；
- 优势 / 普通 / 劣势；
- 失败 Stakes；
- 暴露、资源、时间、关系、身份、伤害和局势升级。

## INV-DSH-08｜UI 只投影真相

> **UI is a projection of game truth, not a second truth source.**

地图、人物、关系、任务、机制、物品 UI 都不能自己拥有第二份 authoritative gameplay state。

## INV-DSH-09｜Model authors candidates; Program commits reality

模型适合：

- 理解玩家自由语言；
- 生成 NPC / 世界行动候选；
- 叙事；
- 语义判断；
- 开放内容创作。

程序 / Domain Owner 负责：

- identity；
- 权限 / ownership；
- RNG；
- authoritative mutation；
- atomic persistence；
- Save / Restore；
- 时间线；
- 结构与约束。

但不要因此预造 Universal Schema / Universal ECS。

---

# 3. G1｜Foundation 需要保留的注意事项

G1 当前仍是 Foundation Spike，不因为本文件而扩大范围。

与 DSH 经验相关的要求只有：

- AI 流式输出必须不冻结 UI；
- Cancel / Error 要有可恢复状态；
- 中文长文本是核心 surface，不是附加测试；
- 本地 IO、图片资产和 Windows Export 必须真实可用；
- Provider 接入保持窄，不提前造通用 AI 平台；
- G1-06 决定 Runtime 边界时，必须考虑 G3 / G5 / G7 的长期需要，而不仅是短 Demo 代码最省事。

特别注意：

> DSH 后期最明显的问题之一就是长局 Context / 文件维护越来越慢。

因此任何 G1 架构选择如果明显会迫使未来把全部长期世界状态绑在 UI Node / Scene Tree / 无界 transcript 上，应在 G1-06 记录为风险。

---

# 4. G2｜AI Conversation Spine

G2 不只是“聊天框能调模型”。

必须保护：

- 自然语言玩家输入；
- 高质量 GM 流式输出；
- 玩家可以在 GM 输出后立即继续；
- Cancel / Retry 不制造隐藏重复 Turn；
- Conversation 是表现 / Context 来源之一，不等于权威 World State；
- 后台状态工作不得挡在叙事前面。

正式 UX 原则：

> **Narrative first; background work afterward while the player reads.**

不要为了追求后台一致性，让玩家每回合先等待一大段 maintenance 才看到故事。

G2-GATE 应至少有同模型基线比较：

```text
my world GM output
vs
简单模型聊天 / DSH reference
```

如果工程更稳定但明显更无聊、拘谨、机械，应判产品风险，而不是“以后 polish”。

---

# 5. G3｜Persistent Game & Timeline

这是 DSH 经验中最应重新设计的一层。

## G3-REQ-01｜Authoritative State 即时提交

不要复制：

```text
DELTAS
→ 等 N 回合
→ 模型 consolidation
→ 批量 edit Owner Markdown
```

目标：

```text
World Mutation
↓
一次可靠提交
↓
Authoritative State 即时成立
↓
UI / Context / Save 从同一事实派生
```

允许 Event Log、Snapshot、数据库、Projection 等不同实现，但技术方案应由 G3 的真实 vertical 决定。

## G3-REQ-02｜Timeline 是一级 Domain

从第一版区分：

- Game；
- Timeline；
- Save Point；
- World State；
- Agent Context；
- Conversation History。

不要再次让 Host Session 代理 RPG Timeline。

## G3-REQ-03｜Restore Future-memory Isolation

必须有产品测试：

```text
Save at T2
→ play to T5
→ Restore T2
→ continue
```

PASS 条件：

- World = T2；
- Context = T2 可解释信息；
- T3–T5 的未来不能继续影响模型；
- UI 不残留未来状态。

## G3-REQ-04｜Save identity 不可歧义

玩家展示名与内部 identity 分离。

不能出现两个存档共享同一 storage key 然后“取第一个”。

## G3-REQ-05｜Recovery artifacts 与 Player Saves 分离

Crash / pre-restore protection / recovery material 不应污染普通 Save 列表。

---

# 6. G4｜World Pack & Local Content Foundation

## G4-REQ-01｜Source / Local Instance / Runtime State 分层

World Pack 是 reusable Source。

一局开始后必须形成独立 local reality。

Source 更新默认不能重写旧游戏已经发生的事实。

## G4-REQ-02｜未来史料不能成为主动脚本

历史世界可以带：

- T0 前事实；
- 史料；
- 人物参考；
- 典型趋势；
- 原历史 trajectory 作为 reference。

但 Runtime 不应持续把“未来几年将发生 X/Y/Z”作为 active context。

历史参照应按需检索，不能成为自动事件队列。

## G4-REQ-03｜美术资产是一等 World Pack 能力

首代至少考虑：

- portrait；
- scene art；
- map；
- world-specific UI / display metadata。

地图首代保持 authored-first：

> **World Pack 作者提供专属地图，通用客户端负责展示、缩放、拖动和当前位置投影。**

不要在 G4 提前实现自动地图生成、GIS、寻路或统一世界坐标引擎。

---

# 7. G5｜World Semantics & GM Runtime —— DSH 最大教训的落地点

G5 不能只做“NPC 会说不同的话”。

G5 必须证明：

> **世界在没有玩家直接推动时也能创造新的、合理的历史。**

## G5-REQ-01｜Actor Agency

重要 NPC 至少要能维持语义上等价于：

```text
Current Agenda
Fear / Cost
Red Line
Obligation
Independent Next Move
```

不要求统一 JSON Schema；但 Runtime 必须能回答：

> 玩家暂时不理这个人，他自己准备做什么？

## G5-REQ-02｜Faction / Organization Agency

诸侯、政权、组织、家族、军队、商会等不能只是 NPC 外壳。

高影响 Faction 需要：

- 当前战略目标；
- 资源 / 约束；
- 已知威胁；
- 外交 / 内部矛盾；
- 可采取的下一步。

## G5-REQ-03｜World Evolution

实现一个**事件驱动、优先级驱动**的世界演化过程，而不是全世界 tick。

概念流程：

```text
时间推进 / 重大变化
↓
选出当前值得模拟的 Actors / Factions / Fronts
↓
读取其 Goal / Belief / Resources / Relationships / Obligations / Threats
↓
形成各自动作
↓
动作互相碰撞
↓
产生 World Events / Durable Mutations
↓
GM 再选择哪些进入玩家视野
```

具体 Planner / Resolver / Commit 边界由 G5 架构设计决定，不要在 G1–G4 提前写死。

## G5-REQ-04｜Counterfactual Propagation

关键事实改变不能只更新一个人物卡。

必须识别受影响者并传播：

```text
Changed Fact
↓
Who cares / Who knows / Who benefits / Who is threatened
↓
Beliefs / Plans change
↓
New actions
```

典型 DSH 失败案例：

- 卢植没有按原历史失势；
- 皇甫嵩全胜并长期掌权；
- 但 189 政局仍大体按原历史播放器推进。

未来 PASS 标准不是“改变一定让玩家赢”，而是：

> **原历史结果如果仍发生，也必须是在改变后的棋盘上重新被因果推出。**

## G5-REQ-05｜Adaptive Opposition

世界难度不能主要靠抬 DC。

强玩家应该自然导致：

- 对手重新结盟；
- 中立者防范；
- 下属利益冲突；
- 好友因底线反对；
- 制度性阻力；
- 资源竞争；
- 信息战与误判。

“世界反抗玩家”真正含义是：

> **世界有自己的目标，不是专门惩罚玩家。**

有时它也会在玩家不在场时主动帮玩家。

## G5-REQ-06｜NPC 人格要进入风险与决策

同一句沟通方式对不同人物应产生不同风险。

例如：

- 重证据者因证据充分获得优势；
- 重名分者可能因越线方案直接拒绝；
- 好大功者可能被荣耀 / 风险收益打动；
- 直率人物可能厌恶复杂话术。

人物差异必须影响：

- 是否可行；
- Advantage / Disadvantage；
- DC；
- Failure Stakes；
- 后续关系。

## G5-REQ-07｜知识来源继续严格

自主行动不能变成全知 AI。

Actor 做计划前只能使用其合法知道的信息。

世界演化中的每个重要行动都要能解释：

> 这个人为什么知道？为什么现在做？为什么有能力做？

---

# 8. G5 必须加入的三项核心产品测试

## TEST-WORLD-01｜Player Absence Test

把玩家放在偏远地点，或让玩家一年不干预主线政治。

PASS：

- 世界发生来自 NPC / Faction 的新变化；
- 这些变化能由当前目标和条件解释；
- 不是简单播放 Source future timeline。

FAIL：

- 天下除了历史脚本外几乎不动；
- 所有关键事件都等玩家触发；
- 世界变化只发生在玩家附近。

## TEST-WORLD-02｜Counterfactual Propagation Test

人工建立一个明显偏离 Source 的关键前提。

例如：

```text
重量级政治人物没有失势
关键战争结果被改写
一个原本弱小势力提前变强
```

然后玩家不参与相关区域数年。

PASS：其它 Actor / Faction 的战略产生可解释的新分叉。

FAIL：原历史节点仍按时间表逐一发生，仅换几个角色或措辞。

## TEST-WORLD-03｜Independent Actor Test

选择重要 NPC A。

记录：

> 如果玩家一年不与 A 接触，A 当前准备做什么？

推进世界。

PASS：A 大体按自己的目标行动，或因为中途新世界事实合理改计划。

FAIL：A 原地等待玩家，或突然按 Source 未来史实行动但没有当前动机链。

---

# 9. G6｜RPG Experience & 2D Presentation

DSH 已证明 RPG UI 有价值，但 UI 不应替代世界语义。

G6 建议优先级仍应由玩家真实需要驱动。

核心 surface：

- Narrative；
- Character Portrait；
- Scene Art；
- Map；
- Character / Relationship / Thread / Mechanic / Inventory 等状态 UI。

地图首版：

```text
Authored map asset
+
location mapping
+
player marker
+
zoom / pan
```

不提前做：

- 点击地图自动移动；
- 路径规划；
- GIS；
- 自动 POI；
- 动态势力边界；
- 自动地图生成。

只有真实试玩出现需求后再扩。

---

# 10. G7｜Long-session Context & Performance

这是 DSH 退出的直接原因之一，必须成为正式 Gate。

## G7-REQ-01｜Context 不能随世界历史无界增长

需要区分：

```text
Total World State
!= Current Relevant State
!= Model Working Context
```

Context Assembly 应只给当前任务足够的信息。

## G7-REQ-02｜Transcript 不是长期世界数据库

完整聊天历史不能成为唯一长期记忆。

需要可恢复的：

- authoritative facts；
- recent scene / narrative continuity；
- relevant actor state；
- active fronts / threads；
- knowledge boundaries。

## G7-REQ-03｜不要重新发明“大 consolidation”

允许 background compaction / projection rebuild，但不能让系统长期依赖：

> 每 N 回合让模型重读大量状态并批量修正文档。

## G7-REQ-04｜长局必须真实压测

至少建立跨多年 / 多势力 / 多人物长局测试。

记录：

- Context token / chars；
- GM first-token latency；
- full generation latency；
- state commit latency；
- Save / Restore latency；
- memory footprint；
- UI responsiveness。

不能只凭 20 回合 Demo 宣布 G7 PASS。

---

# 11. G8｜Mod / Authoring Ecosystem

World Pack / Mod 是一级能力。

必须保留：

- Source 与运行局隔离；
- World Pack 可带地图 / 立绘 / 场景 / Source Lore / 初始人物 / 可选机制；
- game-local reality 不反向污染 Source；
- Source 升级对旧游戏的影响必须显式；
- 作者不需要理解底层 Runtime 数据库才能写普通世界内容。

不要因为 Mod 需求提前暴露所有内部 Domain 类型或允许任意脚本获得权威写权限。

---

# 12. G9｜Standalone Alpha / Release Validation

G9 不应只看工程稳定性。

最终 Alpha 至少同时验证：

## Engineering

- 安装 / 启动；
- Provider；
- 本地持久化；
- Save / Restore；
- 无明显数据损坏；
- 长局性能；
- Crash / recovery；
- World Pack 安装与加载。

## Product Value

- 同模型 GM 质量不明显弱于 DSH / simple baseline；
- 玩家自然语言自由度成立；
- NPC 有明显不同的自主性；
- 世界在玩家离屏时继续演化；
- Counterfactual 会传播；
- 历史世界不会退化为时间表播放器；
- 玩家成功会产生合理的新政治 / 社会 / 人物难度，而不是仅数值膨胀；
- 长期游玩仍有沉浸感；
- UI / 美术增强而不压过对话式 RPG 主循环。

Alpha 的最终 Product PASS 必须由真实 Owner / 玩家长局体验裁定。

---

# 13. 明确不要带进 my world 的 DSH 实现

不要复制：

- DSH Session workaround；
- Restore 后 fresh DSH session seam；
- `fs.watch` Restore workaround；
- DSH Plugin Lifecycle；
- 周期性模型 consolidation 作为主状态一致性；
- DELTAS + 批量 Markdown edit Runtime；
- Markdown 默认权威 gameplay DB；
- 通用 Agent Workspace 的目录结构直接决定 Player UI；
- Active Context 中长期携带 Source future event checklist；
- “玩家改变，NPC 回应，历史继续播放”的主角因果垄断模式。

可以继承的是这些 workaround 背后暴露的需求，而不是实现本身。

---

# 14. 负责项目的 AI 每次做相关设计时应自问

当任务涉及 G3–G9，至少检查：

1. 这个设计是在解决已观察到的真实问题，还是因为理论上“可能需要”？
2. 它是否保护 GM 输出质量和玩家自由度？
3. Authoritative truth 在哪里？是否产生第二真相？
4. Save / Restore 是否同时恢复 Timeline 和 Agent Context？
5. Source 是参考还是偷偷变成剧本？
6. 玩家不干预时，重要 Actor / Faction 会不会自己行动？
7. 一个改变的事实能否影响远方有利益关系的人？
8. NPC 是否只有台词差异，还是目标 / 底线 / 行动真正不同？
9. 难度来自世界因果，还是机械抬 DC？
10. 当前 Context 是否只包含真正相关的信息？
11. 这个系统是否会在 5 年长局后明显变慢？
12. 是否正在把 Godot / Provider / Database 的技术概念误当成产品 Domain 语义？

如果这些问题没有答案，不要因为代码已经能跑就宣布相关 Stage 的产品目标完成。

---

# 15. 最终提醒

The World / DSH 已经证明：

> **Persistent World 是必要的。**

最后阶段又证明：

> **Persistent World 不等于 Autonomous Evolving World。**

`my world` 下一代真正需要跨过去的是这一条。

最终目标不是做一个“记忆更好的聊天 RPG”，而是：

> **一个会自己产生历史的世界，AI GM 把其中最有意义的部分组织成玩家正在经历的故事。**
