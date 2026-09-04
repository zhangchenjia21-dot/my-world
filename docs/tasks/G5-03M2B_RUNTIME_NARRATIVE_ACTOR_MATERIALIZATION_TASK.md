# TASK｜MW-001｜Runtime Narrative Actor Materialization

Type: implementation  
Owner: Kimi  
Reviewer: GPT  
Capability-Anchor: **G5-03**  
Legacy Planning Ref: **G5-03M2B**  
Revision: **1**  
Review-Round: **0**  
Depends-On: **G5-03M2A Stable Actor Registry Foundation — IR#2 PASS / CLOSED**  
Base: `zhangchenjia21-dot/my-world` / `main` / `f5076e23d195093445360af35782baeb61937b3f`  
Formal implementation code base before task docs: `e8d63415ed4c346649149b527fa016cf6754e1c4`  
Status: **ACTIVE — KIMI**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Make a distinct person established during accepted play able to become a durable Game-local stable NPC even when no Character Card exists.

The product path to prove is:

```text
accepted Narrative establishes a continuity-relevant person
→ existing background semantic lane proposes bounded actor material
→ Program mints exact Game-local identity
→ the same semantic durable mutation materializes the actor
→ Save/Restore keeps the identity
→ later Knowledge can target the exact ID
→ same-turn / later Agency can select the actor normally
```

This is the second and final required G5-03M2 slice. Do not enter G5-04.

## 2. Why now

M2A is ENGINEERING PASS / CLOSED and already supplies:

- top-level `stable_npcs[]` storage;
- Program-owned stable actor identity/material normalization;
- `stable_npc_records(world_state, accepted_hashes)` currentness filtering for future `runtime_narrative` records;
- Knowledge roster / Agency selector / actor execution consumption of the unified registry.

MW-001 now adds only the missing runtime Narrative ingress.

## 3. Authority / Source Manifest

1. Owner current explicit instruction.
2. `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md` — FROZEN / CURRENT CANONICAL.
3. `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR2.md` — M2A PASS / CLOSED.
4. Current production code/tests at refreshed `my-world/main`.
5. `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md` — Work Item identity / lineage rule.

Historical `G5_STABLE_NPC_MATERIALIZATION_V0_1_DECISION.md` and the superseded source-only M2 packet are not current authority.

## 4. Read First

Refresh both `main`s, then read only this initial set:

1. `AGENTS.md`;
2. canonical v0.2 decision above;
3. `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR2.md`;
4. `src/世界回合/L2_流程层/语义物化流程.gd`;
5. `src/世界回合/L1_器件层/语义变更响应解析器.gd`;
6. `src/世界回合/L0_公理层/世界回合规则.gd`.

Read the current Agency Scheduler only when implementing/proving same-turn visibility. Expand beyond this set only when concrete evidence requires it; state why.

Do not reread M1 R/C history unless an actual regression requires it.

## 5. Decision Digest / Invariants

### INV-01 — Existing semantic lane only

Extend the existing post-Narrative semantic-analysis request/response. **Do not add a new mandatory Provider call.**

The accepted visible Narrative remains independent of this extraction lane.

### INV-02 — Optional independently fail-soft field

Add optional:

```json
"new_actor_candidates": [
  {
    "display_name": "陈安",
    "profile_text": "Only bounded character material established by the accepted Narrative."
  }
]
```

Absent or malformed `new_actor_candidates` must fail-soft to no actor candidates and must never invalidate otherwise valid `changes` or `knowledge_events`.

Recommended extraction safety ceiling: **8 candidates per semantic turn**. This is not a world actor limit.

### INV-03 — Candidate material only

The model may supply only bounded descriptive character material. It does **not** supply authoritative identity or Source provenance.

Parser/normalization must construct clean candidate records from raw values; do not preserve or trust model-provided fields such as `local_character_id`, `asset_id`, `generation_fingerprint`, `provenance`, `origin`, or role authority.

`display_name` and `profile_text` must be raw strings, trimmed, non-empty, and bounded. Reuse compatible existing M2A bounds where appropriate rather than inventing an expansive profile contract.

Do not dedupe by display name. Exact duplicate candidate material may be fail-soft deduped, but two same-name actors are not the same identity merely because the names match.

### INV-04 — Product selection semantics stay model-owned

Do not create a keyword gate, score threshold, mandatory first-mention rule, or program ontology for deciding who deserves materialization.

