# TASK｜G5-03M1R01C01｜Scheduler Production Lifecycle + Current Snapshot

Type: **focused correction-01 / scheduler lifecycle seam**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-03M1R01 Agency Scheduler v0.3 Simplification Redesign**  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`  
Independent Review: `docs/g5_03/G5-03M1R01_INDEPENDENT_REVIEW.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## 0. Scope

Do not redesign v0.3. Preserve the accepted architecture:

```text
semantic lane = changes + knowledge only
→ standalone Agency Scheduler/Selector
→ validated 0..4 stable actors
→ existing concurrent actor-scoped Agency Cycle
```

This correction closes only production Scheduler lifecycle/current-snapshot defects found in Independent Review.

No real Provider call in this correction.

## 1. Required fix A — production dirty wiring

A newly durably accepted **ordinary player turn** must mark the active Agency Scheduler dirty.

Requirements:

- do not rely on tests/manual `mark_dirty()`;
- hook the durable accepted ordinary-turn lifecycle in production Application/Runtime wiring;
- do not mark Opening-only GM generation as an ordinary Agency opportunity;
- marking dirty must not block Narrative or become a Turn Finalize Barrier;
- rapid A/B/C accepted turns may coalesce into one dirty condition;
- semantic worker terminal remains only a safe scheduling wake-up.

Expected normal path:

```text
ordinary turn durable accepted
→ scheduler.dirty = true
→ semantic worker drains active/queued work
→ terminal wake-up calls consider_agency()
→ one selector evaluates latest current snapshot
```

## 2. Required fix B — cycle terminal cleanup and re-arm

Scheduler owns the `AgencyCycleRuntimeProcess` child lifecycle.

When the current cycle emits `cycle_finished` for normal completion or invalidation:

- detach/free that exact completed cycle safely;
- clear `agency_cycle_runtime` only if it still refers to that cycle;
- preserve already committed durable actor actions;
- late callbacks from an obsolete cycle cannot clear/modify a newer cycle;
- Scheduler must then be capable of handling a later newly accepted dirty world state.

Do not auto-run another selector immediately merely because a cycle ended unless a newer dirty opportunity already exists and the normal safe-start conditions are satisfied. No retry loop.

## 3. Required fix C — selector reads only current world consequences

`Recent World Changes` supplied to the standalone selector must contain only durable semantic records whose:

- `source_turn_index` exists in current durable accepted Conversation; and
- `source_gm_sha256` matches the current accepted GM hash for that turn.

Reuse existing current-hash/truth projection principles where possible. Do not invent a parallel weaker truth definition.

A stale physically retained semantic record from a regenerated/corrected Narrative must not influence actor selection.

Keep selector GM-level visibility; this correction is about **current truth**, not actor-private visibility.

## 4. Lifecycle hygiene

While touching Scheduler lifecycle, keep terminal handling coherent:

- selector completion/failure/cancellation must not strand Scheduler in an active state;
- completed obsolete selector adapter/cycle children should not accumulate indefinitely;
- foreground attempt / Restore / Recovery / close still invalidates active work and clears obsolete dirty state;
- after a failed/no-actors selector opportunity, a **later newly accepted turn** can mark dirty and schedule again;
- do not add automatic retry for the same failed/no-actors opportunity.

Do not broaden this into generic process management refactoring.

## 5. Required deterministic proofs

Add/adjust tests to prove at least:

### A. Production dirty wiring

Using the real Application/production lifecycle seam (or the closest existing integration seam), prove:

```text
ordinary player Narrative durable accepted
→ Scheduler becomes dirty without direct test call to mark_dirty()
→ semantic work settles
→ exactly one selector starts
```

Opening must not create this ordinary-turn Agency opportunity.

### B. Two sequential Agency opportunities

```text
Turn A accepted
→ selector/cycle A completes terminally
→ scheduler cycle reference cleaned
→ later Turn B accepted
→ selector/cycle B can start
```

Prove the system is not permanently one-cycle-only.

Also cover a first cycle where selected actors all hold/fail if practical; terminal cleanup must still re-arm future Agency.

### C. Stale semantic world-change filtering

Create:

- one current hash-matching semantic consequence;
- one physically present hash-mismatching stale semantic consequence.

Expected selector request:

- contains current consequence;
- excludes stale consequence.

### D. No automatic retry loop

Malformed/provider-failed/no-actors selector consumes that opportunity without an immediate retry loop. A later accepted ordinary turn may mark dirty and schedule a fresh selector.

### E. Preserve prior R01 behavior

Re-run all affected G5-03 proofs, especially:

- semantic/Agency decoupling;
- A/B/C coalescing;
- stale selector on foreground/Restore/head change;
- multi-actor concurrent execution;
- sibling head progression;
- actor-private knowledge/history;
- replay no duplicate.

## 6. Regression floor

At minimum:

- full G5-03 focused suite;
- affected Application integration suite;
- G5-02 knowledge suite;
- G5-01 semantic + timeline suites;
- affected G2 Conversation/Context;
- affected G3 Save/Restore;
- affected G4 continuation/Application;
- Public d20 regression because Application wiring is touched;
- `git diff --check`.

## 7. Real Provider

**DO NOT CALL A REAL PROVIDER.**

This is deterministic production wiring/lifecycle correction. Parent real feature proof remains pending honestly.

## 8. Evidence

Create:

`docs/g5_03/G5-03M1R01C01_SCHEDULER_PRODUCTION_LIFECYCLE_CURRENT_SNAPSHOT_EVIDENCE.md`

Record:

- START_HEAD / FINAL_HEAD;
- exact changed paths;
- production dirty wiring proof;
- sequential Cycle A → Cycle B re-arm proof;
- stale semantic consequence filtering proof;
- no-auto-retry proof;
- prior R01/C01 regression results;
- `git diff --check`;
- explicit zero real Provider calls.

## 9. Completion

Commit/push `origin/main`, then return:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not start G5-03M2 or G5-04.
