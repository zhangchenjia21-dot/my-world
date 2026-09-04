# MW-003 — Visual Comfort Theme Pass Evidence

Status: READY FOR INDEPENDENT REVIEW  
Work Item: MW-003 — Visual Comfort Theme Pass  
Owner: Kimi  
Reviewer: GPT

```text
START_HEAD: 42006215838c07910ab8b948cac628a4f43dde4e
FINAL_HEAD (implementation): eb13d559092e288506ce280ea01e9ef3c8a62290
Evidence doc committed as a separate follow-up commit.
Real Provider calls: 0
```

## 1. Scope

Only color / visual-comfort changes. No layout refactor, no font-size change,
no light mode, no theme switching, no visual assets, no G5-04/G5-05 or other
gameplay/runtime behavior change.

Visual direction authority is the relative hierarchy:

```text
surface: canvas < base < input < raised
text:    muted  < secondary < primary
```

No pure-black large surfaces, no pure-white body text, no neon accent, no large
saturated red/orange areas.

## 2. Central palette

New single authoritative palette: `src/ui/视觉舒适调色板.gd`

- Surface constants: `CANVAS 1B1E24`, `SURFACE_BASE 22262D`,
  `SURFACE_INPUT 252A31`, `SURFACE_RAISED 292E36`, `BORDER_SUBTLE 343A44`
- Text constants: `TEXT_PRIMARY D8DCE3`, `TEXT_SECONDARY A7AFBA`,
  `TEXT_MUTED 7F8996`
- Semantic constants (low saturation): `ACCENT 8FA9C4`, `SUCCESS 88AD96`,
  `WARNING C0A06B`, `DANGER C57D78`
- `static func apply_theme(theme)`: default font colors, Label type variations
  (`LabelSecondary/LabelMuted/LabelAccent/LabelSuccess/LabelDanger`),
  `PanelCard` variation, panel/input/button/option/popup/scrollbar/separator
  styleboxes — all assembled from the constants above.

`src/应用壳.gd` `_ready()` calls `Palette.apply_theme(theme)` and sets
`$Background.color = Palette.CANVAS`, so the whole product window inherits the
central palette at launch.

## 3. Changed files

```text
src/ui/视觉舒适调色板.gd        (new)  central palette + Theme assembly
src/应用壳.gd                   theme application + 11 runtime Color literals → palette constants
src/ui/叙事对话视图.gd           8 runtime Color literals → palette constants; mechanic card → PanelCard variation
src/ui/新游戏向导.gd             9 runtime Color literals → palette constants; error bbcode → palette DANGER
src/main.tscn                   font_color literal overrides removed → theme_type_variation semantic roles
src/ui/新游戏向导.tscn           same migration
tests/mw003/视觉舒适主题验证测试.gd (new) real-render verification harness
```

Old high-contrast literals removed:

```text
.tscn theme_override_colors/font_color literals: 28 removed / replaced with type variations
.gd runtime Color(...) literals:                  28 replaced with palette constants (11 + 8 + 9)
Residual Color( outside palette file:           0 (grep-verified over src/)
Residual font_color overrides in the two .tscn: 0
```

## 4. Focused verification (real render, non-headless)

Harness: `tests/mw003/视觉舒适主题验证测试.gd` (SceneTree, real window;
stubbed Providers — 0 real Provider calls).

Command:

```text
Godot_v4.7.2-stable_win64_console.exe --path <repo> \
  --script res://tests/mw003/视觉舒适主题验证测试.gd \
  -- --root=<repo>/build/mw003_comfort
```

Result: **30 PASS / 0 FAIL**

Coverage: palette centralization assertions + full product path smoke —
Menu → Settings (warning state) → Wizard world/character steps → Final Create →
in-game three-pane Narrative → one accepted turn → Save success (success green)
→ transport failure (danger red).

Screenshots (all visually inspected):

```text
build/mw003_comfort/shots/01_main_menu.png        Menu
build/mw003_comfort/shots/02_model_settings.png   Settings / model warning (WARNING gold, raised inputs)
build/mw003_comfort/shots/03_new_game_wizard.png  Wizard world selection
build/mw003_comfort/shots/04_ingame_narrative.png in-game three-pane Narrative
build/mw003_comfort/shots/05_save_success.png     save success confirmation in SUCCESS green
build/mw003_comfort/shots/06_error_state.png      transport error in DANGER red + prior success line intact
```

## 5. Directly-related UI regressions

All run sequentially (never parallel Godot instances), stubbed Providers:

```text
tests/g4_05/应用新游戏向导现实测试.gd --root=build/g4_05_recheck   → done failures=0
tests/g4_07b/可玩界面整合测试.gd      --root=build/g4_07b_recheck   → done failures=0
tests/g3_04/存档读取界面测试.gd       --db=build/g3_04_ui_recheck/…  → done failures=0
tests/g3_07/灾难恢复界面布局测试.gd    --db=build/g3_07_ui_recheck/…  → done failures=0 (real window, 3 resolutions)
```

Note: the first g4_05 run showed transient wizard-population timing failures
(toggle list not yet settled); two subsequent full runs completed with
failures=0. No code change was made for this; the flake predates/is unrelated
to palette changes (color-only diff).

G4-01 lifecycle (headless, `--db=build/g4_01_recheck/current.sqlite`) also ran
green during development: 0 FAIL — proves both modified .tscn load and run.

## 6. Product path / export validation

```text
powershell -NoProfile -ExecutionPolicy Bypass -File run-game.ps1 -ValidateExportOnly
→ "Windows export rebuilt and verified against the current checkout."
→ "Windows export freshness validation completed; game launch skipped by explicit validation mode."
```

First attempt reported "inputs changed during export" because the new palette
script's `.gd.uid` was generated mid-export; immediate rerun passed cleanly.
No game launch, 0 real Provider calls.

## 7. Hygiene

```text
git diff --check: clean
```

One-off migration helper `build/mw003_migrate_theme.py` lives under `build/`
(git-ignored), not committed.

## 8. Non-scope declaration

MW-003 does not advance G6, does not close G5-04, does not authorize G5-05.
G5-04 Owner UAT remains paused, not cancelled. No gameplay, runtime, protocol,
scheduling, persistence, or Provider behavior was touched.
