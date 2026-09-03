# TASK｜G5-03M1R01C02｜Dirty Opportunity Consumption + Lifecycle Proof

Type: **focused correction-02 / scheduler lifecycle seam**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-03M1R01 Agency Scheduler v0.3**  
Prerequisite: `docs/g5_03/G5-03M1R01C01_INDEPENDENT_REVIEW.md`  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## 0. Scope

Do not redesign v0.3. Do not re-couple Agency Selection into semantic analysis.

Preserve all passing C01 work:

- production ordinary-turn dirty wiring;
- selector current-hash consequence filtering;
- selector adapter cleanup;
- cycle child cleanup;
- multi-actor concurrent actor execution;
- actor-private Knowledge/History;
- sibling durable commit/head progression;
- foreground/Restore invalidation;
- replay no duplicate.

No real Provider calls in this correction.

## 1. Required fix — consume one dirty opportunity exactly once

`dirty` represents one pending current-world Agency evaluation opportunity.

When a selector actually starts for that opportunity, consume it before/at selector start:

```text
dirty=true
→ safe selector start
→ dirty=false for the consumed opportunity
```

Then all terminal outcomes consume that same opportunity:

- malformed selector;
- provider failure / synchronous start failure;
- no actors;
- actor hold/failure;
- normal cycle completion.

None may automatically recreate/retry the same opportunity.

Only a **later newly durable accepted ordinary player turn** may call `mark_dirty()` and create a fresh opportunity.

Do not add a timer/polling retry loop.

## 2. Cycle terminal behavior

Cycle terminal cleanup must free/detach the exact completed cycle and clear Scheduler ownership safely.

Prefer an exact-cycle callback identity/binding so a stale callback cannot clear a newer cycle reference.

After normal Cycle A terminal, with no later accepted turn:

```text
scheduler.dirty == false
selector_active == false
agency_cycle_runtime == null
```

and no new selector starts by itself.

After later Turn B is durably accepted:

```text
mark_dirty()
→ normal safe start
→ selector/cycle B may run
```

## 3. Production dirty proof must use production seam

Replace the current focused proof that directly calls `scheduler.mark_dirty()` and labels it production.

Use the real Application signal/callback seam or closest repository-native integration harness to prove:

```text
ordinary generation completion / durable acceptance
→ _on_ordinary_turn_accepted_for_agency
→ Scheduler dirty
→ semantic settled wake-up
→ exactly one selector starts
```

Opening-only GM completion must not dirty Agency.

Do not count a test that invokes `mark_dirty()` directly as production-wiring proof.

## 4. Required deterministic proofs

At minimum:

### A. Completed cycle consumes opportunity

```text
Turn A accepted
→ selector A
→ actor act/hold
→ cycle A terminal
```

Expected:

- selector request count remains exactly 1 for Turn A;
- no selector A2 after one or more process frames;
- direct `consider_agency()` without a new accepted turn returns not-ready / does not start a selector.

### B. no-actors / malformed / provider-failure consume opportunity

For each practical terminal class, prove no immediate or manual re-consider retry for the same opportunity.

A later accepted Turn B must still be able to mark dirty and schedule again.

### C. Sequential A → B

Prove explicitly:

```text
Cycle A terminal
→ zero selector activity until Turn B acceptance
→ Turn B acceptance creates fresh dirty
→ selector/cycle B starts using B snapshot
```

### D. Production wiring

Prove ordinary accepted turn marks dirty through Application/production callback without direct `mark_dirty()` test shortcut; Opening does not.

### E. Preserve C01/R01

Re-run current-hash filtering, coalescing, foreground/Restore stale guards, multi-actor concurrency, actor knowledge isolation, sibling head progression and replay no duplicate.

## 5. Regression floor

Run at minimum:

- full G5-03 focused suite;
- affected Application integration suite;
- G5-02 knowledge suite;
- G5-01 semantic + timeline suites;
- affected G2 Conversation/Context;
- affected G3 Save/Restore;
- affected G4 continuation/Application;
- Public d20 regression;
- `git diff --check`.

## 6. Provider

**ZERO real Provider calls.** Parent G5-03 feature proof remains honestly pending.

## 7. Evidence

Create:

`docs/g5_03/G5-03M1R01C02_DIRTY_OPPORTUNITY_CONSUMPTION_EVIDENCE.md`

Record exact changed paths, dirty-consumption semantics, no-auto-retry proofs, production wiring proof, sequential A→B proof, regressions, `git diff --check`, and zero real Provider calls.

## 8. Completion

Commit/push `origin/main` and return:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not start G5-03M2/G5-04.
