# G4-09R1P1 Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed evidence HEAD: `f615cc49748320f346362430383e6ff074668278`

## Decision

G4-09R1P1 passes Independent Review. Runtime Model Settings v0.1 is ready on the Owner launch line and the owner-requested prerequisite before G4-09UATB is closed.

## Verified

1. Final-head real selected-provider UI verticals completed through the actual Main Menu Model Settings surface using task-owned settings/Game/Source roots:
   - DeepSeek V4 Pro -> Save -> real Opening accepted;
   - Kimi K3 -> Save -> real Opening accepted.
   No provider fallback/substitution was used and evidence contains no secret values.
2. Canonical `.\run-game.ps1 -ValidateExportOnly` detected a stale Windows export, rebuilt the existing `Windows Desktop` preset, and validated the resulting Windows build against the accepted checkout. No competing launcher was introduced.
3. Production managed Source prerequisites remain intact: World current generations = 2, Character current generations = 6, Expansion current generations = 1, and exact Public d20 `exp.check_core.public_d20` remains current with fingerprint `e40bf3cb1059a4952d4230ae624fc3a0ba9bc705e279b13fef8cd1e795ca5ec1`.
4. Owner Games were not modified. Real Provider validation did not overwrite the Owner production model preference.
5. Runtime Settings mechanism, Settings UI integration/layout assertions, Public d20 UI integration, and `git diff --check` are green. SQLite production schema remains v4.
6. R1P1 changed only UAT/readiness documentation; `src/**` has zero diff.

## Review note — Owner Entry label correction

The refreshed Owner UAT instruction used `208 赤壁前夜`, but the canonical World Source exact display name is `208｜赤壁前夕` (`entry_id = t0-208-red-cliffs-eve`). This is a documentation-only mismatch, not an implementation/runtime failure. GPT corrects the Owner UAT record during closeout; no Codex correction task is required.

The R1P1 evidence also contains the same informal `赤壁前夜` wording when describing its task-owned test route. The actual vertical is accepted because the test selects the correct entry identity; the Owner-facing instruction must use the exact UI display label.

## Accepted Runtime Model Settings v0.1

```text
G4-09R1S0 Semantic Freeze             PASS / CLOSED
G4-09R1M1 Backend Mechanism           PASS / CLOSED
G4-09R1M1C01 Projection/Kimi Proof    PASS / CLOSED
G4-09R1B1 Settings UI                 PASS / CLOSED AFTER CORRECTION-01
G4-09R1B1C01A L3 UI Support           PASS / CLOSED
G4-09R1B1C01B UI State Consistency    PASS / CLOSED
G4-09R1P1 Final Integration/Freshness PASS / CLOSED
G4-09R1 Runtime Model Settings v0.1   PASS / CLOSED
```

## Disposition

Owner UAT B may now resume. The model-settings insertion is no longer a blocker.

```text
G4-09UATB Owner Product UAT           ACTIVE — OWNER
G4-09 First Playable B                ACTIVE pending Owner verdict
G4-08 Expansion Pack v0.1             ACTIVE pending Owner verdict
G4-GATE                               NOT YET
```

Owner UAT remains a product-value gate for Public d20, not a DeepSeek-vs-Kimi benchmark. Do not close G4-09/G4-08 before the Owner returns PASS/FAIL.