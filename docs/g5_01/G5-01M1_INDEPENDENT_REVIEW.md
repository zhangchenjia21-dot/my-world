# G5-01M1 Independent Review

Status: **ENGINEERING PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed implementation: `eb171a19dd0b4eeb134392128fb8df7fd5b104cb`  
Reviewed evidence: `f9b1be01bd102f3bb1ae6b0b762a6b97d3a5b6f1`  
Real Provider vertical: **PENDING / EXTERNAL PROVIDER UNAVAILABLE**

## 1. Final review result

G5-01M1 passes engineering Independent Review for its intended v0.1 consumer.

Accepted production ordering:

```text
durable free-form Conversation acceptance
→ separate best-effort semantic-analysis lane
→ optional Program-owned World Turn
→ existing atomic world mutation / Timeline
→ bounded matching Context projection
```

The implementation keeps player-visible Narrative independent from semantic-analysis success, introduces no narrative JSON/output gate, reuses the selected Provider adapter without fallback, reuses the existing world-mutation/SQLite owner, and keeps `living_world.v0.1` as a bounded turn consequence ledger rather than a universal ontology.

## 2. What passed review

Independent Review found the intended v0.1 seams sound:

- semantic analysis starts from accepted Conversation completion rather than provisional streaming text;
- GM-only Opening is skipped;
- visible Narrative is not parsed as machine protocol;
- malformed/empty/transport analysis failure is fail-soft;
- valid semantic result constructs a bounded `living_world.v0.1` record and uses existing `commit_world_mutation_durably(...)`;
- currently materialized accepted content is idempotent through durable record lookup;
- GM-hash mismatch excludes stale replacement/future records from Context;
- Save/Restore restores coherent Conversation + world snapshot and restored-away future World Turn records do not re-enter current Context;
- Context projection is bounded;
- no SQLite schema migration/new table, Source mutation, Runtime Model Settings change, Public d20 change, UI work, G5-02+ domain work or G6 visual work was introduced;
- final evidence honestly records the two Kimi K3 Narrative-stage 420-second timeouts and does not claim a real Provider PASS;
- evidence records `git diff --check` PASS and Owner production fingerprints unchanged.

## 3. Reclassified Restore exact-replay finding — deferred / non-blocking

The previous review temporarily classified one Restore exact-replay case as blocking: session-local `_attempted_versions` can remember a semantic attempt from a restored-away future, so if the player later reaches the same conversation turn index and the GM produces **exactly the same full Narrative bytes/hash**, the worker may suppress a second semantic-analysis attempt.

After further review, this is **not a G5-01 v0.1 blocker** and the proposed C02 correction is cancelled.

Reasons:

1. restored-away durable World Turn records already do not contaminate the restored current Context;
2. the edge case requires the later GM output to reproduce the exact same full-text hash at the same turn index, which is not a normal product-critical path for free-form Narrative;
3. naively clearing attempt memory and re-running analysis can create a deeper identity conflict because current deterministic World Turn / mutation identity is also derived from `game_id + turn_index + GM hash`, while a second nondeterministic extraction could produce a different payload for that same durable identity;
4. a complete solution therefore belongs with an actual branch/exact-replay consumer and would need an explicit design for durable extraction-result reuse or branch-aware semantic identity, rather than a speculative Restore reset mechanism.

Deferred finding:

```text
Restore exact future replay with identical turn_index + full GM hash
→ session-local prior-attempt suppression may prevent re-analysis
→ no current restored-timeline contamination
→ defer until an actual branch/exact-replay consumer requires semantics
```

This follows `Consumer before infrastructure` and does not change accepted G5-01 behavior.

## 4. Real Provider status

The two bounded real Kimi K3 attempts timed out during ordinary Narrative before the feature-specific semantic lane could execute.

Classification remains:

```text
real selected-Provider G5-01 vertical
PENDING / EXTERNAL PROVIDER UNAVAILABLE
```

Engineering PASS does not convert that missing reality proof into PASS.

## 5. Next gate

G5-01 now requires a short Owner/product reality checkpoint before closure.

The checkpoint must prove one simple lived consequence can become durable world reality, survive later play/reopen, and influence later Context while Narrative remains free-form. The previously deferred narrative-voice soft prompt may be observed opportunistically in the same checkpoint but is not a separate gate.

Only after Owner/Product PASS may GPT close G5-01 and shape G5-02 Knowledge Provenance.
