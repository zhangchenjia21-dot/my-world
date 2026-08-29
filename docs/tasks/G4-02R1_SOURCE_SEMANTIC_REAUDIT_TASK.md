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
current_subtask: gpt-han-full-fidelity-early-individuality-and-liu-cao-temporal-remigration
---

# TASK｜G4-02R1｜World / Character Source Semantic Re-audit

Owner: **GPT**

## Outcome

Using real `汉末三国` and `诸界余辉` assets as primary evidence, prove the smallest Source contract that preserves authored richness, keeps Game-local live truth separate, prevents post-T0 canon/personality leakage, preserves T0 character individuality, and still leaves post-T0 world/character development open to the model.

Codex has **no active task** until the real v0.2-r2 package shape/content is stable.

---

## Current state｜2026-08-29

Completed:

- real-source semantic audit against 2 World + 6 Character;
- v0.1 semantic adequacy verdict: **FAIL**;
- v0.2 base rich-section semantic freeze;
- Game-local evolvable semantics decision;
- T0-scoped Source / Post-T0 Canon Quarantine decision;
- v0.2-r2 T0 addendum;
- model-freedom self-check: **PASS**;
- first real temporal pressure: **孙权 + 汉末三国 temporal isolation = PASS at semantic/data level**;
- `汉末三国` 12 authored fixed Entry temporal skeleton restored;
- 孙权 10 in-life Entry profiles restored for 184/189/196/200/208/214/220/229/234/249;
- 孙权 263/280 intentionally has no binding → closed-coverage temporal incompatibility;
- owner requirement added: early/same-stage Characters must preserve distinct starting individuality instead of collapsing into generic age templates.

Current open correction:

> **184/189 孙权已经证明“不倒灌成年未来”，但尚未证明“与其它同阶段儿童有充分个体区分”。Early individuality = NOT YET PROVEN.**

Current:

> **GPT full-fidelity Han World layer + early-character individuality correction + 刘备/曹操 temporal re-audit/migration.**

Still NOT proven:

- same/similar developmental-stage cross-character differentiation pressure;
- Godot v0.2-r2 loader/validator/fingerprint;
- actual Compatibility Review temporal blocking;
- actual Context Assembly exclusion of unselected later content/unsafe metadata;
- final full-fidelity 2 World + 6 Character packages;
- real Provider anti-convergence UAT.

---

## Canonical sources

Read current:

- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_T0_CHARACTER_INDIVIDUALITY_ADDENDUM.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`
- `docs/source/G4-02R1_SUN_QUAN_HAN_WORLD_T0_PRESSURE_AUDIT.md`
- `docs/source/G4-02R1_SUN_QUAN_HAN_WORLD_T0_PRESSURE_RESULT.md`
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

World:

```text
top-level always-safe sections
+ selected Entry-scoped sections
```

Character:

```text
top-level always-safe sections
+ exact matching T0 profile
```

Never fallback to latest/nearest/later/complete-life biography.

### T0 character individuality

> **Age/development stage is a capability boundary, not a personality template.**

Future quarantine must not homogenize early Characters.

Every materialized T0 Character needs enough character-specific starting individuality for the GM to answer why this person starts differently from another same-age/same-stage person.

Use, where available:

- pre-T0 family/social position and lived experience;
- attachments, role models, education and socialization;
- already-observable temperament/interests/fears/habits;
- age-appropriate abilities and limitations;
- knowledge provenance and blind spots;
- open internal tensions / deliberate blanks.

If historical/canon evidence is sparse, authored `reasonable inference / original completion` is allowed when explicitly treated as such, consistent with current T0 conditions, not derived from later-life outcomes, and fully revisable by Game-local lived history.

Do not solve this with a rigid personality schema or a numeric difference score.

### Entry temporal sufficiency

A year/display label alone is not sufficient if a same-year high-impact event changes identity/power/existence. The Entry must clarify whether that event is already-past or still-open-future before dependent profiles bind.

Current conversion clarification:

```text
200 Entry
孙策已经身亡
孙权刚接掌江东
当前北方主战决定性胜负尚未成为过去
```

### Closed per-World Character coverage

If a Character declares any `t0_profiles` binding to World W:

```text
exact Entry binding exists → compatible
missing Entry binding      → temporally incompatible
```

This prevents a dead/not-yet-valid Character from being resurrected by always-safe fallback without creating a universal lifecycle enum.

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

Runtime-visible prose must not enumerate future answers merely to say “do not use them”. Use generic authority language instead.

### Selection metadata != model context

`catalog_summary`, `display_name`, `entry_id`, `profile_id`, etc. are selection/index/diagnostic metadata and are **not automatic prompt strings**.

Player-facing historical labels may remain useful in New Game UI, while Runtime model material is assembled from explicitly eligible semantic content + deliberately selected temporally-safe metadata + Game-local Reality.

Do not dump the manifest into the Prompt.

### Game-local evolvability

> **Source schema is not the possibility ceiling of the Living World.**

Post-T0 semantics may evolve in the Game while Source/global contract/physical SQLite schema remain protected. Existing canonical Domain owners win over duplicate generic truth. Local semantic evolution must be Timeline/Save/Restore reversible.

---

## Current real pressure evidence

Fixture:

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/`

