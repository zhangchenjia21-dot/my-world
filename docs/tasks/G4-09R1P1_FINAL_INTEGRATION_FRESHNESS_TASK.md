# G4-09R1P1 — Runtime Model Settings Final Integration / Owner UAT Readiness

Status: **ACTIVE — CODEX**  
Parent: **G4-09R1 Runtime Model Settings v0.1**  
Owner: **Codex**  
Reviewer / semantic owner: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal reviewed code base: `b6bd6bc8e077bbeccbb8639f6bc0670795e3e36c`

Accepted UI review:

`docs/g4_09r1/G4-09R1B1C01B_INDEPENDENT_REVIEW.md`

Canonical model-settings decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

## Outcome

Prove the accepted Model Settings backend + UI are ready on the current product launch line immediately before Owner UAT B. This is validation/UAT-readiness work, not feature development.

Required final path:

```text
current main
-> actual Main Menu Model Settings
-> DeepSeek selection -> real generation
-> Kimi selection -> real generation
-> canonical Windows export freshness
-> production Source/UAT prerequisites still intact
-> refreshed Owner UAT B instructions
```

## 1. Freshness

Refresh both repository `main` branches and read current `AGENTS.md` before execution. Do not overwrite unknown newer work.

Use the canonical launcher only:

```powershell
.\run-game.ps1 -ValidateExportOnly
```

Do not add a competing launcher. If the export is stale, let the existing script rebuild it; record whether it rebuilt or was already current.

## 2. Final real selected-provider integration

On the final code line, rerun the existing real Model Settings UI vertical using task-owned Game/Source/settings roots and local credentials. At minimum prove:

```text
Main Menu settings -> DeepSeek V4 Pro -> Save -> real Opening accepted
Main Menu settings -> Kimi K3 -> Save -> real Opening accepted
```

Prefer the existing task runner under `tests/g4_09r1b1/` rather than creating a new test framework.

Requirements:

- real Provider calls, not stubs;
- actual Main Menu settings surface performs selection and Save;
- evidence records profile/display identity and accepted generation, never API key values;
- no fallback/substitution;
- if a credential/entitlement unexpectedly fails, stop and report the exact blocker rather than faking PASS.

The purpose of this rerun is final-head integration confidence; do not reopen accepted Provider/model semantics without a concrete regression.

## 3. Production UAT prerequisites

Verify, without modifying Owner Games:

- production managed Source Library still has usable World and Character generations;
- exact Public d20 Expansion remains installed/current for the UAT route;
- do not manually copy files into the managed Source Library;
- do not delete or rewrite Owner Games;
- do not overwrite the Owner's production model preference merely to run tests. Real provider tests must use task-owned settings paths.

If the Public d20 exact generation unexpectedly needs installation, use only the existing supported `SourceLibrary.install_expansion_pack(...)` / accepted G4-09P1 safe prep route. Never use filesystem surgery.

## 4. Regression floor

At minimum rerun/confirm:

- G4-09R1B1 focused settings UI suite;
- Runtime Settings mechanism suite;
- G4-08B Public d20 UI integration smoke/focused suite;
- `git diff --check`.

Do not change SQLite schema; production remains v4.

## 5. Owner UAT B instructions

Update the existing Owner UAT record under `docs/g4_09/` so the product-only route begins with Model Settings before New Game.

The refreshed route must tell the Owner to:

1. launch via `run-game.cmd`;
2. open `模型设置` from Main Menu;
3. choose the model/context/reasoning configuration they want for the play session and Save;
4. reopen Model Settings once to confirm the saved effective summary is what they intended;
5. continue the already frozen First Playable B path with Han / 208 Red Cliffs Eve / Liu Bei / Public d20;
6. exercise one risky action with a visible d20 card and one ordinary/no-risk action with no unnecessary card;
7. Save -> Main Menu -> Continue and verify the same Game/history/mechanic result persists;
8. give the final product verdict on whether Public d20 adds worthwhile gameplay.

Do not make Owner UAT a model-comparison benchmark. The real DeepSeek/Kimi dual-provider verification belongs to this task; Owner only needs to choose the configuration they want to play with.

## 6. Protected boundaries

Do not redesign or extend:

- model catalog / context / reasoning semantics;
- Provider wire or credentials contract;
- Model Settings UI design;
- Source / Composition / Final Create;
- Public d20 rules;
- persistence schema;
- G7/G8 architecture.

If a real regression is discovered, stop and report the exact seam. Do not bypass it with a workaround.

## 7. Return contract

Return:

```text
START_HEAD
EVIDENCE_HEAD / FINAL_HEAD
changed paths
real DeepSeek UI-selected generation result
real Kimi UI-selected generation result
run-game freshness result
production Source/Public d20 verification
Owner games modified: no
regression summary
updated Owner UAT instruction path
SQLite schema unchanged
READY FOR INDEPENDENT REVIEW
```

Do not declare G4-09R1, G4-09, G4-08 or Owner UAT PASS. Do not resume Owner UAT yourself.