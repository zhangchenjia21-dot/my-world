# MW-029 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Identity and authority

- Branch: `mw-029-factual-inventory`.
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-029-factual-inventory`.
- Starting HEAD / Task Packet commit: `574f6ecff87c401d35a8d9e5b95f9edbfecc4fd6`.
- Formal Code Base / refreshed implementation `origin/main`: `f6aae06f6be3be4b7fd24762a10e524b6eb9b683`.
- Implementation HEAD: `5ea0ed9e8826aa51f4900e8e96b10e8cf0c67f0e`.
- Final candidate HEAD: the documentation/evidence commit containing this return. The external handoff supplies its exact SHA; a commit cannot embed its own hash.
- Refreshed governance `origin/main`: `3c469d9826715dcdd8840f6379cc862c48ba8f77`.
- Current status v17.24 / roadmap v4.7 / Inventory frozen decision v1.0. Final fetch found no advance or superseding authority.
- Authority read: repo and governance AGENTS, current status/roadmap, Factual Inventory frozen decision, adjacent System and Debug decisions, active Task Packet. Reads expanded into accepted-input L3, context setup validation and existing test fixtures to preserve currentness and exercise actual foreground requests.

## Implemented result

`行囊` is now a read-only current possession surface between `事务` and `系统`, with `当前行囊`, exact name/summary rows and `当前没有已记录的随身物品。` when empty. Ordinary text is 20px; names/headings are 22px. Long text wraps and the existing information host scrolls. There are no item operation controls or invented initial items.

The existing World semantic request alone extracts optional Inventory ADD/UPDATE/REMOVE from accepted GM possession facts. Player assertion, environmental mentions and Source/initial Character prose do not establish inventory. Semantic judgment remains model-owned. The Program validates structure, resolves request refs and maintains version-bound storage.

- `src/行囊/L0_公理层/行囊事件契约.gd`: exact-field bounded optional response, deterministic item/event identities, persisted event structure/content validation. Limits: 8 operations, name120, summary600, ref128, current items64. These are defensive limits, not RPG capacity rules.
- `src/行囊/L1_器件层/行囊事件折叠器.gd`: current event fold, detached safe materials, fresh opaque request refs and exact ref resolution. Same-name items stay distinct. Unknown/duplicate/stale targets cannot mutate. Current-state UPDATE with unchanged material produces no mutation. Valid operations share one event; invalid targets are dropped without name guessing.
- `src/行囊/L3_外交层/行囊公开接口.gd`: shared accepted-input prefix normalization and GM hash, current player-safe projection, one common foreground context block, semantic request/candidate boundary. Leaf DTO contains only name/summary.
- World parser transfers the optional subfield without changing existing semantic-domain validation. World L2 invokes Inventory L3 after existing world/knowledge/identity processing, then persists the one combined World candidate through the existing commit. No second store or mutation path.
- Ordinary/OOC continuation and d20 control/narrative stages use the same Inventory context seam. World-only Evolution projection does not gain Inventory authority.
- Shell uses its existing semantic-terminal / accepted replacement / Restore / activation refresh. Pending extraction never displays proposed items. Tabs are exactly `概览 | 角色 | 重要经历 | 人物 | 事务 | 行囊 | 系统 | 存档`.
- Debug adds an inventory row using safe counts and terminal status. Invalid Inventory can fail while World commits successfully. Provider failure/cancel is distinguishable from committed no-change. Existing currentness suppression prevents stale callbacks from publishing as current; no artificial stale row is fabricated after an epoch boundary.

No new SQLite table, schema migration, Provider call, Source contract, Curator lane or history backfill. No new upward dependency or cross-module internal-layer access. L3 contracts and non-obvious invariants have Chinese comments. Existing Shell structure is retained.

## Deterministic and real-window evidence

Real Provider calls: **0**. All runtime exercises use isolated SQLite fixtures and existing stub adapters within the task worktree.

| Gate | Result | Evidence |
| --- | --- | --- |
| Focused | 174 checks, 0 failures; exit0; no script/parse errors or exit leaks | `evidence/focused-mw029-focused.txt` |
| Real-window | 174 checks, 0 failures; exit0; 960×540, 1280×720, 1920×1080 | `evidence/window-mw029-window.txt`, seven PNGs |
| Direct regressions | 43 suites: 41 exit0; two known Context failures reproduced on exact Formal Base | `evidence/regressions-results.json`, corresponding logs |
| Final Godot 4.7.2 import | exit0; no script/parse/import errors | `evidence/final-import.txt` |
| Fresh Windows export + ValidateExportOnly | exit0; regenerated PCK; no script/parse/export errors; launch skipped | `evidence/fresh-windows-export.txt`, `evidence/godot-export.txt` |

Focused proof covers empty baseline, ADD/UPDATE/REMOVE, no-change use, deterministic replay, same-name distinct items, exact/duplicate/unknown/stale refs, corrupt and superseded events, bounds and optional-subfield isolation. A real accepted action + controlled World response produces both world change and possession with exactly one Timeline candidate commit. UI is empty while the response is pending and refreshes after the durable terminal.

Ordinary/OOC and all tested d20 request stages contain current Inventory safe material without event/ref keys. World-only projection excludes the Inventory canary. Request derivation adds zero Provider calls. Save before/after possession, Restore in both directions, actual accepted-GM Regenerate replacement, late callback across Restore, OOC zero semantic opportunity, close/reopen and no historical backfill are covered.

One and 64-item windows at all three sizes verify effective font sizes, bounded horizontal geometry, vertical overflow and last-item reachability, accessible navigation/composer and collapsed empty Player Status Host. Tab/render operations leave durable state and semantic call count unchanged. Screenshots were visually inspected. `INVENTORY_CANARY_ONLY` in screenshots is intentional player-safe fixture item text, not hidden material. The Debug snapshot contains no item prose, refs, IDs or hidden profile canary.

The focused harness inherits existing MW-022 assertion helpers, so individual log lines retain the `MW-022 PASS` prefix; its final counter is `MW029 checks=174 failures=0`.

### Known baseline failures and warnings

Both exact Formal Base runs used a fresh `git archive f6aae06f6be3be4b7fd24762a10e524b6eb9b683` under task `build/formal-base`, imported with Godot 4.7.2 and separate disposable DB roots. No assertions were suppressed or changed.

- G3-03 `上下文恢复与界面测试.gd`: `opaque World JSON is not injected as Game Context` fails once on both candidate and Formal Base. See `evidence/formal-base-g3-03.txt` and `evidence/regressions-g3_03.txt`.
- G3-05 `恢复时间线持久化测试.gd`: `raw World/Prompt truth leaked into Context` fails once on both candidate and Formal Base. See `evidence/formal-base-g3-05.txt` and `evidence/regressions-g3_05-persistence.txt`.
- g4_08b, g5_03, g5_04 and mw003 exit0 but each reports two resource/object exit warnings. These remain visible in the regression manifest and logs; no unrelated warning cleanup was attempted.

The regression runner deliberately returns exit1 for the two baseline failures. This report does not label the full regression run green.

## Build identity

Freshness stamp time: `2026-09-09T10:11:05.6551698Z`.

Product input SHA-256: `ec3c12282eca9b58f21d3f9ad6374c651ffd1db283b071d3fa2e60935d81def6`.

Task-local PCK: `build/windows/my-world.pck`, 2,594,712 bytes, mtime UTC `2026-09-09T10:11:04.647576+00:00`.

PCK SHA-256: `746a3825017ad56f8db20f1cab0a2efd56918b330c60d99a47794e8b1f7a98da`.

`build/windows/my-world.exe` (103,035,904 bytes) and `libgdsqlite.windows.template_debug.x86_64.dll` (3,163,136 bytes) are nonempty. Exact hashes/timestamps are in `evidence/build-manifest.json`; the input fingerprint is in `evidence/export-freshness.json`. The export was generated from the product files committed in Implementation HEAD; the final documentation commit does not change them.

## Reproduction

From the task worktree, run:

```powershell
pwsh -NoProfile -File tests/mw029/运行行囊验证.ps1 -Mode Focused
pwsh -NoProfile -File tests/mw029/运行行囊验证.ps1 -Mode Window
pwsh -NoProfile -File tests/mw029/运行行囊验证.ps1 -Mode Regressions
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --import
pwsh -NoProfile -File run-game.ps1 -ValidateExportOnly
```

## Residual limits and handoff

- Real-model possession extraction granularity and whether later GM prose reliably respects Inventory remain deferred Owner/Product evidence. Deterministic tests establish storage/currentness/context/UI behavior, not varied real-model play quality.
- Existing 131072-byte aggregate World response transport limit remains. Invalid/oversized Inventory within an otherwise transport-valid response is isolated; aggregate response overflow still follows existing whole-request failure behavior.
- Current items have a defensive ceiling64; event history remains source-turn-bound inside the existing World snapshot. No history compaction or gameplay weight semantics were added.
- The full accepted prefix conservatively invalidates dependent Inventory events after earlier accepted replacement; there is no automatic semantic re-extraction/backfill.
- No Owner canonical file/build/game was modified; no main merge or Owner installation. Only this task's generated import sidecars were fingerprinted and removed; content-identical fixture import files had line endings normalized. See `evidence/task-generated-sidecars.json`.

Independent Review is pending. Product acceptance is not claimed.
