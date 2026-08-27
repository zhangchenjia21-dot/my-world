---
title: my world｜G3-05 Recovery / Timeline Foundation Task Packet
status: current-task-packet
task_id: G3-05
type: implementation
owner: Codex
created: 2026-08-27
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 618fa0f2238114cbe4fc0fe790a1d60c43e99b45
agent_rules_base: 49e389d423200450b54ff36daf2e8fccf124e403
local_project: D:\AI\Projects\my-world
---

# TASK｜G3-05｜Recovery / Timeline Foundation

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

## 1. Outcome

让一次明确的 Load / Restore **本身也可恢复**，而不要求玩家在误读档前预先知道必须手工 Save 当前未来：

```text
current progress Fcurrent
→ Load old Save S1
→ Runtime 在同一 durable switch transaction 中保存被替换的 Fcurrent 为 internal Recovery Checkpoint R1
→ current 切到 S1
→ 玩家发现读错档
→ Recover Previous Progress
→ current World/head/accepted Conversation 原子回到 R1
→ Context 从 recovered truth 重建
→ AI 从 recovered future 继续
```

同时证明：从旧 Timeline Node 恢复后继续产生新的 durable World mutation，会自然形成新的 internal future，而旧 future nodes 不删除；这只是 Runtime correctness/recovery capability，不建立玩家可浏览的 Timeline debugger。

Implementation Agent 的最高返回状态：`READY FOR INDEPENDENT REVIEW`。Independent Review 通过后仍需 Owner UAT；不得自行宣布 Product PASS，不得开始 G3-06。

---

## 2. Why Now

G3-04 已通过 Independent Review + Owner UAT。当前产品已经可以：

```text
Save S1
→ 继续未来 F2
→ Load S1
→ World + Conversation + Context 正确回到 S1
```

但如果 F2 没有显式 Save，G3-04 只保留了相关 historical Timeline Nodes；F2 的 current accepted Conversation materialization 已被 Load 替换，玩家没有产品级入口恢复完整的 F2。

G3-05 的产品价值是：

> **Reversibility over prevention** 不要求每次 Load 前都靠玩家记得先另存；Runtime 应把高影响进度切换设计成可恢复操作。

