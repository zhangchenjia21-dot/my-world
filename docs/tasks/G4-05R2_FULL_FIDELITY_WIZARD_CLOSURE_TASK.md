---
title: my world｜G4-05R2 Full-Fidelity New Game Wizard Closure
task_id: G4-05R2
type: frontend-product-integration
status: ready-for-agent
owner: Kimi
independent_review_owner: GPT
created: 2026-08-30
updated: 2026-08-30
repository: zhangchenjia21-dot/my-world
branch: main
formal_code_base: 1d8278f9a4bc33a748eb6444873af85d27d5a755
governance_base: 32e7357d2eb86b6788d1a429b0dd97f2ba4a2caa
parent_task: G4-05
owner_uat_required: false
return_ceiling: READY FOR INDEPENDENT REVIEW
---

# TASK｜G4-05R2｜Full-Fidelity New Game Wizard Closure

Primary execution owner: **Kimi**  
Primary task nature: **frontend / UI / interaction integration**  
Formal Code Base: **`1d8278f9a4bc33a748eb6444873af85d27d5a755`**  
Governance Base: **`32e7357d2eb86b6788d1a429b0dd97f2ba4a2caa`**

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Do not announce G4-05 PASS/CLOSED. GPT performs Independent Review after return.

---

## 1. Outcome

Close the remaining product-integration gap in G4-05 by making the existing New Game Wizard use and present the **current frozen Source v0.2 full-fidelity assets directly**.

Required product path:

```text
Application Launch
→ Main Menu
→ New Game
→ choose exact World
→ choose optional opening Entry
→ explicit Expansion none
→ choose exact Player Character
→ choose 0..N Guaranteed NPC Sources
→ minimal settings
→ Compatibility Review
→ STOP before Final Create
```

G4-05 already has working Composition/backend mechanics. This task is not a rewrite. It rebases the player-facing Wizard from obsolete v0.1 converted reality fixtures onto the accepted v0.2 Source model and corrects generic UI language so both temporal and non-temporal Sources fit naturally.

---

## 2. Why now

G4-02R1 is **PASS / CLOSED** after Source v0.2-r2 mechanism implementation and GPT Independent Review.

The accepted implementation can already prove:

- exact Source generation selection;
- exact World Entry projection;
- optional Character T0 profiles;
- temporal incompatibility only where authored coverage requires it;
- non-temporal Character/World paths without artificial temporal matrices;
- G4-03 Library invariants;
- preserved G4-05 Composition/Wizard regressions.

The remaining G4-05 problem is that its primary product/reality test still installs old packages from:

`tests/fixtures/g4_05/历史真实资产转换/...`

Those are `world_pack.v0.1` / `character_card.v0.1` conversion artifacts and are no longer the canonical full-fidelity reality pressure.

The current canonical real fixtures are:

`tests/fixtures/g4_02r1/full_fidelity/`

---

## 3. Read first

Minimum required:

1. `AGENTS.md`
2. this packet
3. `src/ui/新游戏向导.gd`
4. `src/ui/新游戏向导.tscn`
5. `src/应用壳.gd`
6. `src/建局/L3_外交层/建局公开接口.gd`
7. `src/source/L3_外交层/Source合同公开接口.gd`
8. `src/source/L3_外交层/Source库公开接口.gd`
9. `tests/g4_05/G4_05测试夹具.gd`
10. `tests/g4_05/应用新游戏向导现实测试.gd`
11. `tests/g4_05/新游戏向导窗口布局测试.gd`
12. `docs/source/G4-02R1_OPTIONAL_TEMPORAL_SCOPE_CAPABILITY_CLARIFICATION.md`
13. `docs/source/G4-02R1_T0_SCOPED_SOURCE_CONTRACT_ADDENDUM.md`
14. `docs/source/G4-02R1_R2_MECHANISM_IMPLEMENTATION_EVIDENCE.md`
15. current governance `MY_WORLD_CURRENT_STATUS.md`
16. governance `AGENT_EXECUTION_ROUTING_CURRENT.md`

Historical packets:

- `docs/tasks/G4-05_ASSET_ONLY_NEW_GAME_WIZARD_TASK.md`
- `docs/tasks/G4-05R1_REAL_ASSET_FIDELITY_CORRECTION_TASK.md`

are reference/history only. **Do not execute their obsolete v0.1 asset-conversion instructions.**

---

## 4. Decision Digest

### DEC-05R2-01｜Primary Wizard reality assets are current v0.2 full-fidelity fixtures

Primary product/reality tests must install directly from the frozen current set:

```text
tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定
tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备
tests/fixtures/g4_02r1/full_fidelity/汉末三国/曹操
tests/fixtures/g4_02r1/full_fidelity/汉末三国/孙权

tests/fixtures/g4_02r1/full_fidelity/诸界余辉/埃瑟维亚
tests/fixtures/g4_02r1/full_fidelity/诸界余辉/莉维娅
tests/fixtures/g4_02r1/full_fidelity/诸界余辉/阿德里安
tests/fixtures/g4_02r1/full_fidelity/诸界余辉/杜恩
```

