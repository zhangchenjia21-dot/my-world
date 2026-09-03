# G5-01M1 Independent Review

Status: **CORRECTION REQUIRED / NOT ENGINEERING PASS YET**  
Reviewer: **GPT**  
Reviewed implementation: `eb171a19dd0b4eeb134392128fb8df7fd5b104cb`  
Reviewed evidence: `f9b1be01bd102f3bb1ae6b0b762a6b97d3a5b6f1`  
Real Provider vertical: **PENDING / EXTERNAL PROVIDER UNAVAILABLE**

## 1. Review result

The overall G5-01M1 architecture is accepted in principle:

```text
durable free-form Conversation acceptance
→ separate best-effort semantic-analysis lane
→ optional Program-owned World Turn
→ existing atomic world mutation / Timeline
→ bounded matching Context projection
```

The implementation correctly keeps player-visible Narrative independent from semantic-analysis success, introduces no narrative JSON/output gate, reuses the selected Provider adapter without fallback, reuses the existing world-mutation/SQLite owner, and keeps `living_world.v0.1` as a bounded turn consequence ledger rather than a universal ontology.

However, Independent Review found one concrete Timeline isolation defect. Engineering PASS is withheld until the focused correction below is closed.

## 2. Blocking finding — Restore does not reset semantic worker timeline-local state

`SemanticMaterializationProcess` owns in-memory state including:

```text
_attempted_versions
_queue
_active
```

The current Runtime already emits `restore_completed` after a committed Save/Recovery progress switch, but the semantic worker does not observe that signal.

Therefore an abandoned future branch can leave `_attempted_versions` entries behind after Restore.

Concrete failure sequence:

```text
Turn N accepted in future branch
→ semantic version V is attempted/materialized
→ Restore to an earlier Save before Turn N
→ durable Conversation + world_state correctly return to the older snapshot
→ semantic worker memory still remembers version V as attempted
→ player later reaches the same Turn N / accepted GM hash again
→ current world_state has no matching World Turn, but _attempted_versions still contains V
→ worker returns already_attempted
→ no semantic request occurs
→ restored branch can no longer materialize that legitimate consequence
```

This is stale future execution state influencing the restored timeline. It violates the protected principle:

> **Player owns the timeline.**

It also means the existing evidence statement “no stale future semantic memory leaks after Restore” is broader than the current test actually proves. The current Timeline test proves stale/future **records are excluded from Context**, but it does not prove abandoned-future **attempt suppression state** cannot affect subsequent play.

## 3. Neighboring Restore race that the correction must cover

A semantic analysis may also be active or queued when the player performs Save Restore / Recovery because semantic analysis is intentionally independent from foreground Conversation generation.

After a committed progress switch:

- a pre-Restore active analysis must not be allowed to commit into the new timeline, even if the restored Conversation happens to contain coincidentally matching text;
- queued pre-Restore semantic work must not continue as authoritative work for the restored timeline;
- Restore itself must not automatically launch a new semantic Provider request.

The correction may use the existing `session_runtime.restore_completed` signal and a small timeline epoch/invalidation mechanism or an equivalent bounded design. Do not change persistence schema or make semantic analysis a Restore gate.

## 4. What passed review

Independent Review found no blocking issue in these M1 boundaries:

- semantic analysis starts from accepted Conversation completion rather than provisional streaming text;
- GM-only Opening is skipped;
- visible Narrative is not parsed as machine protocol;
- analysis malformed/empty/transport failure is fail-soft;
- valid semantic result constructs a bounded `living_world.v0.1` record and uses existing `commit_world_mutation_durably(...)`;
- same currently materialized accepted version is idempotent through the durable record lookup;
- GM-hash mismatch excludes stale replacement records from Context;
- Context projection is bounded;
- no SQLite schema migration/new table, Source mutation, Runtime Model Settings change, Public d20 change, UI work, G5-02+ domain work or G6 visual work was introduced;
- final evidence honestly records the two Kimi K3 Narrative-stage 420-second timeouts and does not claim a real Provider PASS;
- evidence records `git diff --check` PASS and Owner production fingerprints unchanged.

## 5. Real Provider status

The two bounded real Kimi K3 attempts timed out during ordinary Narrative before the feature-specific semantic lane could execute.

Classification remains:

```text
real selected-Provider G5-01 vertical
PENDING / EXTERNAL PROVIDER UNAVAILABLE
```

This is not the reason for the correction and must not trigger another Provider attempt during the Restore fix.

## 6. Required next task

Issue one focused correction under the correction budget:

`G5-01M1C02 Restore Timeline Isolation Correction`

Temporary execution routing applies through 2026-09-06, so implementation owner is **KIMI**.

Required proof:

1. after Restore removes a future semantic turn, recreating the exact same accepted future version can trigger semantic analysis/materialization again;
2. active pre-Restore analysis is invalidated and cannot commit after the progress switch;
3. queued pre-Restore work is discarded/quarantined;
4. Restore itself launches no semantic Provider request;
5. existing correction/idempotency/Save-Restore/Context tests remain green;
6. no real Provider call is required for this correction.

After the correction is pushed, GPT performs another Independent Review. Engineering PASS still does not imply the missing real Provider/product reality vertical passed.
