# MW-005 Revision 4 Addendum — Bounded Narrative Style Weight Polish

Work Item: **MW-005 — Three Kingdoms Literary Style Primer v0.1**  
Capability-Anchor: **G4 Primary Source Assets & Local Game**  
Revision: **4**  
Review target: **IR#4**  
Triggered-By: Owner feedback after Revision 3: style direction is correct but still needs modest additional weight  
Implementer: **Zcode + GLM-5.3-flash**（Owner weekend routing override）  
Reviewer: **GPT**  
Status: **ACTIVE — ZCODE**  
Task Branch: `mw-005-r4-bounded-style-weight`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-005-r4`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**  
Product UAT: **defer and combine with final G5 Owner checkpoint**

## 1. Purpose

Strengthen the already-existing Narrative-only positive voice preference without reopening Primer content, Source generation or authority boundaries.

This is intentionally a **small weight adjustment**, not a new style system.

## 2. Frozen authority boundary

Keep all Revision-3 boundaries unchanged:

```text
Literary Style Reference
= expression / voice reference only
!= Game truth
!= future canon
!= NPC destiny
!= Player/actor Knowledge
!= semantic-consequence authority
!= World Evolution causal input
!= Public-d20 control/adjudication authority
!= mandatory output protocol
```

Do not modify Primer bytes or republish Source generation.

Current generation remains:

`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`

## 3. Minimal implementation target

Prefer changing **only** the existing request-only `STYLE_NARRATIVE_ANCHOR_CUE` wording in:

`src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`

Do not change placement or consumer routing unless a fresh audit proves the current Revision-3 placement no longer exists.

Desired semantic emphasis:

> 当 Literary Style Reference 存在时，它不是可有可无的古代词汇点缀，而是当前中文 GM Narrative 的主要表达偏好之一。在不牺牲清晰、自然与当前 Game 事实准确性的前提下，请让整段叙事持续体现其句法节奏、人物称谓与礼法、人物说话方式、叙事距离，以及消息/军政信息如何通过人物、使者、塘报、文书、问答与场景进入故事。不要只把现代通用 RPG / 网文骨架换成几个古代名词；当通用现代叙述习惯与参考语体发生冲突时，在保持长期可读的前提下优先参考语体。仍不要机械模仿章回套语、强行半文言或照抄范例。

Exact final copy may be tightened for prompt economy, but must preserve that semantic priority.

## 4. Do not add

- new examples or Primer v0.2;
- duplicate style blocks;
- style score/classifier;
- output rejection/retry;
- mandatory `却说/且说` or chapter formula;
- half-classical conversion rules;
- new parser/protocol;
- global style platform;
- Public-d20 control style input;
- G5-01/G5-04 style input.

## 5. Validation

No separate Owner UAT loop is required. Run only bounded engineering regression sufficient to prove the existing routing boundary remains intact:

- ordinary continuation / Opening receive the strengthened cue once;
- Public-d20 resolution/NO_CHECK/degraded Narrative still receive it once;
- Public-d20 control/control_recovery remain style-free;
- G5-01 semantic and G5-04 world-only remain style-free;
- Primer/source bytes and generation fingerprint unchanged;
- existing MW-005 focused tests green;
- MW-010 focused integrated matrix remains green;
- `git diff --check` clean;
- Windows export validation PASS because production GDScript changes.

Owner prose judgment is intentionally deferred to the combined G5 product checkpoint.

## 6. Worktree / scope discipline

Before starting:

1. refresh current `my-world/main` and `Vibe-Coding/main`;
2. inspect `git worktree list --porcelain`;
3. MW-010 is Engineering PASS / CLOSED and integrated; remove its worktree only if clean, pushed/reachable and free of unknown user work, using `git worktree remove`, then `git worktree prune`;
4. create exactly `D:/AI/Projects/.worktrees/my-world/mw-005-r4`;
5. use branch `mw-005-r4-bounded-style-weight`;
6. keep the active R4 worktree through GPT IR#4.

Do not reopen G5-07, add another style platform, or start the combined Owner UAT inside this implementation task.
