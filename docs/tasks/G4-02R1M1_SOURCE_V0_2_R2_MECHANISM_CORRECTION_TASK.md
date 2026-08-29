---
title: my world｜G4-02R1M1 Source v0.2-r2 Mechanism Correction
status: ready-for-agent
task_id: G4-02R1M1
type: implementation-correction
owner: Codex
created: 2026-08-29
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: f1950d615864fd0e780764fa1a50cfcbf1a5c507
governance_base: 6ac202eca576496e93eb0f4b317ef5b0bffc7399
parent_task: G4-02R1
semantic_contract: v0.2-r2-frozen
independent_review_owner: GPT
owner_uat_required: false
---

# TASK｜G4-02R1M1｜Source v0.2-r2 Mechanism Correction

Owner: **Codex**  
Formal Code Base: **`f1950d615864fd0e780764fa1a50cfcbf1a5c507`**  
Governance Base: **`6ac202eca576496e93eb0f4b317ef5b0bffc7399`**

Target host:

```text
Godot 4.7.2 Standard / non-.NET Windows x64
GDScript
```

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

This task has **no Owner UAT**. GPT performs Independent Review after Codex returns engineering evidence.

---

## 1. Outcome

Implement the already-frozen **World Pack / Character Card Source v0.2-r2 mechanism** against the real full-fidelity fixtures, without changing their meaning.

The task is complete only when the current Source loader/validator/fingerprint/selection seams can prove:

```text
rich immutable Source package
→ deterministic exact-generation validation/fingerprint
→ exact selected World Entry / Character T0 profile projection
→ explicit temporal compatibility result
→ no fallback / no hidden same-family restriction
```

The mechanism must consume the existing 2 World + 6 Character full-fidelity packages **unchanged**.

This task does not create Game-local materialization or G4-06 Final Create.

---

## 2. Canonical semantic authority｜DO NOT REDESIGN

Before implementation, read current `main` versions of:

- `AGENTS.md`
- `docs/source/World Pack与Character Card合同v0.2_SEMANTIC_FREEZE.md`
- `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
- `docs/source/G4-02R1_T0_CHARACTER_INDIVIDUALITY_ADDENDUM.md`
- `docs/source/G4-02R1_FIXED_T0_MULTI_ENTRY_CHARACTER_BINDING_CLARIFICATION.md`
- `docs/source/G4-02R1_REAL_ASSET_V0_2_R2_MIGRATION_SPEC.md`
- `docs/source/G4-02R1_HAN_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`
- `docs/source/G4-02R1_AFTERGLOW_FAMILY_JOINT_FULL_FIDELITY_AUDIT.md`
- `docs/source/G4-02R1_CROSS_FAMILY_PACKAGE_SHAPE_STABILITY_DECISION.md`

Governance ownership/architecture:

- `Vibe-Coding/my world/architecture/source/G4_SOURCE_SEMANTIC_OWNERSHIP_AND_REAUDIT_DECISION.md`
- `Vibe-Coding/my world/architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`
- `Vibe-Coding/my world/architecture/source/G4_T0_SCOPED_SOURCE_AND_POST_T0_CANON_QUARANTINE_DECISION.md`
- `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

Semantic phase verdict is already:

> **PASS / FROZEN FOR MECHANISM.**

Codex owns implementation mechanism only. If implementation exposes a real semantic ambiguity that cannot be resolved mechanically from the frozen sources, **return BLOCKED to GPT**. Do not silently invent a new semantic rule.

---

## 3. Real full-fidelity fixtures are the primary consumer

Use these actual packages as acceptance evidence, not merely tiny synthetic fixtures.

### 汉末三国

Root:

`tests/fixtures/g4_02r1/full_fidelity/汉末三国/`

Required packages:

- World `天下未定/`
- Character `刘备/`
- Character `曹操/`
- Character `孙权/`

### 诸界余辉

Root:

`tests/fixtures/g4_02r1/full_fidelity/诸界余辉/`

Required packages:

- World `埃瑟维亚/`
- Character `莉维娅/`
- Character `阿德里安/`
- Character `杜恩/`

Do not edit, compress, paraphrase, rename, or regenerate their semantic Markdown/TXT files merely to make implementation easier.

---

## 4. Existing implementation seams｜repair forward