Prompt the semantic model to propose a person only when the accepted Narrative establishes a **distinct individual with plausible continuity relevance**. Incidental people may remain ephemeral and can become stable later.

### INV-05 — Current stable roster in request

The semantic request must include the **current exact stable actor roster**, using current accepted turn→GM hashes so stale runtime-origin actors are not presented as current.

Instruct the model not to emit someone already represented in that roster as a new actor.

This is advisory semantic duplicate avoidance. Display-name matching is never authoritative Program dedupe.

Do not reactivate the old semantic `agency_candidates` design; Agency selection remains the standalone v0.3 Scheduler.

### INV-06 — Program-owned deterministic identity

For each accepted valid runtime candidate, Program logic creates the final `local_character_id`.

Runtime record shape:

```text
local_character_id = Program-owned
role = stable_npc
origin.kind = runtime_narrative
origin.source_turn_index = exact accepted turn
origin.source_gm_sha256 = exact accepted GM hash
game_local_material = {display_name, profile_text}
```

No fake Source fields.

Identity generation must be deterministic for replay of the same accepted source version and canonical candidate material. A stable candidate ordinal may be part of the derivation if needed, but identity must not depend on wall-clock time or a fresh random UUID at replay.

### INV-07 — Atomic semantic commit

Materialize valid new actors through the **same existing semantic world mutation** as valid `changes` / `knowledge_events`.

One accepted semantic result may therefore commit:

```text
changes only
knowledge only
actors only
changes + knowledge
changes + actors
knowledge + actors
changes + knowledge + actors
```

Actor-only is valid. Do not fabricate a fake change merely to force a mutation.

Do not create a second actor-registration mutation.

### INV-08 — Candidate-field failure isolation

If actor candidates are malformed but changes/knowledge are valid, commit the valid changes/knowledge exactly as before.

If changes/knowledge are empty but at least one actor candidate is valid, materialize the actor(s).

If all three semantic outputs contain no valid material, retain current no-op behavior.

### INV-09 — Replay / idempotence

The same accepted turn + GM hash must not create duplicate runtime actors on replay/reopen/lost-ACK style re-entry.

Candidate-only materialization must also have a durable replay signal; do not rely solely on in-memory `_attempted_versions` or on the existence of a `changes`/knowledge record.

Use the already materialized runtime actor origin (`source_turn_index + source_gm_sha256`) and/or an equivalent bounded durable semantic marker so an atomic actor-only commit can be recognized after reopen without duplicate IDs/records.

Do not retrofit arbitrary historical accepted turns.

### INV-10 — Regenerate / correction currentness

Do not delete stale physical actor history merely because the accepted Narrative changed.

`stable_npc_records(... accepted_hashes ...)` already defines currentness: a `runtime_narrative` record is current only while the origin turn/hash matches current accepted truth.

Ensure semantic request roster, Knowledge targeting, Agency eligibility, and actor execution continue to use the current filtered registry where applicable.

### INV-11 — Knowledge boundary

Materializing an actor does not grant world knowledge.

`game_local_material` may include the person's own identity/role/background explicitly established by that Narrative. It is not a substitute for G5-02 Knowledge Provenance.

Because the model does not know the Program-minted ID before commit, same-turn `knowledge_events` are not required to target the new actor. Pre-commit roster validation must not guess or backfill such knowledge.

### INV-12 — Same-turn Agency visibility

The existing ordering remains:

```text
accepted ordinary Narrative
→ semantic lane
→ semantic durable terminal
→ standalone Agency Scheduler consider_agency
```

After a semantic commit materializes a runtime actor, the existing terminal wake must allow the selector to see/select that actor in the same player-turn opportunity.

Do not alter dirty-consumption, foreground-priority, 0..4 actor cap, concurrency, or actor-private execution semantics to achieve this.

### INV-13 — No runtime Source lookup

Runtime Narrative actor creation is Game-local. Ordinary semantic/Agency/Continue/Save/Restore paths must not consult mutable Source current to establish or repair the actor.

## 6. Allowed Scope

Allowed production seams:

- `src/世界回合/L1_器件层/语义变更响应解析器.gd`;
- `src/世界回合/L0_公理层/世界回合规则.gd`;
- `src/世界回合/L2_流程层/语义物化流程.gd`;
- the minimal existing runtime/Agency integration seam only if needed for same-turn visibility;
- focused M2B tests and compact evidence.

Tests may reuse existing deterministic Provider adapters/stubs.

## 7. Prohibited Scope

Do not:

