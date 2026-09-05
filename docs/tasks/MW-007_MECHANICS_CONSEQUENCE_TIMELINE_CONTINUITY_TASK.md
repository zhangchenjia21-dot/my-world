# TASK｜MW-007｜Mechanics Consequence Timeline Continuity

Type: implementation / integration hardening / validation  
Owner: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Capability-Anchor: **G5-05 Meaningful Choice / Mechanics Integration**  
Triggered-By: **MW-006 Engineering PASS / G5-05 completion audit**  
Depends-On: **MW-006 ENGINEERING PASS / CLOSED**  
Parallel-With: **MW-005 Revision 2 / Kimi**  
Revision: **1**  
Review-Round: **0**  
Formal Code Base before this packet-only commit: `my-world/main@957338df1572b86dbaa801ea412b3a8ab5666248`  
Governance Base: `Vibe-Coding/main@88bae78540d997a9fcacc393538ac0f58e382cf3`  
Task Branch target: `mw-007-mechanics-consequence-timeline-continuity`  
Status: **ACTIVE — ZCODE**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Prove the full G5-05 durability chain, using the real existing production seams rather than a synthetic in-memory runtime:

```text
CHECK_REQUIRED Player action
→ existing Program-owned durable Public d20 result
→ accepted free-form GM Narrative
→ existing MW-006 mechanics grounding in normal G5-01 semantic analysis
→ model-authored durable world consequence
→ Save / close / reopen / Continue remains coherent
→ Restore rewinds mechanics + Conversation + world consequence coherently
```

This Work Item exists to establish that an Expansion mechanic is not merely an isolated roll/UI fact: once the accepted Narrative establishes a real consequence and G5-01 materializes it, that consequence participates correctly in the same durable Timeline as the rest of the living world.

## 2. Primary product value

G5-05 exists so mechanics can matter to the living world without turning the Runtime into a hardcoded consequence engine.

```text
Program owns the mechanical result.
GM Narrative owns what the result meant in the scene.
G5-01 owns materialization of supported world consequences.
Timeline/Save/Restore owns durable historical consistency.
```

The task must not improve persistence by weakening Model Freedom, free-form Narrative, Player Agency, or the existing Public d20 authority split.

## 3. Authority / Source Manifest

Read current sources from latest `main` at task start. Authority order:

1. Owner current explicit instruction and current repository `AGENTS.md` chain.
2. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` — current stage/status.
3. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G5-05 / G5-GATE outcomes.
4. `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md` — accepted mechanics-grounding contract.
5. `docs/g5_01/G5-01_CLOSEOUT.md` + current G5-01 production/tests — accepted semantic/timeline behavior.
6. Current implementation code/tests at the task branch base.
7. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md` and lifecycle rules only as execution method, not product authority.

Archive, superseded docs, historical chat summaries and model memory are not authority unless a current source explicitly references them.

## 4. Read First

Initial working set; expand only when needed and record why:

