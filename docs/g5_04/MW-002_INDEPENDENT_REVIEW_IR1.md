# MW-002 Independent Review IR#1

Status: **CORRECTION REQUIRED**  
Work Item: **MW-002 — Selective World Evolution Evaluator**  
Capability Anchor: **G5-04**  
Reviewed Revision: **1**  
Review Round: **IR#1**  
Reviewer: GPT  
Date: 2026-09-04

## 1. Freshness / reviewed range

Authoritative heads refreshed before review:

- `my-world/main`: `d42477c45d4699c91ec0e40124ced374101135b9`
- `Vibe-Coding/main`: `ed768d0e0ad912ff9e8f1bcdb439ad3b767b08c1`

Formal MW-002 code base was `0d06365ce25af45a61602227ba5208d7a0fe3cfe`.

Reviewed implementation/evidence commits:

- implementation: `97a874377bc7b25a8e9b7b7b1c2439928ba3429e`
- evidence: `d42477c45d4699c91ec0e40124ced374101135b9`

Actual compare is 2 commits / 10 changed files. Scope is broadly consistent with the packet: evaluator/rules/parser/context, minimal Scheduler/Shell/projector seams, focused tests, evidence. No UI, SQLite schema/table/migration, Faction platform, Public-d20 protocol redesign, pressure queue or G5-05 implementation was introduced.

## 2. What is already correct and must be preserved

Revision 1 establishes substantial correct behavior:

- dedicated World Evolution request after Agency terminal;
- `hold` as a valid first-class result with no fake mutation;
- one-event-per-opportunity safety ceiling;
- raw bounded parser contract with no model-owned IDs/priority/taxonomy authority;
- deterministic Program-owned evolution/mutation/node identities bound to Game + opportunity turn/hash + base head;
- additive `living_world.v0.1` durable event collection; no SQLite schema change;
- committed-event replay idempotence;
- exact accepted-hash currentness for GM Context;
- `## World Evolution Events` as the first real next-GM consumer with explicit no-auto-Player/no-auto-actor-knowledge guidance;
- no Actor Knowledge Provenance in evaluator causal input;
- no mutable Source Library lookup;
- no automatic Knowledge materialization from a world event.

These semantics are not reopened by this review.

## 3. Blocking findings

### F01 — Public-d20 foreground start does not immediately invalidate background evolution

**Severity: BLOCKER**  
**Violates: INV-10 Foreground wins**

The Shell invalidates Agency and World Evolution from `Conversation.attempt_started`.

That is sufficient for the ordinary Narrative path, where the View calls `conversation.begin_turn(text)` before sending the request.

It is not sufficient when the materialized Public-d20 action path is active:

```text
player presses Send
→ Narrative View routes to action_adjudication.start_action(...)
→ Public-d20 control Provider request starts
→ Conversation turn has NOT started yet
→ Conversation.attempt_started has not fired
→ old World Evolution request can still complete and commit
```

Inspection of `公开D20行动判定流程.gd` confirms that a fresh action first starts the `control` Provider stage. `conversation.begin_turn(_player_text)` is deferred until `_ensure_narrative_attempt()`, which is used only when a later narrative stage begins.

Therefore there is a real foreground-authority window in which the Player has already begun a new action but `_opportunity_still_current()` can still see `conversation.is_generating() == false`, unchanged accepted count and unchanged head, allowing an obsolete background event to commit.

**Required correction:** use the smallest existing action-start observability seam in Application composition (prefer the already-existing `action_adjudication.request_assembled` signal) to invoke the same foreground invalidation for Agency + World Evolution as soon as the foreground adjudication request starts. Do not redesign Public d20 mechanics/protocol/UI.

**Required focused proof:** active World Evolution → Player starts a Public-d20 action/control stage → background evolution is invalidated before control completion → simulated late evolution callback cannot commit.

Because Revision 2 now touches a concrete Public-d20 integration boundary, run one minimal directly affected G4-08/Public-d20 regression.

---

### F02 — Agency `already_committed` immediate terminal is not surfaced; Scheduler can strand

**Severity: BLOCKER**  
**Violates: INV-11 terminal observability**

Canonical MW-002 explicitly requires `opportunity_finished` for an equivalent immediate terminal such as **all selected actions already committed**.

`AgencyCycleRuntimeProcess.start_cycle()` can return:

```text
status = already_committed
actor_count = 0
```

when the matching durable cycle already contains actions for every selected actor.

But `AgencySchedulerProcess._on_selector_completed()` always stores the newly-created `agency_cycle_runtime` and then assumes a later `cycle_finished` signal will arrive. The `already_committed` branch starts no actor request and emits no `cycle_finished`.

Consequences:

- no `opportunity_finished`;
- MW-002 never wakes for that completed opportunity;
- `agency_cycle_runtime` remains non-null;
- later Scheduler opportunities can be stranded by the stale runtime reference.

**Required correction:** Scheduler must recognize the immediate terminal return, safely detach/free the cycle runtime, emit exactly one terminal `opportunity_finished` carrying the frozen opportunity turn/hash, and remain re-armed for later new dirty opportunities. Do not change dirty consumption, selector semantics, 0..4 cap, concurrency or retry policy.

