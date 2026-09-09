# MW-028 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Identity

- Branch/worktree: `mw-028-system-public-d20`, `D:/AI/Projects/.worktrees/my-world/mw-028-system-public-d20`.
- Starting HEAD: `bf640238bedfbea50aba9362a6068e70366b3852`.
- Formal Code Base / final refreshed implementation main: `5a336d0a993fd7e91b05b98f9b0cc14d2bb47b21`.
- Production Implementation HEAD: `b62554f7d2bb623ce213328a48bb3b01fe191d15`.
- Final candidate HEAD: the documentation/evidence commit containing this return. Its exact SHA is supplied in the external handoff; the commit cannot embed its own hash.
- Final refreshed governance main: `5cce69a97352c5e20a2df131707b37897ae932a9`, current status v17.23 / roadmap v4.6 / System frozen decision v1.0. No superseding change at closeout.

## Product result

The right information host now includes `系统` between `事务` and `存档`. `近期公开判定` shows up to twelve current accepted CHECKs, newest first, with exact Program rolls, DC, modifier/reasons, stance, total, outcome and stakes. Ordinary NO_CHECK remains durable and available to GM continuity / Debug, but has no persistent player card. Empty state is `暂无公开判定记录。`.

Existing inline Narrative dice cards remain. System refresh occurs on the adjudication `finished` terminal after durable acceptance-marker commit, and through existing activation/Restore safe-panel refresh and System tab navigation. There is no polling, second mechanics store, Curator routing, new model call or fabricated character stat.

## Production changes / architecture

