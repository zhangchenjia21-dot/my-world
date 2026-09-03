# G5-03M1R01 — Agency Scheduler v0.3 Independent Review

Status: **CORRECTION REQUIRED / NOT ENGINEERING PASS YET**  
Reviewer: GPT  
Reviewed implementation: `46f8bd34875a55de7c26a1b9ebc5f11312a9f582`  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## 1. Review conclusion

The v0.3 redesign direction is accepted:

```text
semantic changes + knowledge only
→ standalone Agency Scheduler/Selector
→ 0..4 stable actors
→ existing isolated concurrent actor executions
```

The redesign successfully removes the problematic v0.2 semantic-selection coupling and preserves the downstream multi-actor execution contract.

However, production Scheduler lifecycle/current-snapshot wiring has three material defects. R01 is therefore not Engineering PASS yet.

## 2. Finding A — production never marks Agency dirty

Severity: **BLOCKER**

Production `AgencySchedulerProcess.mark_dirty()` is implemented, and `consider_agency()` correctly requires `dirty == true`.

But Application production wiring never calls `agency_scheduler.mark_dirty()` after an ordinary player turn becomes durably accepted. `_on_world_turn_finished_for_scheduler()` only calls `consider_agency()`.

Because Scheduler starts with `dirty = false`, normal product flow is:

```text
ordinary Narrative accepted
→ semantic worker runs/finishes
→ Application calls scheduler.consider_agency()
→ dirty == false
→ status=not_ready
→ no selector ever starts
```

Focused tests manually call `scheduler.mark_dirty()`, so they prove the process in isolation but not production wake/dirty wiring.

Required correction: connect the durable ordinary-turn acceptance lifecycle to `mark_dirty()` without making Agency a foreground gate. Opening must remain skipped according to v0.3 scope.

## 3. Finding B — completed Agency Cycle permanently blocks future cycles

Severity: **BLOCKER**

`AgencySchedulerProcess.consider_agency()` refuses to start while `agency_cycle_runtime != null`.

When selector starts a cycle, Scheduler assigns a new `AgencyCycleRuntimeProcess`, but never connects to `cycle_finished` to dispose/reset that child after normal completion, hold/failure completion, or invalidation.

`AgencyCycleRuntimeProcess` emits `cycle_finished`, sets `cycle_closed`, and remains alive; it does not self-free.

Therefore after the first actual cycle:

```text
agency_cycle_runtime != null forever
→ later accepted turn marks dirty
→ consider_agency()
→ not_ready forever
```

Required correction: Scheduler owns cycle terminal cleanup. On `cycle_finished`, safely detach/free the completed cycle and set `agency_cycle_runtime = null`. Already committed actions remain durable. Cleanup must tolerate foreground/Restore/shutdown and late callbacks.

## 4. Finding C — selector can read stale semantic consequences

Severity: **HIGH**

The standalone selector builds `Recent World Changes` by iterating every structurally valid `semantic_turns_by_index` record. It does not check whether each record's `source_gm_sha256` still matches the current durable accepted Conversation at that turn index.

Concrete failure:

```text
Turn N old Narrative establishes fact F
→ F materialized
→ player regenerates/corrects Turn N
→ new Narrative no longer establishes F
→ old semantic record may remain physically present but hash-mismatching
→ normal GM Context correctly excludes F
→ Agency Selector still includes F in Recent World Changes
→ selector may choose actors based on erased timeline truth
```

This violates the v0.3 requirement that selector evaluates the **current latest world snapshot**.

Required correction: selector world-change projection must use the same current accepted-hash principle as current GM Context / actor-memory filtering. Do not create a second truth definition.

## 5. Passing behavior to preserve

Do not redesign or regress:

- semantic lane contains only `changes + knowledge_events`;
- older unchanged accepted semantic truth may materialize after foreground advances;
- standalone selector is allowed GM-level visibility;
- selector output validates stable Guaranteed NPC IDs, dedupes and caps 4;
- per-actor execution remains isolated/private;
- selected actor requests may run concurrently;
- sibling durable commits remain serialized with cycle-owned expected-head progression;
- foreground/Restore cancellation remains fail-soft;
- replay no-duplicate behavior;
- no SQLite/UI/Faction/G5-04 scope.

## 6. Test gaps to close

The correction must add production-relevant deterministic proofs for:

1. ordinary durable accepted player turn actually marks the production Scheduler dirty and, after semantic settlement, starts one selector without a manual `mark_dirty()` test shortcut;
2. after Cycle 1 reaches terminal completion, Cycle 2 from a later accepted world state can start normally;
3. stale hash-mismatching semantic consequences are excluded from selector input while current matching consequences remain visible;
4. selector failure/no-actors/actor hold or provider failure still leaves Scheduler capable of handling a later newly accepted turn;
5. existing coalescing, foreground, Restore, concurrency, replay and actor-knowledge tests remain green.

## 7. Provider status

No additional real Provider call is required for this correction. The existing real feature proof remains honestly pending/unavailable. Use deterministic/stubbed lifecycle tests.

## 8. Result

```text
G5-03M1R01 Agency Scheduler v0.3
CORRECTION REQUIRED

Next:
G5-03M1R01C01 Scheduler Production Lifecycle + Current Snapshot
```
