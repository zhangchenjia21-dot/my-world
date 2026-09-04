# G5-03M2A Stable Actor Registry Foundation — Independent Review IR#2

Status: **PASS / CLOSED**  
Reviewer: GPT  
Review-Round: **IR#2**  
Reviewed implementation head: `e0f4b9ad332920217955746d561bee4601db7de8`  
Reviewed evidence head: `e8d63415ed4c346649149b527fa016cf6754e1c4`

Canonical: `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`  
Task: `docs/tasks/G5-03M2A_STABLE_ACTOR_REGISTRY_FOUNDATION_TASK.md`  
Prior review: `docs/g5_03/G5-03M2A_INDEPENDENT_REVIEW_IR1.md`

## Verdict

**G5-03M2A Revision 2 = ENGINEERING PASS / CLOSED.**

IR#1 contained two bounded findings. Both are resolved without changing the M2A Outcome or architecture.

## IR1-F01 — strict string contract

PASS.

`_canonicalize_game_local_npcs` now reads raw `display_name` / `profile_text` values as `Variant`, requires both to be `TYPE_STRING`, and only then trims and applies the existing non-empty / maximum-length validation. Non-string values are rejected with `invalid_composition`; arbitrary values can no longer enter through `String(...)` coercion.

Focused tests separately cover non-string `display_name` and non-string `profile_text`.

## IR1-F02 — production Restore proof

PASS.

The M2A focused suite now executes the production path:

`create_save_point → durable world mutation / head advance → restore_save_point → close → reopen`

and verifies the creation-time stable registry identity survives the switch and reopen.

The directly affected G3-04 persistence regression provides the stronger generic invariant needed for record preservation: it snapshots `saved_world`, performs a later mutation, restores the Save, and asserts `runtime.world_state == saved_world` exactly, then verifies reopen remains on the restored state. Because `stable_npcs` is part of the opaque nested World document and M2A adds no registry-specific persistence machinery, this exact-world Restore invariant covers the full stable actor records, while the M2A focused proof confirms the stable actor IDs are present through the real production path.

No persistence defect was exposed; no schema/table/migration or registry-specific persistence logic was added.

## Scope / regression review

Diff from the IR#1 governance base to Revision 2 contains only:

- `src/最终建局/L0_公理层/最终建局规则.gd`;
- `tests/g5_03m2a/稳定演员注册表基础测试.gd`;
- M2A evidence update.

No Agency scheduler/cycle, semantic-analysis lane, UI, SQLite schema, Public d20, M2B producer, Faction agency, or G5-04 production code changed.

Committed evidence reports:

- M2A focused: **68 PASS / 0 FAIL**;
- G4-06 directly affected Final Create regression: **0 FAIL**;
- G3-04 Save/Restore regression: **PASS**;
- `git diff --check`: clean;
- real Provider calls: **0**.

Reviewer inspected the actual committed diff, production Restore implementation, M2A focused test source, and the G3-04 exact-world Restore regression. The reviewer environment did not expose a Godot executable, so runtime commands were not independently re-executed here; the committed test/evidence and production-code invariants were inspected directly.

## Closeout

M2A is closed. Its frozen behavior remains protected:

- automatic first-intent exact-profile Source-backed stable NPC snapshot;
- creation-authored no-Card stable NPC ingress;
- Program-owned Game-local identities;
- honest Source-backed vs Game-local material families;
- unified stable registry/material/roster helpers;
- Knowledge/Agency consumption through exact local identity;
- existing-Game compatibility with no mutable Source retrofit;
- future runtime-origin currentness filtering prepared by accepted turn/hash.

Parent G5-03 real Provider proof remains honestly `PENDING / EXTERNAL PROVIDER UNAVAILABLE`.

The next distinct executable Outcome is Runtime Narrative Actor Materialization. Under `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`, it receives a new flat Work Item ID rather than extending the legacy planning label.