这一步必须继续保持：重大历史切换是明确意图，但误操作不是不可逆灾难。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令与 G3-04 Owner UAT PASS。
2. `Vibe-Coding/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`。
6. `Vibe-Coding/my world/architecture/persistence/时间线存档与可逆性设计.md`。
7. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` / `MY_WORLD_CURRENT_STATUS.md`。
8. 本仓库 current `AGENTS.md`、code/tests/HEAD。
9. Current `agent-task-packet` / `lifecycle-dev-process` Skill 作为执行方法。

Not authoritative：

- DSH / The World 的 Workspace / Markdown / session-save implementation；
- G3-01 fixture schema；
- Transcript / UI tree / Context messages；
- arbitrary per-Turn rewind / Timeline browser ideas；
- G4/G5/G7 future schema guesses；
- old chat/task status。

---

## 4. Read First

开始先 fetch / fast-forward 最新 `origin/main`，记录 start HEAD 与 `git status --short`，确认包含本 Task Packet 与 current `AGENTS.md`。

初始工作集：

```text
AGENTS.md
本 Task Packet
src/persistence/L2_流程层/世界持久化流程.gd
src/persistence/L3_外交层/世界持久化公开接口.gd
src/runtime/当前游戏会话运行时.gd
src/domain/会话.gd
src/context/上下文组装器.gd
src/应用壳.gd
src/ui/叙事对话视图.gd
src/main.tscn
tests/g3_04/* 仅相关 Restore / Context / crash harness
```

随后读取 current Persistence supporting design。只有现有证据不足时才扩大范围；Final Report 说明扩大原因。不要默认扫描整个仓库。

---

## 5. Pre-implementation State / Failure Matrix

**编码前先完成矩阵。** 使用 task-scoped note，不新建长期 top-level 文档。

至少覆盖：

### Load old Save with automatic recovery

```text
current == target Save exact no-op
current has Conversation-only future
current has later World head + Conversation future
current latest Turn was successfully Regenerated
current latest Turn was successfully Corrected
current has >12 accepted Turns
active Provider generation
missing/corrupt Save target
missing/corrupt target Timeline anchor
invalid target Conversation recovery material
recovery INSERT failure
World update failure after recovery INSERT
head update failure after World update
Conversation update failure after head update
COMMIT success then process dies before memory/UI apply
```

### Recover Previous Progress

```text
no Recovery Checkpoint exists
latest Recovery target exact current no-op
valid latest Recovery after Load
Recover after player has continued new Conversation on restored Save
Recover after player has created a new World branch from restored old node
invalid/missing Recovery Timeline anchor
invalid Recovery Conversation material
failure after reciprocal recovery INSERT but before current switch completes
COMMIT success then process dies before memory/UI apply
normal reopen after Recover
rapid Load/Recover operations within the same wall-clock second
```

对每个场景回答：

- durable active head；
- durable current World；
- durable current accepted Conversation；
- in-memory Conversation；
- latest useful Recovery Checkpoint；
- historical Recovery records / Save Points / Timeline Nodes 是否改变；
- Context request material；
- player-visible result；
- rollback / retry semantics；
- 是否可能 half-switch、orphan checkpoint、future-memory leak、错误选择“latest”。

---

## 6. Decision Digest / Invariants

### DEC-01｜Recovery Checkpoint is not a Save Point

冻结：

```text
Recovery Checkpoint != Save Point
Recovery Checkpoint != Timeline Node
Recovery Checkpoint != copied SQLite database
Recovery Checkpoint != Transcript
```

Save Point 是玩家主动命名的长期恢复引用。

Recovery Checkpoint 是 Runtime 在高影响 progress switch 前自动创建的 safety material，用来恢复**被本次切换替换的 current progress**。

普通 Save 列表不得混入 automatic recovery records。

### DEC-02｜Minimal schema v3 → v4

推荐最小新增 `recovery_checkpoints`（exact column names 可调整）：

```text
recovery_checkpoints
- durable monotonic insertion order / sequence
- game_id
- stable recovery_id
- timeline_node_id
- accepted_turns_json
- reason / source context metadata
- created_at
```

要求：

- `recovery_id` 是稳定 identity；SQLite row id / sequence 不承担业务 identity；
- `timeline_node_id` 必须属于同一 Game；
- accepted Conversation snapshot round-trip exact；
- recovery row 创建后 immutable；
- **latest recovery selection 必须依赖 durable monotonic insertion order/sequence 或等价无歧义机制，不能只按 wall-clock `created_at` 排序**；同一秒内连续 Load/Recover 必须仍得到正确 latest；
- 第一代允许 append-retained records；不要求 cleanup/retention policy；
- 不建立 branch table、event store、ORM、repository framework。

Production schema v3→v4 必须 transactional additive migration；existing Game/World/Timeline/current Conversation/Save Points 原样保留。Intentional mid-migration failure 必须 rollback 到可继续打开的 v3。

### DEC-03｜Progress switch captures displaced current inside the same transaction

Load old Save 不能再采用：

```text
create recovery
COMMIT
→ later restore Save in second transaction
```

因为第二步失败会留下一个并未对应成功切换的 orphan recovery event。

必须等价于：

```text
BEGIN IMMEDIATE
→ resolve + validate target Save material
→ read coherent current durable active head + accepted Conversation
→ if exact no-op: ROLLBACK/finish without recovery mutation
→ INSERT immutable Recovery Checkpoint for displaced current
→ restore target World snapshot/current World
→ switch Game.active_head
→ replace current accepted Conversation
→ COMMIT
```

任一步失败：

```text
ROLLBACK
→ current triple unchanged
→ no new Recovery Checkpoint
```

Recovery Checkpoint World material仍只引用 existing immutable Timeline Node；不复制 World snapshot 到第二 live truth。

### DEC-04｜Recover is another protected progress switch

`Recover Previous Progress` 也会替换 current progress，因此不能直接 consume/delete recovery target。

正确语义等价于：

```text
current = Frestored
latest recovery target = Fold

Recover Previous Progress
→ transaction first captures Frestored as a new Recovery Checkpoint Rnew
→ switch current to Fold
→ COMMIT
```

结果：

- Fold 重新成为 current；
- Frestored 仍可通过新的 latest recovery 找回；
- 玩家可以安全来回恢复最近两个 active futures；
- older internal recovery rows 可以继续保留，但普通 UI 不浏览它们。

不得通过 DELETE/overwrite historical recovery target 来实现“消费”。

### DEC-05｜No-op switch must be truly non-mutating

若目标 durable：

```text
target head == current head
AND
target accepted Conversation == current accepted Conversation
```

则 Load/Recover 是 no-op：

- 不创建新 recovery row；
- 不改变 current World/head/Conversation；
- 不改变 latest useful Recovery；
- 返回 deterministic `already_current` 或等价稳定结果；
- UI 给玩家可理解反馈。

这个规则防止“重复点一下当前存档”意外覆盖真正有价值的 previous progress。

### DEC-06｜Conversation semantics stay Conversation-owned

Save / Recovery target 的 `accepted_turns_json` 在 durable switch 前必须继续使用 Conversation-owned non-mutating validation seam。

Recovery 捕获的是 current durable accepted materialization，因此不得包含：

- streaming draft；
- cancelled partial；
- failed partial；
- 未 durable accepted 的 candidate。

成功 Regenerate / Correction 已经是 current accepted truth，必须被 Recovery 精确保存并恢复。

Persistence 不能自己重新定义 accepted Turn 规则。

### DEC-07｜COMMIT before memory/UI apply, same as G3-04

Load-with-recovery / Recover ordering必须等价于：

```text
validate target without mutating Domain
→ durable protected switch transaction COMMIT
→ update runtime head/world
→ replace in-memory Conversation
→ redraw Narrative from Domain projection
→ rebuild Context on next request
```

若 COMMIT 已成功而 memory apply 极端失败：进入 blocking `reopen_required` 或等价状态；不能让旧 memory 对着新 durable current 继续运行。

必须证明 crash-after-COMMIT / before memory-UI apply 后 reopen 得到 target current，且刚刚 displaced progress 的 Recovery Checkpoint 仍可用。

### DEC-08｜Internal Timeline branch uses existing immutable DAG

G3-02 已有 `timeline_nodes(parent_node_id)` 与 immutable snapshots。

G3-05 不新增 branch registry。必须证明：

```text
H0 → H1 → H2   (old future)
       ↑ Save S1 at H1
Load S1
→ current = H1, Recovery points to H2
→ new World mutation creates H3 with parent H1

result:
H1 has historical children H2 and H3
H2 remains intact
H3 is new current branch
```

sequence number 可以在不同 branch 重复，只要 identity/parent semantics 正确且现有 schema 允许；不要为了全局序号漂亮改写历史 nodes。

UI 不展示 DAG / branch graph / node ids。

### DEC-09｜Recover Context isolation is symmetric

G3-04 已证明 Load 后不能看到被回滚 future。

G3-05 还必须证明 Recover 后不能看到**被 Recover 替换掉的另一条 current future**。

建议 fixture：

```text
Save S1
→ Future A contains RECOVERED_FUTURE_MARKER_A
→ Load S1 (A becomes Recovery)
→ continue branch B containing DISPLACED_BRANCH_MARKER_B
→ Recover Previous Progress
→ current returns to A
→ start new attempt + assemble Provider messages
```

必须证明：

- A 的 accepted truth 精确回来；
- marker A 可按历史位置自然存在；
- marker B 完全不在 recovered Conversation / Context messages；
- recent-12 仍成立；
- current player exactly once and last；
- no Prompt blob / raw opaque World JSON 被拿来补记忆。

### DEC-10｜Latest Recovery UI is minimal, explicit and non-debugger-like

在现有 World Surface Save/Load 区域增加最小 recovery affordance，例如：

```text
可恢复：读取存档前的进度（时间/简短说明）
[恢复读取前进度]
```

要求：

- 无 recovery 时不误导玩家；
- Recover 是明确高影响动作，使用 confirmation 或等价 explicit intent；
- 文案说明当前进度会切换，但当前进度本身也会被保护成新的 recovery；
- 不显示 Timeline Node ID、recovery row id、branch graph；
- 不列出 recovery history；
- existing named Save UI 继续独立。

active generation 中 Load/Recover 均禁用。

### DEC-11｜Current active progress must remain understandable

在不建设完整 Timeline UI 的前提下，玩家至少能理解：

- 当前正在玩的仍是唯一 active current progress；
- 最近一次 Load/Recover 后，存在一个“可恢复的上一进度”时 UI 会明确提示；
- Recover 成功后 Narrative 全量重绘为 recovered Conversation，不叠加两条未来；
- 正常退出/reopen 后 recovery availability 仍从 durable truth 重建，而不是只靠内存 label。

### DEC-12｜Retry / Regenerate / Correction alignment is a validation requirement

本任务不重写 G2/G3-03 Conversation semantics，但必须证明它们与 Recovery 协作：

- 对 latest Turn 成功 Regenerate 后 Load old Save → Recover，恢复的是 regenerate 后 accepted GM；
- 对 latest Turn成功 Correction 后 Load old Save → Recover，恢复的是 corrected player+GM；
- recovery 后 latest Regenerate 仍复用同一 logical Turn，persist-before-accept 继续成立；
- failure/partial draft 永远不进入 Recovery。

发现不一致时只做最小 integration repair，不建立通用 undo/event-sourcing framework。

### DEC-13｜G3-06 hardening remains deferred

本任务不解决：

- SQLite physical corruption automatic recovery；
- online backup retention / restore policy；
- arbitrary interrupted migration recovery beyond existing transaction evidence；
- two simultaneous product processes / single-instance lock / stale-session multi-process write protection；
- general disaster-recovery UI。

若 G3-05 无法在不解决其中某项的情况下保证 correctness，返回 `BLOCKED` 并提供证据，不得偷偷扩大范围。

### INV-PERSIST-01｜No unprotected successful progress switch

任何成功的 Load/Recover，只要 current 与 target 不同，被替换的 current durable progress 必须在同一 transaction 中留下可恢复 checkpoint。

### INV-PERSIST-02｜No half-switch / no orphan recovery

Progress switch 与 recovery capture 要么一起 COMMIT，要么一起不存在。

### INV-TIMELINE-01｜Old futures survive as immutable history

Load/Recover/new branch 不得 DELETE 或 rewrite unrelated historical Timeline Nodes、Save Points 或 older Recovery records。

### INV-CONTEXT-01｜Recovered truth rebuilds context

Recover 后 Provider request 只从 recovered current truth 派生；被替换 branch 的未来信息不得泄漏。

### INV-PRODUCT-01｜Recovery protects player timeline ownership without turning play into debugging

核心价值：玩家可以纠正误读档，同时重大历史切换仍需明确意图；不要通过 arbitrary per-Turn rewind、branch browser 或复杂 Timeline management 降低游戏选择重量。

---

## 7. Required Deliverables

1. Production schema v3→v4 transactional additive migration（或等价 next version）。
2. Minimal immutable internal Recovery Checkpoint durable representation，含无歧义 latest ordering。
3. Persistence L3 read model/API：至少能判断/读取 latest useful Recovery，而不泄露 SQLite row object。
4. Atomic **Load Save + preserve displaced current recovery** path。
5. Atomic **Recover Previous Progress + preserve displaced current reciprocal recovery** path。
6. Exact no-op detection，不制造 recovery spam/覆盖 latest useful recovery。
7. Conversation target validation + COMMIT-after memory replacement orchestration沿用 G3-04 contract。
8. Existing Timeline DAG branching correctness proof；no branch framework。
9. Minimal World Surface recovery availability / Recover UI + explicit confirmation。
10. Restore/Recover 后 Narrative full redraw from Conversation projection。
11. Context isolation evidence for both directions of progress switching。
12. Regenerate / Correction accepted-result recovery alignment evidence。
13. Migration failure / switch late-step rollback / orphan-recovery absence tests。
14. Crash-after-protected-switch-COMMIT / before memory apply + reopen evidence。
15. Same-second rapid Load/Recover deterministic latest-order evidence。
16. Normal reopen preserves current + latest recovery availability。
17. Real DeepSeek post-Recover continuation evidence。
18. G3-04/G3-03/G3-02/G3-01/G2 regressions + Windows export/run-game smoke。

---

## 8. Engineering Acceptance

### AC-01｜Schema v3→v4

Given real production v3 data with one current Game, accepted Conversation, Timeline nodes and named Save Points:

```text
open with G3-05 code
→ transactional additive migration
→ exact same game_id/current head/current World/current Conversation
→ exact same Save Points/Timeline history
→ empty Recovery set initially
```

Intentional migration failure must rollback to usable v3, version unchanged, no partial recovery table/index state.

### AC-02｜Conversation-only future is recoverable

```text
Save S1 at accepted history A
→ continue accepted Conversation to A+B without World mutation
→ Load S1
```

After successful Load:

- current = S1 A；
- latest Recovery = pre-Load A+B at the same Timeline head；
- `Recover Previous Progress` restores exact A+B；
- no future draft/partial enters either target；
- reopen preserves recovered A+B。

### AC-03｜World + Conversation future is recoverable

Seed later head H2 + later Conversation, Load Save at H1, then Recover：

- H2 immutable node still exists；
- current head/World/Conversation return exactly to H2 snapshot/material；
- Save row remains unchanged；
- no unrelated Timeline/Recovery deletion。

### AC-04｜Atomic recovery capture + Save Load

Inject deterministic failures at：

- recovery INSERT；
- current World update；
- Game head update；
- Conversation update；
- COMMIT。

Each failure must prove：

```text
old current triple unchanged
+ no new recovery row
+ old latest recovery unchanged
```

### AC-05｜Recover creates reciprocal recovery

After Load S1 creates Recovery R1 for Future A：

```text
continue current branch B
→ Recover R1
```

Success must：

- current becomes A；
- a newer Recovery R2 now preserves displaced branch B；
- Recover again can return to B；
- R1/R2 historical records are not deleted merely to implement toggling。

### AC-06｜No-op is non-mutating

Load current-equivalent Save and Recover current-equivalent target in isolated fixtures：

- stable `already_current`/equivalent；
- current triple unchanged；
- Recovery count unchanged；
- latest recovery identity/order unchanged。

### AC-07｜Latest order is deterministic under same-second operations

Force at least two protected switches with identical wall-clock `created_at` text or equivalent same-second timing.

The API/UI must still select the actual most recently inserted recovery checkpoint through a durable monotonic order/sequence, not random `recovery_id` lexical order or wall-clock ambiguity.

### AC-08｜Internal branch proof

Construct：

```text
H0 → H1 → H2
Save at H1
Load H1
new mutation → H3 parent=H1
```

Verify：

- H2 parent remains H1；
- H3 parent is H1；
- both nodes exist and snapshots immutable；
- current = H3 until another explicit switch；
- Recovery can return to displaced pre-Load H2 future；
- no branch table/browser was added。

### AC-09｜Regenerate / Correction survive recovery exactly

At least deterministic tests：

- successful Regenerate result is durable → Load old Save → Recover → exact regenerated GM returns；
- successful Correction result is durable → Load old Save → Recover → exact corrected player+GM returns；
- after Recover, latest Regenerate works and remains persist-before-accept；
- injected failed/partial attempt is absent from Recovery material。

### AC-10｜Recover future-memory isolation

Use separate unique markers for recovered Future A and displaced Branch B.

After Recover to A and start a new attempt：

- recovered A history is exact；
- B-only marker absent from accepted Conversation；
- B-only marker absent from Provider messages；
- recent-12 rule unchanged；
- current user exactly once and last；
- no stored Prompt/Context truth；
- no raw opaque World JSON prompt dump。

### AC-11｜Crash after protected COMMIT

For both Load-with-recovery and Recover-with-reciprocal-recovery, at least one exact-PID process-death fixture must prove：

```text
protected switch COMMIT succeeds
→ process dies before runtime/UI apply
→ reopen
→ target current triple is authoritative
→ displaced prior progress remains available as latest recovery
```

No shutdown flush dependency.

### AC-12｜Recovery UI

Offline GUI/scene evidence at 1280×720 and 960×540 proves：

- named Save list remains separate；
- no recovery → no false “可恢复上一进度”；
- successful Load shows useful latest recovery affordance；
- Recover has explicit confirmation；
- confirmation explains current progress will switch and be protected；
- active generation disables Load/Recover；
- Recover success redraws Narrative exactly once from Domain projection；
- no Timeline ids/branch graph/debug terminology leaks to player。

### AC-13｜Reopen

After Load, after Recover, and after Recover-then-continue：

- close/reopen exact current triple；
- latest useful Recovery still available from durable storage；
- UI reconstructs recovery availability without relying on previous-process memory label。

### AC-14｜Real DeepSeek continuation after Recover

Using isolated test DB：

1. seed Save + Future A；
2. Load Save；
3. create Branch B；
4. Recover Future A；
5. real GUI sends new action；
6. captured Provider request contains recovered A context, not B-only marker；
7. real stream completes；
8. accepted Turn durable；
9. reopen confirms continuation survived。

Do not expose API key/Authorization.

### AC-15｜Regression

Must preserve：

- G3-04 Save/Load atomic Restore + future-memory isolation；
- G3-03 resume + persist-before-accept；
- G3-02 mutation CAS/replay/rollback/query failure propagation；
- G3-01 SQLite real validation；
- G2-05 Context Assembly；
- G2-04 Conversation Retry/Regenerate/Correction/empty generation；
- G2-03 Narrative UI/Provider integration；
- no `max_tokens` / artificial Narrative length restriction。

### AC-16｜Windows product path

- normal Windows Desktop export PASS；
- exported product starts through `run-game.ps1` exact executable/PID path；
- Save → future → Load → Recover is reachable on normal product composition without developer DB editing；
- test DB overrides remain isolated and must not damage normal `user://` player DB。

---

## 9. Product Value Acceptance / Owner UAT Boundary

Primary product value for this increment：

> 玩家对 Timeline 有最终主权；明确 Load 可以改变历史，但一次误读档不应不可逆毁掉刚才的 active future。

Engineering PASS 不能替代 Owner UAT。

Independent Review 通过后，Owner 至少真实执行：

```text
run-game.cmd
→ 在当前进度继续玩出一个明显的新未来 F1
→ 不手动 Save F1
→ Load 一个较早的 named Save
→ 确认 UI 明确提示“可恢复读取前进度”
→ 在旧 Save 上再玩 1 Turn 形成 branch F2
→ 点击 Recover Previous Progress + confirmation
→ Narrative 应回到 F1，而不是 F2/旧 Save
→ 问 AI 一个能区分 F1/F2 的问题，确认只记得 F1
→ 再次 Recover，确认可回到刚才被替换的 F2（若实现按 reciprocal recovery 暴露）
→ 正常退出/reopen，确认 current + recovery availability 一致
```

Owner PASS 关注：

- “误读档可以救回来”是否直观成立；
- Recover 文案是否让人理解它恢复的是哪一段进度；
- 来回切换时 Narrative 不混合、不重复、不泄漏另一条 future；
- 不需要理解 Timeline Node / branch / database；
- recovery capability 没有把普通游玩变成每 Turn 都想回滚的调试器体验。

出现以下任一现象应判 Product Gate FAIL，而不是 polish：

- Load 成功但没有可用 pre-Load recovery；
- Recover 回错 future；
- 两条 future Narrative/AI memory 混合；
- recovery 操作让玩家无法判断当前是哪条进度；
- 普通 Save 与 automatic Recovery 混成同一难以理解的列表。

Agent 不得宣布 Product PASS。最高 `READY FOR INDEPENDENT REVIEW`。

---

## 10. Validation Order

按 focused → full：

1. Godot parse / GDExtension load。
2. Conversation recovery-material validation regression。
3. schema v3→v4 migration success/failure rollback。
4. Load-with-recovery atomic success + late-step failure tests。
5. Recover-with-reciprocal-recovery success + late-step failure tests。
6. no-op / same-second latest-order tests。
7. Conversation-only future recovery test。
8. World branch H1→{H2,H3} proof。
9. Regenerate/Correction alignment tests。
10. Recover Context marker/recent-12 test。
11. crash-after-COMMIT exact-PID tests。
12. offline GUI responsive/recovery UX tests。
13. G3-04/G3-03/G3-02/G3-01 regressions。
14. G2-05/G2-04/G2-03 regressions。
15. real DeepSeek post-Recover GUI test。
16. Windows export + normal product `run-game.ps1` smoke / vertical recovery path。
17. `git diff --check`、secret/Authorization/dependency hygiene、working tree clean。

所有 destructive/failure-injection DB 必须位于经过绝对路径校验的 isolated project build/test directory 或显式 test override；不得操作未知正常玩家 DB。

---

## 11. Allowed / Prohibited Scope

Allowed：

- `src/persistence/` 为 schema v4/recovery representation/protected switch 所需最小扩展；
- `src/runtime/` progress switch / recovery orchestration；
- `src/domain/会话.gd` 仅在现有 validation/replacement seam 证据不足时做最小修补；
- `src/应用壳.gd` / `src/main.tscn` 的最小 recovery UI；
- `src/ui/叙事对话视图.gd` Restore/Recover full redraw integration 如必要；
- focused tests/harness/export integration；
- task-scoped matrix / contract comments。

Prohibited：

- G3-06 physical corruption/backup/disaster recovery；
- multi-process single-instance/stale-session hardening，除非成为不可绕过 blocker；
- recovery history browser / branch picker / Timeline graph；
- arbitrary historical Turn rewind；
- Save delete/rename/overwrite manager；
- recovery cleanup/retention platform；
- multi-Game picker；
- G4 World Pack；
- G5 NPC/Faction/Item/Quest semantic schema；
- G7 retrieval/summarization/long-memory；
- full event sourcing；
- ORM / DI container / EventBus / Service Locator / generic repository framework；
- persistence of Provider messages/Context as truth；
- raw World JSON prompt dump；
- output-length/minimum Narrative restrictions；
- destructive tests on unknown player files。

---

## 12. Git / Integration

- Start：记录 `HEAD`、`origin/main`、`git status --short`；fast-forward current main。
- Formal implementation base is `618fa0f2238114cbe4fc0fe790a1d60c43e99b45`; packet/AGENTS commits after it are governance/task instructions, not implementation evidence。
- 不覆盖 unknown dirty worktree。
- focused implementation/validation 后重新 fetch 做 pre-push freshness revalidation。
- 若 `Task Base → Current HEAD` 出现未知 implementation commit：先审计是否改变 G3-05 dependency/schema/ownership；必要时 Decision Propagation or BLOCKED。
- fast-forward push only；不得 force push。
- Task Packet/doc commit 不得冒充 implementation evidence。

---

## 13. Stop / Return Conditions

返回 `BLOCKED`，不要猜测推进，如果出现：

- current authority supersedes G3-05；
- safe recovery requires destructive rewrite of G3-04 Save/Timeline history；
- existing Timeline schema cannot form an old-node child branch without violating an already frozen invariant；
- atomic recovery capture + switch cannot be expressed safely with current SQLite binding；
- Domain cannot validate Recovery Conversation without moving Conversation semantics into Persistence；
- correctness requires implementing G3-06 backup/corruption/multi-process platform first；
- real product composition would require arbitrary Timeline browser / major UI redesign；
- tests can only pass by touching unknown player DB。

否则完成后返回：

```text
READY FOR INDEPENDENT REVIEW
```

Final Report 至少包含：Freshness、state/failure matrix 摘要、schema/recovery shape、atomic switch evidence、same-second latest-order proof、branch proof、Context isolation、Regenerate/Correction alignment、crash/reopen、real Provider、Windows export、scope check、final commit/clean status。
