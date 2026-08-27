---
title: my world｜G3-03 Game Reopen / Resume Task Packet
status: current-task-packet
task_id: G3-03
type: implementation
owner: Codex
created: 2026-08-27
updated: 2026-08-27
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: ee768ca6ec8abdb2d65c994da4e7287886153bff
agent_rules_base: 9fcf0fa2c243a43143d281770a22eb7bba104349
local_project: D:\AI\Projects\my-world
---

# TASK｜G3-03｜Game Reopen / Resume

Type: `implementation`  
Owner: `Codex`  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

## 1. Outcome

把 G3-02 的 durable Game/World kernel 接回真实产品生命周期，让当前产品第一次具备**跨进程的同一 Game continuity**：

```text
first launch / open current Game
→ accepted Conversation becomes durable
→ normal exit
→ next process reopens the same Game identity
→ current World materialization restores exactly
→ accepted Conversation rehydrates exactly
→ Context is rebuilt from restored truth
→ player can continue the next Turn
```

这不是 Save/Load/Restore。G3-03 只建立 **current Game resume**。

Implementation Agent 的最高返回状态：`READY FOR INDEPENDENT REVIEW`。不得开始 G3-04。

---

## 2. Why Now

G3-01 已证明并接受 SQLite + `2shady4u/godot-sqlite v4.9`。G3-02 已通过 Independent Review，production kernel 具备：

- atomic current World + Timeline Node + active head；
- expected-head CAS；
- replay-safe stable mutation identity；
- immutable historical World snapshots；
- explicit query success / zero-row / physical failure contract；
- late-step rollback 与 post-COMMIT lost-ACK evidence。

