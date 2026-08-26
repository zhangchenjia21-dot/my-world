---
title: my world｜G2-04 Turn / Conversation Domain v0.1 Task Packet
status: current-task-packet
task_id: G2-04
type: implementation
owner: KimiCode K3
created: 2026-08-26
updated: 2026-08-26
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: e59df07d4f5670e19f3b872c78c2359d2a7ef132
local_project: D:\AI\Projects\my-world
---

# TASK｜G2-04｜Turn / Conversation Domain v0.1

Type: `implementation`  
Owner: `KimiCode K3`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`  
Formal Code Base: `e59df07d4f5670e19f3b872c78c2359d2a7ef132`

## 1. Outcome

把 G2-03 已通过 Owner UAT 的 Narrative Conversation View 从“UI 自己维护 provisional conversation truth”升级为第一版正式、纯内存的 **Turn / Conversation Domain v0.1**。

完成后：

```text
Conversation Domain
→ owns Turn ordering / player text / accepted GM result / generation lifecycle
→ owns Retry / Regenerate / latest-turn correction semantics

Narrative UI
→ input + render/projection + player action dispatch

Provider Adapter
→ transport only
```

同时完成 G2-03 Owner 留下的一个小型 UX carry-forward：把当前整体偏小的字体调整到**中等可读默认大小**。本任务不建设字体设置系统。

本任务完成后最高报告：

> **READY FOR INDEPENDENT REVIEW**

不得自行宣布 G2-04 PASS，也不得开始 G2-05。

---

## 2. Why Now

G2-03 已由 Owner 明确 PASS。真实 DeepSeek streaming、Cancel、Regenerate、failure recovery、响应式三 Host 与 Composer 已成立。

但当前 `src/ui/叙事对话视图.gd` 仍通过 UI-local `_history`、`_current_turn_in_history`、`_replacing_recorded_turn` 等状态承担 Conversation 语义。G2-05 Context Assembly 若直接消费这些 UI 私有状态，会把错误 ownership 固化到后续架构。

因此必须先建立正式 Conversation owner，再进入 G2-05。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md` — current canonical core design；包含 `Model freedom first`、`Narrative richness over artificial brevity`、`Context stays bounded, not starved`。
3. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md` — current architecture map；按需导航 supporting design。
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G2-04 / G2-05 DAG 与阶段边界。
5. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — G2-03 PASS、G2-04 current、字体 carry-forward。
6. 本仓库 `AGENTS.md`、当前实现、测试、HEAD。
7. `Skill/main/skill/gpt/agent-task-packet/SKILL.md` 与 `skill/gpt/lifecycle-dev-process/SKILL.md` 仅用于执行方法；不得覆盖本项目更高权威的模型自由 / Runtime durability 裁定。

Archive、旧聊天、旧 G2-03 Task Packet 中被 current sources supersede 的路径/状态不构成当前 authority。

---

## 4. Read First

开始时先 fetch / fast-forward 最新 `origin/main`，记录 start HEAD 与 `git status --short`，然后按顺序只读：

1. `AGENTS.md`
2. 本 Task Packet
3. `docs/CORE_DESIGN_PRINCIPLES.md`
4. `src/ui/叙事对话视图.gd`
5. `src/provider/deepseek流式适配器.gd`
6. `tests/g2_03_会话视图离线测试.gd`
7. `tests/g2_03_gui驱动测试.gd`

只有现有证据不足时才扩大读取范围；扩大后在 Final Report 说明原因。

---

## 5. Decision Digest / Invariants

### DEC-01｜Conversation Domain 成为正式 owner

建立最小正式 in-memory Domain。推荐放在语义清楚的 `src/domain/...` 路径，使用 plain GDScript / `RefCounted` / 等价轻量对象。

Domain 不得依赖：

- `Control` / Scene layout；
- HTTP/SSE；
- Provider secret；
- filesystem/database persistence；
- Godot SceneTree 生命周期作为业务语义。

不要为了“分层完整”创建空 interface / service / repository / event bus 森林。

### DEC-02｜最小正式语义

G2-04 至少正式拥有：

```text
Conversation
Player Turn
GM generation / accepted response
Conversation Entry or equivalent ordered read projection
Generation State
Retry
Regenerate
latest-turn correction
```

一个逻辑 Turn 必须有稳定的进程内 identity / ordering；不要求现在设计跨 Save 的永久 UUID 体系。

允许 Agent 选择最小 class/file shape，但必须能清楚回答：

```text
谁是同一个 Turn？
当前玩家输入是什么？
当前稳定 GM 结果是什么？
现在是否正在 generation？
失败/取消后可否 retry？
completed 后 regenerate 如何替换？
```

### DEC-03｜Generation State

至少能表达当前真实需要的生命周期：

```text
idle / ready-equivalent
streaming
completed
cancelled
failed
```

命名可调整，但语义必须明确。

Streaming delta 可以作为当前 draft/provisional generation 内容供 UI 投影；cancelled / failed partial 不能被伪装成 accepted completed GM response。

### DEC-04｜Regenerate 原子替换

对已 completed 的最新 Turn：

```text
old accepted player + GM pair
→ start regenerate
→ old accepted result remains stable
→ stream new draft separately
```

只有新 generation 成功 completed 时：

```text
atomically replace accepted GM result
```

若新 generation Cancel / Fail：

```text
old accepted pair remains valid
```

不得重新引入 IR-01 / IR-02。

### DEC-05｜Retry

对于 latest Turn 的 cancelled / failed generation：

- Retry 使用同一个逻辑 player turn；
- 不制造第二个 player turn；
- cancelled / failed partial 不成为 accepted GM result；
- Retry 成功后该逻辑 Turn 成为一个合法 completed pair。

### DEC-06｜Latest-turn correction 最小正式语义

本任务冻结语义，但**不要求新增玩家 UI 按钮**。

只允许 correction 当前最新逻辑 Turn，不做任意历史编辑。

对于已 completed latest Turn：

```text
old accepted player + GM pair
→ begin correction with new player text
→ old pair remains stable while corrected generation is pending
→ corrected generation completed
→ atomically replace player text + GM result in SAME logical turn
```

若 correction generation Cancel / Fail：

```text
rollback to old accepted pair
```

对于尚无 accepted GM 的 latest cancelled/failed Turn，可以修正该 Turn 的 player text 后再 Retry；仍保持同一个 logical turn identity。

该能力当前主要由 Domain tests 证明；不要借此增加复杂编辑历史、Branch 或 Timeline UI。

### DEC-07｜Transcript != Timeline

Conversation / transcript 表达玩家与 GM 的互动序列。

它不是：

- Save Point；
- Timeline Node；
- Branch；
- arbitrary rewind history；
- persistence journal。

G2-04 不得实现上述能力。

### DEC-08｜UI 不再拥有第二套 Conversation truth

迁移后 `src/ui/叙事对话视图.gd` 可以保留：

- Control refs；
- 当前渲染 block refs；
- scroll/readability/composer layout 状态；
- player action handlers。

但不能继续用独立 `_history` / duplicated generation-state flags 作为第二 authority。

目标关系：

```text
Domain state
→ UI projection
```

不是：

```text
Domain state + UI history
→ 两套同时维护
```

### DEC-09｜Provider / Context 边界

Provider Adapter 继续保持现有 thin seam，不把 Conversation Domain 塞进 adapter。

G2-04 也不正式拥有 Context Assembly。

在 G2-05 前，Narrative integration 可以从 Conversation Domain 的 structured snapshot/read projection **临时适配**成现有 Provider `messages`，以保持当前产品可运行；但：

- 不做 relevance retrieval；
- 不做 world context；
- 不做 token budget / summarization platform；
- 不冻结 G2-05 的 Context contract；
- current provisional GM prompt 保持 `Narrative richness over artificial brevity`，不得添加人为长度限制。

### DEC-10｜字体 UX carry-forward：默认 medium

Owner 已明确 G2-03 PASS，但指出整个页面字体整体偏小。

本任务必须做一次小型、全局一致的 desktop typography baseline 调整：

- 默认正文/控件从当前偏小状态提升到**中等可读**量级；
- Narrative 正文、Composer、按钮、侧栏说明、状态文本、标题层级保持合理层次；
- 优先利用现有 Theme / 少量已有 override 调整，不重构成 typography framework；
- 参考量级可以是 default/body 约 `18px`、Narrative 约 `19–20px`、secondary/support 约 `14–15px`，但最终以真实 2560/maximized、1280×720、960×540 截图可读性与无溢出为准，不要求机械锁死这些数值。

未来玩家可选字体大小 / UI text scale 属于 G6 UI Preference；本任务禁止实现 selector / persistence / custom font manager。

### INV-PRODUCT-01｜不要为了 Domain 正确性削弱 Narrative 核心体验

G2-04 重构必须保持：

- natural-language free input；
- real streaming；
- Cancel / Regenerate；
- long Narrative readability；
- `Narrative richness over artificial brevity`；
- 无新的 Regex / Confirmation / Narrative whitelist / output-length cap。

### INV-OWNERSHIP-01｜单一 Conversation truth

UI、Provider、tests 不得各自再维护一套可漂移的 conversation history truth。

### INV-SCOPE-01｜G2-05 / G3 未授权

本任务不实现 Context Assembly、World Context、Persistence、Save、Timeline、Branch、World/NPC/Faction Domain。

---

## 6. Allowed / Prohibited Scope

### Allowed

- 新增最小 Conversation/Turn Domain 文件；
- 新增 focused G2-04 domain tests；
- 修改 `src/ui/叙事对话视图.gd` 以消费正式 Domain；
- 必要时修改 `src/main.tscn` 做 medium typography baseline；
- 更新现有 G2-03 tests 以匹配正式 ownership；
- 若集成暴露真正的 G2-02 adapter 小 bug，可做最小修复并完整回归，但必须在 Final Report 明示。

### Prohibited

- G2-05 Context Assembly / retrieval / summarization；
- G3 Persistence / SQLite / Save / Timeline / Branch；
- World / NPC / Faction / Relationship / Inventory Domain；
- arbitrary historical correction / rewind；
- EventBus / DI container / service locator / generic command bus；
- generic repository/persistence abstractions；
- generalized Provider platform；
- font settings UI / persistence / Theme framework rewrite；
- 大规模视觉美化。

如果某个需求必须依赖这些禁止项才能正确完成，停止并返回 blocker，不得自行扩张 scope。

---

## 7. Required Deliverables

1. 最小正式 Turn / Conversation Domain v0.1。
2. Narrative UI 从 UI-owned provisional conversation truth 迁移到 Domain projection。
3. Retry / Regenerate / latest-turn correction semantics 的 focused tests。
4. G2-03 real interaction regression 保持通过。
5. 页面 medium-readable typography baseline 小修。
6. Windows exported game 仍可直接由 `run-game.cmd` 启动。
7. 一个独立 implementation commit + fast-forward push + clean status。

不要求为 G2-04 新建架构 CURRENT 文档；若实现发现会改变 canonical architecture 的新事实，先停止并返回，而不是自行创造新长期文档。

---

## 8. Engineering Acceptance

至少证明以下序列：

### AC-01｜Normal completed Turn

```text
send player text
→ one logical turn created
→ streaming deltas accumulate as draft
→ completed
→ one accepted player + GM pair
```

### AC-02｜Cancel → Retry

```text
new turn streaming
→ cancel
→ same logical turn remains retryable
→ retry
→ completed
→ no duplicate player turn
```

### AC-03｜Fail → Retry

同 AC-02，deterministic failure 后 retry 成功，不能污染已接受 history。

### AC-04｜Completed → Regenerate success

```text
old accepted pair
→ regenerate
→ old accepted pair stable while streaming
→ success
→ same turn id
→ player text exactly once
→ new GM accepted atomically
```

### AC-05｜Completed → Regenerate Cancel/Fail

Cancel/Fail 后 old accepted pair 完整保留；随后发送新 Turn 时 context/order 不错位。

### AC-06｜Multiple Turns

至少 3 个 completed logical turns 保持稳定顺序与唯一 identity；UI 显示与 Domain projection 一致。

### AC-07｜Latest-turn correction success

completed latest turn correction：成功后保持 same logical turn identity，并原子替换 latest player text + GM result；不产生额外历史 Turn。

### AC-08｜Latest-turn correction Cancel/Fail rollback

correction 失败或取消后旧 accepted pair 完整恢复/保持，不出现半新半旧。

### AC-09｜No UI second truth

静态 review + focused tests 证明 conversation ordering / accepted text / generation state 来自正式 Domain。UI 不再维护可独立漂移的 `_history` / replacement truth。

### AC-10｜Context boundary preserved

没有 G2-05 retrieval / summarization / World Context；Provider Adapter public seam 不因 Domain 重构膨胀。

### AC-11｜Typography medium baseline

真实截图/尺寸至少证明：

```text
Maximized desktop
1280×720
960×540
```

整体字体相较 G2-03 明显提升到中等可读量级；侧栏、Narrative、Composer、按钮、状态文字无明显裁切/越界；960 窄屏功能不因字号增大失效。

### AC-12｜G2-03 regression

真实 DeepSeek：至少完成 multi-turn + Cancel/Retry + completed Regenerate；streaming 与长 Narrative 仍正常，不新增输出长度限制。

---

## 9. Product Value Acceptance

本任务的主要产品价值不是“新增几个 class”，而是：

> 后续 Context / Save / World 可以依赖一个真正的 Conversation owner，而不会被 UI 私有历史锁死；同时当前玩家体验不因重构退化。

字体 carry-forward 的产品目标只是：默认阅读达到中等舒适度。

G2-04 不要求单独 Owner UAT；字体与整体体验将在 G2-06 Owner Playtest 继续判断。执行 Agent不得用截图自行宣布“字体完美”或“Product PASS”。

---

## 10. Validation

按 focused → broader 顺序执行，实际命令可遵循仓库现有脚本/测试约定：

1. Godot headless parse / import sanity；
2. 新 G2-04 Domain focused tests（离线、确定性）；
3. G2-03 offline regression；
4. G2-02 adapter focused smoke；
5. GUI responsive/typography validation：Maximized、1280×720、960×540；
6. real DeepSeek GUI regression：multi-turn、Cancel/Retry、completed Regenerate；
7. Windows export；
8. `run-game.cmd` / `run-game.ps1` exported-player smoke；
9. `git diff --check`；
10. secret / Authorization hygiene；
11. `git status --short` clean。

GUI 自动化继续必须使用精确 executable + PID；禁止模糊窗口标题匹配，禁止结束身份不明进程。

---

## 11. Git / Integration

- 开始：fetch / fast-forward，记录 start HEAD 与 status；
- 不覆盖未知 dirty worktree；
- 实现前确认 current Task Packet 与 governance current 一致；
- push 前重新 fetch `origin/main`；
- 若 `Task Base != Current HEAD`，审计增量后 rebase/absorb 并重跑受影响验证；
- 只允许 fast-forward push；禁止 force push；
- Final Report 返回 start HEAD、implementation commit、push 结果、clean status。

---

## 12. Stop / Return Conditions

出现以下任一情况，返回 `BLOCKED`，不要自行扩大范围：

- 需要先冻结 G2-05 Context contract 才能继续；
- 需要 Persistence/Timeline 才能定义本任务语义；
- latest-turn correction 与 current canonical reversibility 冲突；
- current HEAD 出现会改变 G2-04 owner/architecture 的新改动；
- Domain 抽取必须破坏当前 real DeepSeek product path 才能完成；
- font baseline 需要大规模 Theme/Settings rewrite 才能避免布局破坏。

---

## 13. Final Report

```text
G2-04 Final Report

Result
READY FOR INDEPENDENT REVIEW | BLOCKED

Freshness
- start HEAD
- pre-push origin/main check

Domain Shape
- files/classes
- canonical Conversation owner
- Turn identity / Generation State
- UI / Domain / Provider ownership split

Behavior Evidence
- normal completed
- cancel → retry
- fail → retry
- completed → regenerate success
- regenerate cancel/fail rollback
- latest-turn correction success
- correction cancel/fail rollback
- multi-turn ordering

UI Migration
- removed/replaced UI-owned conversation truth
- G2-03 regressions

Typography Carry-forward
- actual default/body/narrative/secondary sizes or equivalent Theme change
- Maximized evidence
- 1280×720 evidence
- 960×540 evidence

Scope Check
- no G2-05
- no Persistence/Timeline
- no Settings/font preference system

Validation
- domain tests
- G2-03 regression
- real DeepSeek
- export/run-game
- secret/git hygiene

Git
- implementation commit
- push
- clean status
```
