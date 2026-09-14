# MW-035 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Identity and authority

- Starting HEAD: `120062661ad419d52c36fc339cee6f226b09a78d`.
- Formal Code Base / refreshed implementation main: `0066b587f1d756b55ee18abfa5f473e78a3aeea2`.
- Implementation HEAD: `cc530f2844e51dc7a071c80f857f206f9dea0673`.
- Final Candidate: the evidence commit containing this return; exact SHA and remote equality are reported in the handoff.
- Branch: `mw-035-g7-d20-control-working-set`.
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-035-g7-d20-control-working-set`.
- Governance main: `fc6371361685e2eeaefdef5a513f21dbe64c6696`, Status v18.6, Roadmap v5.5. Frozen MW-035 architecture and Structured Output abstraction gate govern this change. No relevant drift found.
- The two existing product edits were preserved and continued under Owner authorization. No main merge, force push, Owner build installation or Owner data access/mutation.

## Implementation and boundaries

A narrow `assemble_mechanics_control` entry in the existing Context L3 composes current owner projections and calls the existing `assemble_working_set` selector. There is no second budget algorithm.

P0 contains the whole control contract, active action once, exact Expansion rules and the continuation source owner's minimum Game/World identity, selected Entry identity and instructions. P1 selection remains latest complete Turn, safe Character, hash-current World/Knowledge/Agency/Evolution, factual Inventory, Public mechanics, then remaining whole Turns. P2 contains atomic frozen supplement/seed and World/Player/NPC source sections. Literary style is excluded in both control stages; dedicated Experiences/People/Threads blocks are not added.

Character comes from the existing L3 player-safe current projection, with explicit qualitative-continuity framing. Context does not inspect raw World, reinterpret facts or read presentation preferences. Existing source, inventory, World and mechanics owners retain their contracts. The flow no longer uses the old full Opening-era projector for control; the unused instance was removed. Existing unrelated layer debt was not changed.

Control and recovery rebuild from current owners and validated runtime capacity on every request. Assembly failure stops before Provider start and therefore before RNG or mechanics commit. Request-local diagnostics contain counts, capacity, bytes, stage, selected Turn indexes and timing, not text or domain identities. Diagnostics and assembly failure state reset at each action.

Parser/schema, RNG timing, replay identity, accepted marker, retry policy and all three Narrative stage composition paths remain unchanged. No Provider/model fallback, output cap, schema/storage change, retrieval, UI or general retry framework was introduced.

## Deterministic evidence

`evidence/focused.log`: **324 checks, 0 failures, 0 real Provider calls**.

The fixture uses 21 accepted entries with long Chinese prose, old-origin current Character and World/Knowledge/Agency/Evolution, canonical factual Inventory and durable NO_CHECK history. At 256k the originating Opening is absent from the selected transcript while current owner material remains present. Each large source/supplement/seed/NPC body is 80,000 Chinese characters with boundary markers; no partial body is admitted. Separate small-body checks prove all four families remain eligible when they fit.

| Request | Safe bytes | Actual serialized messages bytes | Selected Turns |
| --- | ---: | ---: | ---: |
| 256k control | 209715 | 200198 | 10 |
| 256k control_recovery | 209715 | 200267 | 10 |
| 1m control | 838860 | 655604 | 21 |
| 1m control_recovery | 838860 | 655673 | 21 |
| Actual malformed recovery after capacity change | 838860 | 656187 | 23 |

Full family admission/omission counts and bytes are in `evidence/budget-evidence.json`. At 256k all oversized P2 bodies are omitted whole; at 1m a complete large supplement additionally fits. Counts are structural, with no semantic ranking.

Focused checks also cover:

- Exact active action once, chronological whole retained pairs, GM-only Opening without a fake user message, style/private/stale canary exclusion and safe diagnostics.
- Required Expansion and required World-instruction overflow independently fail loud with zero Provider starts, zero RNG and unchanged World/head.
- Restore excludes truly previously-current future Conversation/World. Reopen produces identical control content. Regenerate removes the old pair and latest GM-hash-bound World record.
- Malformed control triggers exactly one recovery, which reads newly committed Character and newly validated 1m capacity; second malformed starts ordinary degraded Narrative without RNG.
- CHECK rolls only after valid control, accepts once and replay does not reroll/start Provider. NO_CHECK accepts durably and replay starts no Provider. All three Narrative stages retain MW-033 style composition.

## Regression results

- MW-033 focused: **206 checks, 0 failures** (`evidence/mw033-focused.log`).
- MW-034 focused: **441 checks, 0 failures** (`evidence/mw034-focused.log`).
- **49/49 relevant regression suites passed**, zero script/parse/assertion errors (`evidence/regression-results.json` and individual logs).
- Includes G2, G3 Restore/reopen, G4 Opening and d20 CHECK/NO_CHECK/UI, World/Knowledge/Agency/Evolution, Inventory/System, MW-032 and current G6 integrations. G3-03 and G3-05 passed without weakening assertions.
- Five suites retain two exit resource-warning lines each: G4-07B, G4-08B, G5-03, G5-04 and MW-003. These match the already integrated MW-034 regression manifest/baseline-warning evidence; they are not assertion or script failures. No retained failing suite.

Reproduce from this worktree with PowerShell 7:

```powershell
./tests/mw035/运行控制工作集验证.ps1 -Mode Focused
./tests/mw035/运行控制工作集验证.ps1 -Mode Regressions
./tests/mw033/运行工作集验证.ps1 -Mode Focused
./tests/mw034/运行整理恢复验证.ps1 -Mode Focused
```

All tests use isolated fixture storage and stub adapters. No real Provider validation was required or performed.

## Build evidence

- Godot **4.7.2** final import: exit 0, no script/parse errors (`evidence/final-import.log`).
- Fresh Windows export + `run-game.ps1 -ValidateExportOnly`: exit 0; explicitly reported rebuilt and verified, launch skipped (`evidence/export-validation.log`). No PCK existed in this worktree before export.
- EXE, PCK and SQLite DLL verified; full sizes/hashes/timestamps are in `evidence/build-artifacts.json`.
- PCK: `build/windows/my-world.pck`, 2,703,004 bytes, SHA-256 `0470ca8831cae0dfd0f89e2e798664b2ca4cdbb0f6363485ac538691795d5265`, written `2026-09-14T08:22:59.884135Z`.
- Freshness input hash: `923062b432515de14e61eb674e1f85d10230f592384503e533b222f8cec6bd51`; stamp `2026-09-14T08:23:00.9287267Z`. Documentation-only evidence commit does not change product inputs.

## Preservation, deviations and residual risks

No product/test failures remain. Automated approval service twice returned a capacity error; the same authorized commands succeeded on retry. Initial focused failures were fixture errors (NO_CHECK incorrectly attached to GM-only Opening; a short Opening still fit), corrected by using a real action and a genuinely long Opening; no production validation was loosened.

Godot import generated 13 tracked fixture import-normalization changes and 11 untracked import/UID sidecars. All **24** are preserved, excluded from commits and hash-recorded in `evidence/preserved-import-artifacts.json`. Product changes are committed; the remaining dirty status consists of these artifacts. No bulk cleanup or normalization was performed.

Engineering evidence is deterministic. Real-model adjudication quality remains for independent review and later Owner UAT. Large optional background can legitimately remain omitted even at 1m. Existing World and Public mechanics owner bounds/selection remain unchanged by design. This return does not claim Product PASS or Package-8 completion.
