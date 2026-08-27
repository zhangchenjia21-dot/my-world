---
title: my world｜G3-04 Explicit Save / Load / Restore + Context Rebuild Task Packet
status: current-task-packet
task_id: G3-04
type: implementation
owner: Codex
created: 2026-08-27
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 929f4ff1e1253a808522d8f559a3cadd01b8d5db
agent_rules_base: 1427d0916794868cbe322881bc703c2a41b7f01e
local_project: D:\AI\Projects\my-world
---

# TASK｜G3-04｜Explicit Save / Load / Restore + Context Rebuild

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

## 1. Outcome

把 G3-03 已成立的 current Game resume 扩展成第一条玩家可理解、可操作的历史恢复路径：

```text
current Game
→ player creates named Save Point S1
→ later World / Conversation future continues
→ player explicitly selects + Loads S1
→ current World/head restore to S1 Timeline anchor
→ accepted Conversation restores to S1 snapshot
→ Context is rebuilt from restored truth
→ future-only material is absent from the next Provider request
→ player continues a new current future
```

这一步必须是**真实产品路径**，不是只新增数据库 API。第一代只做明确 Save / Load / Restore；不做任意历史 Turn rewind / Timeline debugger。

Implementation Agent 的最高返回状态：`READY FOR INDEPENDENT REVIEW`。Independent Review 通过后仍需 Owner UAT；不得自行宣布 Product PASS，不得开始 G3-05。

---

## 2. Why Now

G3-03 已通过 Independent Review + Owner UAT，真实产品现在可以：

```text
accepted Conversation durable
→ quit
→ reopen exact same Game
→ continue naturally
```

但当前只能恢复“最新 current state”，玩家还不能表达：

> “这个进度很重要，我想保存，以后明确回到这里。”

同时，Save/Restore 若只恢复 World 而不恢复 Conversation，会造成严重 future-memory leak；若只恢复 UI Transcript，也会制造第二 truth。因此 G3-04 必须把 Timeline anchor、accepted Conversation recovery material、current durable state、Context rebuild 与最小 Save/Load UI 一次纵向打通。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令与 G3-03 Owner UAT PASS。
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
- future G4/G5 World/NPC/Faction schema guesses；
- arbitrary rewind / Timeline browser ideas；
- historical chat / old task status。

---

## 4. Read First

开始先 fetch / fast-forward 最新 `origin/main`，记录 start HEAD 与 `git status --short`，确认包含本 Task Packet 和 current `AGENTS.md`。

初始工作集：

```text
AGENTS.md
本 Task Packet
src/persistence/L2_流程层/世界持久化流程.gd
src/persistence/L3_外交层/世界持久化公开接口.gd
src/runtime/当前游戏会话运行时.gd
src/domain/会话.gd
src/context/上下文组装器.gd
src/ui/叙事对话视图.gd
src/应用壳.gd
src/main.tscn
```

随后读取 current Persistence supporting design。只有证据不足时才扩大范围；Final Report 说明扩展原因。不要默认扫描整个仓库。

---

## 5. Pre-implementation State / Failure Matrix

**编码前先完成矩阵。** 不要求额外 top-level 文档；可以使用 task-scoped note 或 Final Report table。

至少覆盖：

### Save

```text
empty accepted Conversation
normal accepted history
>12 accepted Turns
current head after one/multiple World mutations
active Provider generation in progress
Save display name empty / Unicode / duplicate display name
SQLite write failure during Save creation
schema v2 existing DB → v3 migration
```

### Load / Restore

```text
Load Save that points to current head/current Conversation
Load old Save after later Conversation-only future
Load old Save after later World mutation + Conversation future
Load with >12 saved Turns
active generation in progress
missing Save ID
Save points to missing/corrupt Timeline anchor
invalid saved Conversation snapshot
SQL failure after World update but before head/Conversation complete
SQL failure after head update but before Conversation update
COMMIT success then process dies before in-memory/UI apply
normal process reopen after Restore
future-only marker present before Restore
```

