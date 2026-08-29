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
historical_engineering_base: d8405e046ee2134361ec7ab1257f98c7a86c24a8
current_implementation_candidate: 145c3e1192b443f6284da7f36aee74619adad5bf
historical_real_asset_repo: zhangchenjia21-dot/sillytavern-assets
historical_real_asset_sha: 4a5364a042e41f4c8a69621fc4467956a78703c0
codex_active: false
semantic_audit: complete
semantic_contract: v0.2-r2-frozen-implementation-pending
current_subtask: gpt-t0-temporal-pressure-remigration
---

# TASK｜G4-02R1｜World / Character Source Semantic Re-audit

Owner: **GPT**

This task reopens the semantic adequacy of the G4-02 Source contract without rolling back verified engineering history.

## Outcome

Using real `汉末三国` and `诸界余辉` assets as primary evidence, freeze and prove the smallest Source contract that can faithfully carry reusable authored World / Character semantics without importing legacy host debt, Game-local live state, a giant schema forest, or post-T0 canon that biases ordinary Runtime toward source convergence.

## Current state｜2026-08-29

Completed:

- real-source semantic audit against 2 World + 6 Character;
- v0.1 semantic verdict: **NOT ADEQUATE**;
- v0.2 base semantic contract freeze;
- Game-local evolvable semantics architecture decision;
- T0-scoped Source / Post-T0 Canon Quarantine architecture decision;
- v0.2 revision-2 T0-scoped Source contract addendum;
- v0.2-r2 real-asset migration specification;
- model-freedom self-check: PASS.

Current:

> **GPT-owned temporal pressure remigration: 孙权 + 汉末三国 World first.**

Codex still has **no active task**.

Formal outputs:

