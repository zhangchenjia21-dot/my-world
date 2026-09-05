# MW-007 Independent Review — IR#1

Status: **ENGINEERING PASS / CLOSED**  
Work Item: **MW-007 — Mechanics Consequence Timeline Continuity**  
Capability-Anchor: **G5-05 Meaningful Choice / Mechanics Integration**  
Revision reviewed: **1**  
Review round: **IR#1**  
Implementer: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Reviewed implementation SHA: `9494c92ff3b6c9949ff97b86336dbf36baf90942`  
Date: 2026-09-05

## Verdict

MW-007 is **ENGINEERING PASS / CLOSED**.

The task correctly delivered the preferred architecture-preserving outcome: **zero production-code change** plus a production-Runtime/SQLite integration proof that mechanics-grounded semantic consequences participate coherently in Save / close / reopen / Continue / Restore.

This closes MW-007 as an engineering Work Item. It does **not** by itself issue Product PASS for G5-05; Owner product validation still owns whether mechanics feel meaningful and proportionate in actual play.

## Independent inspection performed

IR#1 inspected the actual pushed task commit and focused test implementation rather than relying on the handoff summary alone. The task branch was based on current `main` containing MW-005 Revision 2 and changed only:

- `tests/mw007/机制后果时间线连续性测试.gd`
- `docs/mw007/MW-007_MECHANICS_CONSEQUENCE_TIMELINE_CONTINUITY_EVIDENCE.md`

No production GDScript, persistence schema, Source package, Public-d20 protocol or MW-005 consumer boundary was changed.

GitHub exposes no independent CI status for the task commit. The reported Godot execution is therefore implementer evidence; IR independently checked that the test actually exercises the required production seams and asserts the claimed state transitions.

## Findings

### F01 — V1 Save / close / reopen / Continue continuity — PASS

The focused proof uses real Source library/final-create/runtime/SQLite seams, production Public d20 adjudication with deterministic RNG, the normal G5-01 semantic process, a named Save, runtime close/reopen, and production continuation-context assembly.

It proves that after a CHECK_REQUIRED action whose accepted Narrative materializes a durable consequence:

- Conversation contains the action/Narrative exactly once after reopen;
- the same durable d20 check remains byte/field-equivalent and is not rerolled;
- the semantic consequence remains exactly once;
- reopen alone does not wake a duplicate semantic request;
- explicit semantic reconsideration returns the existing materialization rather than duplicating mutation;
- submitting the already-accepted same action does not call Provider/RNG again;
- later continuation Context contains the committed world consequence through the existing World Turn projection;
- continuation does not create a second mechanics truth or re-project the MW-006 grounding block as ordinary world truth.

### F02 — V2 Restore coherent rewind — PASS

The focused proof creates a Save before the mechanics action, then commits a CHECK_REQUIRED result, accepted Narrative and semantic consequence, and restores the pre-action Save.

After Restore it proves:

- the later Conversation turn is absent;
- the later semantic consequence is absent;
- the later Public-d20 check is absent because it belongs to the same restored World snapshot ownership;
- `matching_accepted_check_for_turn(...)` cannot produce ghost mechanics grounding for the restored-away turn;
- continuation Context contains the retained pre-Save baseline but excludes the restored-away consequence, Narrative, grounding marker and future check id.

This is the required proof that mechanics truth and living-world consequence do not diverge across the current Timeline snapshot/Restore ownership model.

### F03 — No reroll / no duplicate / no second mechanics truth — PASS

The test demonstrates no reroll across reopen and no duplicate semantic materialization. Semantic materialization leaves the Program-owned mechanics record unchanged; the later GM continuation consumes the committed world consequence rather than a new mechanics summary/store.

`NO_CHECK` and existing Public-d20 retry/idempotence remain covered by the reported regressions and no production mechanics code changed.

### F04 — Restore + same caller-owned action_id behavior — PASS with advisory

After restoring away a future check, replaying the **same caller-owned action_id** starts control but later fails loud at durable mutation identity conflict rather than silently reusing or inventing future truth. A fresh action_id proceeds under existing RNG/identity rules.

This satisfies the MW-007 contract because the task was prohibited from inventing a new branch/action identity architecture. However, this remains a product/UX advisory: if actual gameplay can reuse a restored-away action_id through the user-facing path and the fail-loud behavior becomes visible, that would justify a separate identity/Restore product decision rather than a hidden MW-007 fix.

### F05 — Scope discipline — PASS

The implementation did not add:

- SQLite tables/migrations;
- a new mechanics truth/store;
- Public-d20 schema/RNG redesign;
- hardcoded `SUCCESS/FAILURE -> world effect` mappings;
- extra semantic replay/gating;
- G5-04/G5-03/Knowledge changes;
- UI work;
- MW-005 Primer/source/consumer modifications.

Production diff is zero, which is the preferred result when existing architecture is already coherent.

### F06 — Evidence / regression matrix — PASS

Implementer evidence reports green focused/regression runs for:

- MW-007 focused matrix (35 assertions);
- MW-006 mechanics-grounding vertical;
- G5-01 semantic materialization;
- G5-01 timeline Restore;
- Public d20 retry/no-reroll;
- NO_CHECK idempotence;
- `git diff --check`.

Real Provider calls = 0. Windows export validation was correctly omitted because there was no production GDScript change.

## Engineering closeout

```text
MW-007 Revision 1 / IR#1
= ENGINEERING PASS / CLOSED
```

G5-05 now has engineering evidence for both:

```text
MW-006
mechanics result -> normal semantic consequence

MW-007
that consequence -> Save/reopen/Continue/Restore timeline continuity
```

The remaining G5-05 decision is Product/Owner validation, not another speculative mechanics backend expansion unless actual play exposes a concrete defect.
