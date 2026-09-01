# G4-09P1 Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Reviewed implementation/evidence HEAD: `cf8b9cb998263ae44f6f8c2f145f78dd815ef176`  
Formal task: `docs/tasks/G4-09P1_OWNER_UAT_B_PRODUCTION_PREP_TASK.md`

## 1. Result

G4-09P1 is **PASS / CLOSED**.

The production-preparation change is narrowly scoped and satisfies the formal task without reopening gameplay semantics.

Accepted results:

- the prep utility is explicit opt-in and fixed to the accepted Public d20 package;
- it constructs the default production `SourceLibrary` and uses the public `install_expansion_pack` / current / exact / inventory seams rather than managed-filesystem surgery;
- it accepts no arbitrary package path or managed-root override and does not become a generic importer;
- the reviewed commit changes only the prep script plus evidence/UAT documentation; no gameplay, Source mechanism, persistence, Final Create, Provider, Wizard or Narrative implementation changed;
- the recorded production run reports the exact Public d20 generation installed/current and a same-generation idempotent replay;
- the recorded production inventory reports usable World/Character currents and Public d20 as the Expansion current generation;
- the prep utility has no Game Library, Final Create, runtime, persistence or SQLite entry point, so the operation has no implementation path to rewrite Owner games;
- canonical `run-game.ps1 -ValidateExportOnly` freshness validation succeeded and the second run recognized the export as current;
- the G4-08B smoke remains green;
- Provider-facing semantics are unchanged, so a new real DeepSeek call is not required for this preparation-only task;
- the Owner UAT B instructions are product-only and use the accepted Han baseline.

## 2. Production Source safety review

`scripts/G4-09P1_Owner生产Source准备.gd` requires `--confirm-owner-production-source-prep` before constructing `SourceLibrary.new()`.

The package is frozen in code as:

`res://tests/fixtures/g4_08m1/判定与检定_公开d20`

The script verifies:

```text
asset_id      exp.check_core.public_d20
asset_type    expansion_pack
version       0.1.0
capability    action_check.public_d20.v1
slot          action_resolution
```

and verifies both current lookup and exact fingerprint lookup after install.

The recorded production fingerprint is:

`e40bf3cb1059a4952d4230ae624fc3a0ba9bc705e279b13fef8cd1e795ca5ec1`

No destructive normalization of World/Character content is present in the prep code.

## 3. Owner-game safety

The reviewed prep script imports only the Source Library public interface and contains no call into Game Library, Final Create, current-game runtime, persistence or SQLite.

The task evidence records `Owner games modified: no`. I treat this as sufficient for the bounded prep task because the executable path itself cannot address Game storage. The upcoming Owner UAT additionally validates that existing product state remains usable.

## 4. Launch freshness / smoke

Task evidence records:

- first validation rebuilt a stale/missing Windows export;
- second `run-game.ps1 -ValidateExportOnly` reported the export current and skipped rebuild;
- no `.env.local` secret value was printed;
- G4-08B headless smoke exited `0` with `failures=0`.

G4-09P1 added no Provider or product UI/runtime changes, therefore accepted real DeepSeek evidence from G4-08B remains semantically applicable.

## 5. UAT readiness

`docs/g4_09/G4-09UATB_Owner产品验收说明.md` is concise and product-facing. It asks the Owner to judge the intended product gate:

> Does Public d20 add worthwhile tension, clarity or gameplay value rather than merely functioning technically?

The required route includes risky CHECK_REQUIRED play, ordinary NO_CHECK play, and Save → Main Menu → Continue persistence.

## 6. Decision

```text
G4-09P1 Owner UAT B Production Prep   PASS / CLOSED
G4-09UATB Owner Product UAT           ACTIVE — OWNER
G4-09 First Playable B                ACTIVE
G4-08 Expansion Pack v0.1             ACTIVE pending Owner verdict
G4-GATE                               NOT YET
```

No further Codex/Kimi execution is required before Owner UAT B. Do not declare G4-09 PASS, G4-08 Product PASS or G4-GATE PASS until the Owner returns an explicit product verdict.
