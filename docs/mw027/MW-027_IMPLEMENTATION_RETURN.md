# MW-027 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Candidate identity

- Branch/worktree: `mw-027-open-threads`, `D:/AI/Projects/.worktrees/my-world/mw-027-open-threads`.
- Starting HEAD: `b687cfc29f65637424e8b05bbba6c50e332e0999`.
- Formal implementation main: `5820c20b1150cd998b626e56fce79c023004b5ec`.
- Implementation HEAD: `bc12dbd318b3375110dc4d867cfd118d55b92477`.
- Final candidate HEAD: the documentation/evidence commit containing this return; exact SHA is supplied in the external handoff (a commit cannot embed its own hash).
- Governance main re-fetched before closeout: `ba0c3bcd115c40d0673f6b4af04d20eabd04ceb4`; status v17.22 / roadmap v4.5. Both mains unchanged at final refresh.

## Implemented behavior and files

The existing lived Information Curator now maintains Open Threads in its single call. Model selects/updates/removes unresolved matters. Program only validates bounds, stores current records, folds the snapshot, and presents it. No semantic classifier, quest state, extra Provider lane, historical backfill, initial-profile seeding, or new SQLite schema/table.

Production files (plus UIDs for new scripts):

- `src/信息整理/L0_公理层/信息整理契约.gd`: v0.2/v0.3 original-shape validation and version-bound IDs; bounded Threads shape.
- `src/信息整理/L1_器件层/信息整理响应解析器.gd`: optional field compatibility; malformed explicit Threads rejects the atomic response.
- `src/信息整理/L1_器件层/事务快照投影器.gd`: current validated chain fold, null/missing keep, array replace, empty clear.
- `src/信息整理/L2_流程层/回合信息整理流程.gd`: current safe snapshot and minimal semantic instructions in existing request.
- `src/信息整理/L3_外交层/信息整理公开接口.gd`: contract documentation.
- `src/信息整理/L3_外交层/事务投影公开接口.gd`: detached title/summary/details only.
- `src/ui/事务列表.gd`, `src/应用壳.gd`, `src/main.tscn`: sixth tab, empty/non-empty read-only view, wrap/scroll, 20px text / 22px title.
- `src/调试观测/L0_公理层/诊断展示契约.gd`, `src/调试观测/L3_外交层/会话调试观测公开接口.gd`: lived Threads terminal, safe before/after comparison and total count only.

Cross-module consumers use L3. Leaf UI has no Runtime/World input. Old pre-People and v0.2 IDs remain verified using original structure; v0.3 binds open_threads and existing receipt dependency. OOC and initial lanes do not create Threads. Stale People receipts suppress People only; current Threads remain independently valid within the shared accepted prefix.

## Validation

- Focused deterministic suite: **152 checks, 0 failures** (`evidence/mw027-focused.txt`). Includes frozen independent v0.2 hash, v0.3 tamper/currentness, null/replace/clear/missing, shape/caps, safe canaries, initial/OOC isolation, one shared call, failure/timeout/cancellation, stale replacement, Save/Restore/reopen, Debug and UI.
- Real-window fixture: **152 checks, 0 failures** (`evidence/mw027-window.txt`). Screenshots at 960×540, 1280×720, 1920×1080, Debug, and overflowing 12-thread narrow-window list. Inspected for readability/operability; actual fonts >=20, last item reachable with vertical scrolling, navigation/composer remain usable. All fixtures isolated, no Owner Game.
- Direct regression batch: 41 suites; initial batch 38 successful, 3 failures. MW-015 was a superseded five-tab assertion, updated to six and rerun successfully (`mw027-mw015-rerun.txt`). Effective result: **39 successful, 2 reproduced baseline failures**. Original batch results/logs retained without rewriting.
- Baseline G3-03 assertion: `opaque World JSON is not injected as Game Context`; G3-05: `raw World/Prompt truth leaked into Context`. Both reproduced from `git archive 5820c20b1150cd998b626e56fce79c023004b5ec` in isolated formal-base checkout (`mw027-base-g303.txt`, `mw027-base-g305.txt`). Not repaired or suppressed.
- MW-015 R1/R2, MW-018/R1, MW-022, MW-024, MW-025, MW-026, MW-021 and affected Narrative/d20/World/Identity/Agency/Evolution/persistence gates passed. Existing teardown warnings remain in g4_08b/g5_03/g5_04/mw003 logs; no unrelated warning cleanup.
- **Real Provider calls: 0.** Deterministic stubs verify one existing lived Curator call per opportunity and zero dedicated Threads calls. Model semantic quality is not established by these tests.
- Final Godot **4.7.2** import: exit 0, no script/parse errors (`mw027-final-import.txt`).
- Fresh Windows export / `run-game.ps1 -ValidateExportOnly`: exit 0; explicitly rebuilt and verified, no script/parse/export errors; game not launched (`mw027-final-export-console.txt`).
- EXE/PCK/SQLite DLL exist, nonempty. Artifact hashes/timestamps in `windows-artifacts.json`; input fingerprint in `my-world.freshness.json` binds the unchanged implementation product inputs.
- PCK SHA256: `7715B79A6FA95C3972DDFB293D850E8ECACB25EA8647B33D1D6A038E8D033618`; 2,552,776 bytes; UTC `2026-09-09T05:04:54.2644970Z`.
- Build exists only under task `build/windows`; Owner canonical checkout/build was not installed or modified.

Reproduce with `pwsh -NoProfile -File tests/mw027/运行事务验证.ps1 -Mode Focused`, then `-Mode Window`, then `-Mode Regressions`. The full regression runner intentionally still returns failure for the two documented baseline assertions.

## Remaining risks / review boundary

No real Provider semantic sampling performed; whether the model consistently selects useful unresolved matters remains independent review / Owner UAT work. Existing aggregate 65,536-byte response bound still applies in addition to per-field caps; oversized combined output fails safely, with no repair/retry. G3 baseline context assertions and pre-existing teardown warnings remain. No Product PASS claim, no main merge, no Owner build installation.