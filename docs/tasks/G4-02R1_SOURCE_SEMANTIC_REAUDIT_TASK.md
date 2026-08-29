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
current_subtask: gpt-fixed-1287-fantasy-world-and-three-character-full-fidelity-migration
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
- 汉末三国 family joint no-shrinkage / differentiation / temporal coverage / ownership / future-cue audit: **PASS-candidate**.

Current:

> **Second real-family pressure: fixed-1287 诸界余辉 World + 莉维娅·塞兰 / 阿德里安·维尔克 / 杜恩·石痕 full-fidelity rich semantics.**

Still NOT proven:

- final full-fidelity `诸界余辉` World;
- final fixed-1287 rich profiles for 莉维娅 / 阿德里安 / 杜恩;
- second-family original ↔ migrated no-shrinkage audit;
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

A later Character profile must not be an unchanged full-life personality with only year/title/status replaced.

### Character individuality

> **Age/development stage is a capability boundary, not a personality template.**

Every materialized T0 Character needs enough character-specific starting individuality for the GM to answer why this person starts differently from another same-age/same-stage person.

If source evidence is sparse, authored `reasonable inference / original completion` is allowed only when:

- explicitly not presented as attested fact;
- compatible with pre-T0 ecology;
- not selected mainly because it predicts the famous adult;
- revisable by Game-local lived history.

Checks:

- developmental-scale individuality;
- no adult-stereotype backfill;
- counterfactual-adult test;
- multi-future test.

Do not create a rigid personality schema or numeric difference score.

### Shared Entry cut ownership

If multiple Characters depend on the ordering of the same world event, **World Entry owns the shared cut**.

Character profiles consume the World cut; they do not maintain private alternative timelines.

Current critical cuts:

```text
189
central rupture already happened;
individual post-cut responses remain open.

196
emperor already at Xu;
Lü Bu already seized Xiapi;
Liu Bei already lost that core base and is in a fragile Xiaopei arrangement;
subsequent conflict/relationship chain remains open.

200
Sun Ce already dead;
Sun Quan just succeeded;
Cao Cao's eastern defeat of Liu Bei already past for current Liu/Cao states;
Liu Bei already in Yuan Shao's network;
decisive current northern contest result remains open.
```

### Closed per-World Character coverage

If a Character declares any `t0_profiles` binding to World W:

```text
exact Entry binding exists → compatible
missing Entry binding      → temporally incompatible
```

No identity-only fallback inside that declared World coverage.

### Model freedom

No convergence force and no divergence force.

Do not add:

- canon probability;
- divergence score;
- anti-history state machine;
- fixed output format/length;
- forced personality transition table.

Current causality may naturally reproduce canon. If premises change, canon has no privilege.

### No future cues hidden inside warnings

Runtime-visible prose must not enumerate future answers or canon-shaped next actions merely to say they are not guaranteed.

Write:

```text
past facts + current pressure + generic authority boundary
```

not:

```text
here are the historical next steps, but please do not follow them
```

### Selection metadata != model context

`catalog_summary`, `display_name`, `entry_id`, `profile_id`, etc. are selection/index/diagnostic metadata and are **not automatic prompt strings**.

Do not dump the manifest into the Prompt.

### Game-local evolvability

> **Source schema is not the possibility ceiling of the Living World.**

Post-T0 semantics may evolve in the Game while Source/global contract/physical SQLite schema remain protected. Existing canonical Domain owners win over duplicate generic truth. Local semantic evolution must be Timeline/Save/Restore reversible.

---

## Current pressure fixtures

Han full-fidelity evidence root:

`tests/fixtures/g4_02r1/full_fidelity/汉末三国/`

Key evidence:

- `天下未定/` — full rich World + 12 T0 projections;
- `刘备/` — 7 exact rich T0 profiles;
- `曹操/` — 6 exact rich T0 profiles;
- `孙权/` — 10 exact rich T0 profiles;
- `world_projection_expectations.json`;
- `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`.

Earlier `tests/fixtures/g4_02r1/t0_pressure/汉末三国/` remains pressure-design evidence, not the final rich Han candidate.

---

## Current migration order

```text
COMPLETED FIRST FAMILY
1. full Han World temporal/rich decomposition
2. full Han geography / institutions / society / material life / evidence hierarchy / ordinary-person scale preservation
3. full original 刘备 semantics across 7 valid T0 profiles
4. full original 曹操 semantics across 6 valid T0 profiles
5. full original 孙权 semantics across 10 valid T0 profiles
6. joint Han original↔migrated fidelity / temporal / individuality / ownership audit

NOW
7. fixed-1287 诸界余辉 World full fidelity
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
