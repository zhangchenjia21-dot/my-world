---
title: G4-02R1M1 Source v0.2-r2 Mechanism Implementation Evidence
status: ready-for-independent-review
task: G4-02R1M1
formal_code_base: f1950d615864fd0e780764fa1a50cfcbf1a5c507
governance_base: e2423cb50800129fc0bff6d1edc31701023f0f28
start_head: 34c4d80acbdc3eed24cad9d8c9e5552941d1869a
ir01_task: G4-02R1M1-IR01
ir01_start_head: 1914880bccfc04477ec81e1dfb4ba4d1a08ff04f
ir01_formal_code_base: 74d1fe8d93e527794db33d0280d76d16674ae1d7
ir01_governance_base: 14fb4d686c458c2a09a348e54088377f96655d65
---

# G4-02R1M1 Source v0.2-r2 Mechanism Implementation Evidence

## 1. Pre-implementation responsibility matrix

| Concern | Owner | Mechanism seam | Explicit non-owner |
|---|---|---|---|
| Source meaning, section ownership, T0 bindings | Frozen GPT semantic fixtures | Read exactly as declared | Codex does not rewrite or infer prose/bindings |
| Manifest shape and hard boundary validation | Source L0/L2 | v0.1-preserving v0.2-r2 validator | No literary scoring or closed `section_type` ontology |
| Declared bytes and exact generation | Source L1 | safe reads plus deterministic SHA-256 | Runtime visibility does not narrow fingerprint coverage |
| Selected World projection | Source L2/L3 | top-level plus exact selected Entry | No later/nearest Entry fallback |
| Selected Character projection | Source L2/L3 | top-level plus exact bound T0 profile | No latest/nearest/later/full-life fallback |
| Temporal compatibility | Source L2/L3 | exact / zero-world-coverage / temporal-incompatible | No same-family restriction or location recommendation |
| Immutable managed generations | G4-03 existing Library | copy every contract-owned declared file and revalidate | No Library redesign or Source writeback |
| Wizard review | G4-05 existing Composition | exact re-resolve plus v0.2 temporal state check | No Game DB, Provider, materialization, or G4-06 |

## 2. Pre-implementation state / failure matrix

| Input/state | Required result | Mutation |
|---|---|---|
| valid v0.1 package | historical projection and fingerprint remain stable | none |
| valid v0.2-r2 package | rich validated package with all declared content loaded | none |
| exact World Entry | top-level plus only that Entry sections | none |
| exact Character binding | exact-profile state and only that profile sections | none |
| Character covers World but not Entry | temporal-incompatible state; Wizard review blocks | none |
| Character has zero coverage for World | distinguishable always-safe-only state; no family block | none |
| unselected/private bytes change | fingerprint changes; unrelated selected projection remains excluded | task fixture only |
| missing/unsafe/unreadable declared file | fail loud before publication/projection | none |
| duplicate section/profile/binding | fail loud deterministically | none |
| Library staged copy/restart/tamper | preserve append-only/current/exact fail-loud invariants | task-owned Library only |

## 3. Implementation and execution evidence

### 3.1 Implementation commit and changed responsibilities

Implementation commit: `eb11655f8ff592ae096915fab50553708c0b79df`

| Paths | Why |
|---|---|
| `src/source/L0_公理层/Source合同规则.gd`, `Source库规则.gd` | Add the frozen v0.2-r2 manifest/version rules while retaining the v0.1 acceptance boundary. |
| `src/source/L1_器件层/Source包文件读取器.gd`, `Source代次指纹计算器.gd` | Read every declared contract-owned file safely and include its exact bytes in the generation fingerprint. The v0.1 fingerprint domain remains unchanged. |
| `src/source/L2_流程层/世界包加载流程.gd`, `角色卡加载流程.gd` | Validate and load rich World/Character sections, exact profiles/bindings and optional portraits without inventing missing content. |
| `src/source/L2_流程层/Source选定投影流程.gd` | Project top-level plus one exact World Entry, or top-level plus one exact Character T0 profile, and expose the three frozen compatibility states. |
| `src/source/L3_外交层/*` | Publish validated v0.2-r2 data and exact projection/compatibility through the existing Source public boundary. |
| `src/建局/L3_外交层/建局公开接口.gd` | Localized G4-05 Review integration: block closed World coverage without the selected Entry, but keep zero cross-world coverage allowed. |
| `tests/g4_02r1/*` | Exercise the unchanged frozen 2 World + 6 Character packages, exact projection, fingerprint visibility, Library lifecycle and fail-loud validation. |