1. `AGENTS.md`
2. `Vibe-Coding/AGENTS.md`
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` — G5-05 through G5-GATE
5. `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md`
6. `tests/mw006/机制锚定世界后果垂直测试.gd`
7. `tests/g5_01/世界回合时间线恢复测试.gd`

Then trace only the real production seams required for Public d20 execution, G5-01 semantic materialization, Save/Restore, current Game reopen, and continuation Context.

## 5. Two-pass audit before implementation

### Pass A — lifecycle / ownership trace

Trace actual production code and record the exact order and owners for:

- Public d20 action identity and CHECK_REQUIRED result persistence;
- final Narrative acceptance and acceptance marker;
- MW-006 accepted-check lookup and semantic request assembly;
- G5-01 world mutation / Timeline commit;
- named Save snapshot creation;
- close/reopen current Game reconstruction;
- Restore to an earlier Save;
- continuation Context projection of committed semantic consequences.

Do not infer that two records rewind together merely because they both live inside `world_state`; prove the actual snapshot/mutation/restore path.

### Pass B — failure / ghost-state audit

Specifically look for these possible inconsistencies:

```text
A. d20 record survives Restore while accepted Narrative/world consequence is gone
B. world consequence survives Restore while d20/Conversation is gone
C. close/reopen causes reroll or duplicate semantic materialization
D. later continuation sees restored-away consequence
E. later continuation loses a valid post-Save consequence
F. semantic materialization rewrites or duplicates Program-owned mechanics truth
```

If all are already prevented by existing architecture, do not add production code merely to make the task look substantive; add the smallest real integration proof and evidence.

## 6. Required state matrix

At minimum prove these two verticals through task-owned SQLite / production Runtime seams.

### V1 — post-consequence Save → close/reopen → Continue

```text
create/open task-owned Game with Public d20 capability
→ execute one CHECK_REQUIRED action through the production adjudication path
→ deterministic Program result becomes durable
→ final free-form Narrative is accepted
→ normal G5-01 semantic opportunity receives the MW-006 grounding
→ deterministic stub semantic response authors one identifiable world consequence
→ consequence commits through the existing world mutation/Timeline path
→ create Save AFTER the consequence
→ close Runtime
→ reopen existing Game
```

After reopen prove:

- accepted Conversation still contains the action/Narrative once;
- exact same durable d20 check remains; no reroll/new check identity;
- semantic consequence remains exactly once;
- no duplicate semantic request/mutation is produced merely by reopen;
- next ordinary GM continuation Context contains the committed consequence through the normal World Turn context seam;
- continuation does not require or create a second mechanics truth.

### V2 — pre-action Save → action/consequence → Restore pre-action Save

```text
create Save BEFORE the mechanics action
→ execute CHECK_REQUIRED action + accepted Narrative + semantic consequence
→ verify all three exist
→ Restore the pre-action Save
```

After Restore prove coherent rewind:

- restored Conversation no longer contains the later action/Narrative;
- restored world semantic consequence is absent;
- restored Public d20 action/check record created after that Save is absent if current Timeline semantics say world-state snapshots own it;
- no ghost mechanics grounding can be matched for the restored-away turn;
- subsequent continuation Context contains neither the restored-away consequence nor stale semantic memory;
- replaying a new action after Restore follows existing identity/RNG rules and does not silently reuse restored-away future truth.

If the current canonical persistence contract proves that Public d20 records intentionally have different Restore ownership than World State, STOP and return the exact current contract evidence before changing anything. Do not invent a new Restore policy inside this task.

## 7. Invariants

`INV-01` Existing Public d20 durable resolution remains the single mechanics truth.

`INV-02` No `SUCCESS/FAILURE → fixed world effect` mapping may be introduced.

`INV-03` Accepted free-form Narrative remains independent from semantic-analysis success.

`INV-04` G5-01 remains the only normal durable semantic-consequence mutation seam.

`INV-05` Save/Restore must restore a coherent historical snapshot; no future mechanics or semantic consequence may leak backward through Context.

`INV-06` Restore/reopen must never reroll an already-authoritative check or duplicate an already-materialized consequence.

`INV-07` `NO_CHECK` remains free of fake roll/mechanics grounding.

`INV-08` MW-005 literary style reference remains expression-only and must not become mechanics authority. Kimi owns the active Revision-2 consumer correction.

`INV-PRODUCT-01` Do not sacrifice Model Freedom / Visible Narrative / Player ownership of meaningful protagonist choices in order to make persistence easier to test.

## 8. Scope

Allowed:

- new focused test(s) under `tests/mw007/`;
- task evidence under `docs/mw007/`;
- the smallest production fix in existing Public d20 / World Turn / Runtime / persistence ownership seams **only if the state matrix exposes a real defect and the fix is already implied by current canonical semantics**;
- directly required test fixtures/stubs.

Preferred outcome if architecture is already correct:

```text
production diff = 0
focused integration proof + evidence = substantive deliverable
```

Prohibited:

- new SQLite tables or migrations;
- Public d20 proposal/schema/RNG redesign;
- new action identity protocol;
- extra semantic replay opportunities;
- hardcoded consequence tables;
- new generic Timeline/persistence framework;
- G5-04 scheduler/evaluator changes;
- G5-03 Agency changes;
- Knowledge shortcut changes;
- Source schema/current reads;
- MW-005 Primer/source bytes or its Revision-2 implementation;
- UI work;
- G5-06 implementation;
- fixing unrelated stale regressions such as the known G3-04 `Current Game Context` assertion.

## 9. Parallel-work collision rule

Kimi is concurrently implementing MW-005 Revision 2.

Before editing production code, inspect current `main` and likely collision files. If the required fix would modify a file currently being changed by MW-005 Revision 2—especially the shared Game-local projector or Public d20 request assembly—prefer to keep MW-007 test-only if possible. If a production correction genuinely requires an overlapping file, STOP and report the collision instead of independently resolving semantic conflicts.

At final handoff, fetch latest `main`, reconcile/rebase non-destructively, and rerun the focused matrix. Never drop Kimi's merged correction.

## 10. Engineering Acceptance

Engineering PASS requires actual evidence for all of the following:

1. V1 post-consequence Save/reopen continuity passes through production SQLite/runtime seams.
2. V2 pre-action Restore removes all restored-away future truth according to current canonical ownership.
3. no reroll and no duplicate semantic mutation across reopen/Restore.
4. later continuation Context contains the valid committed consequence and excludes restored-away future consequence.
5. mechanics truth is unchanged by semantic materialization; no second store/summary becomes authority.
6. MW-006 focused regression remains green.
7. G5-01 semantic materialization + timeline Restore regression remains green.
8. directly affected Public d20 retry/no-reroll coverage remains green.
9. MW-005 Revision-2 files are not modified by this task unless GPT/Owner separately authorizes it.
10. SQLite schema/table/migration diff is empty.
11. `git diff --check` clean.
12. Windows export validation passes if any production GDScript changes are made.
13. Real Provider calls = 0 by default.

A failing matrix is not permission to broaden architecture. Apply the Stop Conditions below.

## 11. Product Value Acceptance

Automated tests cannot prove the mechanic feels meaningful in play.

After Engineering PASS, Owner UAT remains responsible for checking a real game path such as:

```text
meaningful risky action
→ visible Public d20 result
→ natural GM consequence
→ later world still behaves consistently with that consequence
→ Save/reopen still remembers it
```

Owner should also verify that NO_CHECK remains natural and that mechanics do not dominate every action.

Zcode must not claim `PRODUCT PASS`, `G5-05 CLOSED`, or `G5-GATE PASS`.

## 12. Stop Conditions

STOP and return a blocker rather than redesigning if any required correction needs:

- SQLite schema/table migration;
- a new mechanics truth/store;
- a new Public d20 protocol or RNG contract;
- a new Timeline/branch identity architecture;
- resetting/cancelling the previously deferred G5-01 exact byte-identical replay edge without a concrete reproduction from this task;
- extra semantic replay/gating;
- cross-task changes to MW-005 Revision 2;
- a generic persistence/context/mechanics platform.

## 13. Validation / evidence

Use deterministic stubs and task-owned filesystem/SQLite roots. Prefer actual production L3 interfaces and Runtime over synthetic in-memory substitutes.

At minimum run:

- new `tests/mw007/...` focused matrix;
- `tests/mw006/机制锚定世界后果垂直测试.gd`;
- `tests/g5_01/世界回合语义物化测试.gd`;
- `tests/g5_01/世界回合时间线恢复测试.gd`;
- directly affected Public d20 focused retry/no-reroll tests discovered in Pass A;
- `git diff --check`;
- Windows export validation only if production GDScript changed.

Record any pre-existing failure separately with proof from the task base; do not silently repair unrelated behavior.

## 14. Git / return contract

- Start from fresh latest `main`; record actual base SHA and `git status`.
- Create/use branch `mw-007-mechanics-consequence-timeline-continuity` or an equivalent task-specific branch.
- Do not overwrite unknown dirty work.
- Before final push, fetch current `main`; reconcile non-destructively and rerun focused validation.
- Push the task branch and exact commits.

Return:

- implementation SHA (or explicit `production code unchanged` + test/evidence SHA);
- evidence SHA;
- remote branch;
- actual base/final head;
- changed files;
- Pass A lifecycle trace;
- Pass B ghost-state audit;
- V1 proof;
- V2 proof;
- no-reroll / no-duplicate proof;
- continuation-context proof;
- schema unchanged proof;
- regression commands/results;
- export result if applicable;
- real Provider call count;
- Kimi/MW-005 collision/rebase status;
- remaining risks.

Return ceiling:

`READY FOR INDEPENDENT REVIEW`

Only GPT performs Independent Review; only Owner can issue Product/UAT verdicts.