**Required focused proof:** pre-seed a matching Agency Cycle with all selected actor actions durable → selector chooses those actors → no actor request is sent → immediate terminal cleans the runtime → exactly one `opportunity_finished` → World Evolution wakes exactly once → a later new dirty opportunity can proceed.

---

### F03 — `project_world_only()` leaks non-World Game setup into evaluator baseline

**Severity: BLOCKER**  
**Violates: INV-12 World-only causal input boundary**

The canonical input is a frozen **Game-local T0 World projection only**:

- World / selected Entry;
- world instructions / GM instructions;
- World semantic sections.

Current `project_world_only()` reuses `_append_game(...)` before `_append_world(...)`.

`_append_game(...)` includes:

- Game display name;
- protagonist control mode;
- selected Entry;
- **opening supplement**.

`opening_supplement` is an arbitrary player-authored TextEdit field in New Game setup. It is not guaranteed to be world-level causal truth and may contain protagonist/private opening information. Current focused privacy fixtures set it to empty, so the leak is not tested.

**Required correction:** the world-only projector must use a dedicated minimal world-baseline header and must not reuse the general Game setup block. Exclude protagonist control mode and arbitrary opening supplement, and continue excluding all Player/Character material. Keep the exact selected Entry and frozen World material.

**Required focused proof:** set `opening_supplement` to a unique private marker and verify it is absent from the evaluator request while World/Entry markers remain present.

---

## 4. Required evidence correction

### F04 — Required active-evaluation → production Restore → late-callback proof is missing

**Severity: EVIDENCE BLOCKER**  
**Applies to: focused proof #11 / INV-10**

Revision 1 focused tests prove:

- active evaluation invalidated by a manually-started foreground Conversation;
- unrelated world-head change produces `stale_evaluation`;
- normal Save/Restore behavior after an evolution event has already committed.

They do **not** prove the required active path:

```text
World Evolution request active
→ production Restore/progress switch
→ evaluator invalidated
→ late callback arrives
→ restored head/world remain authoritative
→ no evolution event commits
```

The production Shell wiring appears intended to do this via `_on_restore_completed`, but the task requires an actual focused production proof and the evidence currently overstates coverage.

**Required correction:** add the production Restore-active test above. Prefer also proving that any synchronous Agency invalidation terminal caused by Restore cannot leave a surviving evolution request or commit after the progress switch.

No architecture change is required for F04 unless the test exposes one.

## 5. Non-blocking observation folded into F03

The current `project_world_only()` also includes control mode. This is not the same privacy severity as arbitrary `opening_supplement`, but it is outside the frozen World-only input contract and should be removed by the same narrow correction.

## 6. Validation / reviewer execution limitation

Kimi's committed evidence reports:

- G5-04 focused: **112 PASS / 0 FAIL**;
- directly affected G5-01/G5-02/G5-03/G4-07A regressions green;
- G3-04 PASS;
- `git diff --check` clean;
- real Provider calls = 0.

GPT independently inspected the actual committed diff, production seams, focused test source and evidence. The reviewer environment did **not** have a Godot executable, and the reviewed final commit had no external CI statuses, so GPT could not independently rerun the Godot commands. This limitation does not negate the code-level blockers above.

## 7. Revision 2 scope

Keep the same Work Item:

```text
Work Item: MW-002
Revision: 2
Review-Round: 1
Triggered-By: MW-002 IR#1
Correction Base: d42477c45d4699c91ec0e40124ced374101135b9
```

Revision 2 is narrowly limited to F01–F04. Preferred production edit surfaces:

- `src/应用壳.gd` — earliest existing Public-d20 foreground observability → common invalidation;
- `src/世界回合/L2_流程层/行动代理调度流程.gd` — `already_committed` immediate terminal handling;
- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd` — true World-only projection;
- `tests/g5_04/选择性世界演化评估测试.gd`;
- evidence update.

Read `src/ui/叙事对话视图.gd`, `src/行动判定/L2_流程层/公开D20行动判定流程.gd`, and `src/世界回合/L2_流程层/行动代理循环流程.gd` only to verify existing seams. Prefer no edits there unless concrete evidence proves the existing observability is insufficient.

Do not reopen the evaluator identity/record/parser/context architecture. Do not add UI, SQLite changes, Faction platform, pressure/priority infrastructure, random event machinery, offline evolution or G5-05 work.

Revision 2 validation after focused green:

- G5-04 focused;
- one directly relevant G5-03 Scheduler/Cycle regression;
- one minimal G4-08/Public-d20 regression because F01 now crosses that real seam;
- one G4-07 continuation/context regression if the world-only projector/context path is touched;
- one G3-04 Save/Restore regression;
- `git diff --check`;
- real Provider calls = 0.

## 8. Verdict

**MW-002 Revision 1 — CORRECTION REQUIRED.**

G5-04 remains ACTIVE. Owner UAT is **not yet unblocked**. After Kimi returns Revision 2 as `READY FOR INDEPENDENT REVIEW`, GPT performs IR#2 on the actual correction diff before any Product UAT handoff.