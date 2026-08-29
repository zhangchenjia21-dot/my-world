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
semantic_contract: v0.2-frozen-implementation-pending
current_subtask: gpt-real-asset-v0.2-migration
---

# TASK｜G4-02R1｜World / Character Source Semantic Re-audit

Owner: **GPT**

This task reopens the semantic adequacy of the G4-02 Source contract without rolling back verified engineering history.

## Outcome

Using real `汉末三国` and `诸界余辉` assets as primary evidence, freeze and prove the smallest Source contract that can faithfully carry reusable authored World / Character semantics without importing legacy host debt, Game-local live state, or a giant schema forest.

## Current state｜2026-08-29

Completed:

- real-source semantic audit against 2 World + 6 Character;
- v0.1 semantic verdict: **NOT ADEQUATE**;
- v0.2 semantic contract freeze;
- Game-local evolvable semantics architecture decision;
- real-asset v0.2 migration mapping / omission specification.

Current:

> **GPT-owned faithful v0.2 package/content migration.**

Codex still has **no active task**.

Formal outputs:

- `docs/source/G4-02R1_SOURCE_SEMANTIC_AUDIT.md`
- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_MIGRATION_SPEC.md`
- governance: `architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`

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

### v0.2 direction

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

## Migration requirement

Rule:

> **preserve → re-home → explicitly omit only when owner is wrong.**

For each real package:

- preserve substantive original chapters/tables/examples/limitations;
- preserve GM-private truth with correct disclosure;
- preserve T0/future-open/player-takeover boundaries;
- preserve stable pre-T0 relationship hooks without turning them into current relation state;
- omit only legacy repo/host mechanics and live Game state;
- do not fabricate missing portraits;
- do not use compact summary as fidelity substitute.

## Design constraints

- `Narrative richness over artificial brevity.`
- `Model freedom first.`
- `玩法应该拉出 Schema；不要让玩法迁就先写好的万能 Schema。`
- `System Total State != Runtime Relevant Set != Model-visible Working Set.`
- `Consumer before abstraction.`
- Do not create a universal giant Asset schema.
- Do not move current location/relationship/injury/current knowledge/inventory/player-known/opening placement into Source.
- Do not create a production legacy importer.
- Because the product is unreleased, correct v0.1 directly rather than building a compatibility forest.

## Preservation / no rollback

Do not revert G4-03, G4-04 or the accepted portions of G4-05.

- G4-03 remains PASS unless v0.2 exposes a concrete Library regression; then repair forward.
- G4-04 remains PASS/CLOSED.
- G4-05 Wizard/Composition implementation candidate `145c3e1` remains provisional engineering evidence; G4-05 itself stays REWORK/HOLD.

## Superseded task

`docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md` is **SUPERSEDED / DO NOT EXECUTE**. Codex has no active task during GPT semantic/content work.

## Remaining exit criteria

G4-02R1 closes only when all are true:

1. 2 World + 6 Character have faithful v0.2 package/content representations under GPT semantic ownership;
2. manual original ↔ migrated sampling shows no substantive shrinkage;
3. any omission has explicit owner/reason;
4. v0.2 exact content shape is stable enough to hand to engineering;
5. if code changes are required, a narrow Codex packet is issued from the frozen contract/package evidence;
6. after Codex returns, v0.2 loader/library regressions and content fidelity pass Independent Review.

Do not start G4-06 before G4-05 is later revalidated and closed.
