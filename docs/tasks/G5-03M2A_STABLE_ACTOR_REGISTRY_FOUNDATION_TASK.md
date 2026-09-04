# G5-03M2A — Stable Actor Registry Foundation

Status: **ENGINEERING PASS / CLOSED**  
Reviewer: GPT  
Final Revision: **2**  
Independent Review: **IR#2 = PASS**  
IR#1: `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR1.md`  
IR#2: `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR2.md`  
Implementation evidence: `docs/g5_03/G5-03M2A_STABLE_ACTOR_REGISTRY_FOUNDATION_EVIDENCE.md`

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`

## Outcome closed

M2A established the Game-local stable actor registry foundation so stable NPC identity is no longer equivalent to “has a Character Card”.

Closed behavior includes:

- automatic Source-backed Character Cards with `exact_profile` compatibility are snapshotted only on first creation-intent construction;
- Player and explicit Guaranteed Character asset IDs are excluded from that automatic snapshot;
- exact Source provenance + frozen T0 projection are preserved for Source-backed actors;
- optional creation-time `game_local_npcs` supports no-Card NPCs with bounded `display_name` / `profile_text` and honest `game_local_material`;
- raw no-Card material values must be strings; non-string values are rejected rather than coerced;
- Program-owned `local_character_id` values are assigned to Source-backed and creation-authored stable NPCs;
- duplicate display names remain legal distinct actors;
- `stable_npc_records`, `stable_actor_material`, and `actor_roster` provide the unified Program-owned view;
- Knowledge roster and Agency selector/execution consume exact Game-local identities across both material families;
- actor-private Knowledge / Agency history isolation remains protected;
- existing Games missing `stable_npcs` remain valid with no mutable Source retrofit;
- future `runtime_narrative` currentness is prepared through accepted turn/hash filtering;
- Save/reopen/Restore preserves the opaque World snapshot containing the stable registry and its Program-owned identities.

## Validation closeout

Revision 1 focused evidence: **61 PASS / 0 FAIL** plus the specified affected G4-06 / G5-02 / G5-03 / G3 regression pass.

Revision 2 correction evidence:

- M2A focused: **68 PASS / 0 FAIL**;
- non-string `display_name` rejected;
- non-string `profile_text` rejected;
- production `create_save_point → mutation → restore_save_point → reopen` exercised;
- directly affected G4-06 Final Create regression: **0 FAIL**;
- G3-04 Save/Restore regression: **PASS**, including exact restored `world_state == saved_world`;
- `git diff --check`: clean;
- real Provider calls: **0**.

## Protected boundaries retained

M2A did not:

- implement `new_actor_candidates`;
- add a mandatory Provider call;
- alter Multi-Actor Agency v0.3 scheduling;
- add UI;
- add SQLite schema/table/migration;
- use display-name identity;
- let models mint actor IDs;
- retrofit old Games from mutable Source current;
- implement Faction agency or G5-04;
- change Public d20/mechanics.

## Lineage

This is a legacy/in-flight task identity retained for historical continuity under `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

IR#1 findings did not change the Outcome, so they were resolved as **Revision 2** of the same task rather than by creating `C01/R02` suffix tasks.

The next distinct executable Outcome is Runtime Narrative Actor Materialization and receives a new flat Work Item ID.