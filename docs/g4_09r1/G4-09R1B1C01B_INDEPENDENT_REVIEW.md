# G4-09R1B1C01B Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed implementation/evidence HEAD: `b6bd6bc8e077bbeccbb8639f6bc0670795e3e36c`

## Decision

G4-09R1B1C01B passes Independent Review. The three bounded B1 correction findings are closed.

## Verified

1. `src/应用壳.gd` no longer imports or calls Runtime Settings L0. Corrupt persisted settings now obtain the editable default only through `ModelRuntimeSettingsPublicInterface.validated_default_settings()`.
2. Exact transition `Kimi K3 / 1M -> Kimi K2.7` preserves both failure and capability truth from the C01A L3 partial projection: selected 1M remains visible but unavailable, Save is disabled, reasoning is disabled, fixed Thinking ON explanation remains visible, and no fake graded effective value is shown.
3. Selecting 256K restores a valid Save state while fixed-thinking remains visible; switching back to a graded model re-enables reasoning from backend projection.
4. `ui_cancel` / Escape while the settings overlay is open runs the same Cancel close path: no Save, no application exit, and focus restoration is scheduled back to the Main Menu Model Settings button.
5. Changed production scope is limited to `src/应用壳.gd`; Runtime Settings backend, Provider, Source, Final Create, Persistence and Public d20 paths are unchanged.
6. Focused B1 tests, G4-07B/G4-08B regressions and required desktop layout evidence are reported green; `git diff --check` is clean.

## Accepted B1 vertical

With C01A and C01B applied, the complete G4-09R1B1 UI vertical is accepted:

```text
Main Menu Model Settings
-> exact four display models
-> context/reasoning controls
-> backend-owned candidate projection
-> compatibility/fixed-thinking/effective reasoning disclosure
-> non-secret credential status
-> Save/Cancel/restart persistence
-> real DeepSeek/Kimi selected-provider generation evidence
```

No correction-02 is required.

## Disposition

```text
G4-09R1B1C01A L3 UI Support           PASS / CLOSED
G4-09R1B1C01B UI State Consistency    PASS / CLOSED
G4-09R1B1 Settings UI                 PASS / CLOSED AFTER CORRECTION-01
G4-09R1 Runtime Model Settings v0.1   ACTIVE pending final integration/freshness
G4-09UATB Owner Product UAT           HOLD
```

Next gate: final real selected-provider integration plus canonical Windows export freshness on the accepted code line, then refresh Owner UAT instructions. Do not close G4-09/G4-08 before Owner Product UAT.