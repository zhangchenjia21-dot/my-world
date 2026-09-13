# MW-033 R1 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Lineage and authority

- R1 Starting HEAD (actual fetched task tip): `9697d6398ebbf059a4067205ce935d705ff292c4`.
- Implementation HEAD: `03a226396e14baf1ee780d9b145a72e148e6187e`.
- Final Candidate: the evidence commit containing this return; its exact SHA and remote confirmation are supplied in the handoff (avoids a self-referential commit hash).
- Implementation main: `e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`.
- Governance main: `886a8f3c4a06c9292080a0642636f31b90849a3b`, status v18.2; frozen G7 architecture v1.0.
- Re-fetched both mains and task branch before return: no authority or task-tip drift.

## Correction

Only `GameLocalOpeningContextProjector.project_continuation()` production behavior changed. P0 now explicitly formats minimum Game/World identity, selected Entry ID/name, control mode, World/GM instructions and existing durable authority/provenance framing. Nonempty opening supplement and selected Entry opening seed are two independent atomic P2 `source` blocks, labeled as T0 starting background rather than current lived truth. Existing semantic/NPC/style selection and the Context orchestrator remain unchanged.

First Opening `project()` and its helpers are unchanged. No new dependency, semantic judge, Provider call, UI change, storage/cache or truncation was introduced.

## Focused and source budget evidence

Complete MW-033 focused: **206 checks / 0 failures**, real Provider calls **0**. [Log](r1/evidence/focused.log), [R1 budget evidence](r1/evidence/r1-source-budget.json), [existing working-set cases rerun](r1/evidence/working-set-budget.json).

Each large fixture contains 80000 Chinese characters in one body (about 240 KB), while remaining valid under the full Opening character guard. Every case contains both supplement and selected Entry seed. Both bodies are independently verified as P2, and Entry ID/name as P0.

| Case | 256k actual / budget bytes | 1m actual / budget bytes | Result |
| --- | ---: | ---: | --- |
| Large supplement | 3382 / 209715 | 243489 / 838860 | 256k omits supplement whole; 1m retains exact body |
| Large seed | 3385 / 209715 | 243489 / 838860 | 256k omits seed whole; 1m retains exact body |
| Small supplement + seed | 3513 / 209715 | 3513 / 838860 | Both complete bodies retained in both profiles |

Both pressure cases retain current Character/Thread/World and required identity/instructions. Prefix and suffix absence plus source counters prove atomic omission. Final JSON messages UTF-8 bytes are checked against actual validated Settings capacity. All three actual `start_first_opening()` stub requests equal the existing complete projector-based first-Opening message payload exactly, and contain both complete bodies.

The original focused cases also reran: whole-Turn/section selection, exact budget/+1 boundary, P0 fail-loud/zero Provider starts, UI hide independence, current curation roll-off continuity, Restore displaced-future exclusion, reopen exact reconstruction, Regenerate hash invalidation and OOC preservation.

## Regression results and disclosed fixture correction

Final manifest: **49/49 suites passed**, exit 0 and zero failing assertions/script errors. [Manifest](r1/evidence/regression-results.json), [logs](r1/evidence/regressions/).

Includes G3-03/G3-05 (both repaired raw/stale Context gates pass), G4 first Opening/continuation, Public d20 CHECK/NO_CHECK/degraded Narrative, World Context/Knowledge/Agency/Evolution/currentness, MW-032, and the complete original relevant manifest. No G3 assertion was changed in R1. Restore/Regenerate/reopen evidence remains in the complete focused log and G3/G5 timeline suites.

The first regression pass exposed an invalid **MW-028 test fixture**: its inherited World and Player source projections lacked `semantic_sections`. The same fixture fails in the exact Starting HEAD projector with `invalid_game_setup`; this was not a new P0/P2 behavior difference. [Original failure](r1/evidence/mw028-original-failure.log), [old-projector comparison](r1/evidence/mw028-starting-projector-comparison.log).

The only additional test change supplies empty World/Player `semantic_sections` arrays for that fixture. All existing assertions remain intact, and production validation was not relaxed. MW-028 then passed **377/377**, and the entire 49-suite manifest was rerun successfully. This necessary fixture repair is the only scope deviation beyond the requested projector/focused tests.

Five prior nonblocking teardown-warning suites remain: G4-07B, G4-08B, G5-03, G5-04, MW-003 (two ObjectDB/resource-at-exit warning lines each). No retained failing suite. No warning suppression.

## Final build

Godot `4.7.2.stable.official.ed1daf0bf` final import: exit 0. Fresh Windows export through `run-game.ps1 -ValidateExportOnly`: exit 0; explicit rebuilt/verified message, launch skipped. No script/parse/export error or warning found in final import/export logs.

[Import](r1/evidence/import-final.log), [export](r1/evidence/export-final.log), [freshness](r1/evidence/export-freshness.json), [artifact hashes](r1/evidence/windows-artifacts.json).

- Built at `2026-09-13T14:07:32.5843210Z` from Implementation HEAD product bytes.
- Product input fingerprint: `6c50ddddbcbc29d1ff6c7648d3650f9bbcf5968b3f3404d10eef77174d5deaee`.
- EXE `build/windows/my-world.exe`: 103035904 bytes.
- PCK `build/windows/my-world.pck`: 2673612 bytes, SHA256 `ac6bf6b7d6625a16b84683031b8605141ad16e95b81e68240c04ffd2ec1363f3`.
- SQLite DLL `build/windows/libgdsqlite.windows.template_debug.x86_64.dll`: 3163136 bytes.
- Final evidence commit does not change product inputs. This export is task-local, not an Owner installation.

## Preservation and risks

All **24** known files remain byte-identical before/after testing and export: 13 tracked fixture `.import` normalization artifacts and 11 untracked import/UID sidecars. None were deleted, moved, normalized, staged or committed. [Before hashes](r1/evidence/preservation-before.json), [after hashes](r1/evidence/preservation-after.json). No unknown dirty product file was found. Local worktree intentionally retains these artifacts; it is not advertised as entirely clean.

Real Provider calls: **0**. All test Game/Source/settings mutations use isolated task fixtures. No main merge, force push, Owner build installation/launch, or Owner real-data access/mutation.

Residual risks: structural P2 omission may exclude useful starting context under pressure, as frozen and exposed in diagnostics; no semantic retrieval substitutes for omitted material. Live model long-session quality and Product acceptance remain unverified and deferred. Independent re-review is required.
