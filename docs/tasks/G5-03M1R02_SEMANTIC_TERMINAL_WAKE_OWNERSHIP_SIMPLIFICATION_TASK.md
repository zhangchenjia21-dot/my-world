# TASK｜G5-03M1R02｜Semantic-Terminal Wake Ownership Simplification

Type: **redesign-02 / scheduler wake-ownership simplification**  
Owner: **KIMI**  
Reviewer: **GPT**  
Parent: **G5-03M1R01 Agency Scheduler v0.3**  
Review: `docs/g5_03/G5-03M1R01C02_INDEPENDENT_REVIEW.md`  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## Goal

Restore the already-frozen v0.3 lifecycle with the smallest possible change:

```text
ordinary generation completed
→ mark Agency dirty only
→ semantic worker runs/settles
→ semantic terminal wake
→ consider_agency()
→ selector starts over post-semantic current world/head
```

Do not redesign Multi-Actor Agency, persistence, identity, selector format, actor execution, or semantic extraction.

## Production change

In `src/应用壳.gd::_on_ordinary_turn_accepted_for_agency(...)`:

- keep ordinary-vs-Opening guard;
- keep `agency_scheduler.mark_dirty()`;
- remove the immediate normal-path `agency_scheduler.consider_agency()`.

`_on_world_turn_finished_for_scheduler(...)` remains the normal scheduling wake-up and calls `consider_agency()` after semantic terminal.

No timer, polling, retry loop, extra Provider call, or new state variable.

## Required focused proofs

1. **Real Application ordering**

Use the existing real `main.tscn` Shell harness:

```text
ordinary durable accepted
→ dirty=true
→ semantic stub request becomes active
→ selector request count == 0 while semantic is active
```

Then complete semantic stub (valid no-change is sufficient):

```text
semantic finished
→ selector request count == 1
→ dirty consumed to false
```

No direct test-side `mark_dirty()` for this proof.

2. **Post-semantic snapshot**

Use one semantic result that creates a durable current world change. Prove selector starts only after that materialization and its request includes that current consequence / post-semantic head anchor.

3. **Semantic terminal fail-soft wake**

At least one terminal no-change/malformed/provider-failure semantic result must still release the scheduler to evaluate Agency once the semantic worker is idle. Narrative remains accepted; no retry loop.

4. Preserve C02:

- one dirty opportunity → one selector;
- no selector A2 after terminal;
- later Turn B creates fresh opportunity;
- Opening does not dirty.

## Validation — intentionally narrow

Do **not** rerun the whole historical matrix while iterating.

Iteration order:

1. G5-03 focused suite only until green.
2. Then one final affected regression pass:
   - G5-01 semantic materialization;
   - G4-01 Application lifecycle integration;
   - G4-07B playable Application integration;
   - Public d20 Application regression only because shared Shell wiring is touched;
   - `git diff --check`.

Do not rerun unrelated G2/G3/G5-02 full suites unless a focused failure gives a concrete reason.

## Evidence

Keep evidence compact:

- START_HEAD / FINAL_HEAD;
- changed production/test paths;
- real ordering proof;
- post-semantic snapshot proof;
- terminal fail-soft proof;
- final focused/regression results;
- `git diff --check`;
- real Provider calls = 0.

## Provider

**ZERO real Provider calls.**

## Completion

Commit/push and return:

`READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING`

Do not start G5-03M2 or G5-04.