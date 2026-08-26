---
title: my world｜G2-04 Final Repair｜IR-03 closed + IR-04 empty completion integrity
task_id: G2-04-FINAL-REPAIR
type: implementation-repair
owner: KimiCode K3
status: current-repair-packet
created: 2026-08-26
updated: 2026-08-26
base: d0d5d47f487fdb75f31de5349894517a830a51e8
supersedes_for_repair: docs/tasks/G2-04_TURN_CONVERSATION_DOMAIN_V0_1_TASK.md
---

# TASK｜G2-04 Final Repair｜IR-04 Empty Completion Integrity

## 1. Current Review Result

IR-03 已通过 Independent Review：completed latest Turn 的 Regenerate request 现在正确为 previous accepted pairs + current user，当前旧 accepted assistant 不再进入 replacement request。

当前唯一 blocking defect：

> **IR-04｜empty / whitespace-only completion must not become accepted GM truth.**

完成后最高状态：`READY FOR INDEPENDENT REVIEW`。不得开始 G2-05。

## 2. Read First

先 fetch / fast-forward 最新 `origin/main`，记录 HEAD / status，然后读取：

1. `AGENTS.md`
2. 本文件
3. `docs/tasks/G2-04_TURN_CONVERSATION_DOMAIN_V0_1_TASK.md`
4. `src/domain/会话.gd`
5. `src/ui/叙事对话视图.gd`
6. `tests/g2_04_会话域离线测试.gd`
7. `tests/g2_03_gui驱动测试.gd`

其余 G2-04 invariants / scope 继续有效。

## 3. IR-04 Root Cause

真实 IR-03 GUI 回归已观察到一次 Provider 快速正常结束但没有产生可接受正文 delta 的情况。

当前 Adapter 遇到 `[DONE]` 会发 `completed()`，即使本次没有任何非空 content delta。随后 UI 调用：

```text
conversation.complete_generation()
```

而当前 Domain 无条件把：

```text
pending_player_text → player_text
draft_text          → accepted_gm_text
has_accepted_response = true
```

所以 zero/whitespace draft 会成为正式 accepted GM。

这会导致：

```text
new turn + empty completion
→ accepted [player, ""]
```

以及更严重的：

```text
completed turn
→ regenerate / correction
→ empty completion
→ old accepted GM 被 "" 覆盖
```

现有 T09 还把“没有任何 delta 仍 complete 成 accepted 空 GM”编码成合法行为，必须修正。

## 4. Product Boundary

不要把本修复做成 Narrative 长度限制。

正式语义：

```text
任何非空白内容，包括很短的 1 个字符
→ 允许成为模型输出

zero-length / whitespace-only
→ 没有产生 GM Narrative
→ generation attempt 不能成为 accepted completion
```

禁止：

- minimum chars；
- minimum words；
- Narrative quality classifier；
- “至少写 N 字”；
- 因此新增 `max_tokens` 或其它长度平台。

`Narrative richness over artificial brevity` 保持不变。

## 5. Required Semantics

### A. New Turn empty completion

```text
begin turn
→ provider completed
→ draft empty/whitespace
```

必须：

```text
GenerationState = FAILED-equivalent
has_accepted_response = false
no accepted entry
same logical turn remains retryable
```

Retry 后若有任意非空白 content：

```text
same turn identity
→ accepted normally
```

### B. Completed Turn Regenerate empty completion

```text
old accepted user + GM
→ regenerate
→ empty/whitespace completion
```

必须：

```text
old accepted player unchanged
old accepted GM unchanged
same turn identity
attempt becomes failed/retryable
```

再次 Regenerate 成功后才原子替换 GM。

### C. Completed latest Correction empty completion

```text
old accepted player + GM
→ correct_latest(new player text)
→ empty/whitespace completion
```

必须：

```text
old accepted player unchanged
old accepted GM unchanged
corrected pending text not partially accepted
attempt failed/retryable
```

### D. Failure signal / UX

推荐由 Conversation Domain 在 completion acceptance 时检查：

```text
draft_text.strip_edges().is_empty()
```

若为空，转为明确 failed-equivalent，并发 domain failure code，例如：

```text
empty_generation
```

等价命名可接受。

UI 给该 code 一个正常玩家可读提示，例如：

> 本次没有生成有效叙事，可点击「重新生成」重试。

不要显示工程细节。

Adapter 默认不改：它可以继续表示 HTTP/SSE/API 正常结束；Domain 决定该 attempt 是否产生可接受的游戏 GM response。

## 6. Required Tests

确定性 Domain tests 必须覆盖：

```text
new turn → zero-delta complete
→ no accepted entry
→ failed/retryable
→ retry same identity → non-empty complete → accepted
```

```text
new turn → whitespace-only draft → complete
→ no accepted entry
→ failed/retryable
```

```text
completed turn → regenerate → zero/whitespace complete
→ old accepted pair unchanged
→ same identity
→ retry/regenerate non-empty → atomic replacement
```

```text
completed latest → correction → zero/whitespace complete
→ old accepted player + GM unchanged
→ corrected text not accepted
```

同时修改现有 T09：不得再把 empty completion 视为合法 accepted completion。

必须保持：

- IR-03 one-turn / multi-turn request context assertions；
- IR-01 duplicate-player regression；
- IR-02 regenerate-abort direct-send regression；
- AC-07/08 correction rollback；
- multiple-turn ordering；
- typography / responsive；
- G2-03 / G2-02 regressions。

真实 DeepSeek：不要求强行复现偶发 empty response。正常 completed→Regenerate smoke + IR-03 request assertion通过即可；empty path 用 deterministic Domain test 证明。

## 7. Allowed / Prohibited Scope

Allowed：

- `src/domain/会话.gd` 最小 completion acceptance repair；
- `src/ui/叙事对话视图.gd` 增加 empty-generation 玩家提示；
- 直接相关 tests。

Prohibited：

- 修改 Provider Adapter，除非发现新的独立 transport bug；若发现先返回说明；
- 字数阈值 / quality classifier；
- automatic multi-retry platform；
- G2-05 Context Assembly；
- G3 Persistence / Save / Timeline；
- 大规模重构。

## 8. Validation

focused → full：

1. Godot headless parse；
2. G2-04 Domain tests（含 IR-04）；
3. G2-03 offline regression；
4. G2-02 adapter smoke；
5. real DeepSeek GUI normal + completed→Regenerate + IR-03 context assertions；
6. IR-01 / IR-02 / correction regressions；
7. typography / responsive smoke；
8. Windows export + `run-game.cmd` smoke；
9. `git diff --check` + secret / Authorization hygiene + clean status。

GUI automation继续使用 exact executable + PID。

## 9. Git

- start from latest `origin/main`（至少包含 `d0d5d47...` 与本更新 packet）；
- pre-push freshness revalidation；
- fast-forward push；
- no force push；
- 不覆盖未知 dirty worktree。

## 10. Final Report

```text
Result
READY FOR INDEPENDENT REVIEW | BLOCKED

IR-04 Fix
- root cause
- exact Domain acceptance behavior
- empty/whitespace failure code

Deterministic Evidence
- new-turn empty → retry
- whitespace-only
- regenerate empty preserves old pair
- correction empty preserves old pair

Regression
- IR-03
- IR-01 / IR-02
- correction
- real DeepSeek smoke
- G2-03 / G2-02

Scope Check
- no length threshold
- adapter unchanged
- no G2-05 / G3

Git
- start HEAD
- repair commit
- push
- clean status
```
