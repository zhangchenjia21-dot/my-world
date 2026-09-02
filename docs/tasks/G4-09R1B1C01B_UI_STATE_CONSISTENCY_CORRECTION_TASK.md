# G4-09R1B1C01B — Settings UI State Consistency Correction

Status: **PASS / CLOSED**  
Parent: **G4-09R1B1 Settings UI correction-01**  
Owner: **Kimi**  
Reviewer / semantic owner: **GPT**

Independent Review: `docs/g4_09r1/G4-09R1B1C01B_INDEPENDENT_REVIEW.md`  
Accepted backend prerequisite: `docs/g4_09r1/G4-09R1B1C01A_INDEPENDENT_REVIEW.md`  
Accepted C01A evidence HEAD: `bb3c16b392887a4649f32e23348067c70a3e7a1c`  
Accepted C01B evidence HEAD: `b6bd6bc8e077bbeccbb8639f6bc0670795e3e36c`

## Outcome

Make the existing Main Menu model settings surface layer-correct and state-consistent without redesigning its visual system or Provider behavior.

## Required corrections — completed

### 1. Remove UI → Runtime Settings L0 dependency

`src/应用壳.gd` no longer preloads or calls `src/运行时设置/L0_公理层/**`.

For corrupt/invalid persisted settings, the editable default is obtained only through:

```text
ModelRuntimeSettingsPublicInterface.validated_default_settings()
```

The recoverable visible warning remains; the default is only an editing start point and is not silently saved.

### 2. K2.7 capability truth survives invalid context

The exact transition is accepted:

```text
persisted/current candidate = Kimi K3 / 1M
open Model Settings
change model → Kimi K2.7
```

Accepted state:

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

Selecting 256K restores validity while fixed-thinking remains visible; switching back to DeepSeek/K3 re-enables graded reasoning from backend projection.

### 3. Escape / ui_cancel behaves as Cancel

While Model Settings overlay is open:

```text
ui_cancel / Escape
→ close overlay
→ return Main Menu
→ do not Save
→ restore focus to 模型设置
```

## Accepted B1 behavior preserved

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

## Validation disposition

Focused B1 suite, G4-07B/G4-08B regressions, required layouts and `git diff --check` are accepted green. Existing real Provider evidence remains valid because normal Save/provider routing was unchanged.

No correction-02 is required.