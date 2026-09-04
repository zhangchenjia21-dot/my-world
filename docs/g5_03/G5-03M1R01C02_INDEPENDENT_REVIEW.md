# G5-03M1R01C02 Independent Review

Status: **C02 PASS / PARENT R01 STILL BLOCKED BY WAKE-ORDER DEFECT**  
Reviewed implementation: `2c243815b8e42d510160944333abc57a313f2454`  
Evidence backfill: `17222d0b49f7757347c52d8122596b6d5c182271`

## What C02 fixed correctly

- selector start consumes the current dirty opportunity (`dirty=false`);
- cycle terminal no longer re-considers the same opportunity;
- malformed/provider-failure/no-actors paths consume the opportunity;
- later newly accepted turn may create a fresh opportunity;
- selector adapter lifecycle tests no longer read freed nodes;
- selection-bound test now uses distinct eligible actors + actor stub factory;
- real Application Shell wiring is exercised instead of a direct test-side `mark_dirty()` shortcut.

C02 itself is accepted.

## New material finding exposed by the real production proof

The real Application path currently starts Agency **before the current turn semantic worker has had a chance to enqueue analysis**.

Production ordering is:

```text
_activate_game_surface()
→ _connect_save_runtime()
   generation_completed → _on_ordinary_turn_accepted_for_agency
→ _prepare_world_turn_after_activation()
   WorldTurn constructor later connects its own generation_completed callback
```

Then on ordinary completion:

```text
generation_completed
→ Application callback runs first
→ mark_dirty()
→ consider_agency()
→ WorldTurn still reports busy=false / queued=0
→ selector starts
→ only afterwards WorldTurn receives generation_completed and queues semantic analysis
```

This violates the frozen v0.3 safe-start rule:

```text
accepted ordinary turn
→ semantic lane settles
→ selector evaluates latest current world snapshot
```

Concrete consequence:

- selector prompt can miss current-turn semantic consequences;
- if semantic materialization commits while selector is active, world head changes and the selector may later become stale;
- the production wiring proof currently passes precisely because it never completes the semantic stub before observing one selector request.

## Disposition

Do **not** issue C03. The scheduler lifecycle seam has already consumed correction-01 and correction-02.

Per correction budget, use a minimal wake-ownership redesign:

`G5-03M1R02 Semantic-Terminal Wake Ownership Simplification`

No canonical product semantics change is required. This restores the already-frozen v0.3 lifecycle.

## Required implementation shape

Normal production path should be:

```text
generation_completed ordinary turn
→ mark_dirty() only
→ WorldTurn queues/runs semantic analysis
→ WorldTurn terminal finished
→ _on_world_turn_finished_for_scheduler()
→ consider_agency()
→ selector starts over post-semantic current world/head
```

Opening remains non-dirty. Foreground/Restore cancellation, dirty consumption, multi-actor execution and all other accepted behavior remain unchanged.