但当前真实游戏仍然每次启动都由 Narrative UI 创建一个全新的 in-memory `Conversation`；退出后对话完全消失，也没有真实 current Game lifecycle composition。G3-04 Save/Restore 不能建立在这种 session-only 状态上，因此必须先完成 current resume。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令。
2. `Vibe-Coding/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`。
6. `Vibe-Coding/my world/architecture/persistence/时间线存档与可逆性设计.md`。
7. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` / `MY_WORLD_CURRENT_STATUS.md`。
8. 本仓库 `AGENTS.md`、current code/tests/HEAD。
9. Current `agent-task-packet v1.2` / `lifecycle-dev-process v2.2` 作为执行方法。

Not authoritative：

- DSH / The World 的 Workspace/Markdown/session persistence implementation；
- G3-01 `g3_fixture_*` schema；
- historical chat / old Task status；
- G4/G5 future World Pack/NPC/Faction schema guesses。

---

## 4. Read First

开始先 fetch / fast-forward 最新 `origin/main`，记录 start HEAD 与 `git status --short`，确认包含本 Task Packet。

初始工作集：

```text
AGENTS.md
本 Task Packet
src/persistence/L3_外交层/世界持久化公开接口.gd
src/persistence/L2_流程层/世界持久化流程.gd
src/domain/会话.gd
src/context/上下文组装器.gd
src/ui/叙事对话视图.gd
src/应用壳.gd
```

随后按 Source Manifest 读取 current Persistence supporting design。只有现有证据不足时才扩大读取范围；Final Report 说明扩展原因。

不要默认读取整个仓库。

---

## 5. Pre-implementation State / Failure Matrix

**编码前先完成矩阵。** 可以放在实现注释/Final Report；除非确有需要，不要求再新增一份 working-note 文档。

至少覆盖：

```text
first run: DB file absent
normal accepted new Turn
completed latest Regenerate
completed latest Correction
persistence write fails before accepted commit
normal graceful exit
reopen same process path in a new OS process
reopen with 0 accepted Turns
reopen with >12 accepted Turns
reopen after cancelled/failed/streaming-only attempt
existing DB / same Game
existing DB but no Game row
corrupt/unreadable DB
schema mismatch / failed migration
ambiguous DB containing >1 Game row
```

逐项回答：

- durable Game identity；
- current World/head；
- durable accepted Conversation；
- in-memory Conversation after operation/reopen；
- Context working set；
- player-visible/returned error；
- 是否允许创建新的 Game；
- 是否有 silent fallback / partial accepted truth。

---

## 6. Decision Digest / Invariants

### DEC-01｜Current resume only

G3-03 只解决：

```text
current Game
+ current World
+ current accepted Conversation
→ close/reopen
→ same current state
```

不实现：

- Save Point；
- Load/Restore old Save；
- historical Conversation visibility by Timeline Node；
- future-memory isolation；
- recovery branch UX；
- arbitrary historical rewind。

以上从 G3-04 开始。

### DEC-02｜Conversation remains the semantic owner

`Conversation` 继续拥有：

- accepted Turn order；
- player/GM accepted truth；
- Retry / Regenerate / Correction semantics；
- generation lifecycle。

Persistence 只保存当前 accepted Conversation 的 durable representation。

允许为 G3-03 增加最小公开 seam，例如：

```text
restore_accepted_entries(...)
get_pending_completion_projection()/equivalent
```

但必须是 read/rehydration boundary，不得让 SQLite rows 变成 Conversation Domain API。

Rehydrate 后 `turn_index` 可以由 accepted array 顺序重新建立 `0..N-1`；不要把 `turn_index` 升级成跨系统 UUID、Timeline Node ID 或外部业务 identity。

### DEC-03｜Persist only accepted Conversation truth

Resume-authoritative Conversation 只包含已经 accepted 的：

```text
player_text
+ accepted_gm_text
+ deterministic order
```

以下不得在 reopen 后冒充 accepted history：

- streaming draft；
- cancelled partial；
- failed partial；
- empty_generation；
- Provider transport buffers；
- UI RichText nodes。

正常退出时若 generation 仍在进行，本次未 accepted attempt 不进入 durable Conversation。

### DEC-04｜Context is rebuilt, never resumed as a stored prompt

禁止持久化以下内容作为 authoritative resume truth：

```text
Provider messages
assembled system prompt
recent-12 working set
Context cache without explicit future validity contract
```

Reopen 后必须从：

```text
rehydrated Conversation
+ current available Game/World material
→ Context Assembly
```

重新得到 request messages。

当前 production 尚无正式 World semantic context renderer；**不得因为 SQLite 已有 opaque `World materialization JSON` 就把原始 JSON 直接塞进 `Current Game Context`**。真实 production `game_context_text` 可以继续为空，直到有正式 Game/World projection owner。

### DEC-05｜Minimal current Conversation materialization, not G3-04 history schema

G3-03 推荐新增一个最小 current-only durable representation，例如：

```text
conversation_materializations
- game_id PRIMARY KEY
- accepted_turns_json
- revision / updated_at（仅在实现确有必要时）
```

目标是 current resume，不是历史查询。

可以采用等价简单结构，但必须：

- 不建立 per-Turn event-sourcing platform；
- 不预先设计 Save→Conversation historical visibility schema；
- 不把 Transcript/Markdown 当数据库；
- accepted-turn materialization round-trip exact；
- schema envelope version 与 future Conversation semantic version 分离。

G3-04 可以在真实 Restore 需求下新增 head-bound historical recovery representation；不要为了未来猜测把 G3-03 复杂化。

### DEC-06｜Production schema migration v1 → v2 must be real and transactional

G3-03 是第一条 production schema evolution。必须把当前 G3-02 schema v1 安全升级到 v2（或等价 next version），至少加入 current Conversation durability 所需结构。

要求：

- schema version 仍只有一个明确 source；
- existing v1 Game/World/Timeline data 原样保留；
- additive migration 用一笔 SQLite transaction；
- intentional mid-migration failure rollback 后仍保持可打开的 v1；
- 不建设 ORM / generic migration framework；
- 本次若没有 destructive migration，不强制建立 G3-06 完整 backup platform。

新建 DB 可以直接得到 current schema；existing v1 DB 必须走真实 upgrade evidence。

### DEC-07｜Durable acceptance ordering: persist candidate before Domain accepts

这是 G3-03 的关键完整性边界。

当前 G2 路径是 Provider `completed` → `Conversation.complete_generation()`。进入 durable resume 后，不允许：

```text
Conversation/UI 先把新结果正式 accepted
→ SQLite write 后失败
→ 玩家继续玩
→ restart 后 accepted Turn 消失
```

必须建立最小 orchestration seam，使 successful completion 的顺序等价于：

```text
Provider completed
→ Conversation exposes a non-mutating completion candidate / prospective accepted projection
→ persist candidate current Conversation materialization
→ durable COMMIT succeeds
→ Conversation.complete_generation() makes the same candidate accepted in memory
→ UI continues
```

若 durable write 失败：

```text
no new durable accepted Turn
→ old accepted truth remains
→ current attempt ends failed-equivalent with persistence error
→ player receives a clear retryable persistence error
→ no silent continuation as resume-safe success
```

实现可以不同，但必须证明等价语义。

Regenerate / Correction 同样遵守：旧 accepted pair 在 durable replacement COMMIT 前保持稳定；failed persistence 不得破坏旧 pair。

### DEC-08｜Completion candidate must reuse existing Conversation semantics

不要在 Session/Persistence 里复制第二套 Regenerate/Correction 规则。

`Conversation` 可以提供一个 read-only prospective projection，必须遵循现有语义：

- new Turn → append same `turn_index` candidate；
- Regenerate → replace current GM on same logical latest Turn；
- Correction → replace latest player+GM on same logical Turn；
- empty/whitespace draft → not a valid completion candidate；
- cancelled/failed partial → absent。

Persistence/runtime 只能消费这个 projection，不重新判断 Narrative business semantics。

### DEC-09｜Application/runtime composition owns Game lifecycle; UI does not open SQLite

当前 Narrative UI 自己 `Conversation.new()` 的 provisional composition 必须退休。

引入一个**最小 Game/session runtime composition owner**（exact name/location 可由实现选择，例如 `src/runtime/`），负责至少：

```text
production database path
current game identity
Persistence lifecycle
Conversation instance/rehydration
completion durability orchestration
current World read material
```

UI：

- receives/binds the session/runtime/Conversation；
- renders projection；
- dispatches player/Provider lifecycle events；
- 不直接执行 SQL；
- 不保存第二份 game_id/history。

不要因此建立 DI container、Service Locator、EventBus 或 generic application framework。

### DEC-10｜Minimal one-current-Game product locator for G3

G3-03 不建设多 Game picker。

当前第一代 production path 允许使用一个明确、稳定的 local DB path（例如项目命名空间下的 `user://.../current-game.sqlite` 或等价路径）。具体路径由实现保持集中且可测试。

