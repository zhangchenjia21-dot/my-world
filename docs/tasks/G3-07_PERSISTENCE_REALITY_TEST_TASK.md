---
title: my world｜G3-07 Persistence Reality Test Task Packet
status: current-task-packet
task_id: G3-07
type: implementation
owner: KimiCode K3
created: 2026-08-28
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 7e2e622f03782a1d66f5f8837d739f900615b775
agent_rules_base: fc998a5a22cf477e2ed678cbb2456f30a28e2234
local_project: D:\AI\Projects\my-world
---

# TASK｜G3-07｜Persistence Reality Test

Type: `implementation`  
Owner: **KimiCode K3**  
Repository: `zhangchenjia21-dot/my-world`  
Branch: `main`

## 1. Outcome

把 G3-01..G3-06 已分别成立的 persistence 能力串成一条真实产品路径，证明它们组合后仍然是一个可靠、可恢复、能继续和真实 AI GM 对话的游戏，而不是一组互相独立的测试夹具。

同时完成 Owner 在 G3-06 UAT 明确提出的一个小 UI 修正：**当 Current Game 因物理损坏无法启动且存在 verified backup 时，把“恢复最近安全备份”按钮移动到中央失败提示之后；不要继续藏在右下角。**

Implementation Agent 最高状态：`READY FOR INDEPENDENT REVIEW`。不得自行宣布 G3-GATE PASS，不得开始 G4。

---

## 2. Why Now

G3-01..G3-06 已建立并逐项通过：

```text
atomic persistence
+ reopen/resume
+ named Save
+ atomic Load/Restore
+ future-memory isolation
+ displaced-future Recovery
+ reciprocal Recover
+ internal branch correctness
+ single-writer
+ verified physical backup
+ staged corruption recovery
```

G3 只剩一个问题没有回答：

> **这些能力放在真实长一点的产品路径里连续使用，是否仍然保持同一 Game、同一 durable truth、正确 AI Context 和可理解 UX。**

另外，G3-06 Owner UAT 已 PASS，但 Owner 明确指出全屏/宽屏下灾难恢复按钮在右下角过于不显眼。该问题是小型 UI polish，不值得单独拆 Task，纳入 G3-07 修正。

G3-06 中额外尝试的既有 real-provider continuation 曾返回一次 `transport`。G3-06 本身不依赖真实 Provider，但 **G3-07 必须重新取得真实 Provider 端到端成功证据**。

---

## 3. Authority / Source Manifest

冲突时按以下顺序：

