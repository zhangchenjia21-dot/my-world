# TASK｜MW-023｜Gameplay Typography Readability Baseline

Type: bounded cross-page product readability correction  
Work Item: **MW-023**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / UAT: **Owner**  
Required Task Branch: `mw-023-gameplay-typography-readability`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-023-gameplay-typography-readability`  
Formal Code Base: `bfe108cbb1f749307c421517f5380b9eb00a9317`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Make the active gameplay page consistently readable for sustained text-RPG use.

Owner UAT explicitly requested that current main Narrative body size become the default gameplay text scale.

Frozen target:

```text
Narrative body reference ≈ 20px
→ ordinary active-game text/control size >=20px
→ existing intentionally larger headings remain larger
```

The right-side information surfaces must no longer look materially smaller than the main Narrative.

## 2. Authority

Refresh implementation/governance mains before work and read:

1. Owner current typography feedback.
2. current `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
3. `Vibe-Coding/my world/docs/uat/G6_PACKAGE1_DEBUG_MODE_OWNER_UAT_U1.md`.
4. `Vibe-Coding/my world/architecture/ui/G6_GAMEPLAY_TYPOGRAPHY_READABILITY_BASELINE_V1_0_DECISION.md` — FROZEN/CURRENT.
5. current Roadmap.
6. repository `AGENTS.md` stable rules.
7. current implementation/tests.

If newer governance supersedes the typography decision, STOP.

## 3. Scope audit first

Before editing, inventory the **active gameplay surface** typography sources, including:

- `src/main.tscn` explicit `theme_override_font_sizes/font_size` values;
- root/default Theme font size insofar as it affects gameplay controls;
- dynamic runtime-created Labels/Buttons/RichTextLabels/TextEdit styling in:
  - `src/应用壳.gd`;
  - `src/ui/叙事对话视图.gd`;
  - `src/ui/人物卡片.gd`;
  - `src/ui/会话调试面板.gd`;
  - other directly used active-game UI scripts discovered by exact call/reference evidence.

Do not perform unrelated repository-wide visual cleanup.

## 4. Required typography semantics

### AC-01｜20px minimum ordinary gameplay reading baseline

On the active gameplay page, ordinary visible text/control typography must not intentionally render below **20px**.

This includes, where present:

- body text;
- ordinary Labels;
- Buttons / tabs / toggles;
- helper/status/error text;
- World Information content;
- Character / Important Experiences / People cards;
- Debug rows;
- Recommendation labels/buttons/helper text;
- Save/Restore controls;
- composer/input related ordinary text.

The current main Narrative body remains the reference and must stay >=20px.

### AC-02｜Preserve hierarchy

Do not flatten typography.

Existing larger titles/headings (e.g. 28px/40px) stay >= their meaningful hierarchy unless a concrete bounded layout issue justifies a different **still >=20px** value.

Do not turn every element into exactly 20px.

### AC-03｜Readability over density

If larger text needs more space, prefer:

- wrapping;
- scrolling;
- modest control-height/padding increases;
- bounded panel sizing adjustments.

Do not shrink below 20px simply to keep the same amount of information visible at once.

### AC-04｜Current gameplay only

Primary target is the active Game surface.

Main Menu / New Game Wizard are not a redesign target. If a harmless shared Theme default causes them to inherit 20px ordinary text, accept that only if their layout remains valid. Do not broaden into wizard/menu redesign.

## 5. Layout accommodation

Allowed only when needed to prevent regressions from the new font scale:

- increase minimum control height;
- increase local padding/spacing modestly;
- increase a bounded scroll area/panel dimension;
- rely on existing vertical scroll;
- adjust readable-width calculations if font growth causes concrete clipping.

Prohibited:

- new IA/nav structure;
- moving or deleting information surfaces;
- reducing text below 20px;
- full responsive redesign;
- new breakpoints without a proven concrete need;
- color/palette redesign;
- font-family asset work;
- Dynamic UI.

## 6. Protected product behavior

No changes to:

- Narrative/Conversation semantics;
- Provider calls/prompts;
- World/Identity/Curator semantics;
- Recommendation contract;
- Debug diagnostic semantics;
- Save/Restore/currentness;
- SQLite/schema;
- Package 2 features.

This is presentation-only.

## 7. Validation

### Focused computed-font validation

Use real `main.tscn` / active-game runtime UI and inspect **effective visible font size**, not only source literals.

At minimum test after activating a representative Game:

- TopBar controls;
- Narrative body + auxiliary status/helper/error labels;
- composer/send controls;
- recommendation controls;
- right-side navigation;
- Overview/Character/Important Experiences/People/Save visible text;
- Debug toggle/panel rows.

For each ordinary visible text/control in scope, effective font size must be >=20px.

Do not fail intentionally larger headings because they are >20px.

### Real-window sizes

Validate at minimum:

- 960×540;
- 1280×720;
- 1920×1080.

Prove:

1. right-side information is comfortably readable and no longer materially smaller than Narrative body;
2. no unusable horizontal overflow;
3. no inaccessible clipped controls;
4. vertical scrolling remains possible where content grows;
5. Narrative/composer remain usable;
6. Debug panel remains readable at >=20px, even if fewer rows fit;
7. recommendation buttons/drafts and People cards remain usable;
8. narrow layout still exposes required navigation/control access.

### Regression protection

Run directly affected UI/product suites including at minimum:

- MW-003 visual theme/window smoke;
- MW-011 host/viewmodel UI;
- MW-015 surfaces;
- MW-018 People cards;
- MW-019 recommendation/composer UI;
- MW-021 Narrative scroll;
- MW-022 Debug window/observability;
- core G2 Narrative UI paths;
- G3 Save/Restore UI paths.

Reproduce any pre-existing baseline failure rather than silently relabeling it.

### Export

Because active production UI scripts/scenes/theme change:

- final Godot import;
- fresh Windows export validation;
- no launch required for implementer return.

No real Provider call is required.

## 8. Product Value Acceptance

After reviewed integration, Owner should only need a bounded visual/readability confirmation:

> active game page ordinary text now reads at roughly the same baseline scale as Narrative body; right-side information is no longer tiny; larger headings still preserve hierarchy; gameplay remains usable.

## 9. Explicit non-scope

Do not implement:

- Package 2 OOC / Character-guided recommendations;
- Open Threads/System/Inventory;
- full visual redesign;
- Dynamic UI;
- accessibility settings/font-size preference framework;
- DPI scaling framework;
- custom font packaging;
- Application Shell decomposition;
- unrelated architecture-debt cleanup.

## 10. Git / return

- Use only required branch/worktree.
- Preserve Owner unknown/local files; no reset/clean/force.
- Do not modify `main` directly.
- Commit + push implementation/evidence.
- Write `docs/mw023/MW-023_IMPLEMENTATION_RETURN.md`.
- Return exact Starting HEAD / Implementation HEAD / Final candidate HEAD.
- Include font inventory summary, focused/window/regression/export evidence, and residual risks.
- Do not merge main.
- Do not install Owner build.
- Do not grant Product PASS.

Highest state: **READY FOR INDEPENDENT REVIEW**.
