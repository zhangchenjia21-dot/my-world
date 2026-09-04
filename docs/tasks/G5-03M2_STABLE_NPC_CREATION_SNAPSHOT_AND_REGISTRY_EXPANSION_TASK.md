# G5-03M2 — Stable NPC Creation Snapshot + Registry Expansion

Status: **ACTIVE — KIMI**  
Reviewer: GPT  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_STABLE_NPC_MATERIALIZATION_V0_1_DECISION.md`

## 1. Goal

Expand G5-03's stable actor pool beyond explicit `guaranteed_npcs` while preserving authoritative identity and Game-local Source freezing.

New Games should snapshot additional Character Cards that explicitly have an `exact_profile` for the selected exact World + Entry, materialize them as `stable_npcs`, and let existing G5-02/G5-03 consumers use them through one unified stable-NPC helper.

Do not change multi-actor Agency scheduling/execution semantics.

## 2. Read only what you need first

Before editing, refresh both mains and read:

- `AGENTS.md`;
- the canonical M2 decision above;
- `src/最终建局/L2_流程层/原子最终建局流程.gd`;
- `src/source/L3_外交层/Source库公开接口.gd` and existing selected T0 projection contract;
- `src/世界回合/L0_公理层/世界回合规则.gd`;
- the current Agency Scheduler/Cycle files only where actor-pool/source lookup must change.

Do not re-read the full R01/C01/C02 history unless a concrete failure requires it.

## 3. Required implementation

### A. Creation-time automatic stable-NPC snapshot

During the first creation-intent build, before the first durable Game side effect:

- use validated `SourceLibrary.list_current_sources()` inventory;
- consider Character Cards only;
- call existing `project_character_t0(... selected world asset id, selected entry id ...)`;
- include only `compatibility_state == exact_profile`;
- exclude Character `asset_id`s already used by Player Character or explicit Guaranteed NPCs;
- deterministic sort by exact Source identity;
- assign Program-owned Game-local IDs;
- freeze exact provenance + returned T0 `source_projection` into optional `initial_setup.stable_npcs[]` records with role `stable_npc`.

Do not put these records into `guaranteed_npcs`.

### B. Creation retry/resume stability

Once the creation intent exists, the stored `initial_setup` owns the snapshot. Same `creation_id` retry/resume MUST NOT rescan/recompute stable NPCs from a later Source `current`.

Do not change the current explicit player composition semantics merely to encode this automatic snapshot; reuse the existing creation-intent authority seam.

### C. Existing Game compatibility

`stable_npcs` is optional additive Game-local state:

- missing → `[]`;
- no error;
- no runtime Source Library lookup;
- no retrofit of old Games.

No new SQLite table or migration.

### D. Unified stable-NPC helper

Add/reuse one World rules helper equivalent to:

```text
stable_npc_records(world_state)
= guaranteed_npcs + stable_npcs
```

Then update only the necessary consumers:

- `actor_roster(world_state)` includes Player + all stable NPCs;
- Agency selector eligible actor IDs include Guaranteed + automatic stable NPCs, never Player;
- actor execution Source lookup can resolve either Guaranteed or automatic stable NPC by exact `local_character_id`.

Reject duplicate/empty local IDs fail-soft/deterministically; do not introduce display-name identity.

### E. Preserve knowledge boundaries

Materializing a stable NPC does not create knowledge. G5-02 events remain the only post-T0 durable actor-knowledge path.

Actor execution must still receive only that actor's own frozen Source + own committed Knowledge + own recent Agency history.

## 4. Must not do

- no free-form name matching;
- no model-minted actor IDs;
- no ordinary-runtime lookup of mutable Source `current`;
- no Faction agency / G5-04;
- no generic entity registry platform;
- no new UI;
- no Source schema change;
- no SQLite migration/table;
- no real Provider calls;
- no changes to Public d20/mechanics;
- no new mandatory gate.

## 5. Deterministic focused proofs

Build focused tests for these exact behaviors:

### A — New Game snapshot
Fixture has:
- selected World + Entry;
- Player Character card;
- explicit Guaranteed NPC card;
- at least two additional Character Cards with exact profiles for that World+Entry;
- one temporal-incompatible Character Card;
- one no-world-coverage/unrelated Character Card.

Prove `stable_npcs` contains only the additional exact-profile cards, with stable IDs, exact provenance, frozen T0 projections, deterministic order, and no Player/Guaranteed duplicates.

### B — Retry/resume authority
After first creation intent captures `stable_npcs`, mutate/publish different Source `current` state, then resume the same `creation_id`. Prove the exact stored `initial_setup.stable_npcs` remains unchanged and no new current inventory affects it.

### C — Old Game compatibility
Use a legal existing setup without `stable_npcs`. Prove stable helper/roster/Agency behavior remains Guaranteed-only and no Source lookup is required.

### D — Unified roster / Agency eligibility
Prove:
- Knowledge roster = Player + Guaranteed + automatic stable NPCs;
- Agency candidate pool = Guaranteed + automatic stable NPCs only;
- Player/unknown IDs rejected.

### E — Existing actor execution reused
Select one automatic stable NPC. Prove its existing actor execution request contains its own frozen Source and own Knowledge/history, excludes another actor/Player private Knowledge, and can produce one normal durable action through the existing AgencyCycle path.

### F — Persistence
Save/reopen/Restore preserves `stable_npcs` as ordinary Game-local world state with stable local IDs; no Source re-resolution.

## 6. Validation budget

Use the slim policy.

While developing: run the new M2 focused suite only.

After focused green, run one final affected regression pass:

- G4-06 Final Create / creation integration;
- G5-03 focused;
- G5-02 focused because `actor_roster` expands;
- one directly relevant G3 Save/Restore suite;
- `git diff --check`.

Do not rerun unrelated G2/UI/Public-d20/full-project suites unless a concrete failure gives a reason.

## 7. Evidence

Write compact evidence under `docs/g5_03/` containing only:

- START_HEAD / FINAL_HEAD;
- changed files;
- requirement → implementation mapping;
- focused + affected regression results;
- confirmation: real Provider calls = 0;
- `git diff --check` result.

Commit/push and return:

`READY FOR INDEPENDENT REVIEW`
