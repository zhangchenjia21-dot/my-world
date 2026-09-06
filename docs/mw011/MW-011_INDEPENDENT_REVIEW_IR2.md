# MW-011 Independent Review IR#2 — Player Character Profile Projection + Player Host Surface

Status: **NOT PASS — REVISION 3 REQUIRED**  
Work Item: **MW-011**  
Revision: **2**  
Review-Round: **IR#2**  
Reviewer: **GPT**  
Reviewed candidate: `09de33c3ac34485b7a5ec7e807d0e2464d04c7ca`  
Candidate parent / refreshed implementation base: `6968e137e210430bab37e0a9bdbb74c346ba8bfa`  
Governance base reviewed: `Vibe-Coding/main@5f53983ef641aa6e95bad1a8cb80668ed5d2459c`  
Architecture: `Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`  
Task addendum: `docs/tasks/MW-011_REVISION2_PLAYER_CHARACTER_PROFILE_SURFACE_ADDENDUM.md`

## 1. Verdict

**NOT PASS. Revision 3 is required.**

The mechanism implementation is substantially aligned with the frozen R2 architecture: it adds a bounded optional Character `player_profile`, freezes it through the existing selected projection path, introduces a separate fail-closed Player Character Profile Projection, extends the existing presentation-only ViewModel, and renders a scrollable rich Player Host without broadening MW-009 or introducing a generic UI platform.

However, the actual pushed candidate does **not contain the Zhang Chen `player_profile` Source update that the task requires and the evidence claims**. This makes the candidate internally inconsistent and makes the reported focused/production evidence non-reproducible from the exact reviewed commit.

Do not integrate this candidate.

## 2. Actual candidate scope inspected

GitHub compare `6968e137... → 09de33c3...` shows one candidate commit and the intended mechanism files, including:

- `src/source/L0_公理层/Source合同规则.gd`
- `src/source/L2_流程层/角色卡加载流程.gd`
- `src/source/L2_流程层/Source选定投影流程.gd`
- `src/source/L3_外交层/角色卡公开类型.gd`
- `src/rpg视图模型/L1_器件层/玩家角色档案投影器.gd`
- `src/rpg视图模型/L1_器件层/RPG主机视图模型.gd`
- `src/rpg视图模型/L3_外交层/RPG主机视图模型公开接口.gd`
- `src/main.tscn`
- `src/应用壳.gd`
- `scripts/MW-012_张琛角色卡生产Source发布.gd`
- `tests/mw011r2/玩家档案表面测试.gd`
- focused/regression path adaptations and evidence.

But the actual compare does **not** include:

`tests/fixtures/mw012/汉末三国/张琛/source.json`

although the candidate evidence explicitly lists that file as changed.

GitHub exposes no CI status for this candidate, so runtime counts are implementer evidence and must be consistent with the exact pushed bytes before they can support a PASS.

## 3. Finding F01 — required Zhang Chen Source bytes are absent from the candidate

The task requires Zhang Chen to gain a real authored `player_profile`, with a normal package version increment (expected `0.1.1`) and a new immutable generation for future Games.

Independent inspection of the exact pushed candidate shows:

- base `6968e137.../tests/fixtures/mw012/汉末三国/张琛/source.json`
- candidate `09de33c3.../tests/fixtures/mw012/汉末三国/张琛/source.json`

are the **same blob** (`d403e2ba6eae139257fbb8cfe02acfefd2c988ba`).

The candidate file still says:

```text
version: 0.1.0
```

and contains no `player_profile` field at all.

Therefore a clean checkout of the reviewed candidate cannot produce the required rich Zhang Chen Player Host. The core Owner UAT outcome is still absent from the committed product content.

### Required correction

Commit the actual Zhang Chen `source.json` update into the MW-011 line:

- `version = 0.1.1` (or the exact next version justified by the final bytes);
- valid bounded `player_profile`;
- exactly seven authored groups in the frozen order: background / personality / capabilities / limits / goals / principles / possessions;
- content faithfully derived from the already accepted MW-012 semantics only.

The exact committed Source bytes, not an uncommitted local file, must be the bytes reviewed and tested.

## 4. Finding F02 — production publish script and committed package are mutually inconsistent

The candidate changes:

`scripts/MW-012_张琛角色卡生产Source发布.gd`

to:

```text
VERSION = 0.1.1
```

