---
title: my world｜G2-05 Context Assembly v0.1 Task Packet
status: current-task-packet
task_id: G2-05
type: implementation
owner: Codex
created: 2026-08-26
updated: 2026-08-26
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: d1acd2a58e00fd99b73ab98bc3ccdc3c79762951
agent_rules_base: 5472045998865ffdb4eea969d3faa376aa7af415
local_project: D:\AI\Projects\my-world
---

# TASK｜G2-05｜Context Assembly v0.1

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `d1acd2a58e00fd99b73ab98bc3ccdc3c79762951`

## 1. Outcome

把 G2-04 仍暂存在 `Conversation.build_provider_messages()` 内的请求拼装责任迁移成第一版正式、独立、纯内存的 **Context Assembly v0.1**。

完成后 ownership 必须是：

```text
Conversation Domain
→ owns Turn / accepted player+GM truth / generation lifecycle
→ exposes read-only derived context projection

Context Assembly
→ owns GM/system instruction composition
→ owns bounded Conversation working-set selection
→ accepts current minimal Game Context material
→ produces Provider messages

Narrative UI
→ input + render/projection + action dispatch

Provider Adapter
→ transport only
```

本任务不建设 World/NPC/Game persistence；生产路径当前可以没有真实 Game Context material，但必须建立一个诚实、可测试的输入 seam，让未来正式 Game/World projection 能提供材料而不重写 Context Assembly。

本任务完成后最高状态：

> **READY FOR INDEPENDENT REVIEW**

不得自行宣布 G2-05 PASS，也不得开始 G2-06 / G3。

---

## 2. Why Now

G2-04 已通过 Independent Review，Conversation / Turn truth、Retry / Regenerate / correction、accepted replacement / rollback 语义已稳定。

但 `Conversation.build_provider_messages()` 仍同时知道：

- Provider role/message 结构；
- 当前 attempt 怎样进入 prompt；
- 哪些 accepted turns 进入 request。

这会让 Conversation Domain 继续承担 Context policy，并使未来 G4/G5 Game/World projection、G7 bounded/retrieval evolution 无处自然接入。

G2-06 是第一轮 Owner Playtest，因此在此前必须把请求 Context ownership 放到正确位置，但不能为了未来需求提前造 long-memory platform。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` — current product definition；Primary Purpose = 长期持续 AI RPG + 高质量自由 AI GM。
3. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md` — current core design；特别是 `Narrative richness over artificial brevity`、`Context stays bounded, not starved`。
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G2-05 = system/GM instructions + current Conversation working set + current minimal game context；不做复杂 retrieval/long-memory platform。
5. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — G2-04 PASS、G2-05 current。
6. 本仓库 `AGENTS.md`、当前实现、测试、HEAD。
7. `Skill/main/skill/gpt/agent-task-packet/SKILL.md` v1.2 与 `skill/gpt/lifecycle-dev-process/SKILL.md` v2.2 仅用于执行方法，不覆盖本项目更高权威的产品裁定。

Not authoritative unless explicitly referenced:

- archive / legacy-reference；
-旧 G2-03/G2-04 repair 状态；
- historical chat summary；
- The World / DSH 的旧 Context implementation。

---

## 4. Read First

开始时：

1. fetch / fast-forward 最新 `origin/main`；
2. 记录 start HEAD 与 `git status --short`；
3. 确认本 Task Packet 是 current G2-05 packet；
4. 按顺序只读：

```text
AGENTS.md
本 Task Packet
docs/CORE_DESIGN_PRINCIPLES.md
src/domain/会话.gd
src/domain/对话回合.gd
src/ui/叙事对话视图.gd
src/provider/deepseek流式适配器.gd
tests/g2_04_会话域离线测试.gd
tests/g2_03_会话视图离线测试.gd
```

只有证据不足时才扩大读取范围；Final Report 说明扩大原因。

---