Prefer extending the existing layered Source module rather than creating a parallel loader framework.

Current relevant seams include:

```text
src/source/L0_公理层/Source契约验证器.gd
src/source/L1_器件层/Generation内容指纹器.gd
src/source/L1_器件层/Generation路径与写入器.gd
src/source/L1_器件层/Generation验证加载器.gd
src/source/L1_器件层/Source代际目录.gd
src/source/L2_流程层/Generation不可变映射服务.gd
src/source/L2_流程层/Source包安装服务.gd
src/source/L2_流程层/Source选择服务.gd
src/source/L2_流程层/Source库再验证服务.gd
src/source/L2_流程层/Source库启动校验服务.gd
src/source/L3_外交层/Source合同公开接口.gd
src/source/L3_外交层/Source库公开接口.gd
src/source/L3_外交层/Source选择公开接口.gd
```

At Formal Code Base the public contract seam is still v0.1-oriented. Add the smallest v0.2-r2 projection/compatibility capability needed by current consumers.

Do not rewrite G4-03/G4-05 wholesale if localized repair is sufficient.

---

## 5. Frozen semantic mechanism to implement

### 5.1 World v0.2-r2

Support `world_pack.v0.2`:

```text
thin identity / version / display metadata
+ catalog_summary
+ world_instructions / gm_instructions
+ semantic_sections[]
+ entries[].semantic_sections[]
+ authored_assets[]
```

Each semantic section declares:

```text
section_id
section_type        open semantic hint, not closed enum ontology
title
disclosure          gm_reference | gm_private
content_path        safe package-local UTF-8 Markdown/TXT path
```

Selected World Source Projection:

```text
top-level semantic_sections
+
exact selected Entry.semantic_sections
```

Other Entry sections remain part of the immutable generation and fingerprint, but are excluded from that selected projection.

### 5.2 Character v0.2-r2

Support `character_card.v0.2`:

```text
thin identity / version / display metadata
+ catalog_summary
+ top-level semantic_sections[]
+ t0_profiles[]
+ optional portrait
+ player_character_supported
```

Each profile may declare:

```text
profile_id
display_name
bindings[{world_asset_id, entry_id}]
semantic_sections[]
```

Selected Character Source Projection:

```text
top-level semantic_sections
+
exact matching T0 profile.semantic_sections
```

Never implement:

```text
latest profile fallback
nearest-year fallback
later-profile fallback
complete-life biography fallback
display-name/year/provider-history guessing
```

### 5.3 Closed per-World coverage

If a Character declares **any** T0 binding to selected World W:

```text
exact selected Entry binding exists → compatible
binding missing                      → hard temporal incompatibility
```

If a Character declares **zero** profile bindings to selected World W:

```text
NOT hard temporal incompatibility by this rule
```

Preserve an explicit result that can distinguish:

- exact profile match;
- no profile coverage for this World / always-safe-only route;
- declared-World coverage but selected Entry missing = temporal incompatibility.

Do not introduce a same-family restriction.

### 5.4 Same-T0 multiple Entry bindings

`world.ashtervia.afterglow` has three 1287 Entries. Each of 莉维娅 / 阿德里安 / 杜恩 has one 1287 profile binding all three.

Binding means authored starting compatibility. It does **not** mean:

- current location;
- opening appearance;
- current contract;
- recommended-scene score;
- current relationship to Player.

### 5.5 Disclosure

Preserve `gm_reference` / `gm_private` metadata exactly.

The Source mechanism does **not** infer player knowledge from disclosure.

This task need not build a new general Context Retrieval system. It must, however, return enough structured projection data that a later Context consumer does not need to parse the full package manifest or read unselected sections.

---

## 6. Exact generation / fingerprint requirements

Exact generation fingerprint must remain deterministic and content-sensitive over **all declared package bytes**, including:

- canonical manifest;
- top-level semantic section content files;
- all Entry-scoped semantic section files, including unselected Entries;
- all Character T0 profile section files, including unselected profiles;
- authored assets;
- optional portrait when declared/present.

Invariant:

> **Fingerprint coverage != Runtime visibility.**

A private or unselected file must still change the generation fingerprint when bytes change, even though it is excluded from a different selected projection.

Missing, unreadable, unsafe, escaping, or tampered declared content must fail loud; do not silently drop it from the generation.