对每个场景回答：

- durable active head；
- durable current World；
- durable current accepted Conversation；
- in-memory Conversation；
- Context request material；
- Save Point rows / Timeline nodes 是否改变；
- player-visible result；
- rollback / retry semantics；
- 是否会 silent fallback / half-restore / future-memory leak。

---

## 6. Decision Digest / Invariants

### DEC-01｜Save Point is a player recovery reference, not a World DB copy

冻结：

```text
Save Point != Timeline Node
Save Point != copied SQLite database
Save Point != Transcript
```

第一代 Save Point 至少拥有：

```text
stable save_id
player-visible display_name
game_id
target Timeline Node / head reference
accepted Conversation recovery snapshot/material
created_at
```

World recovery 使用目标 Timeline Node 已存在的 immutable `world_snapshot_json`；不要在 Save Point 再复制第二份 World live truth。

Save Point 中的 accepted Conversation snapshot 是**恢复材料**，不是第二份 current Conversation。只有 Load/Restore transaction 把它重新 materialize 成 current accepted Conversation 后，它才重新成为当前 truth。

### DEC-02｜Minimal schema v2 → v3

G3-04 推荐最小 additive representation：

```text
save_points
- game_id
- save_id
- display_name
- timeline_node_id
- accepted_turns_json
- created_at
```

Exact columns/indexes 可按 SQLite contract 做最小调整，但必须：

- stable `save_id` 是 identity；display name 不承担 identity；
- `timeline_node_id` 必须属于同一 Game；
- accepted snapshot round-trip exact；
- Save Point 创建后默认 immutable；
- 本任务不做 rename/delete/overwrite framework；
- 不建立 full event store / save-file-per-point / ORM。

Duplicate display names 可以被允许，只要 UI 不用名字作为 identity；若实现选择禁止 duplicate name，也必须保持简单并给 deterministic test。不要引入 overwrite semantics。

Production schema v2→v3 必须 transactional additive migration；existing Game/World/Timeline/current Conversation 原样保留。Intentional mid-migration failure 必须 rollback 到可继续打开的 v2。

### DEC-03｜Save captures durable accepted truth at one coherent moment

Save 只允许在 stable non-generating state，或使用等价的明确安全 transition。不要在屏幕仍展示 streaming partial 时让玩家误以为 partial 已进入 Save。

推荐 Persistence transaction 自己读取当前 durable：

```text
Game.active_head
+ current Conversation materialization
→ insert Save Point
```

这样 Save 捕获的是一个一致的 durable moment，而不是 UI 临时文本。

Save 不改变 active head、World、current Conversation 或 Timeline；它只是建立 recovery reference/material。

### DEC-04｜Restore durable atomic boundary

Load/Restore 的 durable state change 必须是一个 transaction：

```text
resolve selected Save Point
+ resolve target Timeline Node immutable World snapshot
+ update current World materialization to target snapshot/head
+ update Game.active_head_id to target head
+ replace current accepted Conversation with saved snapshot
→ one SQLite transaction
→ COMMIT
```

任一步 SQL/validation failure：

```text
ROLLBACK
→ old current head unchanged
→ old current World unchanged
→ old current Conversation unchanged
```

禁止先切 World、后异步恢复 Conversation；禁止靠 UI/Transcript 补齐。

### DEC-05｜Conversation semantics remain Conversation-owned

Persistence 不得自行决定什么是合法 accepted Turn。

在 durable Restore 前，saved `accepted_turns_json` 必须经过 Conversation-owned non-mutating validation seam 或等价验证。允许最小增加：

```text
validate_accepted_entries(...)
replace/restore_accepted_entries(...)
```

要求：

- accepted order exact；
- `player_text` / `gm_text` String shape；
- empty/whitespace GM 不可成为 accepted truth；
- no active streaming attempt during replacement；
- validation 不修改 live Conversation。

Persistence 只持久化已经由 Domain 契约认可的恢复材料。

### DEC-06｜COMMIT before in-memory/UI switch

Restore ordering 必须等价于：