The script installs `PACKAGE_PATH = res://tests/fixtures/mw012/汉末三国/张琛` and then explicitly fails if the installed generation version is not `0.1.1`.

But the exact committed package at that path remains `0.1.0`.

Therefore the production publication command from a clean checkout of candidate `09de33c3...` must reach `installed_identity_mismatch / version mismatch`; it cannot produce the evidence-recorded successful `0.1.1` publication.

The evidence claims a successful current generation with fingerprint:

`0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4`

That result is not reproducible from the pushed candidate bytes. The most likely explanation is that testing/publication used a dirty or otherwise uncommitted worktree version of `source.json`.

### Required correction

After committing the exact Source bytes, run the bounded production publication seam from the clean reviewed candidate and record:

- exact candidate HEAD;
- `git status --short` clean before the run;
- installed/already-installed status;
- exact `asset_id`, version and generation fingerprint derived from those committed bytes;
- `zhang_chen_present=true` in current inventory;
- `owner_games_modified=false`.

Do not preserve the old reported fingerprint artificially. Recompute from the final committed candidate.

## 5. Finding F03 — focused test result is not reproducible from the pushed candidate

`tests/mw011r2/玩家档案表面测试.gd` loads the real product package:

```text
ZHANG_PACKAGE = res://tests/fixtures/mw012/汉末三国/张琛
```

and immediately expects the loaded Source to contain:

```text
player_profile.headline == "24岁 · 现代穿越者"
```

It then Final Creates Zhang Chen and requires the frozen Game-local profile to contain the headline and seven groups, and requires those values to render visibly in the Player Host.

The exact pushed package contains no `player_profile`. Therefore the reported `45 assertions / 0 failures` cannot be the result of executing the committed candidate in a clean checkout.

### Required correction

After F01 is committed, rerun the focused suite and the required regressions from a clean exact candidate HEAD. Evidence must identify that exact HEAD and must not rely on dirty/uncommitted Source bytes.

## 6. Mechanism work accepted in principle — preserve in R3

The following reviewed mechanism direction is acceptable and should **not** be redesigned merely because the content file was omitted:

- Character Card v0.2 optional `player_profile` remains backward compatible for cards that omit it;
- bounded validation shape and limits are appropriate for this internal presentation field;
- `project_character_t0()` carries the validated profile through the existing selected projection so Final Create can freeze it with normal Source ancestry;
- `PlayerCharacterProfileProjectionDevice` reads only the frozen Player Character profile and has no Source Library / semantic-section / catalog-summary fallback;
- MW-009 current Player-known-facts contract remains untouched;
- the RPG Host ViewModel receives only the separate profile projection rather than raw Character Source sections;
- Player Host renders headline/summary/groups before World/recent-action material;
- the left Host uses a bounded vertical `ScrollContainer` while Narrative keeps the 60% desktop stretch ratio;
- no stat system, Inventory mechanics, generic UI DSL, Mod schema, Provider summarization or new persistence table was introduced.

These are subject to normal regression proof after the committed Source correction.

## 7. Non-blocking cleanup advisory

`src/main.tscn` currently repeats identical `layout_mode = 2` and `theme_override_constants/separation = 8` assignments inside `PlayerPanelColumn`. If Godot continues to parse/export this cleanly it is not an IR blocker, but R3 may remove the duplicate lines as a no-semantic-change cleanup while touching the same scene only if desired.

## 8. Revision 3 scope

Revision 3 is intentionally bounded:

```text
commit the missing Zhang Chen v0.1.1 + player_profile Source bytes
+ make script/package version identity consistent
+ rerun focused/regression/export from clean exact candidate HEAD
+ rerun bounded production publication from those exact committed bytes
+ correct evidence changed-file list and fingerprint
```

Do **not** reopen the approved R2 architecture, MW-012 Character semantics, G5 disclosure/world semantics, or introduce new UI/platform scope.

Use the same Work ID `MW-011`; this is a same-outcome correction.

## 9. Current disposition

```text
MW-011 R1 / IR#1 = ENGINEERING PASS / INTEGRATED
MW-011 R1 Owner UI UAT = NOT PASS
MW-011 R2 / IR#2 = NOT PASS — REVISION 3 REQUIRED
```

No Owner UAT should be requested from this R2 candidate because the committed first-party Zhang Chen profile bytes are not present.