---

## 7. Validation requirements

Validator/loader must fail loud on at least:

- unsupported/invalid required v0.2 shape;
- unsafe/escaping `content_path`;
- declared missing section file;
- invalid UTF-8/read failure where applicable;
- duplicate package-wide `section_id` across top-level and nested Entry/profile sections;
- duplicate Character `profile_id`;
- binding with empty `world_asset_id` or `entry_id`;
- duplicate exact Character binding `(world_asset_id, entry_id)`;
- invalid disclosure value;
- declared asset/portrait path violation;
- existing v0.1 forbidden live-state fields/regressions that remain applicable.

Do not validate `section_type` as a giant closed ontology.

Do not attempt to semantically score whether prose is “good enough”.

---

## 8. Acceptance matrix｜must be proven

### A. Full-fidelity load

All 2 World + 6 Character packages validate/load **without editing semantic fixture content**.

### B. World exact projection

For Han, selecting an early Entry returns top-level + that exact Entry's section inventory/content and excludes later Entry-only sections/markers.

For Afterglow, selecting each of the three 1287 Entries returns top-level + its exact snapshot and excludes the other two Entry snapshots.

Assertions must inspect actual projection inventory/content, not only row counts.

### C. Character exact projection

Han Character selected projection returns only top-level + exact matching profile.

Prove no later profile content enters an earlier selection.

### D. Closed temporal coverage

At minimum prove:

```text
刘备
- supported through authored 220 binding
- 229+ selected Han Entry → temporal incompatibility

曹操
- supported through authored 214 binding
- 220+ selected Han Entry → temporal incompatibility

孙权
- supported through authored 249 binding
- 263 / 280 → temporal incompatibility
```

### E. Afterglow same-T0 compatibility

For each of 莉维娅 / 阿德里安 / 杜恩:

```text
ovista       → exact 1287 profile match
border-route → exact 1287 profile match
public-works → exact 1287 profile match
```

No location/recommendation restriction may be invented.

### F. Cross-world zero-coverage route

A Character with no bindings to selected World must **not** be hard-blocked by an invented family rule.

Return a distinguishable no-exact-profile / always-safe-only state for later Compatibility policy.

### G. Fingerprint vs visibility

Prove all of the following separately:

1. mutate bytes in an unselected Entry/profile section → generation fingerprint changes;
2. mutate bytes in a `gm_private` section → generation fingerprint changes;
3. selected projection that should exclude that file still excludes it;
4. disclosure metadata is preserved in included section records.

### H. Tamper / missing file failure

Delete/tamper a declared rich file after install/staging in the relevant test seam and prove revalidation/load fails loud rather than silently shrinking the Source.

### I. Optional portrait

Character packages with no portrait must validate/load successfully. Do not create placeholder portrait bytes.

---

## 9. G4-03 regression｜must stay green

G4-03 remains PASS/CLOSED unless a concrete corrected-contract regression is found.

Re-run and preserve its real invariants:

- managed Source Library root/lifecycle;
- staged verified publish;
- append-only immutable generations;
- explicit current generation;
- restart truth;
- exact fingerprint identity;
- missing/tampered generation fail-loud;
- existing Game/source selection can still resolve exact old generation;
- no silent mutation of old generation.

If v0.2-r2 requires localized Library repair, repair forward and document it. Do not redesign the Library.

---

## 10. G4-05 preserved Wizard/Composition regression｜must stay green

G4-05 itself remains **REWORK / HOLD**. This task only proves the preserved engineering seams still work with corrected Source mechanics.

At minimum re-prove:

- chooser visibility/focus != selection;
- only explicit click selects exact generation;
- composition stores exact generation identity;
- selected X does not drift to newer current Y;
- changing World clears dependent Entry;
- Player Character eligibility still enforced;
- same exact Character cannot be both Player + Guaranteed NPC;
- Review exact re-resolve still fail-loud on missing/tamper;
- Wizard→Review creates no Game SQLite;
- Wizard→Review does not mutate Game Library;
- Wizard→Review makes no Provider call;
- Cancel returns Main Menu/no Session;
- no same-family restriction is introduced;
- Expansion remains honest none-only in G4-05.

Do not resume/close G4-05 as part of this task.

---

## 11. Non-scope / forbidden work

