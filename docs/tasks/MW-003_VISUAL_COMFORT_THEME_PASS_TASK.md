# TASK｜MW-003｜Visual Comfort Theme Pass

Type: implementation / product polish  
Owner: Kimi  
Reviewer: GPT  
Capability-Anchor: **G6 RPG Experience & Internal Declarative UI Host**  
Inserted-By: **Owner**  
Blocks: **resume of G5-04 Owner UAT**  
Revision: **1**  
Review-Round: **0**  
Base: `my-world/main@895adb1576e9dd7501a2d07740accc1b05e9a50a`  
Governance Base: `Vibe-Coding/main@3bf48fb15f7ee298726f9defb04dc02872c83386`  
Status: **ACTIVE — KIMI**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Why this task exists

Owner product UAT surfaced a direct visual-comfort problem: the current dark palette is visually harsh enough to cause eye strain during normal play.

This is an independently meaningful product outcome, not a G5-04 correction. It is therefore a new flat Work Item under the approved task-lineage rule.

This task is an **early inserted G6 visual-polish slice**. It does not advance the project to G6, does not close G5-04, and does not authorize G5-05.

## 2. Primary outcome

Make the current product materially more comfortable for sustained reading while preserving a dark, restrained RPG presentation.

The target experience is:

> **Low glare, clear hierarchy, readable narrative, calm surfaces, restrained semantic color.**

The user should be able to read and interact for an extended session without the UI feeling like bright text floating on near-black panels.

## 3. Product direction

### 3.1 Contrast philosophy

Avoid the current harsh extreme of near-black large surfaces plus near-white body text.

Use layered dark neutrals instead:

- background should be dark but not pure/near-black;
- panels should be visibly separated by modest luminance differences, not hard outlines everywhere;
- primary body text should be a softened off-white rather than maximum-bright white;
- secondary text should be clearly subordinate but still comfortably readable;
- placeholders / disabled states may be muted, but must not become illegible;
- error/warning/success colors should remain noticeable without becoming saturated visual alarms.

WCAG-style contrast ratios may be used as an engineering heuristic: normal text should generally remain at least 4.5:1 against its surface, large text at least 3:1. Do not pursue maximal contrast as a visual goal.

### 3.2 Preferred starting palette

These are implementation starting values, not immutable canon. Small tuning is allowed if the relative hierarchy and acceptance goals remain intact.

```text
canvas/background      #1B1E24
surface/base           #22262D
surface/raised         #292E36
surface/input          #252A31
border/subtle          #343A44

text/primary           #D8DCE3
text/secondary         #A7AFBA
text/muted             #7F8996

accent                 #8FA9C4
success                #88AD96
warning                #C0A06B
danger                 #C57D78
```

Do not introduce neon accents, pure white, pure black, or large saturated red/orange regions.

### 3.3 Information hierarchy

Narrative remains the visual center of gravity.

Expected hierarchy:

```text
Narrative content / active input
> panel headings / active controls
> secondary metadata / hints
> disabled / tertiary state
```

Status/error/recovery colors are semantic accents, not competing focal points.

## 4. Required surfaces

Apply the same visual system coherently across the existing product surfaces that the Owner can reach through `run-game.cmd`:

1. Main Menu;
2. Model Settings dialog;
3. New Game Wizard;
4. in-game three-column shell;
5. Narrative content and composer;
6. buttons / OptionButton / LineEdit / TextEdit states;
7. Save / Restore / recovery / status messages;
8. error / warning / success states;
9. modal/confirmation surfaces that inherit the application Theme.

The pass is incomplete if only the screenshoted in-game surface changes while setup/settings remain visually inconsistent.

## 5. Implementation shape

Current implementation has a very small root `Theme` plus many scene-level and runtime color overrides. The correction should make the **core palette centrally owned** instead of continuing to duplicate important color literals across surfaces.

Use the smallest Godot-native structure that achieves this, for example a reusable Theme resource and/or one bounded palette helper consumed by runtime-created controls.

Required properties:

- core semantic colors have one authoritative definition;
- local one-off overrides exist only when semantically justified;
- runtime-created Narrative/status controls use the same semantic palette;
- existing font family and typography hierarchy are not redesigned;
- no large design-system/framework build.

## 6. Explicit non-scope

Do **not** use this task to implement:

- light mode;
- theme switching / user theme preferences;
- Accent Color settings;
- layout redesign;
- typography redesign;
- new icons or image assets;
- animation system;
- responsive-layout architecture;
- new Character / Relationship / Inventory / Faction / Map surfaces;
- Runtime Asset Resolution;
- G5-04/G5-05 gameplay changes;
- Provider / persistence / Timeline / Agency / World Evolution changes.

Minor border opacity, panel fill, hover/focus/pressed/disabled styling that is necessary to make the palette coherent is in scope.

## 7. Functional invariants

The visual pass must not change product behavior.

Protect at least:

- Main Menu navigation;
- Model Settings save/cancel and credential status behavior;
- New Game Wizard flow;
- first-opening / retry path;
- Narrative send/cancel/regenerate;
- Public-d20 interaction if present;
- Save / Load / Restore;
- current G5 world semantics and background scheduling.

No persistence schema change.

## 8. Acceptance evidence

### 8.1 Static/code evidence

Show that:

- core colors are centralized;
- the main product surfaces consume the new palette;
- old duplicated high-contrast literals are removed/reduced where appropriate;
- no unrelated gameplay/runtime scope was changed;
- `git diff --check` is clean.

### 8.2 Runtime evidence

Use the real Owner product path (`run-game.cmd` / current Windows export), not Editor-only appearance.

Capture or document runtime inspection for at least:

- Main Menu;
- Model Settings or New Game Wizard;
- active in-game Narrative surface with input + side panels;
- one semantic state such as error/warning/recovery.

### 8.3 Minimal regressions

Run only directly affected UI/product smoke coverage. At minimum keep green:

- one Main Menu / lifecycle smoke;
- one New Game / First Playable UI path;
- one Narrative interaction test;
- one Save/Restore UI-connected path if visual code touches Shell controls;
- `git diff --check`.

Do not run a broad world-semantics matrix unless a concrete regression reason appears.

## 9. Independent Review requirements

GPT review will inspect actual implementation, not screenshots alone.

Review questions:

1. Is the palette centrally owned rather than scattered further?
2. Did the implementation stay visual-only?
3. Are all required product surfaces coherent?
4. Are Narrative and input still the focal area?
5. Are semantic states readable but restrained?
6. Did the implementation avoid turning this into a G6 theme/settings platform?
7. Are functional regressions absent in the directly affected UI paths?

Kimi may return at most:

`READY FOR INDEPENDENT REVIEW`

## 10. Owner Product UAT

Engineering review cannot prove eye comfort. Owner is the final judge.

After Engineering PASS, Owner should use `run-game.cmd` and judge:

- 10–20 minutes of normal Narrative reading feels materially less harsh;
- body text no longer feels like bright white on black;
- panel hierarchy is visible without heavy borders or excessive contrast;
- input, button, hover/focus/disabled states remain obvious;
- warnings/errors remain easy to notice without visually shouting;
- Main Menu → Settings/Wizard → Game feels like one coherent product.

Only Owner Product PASS closes MW-003.

After MW-003 closes, resume the paused **G5-04 Owner UAT** exactly where it was; do not reinterpret the interruption as a G5-04 failure.