World temporal skeleton now contains all 12 original fixed Entries:

```text
184  黄巾大乱
189  洛阳巨变
196  天子至许
200  官渡前夕
208  赤壁前夕
214  益州易主
220  汉魏鼎革
229  三国鼎立
234  五丈原时代
249  高平陵之变时代
263  蜀汉存亡前夕
280  吴亡前夕
```

This is not yet the full 53KB World fidelity migration; it proves temporal ownership/cuts.

孙权 current profile coverage:

```text
184  child
189  child
196  adolescent / family political environment
200  newly succeeded ruler
208  years of earned rule
214  mature long-running ruler
220  ~20 years of earned rule
229  emperor + decades of earned rule
234  mature institutional ruler
249  current succession/faction pressure legitimately enters profile
263  no binding → incompatible
280  no binding → incompatible
```

Important pressure lesson:

> A semantic dimension quarantined at early T0 may legitimately appear later once lived history has actually produced it. Quarantine delays authority; it does not erase character development.

New owner pressure lesson:

> A semantic dimension absent because it belongs to the future must not be replaced by a generic age template. Early Characters still require distinct present individuality.

Projection expectations:

`tests/fixtures/g4_02r1/t0_pressure/汉末三国/projection_expectations.json`

---

## Current migration order

```text
NOW
1. correct / strengthen 184/189 Sun Quan early individuality without future leakage
2. add same/similar-stage cross-character differentiation pressure
3. complete full-fidelity 汉末三国 World sections under the 12-entry temporal skeleton
4. re-audit / migrate 刘备 across valid Entries
5. re-audit / migrate 曹操 across valid Entries

THEN
6. fixed-1287 诸界余辉 World full fidelity
7. 莉维娅 / 阿德里安 / 杜恩 final fixed-1287 profiles
8. manual original ↔ migrated fidelity + temporal leak + individuality audit
9. freeze exact package shape
10. issue narrow Codex v0.2-r2 mechanism packet
```

---

## Remaining exit criteria

G4-02R1 closes only when all are true:

1. 2 World + 6 Character have faithful v0.2-r2 package/content representations;
2. manual original ↔ migrated sampling shows no substantive shrinkage;
3. historical/multi-T0 assets prove no post-T0 canon/personality leakage;
4. at least one same/similar developmental-stage cross-character pressure proves early Characters remain individually distinct without future-canon backfill;
5. each materialized Character profile has enough T0-specific starting individuality or explicit evidence-backed deliberate blanks;
6. any omission has explicit owner/reason;
7. stable IDs / eligibility / optional portrait rules are correct;
8. package shape stops changing under real pressure;
9. Codex implements only the frozen mechanism;
10. loader/library/fingerprint/T0 projection/Compatibility regressions pass IR;
11. G4-07 includes anti-convergence + Narrative-richness + Character-individuality Owner UAT.

G4-05 remains REWORK/HOLD. G4-06+ must not start.