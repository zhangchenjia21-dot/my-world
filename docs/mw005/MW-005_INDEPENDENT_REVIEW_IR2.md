# MW-005 Independent Review — IR#2

Status: **ENGINEERING PASS — OWNER UAT**  
Work Item: **MW-005 — Three Kingdoms Literary Style Primer v0.1**  
Revision reviewed: **2**  
Review round: **IR#2**  
Reviewer: **GPT**  
Reviewed main: `4e2c467fd9468dfa9c3d296c66e04e16ed9628df`  
Revision-2 implementation SHA: `583dde4d4dc9e4b6f2b82dd5f0cae0960dcc62cc`  
Revision-2 evidence SHA: `4e2c467fd9468dfa9c3d296c66e04e16ed9628df`  
Date: 2026-09-05

## Verdict

Revision 2 closes the blocking consumer leak identified in IR#1. MW-005 is now **ENGINEERING PASS — OWNER UAT**.

The Engineering verdict does not claim that the prose is subjectively better in play. The next gate is Owner A/B UAT using a **new Three Kingdoms Game** that freezes Source generation:

`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`

## Independent inspection performed

IR#2 inspected the actual pushed production diff, current production files, focused test code, Revision-2 evidence and the frozen Three Kingdoms source fixtures rather than relying on the handoff summary alone.

Inspected seams include:

- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`
- `src/首次开场/L3_外交层/游戏本地上下文公开接口.gd`
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
- `tests/mw005/公开D20控制文风排除测试.gd`
- `docs/mw005/MW-005_REVISION2_CONTROL_LANE_STYLE_EXCLUSION_EVIDENCE.md`
- current Three Kingdoms World/Character fixtures and the approved Primer input

GitHub exposes no independent CI status for the implementation commit, so the reported Godot/export execution remains implementer evidence. IR#2 independently inspected whether the tests and production changes materially prove the required contract; GPT did not independently rerun Godot in this review environment.

## Findings

### F01 — Public d20 control/control_recovery no longer receive the World literary Primer — PASS

`PublicD20ActionAdjudicationProcess._control_messages()` now calls the existing Game-local projector as:

```text
project(session_runtime.world_state, false)
```

Both `control` and `control_recovery` use `_control_messages()`, so the exclusion applies to both mechanics-adjudication stages.

The projector's `include_style=false` path still appends the normal Game setup, World factual sections and Player/Character factual material. It does **not** switch to `project_world_only()`, so mechanics has not been starved of factual context merely to remove literary examples.

This closes IR#1 F01 for the actual MW-005 v0.1 carrier: the current Three Kingdoms literary reference is a World `semantic_section` with `section_type=literary_style_reference`.

### F02 — Narrative consumers continue to receive the Primer — PASS

The new projector parameter defaults to `true`. Existing opening and ordinary GM-Narrative callers therefore retain their prior behavior.

Public d20 `resolution_narrative`, `no_check_narrative` and `degraded_narrative` also continue to call the default projector and therefore receive the Primer under the explicit non-factual literary boundary.

No fixed output format, chapter-novel formula, parser/classifier gate or Narrative retry protocol was introduced.

### F03 — G5-04 World Evolution exclusion remains intact — PASS

`project_world_only()` continues to call the World projection with style disabled. The literary reference therefore remains absent from World Evolution causal baseline.

Revision 2 does not route style into G5-04, Actor Knowledge, MW-006 mechanics grounding or any durable world mutation.

### F04 — Source bytes/generation/freeze semantics remain unchanged — PASS

Revision 2 changes only Runtime projection/request consumption and adds focused proof. It does not edit the approved Primer bytes or republish Source.

The task-owned fixture still carries the literary section in the Three Kingdoms World Pack, and the approved task input and installed fixture content remain byte-identical at the inspected source seam.

The expected generation remains:

`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`

Old Game freeze semantics from Revision 1 are unchanged.

### F05 — Focused proof matches the correction contract — PASS

The new focused test drives a frozen Three Kingdoms Game with Public d20 through actual `request_assembled(stage, messages)` observation and covers:

- `control` exclusion;
- `control_recovery` exclusion after malformed control output;
- `no_check_narrative` inclusion;
- `resolution_narrative` inclusion after CHECK_REQUIRED;
- `degraded_narrative` inclusion after recovery exhaustion;
- factual World and Player Character material still present in control requests;
- deterministic RNG called exactly once for CHECK_REQUIRED and zero times for degraded no-check handling;
- no duplicate accepted actions;
- unchanged Source generation assertion.

The implementer reports the focused suite as 51 PASS / 0 FAIL.

### F06 — Relevant regressions/evidence are consistent with the production diff — PASS

The implementer reports green regressions for:

- MW-005 main Primer/freeze/world-only coverage;
- Public d20 mechanism/retry/no-reroll coverage;
- Public d20 UI integration;
- MW-006 mechanics grounding;
- G5-04 selective world evolution;
- first-opening runtime focus;
- Windows export validation;
- `git diff --check`.

Real Provider calls were 0, which is acceptable for this engineering correction.

## Non-blocking advisory

### A01 — `include_style=false` currently filters the World literary carrier, not hypothetical future Character-carried style sections

The generic projector comment says control preserves factual World/Player/Character material while filtering `literary_style_reference`, but the current implementation passes `include_style` into `_append_world()` only; `_append_character()` still uses the default style-including section renderer.

This is **not a blocker for MW-005 v0.1** because the authorized Primer carrier is the Three Kingdoms **World Pack**, and the inspected Liu Bei Character Card contains only identity/T0-profile section types. No current MW-005 Character source carries `literary_style_reference`.

If a future product decision introduces Character-specific literary references and intends the same mechanics-control exclusion, the projector seam should be extended deliberately then. Do not build that speculative generalization now.

## Engineering closeout state

```text
MW-005 Revision 2 / IR#2
= ENGINEERING PASS — OWNER UAT
```

Protected authority boundary after IR#2:

```text
Literary Style Reference
→ Opening / ordinary GM Narrative / d20 narrative prose

!= Public d20 control/control_recovery mechanics authority
!= G5-04 World Evolution causality
!= Player/actor Knowledge
!= future canon / NPC destiny
```

## Owner UAT gate

Use a **new** Three Kingdoms Game. Evaluate product value, not prompt visibility:

1. adviser/official dialogue feels more naturally period-rooted without making everyone ornate;
2. remote intelligence enters through messenger/report/question/scene rather than repeated `XX方向：` dashboard headings;
3. war/administrative narration feels less like a modern strategy briefing;
4. prose remains readable rather than forced semi-classical Chinese;
5. no mechanical overuse of `却说` / `且说` / poetry / chapter-ending tics;
6. no future *Romance of the Three Kingdoms* plot leaks merely because the Primer exists;
7. MW-004 Player Agency remains natural.

Only Owner can issue Product PASS / CLOSED after that UAT.