Layer/dependency check: the new projection responsibility is L2, depends downward on loaded Source contract data, and is exposed only through Source L3. The existing cross-module Wizard seam remains `建局/L3 -> source/L3`; no Source internal layer is referenced across modules and no upward dependency was introduced. Public comments state the exact-selection, no-fallback and compatibility-state contracts.

### 3.2 Exact validation commands

Godot executable for every command below:

```powershell
$godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
```

Focused v0.2-r2 and prior G4-02 contract tests:

```powershell
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_02r1_mechanism_final'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02r1/Source_v0_2_r2_负向测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_02r1_negative_final'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02/Source合同现实测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_02_regression'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02/Source合同负向测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_02_negative_regression'
```

G4-03 and G4-05 regressions:

```powershell
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_03/Source库现实测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_03_reality_final'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_03/Source库失败与篡改测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_03_failure_final'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_03/Source库重启验证测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_03_reality_final'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/历史真实资产转换现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05_final_assets'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/建局Composition测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05_final_composition'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/应用新游戏向导现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05_final_application'
& $godot --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/新游戏向导窗口布局测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05_gui_final' --shot-dir='D:/AI/Projects/my-world/build/g4_05_gui_final/shots'
```

Windows rendering and final editor parse:

```powershell
& $godot --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/新游戏向导窗口布局测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05_r2_windows' --shot-dir='D:/AI/Projects/my-world/build/g4_05_r2_windows/shots'
& $godot --headless --path 'D:\AI\Projects\my-world' --editor --quit
git diff --name-only -- tests/fixtures/g4_02r1/full_fidelity
git diff --cached --check
```

### 3.3 Real 2 World + 6 Character proof

`Source_v0_2_r2_机制现实测试.gd` loaded the unchanged production-shaped frozen fixtures through `Source合同公开接口`: `天下未定`, `埃瑟维亚`, `刘备`, `曹操`, `孙权`, `莉维娅`, `阿德里安`, and `杜恩`. It asserted `2 World + 6 Character` rather than only package counts: every stable identity resolved, rich declared files loaded, and all six genuinely absent portraits remained absent without placeholder or fabricated bytes. Result: `failures=0`.

`git diff --name-only -- tests/fixtures/g4_02r1/full_fidelity` returned empty before commit; the mechanism did not modify or compress any frozen fixture.

### 3.4 Selected projection positive and negative proof

- Han World Entry `t0-184-yellow-turban` projected the World top-level sections and that exact snapshot only; later/unselected Entry files were absent.
- Each of the three Afterglow Entries projected its own selected snapshot and excluded the other two snapshots.
- Liu Bei at the exact 184 binding included only that profile inventory and content; a later-profile truth marker was absent.
- Liu Bei, Cao Cao and Sun Quan each matched their last authored Han binding; the immediately later authored World Entry returned `temporal_incompatible`, proving there is no latest/nearest/later/full-life fallback.
- All three Afterglow Characters matched all three authored 1287 Entry bindings exactly.
- The negative suite rejected package-wide duplicate section IDs, duplicate profile IDs, duplicate exact bindings, unsafe paths, missing files, invalid UTF-8 and recursive live-state fields. A new safe `section_type` remained accepted, so the validator did not invent a closed semantic ontology.

### 3.5 Fingerprint versus visibility proof

The focused reality test mutated bytes in an unselected World Entry: the exact generation fingerprint changed while that Entry remained absent from the selected projection. It separately mutated a `gm_private` Character profile: the fingerprint changed while the unmatched profile remained absent from an always-safe-only projection. Selecting that exact profile retained its `gm_private` disclosure metadata. Therefore visibility narrows projection, not the generation fingerprint domain.

Missing declared content and invalid UTF-8 failed before publication/projection. Managed rich-file tamper returned `managed_generation_invalid`; no directory-name or current-generation fallback was accepted.

### 3.6 Temporal compatibility proof

The three observable states were exercised:

- `exact_profile_match`: an explicit `(world_asset_id, entry_id) -> profile_id` binding exists and only that profile is projected;
- `no_world_coverage`: the Character declares zero coverage for the selected World and remains allowed, including cross-family selection;
- `temporal_incompatible`: the Character declares coverage for the World but has no binding for the selected Entry, and G4-05 Review blocks with `character_temporal_incompatible`.