Do not copy, rewrite, compress, paraphrase or fork these fixtures merely for Wizard tests.

The old G4-05 v0.1 conversion fixtures may remain as historical regression artifacts, but they are no longer the primary acceptance path.

### DEC-05R2-02｜Temporal quarantine is optional, so generic UI must be non-temporal

Do not present `T0` as a universal player-facing concept.

Generic Wizard language should use concepts such as:

- `开局入口`
- `开局场景`
- `所选开局`

Historical assets can naturally show their authored Entry labels such as `184｜黄巾大乱`.

A fantasy/original World with scenario Entries must not look as though it has been forced into a historical timeline mode.

Do not add `historical`, `temporal_mode`, `requires_quarantine`, family mode or any equivalent UI/global switch.

### DEC-05R2-03｜Use `catalog_summary` for chooser comprehension

Source v0.2 `catalog_summary` exists specifically for Source Library / New Game browsing.

World and Character chooser items should make this summary visible/readable enough for a player to understand the choice before clicking.

Do not inject full rich Source prose into the chooser.

Exact generation identity remains authoritative internally. Raw fingerprint/hash should not be the primary player-facing information. Version may be shown subtly; tests may inspect exact identity programmatically.

### DEC-05R2-04｜Guaranteed NPC copy must not imply opening appearance

Current semantics:

> Guaranteed NPC means the player requires that Character Source to belong to the created Game's canonical cast after Final Create.

It does **not** mean opening appearance, same scene, player-known or current relationship.

Prefer player-facing wording equivalent to:

`保证加入本局的 NPC`

rather than wording that implies immediate “登场”. Keep the explanatory hint concise.

### DEC-05R2-05｜Compatibility failures should be understandable without exposing backend jargon

Backend remains authoritative.

For example, if Han 229 + 刘备 returns `character_temporal_incompatible`, the UI should explain plainly that this Character does not have a valid starting profile for the selected opening and the player should change the opening or Character.

Do not expose phrases like `closed T0 coverage`, internal state names or schema terminology as the main player message.

Do not weaken the backend result or auto-fallback to another profile.

---

## 5. Backend invariants｜do not redesign

### INV-05R2-01

Chooser visibility/focus != authoritative selection. Only explicit interaction selects an exact generation.

### INV-05R2-02

Composition remains pinned to exact generation fingerprint selected at click time. Current-generation drift must not replace it.

### INV-05R2-03

Changing World clears dependent Entry selection.

### INV-05R2-04

Player Character is exactly one and must be player-eligible. The exact same Character generation cannot also be Guaranteed NPC.

### INV-05R2-05

Compatibility Review exact-re-resolves selected generations through Managed Source Library and fails loud on missing/tampered data.

### INV-05R2-06

Temporal incompatibility is only authored Source behavior. No same-family restriction and no latest/nearest/later/full-life fallback.

### INV-05R2-07

G4-05 creates no Game SQLite, Game Library record/current, Source materialization, Session or Provider call.

### INV-05R2-08

Final Create remains visibly unavailable / next-stage only. G4-06 is out of scope.

---

## 6. Allowed scope

Primary allowed production paths:

```text
src/ui/新游戏向导.gd
src/ui/新游戏向导.tscn
```

Narrow Application-shell UI wiring may be changed if required:

```text
src/应用壳.gd
src/main.tscn
```

Tests/evidence:

```text
tests/g4_05/**
docs/g4_05/** or existing G4-05 evidence docs
```

Task-owned test helper changes are allowed, including rebasing `G4_05测试夹具.gd` to the v0.2 full-fidelity fixture roots.

---

## 7. Prohibited scope / stop conditions

Do not change backend production code under these areas merely for convenience:

```text
src/source/**
src/建局/**
src/persistence/**
src/runtime/**
src/provider/**
```

Exception: if a concrete frontend integration test proves a real backend defect, **do not silently fix it in this task**. Return:

```text
BLOCKED — BACKEND DEFECT
+ exact reproduction
+ expected vs actual
+ smallest implicated seam
```

GPT will decide whether to wait for Codex, explicitly authorize Kimi backend fallback, or split a new backend packet.

Also do not:

- modify frozen full-fidelity semantic fixtures;
- resurrect old v0.1 conversion as the target;
- create a new Source contract;
- implement Expansion Pack runtime;
- implement G4-06 Final Create;
- create SQLite / canonical Game state;
- call Provider;
- build Creator/importer/platform frameworks;
- add generic historical/temporal mode settings.

---

## 8. Required acceptance gates

### AC-05R2-01｜Current v0.2 inventory reaches Wizard

A primary Wizard reality test must install the frozen 2 World + 6 Character v0.2 packages directly through production Managed Source Library.

