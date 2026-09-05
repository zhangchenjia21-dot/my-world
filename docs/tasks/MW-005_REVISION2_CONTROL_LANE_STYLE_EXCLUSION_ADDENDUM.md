# TASK ADDENDUM｜MW-005 Revision 2｜Exclude Literary Style Reference from Public d20 Control

Status: **ENGINEERING PASS — OWNER UAT**  
Work Item: **MW-005 — Three Kingdoms Literary Style Primer v0.1**  
Revision: **2**  
Review target: **IR#2 — PASS**  
Implementer: **Kimi**  
Reviewer: **GPT**

Canonical parent packet remains:

`docs/tasks/MW-005_THREE_KINGDOMS_LITERARY_STYLE_PRIMER_TASK.md`

IR#1:

`docs/mw005/MW-005_INDEPENDENT_REVIEW_IR1.md`

IR#2:

`docs/mw005/MW-005_INDEPENDENT_REVIEW_IR2.md`

## Correction purpose

Revision 1 correctly separated literary style from G5-04 World Evolution, but the shared Game-local projector also feeds Public-d20 **control** requests. This unintentionally exposed expression exemplars to mechanics adjudication.

The correction is deliberately narrow:

> **Literary style may shape GM prose; it must not shape whether/how Program-owned mechanics are proposed.**

## Required consumer matrix

```text
first opening                         INCLUDE style
ordinary continuation GM narrative   INCLUDE style
Public d20 resolution narrative       INCLUDE style
Public d20 NO_CHECK narrative         INCLUDE style
Public d20 degraded narrative         INCLUDE style
Public d20 control                     EXCLUDE style
Public d20 control_recovery            EXCLUDE style
G5-04 project_world_only()             EXCLUDE style
```

## Implementation constraints

- Keep the approved Primer bytes unchanged.
- Keep Source generation `58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443` unchanged; **do not republish a new generation** for this fix.
- Do not use `project_world_only()` for Public-d20 control because control may still need Game/Player/Character factual context.
- Add the smallest explicit projector/request seam that can include all normal factual Game-local context while excluding the current World-carried `literary_style_reference` from control/control_recovery.
- Do not change Public-d20 decision schema, DC/modifier rules, RNG, retry/no-reroll, accepted Narrative ordering, MW-006 mechanics grounding, G5-04 scheduling, Player Agency, SQLite, Source schema, or Narrative output protocol.
- Do not add a generic context-policy platform.

## Required proof

Focused proof must capture Public-d20 `request_assembled(stage, messages)` from a frozen Three Kingdoms Game carrying the Primer and demonstrate:

1. `control` has no Primer marker, no `literary_style_reference`, and no literary boundary header;
2. `control_recovery` also excludes them when that stage is exercised;
3. the following narrative stages include the Primer exactly once under the non-factual boundary;
4. MW-005 opening/ordinary continuation and `project_world_only()` tests remain green;
5. directly affected Public-d20 regressions remain green, including no-reroll/retry behavior;
6. MW-006 focused grounding regression remains green;
7. `git diff --check` clean and export validation passes if production GDScript changed.

## Review result

Revision-2 implementation:

`583dde4d4dc9e4b6f2b82dd5f0cae0960dcc62cc`

Revision-2 evidence:

`4e2c467fd9468dfa9c3d296c66e04e16ed9628df`

IR#2 verdict:

`ENGINEERING PASS — OWNER UAT`

Engineering completion does not certify prose quality. Owner must perform a new-Game Three Kingdoms A/B UAT before Product PASS / CLOSED.