## 5. Pre-implementation State Matrix｜先列清楚再编码

在写实现前，先在 scratch / working notes 中明确以下 request shape；不要求新建长期文档，但 Final Report 必须给出简表证明没有遗漏。

维度 A：attempt 类型

```text
new turn
retry unaccepted latest
regenerate completed latest
correct completed latest
```

维度 B：Conversation working set

```text
short history (< limit)
full history (> limit)
```

维度 C：Game Context

```text
empty
non-empty fixture
```

至少逐项回答：

- previous accepted pairs 哪些进入；
- current attempt user 是否恰好一次；
- current Turn 的 old accepted pair 是否应该排除；
- request last role；
- game context 放在哪个 system section；
- working-set 达到上限时哪个完整 Turn 被排除。

不得先编码再让测试偶然决定语义。

---

## 6. Decision Digest / Invariants

### DEC-01｜Context Assembly 是 derived request owner，不是 truth owner

建立最小 `Context Assembly` 对象/模块，推荐放在语义清楚的 `src/context/` 下，使用 plain GDScript / `RefCounted` 或等价轻量对象。

它可以拥有：

- request message composition；
- system/GM instruction composition；
- Conversation working-set selection；
- Game Context material inclusion；
- request-level diagnostics/test projection。

它不能拥有：

- Turn accepted truth；
- Game / World / NPC authoritative state；
- persistence；
- Provider transport；
- UI state。

### DEC-02｜Conversation 只提供 read-only context projection

`Conversation` 可以新增一个最小 read projection，例如等价于：

```text
accepted_turns:
  [{turn_index, player_text, gm_text}, ...]

active_attempt:
  null
  or {turn_index, player_text}
```

具体函数名/Dictionary shape 可调整，但必须满足：

- 返回 derived copy/read model，不给 Context Assembly 第二套 mutable truth；
- Context Assembly 不直接修改 Turn；
- active attempt player text = 当前实际将发给 Provider 的 pending text；
- accepted turns 仍来自 Domain accepted truth；
- 不在 Conversation 里做 working-set trim / system prompt composition。

如果需要额外 mode 字段才能无歧义表达当前 attempt，可以最小增加；不要造通用 DTO framework。

### DEC-03｜退休 `Conversation.build_provider_messages()`

G2-05 完成后 Provider request assembly 不再由 Conversation 拥有。

无真实外部兼容义务，因此：

> **Supersession before compatibility.**

优先移除/退休 `build_provider_messages()` 并迁移所有调用和测试；不要保留一个偷偷继续工作的 legacy fallback。

### DEC-04｜第一代 bounded Conversation working set = 最近 12 个完整 accepted Turn + current attempt

第一代明确策略：

```text
RECENT_ACCEPTED_TURN_LIMIT = 12
```

请求最多携带：

- 最近 12 个**完整 accepted Turn pairs**；
- 当前 active attempt 的 player user 恰好一次；
- system message。

规则：

- 以完整 Turn 为单位取舍；
- newest-first 选择、最终仍按原始 chronological order 发送；
- 不截断某一条 player text / GM text；
- 不对单条 Narrative 做字符裁切；
- 不 summarize；
- current active attempt 永远不能因为窗口满而被丢弃。

这只是 G2 第一代 working-set policy，不是永久产品 token。G7 可基于真实 long-play evidence 改为 relevance/subgraph/summary 等更高级策略。

### DEC-05｜Regenerate / Correction request 继续遵守 G2-04 语义

对于 completed latest Turn：

```text
old accepted current pair
→ remains Domain truth until success
→ but is excluded from current replacement request
```

所以 Regenerate：

```text
recent previous accepted pairs
+ current original player text
```

Correction：

```text
recent previous accepted pairs
+ corrected current player text
```

两者 request 都以 current `user` 结束；current old assistant 不得进入 request。

不得重新引入 IR-03。

### DEC-06｜Retry unaccepted Turn

