# TASK｜G5-01M1C01｜Provider Outage / Reviewability Correction

Type: **task closeout correction / no feature expansion**  
Owner: **CODEX**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-01M1 World Turn / Semantic Materialization Spine**  
Status: **ACTIVE — APPLY TO CURRENT LOCAL WORKTREE**  
Return ceiling: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## 1. Why this correction exists

The current G5-01M1 implementation and offline/integration regressions are reported green, but the bounded real Provider proof could not reach the feature-specific semantic lane because both authorized Kimi K3 requests timed out during ordinary Narrative after 420 seconds.

Observed external outcome:

```text
attempt 1 → ordinary Narrative wait → 420s timeout
attempt 2 → ordinary Narrative wait → 420s timeout
no accepted Narrative
no semantic-analysis request
no World mutation
no Provider fallback
no third attempt
```

This does **not** prove the G5-01M1 implementation correct, but it also does not provide evidence of a feature-specific defect. The failure occurred before the new semantic-materialization lane was exercised.

Canonical standing policy now clarifies:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

> **External Provider availability may block reality proof; it does not block code review.**

## 2. Superseded completion behavior

For the current worktree only, supersede any interpretation of the parent packet that says failed real Provider evidence requires the implementation/evidence to remain uncommitted or unpushed.

Do **not** perform another real Provider attempt for this correction. The parent packet's bounded ceiling has already been exhausted.

Do **not** switch Provider/model, add fallback, raise timeouts, or create a third attempt merely to obtain a green real result.

## 3. Required action

Preserve the current local implementation and already-completed test work.

1. Fetch both repository `main`s.
2. Reconcile the new task/governance documentation without discarding local production/test/evidence changes.
3. Revalidate only what is necessary to ensure the local worktree still corresponds to the current task authority; do not gratuitously rerun the two real Provider attempts.
4. Finalize `docs/g5_01/G5-01M1_WORLD_TURN_SEMANTIC_MATERIALIZATION_EVIDENCE.md` with an explicit real-provider section stating:
   - both Kimi K3 attempts timed out at ordinary Narrative after 420 seconds;
   - no Narrative was accepted;
   - semantic analysis and World mutation were therefore not exercised by the real run;
   - no fallback / hidden model switch / third attempt occurred;
   - real Provider vertical status = `PENDING / EXTERNAL PROVIDER UNAVAILABLE`;
   - this evidence does not claim real Provider PASS.
5. Explicitly record final `git diff --check`.
6. Commit implementation/tests/evidence.
7. Push to `origin/main`.

## 4. Independent Review eligibility

Codex may return for GPT review when:

- implementation is committed and pushed;
- required offline/in-process/SQLite/Timeline/Save-Restore/Context regressions are green as already reported;
- the Provider-outage evidence is honest and bounded;
- Owner production settings / Source / Games / Game Library / current SQLite fingerprints remain unchanged;
- no new feature scope was added while closing out.

Return:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Include:

- START_HEAD;
- IMPLEMENTATION_HEAD;
- EVIDENCE_HEAD / FINAL_HEAD;
- exact changed paths.

## 5. What GPT may and may not conclude

GPT may inspect actual code and offline/integration evidence and decide whether the **engineering implementation** passes Independent Review.

GPT must **not** claim that the G5-01 real Provider vertical passed unless a later real run or Owner UAT actually exercises:

```text
accepted Narrative
→ semantic analysis
→ durable World Turn
→ reopen
→ later Context projection
```

If engineering review passes while real evidence remains unavailable, G5-01 product/reality acceptance stays pending and can be satisfied later by the next successful real Provider run or Owner UAT.

## 6. Scope protection

This correction authorizes no production behavior change by itself.

Do not:

- redesign Provider timeouts;
- add Provider fallback;
- change model settings;
- change semantic-materialization semantics;
- change UI;
- change SQLite schema;
- start G5-02;
- create new benchmark/retry infrastructure.

The correction only separates **reviewability** from **external Provider availability**.