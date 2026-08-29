---
title: my world｜G4-02R1 World / Character Source Semantic Re-audit
status: current-task-packet
task_id: G4-02R1
type: semantic-design-correction
owner: GPT
created: 2026-08-29
updated: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
historical_real_asset_repo: zhangchenjia21-dot/sillytavern-assets
historical_real_asset_sha: 4a5364a042e41f4c8a69621fc4467956a78703c0
codex_active: false
semantic_contract: v0.2-r2-frozen-implementation-pending
current_subtask: gpt-fixed-1287-fantasy-three-character-full-fidelity-migration
---

# TASK｜G4-02R1｜World / Character Source Semantic Re-audit

Owner: **GPT**

## Outcome

Using real `汉末三国` and `诸界余辉` assets as primary evidence, prove the smallest Source contract that preserves authored richness, keeps Game-local live truth separate, prevents post-T0 canon/personality leakage, preserves T0 character individuality, and still leaves post-T0 world/character development open to the model.

Codex has **no active task** until the real v0.2-r2 package shape/content is stable.

---

## Current state｜2026-08-29

Completed semantic/pressure evidence:

- real-source semantic audit against 2 World + 6 Character;
- v0.1 semantic adequacy verdict: **FAIL**;
- v0.2 base rich-section semantic freeze;
- Game-local evolvable semantics decision;
- T0-scoped Source / Post-T0 Canon Quarantine decision;
- v0.2-r2 T0 addendum;
- model-freedom self-check: **PASS**;
- `汉末三国` 12 authored fixed Entry temporal skeleton restored;
- 孙权 full valid Han temporal skeleton: 184/189/196/200/208/214/220/229/234/249; 263/280 incompatible;
- 孙权 temporal isolation pressure: **PASS**;
- early-character individuality contract frozen;
- 184/189 孙权 individualized at age-appropriate developmental scale;
- `189 孙权 vs 189 诸葛亮` same-stage blind differentiation: **PASS**;
- no adult-stereotype childhood backfill rule frozen;
- 刘备 temporal re-audit completed;
- 曹操 temporal re-audit completed;
- 刘备 full valid Han temporal skeleton: 184/189/196/200/208/214/220; 229+ incompatible;
- 曹操 full valid Han temporal skeleton: 184/189/196/200/208/214; 220+ incompatible;
- 刘备 / 曹操 early-vs-earned temporal ladder pressure: **PASS**;
- 189 / 196 shared same-year cuts refined at World Entry level;
- future-cue lint repaired: Runtime-visible “future is open” prose may not enumerate canon-shaped next actions merely to prohibit them;
- 汉末三国 World full-fidelity candidate: **PASS at semantic/content level**;
- 刘备 7-profile full-fidelity candidate: **PASS at semantic/content level**;
- 曹操 6-profile full-fidelity candidate: **PASS at semantic/content level**;
- 孙权 10-profile full-fidelity candidate: **PASS at semantic/content level**;
- 汉末三国 family joint no-shrinkage / differentiation / temporal coverage / ownership / future-cue audit: **PASS-candidate**;
- `诸界余辉` full-fidelity mapping completed;
- `诸界余辉` fixed-1287 World full-fidelity candidate: **PASS at semantic/content level**;
- `诸界余辉` World disclosure pressure: 20 rich `gm_reference` sections + 4 rich `gm_private` secrets + 3 preserved Entry snapshots, without universal nation/god/spell/law schema.

Current:

> **Fixed-1287 Character full-fidelity migration: 莉维娅·塞兰 / 阿德里安·维尔克 / 杜恩·石痕.**

Still NOT proven:

- final fixed-1287 rich Character package for 莉维娅;
- final fixed-1287 rich Character package for 阿德里安;
- final fixed-1287 rich Character package for 杜恩;
- fantasy-family original ↔ migrated no-shrinkage / disclosure / knowledge / complex-ability audit;
- final cross-family 2 World + 6 Character package-shape stability decision;
- Godot v0.2-r2 loader/validator/fingerprint;
- actual Compatibility Review temporal blocking;
- actual Context Assembly exclusion of unselected later content/unsafe metadata;
- real Provider anti-convergence UAT.

---

## Canonical semantic sources

Read current before further design/migration:

- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_T0_CHARACTER_INDIVIDUALITY_ADDENDUM.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`
- `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`
- `docs/source/G4-02R1_HAN_WORLD_FULL_FIDELITY_RESULT.md`
- `docs/source/G4-02R1_LIU_BEI_FULL_FIDELITY_RESULT.md`
- `docs/source/G4-02R1_CAO_CAO_FULL_FIDELITY_RESULT.md`
- `docs/source/G4-02R1_SUN_QUAN_FULL_FIDELITY_RESULT.md`
- `docs/source/G4-02R1_AFTERGLOW_WORLD_FULL_FIDELITY_MAPPING.md`
- `docs/source/G4-02R1_AFTERGLOW_WORLD_FULL_FIDELITY_RESULT.md`
- governance `architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`
- governance `architecture/source/G4_T0_SCOPED_SOURCE_AND_POST_T0_CANON_QUARANTINE_DECISION.md`

Historical r1 migration spec is superseded design evidence only.

---

## Frozen invariants

### Richness

> **Preserve meaning; do not force prose into a schema forest.**

Long authored Markdown/TXT sections are first-class Source bytes. Do not compress real characters into `summary/traits/background/drives`; do not replace World chapters with a few lore bullets.

### T0 authority

> **Do not show the model a post-T0 answer and then ask it to forget that answer.**

```text
Source Package Total Content
!= Selected T0 Projection
!= Game-local Reality
!= Runtime Relevant Set
!= Model-visible Working Set
```

World Runtime Source Projection:

```text
top-level always-safe sections
+ selected Entry-scoped sections
```

Character Runtime Source Projection:

```text
top-level always-safe sections
+ exact matching T0 profile sections
```

Never fallback to latest/nearest/later/complete-life biography.

### Temporal growth

> **A semantic dimension may enter a later profile only when pre-T0 lived history has actually earned it.**

Quarantine delays authority; it does not erase late complexity.

For fixed-1287 fantasy Characters, do not invent artificial multi-year profiles; preserve the one authored T0 in full.

### Character individuality

> **Age/development stage is a capability boundary, not a personality template.**

Every materialized T0 Character needs enough character-specific starting individuality for the GM to answer why this person starts differently from another same-age/same-stage person.

Do not create a rigid personality schema or numeric difference score.

### Shared Entry / Character binding ownership

World Entry owns shared starting place/time conditions. Character profile consumes those conditions and owns person-specific meaning; it does not create a private alternative World timeline.

### Closed per-World Character coverage

If a Character declares any `t0_profiles` binding to World W:

```text
exact Entry binding exists → compatible
missing Entry binding      → temporally incompatible
```

No identity-only fallback inside that declared World coverage.

For the fixed-1287 fantasy family, explicit bindings must reflect the authored compatible Entry set rather than guessed same-family compatibility.

### Model freedom

No convergence force and no divergence force.

Do not add canon probability, divergence score, anti-history state machine, fixed output format/length or forced personality transition table.

### No future cues hidden inside warnings

Runtime-visible prose must preserve current facts/pressures and generic authority boundaries, not enumerate future answers merely to prohibit them.

### Selection metadata != model context

`catalog_summary`, `display_name`, `entry_id`, `profile_id`, etc. are selection/index/diagnostic metadata and are **not automatic prompt strings**.

Do not dump the manifest into the Prompt.

### Disclosure != knowledge

`gm_reference` means ordinary GM-authored reference, **not player-known**.

`gm_private` means explicit backstage/secret Source truth; it becomes Character knowledge only through real Game-local evidence and propagation.

### Complex abilities do not force a universal mechanic schema

Character ability/skill/spell tables may remain rich Markdown Source semantics when no deterministic mechanic consumer needs a machine ontology.

A spell list describes current authored familiarity; it is not a whitelist of all future magical possibility.

### Game-local evolvability

> **Source schema is not the possibility ceiling of the Living World.**

Post-T0 semantics may evolve in the Game while Source/global contract/physical SQLite schema remain protected. Existing canonical Domain owners win over duplicate generic truth. Local semantic evolution must be Timeline/Save/Restore reversible.

---

## Current full-fidelity evidence

### Han family

Root:

`tests/fixtures/g4_02r1/full_fidelity/汉末三国/`

- `天下未定/` — rich World + 12 T0 projections;
- `刘备/` — 7 exact rich T0 profiles;
- `曹操/` — 6 exact rich T0 profiles;
- `孙权/` — 10 exact rich T0 profiles;
- joint family audit: `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`.

### Fantasy family World

Root:

`tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚/`

- 20 rich reference sections;
- 4 private secret sections;
- 3 preserved fixed-1287 Entry snapshots;
- `world_pack.v0.2` manifest;
- mapping/result docs under `docs/source/`.

Earlier G4-05 converted fantasy fixture remains failure/design evidence and is not the full-fidelity candidate.

---

## Current migration order

```text
COMPLETED FIRST FAMILY
1. full Han World temporal/rich decomposition
2. full Han World richness preservation
3. full 刘备 semantics across 7 valid T0 profiles
4. full 曹操 semantics across 6 valid T0 profiles
5. full 孙权 semantics across 10 valid T0 profiles
6. joint Han family audit

COMPLETED SECOND-FAMILY WORLD
7. fixed-1287 诸界余辉 World full fidelity + disclosure pressure

NOW
8. 莉维娅 / 阿德里安 / 杜恩 final fixed-1287 rich profiles
9. fantasy-family original↔migrated no-shrinkage / disclosure / knowledge / complex-ability audit
10. final 2 World + 6 Character package-shape stability decision
11. only then issue narrow Codex v0.2-r2 mechanism packet
```

---

## Remaining exit criteria

G4-02R1 closes only when all are true:

1. 2 World + 6 Character have faithful v0.2-r2 package/content representations;
2. manual original ↔ migrated sampling shows no substantive shrinkage;
3. historical/multi-T0 assets prove no post-T0 canon/personality/action-cue leakage;
4. same/similar developmental-stage pressure proves early Characters remain individually distinct;
5. each materialized Character profile has enough T0-specific starting individuality or explicit evidence-backed deliberate blanks;
6. all shared same-year ordering required by multiple Characters is owned by deterministic World Entry cuts;
7. unsupported Character/Entry combinations fail by explicit temporal coverage, not fallback;
8. any omission has explicit owner/reason;
9. stable IDs / eligibility / optional portrait rules are correct;
10. package shape stops changing under real full-fidelity pressure;
11. Codex implements only the frozen mechanism;
12. loader/library/fingerprint/T0 projection/Compatibility regressions pass IR;
13. G4-07 includes anti-convergence + Narrative-richness + Character-individuality Owner UAT.

G4-05 remains REWORK/HOLD. G4-06+ must not start.