启动规则必须区分 **file absent** 与 **existing file/problem**：

```text
DB file absent on genuine first run
→ create schema
→ generate one stable Game identity/root identity
→ create empty initial World materialization `{}`
→ create empty accepted Conversation materialization
→ continue

existing DB
→ open and inspect
→ exactly one Game → resume it
→ zero Game rows → fail-loud, do NOT silently mint replacement Game
→ more than one Game → explicit ambiguous/unsupported result, do NOT guess
→ corrupt/schema/read failure → fail-loud, do NOT create replacement Game
```

`{}` 只是当前无 World semantics 的空 materialization，不代表虚构世界事实。

G4/G6 再建立 New Game / Game picker / World Pack creation UX。不要在本任务冻结最终 multi-Game storage topology。

### DEC-11｜Stable Game identity is generated once, then read from durable truth

First-run Game/root IDs 必须由最小 local identity helper 或等价机制生成一次并写入 DB。之后 restart 必须从 DB 恢复 exact identity；不得按时间、窗口、Conversation 文本重新推导。

不要为此建设通用 identity framework。

### DEC-12｜Startup failure is blocking, not fresh-game fallback

若 existing current DB 存在但发生：

- SQLite open/query failure；
- corrupt file；
- schema mismatch；
- ambiguous Game rows；
- invalid persisted Conversation materialization；

真实产品必须进入明确 startup/resume failure 状态：

- 不向玩家显示一个“空白新局”冒充成功；
- 输入/生成主路径不得继续写入同一失败状态；
- 原 DB 文件保留供 G3-06 recovery。

UI 可显示简洁玩家错误，不倾倒 SQL/秘密；日志可保留工程 cause。

### DEC-13｜Rehydrate UI from Domain projection, not duplicated transcript state

恢复后 Narrative View 必须从 `Conversation.get_accepted_entries()` 或等价 projection 渲染已有 Turn。

