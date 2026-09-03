# G5-03M1R01C01 — Independent Review

Status: **CORRECTION REQUIRED**  
Reviewer: **GPT**  
Reviewed implementation HEAD: `9da292966e5a56bbbea7ca5aedb20919d5ebb092`  
Parent: `G5-03M1R01 Agency Scheduler v0.3`

## Result

C01 correctly added production dirty wiring, cycle terminal cleanup, selector current-hash consequence filtering, and selector child cleanup. The v0.3 architecture remains accepted.

One blocking scheduler-state defect remains in the same lifecycle seam.

## Blocking finding — dirty opportunity is never consumed

Production `AgencySchedulerProcess.mark_dirty()` sets `dirty = true`, but `_start_selector()` never consumes/clears that dirty opportunity.

At cycle terminal, `_on_agency_cycle_finished()` currently does:

```text
if dirty and not selector_active:
    consider_agency()
```

Because `dirty` is still true from the same accepted player turn, a normal completed Agency Cycle immediately starts another selector over the same world opportunity.

Concrete failure:

```text
Turn A accepted
→ dirty=true
→ selector A
→ actor(s) act / cycle A completes
→ dirty is still true
→ cycle_finished immediately calls consider_agency()
→ selector A2 starts without a newer accepted turn
→ possible repeated Agency cycles for the same player-world opportunity
```

This violates the frozen v0.3 rule that malformed/provider-failed/no-actors/completed Agency consumes that opportunity and does not auto-retry; only a later newly accepted player turn should create a new dirty opportunity.

## Test gap

`_test_r01c01_no_auto_retry()` currently asserts that dirty remains true and that a second manual `consider_agency()` starts another selector. That proves the opposite of the packet requirement.

`_test_r01c01_production_dirty_wiring()` also still calls `scheduler.mark_dirty()` directly, so it does not prove the production Application signal path required by the C01 packet.

The sequential-cycle test does not assert that no selector starts between Cycle A terminal and later Turn B acceptance.

## Review decision

```text
G5-03M1R01C01  CORRECTION REQUIRED
G5-03M1R01C02  ACTIVE — KIMI
```

This is correction-02 on the scheduler lifecycle seam, not another architecture redesign. Preserve v0.3 semantic/Agency decoupling and all passing multi-actor behavior.

No real Provider call is required for C02.
