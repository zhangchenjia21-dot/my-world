# MW-018 People Curation + Card Surface — Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**
Implementer: Codex · Revision 1 · Review Round 0
Branch: `mw-018-people-curation-card-surface`
Worktree: `D:/AI/Projects/.worktrees/my-world/mw-018`

## Exact lineage

- Refreshed implementation main: `a1af1ed7aaf2d322b3dfb8659907ba1c8927abf3`.
- Refreshed governance main: `c6d5712c075db4ab853b31a45b14fb1460d91564`.
- Formal packet product base: `73004d67ef14be2fb2bb7c386e6a89a604e93f8f`; reviewed MW-017 integration: `27519c0e11ff995df4c584e835dc0be39ee3f4d5`.
- Code + tests commit: `e9157f79860437207b73e894647be9f1278f5a74`.
- The final candidate adds only this report/evidence to that code commit. Exact candidate SHA is supplied in the final return and branch HEAD; no self-referential SHA is embedded here.
- Both remote mains re-fetched before closeout and unchanged from these bases.

## Player outcome / scope

Right information navigation is **概览 | 角色 | 重要经历 | 人物 | 存档**. Each maintained person has a separate panel: collapsed name/headline, expanded current player-known summary/relationship/details. Cards rebuild collapsed, use existing scrolling, and do not keep historical versions in the UI.

The outcome serves the long-lived world / native RPG information experience. Content-worth, relationship prose and semantic corrections belong to the model. No name matching, semantic score/router, relationship state machine, extra People call, SQLite table/migration, portraits, search/filter, historical backfill, GM-only opening curation or MW-013 host was added.

Owner UAT remains pending after GPT Independent Review, reviewed integration and canonical Owner build handoff. This report declares neither Engineering PASS nor Product PASS.

## Identity, input and persistence

The lived worker consumes MW-017 `request_evidence` only after its same-turn terminal barrier. Model-visible `people_evidence` entries contain request-scoped `actor_ref`, exact accepted GM `quote`/`gm_span`, and only the implicated actor's prior player-known snapshot when present. It sends neither the whole prior card map nor the stable roster. Canonical local IDs and the exact receipt dependency stay in the active Program envelope. No private actor material, Knowledge, Agency, Evolution or Source-current content is hydrated for this input.

One existing lived curator request now returns Character, Experiences and `people_updates`. The model response is resolved through the private ref map before persistence. Unknown/stale refs and malformed entries are dropped independently; all duplicate operations resolving to the same canonical actor are dropped. A non-array or over-eight People component becomes no-op; invalid base Character/Experiences or globally malformed JSON still fails the call. Structural ceilings follow the packet. Optional unknown snapshot fields normalize to empty strings/arrays, never invented prose.

The existing `information_curation.v0.1` owner and `turns` collection remain. Old exact `{prefix,parent,id,result}` records still use `SHA256(JSON([prefix,parent,result]))` with their original two-field result. Old records are never injected with `people_updates` before validation.

New lived records add `schema=information_curation_lived.v0.2` and `identity_receipt_id`, with result `{character,experiences,people_updates:[{local_character_id,snapshot}]}`. New identity hashes `[schema,prefix,parent,result,identity_receipt_id]`. Valid old/new IDs form the same parent chain. Empty dependency is a legitimate no-People opportunity. The dependency is revalidated on completion; if it changed, only People loses write authority while valid base curation persists. Initial/T0 normalization, IDs and recovery remain unchanged and People-free.

## Fold and disclosure seam

The internal People fold consumes validated records in accepted order, checks the exact receipt and its bound IDs through the World L3 boundary, and requires current actor applicability. Full snapshots replace prior snapshots; tombstones erase cards without touching NPCs. Dictionary insertion order preserves first-card appearance; replacement does not reorder, removal/recreation inserts anew. Receipt-invalid People parts do not rewrite the Character/Experiences ID chain.

`src/信息整理/L3_外交层/人物投影公开接口.gd` returns only the five content fields. It never returns local ID, ref, receipt, prefix/hash, provenance or storage. Leaf `src/ui/人物卡片.gd` receives only those DTOs and cannot read Runtime/Source or call a Provider. No NPC truth is rehydrated into a previously curated card.

The Shell now separately handles durable `generation_completed`: projection refresh happens synchronously when accepted history changes. Provisional regeneration retains accepted knowledge; accepted replacement immediately reverts stale People text before the new curator finishes. Restore includes People; reopen folds current storage without a Provider call. No displaced-future or Initial Character recovery path is used by People.

