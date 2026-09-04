# G5-03M2A Independent Review — IR#1

Status: **CORRECTION REQUIRED**  
Reviewer: GPT  
Reviewed implementation commit: `34d431690765d31e4604b329a3054cf1335d91b8`  
Reviewed repository head: `8e00ca45ae7ebb9bc428d0cba6cf24a3e099734e`  
Task: `docs/tasks/G5-03M2A_STABLE_ACTOR_REGISTRY_FOUNDATION_TASK.md`  
Canonical: `Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`

## 1. Review scope

Independent Review inspected the actual commit range from the M2A task base, production code, focused test source, affected-regression evidence, and task/canonical requirements.

The implementation direction is substantially correct:

- automatic Source-backed exact-profile snapshot is created only during first intent construction;
- Player / Guaranteed asset IDs are excluded from automatic snapshot;
- exact Source provenance + frozen T0 projection are stored;
- creation-authored no-Card actors use honest `game_local_material` with Program-owned IDs;
- Guaranteed remains a distinct product role;
- unified registry/material helpers feed Knowledge/Agency consumers;
- Player is excluded from Agency eligibility;
- runtime Narrative currentness helper contract is prepared without an M2B producer;
- runtime consumers do not read mutable Source current;
- M1 scheduling semantics were not reopened;
- no `new_actor_candidates`, UI, SQLite migration, G5-04, or Public d20 change was introduced.

Kimi evidence reports 61 focused assertions green, the specified G4-06 / G5-02 / G5-03 / G3 affected passes green, `git diff --check` clean, and zero real Provider calls.

## 2. Blocking findings

### IR1-F01 — `game_local_npcs` string type is not enforced

Task §3A requires bounded **non-empty strings** for `display_name` and `profile_text`.

Current production canonicalization does:

```gdscript
var display_name := String(npc.get("display_name", "")).strip_edges()
var profile_text := String(npc.get("profile_text", "")).strip_edges()
```

This silently accepts non-string values that stringify to non-empty text, for example an integer `123`.

Required correction:

- reject values whose raw type is not `TYPE_STRING` before normalization;
- keep the existing trim / empty / max-length rules;
- add focused proof that non-string values are rejected for both fields;
- do not widen the input contract or introduce coercive semantics.

### IR1-F02 — focused proof does not exercise actual Restore

Task §4 proof 9 explicitly requires:

```text
Save/reopen/Restore preserves creation-time registry records and IDs.
```

The current focused test proves initial reopen and mutation + reopen, but it does not invoke the production Restore path and assert the registry/IDs after Restore.

Required correction:

- extend the focused persistence proof through the existing production Restore path;
- restore to a snapshot that contains the creation-time registry and assert the exact stable actor records / Program-owned IDs survive unchanged;
- do not add persistence schema or special-case registry persistence logic unless the focused test exposes a real production defect.

## 3. Non-findings / protected boundaries

Do not reopen or expand:

- Multi-Actor Agency v0.3 dirty/wake/foreground semantics;
- Source snapshot architecture beyond the two findings above;
- runtime Narrative materialization / `new_actor_candidates`;
- UI;
- SQLite schema/table/migration;
- Faction agency / G5-04;
- Public d20/mechanics;
- real Provider proof.

## 4. Correction shape

This is **not a new task Outcome**. Under current Task Identity / Lineage governance, keep the same legacy task identity and advance metadata only:

```text
Task: G5-03M2A
Revision: 2
Review-Round: IR#1 → correction → IR#2
```

Do not create `G5-03M2AC01`, `R02`, or another recursive suffix.

## 5. Validation budget for Revision 2

Run only:

1. M2A focused suite with the new type-rejection + Restore assertions;
2. if the correction touches only Final Create validation/tests and the existing generic Restore path, rerun only the directly affected minimal regressions;
3. `git diff --check`;
4. zero real Provider calls.

Do not rerun a full G2/G3/G4/G5 matrix without a concrete regression reason.

## 6. Verdict

```text
G5-03M2A Independent Review IR#1 = CORRECTION REQUIRED
M2B = DO NOT START
```

Return ceiling after Revision 2 remains:

`READY FOR INDEPENDENT REVIEW`