要保证 latest restored accepted Turn 的 Regenerate 仍能复用同一 visual block / logical Turn，不创建 duplicate player entry。

UI 不保存单独 `_history`。

### DEC-14｜Graceful close owns resource cleanup, not final truth flush

因为 accepted Turn 在接受前已 durable，正常退出不应依赖“最后一秒保存整个会话”才能安全 resume。

退出路径负责：

- 若必要，cancel/abandon active non-accepted generation；
- close persistence connection cleanly；
- quit。

不得把 durability 主要押在 `_exit_tree()` / process shutdown flush 上。

### INV-PERSIST-01｜No silent accepted/durable divergence

玩家看到的正式 accepted Conversation 与 durable resume truth 不得在正常产品路径中静默分叉。

### INV-CONTEXT-01｜Restore truth, rebuild context

Context remains bounded derived material. Reopen 不能复用旧 Prompt blob。

### INV-PRODUCT-01｜Resume supports the RPG loop, not a database demo

G3-03 必须让真实 Narrative product path 能跨 restart 继续游戏；只提供 headless `open()` API 不算产品完成。

### INV-SCOPE-01｜G3-04+ not authorized

不做 Save/Load/Restore、historical rewind、future-memory isolation、Game picker、World Pack、NPC/Faction/Item schema、long-memory/retrieval platform。

---

## 7. Suggested Minimal Shape

仅作结构参考，不要求 exact names：

```text
Application Shell / Composition Root
└─ Current Game Session Runtime
   ├─ Persistence L3
   ├─ game_id / DB lifecycle
   ├─ current World read material
   ├─ Conversation Domain
   └─ durable-completion orchestration

Narrative View
├─ bound Conversation/session
├─ Provider Adapter
└─ Context Assembly
```

Persistence v2 minimal addition：

```text
conversation_materializations
- game_id
- accepted_turns_json
- updated_at
```

如果实现需要一个小 revision/CAS 字段防止同进程 stale session write，可以增加；不要为了它建设通用 concurrency platform。

---

## 8. Required Deliverables

1. Production schema v1→v2（或等价 next version）transactional migration。
2. Minimal current accepted Conversation durable representation。
3. Persistence L3 APIs for reading/writing current Conversation without exposing SQLite rows。
4. Conversation rehydration seam + non-mutating completion candidate/prospective projection seam or equivalent。
5. Minimal Game/session runtime composition owner，retire Narrative UI self-owned `Conversation.new()` path。
6. First-run/open-current-Game lifecycle using one explicit product DB path and exact durable Game identity。
7. Persist-before-accept completion orchestration for new / Regenerate / Correction。
8. Startup fail-loud path for existing corrupt/schema/query/ambiguous state；no fresh-game fallback。
9. Narrative UI renders restored accepted turns and can continue / regenerate latest after resume。
10. Context after resume is rebuilt from restored Conversation; no stored Prompt/Context truth。
11. Deterministic isolated two-process resume tests。
12. Real Windows exported product path + DeepSeek continuity evidence as specified below。

---

## 9. Engineering Acceptance

### AC-01｜Schema migration

Given a real G3-02 production v1 DB with one Game at H1/W1:

```text
open with G3-03 code
→ transactional migrate to current schema
→ same game_id
→ same active head
→ exact W1
→ same existing Timeline nodes/snapshots
→ empty current accepted Conversation materialization
```

Intentional migration failure must rollback to usable v1 with version unchanged.

### AC-02｜First-run current Game

On an isolated product DB path that genuinely does not exist:

```text
launch/open
→ create exactly one stable Game
→ root head + `{}` World
→ empty accepted Conversation
```

Reopen must return the exact same `game_id` and root identity, not generate new IDs.

### AC-03｜Existing invalid state does not become a new Game

At least verify:

- existing DB with zero Game rows；
- existing DB with >1 Game rows；
- corrupt/unreadable DB；
- unsupported schema version。

Each must fail-loud and preserve the existing file/state. No fallback new Game is created.

### AC-04｜Accepted new Turn durability ordering

For a new Turn with non-empty GM draft:

```text
prospective accepted Conversation
→ durable Conversation COMMIT
→ Domain accepted completion
```