```text
player confirms Load S1
→ validate Save/Conversation candidate without mutating current Domain
→ durable Restore transaction COMMIT
→ update runtime head/world
→ replace in-memory Conversation with same accepted snapshot
→ redraw UI from Domain projection
→ future requests use rebuilt Context
```

若 durable Restore 失败：UI/Domain 仍停留在旧 current progress。

若 COMMIT 已成功，但极端情况下 in-memory apply unexpectedly fails despite prevalidation：runtime 必须进入明确 blocking/reopen-required state，不得继续让旧 memory 对着新 DB 玩。正常 restart 必须恢复 durable restored state。

### DEC-07｜Crash-after-Restore-COMMIT safety

必须证明：

```text
Restore COMMIT succeeds
→ process terminates before UI/memory refresh
→ reopen same DB
→ restored head/World/Conversation is authoritative
```

不要通过 shutdown flush 才完成 Restore。

### DEC-08｜Future-memory isolation is blocking

建立一个唯一 future-only marker fixture，例如：

```text
FUTURE_ONLY_SECRET_G304
```

流程：

```text
Save S1 at history Hsave
→ continue future Conversation containing marker
→ optionally advance World to later head
→ Load S1
→ start new player attempt
→ assemble Provider messages
```

必须证明：

- restored accepted history exactly equals S1 snapshot；
- future-only player/GM text absent；
- marker absent from Context messages；
- recent-12 bounded rule仍成立；
- current player appears exactly once and last；
- no stored Prompt/Context blob participates；
- raw opaque World JSON still is not dumped into Prompt。

这不是可延后 polish。只要 Restore 后模型请求仍能看到被回滚 future，G3-04 FAIL。

### DEC-09｜Historical Timeline Nodes survive Load

Load old Save 不得执行：

```text
DELETE future Timeline Nodes
DELETE unrelated Save Points
rewrite immutable historical snapshots
```

G3-04 只改变 active current references/materializations。

**注意阶段边界：** G3-04 不宣称“未显式保存的 pre-Load current Conversation future 已自动可恢复”。完整 automatic recovery checkpoint / old-head recovery / branch semantics 属于 G3-05。当前 UI 必须清楚提醒：若玩家想保证能返回当前进度，应先建立 Save Point。

### DEC-10｜Explicit high-impact Load UX

Load 不是 Narrative 历史旁边的一键 rewind。

在现有 `WorldSurfaceHost` 内建立最小 Save/Load surface，推荐形态：

```text
存档名称输入
[保存当前进度]
Save 列表 / selection
[读取所选存档]
```

Load 必须明确显示选中的 Save name，并使用一个明确的高影响确认步骤或等价 explicit intent interaction，例如：

> 读取将切换当前进度。若希望以后回到现在，请先保存当前进度。

不得使用工程术语、Timeline Node ID、SQLite row 或 branch graph 作为主要玩家文案。

不要求视觉 polish；保持现有三栏、18/60/22 baseline、窄屏 World toggle 与 960×540 / 1280×720 可用性。

### DEC-11｜Save/Load controls and active generation

Active generation 中：

- Save / Load 不得静默执行；
- 推荐 disable 并要求玩家先 Cancel / 等待 completion；
- 不自动把 partial draft 当 Save truth；
- 不自动 Load 到 Provider callback 仍可能回来的旧 session 下。

完成 Restore 后必须确保没有旧 active attempt / streaming draft 残留。

### DEC-12｜UI is projection/request surface only

Save/Load UI：

- 请求 Runtime/Domain 执行 Save / Restore；
- 展示 Save read model 与当前结果；
- 不直接 SQL；
- 不保存第二份 authoritative history；
- Restore 后 Narrative entries 必须从 restored Conversation projection 完整重绘，而不是逐条手工 patch 旧 UI。

### DEC-13｜Current resume remains valid after Restore

Restore 后：

```text
close game
→ reopen
→ same restored active head
→ same restored World
→ same restored Conversation
```