cancelled / failed / `empty_generation` 的 latest Turn 若尚无 accepted response：

```text
recent accepted pairs
+ same logical turn pending player text
```

- same turn identity；
- player text 恰好一次；
- cancelled/failed partial draft 不进入 context。

### DEC-07｜GM/System Instructions 由 Context module 组装

把当前 provisional GM instructions 从 UI-local prompt ownership 迁移到 Context module 或等价 context-owned source。

当前语义继续保持：

- 玩家输入是自由游戏行动/意图；
- 自然、沉浸中文 RPG Narrative；
- 充分展开有价值的环境、人物、行动、对话与后果；
- 不必刻意简短；
- 场景决定篇幅；
- 不输出工程说明。

不得增加：

- `max_tokens`；
- minimum/maximum word count；
- “请简短回答”；
- Narrative whitelist / Regex / Confirmation。

### DEC-08｜Current minimal Game Context = input material seam，不伪造 World truth

G2-05 必须支持一个**非 authoritative、derived material input**，第一版可以是简单 UTF-8 text / small section object，例如：

```text
game_context_text: String
```

当非空时，Context Assembly 在 system message 中明确分节，例如：

```text
GM Instructions
...

Current Game Context
...
```

要求：

- Game Context material 只进入 system/context material section；
- 不冒充 user/assistant conversation entry；
- 不成为 Conversation truth；
- Context Assembly 不解析它为 Character/World authoritative schema；
- production 当前没有正式 Game/World state 时可以传空；**禁止为了“看起来有 game context”硬编码虚构角色/地点/状态**；
- focused tests 必须注入非空 fixture，证明未来正式 Game/World projection 可接入。

### DEC-09｜空 Game Context 不得向模型暴露工程阶段说明

如果 production 当前传空 context：

- 可以省略 `Current Game Context` section；
- 不得发送“目前还没实现 World State”“这是 G2-05 测试”等工程文字给 GM。

### DEC-10｜Context bounded != Narrative short

Input Context working set 有界，不代表输出要短。

保持：

> **Narrative richness over artificial brevity.**

不要为了 recent-window 策略顺手增加 output cap / short-answer prompt。

### DEC-11｜No long-memory platform

本任务明确不实现：

- embeddings；
- vector DB；
- semantic retrieval；
- RAG framework；
- summarization/consolidation；
- token estimator / tokenizer service；
- dynamic token budget platform；
- lorebook engine；
- Context plugin/provider registry；
- background memory agent。

这些能力只有真实 G7 evidence 需要后再设计。

### INV-PRODUCT-01｜Context 应增加材料，不应成为创作约束层

Context Assembly 的目标是让模型拿到当前相关材料并维持 continuity，不是“让模型只能说 Context 里已经写过的东西”。

禁止把 game context 实现成 Narrative whitelist。

### INV-OWNERSHIP-01｜Derived material cannot write back

Context snapshot/messages 只能读取 Conversation/Game projections，不能反向修改 authoritative state。

### INV-SCOPE-01｜G3/G4/G5/G7 未授权

不实现 Persistence / Save / Timeline / World Pack / Character / NPC / Faction / World evolution / long-session retrieval。

---

## 7. Expected Request Shapes

这些是 Acceptance 语义，不要求 exact internal API 名称。

### New Turn after short history

```text
system(instructions + optional game context)
previous user1
previous assistant1
...
current user
```

### Retry unaccepted latest

```text
system
recent accepted pairs
same pending current user
```

### Regenerate completed latest

若 latest accepted = `userN + assistantN_old`：

```text
system
recent accepted pairs BEFORE current turn
userN
```

要求：`assistantN_old` 不在 request，Domain 内仍稳定保留。

### Correction completed latest

```text
system
recent accepted pairs BEFORE current turn
corrected userN
```

old userN / old assistantN 不进入 request，Domain 内旧 accepted pair 在 replacement 成功前继续稳定。