After success, in-memory and durable accepted entries are exact.

Inject deterministic persistence failure before COMMIT and prove：

- new accepted entry is not durable；
- Conversation does not accept it；
- attempt becomes failed/retryable with persistence error；
- previous accepted truth unchanged；
- next product action is not silently allowed as if save succeeded。

### AC-05｜Regenerate durability

Completed latest Turn → Regenerate：

- old player/GM remains accepted before durable replacement；
- candidate materialization replaces GM on same logical Turn；
- durable COMMIT succeeds before Domain replacement；
- success keeps same Turn count/identity/order；
- injected durable failure preserves old GM both in Domain and DB。

### AC-06｜Correction durability

Completed latest Turn → Correction：

- candidate replaces latest player+GM on same logical Turn；
- durable success then Domain success；
- durable failure preserves old accepted player+GM；
- no duplicate Turn。

### AC-07｜Only accepted truth resumes

Seed accepted Turns plus one of each non-accepted condition in isolated runs：streaming-only/cancelled/failed partial。

After process restart, only accepted entries rehydrate. No partial GM text or failed player attempt appears as accepted history/context.

### AC-08｜Two-process exact resume

Use two separate Godot OS processes with the same isolated product DB path：

Process A：

```text
open/create Game
→ establish at least 3 accepted Turns through production session durability path
→ close cleanly
```

Process B：

```text
open same DB
→ exact same game_id
→ exact current head/World
→ exact 3 accepted Turns/order/text
→ no generating state
→ continue a 4th Turn
```

This must use the production session/runtime + Persistence L3 path, not G3 fixture tables.

### AC-09｜Context rebuild after resume

Persist at least 14 accepted Turns, close, reopen, then create current attempt and assemble messages：

- Context uses restored Conversation；
- recent-12 rule remains unchanged；
- current player appears exactly once and last；
- no persisted Provider-message blob is read；
- no raw opaque World JSON is injected as Game Context merely due to persistence availability。

### AC-10｜Restored Narrative UI projection

Offline GUI/scene test proves：

- restored accepted Turn pairs render in order；
- no duplicate history owner exists in UI；
- latest restored Turn can Regenerate using the same logical Turn and existing GM visual block；
- new Turn appends after restored history；
- failed resume disables/blocks normal send path and shows a player-readable resume/storage error。

### AC-11｜Real DeepSeek continuation from resumed history

Using an isolated resume test Game or safe test override：

1. durable accepted history exists before GUI launch；
2. real GUI opens it；
3. send a new player action；
4. captured Provider request contains restored recent Conversation in correct order and current user once；
5. real DeepSeek stream completes；
6. new accepted Turn becomes durable；
7. close/reopen test process and confirm that new Turn is still present。

Do not expose API key/Authorization in logs.

### AC-12｜Normal Windows product path

- normal `Windows Desktop` export passes；
- exported application starts with the normal product configuration；
- `run-game.ps1` exact executable/PID smoke passes；
- normal application no longer creates a fresh Conversation on every launch；
- first run and reopen paths are both reachable without developer-only manual DB editing。

### AC-13｜G3-02/G2 regressions

Must preserve：

- G3-02 atomic World mutation / stale / replay / conflict / late rollback / query failure propagation；
- G3-01 SQLite real validation；
- G2-05 Context Assembly；
- G2-04 Conversation Retry/Regenerate/Correction/empty_generation；
- G2-03 Narrative UI / Provider integration；
- no output-length cap / `max_tokens` convenience restriction。

---

## 10. Product Value Acceptance / Owner UAT boundary

G3-03 首次改变真实长期用户路径，因此 Engineering PASS 不能替代 Owner UAT。

Independent Review 通过后，Owner UAT 至少执行：

```text
run-game.cmd
→ 连续完成 2–3 个真实 Turn
→ 记住最后剧情
→ 正常退出游戏
→ 再次 run-game.cmd
→ 确认旧 Narrative 仍在、顺序正确
→ 再发一个新行动
→ 确认 AI 能自然承接重启前内容
→ 可选：对重启前最后一个 Turn 做一次 Regenerate
```

Owner 只需要判断：

