# MW-023｜Gameplay Typography Readability Baseline — Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**  
Reviewer: GPT  
Date: 2026-09-08

## 1. Reviewed identity

- Formal product-code base: `bfe108cbb1f749307c421517f5380b9eb00a9317`
- Task starting HEAD: `ea09d6bc3f032e55c01c162ff34551707cab7658`
- Implementation HEAD: `4ad8d2137f905edc2821d1a09eae8545df055baf`
- Submitted final candidate: `76d615ec9aa477d86281f5844a04454e611e45bb`
- Branch: `mw-023-gameplay-typography-readability`

Independent compare confirms the final candidate is exactly one evidence-only commit after Implementation HEAD; production/test tree is unchanged after implementation.

## 2. Scope / diff review

Formal base → implementation changes only the typography/readability surface:

- `src/main.tscn`
- `src/ui/人物卡片.gd`
- `src/ui/会话调试面板.gd`
- `src/ui/叙事对话视图.gd`
- `src/应用壳.gd`
- MW-023 focused tests / task metadata

No Provider, Conversation, World, Curator, Recommendation contract, Debug semantics, SQLite, Save or currentness owner is modified.

The root Theme default font moves 18→20px. Explicit gameplay labels below 20px are raised to 20px while existing larger title hierarchy such as 28px/40px is retained.

Layout accommodations are bounded and justified by the font increase:

- World navigation changes `HBoxContainer` → `HFlowContainer` so the same five tabs can wrap without IA change;
- Save surface receives a local vertical `ScrollContainer` without changing Save/Restore commands or ownership;
- local scrollbar intrinsic widths prevent enlarged text from being covered;
- public d20 labels can wrap;
- Narrative vertical whitespace is modestly reduced while font/composer sizes stay at the readability baseline.

No semantic routing or gameplay behavior was added.

## 3. Effective-font evidence

The MW-023 focused test uses the real `main.tscn`, task-owned SQLite, accepted Conversation, real player-safe Character/Experiences/People projections, recommendation controls, Save controls and Debug surface.

It recursively inspects visible runtime Controls using `get_theme_font_size()` rather than grepping source constants. It also checks RichText normal/bold/italics/bold-italics/mono sizes individually.

Evidence reports:

- 789 runtime effective-font samples;
- every sampled regular gameplay font >=20px;
- larger titles remain larger;
- ConfirmationDialog controls and Save dropdown are separately checked at >=20px.

Focused: 949 checks / 0 failures.  
Real-window: 949 checks / 0 failures.

## 4. Layout / usability engineering evidence

Real windows cover:

- 960×540
- 1280×720
- 1920×1080

At each size the suite exercises Overview / Character / Important Experiences / People / Save and Debug, including populated long content.

The tests independently require:

- Narrative remains >80px high;
- composer remains inside the viewport;
- navigation remains reachable;
- no horizontal host overflow;
- overflowing right surfaces expose draggable vertical scroll;
- lower Save controls remain reachable after scroll;
- Debug text is not covered by its scrollbar;
- recommendation click still fills the exact draft;
- resizing/toggling/scrolling produces no durable mutation or extra Provider call.

The 960×540 result intentionally trades density for readability: Narrative is about 92px high and right-side information requires more scrolling. This matches the frozen product rule: do not shrink below the 20px reading baseline merely to preserve information density.

## 5. Regression review

22 direct suites were recorded.

21 exit clean. The only failing suite is G3-03 with:

`opaque World JSON is not injected as Game Context`

The submitted evidence reproduces the same single assertion failure on an isolated exact Formal Base `bfe108cbb1f749307c421517f5380b9eb00a9317`. The remaining G3-03 Conversation/reopen/Regenerate/Send/corrupt-DB protection checks pass. Therefore this is retained baseline debt, not an MW-023 regression.

MW-003 retains its pre-existing ObjectDB/resource exit warnings; the suite itself exits 0.

## 6. Import / export

Submitted final evidence records:

- Godot 4.7.2 final import: PASS;
- fresh Windows export / `run-game.ps1 -ValidateExportOnly`: PASS;
- EXE/PCK/SQLite DLL present;
- no real Provider call required for this presentation-only task.

## 7. Product acceptance note

Owner explicitly reported on this candidate outcome:

> 字体大小已经差不多了。

This is sufficient bounded product acceptance of MW-023's typography outcome, provided reviewed integration preserves the exact production bytes. No duplicate typography replay is required after a non-rewriting integration.

## 8. Notes / residuals

Non-blocking:

1. 960×540 necessarily requires more vertical scrolling when right information and recommendations are both present; this is an accepted readability-over-density tradeoff.
2. MW-003 retains existing teardown/resource warnings.
3. G3-03 retained Context assertion remains separate debt.

## 9. Verdict

**ENGINEERING PASS_WITH_NOTES**.

MW-023 may be integrated by non-force fast-forward if implementation `main` is still the exact formal base/task start ancestry. If integration preserves the reviewed product code, Owner's explicit visual acceptance may be recorded as **MW-023 PRODUCT PASS** without another duplicate UAT round.