No same-family check or recommendation/fallback rule was added.

### 3.7 G4-03 regression

The v0.2 focused path installed all eight real packages, copied all contract-owned rich files, restored an inventory of exactly `2 World + 6 Character`, and failed loud after tampering an unselected rich file. Existing G4-03 reality, failure/tamper and restart suites each ended with `failures=0`, preserving replay-safe duplicate install, append-only exact generations, explicit current metadata, restart recovery, interrupted staging isolation and no historical/current fallback on damage.

### 3.8 G4-05 regression and Windows evidence

Existing historical conversion, Composition, Application Wizard and layout suites each ended with `failures=0`. They retain explicit selection, exact generation pinning, World-change Entry clearing, role separation, Light default, deterministic review, cancel cleanup, zero Game DB/Game Library mutation and disabled G4-06 Final Create.

The non-headless Windows run used Godot `4.7.2.stable`, Vulkan `1.4.341`, and `NVIDIA GeForce RTX 4070 Laptop GPU`. It passed 1280x720, maximized and 960x540 Wizard/Review/Cancel paths with `failures=0`; screenshots are under `build/g4_05_r2_windows/shots/`. The final editor parse reported no script parse/compile failure. Windows root-certificate-store access and editor-settings persistence emitted sandbox-environment warnings; neither affected Source tests or GUI assertions.

## 4. Known limitations and deferred work

- This packet establishes only validator/loader/fingerprint, exact selected projection, temporal compatibility and localized regressions. It does not create Game databases, materialize Sources or implement G4-06.
- Compatibility is only the frozen authored exact-binding mechanism. It performs no same-family restriction, nearest/latest profile selection, recommendation, AI scoring or geographic plausibility inference.
- Optional portraits remain honestly absent; no portrait synthesis or placeholder production was added.
- Headless rendering cannot produce meaningful screenshots with Godot's dummy renderer; screenshot evidence therefore comes only from the successful non-headless Windows/Vulkan run.
- Engineering evidence is ready for GPT Independent Review; it does not close G4-02R1 or change G4-05 state.

## 5. G4-02R1M1-IR01 optional temporal scope evidence correction

### 5.1 Scope and commit

IR01 test commit: `b6f83851758a79dff2a24f621befdebdcc21c940`

Formal Code Base `74d1fe8d93e527794db33d0280d76d16674ae1d7` to Start HEAD `1914880bccfc04477ec81e1dfb4ba4d1a08ff04f` contained only repository-native AGENTS/packet changes. No material implementation drift existed.

Changed files:

- `tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd`: replace generic cutoff sampling with direct production-path assertions for every required Han Entry.
- `tests/g4_02r1/Source可选时态范围证据测试.gd` and UID: prove optional temporal capability through the existing Source L3 loader/projection seam.
- `tests/fixtures/g4_02r1/ir01_optional_temporal/非时态角色/*`: task-owned profile-free rich Character evidence.
- `tests/fixtures/g4_02r1/ir01_optional_temporal/非时态世界/*`: task-owned multi-Entry World evidence without a temporal section matrix.

Production code changed: **no**. `git diff --name-only -- src` was empty. Frozen full-fidelity fixtures changed: **no**. `git diff --name-only -- tests/fixtures/g4_02r1/full_fidelity` was empty. Tests remain outside the four Source layers; no dependency direction, cross-module boundary or public contract changed.

### 5.2 Exact commands

```powershell
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02r1/Source可选时态范围证据测试.gd'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02r1/Source_v0_2_r2_机制现实测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_02r1_ir01_reality'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_02r1/Source_v0_2_r2_负向测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_02r1_ir01_negative'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_03/Source库现实测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_03_ir01_reality'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_03/Source库重启验证测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_03_ir01_reality'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_03/Source库失败与篡改测试.gd' -- --work-root='D:/AI/Projects/my-world/build/g4_03_ir01_failure'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/建局Composition测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05_ir01_composition'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --script 'res://tests/g4_05/应用新游戏向导现实测试.gd' -- --root='D:/AI/Projects/my-world/build/g4_05_ir01_application'
& 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:\AI\Projects\my-world' --editor --quit
git diff --name-only -- src
git diff --name-only -- tests/fixtures/g4_02r1/full_fidelity
git diff --check
```

### 5.3 Complete Han closed-coverage evidence