随后继续一个新 Turn并退出/重开，仍必须 durable。

### DEC-14｜No accidental scope expansion

本任务不实现：

- automatic pre-Load recovery checkpoint；
- recover previous unsaved current future；
- branch picker / Timeline graph；
- per-Turn arbitrary rewind；
- Save delete/rename/overwrite manager；
- multi-Game picker；
- G4 World Pack；
- G5 NPC/Faction/Item/Quest schema；
- G7 retrieval/summarization/long-memory；
- generic repository/ORM/EventBus/DI/Service Locator；
- output length limits。

### INV-PERSIST-01｜No half-restore

`active head + current World + current accepted Conversation` 要么全部恢复到 Save，要么全部保持 Restore 前状态。

### INV-CONTEXT-01｜Restore truth, rebuild context

Context / Provider messages 永远是 restored truth 的 derived material，不是 Save payload truth。

### INV-PRODUCT-01｜Save/Load serves long-term RPG continuity

玩家必须能直观完成“保存这个重要进度 → 继续玩 → 明确回到它 → AI 从那里继续”，而不是操作数据库或调试器。

---

## 7. Required Deliverables

1. Production schema v2→v3 transactional migration（或等价 next version）。
2. Minimal stable Save Point durable representation。
3. Persistence L3 APIs：create/list/get/restore Save，不泄露 SQLite row objects。
4. Save creation from one coherent durable current moment。
5. Atomic durable Restore across current head + World + accepted Conversation。
6. Conversation non-mutating validation + in-memory replacement/rehydration seam as necessary。
7. Current Game runtime orchestration for create/list/restore Save。
8. Minimal WorldSurface Save/Load UI + explicit Load intent/confirmation。
9. Restore-driven Narrative UI full redraw from Conversation projection。
10. Context rebuild/future-memory isolation deterministic evidence。
11. Migration failure / Save failure / Restore late-step rollback tests。
12. Crash-after-Restore-COMMIT/reopen evidence。
13. Normal reopen-after-Restore and continue-next-Turn evidence。
14. Real DeepSeek post-Restore request evidence。
15. G3-03/G3-02/G3-01/G2 regressions + Windows export/run-game smoke。

---

## 8. Engineering Acceptance

### AC-01｜v2 → v3 migration

Given real production v2 DB with current Game/head/World/Conversation:

```text
open with G3-04 code
→ transactional additive migration
→ exact same game_id/head/World/current accepted Conversation
→ save_points empty
→ schema current version
```

Intentional migration interruption must rollback table/version changes and leave v2 usable.

### AC-02｜Create Save Point

At stable current state:

```text
head = H1
accepted Conversation = C1
create Save "测试存档甲"
```

Verify：

- stable non-empty `save_id`；
- display name round-trips Unicode exactly；
- target node = H1；
- accepted snapshot = exact C1；
- current head/World/Conversation unchanged；
- reopen lists same Save。

### AC-03｜Save failure is non-mutating

Inject deterministic failure during Save insert/commit：

- no partial Save row；
- current state unchanged；
- player gets non-destructive retryable Save error；
- no fake success in UI。

### AC-04｜Conversation-only future Restore

```text
Save S1 at C1
→ accept later Turns C2 containing FUTURE_ONLY_SECRET_G304
→ Load S1
```

Verify durable + in-memory Conversation = exact C1, no future Turn, no duplicate entries, Save row remains.

### AC-05｜World + Conversation Restore

```text
Save S1 at head H1 / World W1 / Conversation C1
→ durable World mutation to H2 / W2
→ later Conversation C2
→ Load S1
```

After COMMIT：

- Game.active_head = H1；
- current World = W1；
- current Conversation = C1；
- historical H2/W2 Timeline Node still exists unchanged；
- S1 still exists；
- no half-old/half-new state。

### AC-06｜Late-step Restore rollback

Use deterministic isolated SQLite failure injection at least after an earlier Restore write has executed but before all head/World/Conversation steps finish.

After failure：