- “这是同一局游戏”是否直观成立；
- Narrative 是否真的保留；
- 重启后的下一 Turn 是否自然承接；
- 是否出现空白新局、重复历史、未来/旧内容错乱、明显卡死。

Implementation Agent 不得宣布 `PRODUCT PASS`。最高 `READY FOR INDEPENDENT REVIEW`。

---

## 11. Validation Order

按 focused → full，避免先消耗真实 Provider：

1. Godot parse / GDExtension load。
2. Conversation rehydration + prospective completion focused tests。
3. production v1→v2 migration success/failure rollback。
4. durable Conversation new/regenerate/correction failure-order tests。
5. first-run / existing-invalid / corrupt / ambiguous Game lifecycle tests。
6. deterministic two-process resume harness。
7. 14-Turn Context rebuild test。
8. offline GUI restored-history / startup-failure tests。
9. G3-02 focused + IR-01 + lost-ACK regression。
10. G3-01 real persistence regression。
11. G2-05 / G2-04 / G2-03 regressions。
12. real DeepSeek resumed-history GUI test。
13. Windows Desktop export + `run-game.ps1` exact executable/PID smoke。
14. `git diff --check`、secret/Authorization/dependency hygiene、working tree clean。

所有测试数据库必须位于经过绝对路径校验的 isolated project build/test directory，或显式 test override；不得清理/损坏正常 `user://` 当前 Game。

---

## 12. Allowed / Prohibited Scope

Allowed：

- `src/persistence/` 为 schema v2/current Conversation representation 所需的最小扩展；
- `src/domain/会话.gd` 的最小 rehydrate/candidate projection seam；
- minimal `src/runtime/` / application composition owner；
- `src/ui/叙事对话视图.gd` 的 session binding / restored projection / persistence failure UI；
- `src/应用壳.gd` 或 scene composition 的必要 lifecycle wiring；
- focused tests/harness/export integration；
- 必要 contract comments。

Prohibited：

- G3-04 Save/Load/Restore；
- Save Point schema/UI；
- arbitrary Timeline browser/rewind；
- historical Conversation-by-Save design；
- G4 World Pack / New Game picker；
- G5 NPC/Faction/Item/Quest semantic schema；
- G7 long-memory/retrieval/summarization platform；
- ORM / DI container / EventBus / Service Locator / generic repository framework；
- persistence of Provider messages/Context as truth；
- raw World JSON prompt dump；
- output-length/minimum Narrative restrictions；
- destructive test operations on unknown player files。

---

## 13. Git / Integration

- Start：记录 `HEAD`、`origin/main`、`git status --short`；fast-forward current main。
- 不覆盖 unknown dirty worktree。
- 开发与 focused validation 完成后，重新 fetch 做 pre-push freshness revalidation。
- 若 `Task Base → Current HEAD` 出现新 commit：先审计是否改变 G3-03 dependency/architecture/schema/owner；必要时 Decision Propagation。
- fast-forward push only；不得 force push。
- Task Packet/doc commit 不得冒充 implementation evidence。

---

## 14. Stop / Return Conditions

返回 `BLOCKED`，不要猜测推进，如果出现：

- current authority supersedes G3-03；
- existing production schema 无法在不 destructive migration 的情况下安全演化；
- Godot/sqlite binding 在真实 reopen path 产生新基础 blocker；
- 必须提前决定 G3-04 Save/Restore semantics 才能继续；
- 真实 product composition 需要大规模 UI/Provider rewrite 超出本 task；
- 测试只能通过操作未知真实玩家 DB 才能完成。

否则完成后返回 `READY FOR INDEPENDENT REVIEW`。

---

## 15. Final Report

至少包含：

```text
Result
Freshness / final HEAD
Pre-implementation state/failure matrix summary
Schema v1→v2 exact migration
Current Game lifecycle / production DB path
Conversation durable representation
Persist-before-accept ordering evidence
Rehydrate semantics
New / Regenerate / Correction durability evidence
Two-process resume evidence
Context rebuild evidence
Real DeepSeek resumed-history evidence
Startup failure / no fresh-fallback evidence
Scope check
G3-02/G3-01/G2 regression
Windows export/run evidence
Git commit/push/clean status
```