## Validation evidence

Machine-readable results: [evidence/results.json](evidence/results.json). Exact changed files: [MW-018_CHANGED_FILES.md](MW-018_CHANGED_FILES.md).

- Final focused suite: **135 checks, 0 failures**, real SQLite and production World/Curator/Shell seams. Covers same-name actors, private input/output canaries, mixed legacy chain, full replacement/tombstone/order, current receipt dependencies, malformed/unknown/stale/duplicate refs, failed semantic no-op, same-turn runtime actor mint, hidden changes, Save/Restore before/between versions, immediate accepted replacement, reopen/no-backfill, field bounds and base failure isolation.
- Full offline run: **16 suites + Windows export passed**. Includes MW-018, all 120 MW-017 checks, MW-014, MW-015, MW-015 R2 baseline/UI/contract, G5 materialization/timeline/Knowledge/Agency/actor registry/runtime materialization/Evolution, MW-006 and G4-07B. The original full-run MW-018 log predates eight added parser/hash checks and one visible-navigation assertion; final focused evidence supersedes its count.
- Actual Godot rendering: **127 checks, 0 failures**, before the eight parser/hash-only additions. Inspected screenshots at maximized 2560×1351, 1280×720 and 960×540. Five visible navigation controls, compact collapsed panels, per-card expansion, wrapped detail and narrow vertical scrolling are shown. First screenshot attempt exposed an incomplete test world fixture; the final images use valid world setup metadata and a visible navigation assertion.
- Final Windows Desktop export from exact code commit `e9157f79860437207b73e894647be9f1278f5a74`: exit 0, no export errors. Artifact remains under task `build/mw018/export-final/`; executable hash is recorded in results. No Owner installation was performed.
- `git diff --check` clean. New dependencies keep same-module downward direction and cross-module calls use World L3. No production persistence schema/table files changed.

Known regression exit warnings match the MW-017 independently reviewed baseline: G5-03 has 3 leaked objects / 1 resource; G5-04 has 43 / 20; G4-07B has 3 / 1. Those suites exit 0 with no assertion/script failures; MW-018 and MW-017 focused tests have no such warnings. This is not a zero-warning claim.

Commands (PowerShell 7, from task worktree):

```powershell
./tests/mw018/运行人物整理离线验证.ps1
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script 'res://tests/mw018/人物整理卡片纵向测试.gd' -- --root=<fresh-task-owned-path-containing-mw018>
# For screenshots use the same focused script without --headless, with --rendering-method gl_compatibility and user argument --visual.
./tests/mw018/运行真实人物验证.ps1
```

## Bounded real configured Provider result

[evidence/real-people-smoke.json](evidence/real-people-smoke.json) preserves exact model requests/responses, receipt and safe cards. Current Kimi K3 (`k3-256k`, high, 256k) was used unchanged. **One World semantic request + one existing lived curator request**, no retries or third request, generated a valid card for **李亭**. Owner settings/Source/Games/current DB fingerprints are identical before/after; both fingerprint files are included. The Game and accepted river-crossing interaction were synthetic task-owned data; no production Game was modified.

The card identifies 李亭 as an accompanying companion, summarizes his presence at the ferry agreement, and shows player-visible relationship/details. Its content traces to the accepted narrative rather than the private profile canary. The qualitative companion wording remains model interpretation for review/UAT.

**Observed limitation, not repaired:** the World model referenced `cand-shenqing` in `people_bindings` but omitted `candidate_ref` from the 沈青 candidate. MW-017 correctly could not resolve that transient reference, so 沈青 received no card in this smoke. The valid 李亭 binding/update survived. Same-turn new-actor card creation is separately proven offline with a well-formed candidate ref. No heuristic matching, provider switch or extra model call was added to force a second card.

## Git / Owner preservation / next gate

The Owner checkout remains on main at `643eb1a0ce44830cae10f519410a2d00241c2996`, with its pre-existing `.gitignore` modification and six screenshot import files preserved. This candidate was developed only in the required worktree. Task-generated peripheral imports were preserved in task build archives, never removed using reset/clean/force.

Next gate: GPT Independent Review of the exact clean pushed candidate. Keep the worktree through review/integration verification. Owner product acceptance follows only after reviewed integration and the canonical build handoff.
