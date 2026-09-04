# G5-03M2A — Stable Actor Registry Foundation

Status: **ACTIVE — KIMI**  
Reviewer: GPT  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_STABLE_ACTOR_REGISTRY_AND_MATERIALIZATION_V0_2_DECISION.md`

## 1. Goal

Build the Game-local registry foundation so stable NPC identity is no longer equivalent to “has a Character Card”.

M2A must support two non-Guaranteed ingress paths:

1. automatic Source-backed Character Cards compatible with the selected exact World+Entry;
2. Game-local NPCs explicitly authored/enabled for this Game **without** a Character Card.

M2B will then add runtime Narrative-emergent NPC materialization on top of this foundation. Do not implement M2B semantic extraction in this packet.

## 2. Read only what is needed

Refresh both mains, then read:

- `AGENTS.md`;
- the canonical v0.2 decision;
- `src/最终建局/L0_公理层/最终建局规则.gd`;
- `src/最终建局/L2_流程层/原子最终建局流程.gd`;
- existing Source exact T0 projection contract;
- `src/世界回合/L0_公理层/世界回合规则.gd`;
- current Agency Scheduler/Cycle only where actor registry/material resolution is consumed.

Do not re-read R01/C01/C02/R02 history unless a concrete regression requires it.

## 3. Required implementation

### A — Optional creation-authored no-Card NPC input

Extend Final Create Composition additively with an optional field:

```text
game_local_npcs
```

Missing field MUST canonicalize as `[]`; all existing callers remain valid.

Each item is bounded Game-local material, conceptually:

```json
{
  "display_name": "陈安",
  "profile_text": "This Game's established character identity/role/background material."
}
```

Requirements:

- validate bounded non-empty strings;
- do not require or invent Source provenance;
- do not use display name as identity or dedupe authority;
- duplicate display names are legal distinct people;
- freeze canonicalized records into the creation intent.

No UI work in M2A.

### B — Automatic Source-backed stable NPC snapshot

On the first creation-intent build only:

- inspect validated current Character inventory once;
- use the existing exact T0 projection contract for selected exact World+Entry;
- include only `compatibility_state == exact_profile`;
- exclude Player Character and explicit Guaranteed NPC Character asset IDs;
- deterministically order Source-backed candidates by exact Source identity;
- freeze exact provenance + exact T0 `source_projection`.

Same creation ID retry/resume reuses the stored intent and MUST NOT rescan later Source current.

### C — Program-owned stable NPC identities

During first intent construction, assign Program-owned `local_character_id` values for both:

- automatic Source-backed records;
- creation-authored no-Card records.

Store both under optional additive `initial_setup.stable_npcs[]`, preserving `guaranteed_npcs[]` as a distinct product role.

Source-backed record concept:

```text
local_character_id
role = stable_npc
origin.kind = source_character
provenance = exact pin
source_projection = frozen T0 projection
```

Creation-authored record concept:

```text
local_character_id
role = stable_npc
origin.kind = creation_authored
game_local_material = { display_name, profile_text }
```

Do not fabricate Source fields for the second form.

### D — Unified Program-owned helpers

Create/reuse helpers equivalent to:

```text
stable_npc_records(world_state, accepted_hashes = {})
stable_actor_material(record)
actor_roster(world_state, accepted_hashes = {})
```

For M2A:

- Guaranteed NPCs are included;
- creation-time `stable_npcs` are included;
- Player is included only in `actor_roster`, never Agency eligibility;
- empty/duplicate local IDs are rejected deterministically/fail-soft;
- `stable_actor_material` returns Source projection for Source-backed/Guaranteed actors and Game-local material for no-Card actors.

Prepare the helper currentness contract for M2B: if a synthetic/future record has `origin.kind == runtime_narrative`, it is returned only when supplied `accepted_hashes[source_turn_index] == source_gm_sha256`. Do not implement runtime production yet.

### E — Update only necessary consumers

Update G5-02/G5-03 consumers so they use the unified registry/material helpers:

- Knowledge roster can include creation-authored no-Card NPCs;
- Agency selector eligibility includes Guaranteed + Source-backed stable + creation-authored stable NPCs;
- actor execution can resolve either Source-backed material or Game-local material by exact `local_character_id`;
- actor-private Knowledge/history isolation remains unchanged.

Do not change v0.3 scheduling semantics.

### F — Existing Game compatibility

For existing Games with no `stable_npcs` and no `game_local_npcs` creation payload history:

```text
missing → []
no failure
no runtime Source lookup
Guaranteed-only behavior stays exact
```

No SQLite migration/table.

## 4. Deterministic focused proofs

Build a small M2A focused suite proving:

1. **Source-backed snapshot** — extra exact-profile Character Cards materialize; Player/Guaranteed/temporal-incompatible/no-world-coverage cards do not.
2. **No-Card creation actor** — `game_local_npcs` creates a stable NPC with Program ID + `game_local_material` and no fake provenance.
3. **Same-name distinct actors** — two Game-local NPCs may share a display name but receive distinct local IDs.
4. **Retry authority** — same creation ID reuses frozen Source snapshot and authored records after Source current changes.
5. **Old Game compatibility** — missing `stable_npcs` remains valid and performs no Source lookup.
6. **Unified roster/eligibility** — Knowledge roster = Player + all stable NPCs; Agency pool excludes Player.
7. **Material family resolution** — actor execution prompt can use one Source-backed NPC and one no-Card NPC through the existing actor-scoped path without leaking another actor's Knowledge.
8. **Future currentness helper** — synthetic runtime-origin record is included only for a matching accepted hash and excluded for a mismatching hash.
9. **Persistence** — Save/reopen/Restore preserves creation-time registry records and IDs.

No real Provider calls.

## 5. Slim validation budget

While developing: run M2A focused tests only.

After focused green, run once:

- G4-06 Final Create / creation integration;
- G5-02 focused;
- G5-03 focused;
- one directly relevant G3 Save/Restore suite;
- `git diff --check`.

Do not run unrelated UI/Public-d20/full-project suites without a concrete reason.

## 6. Scope ceiling

Do NOT:

- implement `new_actor_candidates` yet;
- modify semantic-analysis Provider behavior in M2A;
- add UI;
- add SQLite schema/table/migration;
- use display-name identity;
- let models mint IDs;
- retrofit existing Games from mutable Source current;
- implement Faction agency or G5-04;
- change Public d20/mechanics.

## 7. Evidence / return

Write compact evidence under `docs/g5_03/`:

- START_HEAD / FINAL_HEAD;
- changed files;
- requirement → implementation mapping;
- focused + affected regression results;
- real Provider calls = 0;
- `git diff --check`.

Commit/push and return:

`READY FOR INDEPENDENT REVIEW`