Assert:

```text
World count = 2
Character count = 6
all eight schema_version are v0.2 through loaded generation.source
```

No old G4-05 v0.1 conversion package may satisfy this gate.

### AC-05R2-02｜Chooser presents meaningful current Source summaries

At least World and Character chooser surfaces visibly include each selected item's `catalog_summary` or an equivalent direct current Source projection.

Test actual UI text, not merely that `catalog_summary` exists in the loaded object.

### AC-05R2-03｜Generic UI does not impose T0 on every World

Player-facing generic labels/hints for the opening-selection step and Review must not universally say `T0`.

Historical Entry display names may contain years or historical wording because that content belongs to the asset.

Add a focused UI assertion using the existing IR01 non-temporal evidence fixtures or an equivalent task-owned path to prove a scenario-style World can be shown without a temporal-mode concept.

### AC-05R2-04｜Compatible Han route reaches valid Review

Use frozen v0.2 real assets through the actual Application/Wizard path.

Example acceptable route:

```text
World: 汉末三国：天下未定
Entry: 208｜赤壁前夕
Player: 刘备
Guaranteed NPC: 曹操 + one zero-world-coverage Character if desired
Settings: valid
```

Review must succeed and show the actual chosen composition.

### AC-05R2-05｜Temporal incompatibility is clear and non-destructive

Use a real incompatible route, e.g.:

```text
World: 汉末三国：天下未定
Entry: 229｜三国鼎立
Player: 刘备
```

Review must:

- fail because backend reports temporal incompatibility;
- show a plain player-understandable message;
- not substitute another Liu Bei profile;
- not create Game/Session/SQLite/Game Library mutation;
- allow the player to go back and change the choice.

### AC-05R2-06｜Afterglow is not treated as historical restriction

Using the frozen Afterglow World and Characters, prove at least one normal Wizard route reaches Review and that no family/time restriction is invented beyond the authored bindings.

### AC-05R2-07｜Guaranteed NPC wording is semantically accurate

UI copy must not promise opening appearance or current relationship.

### AC-05R2-08｜Existing G4-05 mechanics stay green

Re-run at least:

- `建局Composition测试.gd`
- `应用新游戏向导现实测试.gd`
- `新游戏向导窗口布局测试.gd`

and any additional focused G4-05 tests added here.

### AC-05R2-09｜Windows visual evidence

Run the Wizard non-headless on Windows/Godot 4.7.2 and capture evidence at minimum for:

- 1280×720;
- maximized desktop window;
- 960×540.

Check:

- summaries readable;
- buttons/labels do not overlap;
- long Chinese Entry/opening text wraps safely;
- navigation remains reachable;
- Review error and Review success are legible;
- keyboard/focus behavior does not create implicit selection.

### AC-05R2-10｜No G4-06 side effects

Across successful and failed Review routes:

```text
no Game SQLite
no Game Library mutation
no Session runtime
no Provider call
Final Create remains disabled/unimplemented
```

---

## 9. Product Value Acceptance

Engineering PASS alone is not enough for this UI task. Evidence should make it credible that a normal player can understand:

1. what World they are choosing;
2. what opening/scenario they are choosing without needing schema vocabulary;
3. which Character is the Player Character;
4. which NPC Sources are guaranteed to belong to the future Game;
5. why an incompatible historical Character/opening combination cannot proceed;
6. that the current stage is Review only, not actual creation.

This is still not G4-07 Owner UAT. Kimi must not claim overall playability/product PASS.

---

## 10. Validation order

Use focused → regression → Windows visual evidence.

Expected baseline commands include the existing G4-05 Godot tests plus any new focused test created for v0.2 Wizard presentation.

Also run:

```text
Godot editor parse / quit
Git diff check
```

If an existing unrelated environment warning appears, distinguish it from assertion/parse failure in the report.

---

## 11. Git / evidence

Start by recording current `main` / `origin/main` and verifying no unknown dirty work.

Commit implementation/tests separately from evidence docs when practical.

Do not edit or rewrite the frozen full-fidelity fixtures.

Recommended evidence document:

`docs/g4_05/G4-05R2_FULL_FIDELITY_WIZARD_EVIDENCE.md`

---

## 12. Final return format

Return exactly one of:

- `READY FOR INDEPENDENT REVIEW`
- `BLOCKED — BACKEND DEFECT`
- `BLOCKED — AUTHORITY/DRIFT`

Final report must include:

- Start HEAD
- Final HEAD
- commits
- changed production paths
- changed test paths
- proof primary Wizard path uses v0.2 full-fidelity fixtures
- chooser summary evidence
- generic non-T0 UI evidence
- compatible Han Review evidence
- incompatible Han Review evidence
- Afterglow evidence
- responsive/Windows visual evidence
- G4-05 regression results
- no-G4-06-side-effect proof
- whether any backend production code changed (expected: **no**)
- known limitations

Do not close G4-05 yourself.