Do **not**:

- edit/compress/paraphrase the frozen full-fidelity semantic fixtures;
- redesign Source semantics or Character bindings;
- turn `section_type` into a universal ontology;
- introduce universal skill/spell/nation/god/personality schema merely to parse prose/tables;
- restore generic `source_material`;
- add same-family compatibility restriction;
- implement Expansion Pack runtime semantics;
- implement G4-06 Final Create/materialization;
- build Creator/platform/importer framework;
- build generic legacy auto-compressor/importer;
- perform broad Prompt/Context refactor beyond the selected-projection seam needed here;
- add fake/placeholder Source portraits;
- destructively roll back G4-03/G4-04/G4-05 engineering history;
- silently migrate/rename stable `ashtervia` asset IDs.

If one of these appears necessary, stop and return **BLOCKED** with concrete evidence.

---

## 12. Suggested implementation shape｜non-authoritative

Prefer the smallest correction to existing layers:

```text
L0 validator
→ understands v0.2 manifests/nested sections/bindings/uniqueness

L1 verified loader/fingerprint
→ reads all declared bytes safely and fingerprints them

L2 selection/projection service
→ resolves exact Entry/profile and compatibility state

L3 public seam
→ exposes validated package + selected projection/compatibility to current consumers
```

Exact class/function names are Codex-owned mechanism decisions.

Do not create parallel duplicate Source stacks when existing seams can be extended.

---

## 13. Evidence deliverable

Create/update:

`docs/source/G4-02R1_R2_MECHANISM_IMPLEMENTATION_EVIDENCE.md`

It must record at minimum:

- Formal Code Base;
- implementation commit(s);
- files changed and why;
- exact validation/test commands;
- Godot/Windows execution evidence;
- 2 World + 6 Character real-fixture results;
- selected projection positive/negative assertions;
- closed-coverage incompatibility assertions;
- cross-world zero-coverage assertion;
- fingerprint-vs-visibility mutation evidence;
- tamper/missing failure evidence;
- G4-03 regression evidence;
- G4-05 preserved-mechanics regression evidence;
- any known limitation or deferred work.

Do not use “all tests pass” as the only evidence. State what each important assertion proves.

---

## 14. Independent Review gate

Codex return state maximum:

> **READY FOR INDEPENDENT REVIEW**

GPT Independent Review will inspect, not merely trust, the evidence and implementation.

IR will specifically verify:

- tests assert actual selected projection contents, not just fixture existence/count;
- real full-fidelity packages are used, not only tiny mocks;
- private/unselected bytes remain fingerprinted while staying out of wrong selected projection;
- no latest/nearest/later/full-life fallback exists;
- closed coverage is enforced exactly where authored;
- cross-world zero-coverage is not converted to a same-family hard block;
- G4-03 lifecycle/tamper invariants remain real;
- G4-05 accepted Wizard/Composition behavior still holds;
- semantic fixtures were not quietly rewritten to fit code.

Engineering PASS from IR will still not equal Product PASS for later playable stages.

---

## 15. Git protocol

1. Start from exactly Formal Code Base `f1950d615864fd0e780764fa1a50cfcbf1a5c507` plus this repository-native task packet/governance-only follow-up commits on `main` as task instructions. Do not reinterpret later unrelated code drift as the formal baseline without surfacing it.
2. Before editing, inspect `git status`, current HEAD, and relevant existing tests/source seams.
3. Preserve unrelated work. No destructive reset/clean of unknown changes.
4. Commit implementation and evidence to `main` using focused commits.
5. Do not amend/rewrite historical PASS commits.
6. Before return, report exact final HEAD and changed paths.

If current implementation code has materially drifted from Formal Code Base before implementation begins, stop and report the drift rather than silently changing the task baseline.

---

## 16. Return protocol

Return a concise structured report containing:

```text
Task: G4-02R1M1
State: READY FOR INDEPENDENT REVIEW | BLOCKED
Formal Code Base: f1950d615864fd0e780764fa1a50cfcbf1a5c507
Start HEAD:
Final HEAD:
Implementation commits:
Evidence doc:
Tests/commands:
Real-fixture proof:
G4-03 regression:
G4-05 regression:
Known limitations:
```

Do not declare G4-02R1 closed. Do not declare G4-05 resumed or closed.
