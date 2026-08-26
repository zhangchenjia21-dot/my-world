---
title: my world｜G2-04 IR-03 Regenerate Provider Context Repair
task_id: G2-04-IR-03
type: implementation-repair
owner: KimiCode K3
status: current-repair-packet
created: 2026-08-26
base: 0bf1f012366db7271664a192c1c30e60947cc5c9
supersedes_for_repair: docs/tasks/G2-04_TURN_CONVERSATION_DOMAIN_V0_1_TASK.md
---

# TASK｜G2-04-IR-03｜Regenerate Provider Context Repair

## Outcome

修正 G2-04 Independent Review 发现的唯一 blocking defect：**completed latest Turn 的 Regenerate 请求不能把该 Turn 的旧 accepted assistant 一起发送给 Provider。**

Domain 仍需保留旧 accepted assistant 作为稳定 accepted truth，直到 replacement 成功；但 replacement request 必须以当前 player user 结束，真正请求同一 player action 的新 GM response。

完成后最高状态：`READY FOR INDEPENDENT REVIEW`。不得开始 G2-05。

## Read First

先 fetch / fast-forward 最新 `origin/main`，记录 HEAD / status，然后读取：

1. `AGENTS.md`
2. 本文件
3. `docs/tasks/G2-04_TURN_CONVERSATION_DOMAIN_V0_1_TASK.md`
4. `src/domain/会话.gd`
5. `tests/g2_04_会话域离线测试.gd`
6. `tests/g2_03_gui驱动测试.gd`

本 repair packet 只在 IR-03 冲突点上覆盖原 Task Packet；其余 G2-04 invariants / scope / acceptance 继续有效。

## IR-03 Root Cause

当前 `Conversation.build_provider_messages()` 对 active completed Turn 的 Regenerate 使用：

```text
if turn == _active_turn:
    append current user
    if has_accepted_response and pending_player_text == player_text:
        append old accepted assistant
```

于是第一次 completed Turn regenerate 的 Provider messages 为：

```text
[system, user(current), assistant(old)]
```

多 Turn 情况为：

```text
[system,
 previous user, previous assistant,
 current user, current old assistant]
```

这把两个不同概念混在一起了：

```text
Accepted Domain Truth stability
!=
Regenerate Provider Request content
```

旧 assistant 应在 Domain 内保持稳定，供 Cancel/Fail rollback；但它不应条件化当前 replacement generation。

不要通过 DeepSeek beta prefix continuation / `prefix=true` 修补。当前正式 Adapter 不改。

## Required Semantics

### Regenerate completed latest Turn

假设：

```text
turn1 = accepted user1 + assistant1
turn2 = accepted user2 + assistant2   # latest
```

开始 regenerate turn2 后：

Domain accepted truth 仍是：

```text
turn1 user1 + assistant1
turn2 user2 + assistant2
```

但 Provider request 必须是：

```text
system
user1
assistant1
user2
```

要求：

- `user2` 恰好一次；
- `assistant2` occurrence == 0；
- last role == `user`；
- replacement draft 与 old accepted assistant 分离；
- completed 后 same turn identity 原子把 `assistant2` 替换为新 GM；
- Cancel/Fail 后 old `assistant2` 保持 accepted。

对于只有一个 Turn：

```text
[system, user1]
```

### Correction

latest-turn correction 继续保持：

```text
previous accepted pairs
+ corrected current user
```

不得带 current Turn 的 old accepted assistant；Cancel/Fail rollback 语义保持不变。

### New Turn / Retry

不得破坏现有：

- new Turn context；
- cancelled/failed first-attempt Retry；
- IR-01 duplicate-player protection；
- IR-02 regenerate abort → direct new Send；
- accepted ordering / identity。

## Required Regression Changes

### Focused Domain Test

修正当前 T04 中错误断言：不得再期待 regenerate context `[system,user,assistant]`。

至少断言：

```text
first completed turn
→ regenerate
→ provider roles == [system, user]
→ old accepted assistant count == 0
→ current player count == 1
→ last role == user
→ Domain accepted_gm_text still == old GM before completion
→ new completion atomically replaces accepted_gm_text
```

再增加 / 强化多 Turn regenerate：

```text
previous accepted pairs preserved
current latest user exactly once
current latest old assistant absent
last role == user
```

### Real DeepSeek GUI

在现有 completed→Regenerate 真实路径上，对 `_sent_contexts[-1]` 增加：

- last role == `user`；
- 当前 Turn old GM assistant 不在 request；
- previous completed pairs 正常保留；
- 当前 player input 恰好一次；
- real generation completed；
- accepted same turn identity + new GM。

“Provider 返回了非空文本”单独不能证明 Regenerate 正确。

## Validation

按 focused → full：

1. Godot headless parse。
2. G2-04 domain focused tests。
3. G2-03 offline regression。
4. G2-02 adapter smoke（adapter 不应修改）。
5. Real DeepSeek GUI completed→Regenerate，带新增 request-context assertions。
6. IR-01 / IR-02 / correction regressions。
7. typography / responsive smoke 保持通过。
8. Windows export + `run-game.cmd` smoke。
9. `git diff --check`、secret / Authorization hygiene、clean status。

GUI automation继续使用 exact executable + PID。

## Scope

Allowed：

- `src/domain/会话.gd` 的最小 context assembly repair；
- 直接相关 G2-04 / G2-03 tests。

默认不应需要修改 UI / scene / typography；若确实需要，Final Report 解释原因。

Prohibited：

- 修改 Provider Adapter 来做 prefix completion；
- G2-05 Context Assembly / retrieval / summarization / token budgeting；
- G3 Persistence / Save / Timeline；
- 新 Provider platform；
- 大规模重构。

## Git

- base = 当前最新 main（至少包含 `0bf1f012...` 与本 repair packet）；
- pre-push freshness revalidation；
- fast-forward push；
- no force push；
- 不覆盖未知 dirty worktree。

## Final Report

```text
Result
READY FOR INDEPENDENT REVIEW | BLOCKED

IR-03 Fix
- root cause
- exact build_provider_messages change

Provider Context Evidence
- one-turn regenerate roles
- multi-turn regenerate roles
- current old assistant occurrence
- last role
- real DeepSeek request assertion

Regression
- IR-01
- IR-02
- correction
- G2-03 / G2-02

Scope Check
- no G2-05 / G3
- adapter unchanged

Git
- start HEAD
- repair commit
- push
- clean status
```
