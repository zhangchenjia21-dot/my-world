# G4-09UATBC02P1 — Independent Review

Status: **PASS / CLOSED**
Date: 2026-09-02
Reviewer / semantic owner: **GPT**
Parent: **G4-09UATB Owner Product UAT**

## Reviewed heads

- START_HEAD: `e8dfcdce26487da0ffd6967eea703b104ca907a2`
- EVIDENCE_HEAD: `f8fea02b0c77ec4ea597b31b4c721825266cfc64`
- Governance START_HEAD: `973ea6c858a9ff409b90996214890f7144ec57c4`

## Scope review

Comparison from START_HEAD to EVIDENCE_HEAD contains exactly one changed path:

- `docs/g4_09/G4-09UATBC02P1_FINAL_WINDOWS_FRESHNESS_EVIDENCE.md`

No production code, tests, launcher semantics, Provider, Source, persistence, Runtime Model Settings, schema, or Owner data were changed by this validation task.

## Freshness proof accepted

Canonical command:

```powershell
.\run-game.ps1 -ValidateExportOnly
```

First run correctly detected a stale/missing export, rebuilt the tracked `Windows Desktop` preset, verified the resulting Windows build, and exited 0. Immediate second run reported the export current and skipped rebuild, also exiting 0.

This establishes that the Owner Windows build now corresponds to the final correction-02 source line, including C02B/C02BC01 UI changes.

## Focused current-head regression accepted

Current-head G4-08B/C02B/C02BC01 integration result:

```text
127 PASS / 0 FAIL
exit 0
```

The suite directly covers safe terminal transport/credential/persistence visibility, degraded non-blocking narrative, normal NO_CHECK/CHECK_REQUIRED behavior, durable-before-narrative ordering, retry/reopen no-reroll, no-Expansion legacy route, Game preservation, and restored mechanic cards.

## Protected surfaces

Accepted evidence records identical before/after fingerprints for:

- production Source library;
- Game Library;
- Owner Games;
- runtime model settings preference;
- repository `.env.local`.

No credential value was read or printed. SQLite schema remains v4.

## Provider evidence disposition

No new real Provider run was required. C02A already proved real selected-provider DeepSeek NO_CHECK and Kimi CHECK_REQUIRED paths. C02B and C02BC01 only changed UI projection of existing terminal result codes; P1 changed no product behavior.

## Verdict

**PASS / CLOSED.**

Correction-02 is now engineering-complete and current-head Windows freshness is satisfied. Resume only the already-planned focused Owner reliability/responsiveness retest:

- ordinary action reaches free-form narrative and visibly streams;
- risky action still shows the durable d20 result before free-form result narrative;
- model control formatting cannot dead-end play;
- genuine terminal failures show a safe reason and remain retryable;
- no duplicate turn/card/reroll;
- Save/Continue remains intact.

The Owner is not asked to re-evaluate the already accepted question of whether Public d20 gameplay is worthwhile.

Do not close G4-09UATB, G4-09, G4-08, or G4-GATE until the Owner returns the focused product verdict.