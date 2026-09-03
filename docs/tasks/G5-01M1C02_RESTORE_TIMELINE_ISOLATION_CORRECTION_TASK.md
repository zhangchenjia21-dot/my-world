# TASK｜G5-01M1C02｜Restore Timeline Isolation Correction

Status: **CANCELLED / DO NOT EXECUTE**  
Type: historical focused-correction proposal  
Former owner: **KIMI**  
Semantic owner: **GPT**  
Parent: **G5-01M1 World Turn / Semantic Materialization Spine**

## 1. Cancellation decision

Do **not** implement this packet.

Independent Review was revised after deeper analysis. The Restore exact-replay scenario described here is a real but low-probability edge case, not a current G5-01 v0.1 blocker.

Current authoritative review:

`docs/g5_01/G5-01M1_INDEPENDENT_REVIEW.md`

G5-01M1 is now:

```text
ENGINEERING PASS / CLOSED
```

while the real selected-Provider vertical remains:

```text
PENDING / EXTERNAL PROVIDER UNAVAILABLE
```

## 2. Why this packet was cancelled

The proposed reset/invalidation correction would solve only one narrow symptom:

```text
Restore to an earlier timeline
→ later reproduce the exact same turn_index + full GM Narrative hash
→ old session-local attempted-version memory can suppress re-analysis
```

However, current World Turn / mutation identity is also deterministic from the same accepted version identity. Blindly allowing re-analysis can therefore produce a second nondeterministic semantic payload for the same durable mutation identity.

A complete solution would require a real consumer-driven decision about one of:

- durable reuse of the original semantic-extraction result;
- branch-aware semantic identity;
- another explicit exact-replay ownership model.

No current G5-01 product consumer requires that complexity.

## 3. Protected current behavior

The current implementation already protects the important product path:

- Save/Restore returns Conversation + world snapshot to the selected durable point;
- restored-away future World Turn records do not re-enter current Context;
- GM-hash mismatch quarantines stale semantic records;
- normal later Narratives with different full text/hash are evaluated as new accepted versions;
- Narrative remains independent from semantic-analysis success.

## 4. Deferred finding

Retain only as future design evidence:

```text
Exact future replay after Restore
with identical turn_index + full GM Narrative hash
may remain suppressed by session-local attempt memory.
```

Revisit only when an actual branching/exact-replay consumer makes the behavior product-relevant.

## 5. Current route

```text
G5-01M1 Engineering PASS / CLOSED
→ G5-01 Owner/Product Reality Checkpoint
→ if PASS: close G5-01
→ shape G5-02 Knowledge Provenance
```

Do not perform any C02 code change, test work, or real Provider call.