### Full window

若存在 20 个 previous accepted turns，再发送一个 new Turn：

```text
only turns 8..19 (12 complete pairs)
+ current user
```

不能出现 orphan user/assistant，也不能把 turn7 的一半截进来。

---

## 8. Allowed / Prohibited Scope

### Allowed

- 新增最小 `src/context/...` Context Assembly 文件；
- Conversation 新增 read-only derived context projection；
- 移除/退休 `Conversation.build_provider_messages()`；
- 修改 Narrative UI 以调用 Context Assembly；
- 移动 provisional GM instructions 到 context ownership；
- 新增 focused G2-05 tests；
- 更新现有 G2-04/G2-03 tests 适配新 owner；
- 必要的小型 diagnostics/test seam。

### Prohibited

- Provider Adapter redesign；
- World/Character/NPC/Faction Domain；
- Persistence / Save / Timeline；
- World Pack；
- retrieval / embeddings / summarization / long-memory；
- arbitrary transcript editing；
- UI redesign / new RPG panels；
- Context plugin architecture；
- output-length caps；
- EventBus / DI / service locator / generic command bus。

若完成任务必须依赖禁止项，停止并返回 blocker。

---

## 9. Required Deliverables

1. Context Assembly v0.1 independent owner。
2. Conversation read-only context projection。
3. `Conversation.build_provider_messages()` retirement。
4. UI → Context Assembly → Provider integration。
5. deterministic G2-05 focused tests covering state matrix。
6. recent-12 whole-turn working-set boundary tests。
7. non-empty Game Context fixture inclusion test + empty production behavior test。
8. G2-04 IR-03/IR-04 / Retry / Regenerate / correction regressions。
9. real DeepSeek streaming / Cancel / Regenerate smoke after migration。
10. Windows export + direct launcher regression。
11. one implementation commit + fast-forward push + clean status。

不要求新建 architecture CURRENT/supporting design；若发现需要改变 canonical Context architecture 的新事实，先返回说明，不自行扩张文档树。

---

## 10. Engineering Acceptance

### AC-01｜Context owner separation

静态 review 证明：

```text
Conversation != Provider-message assembler
Provider != Context owner
UI != conversation/context truth owner
```

### AC-02｜Normal new Turn

short history 下：previous accepted complete pairs + current user；current user exactly once；last role == user。

### AC-03｜Retry

cancel/fail/empty_generation latest retry：same logical turn player text exactly once；partial draft absent；previous accepted pairs preserved。

### AC-04｜Regenerate

completed latest regenerate：current old assistant absent；current user exactly once；previous accepted pairs preserved；last role == user；Domain old accepted pair remains unchanged until completion。

### AC-05｜Correction

completed latest correction：current old user/assistant absent from request；corrected user exactly once；previous pairs preserved；failed/empty correction keeps Domain old accepted pair。

### AC-06｜Bounded whole-turn working set

构造至少 15 个 completed turns，再开始新 Turn：

- request contains exactly latest 12 accepted complete pairs + current user；
- oldest retained index 正确；
- dropped turn user/assistant 都不存在；
- retained turn user/assistant 都完整；
- chronological ordering correct；
- no partial text truncation。

### AC-07｜Game Context material

non-empty fixture：

- appears exactly once in system content；
- does not appear as user/assistant；
- GM instructions preserved；
- Conversation entries unchanged。

empty production/default：

- no fake engineering-stage placeholder；
- normal request still valid。

### AC-08｜Narrative freedom preserved

- Provider payload still has no convenience `max_tokens` cap；
- GM instructions retain richness guidance；
- one-character GM completion remains valid via G2-04 Domain semantics；
- `empty_generation` behavior preserved。

### AC-09｜No second truth / no mutation

Context projection/messages are derived copies/read models; modifying returned dictionaries in a focused test must not mutate Domain accepted truth, or equivalent evidence proving no reverse write path。

### AC-10｜Real integration

