# G5-03M2B — Runtime Narrative Actor Materialization

Status: **PLANNED / DO NOT EXECUTE UNTIL M2A INDEPENDENT REVIEW PASS**  
Reviewer: GPT

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`

## Purpose

Make a distinct character created during accepted play able to become a durable Game-local NPC even when no Character Card exists.

This is mandatory for G5-03M2 completion.

## Frozen implementation direction

After M2A registry foundation exists:

1. Extend the existing background semantic-analysis response with optional `new_actor_candidates`.
2. Do not add another mandatory Provider call.
3. Keep the field independently fail-soft: malformed/absent actor candidates never invalidate Narrative, valid `changes`, or valid `knowledge_events`.
4. Candidate shape is bounded character material only, conceptually:

```json
{
  "display_name": "陈安",
  "profile_text": "Only identity/role/background material established by this accepted Narrative."
}
```

5. The semantic request includes the current exact stable roster and instructs the model not to emit already-stable actors as new.
6. Program logic, never the model, mints the final `local_character_id`.
7. Runtime records use `origin.kind = runtime_narrative` plus exact `source_turn_index + source_gm_sha256`.
8. Commit valid new actors atomically through the existing semantic world mutation together with valid changes/knowledge when present; no second actor-registration mutation.
9. `stable_npc_records(... accepted_hashes ...)` filters runtime records by current accepted GM hash so regenerate/correction makes erased actor history inert.
10. After semantic terminal, existing Agency v0.3 wake can see the new actor immediately in the same player-turn opportunity.

## Product selection rule

Do not materialize every incidental person. A candidate is appropriate when the accepted Narrative establishes a distinct individual with plausible continuity relevance. A character may remain ephemeral on first mention and become stable later.

No keyword/score gate and no first-mention requirement.

## Protected boundaries

- no display-name authoritative identity;
- no model-minted local IDs;
- no runtime Source-current lookup;
- no fake Source provenance;
- no new mandatory Provider call;
- no Narrative acceptance gate;
- no automatic knowledge grant;
- no universal entity ontology;
- no Faction/G5-04/UI/Public-d20 scope.

## Required deterministic proofs when activated

At minimum prove:

- valid new candidate becomes one durable Program-owned stable NPC;
- candidate-only semantic result can materialize without fake `changes`;
- malformed actor-candidate field does not damage valid changes/knowledge;
- same accepted-version replay does not duplicate the actor;
- regenerate/correction hash mismatch excludes stale runtime actor from roster and Agency;
- Save/reopen/Restore preserves the runtime actor record and exact ID;
- after semantic commit, same-turn Agency selector can see/select the new actor;
- no knowledge is granted merely by materialization;
- no runtime Source lookup occurs.

Use focused-first validation. Do not execute this packet before M2A PASS.