1. 用户当前明确指令：G3-06 Owner UAT PASS；恢复按钮移到中央失败提示之后；后续可由 KimiCode/Grok Build 接手。
2. `Vibe-Coding/AGENTS.md`。
3. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md`。
4. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`。
5. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`。
6. `Vibe-Coding/my world/architecture/persistence/时间线存档与可逆性设计.md`。
7. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md`。
8. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`。
9. 当前 implementation `AGENTS.md`、code/tests/HEAD。
10. `Skill/skill/gpt/agent-task-packet/SKILL.md` v1.2 与 current lifecycle skill 作为执行方法。

Not authoritative：旧聊天状态、DSH/The World persistence implementation、Transcript/UI/Prompt/Context cache、任意 Timeline browser/backup browser 设想。

---

## 4. Read First

开始先 fetch / fast-forward 最新 `origin/main`，记录 start HEAD 与 `git status --short`，确认至少包含：

```text
fc998a5a22cf477e2ed678cbb2456f30a28e2234  current AGENTS.md for G3-07
本 Task Packet commit
```

初始工作集：

```text
AGENTS.md
本 Task Packet
src/runtime/当前游戏会话运行时.gd
src/应用壳.gd
src/main.tscn
src/context/上下文组装器.gd
src/domain/会话.gd
src/provider/ 中 current DeepSeek adapter 直接入口
tests/g3_06/* 中 product/recovery/single-writer harness
tests/g3_05/* 中 Recover/Context harness
```

随后只读取 G3-04/G3-03 直接相关恢复/真实 Provider harness。只有现有证据不足时才扩大范围，并在 Final Report 说明原因。不要默认扫描整个仓库。

---

## 5. Pre-implementation Reality Matrix

**先完成矩阵，再改代码。** 放在 `docs/tasks/` 下 task-scoped note，不新建 top-level current 文档。

至少覆盖：

### Product continuity

```text
fresh isolated Game startup
real Provider accepted Turn
multiple accepted Turns
normal exit
reopen same game_id/head/conversation
named Save
continue Future A
Load old Save
next Provider request excludes Future A-only marker
continue Future B
Recover Previous Progress
Future A exact restoration
next Provider request includes A truth and excludes B-only marker
optional reciprocal Recover back to B
normal exit/reopen after Recover
```

### Context boundary

```text
accepted history crosses recent-12 boundary
current user exactly once and last
Regenerate after reopen
Correction after reopen
Load excludes rolled-back future
Recover excludes displaced alternate future
Prompt/provider messages are rebuilt, not persisted truth
raw opaque World JSON is not injected accidentally
```

### Process / physical safety

```text
second product instance rejected
owner process crash releases single-writer
kill before durable COMMIT -> last committed truth
kill after COMMIT/before UI observation -> committed truth on reopen
verified latest/previous backup remains discoverable
normal crash does not show corruption UX
isolated physically corrupt DB shows recovery UX
```

### UI polish

```text
healthy READY
physical corruption + verified backup
physical corruption + no verified backup
interrupted recovery + verified backup
fullscreen/wide
1280×720
960×540
```

对每个场景回答：durable current truth、Conversation projection、Provider Context、player-visible UI、backup/recovery state、PASS/FAIL evidence。

---

## 6. Decision Digest / Invariants

### DEC-01｜Reality test, not new architecture

G3-07 默认不新增 schema、不新增 persistence owner、不建设新 framework。发现 bounded defect 可以最小修；若修复需要重开 persistence architecture，停止并返回 `BLOCKED`。

### DEC-02｜Real Provider is blocking in G3-07

必须至少证明真实 DeepSeek 通过正式 product/Runtime/Context path 完成恢复历史后的继续游戏。

要求：

- 不允许只调用 Provider unit seam 然后宣称 end-to-end；
- request 必须来自 restored/recovered Conversation → Context Assembly；
- streaming 正常结束；
- completion 经 persist-before-accept durable；
- reopen 后该 Turn 仍存在；
- 不记录 API key / Authorization。

若短暂 `transport`，允许有限重试并记录每次结果；若在合理验证窗口持续不可用，返回 `BLOCKED_EXTERNAL_PROVIDER` / `BLOCKED`，不得用离线测试替代 G3-GATE 证据。

### DEC-03｜Bounded Context must survive reality path

至少跨过 current recent-12 边界。可以用 deterministic durable seed 构造较老 accepted history，再使用真实 Provider 完成关键 Turn，避免为了证明 bounded context 浪费大量真实调用。

必须证明：

```text
system
+ recent accepted working set
+ current player exactly once at last position
```

Load/Recover 后另一条 future 的 marker 不得进入下一次 Provider request。

### DEC-04｜Use explicit future markers

Reality harness 使用不会误撞的 task marker，例如：

```text
G307_FUTURE_A_ONLY
G307_FUTURE_B_ONLY
```

marker 可以出现在玩家输入/accepted history 中，用来证明 request isolation；不要求模型照抄 marker。

### DEC-05｜Owner UI feedback is required polish

当前 G3-06 UI 在全屏/宽屏时把唯一 `DatabaseRecoveryButton` 放在右下角，Owner 已确认“不够显眼”。

修正目标：

```text
中央 startup failure / data damaged 提示
↓
紧邻其下
[恢复最近安全备份]
```

必须：

- 移动已有唯一 recovery action，而不是复制第二个按钮；
- healthy READY 时隐藏；
- corrupt/interrupted + verified backup 时显示；
- 无 verified backup 时不显示可点击恢复动作；
- confirmation 继续说明：可能丢失 backup 之后的新进度、损坏原件保留、不是普通 Save/Load；
- 1280×720、fullscreen/wide、960×540 均明显可见且不遮挡 composer/Narrative；
- 不借机重做三栏 UI。

### DEC-06｜Normal product path stays primary

Reality Test 必须覆盖正式 `CurrentGameRuntime + Application Shell + Narrative View + Provider Adapter` 路径。内部 persistence API 测试是补充证据，不可替代 product continuity。

### DEC-07｜No owner-data destruction

所有自动 crash/corruption 测试继续使用明确 task-owned isolated DB，例如 `build/g3_07_reality` / `tests/.tmp/g3_07_*`。禁止损坏或清理默认 `user://my-world/current-game.sqlite`。

### DEC-08｜Measure, do not prematurely optimize

记录现实路径至少以下指标：

```text
final DB size
Save-triggered physical backup refresh elapsed time
graceful-close backup refresh elapsed time
reopen elapsed time where practical
```

本阶段不设拍脑袋硬性能阈值。若出现明显多秒级冻结或失败，必须报告并判断是否阻塞产品 Reality Test；否则把数据带给未来 G7。

### INV-PERSIST-01

Game/head/World/Conversation/Save/Recovery 不能在综合路径中出现 mixed-generation / half-switch / duplicate accepted truth。

### INV-PERSIST-02

Backup 仍不是 normal gameplay fallback truth；Reality Test 不通过从 backup 拼接 current 来“修”逻辑错误。

### INV-PRODUCT-01

G3 的核心价值是：玩家可以长期继续同一个 AI RPG 世界，并且 Save/Load/Recover/异常恢复不会要求理解数据库工程细节。

### INV-SCOPE-01

不得开始 G4 World Pack、G5 World semantics、G6 UI redesign、G7 long-session platform、Timeline browser、backup browser、任意 Turn rewind。

---

## 7. Scope

### Allowed

- `src/main.tscn` / `src/应用壳.gd` 的最小灾难恢复按钮位置修正；
- G3-07 reality harness / test scripts / task notes；
- 若 Reality Test 暴露 bounded G3 persistence bug，允许最小相关修复；
- current export/run harness 的必要测试参数；
- focused regression adaptation；
- task-owned metrics/evidence report。

### Prohibited

- schema v5 或新 gameplay persistence tables，除非发现 blocker 并先返回架构重开；
- G4/G5/G6/G7 implementation；
- full UI redesign；
- cloud backup/sync；
- backup browser/history manager；
- Timeline/branch browser；
- arbitrary per-Turn rewind；
- external DB/server/.NET switch；
- persistence of Prompt/Provider messages as truth；
- output-length caps / `max_tokens` convenience limits；
- destructive tests against unknown/Owner data。

---

## 8. Required Deliverables

1. `G3-07_实现前现实验证矩阵.md` 或等价 task-scoped matrix。
2. Owner-requested central disaster-recovery button placement fix。
3. Focused UI test at fullscreen/wide, 1280×720, 960×540。
4. Integrated isolated reality harness covering resume → Save → Future A → Load → Future B → Recover → reopen。
5. Bounded-context proof across recent-12 with A/B future markers。
6. Successful real DeepSeek continuation after restored/recovered durable history。
7. Persist-before-accept + reopen proof for that real generated Turn。
8. Exact-PID crash/reopen and single-writer focused revalidation using existing production paths。
9. Physical backup/recovery focused revalidation; no Owner-data destruction。
10. DB/backup/reopen timing + DB-size evidence note。
11. G3-06..G3-01 and relevant G2 regressions。
12. Windows Desktop export + exported executable smoke。
13. Clean Git diff/status + secret/dependency hygiene。
14. Final engineering evidence record under `docs/tasks/`.

---

## 9. Engineering Acceptance

### AC-01 UI recovery discoverability

- isolated corrupt-current fixture displays central failure explanation;
- when verified backup exists, `恢复最近安全备份` is immediately adjacent below that explanation in wide/fullscreen and 1280×720;
- 960×540 remains usable;
- no duplicate recovery button remains in right-bottom World Surface;
- healthy startup does not show the disaster recovery action;
- no verified backup does not offer a false recovery action。

### AC-02 Resume continuity

Normal exit/reopen preserves exact same `game_id`, active current, durable accepted Conversation and relevant Save/Recovery availability.

### AC-03 Save / future / Load isolation

- create named Save S;
- generate/accept Future A containing `G307_FUTURE_A_ONLY` in accepted history;
- Load S;
- next assembled/request messages do not contain A marker;
- no duplicate/half Conversation projection。

### AC-04 Alternate future / Recover isolation

- after Load, create Future B containing `G307_FUTURE_B_ONLY`;
- Recover Previous Progress;
- exact A durable history/current restored;
- next request contains appropriate A history and excludes B marker;
- reciprocal Recover may return to B without history mixing。

### AC-05 Real Provider continuity

At least one real DeepSeek Turn must be generated **after a Restore or Recover**, through the real product Context/Provider path, stream to a valid terminal completion, commit durably, and survive reopen.

Recommended to obtain multiple real turns across the whole path (e.g. pre-Save and post-Recover), while older context can be deterministically seeded to control cost.

### AC-06 Context boundedness

Cross recent-12 boundary and prove current user exactly once/last; rolled-back alternate future absent; no persisted Prompt/raw World JSON becomes request truth.

### AC-07 Crash / writer safety

Focused existing harness proves second writer blocked, owner crash releases lock, pre-COMMIT kill keeps last truth, post-COMMIT observation gap reopens committed truth, and normal crash does not trigger corruption UX.

### AC-08 Physical safety

Verified backup remains usable; isolated corruption recovery continues staged/quarantined behavior; no blank Game fallback.

### AC-09 Reality metrics

Report DB size and backup/reopen elapsed measurements. Obvious user-visible multi-second stalls, repeated errors or hangs must be called out rather than hidden behind PASS.

### AC-10 Regression / export

G3-06..G3-01 + relevant G2 suites PASS; Windows Desktop export and exact executable/PID smoke PASS; no secret leakage; no output length cap added。

---

## 10. Product Value Acceptance / Owner UAT

Independent Review PASS 后仍需 Owner UAT；Agent 不得宣称 Product PASS。

Owner UAT 应尽量短，但覆盖组合体验：

```text
正常 run-game
→ 连续玩几 Turn
→ Save
→ 再玩出一个明显 future
→ Load
→ 确认 AI 不知道被回滚 future
→ 再继续一个 alternate future
→ Recover Previous Progress
→ 确认原 future 回来且 AI 不串线
→ 正常退出/reopen
```

另用 G3-06/G3-07 isolated damaged fixture 确认新的中央 recovery button 位置明显、易理解。

G3-GATE Product FAIL 条件包括：

- 组合使用时 Narrative/history 重复、混线、丢失；
- Load/Recover 后 AI 泄漏另一条 future；
- reopen 变成空白局或不同 Game；
- persistence/recovery 需要玩家手工找数据库文件；
- disaster recovery action 在阻断页面仍明显难发现；
- real Provider 无法从 recovered durable history 正常继续。

---

## 11. Validation Order

按成本从低到高：

```text
1. freshness / parse / diff-check
2. central recovery-button focused UI tests
3. deterministic integrated Save/Load/Recover/Context reality harness
4. G3-06 single-writer / backup / crash focused regressions
5. G3-05..G3-01 + G2 offline regressions
6. Windows Desktop export + launcher smoke
7. real DeepSeek product continuity after Restore/Recover
8. reopen after real accepted Turn
9. metrics/evidence collection
10. final diff/dependency/secret/status check
```

不要在低成本 Gate 失败时浪费真实 Provider 调用。

---

## 12. Git / Integration

- 开始记录 `git rev-parse HEAD`、`git status --short`、`git fetch origin`。
- Formal code base：`7e2e622f03782a1d66f5f8837d739f900615b775`；current main 还必须包含 G3-07 `AGENTS.md` 与本 packet。
- 不覆盖 unknown dirty worktree。
- authoritative push 前 fetch / compare `origin/main`；有并发提交先审计并吸收或返回。
- implementation commit message 应明确 `G3-07 persistence reality test` / UI polish outcome。
- push 后确认 `HEAD == origin/main` 且 worktree clean。
- Task Packet 文档 commit 不是 Engineering PASS 证据。

---

## 13. Stop / Return Conditions

返回 `BLOCKED` 而不是绕过，如果：

- real Provider 在合理有限重试后持续不可用，无法获得 G3-07 blocking real-continuity evidence；
- Reality Test 暴露需要 schema/ownership/architecture 大改的 persistence defect；
- Save/Load/Recover 组合出现 mixed durable truth 且不能用 bounded repair 修复；
- single-writer / backup / corruption regression 发生真实退化；
- current authority/main 出现 superseding decision；
- 只能通过破坏 Owner 真实数据才能验证。

不得为了 PASS：

- 用离线 Provider mock 替代真实 Provider Gate；
- 忽略 `transport`/failure；
- 持久化 Prompt 当恢复捷径；
- 回退到 Transcript reconstruction；
- 增加 arbitrary Narrative validator；
- 开始 G4。

---

## 14. Final Report Contract

完成后返回：

```text
READY FOR INDEPENDENT REVIEW
```

并报告：

- start/final HEAD、origin/main、worktree；
- reality matrix path；
- exact UI placement change + resolutions verified；
- integrated Save/Load/Recover/reopen evidence；
- A/B marker Context isolation evidence；
- real Provider attempt count/result、post-Restore/Recover request/stream/durable/reopen evidence；
- single-writer/crash/backup focused regression；
- full relevant regressions；
- Windows export/executable evidence；
- DB size and measured backup/reopen timings；
- secret/dependency/output-cap scope check；
- any bounded repair made；
- remaining risk before G3-GATE；
- no claim of Product PASS / G3-GATE PASS。
