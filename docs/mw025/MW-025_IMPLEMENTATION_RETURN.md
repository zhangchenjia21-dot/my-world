# MW-025 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Identity / current authority

- Branch: `mw-025-character-guided-recommendations`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-025-character-guided-recommendations`
- Formal Base / refreshed implementation main: `ad0f3bc7fcd6edc6175121df2cf079efa1c3a493`
- Starting HEAD: `4d2a5042bb0234fa093e0d33f88ba6797b0fc12e` (new task worktree, clean).
- Implementation HEAD: `0be20d7e39f061a390fb56598a61990d1495a353`
- Final candidate: documentation-only child containing this return. Its exact SHA is verified against the remote and supplied in the final delivery message (a Git document cannot contain its own commit hash).
- Governance main: `98128b43bc599e94300b01df20273856bf044a72`, current status v17.17, roadmap v4.4 and Frozen Package-2 interaction architecture. Both mains refreshed again before final submission; unchanged.
- Read repo/governance AGENTS, Owner preferences, Task Packet and all listed Source Manifest authorities, MW-024 review/integration, and current agent-task-packet skill. The stale repo stage table is superseded by current status/packet; no materially superseding architecture found.

## Product outcome / changed ownership

Recommendations now use the current player-visible Character as soft context, alongside typed accepted Conversation and the latest final accepted role action. The model is explicitly free to suggest reasonable deviations, experiments, challenges to old tendencies and growth. Free-form action remains primary.

Production changes are limited to four files:

1. Action Recommender L3 composes a small reader through `信息整理/L3_外交层/角色经历投影公开接口.gd`, returning only `.character`.
2. Action Recommender L2 reads it once when preparing the ordinary request. No Character-change subscription, new hash, barrier, retry or second request.
3. InputBuilder adds `current_character`, `latest_accepted_role_action`, and existing typed `conversation`. It searches accepted entries structurally by action mode; OOC/opening/unsent drafts are not role-action evidence. Original accepted-prefix identity is untouched.
4. Only the lived Curator instruction is strengthened: final accepted action is behavioral evidence, not a mutation command; ordinary action may return character=null; isolated unusual behavior does not mechanically replace personality; model judges meaningful changes against current Character and Narrative.

No UI production file, parser contract, initial Curator instruction, People/Experiences schema, storage, SQLite, accepted normalization/currentness owner or Debug architecture changed. Cross-module Character access stays through public L3; lower recommendation layers receive safe material only. No semantic scoring/classification/ranking or generic framework was added.

## Bound / timing policy

- Input capacity remains **24576 UTF-8 bytes**; recent Conversation maximum remains four entries.
- Complete safe Character and latest final action are fixed material. Entries are added newest-to-older whole. If fixed material + latest entry cannot fit, the ordinary opportunity becomes unavailable with zero Provider calls; there is no truncation, summary or capacity increase.
- Latest prior action remains evidence even after several accepted OOC turns have moved it outside the recent-four window.
- Request uses the Character current at request start. Same-turn later Curator commit neither starts a second call nor invalidates an otherwise-current response. Next opportunity/reopen naturally reads the new Character.
- Accepted Conversation prefix/serial/Restore remain the only recommendation stale authorities.

## Deterministic / window evidence

Commands: `pwsh -NoProfile -File tests/mw025/运行角色推荐验证.ps1 -Mode Focused`, `-Mode Window`, `-Mode Regressions`.

- **Focused 54 checks / 0 failures**, zero script errors or exit warnings: `evidence/mw025-focused.txt`.
- Real Runtime/SQLite/World/Curator/Recommender composition proves request starts while World and same-turn Curator are unfinished; current snapshot + accepted action; later Character commit has no second call and original response remains ready; next opportunity sees updated Character.
- Captured lived Curator input contains exact final accepted Player action and non-mechanical evidence instruction. Controlled character=null remains valid. Cancelled/failed attempts and OOC create no lived evidence; clicked-but-unsent recommendation produces no Curator request or durable mutation.
- Hidden profile/Knowledge/Agency/Evolution/Source/credential/storage-metadata canaries do not enter recommendation material. Current safe Character does enter.
- Exact 24KiB and +1-byte cases, oversized fixed material zero-call path, no prior action => null, prior action outside four recent OOC entries, Restore stale callbacks and actual reopen one fresh current-Character request covered.
- **Real window run 52 checks / 0 failures** (before the two additional budget/call-count assertions), at 960×540, 1280×720, 1920×1080. Screenshots inspected at all three sizes: `evidence/feedback-*.png`. Real main scene click ensures action mode + exact draft + no-send; composer stays editable. Existing vertical scrolling/readability remains unchanged.

## Direct regressions / exact baseline exceptions

**37/39 suites passed**; `evidence/regressions/results.json` and all logs retained. Covers MW-024 contract/vertical, MW-019 strict pairs/lifecycle/Send+d20, MW-014/015/017/018 and sparse milestone semantics, MW-022 Debug, MW-023 typography, G2, G3, Public d20, G5 World/Identity/Agency/Evolution, MW-021 scroll.

The two failing assertions were freshly reproduced using a git archive of exact Formal Base `ad0f3bc7fcd6edc6175121df2cf079efa1c3a493`, independently imported and run with new isolated databases:

- G3-03: `opaque World JSON is not injected as Game Context`.
- G3-05 persistence: `raw World/Prompt truth leaked into Context`.

Evidence: `baseline-g3_03.txt`, `baseline-g3_05.txt`. The regression runner still returns failure for them; no suppression or unrelated Context fix. Existing resource-exit warnings remain in g4_08b, g5_03, g5_04 and mw003 (two warning matches each); focused/window are clean.

Only the old MW-019 exact input-budget fixture overhead changed to account for the newly required fixed keys; parser/output bounds and assertions were not weakened.

## Bounded real Provider / product evidence

`tests/mw025/运行真实角色推荐验证.ps1` ran **two total real background requests**, both ordinary Recommender calls, each with one network attempt using `k3-256k`. Both returned ready with strict five label/draft pairs: **23361 ms** and **9724 ms**. World and initial Curator used stubs; no real Narrative/World/Curator call, retry or fallback. Evidence: `real-character-recommendations.json`, `real-provider.txt`.

Fixed scene/action, different safe Character:

- The patient travelling healer received suggestions about herbs, care, helping and practicing expression.
- The curious travelling student received exploration, route questions and local-culture suggestions.

Manual observation supports that Character is consumed; outputs remain independent alternatives. This is not a semantic score or Product PASS. Some drafts extrapolate small unstated scene details (e.g. wet belongings, other people or pounding herbs), and visible deviation/growth quality is not conclusively established by two samples. Those are explicit combined Package-2 UAT risks, not grounds for adding a Program heuristic. No optional real lived-Curator example was run; its evidence handling is structurally tested, not claimed semantically proven by a live sample.

## Final import / fresh Windows export

Godot **4.7.2 stable official** final import and fresh Windows export via `run-game.ps1 -ValidateExportOnly` succeeded, with no script/parse/export errors in final logs. Exported game was not launched or installed to Owner.

First build attempt failed when Godot scanned task-owned deep Source fixture paths because build lacked `.gdignore`. Failure logs are retained (`import-attempt-1.txt`, `export-attempt-1.txt`). Added task build ignore and made the test runner establish it; the corrected import/export succeeded without production changes.

- Built UTC: `2026-09-08T10:52:11.3402083Z`.
- Product input SHA256: `5ba38b39f609e2b53c54344b5db36041acdc20d0ae20ffe076e33e81144030e6`.
- PCK: `build/windows/my-world.pck`, **2523768 bytes**.
- PCK SHA256: `3a9ac851f8a2f041f9549e51faa6d33c8392552aa80505beed5ea4762567f180`.
- EXE/PCK/SQLite DLL hashes and times: `export-artifacts.json`; freshness: `my-world.freshness.json`.

## Preservation / residual risks / next gate

Owner canonical checkout was neither updated nor installed. Its `.gitignore` modification and original ten untracked sidecars remain. Task-generated import files were identified from the initially clean worktree and verified initial-import creation window/hashes before cleanup. Automatic review first rejected cleanup for insufficient provenance; after read-only exact-path/time/hash verification, the bounded cleanup was approved. No unknown Owner file was deleted, moved or overwritten; no reset/clean/force update occurred.

Remaining: two exact-baseline G3 assertions, existing teardown warnings, real recommendation grounding/deviation quality and long-session Character feedback need Owner judgement. Oversized complete Character/action input deliberately yields unavailable guidance under the frozen bound; free-form action stays available.

No main merge, Owner build installation, Engineering PASS or Product PASS declaration. After GPT Independent Review/integration, proceed to the single combined Package-2 Owner UAT as governed by the packet.
