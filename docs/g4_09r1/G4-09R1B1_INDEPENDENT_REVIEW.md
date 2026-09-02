# G4-09R1B1 Independent Review

Status: **PASS / CLOSED AFTER CORRECTION-01**  
Reviewer: **GPT**

Original reviewed HEAD: `fcdcec66edad41afbb93f4a5e9cc70174402be5c`  
C01A accepted evidence HEAD: `bb3c16b392887a4649f32e23348067c70a3e7a1c`  
C01B accepted evidence HEAD: `b6bd6bc8e077bbeccbb8639f6bc0670795e3e36c`

## Final decision

G4-09R1B1 Model Settings UI / Interaction passes Independent Review after correction-01.

The original B1 implementation already established the Main Menu settings surface, exact four model names, backend-driven valid candidate projection, Medium→actual High disclosure, valid K2.7/256K fixed-thinking UX, non-secret credential status, Save/Cancel/restart persistence, layout evidence, no Game/Source mutation, regressions, and real DeepSeek/Kimi UI-selection-to-Opening generation.

The initial review found three bounded seams:

1. `K3 / 1M -> K2.7` preserved the invalid context but lost fixed-thinking presentation.
2. Application Shell directly imported Runtime Settings L0 for invalid-persisted recovery.
3. Settings overlay had no explicit `ui_cancel` / Escape cancel path.

Correction-01 closed them in two steps:

- `G4-09R1B1C01A` added L3 `validated_default_settings()` and safe partial capability projection for known incompatible context; PASS / CLOSED.
- `G4-09R1B1C01B` removed UI→L0, consumed the partial projection for state-consistent K2.7 invalid context, and implemented Escape/ui_cancel = Cancel; PASS / CLOSED.

Formal correction reviews:

- `docs/g4_09r1/G4-09R1B1C01A_INDEPENDENT_REVIEW.md`
- `docs/g4_09r1/G4-09R1B1C01B_INDEPENDENT_REVIEW.md`

## Accepted UI vertical

```text
Main Menu Model Settings
-> DeepSeek V4 Pro / V4 Flash / Kimi K3 / Kimi K2.7
-> 256K / 1M compatibility from backend
-> Low / Medium / High / Max with effective disclosure
-> K2.7 fixed Thinking ON behavior
-> non-secret credential status
-> Save / Cancel / Escape / restart persistence
-> selected-provider real generation
```

No correction-02 is required.

## Current progression

```text
G4-09R1B1 Settings UI                 PASS / CLOSED AFTER CORRECTION-01
G4-09R1P1 Final Integration/Freshness ACTIVE — CODEX
G4-09R1 Runtime Model Settings v0.1   ACTIVE
G4-09UATB Owner Product UAT           HOLD
```

G4-09R1 closes only after final-head real DeepSeek/Kimi integration and canonical Windows export freshness pass. G4-09/G4-08 remain open until Owner Product UAT.