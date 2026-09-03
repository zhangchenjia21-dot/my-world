# G5-02M1C01 Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed parent implementation: `492815aefd127c20bd17fbda892aad8d41279dcb`  
Reviewed correction: `4de236907934830404b805642e5d407887abd5be`  
Real selected-Provider feature vertical: **PENDING / EXTERNAL PROVIDER UNAVAILABLE**

## 1. Verdict

G5-02M1C01 closes the concrete Independent Review findings without expanding the architecture.

Engineering verdict:

```text
G5-02M1C01  PASS / CLOSED
G5-02M1     ENGINEERING PASS / CLOSED
```

The real selected-Provider feature-specific proof remains historically pending because the single bounded parent attempt timed out during ordinary Narrative before the semantic lane ran. The correction correctly made no second Provider attempt.

## 2. Actor roster request seam — PASS

Production `_analysis_messages(...)` now derives the exact stable Game-local actor roster from the current durable world state and places display-name + `local_character_id` pairs inside the same existing semantic-analysis request.

The machine instruction now explicitly requires `knower_id` to come only from that supplied roster.

No second semantic/knowledge Provider request was added.

This fixes the prior production gap where deterministic tests could hand-write valid IDs that a real model had never been shown.

## 3. Recent knowledge projection — PASS

Knowledge projection now selects matching records newest-first until the bounded event cap is filled, then renders each actor's selected events chronologically.

Therefore long-running play no longer pins the knowledge working set to the earliest records while excluding newly acquired information.

The existing actor/event/character bounds remain intact; no G7 retrieval system was introduced.

## 4. Real-provider harness truthfulness — PASS

The real-provider harness now requires feature-specific evidence before it can claim success:

- ordinary Narrative accepted;
- semantic result is committed;
- at least one durable non-empty knowledge record/event exists;
- all committed knowers are stable roster actors;
- later Context contains `Actor Knowledge Provenance` and the committed fact.

`no_changes`, empty knowledge, or mere Context assembly can no longer masquerade as G5-02 feature PASS.

The corrected harness was intentionally not executed because the Task Packet's one bounded real attempt had already been consumed.

## 5. Regression / scope review

Evidence records:

- G5-02 focused: 40 PASS / 0 FAIL;
- G5-01 semantic + Timeline regressions green;
- directly affected G2/G3/G4 context/continuation regressions green;
- `git diff --check` clean;
- no Conversation acceptance change;
- no UI change;
- no persistence schema/table change;
- no Source mutation;
- no Runtime Model Settings/Public d20 change;
- no G5-03/G5-04/G6/G7 implementation.

Independent code inspection confirms the production correction is limited to the existing semantic-request and knowledge-projection seams.

## 6. Product/reality checkpoint decision

No separate Owner UAT is required for G5-02 alone.

Reason:

> Knowledge Provenance is primarily a backend semantic boundary. Its first materially player-visible consumer is G5-03 actor agency: an NPC must act from what that NPC knows rather than from GM omniscience.

Creating another isolated UAT solely to inspect the hidden knowledge ledger would add Owner burden without a stronger product consumer.

Therefore the missing real-provider feature vertical remains an honest evidence gap and will be exercised naturally by the first real G5-03 actor-agency consumer; it is not rewritten as historical PASS.

## 7. Route

```text
G5-02 Knowledge Provenance
PASS / CLOSED

→ G5-03 NPC / Faction Agency
→ first slice: stable Guaranteed-NPC independent agency
```

Faction agency is not pulled into the first slice merely for symmetry; stable faction identity/ownership should be introduced only when a concrete agency consumer requires it.