真实 DeepSeek 至少证明：

```text
new Turn stream
→ completed
→ completed latest Regenerate
→ request-context assertions still correct
→ new stream completed
```

Cancel smoke 保持。

### AC-11｜Regression

G2-02 adapter smoke、G2-03 offline/GUI relevant paths、G2-04 domain tests、IR-03/IR-04 全部保持通过。

### AC-12｜Scope

没有 G3/G4/G5/G7 提前实现，没有 retrieval/summarization platform，没有 UI redesign。

---

## 11. Product Value Acceptance

G2-05 本身主要是 engineering ownership/context foundation，不单独要求 Owner UAT。

它服务的 Core Value 是：

> **高质量 AI GM 能获得足够的当前相关材料，同时 Context 不随总历史无界膨胀。**

Engineering 可证明 Context shape / boundedness / ownership；不能证明 Narrative 最终是否更沉浸、更自然。

真正 Product Value Gate 留给下一任务：

> **G2-06 第一轮 Owner Playtest**

因此 G2-05 Agent 最高只报告：

> `READY FOR INDEPENDENT REVIEW`

---

## 12. Validation

按 focused → full：

1. Godot headless parse。
2. 新 G2-05 Context focused tests。
3. G2-04 domain tests。
4. G2-03 offline tests。
5. G2-02 Adapter smoke。
6. real GUI + real DeepSeek new Turn / Regenerate / Cancel smoke。
7. typography/responsive smoke，不要求新视觉截图除非发生回归。
8. Windows export。
9. `run-game.cmd` / `run-game.ps1` smoke。
10. `git diff --check`。
11. secret / Authorization hygiene。
12. `git status --short` clean。

Real Provider test 如遇可明确归因的供应商瞬时失败，可以 bounded retry 一次以区分环境波动；不得用无限重跑掩盖 deterministic failure。任何 deterministic assertion failure 必须修复或返回 BLOCKED。

GUI automation必须使用 exact executable + PID；禁止 fuzzy window-title kill。

---

## 13. Git / Freshness

- 开始记录 start HEAD / status；
- 不覆盖未知 dirty worktree；
- implementation 前确保已吸收本 Task Packet；
- authoritative write / push 前 fetch 并重新比较 task base 与 current origin/main；
- 若远端前进，先审计增量、rebase/吸收并重新跑受影响验证；
- fast-forward push only；
- no force push。

---

## 14. Stop / Return Conditions

立即停止并返回 `BLOCKED`，如果：

- current canonical source 与本 packet 对 Context ownership 冲突；
- 需要提前建立 World/Character/Persistence 才能完成；
- recent-12 policy 暴露真实产品 blocker，需要重新裁定；
- Conversation projection 无法在不泄露 mutable truth 的情况下提供所需数据；
- real integration 暴露 deterministic Provider/Domain contract conflict；
- freshness 显示任务已被 supersede。

不要自行扩大 scope。

---

## 15. Final Report

```text
Result
READY FOR INDEPENDENT REVIEW | BLOCKED

Freshness
- start HEAD
- pre-push HEAD/origin

Pre-implementation Matrix
- new / retry / regenerate / correction request shapes
- short / full working set behavior
- empty / non-empty game context

Context Shape
- Context Assembly owner/API
- Conversation read projection
- GM instructions ownership
- game context seam
- build_provider_messages retirement

Bounded Working Set Evidence
- limit
- 15+ turn fixture
- retained/dropped indices
- whole-turn / ordering evidence

Behavior Evidence
- new
- retry
- regenerate
- correction
- empty_generation preservation

Game Context Evidence
- non-empty fixture
- empty production behavior

Real Integration
- DeepSeek new turn
- Regenerate
- Cancel

Scope Check
- no G3/G4/G5/G7
- no retrieval/summarization platform
- no output cap

Validation
- focused/full results

Git
- implementation commit
- push
- clean status
```