- `docs/source/G4-02R1_SOURCE_SEMANTIC_AUDIT.md`
- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`
- governance: `architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`
- governance: `architecture/source/G4_T0_SCOPED_SOURCE_AND_POST_T0_CANON_QUARANTINE_DECISION.md`

Historical r1 migration spec:

`docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md` — **SUPERSEDED / design evidence only**.

## Required evidence

Historical snapshot, read-only:

`zhangchenjia21-dot/sillytavern-assets@4a5364a042e41f4c8a69621fc4467956a78703c0`

Required real assets:

- `世界包/汉末三国_天下未定_World_Pack_v0.2.3.md`
- `世界包/埃瑟维亚_诸界余辉_World_Pack_v0.1.3.md`
- 刘备、曹操、孙权、莉维娅·塞兰、阿德里安·维尔克、杜恩·石痕

## Frozen semantic verdict

### Character v0.1

FAIL as a semantic contract because `summary/traits/background/drives` causes real authored identity/personality/capability/behavior/relationship/autonomy/expression/knowledge/T0 semantics to collapse into compact summaries. Required portrait also creates pressure to fake visuals.

### World v0.1

FAIL as a semantic contract because rich content lacks section-level disclosure/retrieval semantics and mandatory arbitrary `source_material` is an unproven catch-all / hidden-schema escape hatch.

### v0.2 base direction

```text
thin identity
+ catalog summary
+ compact always-on instructions where appropriate
+ ordered rich semantic sections
+ gm_reference / gm_private disclosure
+ package-local Markdown/TXT content files
+ exact fingerprint over all declared bytes
```

No universal giant schema. No full-asset prompt dump. No machine skill/spell ontology until a real consumer needs it.

## T0-scoped v0.2-r2 correction

DSH long-play evidence exposed a second semantic risk:

> **Prompt-only “future is open” rules are insufficient when ordinary GM Context can still read the post-T0 answer.**

Formal invariant:

> **Do not show the model a post-T0 answer and then ask it to forget that answer.**

Must distinguish:

```text
Source Package Total Content
!= Selected T0 Projection
!= Game-local Canonical Reality
!= Runtime Relevant Set
!= Model-visible Working Set
```

### World

- top-level sections = always-safe across supported T0s;
- Entry may own Entry-scoped rich sections;
- current Runtime projection = always-safe + selected Entry sections only;
- later Entry material remains quarantined.

### Character

- top-level sections = always-safe;
- optional `t0_profiles[]` bind authored rich sections to explicit `world_asset_id + entry_id`;
- current Runtime projection = always-safe + exact matching profile only;
- no matching profile may not fallback to latest/nearest/later/complete-life biography;
- all profiles remain one stable Character `asset_id`.

### No convergence force / no divergence force

Do not implement canon-following probability, divergence score, fate-convergence strength or forced anti-history randomness.

Current causality may naturally reproduce canon. If premises change, canon has no convergence privilege.

Randomness applies to current uncertainty/actors/resources/events, not to a lottery over “follow history vs diverge”.

### Model freedom guardrail

T0 quarantine is Context/authority control, not Narrative control.

Do not add:

- fixed output length/format;
- anti-history checklist/state machine;
- forced divergence;
- personality transition table replacing model judgment.

T0 profile must preserve rich present depth: personality inertia, pre-T0 experience, capabilities/limitations, relationships, knowledge provenance, institutions/resources/geography and open goals.

> **Quarantine future answers; preserve present depth.**

Provider pretrained/external post-T0 canon has no authority as current Game fact, character motive or future prediction unless an explicit in-game Knowledge/Historical Reference owner introduces it.

## Game-local evolvability requirement

Owner explicitly approved:

> **Source schema is not the possibility ceiling of the Living World. Game-local semantic structure is evolvable.**

Constraints:

- Source immutable;
- Program-owned game-local identity/provenance/lifecycle kernel stable;
- model/runtime may evolve local open semantics;
- model cannot rewrite Source/global contract or physical SQLite schema;
- existing formal Domain wins over duplicate generic facet;
- local semantic evolution must be durable and Timeline/Save/Restore reversible;
- repeated open semantics become formal Domain only after a real consumer appears.

T0 quarantine and local evolvability are complementary: future answers are hidden; future creative capacity remains open.

## Migration requirement

Current canonical migration specification:

`docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`

Rule:

> **preserve → re-home → T0-scope → explicitly omit only when owner is wrong.**

For each real package:

- preserve substantive original chapters/tables/examples/limitations;
- preserve GM-private truth with correct disclosure;
- preserve T0/future-open/player-takeover boundaries;
- preserve stable pre-T0 relationship hooks without turning them into current relation state;
- omit only legacy repo/host mechanics and live Game state;
- do not fabricate missing portraits;
- do not use compact summary as fidelity substitute;
- do not expose post-T0 later biography/result to an earlier T0 Runtime projection;
- preserve existing stable asset IDs; do not rename `ashtervia` identities during this correction.

Current pressure order:

```text
1. 孙权 — early/late personality isolation
2. 汉末三国 World — Entry-scoped historical/world truth isolation
3. 刘备 / 曹操 temporal re-audit
4. 诸界余辉 fixed-1287 assets
```

Already-created pre-r2 fixtures are evidence only until they pass this temporal leakage review.

## Design constraints

- `Narrative richness over artificial brevity.`
- `Model freedom first.`
- `玩法应该拉出 Schema；不要让玩法迁就先写好的万能 Schema。`
- `System Total State != Runtime Relevant Set != Model-visible Working Set.`
- `Source Package Total Content != Selected T0 Projection.`
- `Consumer before abstraction.`
- Do not create a universal giant Asset schema.
- Do not move current location/relationship/injury/current knowledge/inventory/player-known/opening placement into Source.
- Do not create a production legacy importer.
- Do not use post-T0 canon as ordinary Runtime future truth.
- Do not solve canon leakage with anti-history Narrative restrictions.
- Because the product is unreleased, correct v0.1/v0.2-r1 directly rather than building a compatibility forest.

## Preservation / no rollback

Do not revert G4-03, G4-04 or the accepted portions of G4-05.

- G4-03 remains PASS unless v0.2-r2 exposes a concrete Library regression; then repair forward.
- G4-04 remains PASS/CLOSED.
- G4-05 Wizard/Composition implementation candidate `145c3e1` remains provisional engineering evidence; G4-05 itself stays REWORK/HOLD.

## Superseded task

`docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md` is **SUPERSEDED / DO NOT EXECUTE**. Codex has no active task during GPT semantic/content work.

## Remaining exit criteria

G4-02R1 closes only when all are true:

1. 2 World + 6 Character have faithful v0.2-r2 package/content representations under GPT semantic ownership;
2. manual original ↔ migrated sampling shows no substantive shrinkage;
3. historical/multi-T0 assets prove no post-T0 canon/personality leakage into earlier projection;
4. any omission has explicit owner/reason;
5. v0.2-r2 exact content shape is stable enough to hand to engineering;
6. if code changes are required, a narrow Codex packet is issued from the frozen contract/package evidence;
7. after Codex returns, loader/library regressions, exact fingerprint, T0 projection exclusion and content fidelity pass Independent Review;
8. G4-07 acceptance plan includes anti-convergence Product UAT and Narrative richness negative-control.

Do not start G4-06 before G4-05 is later revalidated and closed.