- active head remains pre-Load head；
- current World remains pre-Load World；
- current Conversation remains pre-Load Conversation；
- no Save/Timeline deletion；
- API returns stable failure, no runtime crash。

### AC-07｜Invalid target fails before mutation

At least prove：

- unknown save_id → `not_found` / equivalent stable absence；
- missing/corrupt target Timeline anchor → fail-loud；
- invalid accepted Conversation snapshot → Domain validation failure / storage failure as appropriate；
- no current state mutation in each case。

### AC-08｜Crash after Restore COMMIT

Use exact executable/PID safe harness or equivalent isolated process proof：

```text
old current state
→ Restore transaction COMMIT to S1
→ marker confirms durable COMMIT
→ terminate exact helper process before in-memory/UI apply
→ reopen through production runtime
```

Must restore S1 head/World/Conversation exactly.

### AC-09｜Future-memory isolation

After Load S1 and beginning a new attempt：

- future-only marker absent from `Conversation.get_context_projection()` accepted history；
- absent from assembled Provider messages；
- recent-12 whole-turn policy unchanged；
- current player exactly once and last；
- no raw World persistence JSON injected；
- no stored prompt/context table/blob used。

### AC-10｜Minimal Save/Load UI

Real/offline GUI evidence proves：

- right World surface exposes Save name + save action + existing Save selection/list + Load action；
- saved item appears without restart；
- Save list survives restart；
- Load clearly identifies target Save and requires explicit high-impact intent；
- active generation disables/blocks Save/Load；
- successful Load redraws Narrative to restored history, removing future visual blocks；
- failed Load leaves current Narrative/state unchanged and shows player-readable error；
- no Timeline IDs/SQLite details required from player。

### AC-11｜Resume after Restore

```text
Load S1
→ close normally
→ reopen
```

Exact restored state survives. Then accept one new Turn, close/reopen again, and verify new post-Restore future is durable.

### AC-12｜Real DeepSeek after Restore

Using isolated test DB/product override：

1. seed Save S1 with durable accepted history；
2. create future accepted Turn containing unique future marker；
3. Load S1 through production runtime/UI path；
4. send a real new action；
5. captured Provider request includes only restored recent history + current user；
6. marker absent；
7. DeepSeek stream completes；
8. result durable；
9. reopen confirms post-Restore new Turn。

Do not expose API key/Authorization.

### AC-13｜Regression

Preserve：

- G3-03 cross-process resume, persist-before-accept, invalid startup fail-loud；
- G3-02 World transaction/stale/replay/conflict/rollback/query failure semantics；
- G3-01 SQLite route/migration/crash evidence；
- G2-05 Context recent-12；
- G2-04 Retry/Regenerate/Correction/empty_generation；
- G2-03 Narrative UI/Provider integration；
- no `max_tokens` / arbitrary Narrative length cap。

---

## 9. Product Value Acceptance / Owner UAT Boundary

G3-04 直接改变长期玩家路径，所以 Independent Review 通过后必须 Owner UAT。Agent 最高状态 `READY FOR INDEPENDENT REVIEW`。

Owner UAT 应能只通过游戏 UI 完成，不看数据库/日志：

```text
打开现有 current Game
→ 创建一个名字容易记住的 Save Point
→ 再玩 1–2 Turn，制造明显“未来剧情”
→ 在 Save Surface 选择旧 Save
→ 明确 Load
→ 确认 Narrative 回到保存时状态，后续未来消失
→ 再输入一个新行动
→ 确认 AI 不知道刚才被回滚的未来，并自然从旧进度继续
→ 正常退出 / 重开
→ 确认 restored + new future 仍存在
```

PASS 关注：

- Save/Load 意图是否清楚；
- Load 后是否明显是保存时的那段进度；
- World/Narrative 没有半恢复、重复、乱序；
- AI 不泄漏被回滚 future；
- 重启后仍是 restored current progress；
- 没有变成复杂 Timeline debugger。

若 future-memory leak、半恢复、Load 后空白/重复历史、或 Save/Load 需要工程操作，Product Gate FAIL。

