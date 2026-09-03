# G5-02M1 Independent Review

Status: **CORRECTION REQUIRED / NOT ENGINEERING PASS YET**  
Reviewer: **GPT**  
Reviewed implementation/evidence HEAD: `492815aefd127c20bd17fbda892aad8d41279dcb`  
Real Provider vertical: **PENDING / EXTERNAL PROVIDER UNAVAILABLE**

## 1. Review result

The overall G5-02M1 architecture is accepted:

```text
accepted free-form Narrative
→ one existing auxiliary semantic-analysis request
→ isolated changes + knowledge parsing
→ stable actor allowlist validation
→ at most one atomic world mutation
→ bounded Actor Knowledge Provenance in later GM Context
```

The implementation preserves G5-01 acceptance semantics, introduces no second Provider call, no Narrative protocol/output gate, no SQLite schema/table, no Source migration and no G5-03+ scope.

However, Independent Review found two concrete feature-level defects that prevent Engineering PASS.

## 2. Blocking finding A — semantic request does not provide the stable actor roster

`knowledge_events[*].knower_id` must be a current Game-local `local_character_id`, and non-roster IDs are correctly rejected before persistence.

But the production semantic request currently contains only:

```text
Accepted Player Action
Accepted GM Narrative
```

The request does **not** provide the Player Character / Guaranteed NPC local IDs or their display names.

Therefore a real model is instructed to return a stable local ID it has never been shown. Deterministic tests pass only because the stub response manually supplies IDs such as `char-player-001`.

This makes the real G5-02 consumer unreliable even when the Provider is healthy.

Required correction: include a compact read-only current actor roster in the **same existing semantic-analysis request**, e.g. display name + exact local ID for Player Character and Guaranteed NPCs. Do not add a second Provider call and do not expose unrelated Source/Context.

## 3. Blocking finding B — bounded knowledge projection keeps oldest events, not recent events

`WorldTurnContextProjector._project_knowledge(...)` sorts matching knowledge records oldest → newest, then stops once `MAX_KNOWLEDGE_EVENTS_PROJECTED` is reached.

After the cap is reached, later newly acquired knowledge is never projected. In a long-running Game the GM can therefore keep seeing the earliest eight knowledge events while missing newer knowledge.

This contradicts the frozen requirement for a bounded **recent** knowledge working set and can make actor behavior stale.

Required correction: select the newest matching knowledge events/turns within the cap, while preserving a readable chronological order in the final rendered block if desired.

## 4. Real Provider harness must prove the feature, not merely terminate

The current real-provider harness accepts `semantic_status == no_changes` and treats an empty knowledge record set as sufficient for the context-boundary check.

A future healthy Provider run could therefore finish successfully without producing any valid knowledge provenance and still report a passing feature-specific vertical.

Correction: when a future real proof is eventually run, the private-discovery scenario must require at least one committed valid roster knowledge event and require the later Context to contain the Actor Knowledge Provenance section for that event.

Do **not** make another real Provider request in this correction. The one authorized G5-02M1 attempt was already consumed and timed out in ordinary Narrative. The real vertical remains pending.

## 5. What passed review

Independent Review found no blocking issue in these boundaries:

- one auxiliary semantic request per accepted ordinary turn;
- Narrative remains free-form and is accepted independently of semantic-analysis success;
- knowledge parsing failure does not invalidate otherwise valid G5-01 `changes`;
- unknown/non-roster IDs are discarded before durable materialization;
- knowledge-only and changes+knowledge use the existing single atomic world-mutation seam;
- durable knowledge is stored inside `living_world`, not a new database/schema;
- source GM hash matching excludes stale knowledge from Context;
- no generic Knowledge Graph, false-belief engine, Faction knowledge, emergent NPC identity, UI, G5-03 Agency or G6/G7 work was introduced;
- deterministic evidence reports all focused/regression gates green;
- the real selected-Provider timeout is honestly recorded as pending rather than PASS.

## 6. Required next task

Issue one focused correction:

`G5-02M1C01 Actor Roster + Recent Knowledge Projection Correction`

Temporary routing through 2026-09-06 assigns the correction to **KIMI**.

No real Provider call is required or allowed for the correction because the parent task's one-attempt ceiling has already been consumed.