- `src/行动判定/L1_器件层/公开机制历史投影器.gd`: extract one `_current_records` selector. Existing GM `project()` retains its exact former output fields/text and last-twelve CHECK+NO_CHECK behavior. New `project_checks()` derives detached thirteen-field CHECK DTOs, newest first / max12, using the same selector.
- `src/行动判定/L3_外交层/公开机制历史公开接口.gd`: add read-only `project_session(runtime)` for System. Cross-module consumers use this L3; no raw Runtime/World reaches leaf UI.
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`: add payload-free `action_started` observation signal, including replay paths that make no Provider request. Existing RNG/control/storage/finished semantics unchanged.
- `src/调试观测/L3_外交层/会话调试观测公开接口.gd`: bounded pending attempt token, existing epoch/prefix guard, safe terminal-to-row mapping. Restore clears pending mechanics along with existing diagnostics. Shutdown disconnects subscriptions.
- `src/调试观测/L0_公理层/诊断展示契约.gd`: mechanics lane, closed CHECK/NO_CHECK/replay/degraded reason vocabulary and structural checks/no_checks counts.
- `src/ui/会话调试面板.gd`: Chinese count labels for those two safe fields.
- `src/ui/系统判定列表.gd` (+ UID): first-party read-only wrapped list; body20/title22. No internal IDs/control/provider/world payload input.
- `src/应用壳.gd`, `src/main.tscn`: System navigation/container and direct terminal refresh; wire observer when adjudication is composed after Debug owner creation.

No upward dependency or new cross-module internal-layer access introduced. Public projection/start subscription contracts are documented in Chinese. No unrelated shell decomposition or storage/schema change.

## Validation and evidence

All fixtures live under this task worktree. **Real Provider requests: 0. New System/Debug Provider calls: 0.** Controlled CHECK verifies only the existing control + narrative requests and unchanged deterministic RNG count. Degraded validation exercises the existing bounded control recovery path, not a new fallback.

### Focused / real window

- Final focused: **377 checks, 0 failures, exit0** (`evidence/mw028-focused.txt`).
- Final real-window: **377 checks, 0 failures, exit0** (`evidence/mw028-window.txt`).
- Exact safe values and thirteen-field shape; private canaries absent; JSON integer normalization; detached arrays; original GM context fields/values; OOC, unaccepted/replaced and conflicting branches excluded.
- Real Shell plus adjudication and SQLite: `generation_completed` observes no eligible new CHECK; following `finished` observes visible new CHECK without another tab/turn/reopen. Inline card retained.
- CHECK changed, NO_CHECK changed, accepted replay no-change, degraded accepted no-change, Provider failure and cancellation proven through observer wiring. Private payload/reason canaries do not reach Debug. Restore clears epoch; late terminal after Restore is ignored.
- Save before/after CHECK, Restore both ways, immediate player list refresh, actual session close/reopen and identical integer projection pass.
- Empty / one / twelve CHECKs, deterministic newest-first ordering, all seven nav tabs, no tab/render durable writes or d20 calls, wrapped text, vertical overflow/last-item reachability, composer access and collapsed Player Status Host.
- Screenshots at **960×540, 1280×720, 1920×1080**, single and long history, plus actual accepted-CHECK Debug panel (`system-check-debug.png`). Inspected screenshots confirm readability and operable layout. Long cards intentionally require vertical scrolling. The many-history fixture follows controlled failure/cancel tests, so its Narrative may retain their legitimate retry notification.
- Ordinary System text effective size >=20px; adjacent global gameplay typography suite also passes.

### Direct regressions

`evidence/regression-results.json` and individual logs preserve all **42** suite results:

- **40 successful**, including Public d20 contract/control/RNG/no-reroll/NO_CHECK/persistence and inline UI; MW-026 GM mechanics/OOC continuity; MW-021 Scroll; MW-022 Debug; MW-023 fonts; MW-024 OOC; MW-027 Threads; G2 and affected Save/Restore; adjacent Character/People/Recommendations.
- Two retained failures: G3-03 `opaque World JSON is not injected as Game Context`; G3-05 persistence `raw World/Prompt truth leaked into Context`.
- Both reproduced on isolated `git archive 5a336d0a993fd7e91b05b98f9b0cc14d2bb47b21`, with its own Godot import and fixtures. See `mw028-base-g303.txt`, `mw028-base-g305.txt`, `mw028-base-import.txt`. Original failure assertions preserved; no suppression or debt repair.
- Existing teardown/resource warnings remain in g4_08b, g5_03, g5_04, mw003 (two each). These suites return success; no unrelated warning cleanup.
- MW-015/MW-018 nav assertions updated from six to the authorized seven tabs; both pass.

### Final build

- Godot **4.7.2** final import: exit0, no script/parse error (`mw028-final-import.txt`).
- Fresh Windows export + `run-game.ps1 -ValidateExportOnly`: exit0, explicitly rebuilt, verified against current product input hash, no script/parse/export error (`mw028-final-export-console.txt`). No exported game launch.
- Task-only EXE / PCK / SQLite DLL exist and are nonempty; exact hashes, lengths and UTC mtimes are in `windows-artifacts.json`.
- PCK: 2,568,756 bytes; SHA256 `85E795598198A77975F7EFECFF3B2434C3C2C5A177FFD32FCB077FC0313C756B`; UTC `2026-09-09T08:02:15.9412283Z`.
- Product input hash: `0d2c94c7c7474f769cd6941e0b65cfedced1835be14ec3327009f01f34d32c75` (`my-world.freshness.json`). Production inputs unchanged between validation and implementation commit; return/evidence are docs-only.

Reproduce: `pwsh -NoProfile -File tests/mw028/运行系统验证.ps1 -Mode Focused`, then `-Mode Window`, then `-Mode Regressions`. Regression runner intentionally still exits nonzero for the two exact-baseline G3 assertions.

## Residual risks / handoff boundary

Player experiential confirmation remains deferred to Owner; this return establishes deterministic mechanics projection and controlled real-window evidence, not Product PASS. Existing G3 context assertion debt and teardown warnings remain. The shared selector deliberately retains MW-026 / Public d20 acceptance pairing rules rather than introducing another currentness authority or expanding mechanics semantics.

No merge to main. No Owner build installation. Owner canonical `.gitignore` and unknown screenshot/import sidecars were not modified. Only task-generated imports were fingerprint-checked and removed in this worktree; tracked fixture line endings restored without content changes.