---

## 10. Validation Order

按 focused → full：

1. Godot parse / GDExtension load。
2. Conversation recovery validation/replacement focused tests。
3. production v2→v3 migration success + intentional failure rollback。
4. Save create/list/reopen + failure rollback tests。
5. World+Conversation atomic Restore + late-step rollback。
6. invalid Save/anchor/Conversation recovery tests。
7. crash-after-Restore-COMMIT exact-PID/reopen proof。
8. future-memory isolation + recent-12 Context assertions。
9. offline GUI Save/Load surface + restored Narrative redraw + failure path。
10. deterministic close/reopen after Restore + continue Turn。
11. G3-03 full relevant regressions。
12. G3-02 / G3-01 real persistence regressions。
13. G2-05 / G2-04 / G2-03 regressions。
14. real DeepSeek post-Restore GUI path。
15. Windows Desktop export + `run-game.ps1` exact executable/PID smoke。
16. `git diff --check`、secret/Authorization/dependency hygiene、working tree clean。

所有 destructive/failure-injection databases 必须位于绝对校验过的 isolated `build/g3_04_*` 或显式 test override path。不得操作未知玩家 DB。

---

## 11. Allowed / Prohibited Scope

Allowed：

- `src/persistence/` 的 schema v3 / Save Point / atomic Restore 最小扩展；
- `src/domain/会话.gd` 的恢复 validation/replacement seam；
- `src/runtime/当前游戏会话运行时.gd` 的 Save/Restore orchestration；
- existing World Surface / Application Shell 的最小 Save/Load product UI；
- Narrative UI 的 restored-history redraw seam；
- focused tests/harness/export integration；
- task-scoped note 与必要 contract comments。

Prohibited：

- G3-05 automatic recovery checkpoint / old-current-future recovery；
- branch graph / Timeline browser / arbitrary per-Turn rewind；
- Save manager feature set（rename/delete/overwrite/autosave slots）；
- multi-Game picker；
- G4 World Pack；
- G5 NPC/Faction/Item/Quest semantics；
- G7 retrieval/summarization/vector DB/long-memory；
- ORM / generic migration framework / EventBus / DI / Service Locator；
- Context/Provider messages as durable truth；
- raw World JSON prompt dump；
- output-length/minimum Narrative restrictions；
- destructive operations on unknown player data。

---

## 12. Git / Integration

- Start：记录 HEAD / `origin/main` / status，fast-forward 到 current main。
- 不覆盖 unknown dirty worktree。
- Task Base 是 G3-03 implementation `929f4ff1...`；Task Packet/AGENTS doc commits 不是 implementation evidence。
- 实现完成后 fetch 做 Pre-push Freshness Revalidation；审计 Task Base→current HEAD 是否出现并行语义变化。
- fast-forward push only；不得 force push。
- 一个清晰 implementation commit 为优先；若必须分开 migration/UI commits，Final Report 说明原因与顺序。

---

## 13. Stop / Return Conditions

返回 `BLOCKED`，不要猜测推进，如果：

- current authority supersedes G3-04；
- exact Restore correctness 必须先冻结 G3-05 branch/recovery semantics 才能实现；
- schema v2→v3 需要 destructive migration 才能继续；
- current Timeline snapshot 无法恢复 World without redesigning G3-02 kernel；
- Save/Restore 必须把 Context/Prompt 作为 truth 才能工作；
- product UI 需要大规模 G6 redesign 才能暴露最小 Save/Load；
- validation 只能通过操作未知真实 player DB 才能完成。

否则完成后返回：

`READY FOR INDEPENDENT REVIEW`

Final Report 至少包含：

- Freshness / commits / clean status；
- pre-implementation state/failure matrix summary；
- schema v3 + Save Point shape；
- Save semantics；
- Restore atomic boundary；
- late-step rollback evidence；
- crash-after-COMMIT evidence；
- future-memory isolation/context evidence；
- real UI + DeepSeek evidence；
- regressions / export / launcher；
- scope check。
