# MW-026 Package 2 UAT Cleanup — Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Exact lineage

- Formal Base / refreshed implementation main: `b8b5c54eeda95b321c2c8492f3801f30991f89be`.
- Starting HEAD: `19ac57da2834d62833236458bf239c5232220bf5`.
- Implementation HEAD: `fa3452fc15d8f727239f83550098829d770e3d2f`.
- Final candidate: the documentation/evidence commit containing this report; exact SHA returned with push verification in the handoff. It has the same production tree as Implementation HEAD.
- Branch: `mw-026-package2-uat-cleanup`.
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-026-package2-uat-cleanup`.
- Governance main at start and pre-commit recheck: `0558fbd48b3ed85e8c25b9a34a47ecae24bf38bd` (status v17.20, Package-2 UAT v1.4 and frozen cleanup decision).

## Three bounded corrections

1. Mechanics L1 pure history projection, exported through L3. Uses the existing CHECK acceptance matcher (accepted marker, exact turn position and Player text, unique match); excludes OOC/opening. NO_CHECK additionally matches its durable exact Narrative. No new hash, storage or currentness owner. Output is the latest 12 accepted public records with explicit field allowlisting. Restore supplies the existing paired current World/Conversation. Both FirstOpening continuation/OOC and mechanics-owned Narrative append this factual material before the style anchor. No added Provider call.
2. Derived OOC user content uses readable `OOC / GM 指导`; historical assistant prose stays exact. Active OOC has explicit system guidance. Internal bracketed `input_mode=ooc` wrappers are no longer generated. No accepted text rewrite or output filter.
3. Recommendation Grid becomes HFlowContainer, content-width 20px choices with 40px minimum height. Actual rows determine height up to the local scroll cap. Horizontal SHOW_NEVER prevents old child minimum widths from expanding the Host on resize; buttons wrap to available width. Composer sizing and model label/draft contract remain unchanged.

Changed production files (UID sidecars accompany the two new scripts):

- `src/context/上下文组装器.gd`
- `src/main.tscn`
- `src/ui/叙事对话视图.gd`
- `src/行动判定/L1_器件层/公开机制历史投影器.gd`
- `src/行动判定/L1_器件层/公开机制历史投影器.gd.uid`
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
- `src/行动判定/L3_外交层/公开机制历史公开接口.gd`
- `src/行动判定/L3_外交层/公开机制历史公开接口.gd.uid`
- `src/首次开场/L2_流程层/首次开场运行流程.gd`

## Verification

- `pwsh -NoProfile -File tests/mw026/运行清理验证.ps1 -Mode Focused`: **41 checks, zero failures**. Current failed CHECK and stakes in action/OOC requests; mechanics-owned continuation; no private IDs/control canaries; no extra calls; real isolated SQLite Save/Restore before/after; stale Player/OOC/unaccepted/ambiguous records; NO_CHECK production context and exact Narrative matching; 12-record bound; raw accepted bytes unchanged.
- MW-024 contract + vertical tests pass: explicit mode, legacy hashes, OOC structural exclusions, Save/reopen/Restore and callback currentness. See archived regression logs.
- Real-window fixture: **105 checks, zero failures**, 960×540, 1280×720, 1920×1080; inspected all screenshots including 48-character labels. Exact draft prefill, free editing, no-send/no extra calls, keyboard scroll to fifth choice, failure/free-form route preserved.
- Direct regressions: **40 cases, 38 pass, 2 known baseline failures**. Public d20/NO_CHECK, G2/G3, MW-019/021/022/023/024/025 plus affected World/curation suites. Full outcomes and exit warnings are preserved in `evidence/regressions.json`.
- Exact Formal Base reproduces both failures without production edits: G3-03 `opaque World JSON is not injected as Game Context`; G3-05 `raw World/Prompt truth leaked into Context`. No suppression or unrelated fix. Baseline extraction used git archive; only baseline window test dimensions changed from 1600 to 1920 for like-for-like measurement. G3 tests unchanged.
- Final Godot **4.7.2** import: exit 0, no script/parse errors.
- Fresh Windows export + `run-game.ps1 -ValidateExportOnly`: exit 0, explicitly rebuilt and verified; no script/parse/export errors. EXE/PCK/SQLite DLL exist; hashes in `evidence/artifacts.json`.
- Freshness UTC: `2026-09-09T02:18:23.3265364Z`; input hash `1c25b8e99742771ded8f5b96a239855498f85ce17f28a16a61fc8cd98cd8e65b`.
- PCK SHA256: `7a8318dc8b815e199c92e25996eccdd1d153dd905c33fc94a5e3989971ba8087`.
- Real Provider: **not used** (optional). All test adapters/SQLite data isolated; no Owner game launch or build installation.
- New dependencies: mechanics L3 → L1 → existing L0. Continuation consumes L3; mechanics internal Narrative consumes L1. No new upward or cross-module internal dependency; `git diff --check` clean.

## Measured Narrative space

Same five labels, active main.tscn fixture, information panel visible. Before = exact Formal Base product tree.

| Window | Rows after | Recommendation height before → after | Narrative height before → after |
| --- | --- | --- | --- |
| 960×540 | 2 (scrollable) | 88 → 80 | 136 → 144 |
| 1280×720 | 1 | 192 → 72 | 212 → 332 |
| 1920×1080 | 1 | 192 → 72 | 542 → 662 |

No horizontal overflow; composer and Send remain reachable. Narrow windows deliberately keep bounded vertical scrolling. Long-label buttons wrap to 64px and remain scrollable. Font size is still 20px; larger titles and Narrative typography unchanged.

## Residual risks / limits

- This makes disclosed mechanics available as authoritative context; it is not a consequence engine or proof of every future model response. No real Provider trace was used. An Owner spot confirmation remains after review/integration.
- CHECK currentness intentionally reuses existing mechanics identity, not a new GM-prose hash: the durable roll remains the same roll across its permitted Narrative lifecycle. NO_CHECK already owns exact Narrative matching. No migration/backfill added.
- The two reproduced G3 baseline assertions and existing exit-time resource warnings remain, as required by scope.
- At 960×540, the compact area still scrolls; not all alternatives/long-label lines fit simultaneously. Five alternatives remain accessible, including keyboard focus.
- Owner canonical checkout/local files were untouched. Only import artifacts created in this new isolated worktree were removed after exact hash verification; existing tracked fixture imports were index-refreshed only after identical Git content hashes.

No main merge, Owner build installation, Product PASS or Engineering PASS declaration.
