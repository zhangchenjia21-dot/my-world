# G4-09R1B1C01A Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed implementation/evidence HEAD: `bb3c16b392887a4649f32e23348067c70a3e7a1c`  
Formal task: `docs/tasks/G4-09R1B1C01A_RUNTIME_SETTINGS_L3_UI_SUPPORT_TASK.md`

## Result

G4-09R1B1C01A **PASS / CLOSED**.

The focused Runtime Settings support seam is sufficient for the pending UI correction and stays within the assigned backend boundary.

## Accepted implementation

1. `ModelRuntimeSettingsPublicInterface.validated_default_settings()` returns the exact validated application default `deepseek_v4_pro / 256k / high` as a defensive copy. It does not read/write the settings store and exposes no credential or transport data.
2. `inspect_candidate()` now preserves `success=false / status=incompatible_context_limit` for a known incompatible context while attaching a UI-safe partial `candidate` projection.
3. For `kimi_k27 / 1m / high`, the partial projection contains the requested context plus backend-owned capability truth: `allowed_context_limits=[256k]`, `graded_reasoning=false`, `fixed_thinking=true`, `reasoning_effective=null`, and selected-provider credential configured boolean.
4. Unknown/malformed settings still fail without partial candidate identity.
5. No endpoint, model id, request path, payload field, or credential value is returned through the UI-safe projection.
6. Provider/UI/Source/Final Create/Persistence/Public d20 paths were not modified; SQLite schema remains v4.

## Evidence reviewed

Focused mechanism tests directly assert:

- exact default and defensive-copy behavior;
- no settings-file creation from default/candidate inspection;
- no Game/Source/SQLite sentinel mutation;
- incompatible K2.7 capability projection;
- valid DeepSeek/K3 Medium→High and valid K2.7 fixed-thinking behavior remain intact;
- unknown/malformed candidate safety;
- secret/transport field absence.

The accepted B1 settings UI regression remains green. Real Provider rerun was not required because Provider/request code did not change.

## Decision

```text
G4-09R1B1 Settings UI                 CORRECTION REQUIRED
G4-09R1B1C01A L3 UI Support           PASS / CLOSED
G4-09R1B1C01B UI State Consistency    ACTIVE — KIMI
G4-09UATB Owner Product UAT           HOLD
```

C01B may now consume only the Runtime Settings L3 public seam to remove the Application Shell L0 dependency, preserve K2.7 fixed-thinking truth during the invalid 1M intermediate state, and add Escape/ui_cancel = Cancel.

Do not resume Owner UAT until C01B receives GPT Independent Review PASS and the final integration/freshness closeout is complete.
