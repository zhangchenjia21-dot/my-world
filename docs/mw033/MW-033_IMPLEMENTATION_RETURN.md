# MW-033 — Narrative Working-Set Orchestrator v0.1

Status: **READY FOR INDEPENDENT REVIEW**

## Exact task identity

- Branch: `mw-033-g7-narrative-working-set`.
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-033-g7-narrative-working-set`.
- Formal Base / refreshed implementation `origin/main`: `e876e217f0220fdc6a577cd0b52143dc8d5b6b5c`.
- Starting HEAD / Task Packet: `dc6c46d952ba0b63a8f713e9388896969cd71f7d`.
- Production Implementation HEAD: `d6ebe8ca2ac23ec589ca266c104470888e6daa4f`.
- Final Candidate HEAD: the commit containing this report, reported exactly in the final delivery and verified against the remote tip. Its production bytes equal Implementation HEAD; this last commit contains evidence/report plus one test EOF whitespace cleanup. Self-embedding the final commit SHA would change that SHA.
- Governance `origin/main`: `fc27679efee3988e2352e52664b2b46139a9223a` at start and pre-push refresh. Current Status v18.1 explicitly dispatches MW-033; Roadmap v5.1 and frozen G7 Narrative Working Set v1.0 govern. Roadmap's older dispatch-summary wording is superseded by current Status and this Task Packet. Neither main nor task branch advanced during implementation.

## Outcome and ownership mapping

Ordinary created-Game Narrative now calls `ContextAssemblyPublicInterface.assemble_session()` and gets one globally budgeted message array. First Opening still uses its original exact full frozen setup and `assemble_first_opening_messages()`; no long-session omission is applied there.

| Owner / changed path | Contribution / responsibility |
| --- | --- |
| `src/context/上下文组装器.gd` | Pure Narrative-only P0/P1/P2 whole-block selection, final JSON UTF-8 accounting, chronological rendering and safe statistics. Existing `assemble_messages` remains for non-Narrative/legacy contracts. |
| `src/context/L3_外交层/上下文组装公开接口.gd` | Single continuation entry gathers public domain projections and runtime settings; never accesses raw `world_state` or presentation preferences. |
| `首次开场/L1_器件层/游戏本地开场上下文投影器.gd` + new `L3_外交层/续玩来源上下文公开接口.gd` | Continuation source blocks from exact Game-local setup. Required Game/World/GM identity/instructions are separate from T0 sections, authored NPC sections and non-factual style reference. Each source section retains its own header. Invalid source shapes fail safely. |
| new `信息整理/L3_外交层/叙事整理上下文公开接口.gd` | Current Character, Experiences, People and Threads through existing validated projections; cards remain whole and in owner order. No subject/thread IDs, presentation keys or request refs. People explicitly remains player-known memory/reputation, not actor existence. |
| `世界回合/L3_外交层/世界回合上下文公开接口.gd` | Thin session projection reuses unchanged accepted-hash/currentness filters for World/Knowledge/Agency/Evolution. |
| `行动判定/L3_外交层/公开机制历史公开接口.gd` | Thin current mechanics text projection. Inventory uses its existing public text projection unchanged. |
| `首次开场/L2_流程层/首次开场运行流程.gd` | Continuation delegates to Context; first Opening remains unchanged. |
| `行动判定/L2_流程层/公开D20行动判定流程.gd` | Its Narrative stages also delegate to the same Context owner, carrying the already-decided outcome/instruction as P0. Control/control-recovery protocols remain unchanged. No extra Provider call; Narrative assembly failure returns before Narrative Provider start. |

Seven existing production files changed, two narrow public projection files added (plus Godot UIDs). G3 tests and a dedicated MW-033 focused/runner vertical are included. No UI implementation, SQLite/schema migration/cache, Source-current lookup, semantic ranking, output `max_tokens`, model routing or reliability middleware.

## Structural policy and failure matrix

Selection is deterministic:

1. P0: GM protocol/current input mode/current attempt plus exact minimum Game/World instructions; mechanics owner may add a required already-decided instruction.
2. P1: newest complete accepted Turn, then current Character/Threads/World/Inventory/mechanics in stable family order, then remaining Turns newest-first. This simple interleave prevents transcript from starving all other current P1 families.
3. P2: Experiences, People, source/NPC background, style. Domain order is preserved; no content scoring.
4. Selected Turns render chronological. A candidate that cannot fit is omitted whole; there is no character/byte slicing, partial Turn or partial card.

| Condition | Result |
| --- | --- |
| Invalid current runtime/settings/source | Explicit assembly failure; no fallback budget/source. |
| P0 exceeds safe budget | `required_context_overflow`, no `messages` payload; production Narrative UI starts Provider zero times. |
| P1/P2 exceeds remaining budget | Whole unit omitted; safe family diagnostics record `budget`. |
| Empty/not-current domain output | No fabricated block; family records `empty_or_not_current`. |
| Restore/Regenerate/reopen | Rebuild from current canonical owners; no persisted request/working-set cache. |
| UI hide/recover | Never enters Context inputs; messages remain unchanged. |

Budget comes from current validated Runtime Settings `context_budget_metadata()`; tests use isolated settings files and the same public metadata seam. Final `JSON.stringify(messages).to_utf8_buffer().size()` is measured including system content, role/envelope syntax, escaping and separators. Family byte counters describe encoded atomic bodies/message groups; they are not a replacement for the authoritative final payload count. Protocol/current attempt cost and selected Turn count/range are explicit diagnostics. No generated output cap is added.

## Deterministic and budget evidence

Focused: **107 checks / 0 failures**, exit 0, script errors 0, exit warnings 0. [Log](evidence/focused.log), [budget measurements](evidence/budget-evidence.json).

| Profile | Context ceiling | floor(ceiling × 0.80) | Actual messages bytes | Selected Turns |
| --- | ---: | ---: | ---: | ---: |
| 256k | 262144 | 209715 | 198976 | 10 |
| 1m | 1048576 | 838860 | 714501 | 21 |
| 256k exact boundary | 262144 | 209715 | 209715 | 0 |
| One additional card byte | 262144 | 209715 | 1431 after whole-card omission | 0 |

The production-shaped fixture contains a 100000-character background section and 21 accepted Turns. 256k omits that complete background and older transcript while retaining current Character/Thread/People/Experience/World from owner projections; 1m admits the whole background and all 21 Turns. Assembly measured approximately 25.6 ms / 29.1 ms in this fixture; this is local evidence, not an extreme-scale performance guarantee.

Focused also proves:

- exact first Opening payload equality with the existing full projector;
- real Runtime/SQLite current curation and World contributions;
- an old curation-origin Turn is outside the selected transcript but current curation survives;
- referent-only People inclusion does not change actor roster;
- three surface hides cause zero model-message change;
- current World marker enters, stale hash marker stays out;
- displaced future markers enter the request before Restore, then disappear from transcript/curation/World afterward;
- reopen reproduces the same current messages without persisted request bytes;
- accepted Regenerate replacement invalidates the old GM-bound World contribution;
- both oversized current attempt and oversized required instruction fail;
- real Narrative view `_start_request()` starts zero Provider requests on P0 failure;
- OOC request labels preserve accepted originals and the input projection;
- invalid frozen NPC projection fails without a script error;
- diagnostic evidence contains no private prose/IDs.

## Regressions and real window

**49 / 49 regression suites passed**, no retained failing suite. [Manifest](evidence/regression-results.json), [logs](evidence/regressions/).

Coverage includes G2 Conversation/Context, G3 persistence/Save/Restore/Recovery, G4 first Opening/created-Game continuation, d20 CHECK/NO_CHECK/UI, G5 World/Knowledge/Agency/Evolution/currentness, MW-014/015/017/018/019/020/021/022/023/024/025/026/027/028/029/030/032.

G3 repair results:

- G3-03 UI/Context **exit 0**: a real durable opaque-payload fixture seeds `provider_messages`, `accepted_turns_json`, `materialization_json` and canaries. Fresh working-set messages exclude them while retaining a legitimate derived Game identity block and all budget-fitting whole current Turns.
- G3-05 persistence **exit 0**: reciprocal Recovery retains only the current branch, rejects the displaced marker/raw whole World/persistence payloads, and permits legitimate derived identity Context. A second Recovery rebuild proves the first branch request is not retained.
- Neither test is expected-fail, and `Current Game Context` was not removed from production to satisfy an old assertion.

Five suites retain teardown warnings (two ObjectDB/resource warning lines each): G4-07B, G4-08B, G5-03, G5-04, MW-003. They exit 0 with no failing checks; no warning suppression added. Raw local logs remain intact; archived log trailing whitespace is normalized only for Git hygiene.

Real-window: **484 checks / 0 failures**, exit 0, at 960×540 / 1280×720 / 1920×1080, using the existing real `main.tscn` host fixture. Ordinary font >=20px, navigation/scroll/hide recovery/composer/recommendations remain operable. [Log](evidence/window.log), [three visually inspected screenshots](evidence/window/). The full local window fixture has 27 screenshots. No visual redesign.

Focused final additions (source-shape rejection/diagnostic fields) were validated after the initial regression start; they do not alter the passing valid-source selection policy or UI layout. Final import includes these additions.

**Real Provider calls: 0.** All model responses are stubs; Game/settings/preference mutations in tests use task-owned isolated roots. Live long-session coherence remains a later concentrated Product test.

## Build evidence

Godot `4.7.2.stable.official.ed1daf0bf` final import: **exit 0**. Fresh Windows export + `run-game.ps1 -ValidateExportOnly`: **exit 0**, explicitly rebuilt and verified, game launch skipped. No script/parse/export error or warning found. [Import](evidence/import-final.log), [export](evidence/export-final.log).

Built at `2026-09-13T09:56:05.1021140Z`; product-input fingerprint `e97bfec92f2f0e1cbf7856189c0913ab05086bb9f7bac8046f0931e8e931d9e7`. Product bytes equal Implementation HEAD and final candidate. [Freshness](evidence/export-freshness.json), [artifact details](evidence/windows-artifacts.json).

- EXE: `build/windows/my-world.exe`, 103035904 bytes.
- PCK: `build/windows/my-world.pck`, 2670124 bytes; SHA256 `895cd97742e7c3fe4f9a54253f55fc1235874a2053d78a356076dff2ca73d64d`.
- SQLite DLL: `build/windows/libgdsqlite.windows.template_debug.x86_64.dll`, 3163136 bytes.

## Architecture / preservation / remaining risks

New cross-domain calls use L3 public seams. The source-specific decomposition stays with its owner L1; current curation remains with existing validators/projectors. Context handles only request-derived values and cannot mutate World/Conversation/Timeline. No new upward dependency, semantic judge or second Context owner was introduced. New business source files use Chinese names and contract comments.

No main merge/force push, Owner installation/launch, or Owner real Game/Source/settings/preference mutation. Owner canonical checkout was not updated.

Automatic approval rejected a proposed bulk sidecar cleanup/fixture line-ending normalization. That command did not execute. The safe alternative preserves all such files: 11 untracked import/UID sidecars and 13 fixture imports whose Git-normalized content equals HEAD. They are not in the task commit; [read-only preservation hashes](evidence/preserved-import-artifacts.json). Consequently the local worktree is not advertised as completely clean, although there are no uncommitted product changes. The final test-only EOF cleanup is included with this report.

Residual risks: whole-block structural selection can omit useful P2 background/People under pressure; this is visible in diagnostics and is not replaced with semantic ranking. Conservative byte accounting deliberately leaves capacity unused. Very large sessions may need later measured optimization; no speculative retrieval or durable cache was added. Live model coherence, G7 Product acceptance and deferred MW-032 Product confirmation remain unclaimed.
