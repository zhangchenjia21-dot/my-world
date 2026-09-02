# G4-09UATBC02P1 — Final Windows Freshness / Owner Retest Readiness

Type: **validation / no-feature closeout**
Status: **ACTIVE — CODEX**
Owner: **Codex**
Reviewer / semantic owner: **GPT**
Parent: **G4-09UATB Owner Product UAT**
Prerequisites:
- G4-09UATBC02A PASS / CLOSED
- G4-09UATBC02B PASS / CLOSED AFTER C01
- G4-09UATBC02BC01 PASS / CLOSED

Return ceiling: **READY FOR INDEPENDENT REVIEW**. Do not declare G4-09UATB/G4-09/G4-08/G4-GATE PASS.

## Goal

Produce/validate the canonical Windows Owner build from the current final correction-02 source head before Owner focused retest.

This task must not change product behavior.

## Required work

1. Refresh both repository `main` branches and record exact START_HEAD.
2. Run the canonical Windows freshness command:

```powershell
.\run-game.ps1 -ValidateExportOnly
```

If the export is stale, allow the canonical launcher to rebuild it from the current checkout and then validate it.
3. Run the focused Public d20 UI integration suite that includes C02B/C02BC01 assertions.
4. Run `git diff --check`.
5. Confirm SQLite schema remains v4.
6. Confirm no production Source generations, Owner Games, Runtime Model Settings preference, credentials, or `.env.local` are modified.

## Protected scope

No production code changes are expected. If validation exposes a real blocker, stop and return the blocker before editing behavior.

Do not:

- change Action Adjudication semantics;
- change Provider protocol/model settings;
- add parser/model-format gates;
- alter persistence schema;
- rerun or rewrite Source/Final Create assets;
- perform another DeepSeek/Kimi benchmark solely for this freshness task.

Existing real-provider evidence from C02A remains valid because C02B/C02BC01 changed only UI projection.

## Acceptance

Return:

```text
START_HEAD
FINAL_HEAD / EVIDENCE_HEAD
Windows ValidateExportOnly result
whether stale export was rebuilt
focused G4-08B/C02B/C02BC01 result
SQLite schema v4 confirmation
Owner Games / Source / settings / credentials untouched
changed paths (expected evidence-only, or exact blocker)
git diff --check
READY FOR INDEPENDENT REVIEW
```

After GPT PASS, Owner UAT may resume as the already-planned focused reliability/responsiveness retest. The Owner is not asked to re-evaluate Public d20 gameplay value.