- add another semantic/actor-discovery Provider request;
- gate visible Narrative acceptance on actor extraction;
- let the model mint local IDs;
- use display-name equality as authoritative identity/dedupe;
- invent Source provenance for runtime actors;
- read mutable Source current during runtime materialization/Continue/Save/Restore/Agency;
- introduce a universal entity/relationship/faction ontology;
- add UI;
- add SQLite schema/table/migration;
- implement Faction agency;
- enter G5-04;
- modify Public d20/mechanics;
- change Agency v0.3 scheduling semantics;
- switch Provider merely to manufacture parent G5-03 real-provider evidence.

## 8. Required Focused Proofs

Create a small deterministic `tests/g5_03m2b/` suite. At minimum prove:

1. **Valid runtime actor** — a valid `new_actor_candidates` item becomes one durable `runtime_narrative` stable NPC with Program-owned ID, exact origin turn/hash, bounded `game_local_material`, and no fake Source provenance.
2. **Actor-only semantic result** — `changes=[]`, `knowledge_events=[]`, valid actor candidate still produces one semantic durable mutation and actor materialization without fake changes.
3. **Fail-soft actor field** — malformed/non-array/invalid candidate material yields no actor but does not damage otherwise valid changes and/or knowledge.
4. **Raw type contract** — non-string display/profile candidate values are dropped/rejected fail-soft, not coerced.
5. **Same accepted-version replay** — replay/reopen of an already actor-materialized accepted version does not create a second actor or a second identity, including actor-only materialization.
6. **Current-hash filtering** — after regenerate/correction hash mismatch, the stale runtime actor remains physically in history/world snapshot but is absent from current roster and Agency eligibility.
7. **Save/reopen/Restore** — exact runtime actor record and Program-owned ID survive production Save/reopen/Restore.
8. **Same-turn Agency visibility** — semantic commit materializes actor, semantic terminal completes, and the existing Scheduler selector request/eligibility can see and select that new ID in the same dirty opportunity.
9. **No automatic Knowledge** — materialization alone creates no knowledge event for the new actor; another actor's private Knowledge remains private.
10. **No runtime Source lookup** — focused runtime proof uses no Source Library access and production diff introduces none.
11. **Roster duplicate guidance** — semantic request includes current stable roster and instructions not to propose already-stable actors; stale runtime actors are excluded via accepted-hash currentness.
12. **M1 protection** — existing dirty semantics / foreground invalidation / selector 0..4 validation remain unchanged through one directly relevant G5-03 regression.

Use exact local identity in assertions; never assert correctness through display-name matching.

## 9. Validation Budget

Development loop:

- run only the new M2B focused suite until green.

After focused green, one minimal affected pass:

- G5-01/G5-02 semantic materialization/knowledge focused tests affected by parser/semantic-candidate changes;
- one directly relevant G5-03 Scheduler/Cycle focused suite for wake/eligibility protection;
- one G3-04 Save/Restore suite for runtime actor persistence;
- `git diff --check`.

Do not run the entire project, unrelated UI suites, G4 Final Create, or Public-d20 suites without a concrete reason.

Use deterministic semantic stubs. **Do not make real Provider calls for MW-001 acceptance.** Parent real G5-03 Provider proof stays honestly pending if the external Provider remains unavailable.

## 10. Evidence / Git

Before changes record current `main` HEAD and status. Do not overwrite unknown/newer work.

Before authoritative push, refresh/recheck `main`; if Product/Architecture/Task/target files changed, stop and re-audit rather than overwriting them.

Write compact evidence under:

`docs/g5_03/MW-001_RUNTIME_NARRATIVE_ACTOR_MATERIALIZATION_EVIDENCE.md`

Include:

- Work Item ID / Capability Anchor / Revision;
- START_HEAD / FINAL_HEAD;
- changed files;
- requirement → implementation mapping;
- focused results;
- minimal affected regressions;
- explicit real Provider calls = 0;
- `git diff --check` result;
- confirmation that M2A and Agency v0.3 protected behavior was not reopened.

Commit + push implementation and evidence.

## 11. Stop / Return

Stop immediately and report instead of improvising if current authority now conflicts with this packet or if satisfying the task would require a new schema, extra mandatory Provider call, display-name identity, new UI, Faction/G5-04, or Agency scheduling redesign.

Kimi may return at most:

`READY FOR INDEPENDENT REVIEW`

Kimi does not self-certify Engineering PASS or Product PASS.
