# G4-09R1B1C01B — Settings UI State Consistency Correction

Status: **HOLD — KIMI AFTER C01A GPT IR PASS**  
Parent: **G4-09R1B1 Settings UI correction-01**  
Owner: **Kimi**  
Reviewer / semantic owner: **GPT**

Independent Review: `docs/g4_09r1/G4-09R1B1_INDEPENDENT_REVIEW.md`  
Backend prerequisite: `docs/tasks/G4-09R1B1C01A_RUNTIME_SETTINGS_L3_UI_SUPPORT_TASK.md`

## Outcome

After C01A is accepted, make the existing Main Menu model settings surface layer-correct and state-consistent without redesigning its visual system or Provider behavior.

## Required corrections

### 1. Remove UI → Runtime Settings L0 dependency

`src/应用壳.gd` must no longer preload or call `src/运行时设置/L0_公理层/**`.

For corrupt/invalid persisted settings, obtain the exact editable default only through the accepted Runtime Settings L3 public seam from C01A. Preserve the current UX: visible recoverable warning, default used only as an editing start point, no silent save.

### 2. K2.7 capability truth survives invalid context

Reproduce this exact transition:

```text
persisted/current candidate = Kimi K3 / 1M
open Model Settings
change model → Kimi K2.7
```

Expected state:

```text
selected context 1M remains visibly invalid
Save disabled
1M unavailable/disabled
reasoning control disabled
fixed Thinking ON explanation visible
no fake Low/Medium/High/Max effective value
no automatic model/context substitution
no persistence until explicit valid Save
```

When the player then selects 256K:

```text
candidate becomes valid
Save enabled
reasoning remains disabled
fixed-thinking explanation remains visible
```

When the player switches back to DeepSeek/K3, graded reasoning becomes enabled again according to backend projection.

All compatibility/fixed-thinking/effective truth must come from the C01A L3 result. Do not hard-code a Kimi-specific provider policy in UI.

### 3. Escape / ui_cancel behaves as Cancel

While Model Settings overlay is open on Main Menu:

```text
ui_cancel / Escape
→ close overlay
→ return Main Menu
→ do not Save
→ restore sensible focus to 模型设置
```

It must not exit the application, open another surface, or mutate Game/Source/settings.

## Accepted B1 behavior to preserve

Do not redesign or regress:

- four exact model names;
- Main Menu-only surface;
- valid candidate `inspect_candidate` preview;
- Medium → actual High disclosure;
- K2.7 valid 256K fixed-thinking UX;
- non-secret credential status;
- Save/Cancel/reopen/restart persistence;
- missing-credential warning with no fallback;
- responsive 1280×720 / 960×540 / maximized layout;
- Continue / New Game / Public d20 behavior;
- real DeepSeek/Kimi Provider routing.

## Scope

Expected production changes:

```text
src/应用壳.gd
src/main.tscn only if required for focus/input behavior
```

Plus task-owned tests/evidence.

Do not modify Runtime Settings/backend/Provider/Source/Final Create/Persistence/Public d20 paths; C01A owns the backend seam.

## Required tests

Add direct assertions for:

1. no `运行时设置/L0_公理层` dependency remains in Application Shell;
2. invalid persisted recovery uses L3 default and does not silently write;
3. exact `K3 / 1M → K2.7` transition shows **both** invalid-context truth and fixed-thinking truth;
4. selecting 256K restores Save-valid state without changing fixed-thinking presentation;
5. switching away from K2.7 re-enables graded reasoning when backend says graded;
6. `ui_cancel` / Escape closes overlay without save;
7. existing B1 focused suite remains green;
8. G4-07B and G4-08B regressions remain green;
9. required desktop layouts remain usable;
10. `git diff --check`.

Existing real DeepSeek/Kimi UI generation evidence remains applicable if normal Save/provider routing is unchanged. If that path changes, rerun both real Provider UI verticals.

## Return contract

Return:

```text
START_HEAD
IMPLEMENTATION_HEAD
EVIDENCE_HEAD
changed paths
L0 dependency removal proof
K2.7 invalid-context state proof
valid-recovery transition proof
Escape/Cancel proof
regression/layout summary
whether real Provider rerun was necessary
READY FOR INDEPENDENT REVIEW
```

Do not resume Owner UAT or declare G4-09R1/G4-09/G4-08 PASS.