Every row below called `Source合同公开接口.project_character_t0(...)` with the unchanged real Character fixture and exact real World Entry ID; no year arithmetic or name inference was used:

```text
刘备 t0-220-han-wei-transition -> exact_profile_match (han-220)
刘备 t0-229-three-states       -> temporal_incompatible
刘备 t0-263-shu-survival-eve   -> temporal_incompatible
刘备 t0-280-wu-survival-eve    -> temporal_incompatible

曹操 t0-214-yizhou-transition  -> exact_profile_match (han-214)
曹操 t0-220-han-wei-transition -> temporal_incompatible
曹操 t0-229-three-states       -> temporal_incompatible
曹操 t0-263-shu-survival-eve   -> temporal_incompatible
曹操 t0-280-wu-survival-eve    -> temporal_incompatible

孙权 t0-249-gaopingling-aftermath -> exact_profile_match (han-249)
孙权 t0-263-shu-survival-eve      -> temporal_incompatible
孙权 t0-280-wu-survival-eve       -> temporal_incompatible
```

The direct Sun Quan 280 assertion additionally required `hard_incompatible == true` and an empty `selected_profile`, proving no earlier/latest/nearest/full-life profile was substituted.

### 5.4 Non-temporal Character evidence

The task-owned `character.ir01.river_cartographer` manifest omits `t0_profiles` entirely. Its complete identity, personality contradiction, expression, capability, limitation and autonomy semantics live in two top-level rich Markdown sections.

Production results:

- loader accepted `character_card.v0.2` and returned zero profiles without creating a synthetic profile;
- projection against `world.ir01.tidal_archipelago/opening-harbor-market` returned `no_world_coverage`, `hard_incompatible == false` and an empty `selected_profile`;
- both top-level markers remained in the selected projection, proving always-safe-only does not starve rich semantics;
- manifest contains none of `historical`, `temporal_mode`, `requires_quarantine` or `family_mode`.

Focused result: `failures=0`.

### 5.5 Non-temporal World evidence

The task-owned `world.ir01.tidal_archipelago` keeps complete rich world-operation semantics top-level and declares two Entries solely as opening/scenario choices. Both Entries have empty `semantic_sections`.

Production results:

- loader accepted `world_pack.v0.2` without a temporal mode field;
- exact selection independently returned `opening-harbor-market` and `opening-outer-lighthouse`;
- each selected projection contained exactly the same complete top-level rich section and the correct selected Entry metadata;
- no history/year/family classification or artificial Entry section matrix was introduced.

Focused result: `failures=0`.

### 5.6 Existing temporal quarantine and regression

The updated real-fixture suite ended with `failures=0` and retained:

- Han 184 World projection excludes later Entry inventory and later canon markers;
- Liu Bei 184 projection excludes the later 220 profile and its truth marker;
- all three Afterglow Characters exact-match all three authored 1287 Entries;
- cross-world zero coverage remains non-hard-blocking;
- unselected/private byte mutations change fingerprint while remaining outside the wrong selected projection;
- optional portrait absence remains honest for all six real Characters;
- G4-03 exact managed-generation tamper still fails loud.

The existing v0.2 negative suite ended with `failures=0`. G4-03 reality, restart and failure/tamper suites each ended with `failures=0`. G4-05 Composition and Application Wizard suites each ended with `failures=0`, preserving exact selection, no drift to current Y, fail-loud review, zero Game DB/Game Library mutation and disabled G4-06.

Godot editor parse completed without script parse/compile errors. The run emitted pre-existing test-build UID duplication warnings plus sandbox limitations for the Windows certificate store, `user://` log rotation and editor-settings persistence; none changed process exit status or test assertions.

No GUI or production code changed, so IR01 did not repeat the non-headless screenshot pass. The prior G4-02R1M1 Windows/Vulkan evidence in section 3.8 remains the applicable engineering evidence.

### 5.7 IR01 known limitations

- `no_world_coverage` proves only that the temporal-coverage rule has no basis to hard-block; it does not decide every future Compatibility policy.
- The synthetic packages are narrow mechanism evidence, not product-valued Source content or Owner UAT assets.
- IR01 adds no generic temporal-mode classifier, profile fallback, same-family restriction, G4-06 behavior or Context/Prompt refactor.
- This correction is ready for GPT Independent Review and does not close G4-02R1 or change G4-05 hold state.
