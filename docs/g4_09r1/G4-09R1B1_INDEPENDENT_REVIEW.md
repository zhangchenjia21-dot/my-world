# G4-09R1B1 Independent Review

Status: **CORRECTION REQUIRED**  
Reviewer: **GPT**  
Reviewed HEAD: `fcdcec66edad41afbb93f4a5e9cc70174402be5c`

## Result

G4-09R1B1 is not PASS yet. The main settings surface, persistence, layout evidence, and real DeepSeek/Kimi UI-to-generation vertical are accepted. Three bounded seams remain.

### A. Kimi K2.7 invalid-context UI state

If the current context is `1m` and the player switches model to Kimi K2.7, backend `inspect_candidate()` correctly returns `incompatible_context_limit`. The current failure branch disables Save and the incompatible context item, but returns before applying fixed-thinking presentation. As a result the reasoning control can remain enabled and the fixed-Thinking explanation is hidden. Any selected K2.7 state must preserve fixed-thinking UI truth, even while the selected context is invalid.

### B. UI layer boundary

`src/应用壳.gd` directly preloads `src/运行时设置/L0_公理层/模型运行时设置规则.gd` only to obtain `validated_default()` for corrupt persisted settings. Application/UI should depend on the Runtime Settings L3 public interface, not internal L0. Add the smallest L3 non-mutating default-settings projection and remove the UI L0 dependency.

For an incompatible candidate, L3 should also return enough non-secret partial capability truth for the UI to render allowed contexts and fixed/graded reasoning consistently while `success=false`.

### C. Escape / ui_cancel

The custom settings overlay wires the visible Cancel button but no `ui_cancel`/Escape path. While the overlay is open, Escape must behave like Cancel: close without saving or mutating settings/Game/Source.

## Accepted from B1

Accepted and protected absent regression: Main Menu entry; exact four model names; valid candidate preview through backend projection; Medium→actual High disclosure; valid K2.7/256K fixed-thinking UX; boolean credential status; Save/Cancel/reopen/restart persistence; no Game/Source mutation; Continue/New Game/Public d20 regressions; recorded 1280×720/960×540/maximized layout; real DeepSeek V4 Pro and Kimi K3 UI selection→persistence→real Opening generation; SQLite schema v4 unchanged.

Real Provider calls do not need rerun solely for the correction unless normal Save/provider routing changes.

## Routing

```text
G4-09R1B1 Settings UI                 CORRECTION REQUIRED
G4-09R1B1C01A L3 UI Support           ACTIVE — CODEX
G4-09R1B1C01B UI State Consistency    HOLD — KIMI
G4-09UATB Owner Product UAT           HOLD
```

Do not resume Owner UAT until both correction steps pass Independent Review.