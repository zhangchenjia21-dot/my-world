# G4-09R1B1 — Model Settings UI / Interaction

Status: **PASS / CLOSED AFTER CORRECTION-01**  
Parent: **G4-09R1 Runtime Model Settings v0.1**  
Primary owner: **Kimi**  
Reviewer / semantic owner: **GPT**

Canonical semantic decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

Accepted backend prerequisite:

`docs/g4_09r1/G4-09R1M1C01_INDEPENDENT_REVIEW.md`

Final Independent Review:

`docs/g4_09r1/G4-09R1B1_INDEPENDENT_REVIEW.md`

Correction reviews:

- `docs/g4_09r1/G4-09R1B1C01A_INDEPENDENT_REVIEW.md`
- `docs/g4_09r1/G4-09R1B1C01B_INDEPENDENT_REVIEW.md`

## Accepted outcome

The player-facing Main Menu model settings surface is accepted.

Visible logical controls:

```text
模型
上下文上限
思考强度
```

Display models:

```text
DeepSeek V4 Pro
DeepSeek V4 Flash
Kimi K3
Kimi K2.7
```

Context options:

```text
256K
1M
```

Reasoning options:

```text
Low
Medium
High
Max
```

Accepted behavior:

- UI consumes Runtime Settings L3 `inspect_candidate()` / `validated_default_settings()` rather than internal L0 policy;
- K2.7 exposes 256K-only compatibility and fixed Thinking ON, including during an invalid 1M intermediate state;
- DeepSeek/K3 Medium visibly discloses actual High;
- credential status is boolean/non-secret only;
- Save/Cancel/Escape/reopen/restart persistence is correct;
- invalid persisted settings are visibly recoverable without silent provider substitution/save;
- no Game/Source/SQLite mutation from settings;
- settings remain Main-Menu-only and outside New Game Composition/Source Review;
- 1280×720, 960×540 and maximized desktop layouts are accepted;
- Continue/New Game/Public d20 regressions are accepted green;
- real DeepSeek and Kimi selection through the actual settings surface each reached real generation.

## Final evidence heads

Original B1 evidence: `fcdcec66edad41afbb93f4a5e9cc70174402be5c`  
C01A evidence: `bb3c16b392887a4649f32e23348067c70a3e7a1c`  
C01B evidence: `b6bd6bc8e077bbeccbb8639f6bc0670795e3e36c`

## Progression

```text
G4-09R1B1 PASS / CLOSED
→ G4-09R1P1 final real Provider / Windows freshness integration
→ GPT Independent Review
→ if PASS: close G4-09R1 and resume G4-09UATB — OWNER
```

G4-09/G4-08 remain open until Owner Product UAT.