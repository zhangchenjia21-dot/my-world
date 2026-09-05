# MW-005 Independent Review — IR#3

Status: **ENGINEERING PASS — OWNER UAT**  
Work Item: **MW-005 — Three Kingdoms Literary Style Primer v0.1**  
Revision reviewed: **3**  
Review round: **IR#3**  
Reviewer: **GPT**  
Implementation SHA: `a52236c5ec55bf07a727b4e07c4ef63572b18555`  
Implementation base: `c678dfd04bb1ac7ed933e4a0f806eac3d5f8d7ba`  
Date: 2026-09-05

## Verdict

Revision 3 is **ENGINEERING PASS — OWNER UAT**.

The correction satisfies the frozen Revision-3 outcome: the already-approved Three Kingdoms literary reference is no longer merely one semantic section embedded inside a large factual request. It is now projected as a single request-only narrative style anchor and appended late in each Narrative consumer after factual World/Character/World-Turn and mechanics authority material, while remaining absent from mechanics control, G5-04 causal input and G5-01 semantic analysis.

This Engineering verdict does **not** claim that the prose improvement is perceptible enough in play. The Owner must run a new Three Kingdoms Game and judge the actual Narrative. If the difference remains weak, the next correction should revisit Primer content rather than adding more prompt weight.

## Independent inspection performed

IR#3 inspected the actual pushed branch, implementation diff, production files, focused test code, task packet and implementation evidence. The reviewed implementation is one commit ahead of its base with no unrelated production changes.

Production files inspected:

- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`
- `src/首次开场/L2_流程层/首次开场运行流程.gd`
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`

Proof inspected:

- `tests/mw005/叙事风格锚点显著性测试.gd`
- `tests/mw005/三国文风Primer接线测试.gd`
- `docs/mw005/MW-005_REVISION3_STYLE_SALIENCE_EVIDENCE.md`

GitHub exposes no independent CI/check status for the implementation commit. Reported Godot/export executions remain implementer evidence; IR#3 independently inspected that the tests materially exercise the required production seams.

## Findings

### F01 — factual context and narrative style material are separated without creating a second durable truth — PASS

`GameLocalOpeningContextProjector.project()` now returns:

```text
context_text
= factual Game / World / Player / Character request material

style_reference_text
= derived request-only Literary Style boundary + existing Primer + concise positive cue
```

The Primer remains sourced from the same frozen `literary_style_reference` semantic section. No second persisted style store or copied Source payload is introduced. The style anchor is derived per request.

Primer/World Source bytes were not changed and the Source generation remains:

`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`

No Source republish or schema change occurred.

### F02 — Narrative consumers place the style anchor late enough to address the observed dilution problem — PASS

The actual production consumers now append `style_reference_text` after their other request material:

- first opening: after factual Game / World / Player / Character context;
- ordinary continuation: after factual context **and** materialized World-Turn context;
- Public-d20 resolution narrative: after factual context, Expansion rules and Program-owned outcome authority;
- Public-d20 NO_CHECK/degraded narrative: after factual context and the applicable narrative/control instruction.

This directly addresses the Owner-observed failure mode from Revision 2, where the literary material was present but followed by several thousand characters of factual/mechanics material.

### F03 — positive steering remains bounded and expression-only — PASS

The new `STYLE_NARRATIVE_ANCHOR_CUE` identifies the Literary Style Reference as the default Chinese Narrative voice anchor and names the intended dimensions: sentence rhythm, address/etiquette, dialogue form, information delivery and narrative distance.

It also names the already-observed failure shape — modern strategic-briefing style presentation of military/political information — and prefers diegetic forms such as scene, messenger/report, question/answer or written dispatch when natural.

The cue does **not** introduce a fixed prose template, mandatory chapter-novel formula, modern-word blacklist, parser/classifier, style score, rejection gate or retry loop. Model Freedom First remains intact.

### F04 — Public-d20 control/control_recovery remain style-free — PASS

`_control_messages()` still uses the Revision-2 `project(..., false)` path and never appends the Narrative style anchor.

The new focused proof captures the actual `control` and `control_recovery` requests and asserts absence of:

- Primer marker;
- `literary_style_reference` token;
- Literary Style boundary;
- new positive style cue;

while retaining factual World and Player material.

The Public-d20 mechanics authority boundary therefore remains intact.

### F05 — G5-04 / G5-01 authority boundaries remain intact — PASS

`project_world_only()` still uses style-disabled World projection, so G5-04 causal evaluation receives no literary material or cue.

The focused test also observes the normal G5-01 semantic request and verifies that it contains no Literary Style boundary, Primer marker or positive cue. Revision 3 therefore does not turn expression material into semantic-consequence authority.

### F06 — focused proof materially exercises final requests, not only projector helpers — PASS

The new focused test uses a frozen Three Kingdoms Game and captures real final request messages for:

- first opening;
- ordinary continuation after a committed materialized World Turn;
- Public-d20 control;
- control recovery;
- CHECK_REQUIRED resolution narrative;
- NO_CHECK narrative;
- degraded narrative.

For Narrative stages it verifies Primer exactly once, cue exactly once, boundary → Primer → cue ordering, and placement after relevant factual/mechanics markers. It separately verifies control-lane exclusion and G5-04/G5-01 style-free behavior.

The implementer reports 81 focused assertions PASS / 0 FAIL, plus green MW-005 R1/R2, Opening, Public-d20, MW-006, MW-007, G5-01 and G5-04 regressions, `git diff --check` clean, Windows export PASS and 0 real Provider calls.

### F07 — worktree hygiene requested by Owner was performed safely — PASS

The implementation evidence records inspection and safe removal of the old task worktrees under `D:/AI/Projects` using Git worktree operations rather than blind directory deletion. The active Revision-3 worktree was created at the required location:

`D:/AI/Projects/.worktrees/my-world/mw-005-r3`

This satisfies the Owner's workspace-cleanliness request for this task. Future task worktrees should continue under `D:/AI/Projects/.worktrees/my-world/<task>`.

## Non-blocking advisory

### A01 — future Character-carried literary sections remain outside the current v0.1 contract

As already noted in IR#2, current style filtering is sufficient for the authorized MW-005 carrier because the Three Kingdoms Primer lives in the World Pack. Character-card style sections do not currently exist. If that product capability is introduced later, mechanics-control exclusion must be re-audited deliberately rather than generalized speculatively now.

## Engineering closeout state

```text
MW-005 Revision 3 / IR#3
= ENGINEERING PASS — OWNER UAT
```

Protected semantics after IR#3:

```text
Literary Style Reference
→ single late request-only anchor for Opening / ordinary GM Narrative / d20 Narrative

!= durable world truth
!= future canon
!= Public-d20 control authority
!= G5-04 causality
!= G5-01 semantic-consequence authority
!= Player/actor Knowledge
!= mandatory output protocol
```

## Owner UAT gate

Use a **new** Three Kingdoms Game. Judge only the visible prose outcome:

1. the difference is perceptible without inspecting prompts;
2. sentence rhythm and narrative distance change, not only nouns;
3. adviser/official dialogue feels more period-rooted while remaining readable;
4. remote military/political information more often enters diegetically when appropriate rather than as strategy-dashboard exposition;
5. no mechanical `却说` / `且说` / poetry / chapter-ending tics;
6. no future *Romance of the Three Kingdoms* plot leakage;
7. MW-004 Player Agency remains natural.

If the Owner still cannot perceive a meaningful difference, **do not add another salience/prompt-weight revision**. Reassess the Primer content and selection strategy instead.
