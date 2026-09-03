# G5-03M1C01 Independent Review — Agency Currentness + Timeline Isolation

Status: **CORRECTION REQUIRED — C02**  
Reviewer: **GPT**  
Reviewed implementation: `a28ccc7688ca44bce91589badb129f90736cc603`  
Parent: `G5-03M1 Multi-Actor Agency Cycle`

## 1. Review result

C01 correctly closes the six findings from the first M1 review:

- stale Agency execution is guarded at commit time;
- production Restore invalidates active Agency;
- sibling commits advance a cycle-owned expected head while unrelated head changes stale remaining work;
- stale Knowledge / Agency History are filtered by current accepted GM hash before actor requests;
- same-turn stale cycle is replaced rather than merged;
- already committed actors are skipped on replay.

The Multi-Actor Agency Cycle architecture remains intact and should **not** be redesigned.

However, two neighboring defects in the same currentness/handoff seam prevent Engineering PASS.

## 2. Blocking finding A — semantic materialization was accidentally made latest-turn/foreground-idle only

C01 changed `_accepted_version_still_current()` so a semantic result is rejected whenever its source turn is no longer the latest accepted turn or a newer foreground generation is active.

That is too broad.

The product distinction must be:

```text
accepted source version still exists with the same GM hash
→ its G5-01 changes / G5-02 knowledge may still materialize

source turn is no longer latest or foreground has already advanced
→ do not start Agency for that old turn
```

A player beginning Turn B while Turn A semantic analysis is still finishing must not cause already-accepted Turn A world consequences/knowledge to disappear merely because the player was fast.

This is a G5-01/G5-02 regression introduced by C01 and must be corrected without reintroducing stale Agency handoff.

## 3. Blocking finding B — selection-only semantic results cannot start production Agency

The successful `no_changes` result path carries `agency_candidates` but does not carry `source_gm_sha256`.

`Application._on_world_turn_finished()` correctly requires the source hash to match current accepted Conversation before starting Agency. Therefore a valid semantic response like:

```json
{
  "changes": [],
  "knowledge_events": [],
  "agency_candidates": ["char-npc-sun", "char-npc-cao"]
}
```

cannot start Agency in production because the handoff identity is incomplete.

The same loss can occur in the later branch where parsed knowledge exists but all knowledge events are dropped by the stable-actor allowlist, leaving no world/knowledge record to commit.

Agency Selection must be able to stand on its own. A world window can plausibly produce no newly materialized `changes`/`knowledge_events` while still giving existing actors reason to act.

## 4. Required correction direction

Do not redesign the cycle. Separate two predicates:

1. **semantic source-version currentness** — source turn still exists in durable accepted Conversation and its GM hash still matches. This governs whether changes/knowledge may materialize.
2. **agency handoff eligibility** — source version is still the latest accepted ordinary turn, Conversation is foreground-idle, and its hash matches. This governs whether `agency_candidates` may be handed to Application.

Then preserve complete source identity (`source_turn_index` + `source_gm_sha256`) on every successful semantic terminal result that can legally carry `agency_candidates`, including selection-only/no-record paths.

If semantic source version is still valid but Agency is no longer eligible, commit valid changes/knowledge and publish `agency_candidates=[]`.

If the source GM hash itself was replaced/corrected, neither semantic materialization nor Agency may proceed.

## 5. Scope

This is `correction-02` on the currentness/handoff seam.

Do not change:

- multi-actor selection/execution architecture;
- max-4 cap;
- concurrent actor requests;
- actor knowledge isolation;
- persistence schema;
- UI;
- Source;
- G5-03M2/G5-04+;
- Provider/model settings.

No real Provider call is required or authorized by this correction.

## 6. Verdict

```text
G5-03M1C01
PARTIAL PASS / CORRECTION-02 REQUIRED

G5-03M1
NOT YET ENGINEERING PASS

Next:
G5-03M1C02 Semantic-vs-Agency Currentness Separation
```
