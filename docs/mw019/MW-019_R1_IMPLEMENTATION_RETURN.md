# MW-019 R1 — Recommendation UX Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

Date: 2026-09-08

## Exact source identity

- Branch: `mw-019-r1-recommendation-ux`
- Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-019-r1-recommendation-ux`
- Formal base / refreshed implementation `origin/main`: `5168893109ef7d22ad3ef6b392988d602304e54c`
- Exact starting HEAD: `3f71d1017ebf037b8e221784069568a4943dd675`, clean; only the published Task Packet sits above the formal code base.
- Implementation HEAD: `23ba847169f901497a36fabe0514704969452d9e`.
- Final candidate: the evidence-only commit containing this return, immediately after implementation HEAD. Its exact SHA is returned in the delivery message after the commit exists. No production/test changes follow implementation HEAD.
- Governance main at both initial and pre-push refresh: `bfe1bce64ab919b17c94aa292b6969f84e6e3779`; shaping base `3f971103099e4b2d025704ec6f76a7371477002f`.

Both mains were refreshed. Status v17.7 still dispatches MW-019 R1, followed by the separate Context Budget correction before Owner re-UAT. Read implementation/governance AGENTS, Owner collaboration preferences, current status/roadmap, Task Packet, Five Recommended Actions original/correction decisions, Package 0 U1 and original MW-019 Independent Review. No superseding decision or materially different root cause was found.

Owner canonical checkout stays on `main` at `782daf65348f484d636d46260ac2374559cf554d`. Its pre-existing `.gitignore` change and ten untracked screenshot imports remain untouched. All existing worktrees were inspected and retained; no main merge, reset, clean, force operation or Owner installation occurred.

## Minimal implementation

The old contract emitted five strings, reused the entire string as both button text and prefill, and rendered 13px/28px clipped controls. The corrected existing lane now emits exactly five `{label,draft}` objects in one call.

- L0 validates the exact top-level/item keys, string types, five-item cardinality, normalized nonempty strings, <=48/400 Unicode characters and exact duplicate labels/drafts. It trims only edge whitespace; internal wording/newlines remain intact. Old five-string responses are rejected.
- The response ceiling is 32 KiB: five maximum-sized pairs can occupy roughly 26.9 KiB when supplementary Unicode scalars use JSON surrogate escapes. The test covers that representation as well as the exact byte ceiling. Maximum nesting becomes three (object → array → item object), with no fence stripping, repair, fill, retry or fallback.
- L1 prompt requests five independently selectable next actions, explicitly excluding a single plan split across five items. Labels and drafts are both direct model outputs. No categories, quotas, scoring, diversity/ranking classifier or plan-step detector exists.
- L2 snapshots deep-copy nested pairs. Full-prefix currentness, foreground cancellation, Restore/reopen and fail-soft behavior are otherwise unchanged. The player-visible accepted Conversation window stays <=4 entries / 24 KiB; Character/personality and private world inputs are not added.
- Existing UI buttons show `label` only, with no full-draft tooltip. Click uses the current paired normalized `draft`, replaces input, focuses it and moves the caret to the exact end. No send, d20, accepted-history mutation or second Provider call occurs.
- Heading is 16px, recommendation controls 18px with minimum 48px height, 8px vertical / 12px horizontal padding and natural wrapping. The existing two-column layout becomes one column below 560px Narrative width. A local vertical scroll container caps the area at 168px, or 56px for <=600px-high windows, preserving Narrative and free input. Its scrollbar has an explicit local 12px width because the existing theme supplies none. Keyboard focus scrolls all five alternatives into view.
- PlayerInput uses 20px and a 132–180px responsive height; Send/Cancel use 20px and minimum 72×48px. Existing theme colors and submission routes remain.

Production diff is limited to seven existing files: five Action Recommender L0–L3 files, Narrative view and its scene. Existing dependency direction and cross-module L3 seams remain; no new production module/table/persistence/Provider lane is introduced. All People identity/curation and sparse Important Experiences production files are unchanged from the integrated base. New test/runner names describe their responsibility in Chinese. Public contract comments were updated.

## Validation, in required order

Godot `4.7.2.stable.official.ed1daf0bf`; isolated task-owned data, no Owner gameplay session.

1. **Focused contract/parser/production UI: 105 checks, 0 failures**, including malformed/extra/missing/type-invalid/duplicate/oversize/old-shape/fenced responses, Unicode scalar and escaped bounds, exact multiline prefill, stale pair rejection, free input and zero extra calls. Final visual run uses 1600×900, 1280×720, 960×540 and maximized windows; 48-character labels wrap, 400-character multiline drafts remain outside controls and prefill exactly. Fifth-item keyboard reachability and visible scrollbar are asserted.
2. **13 affected regression suites: all exit 0, no assertion/parse/script errors.** MW-019 vertical/lifecycle **165 checks / 0 failures** includes opening, foreground, saved late callbacks, cancellation/failure/timeout/oversize, correction/Regenerate, Restore, reopen and nested snapshot isolation. MW-019 Send/Ctrl+Enter/d20 verifies zero click calls/rolls and unchanged submission. Other suites: G2-03, G2-04, G4-08B, G4-08M1, NO_CHECK idempotency, MW-018 R1 (**81 checks**), MW-018 card surface, MW-015 R1 (**37 checks**), MW-015 Character/Experiences UI, MW-015 R2 initial UI, G4-07B.
3. **Bounded real configured Kimi K3: exactly 2 calls, both strict paired responses accepted**, no retries/prompt adjustment/fallback. Raw responses, exact requests and normalized pairs are committed. Owner settings/Source/Games/current DB fingerprints match before/after.
4. **Final Godot import + Windows export: exit 0**, no script/parse/export errors or warnings. `run-game.ps1 -ValidateExportOnly` rebuilt and verified this task checkout's export, explicitly skipping launch. EXE, separate PCK, console wrapper and SQLite DLL SHA-256/size evidence is committed; the EXE alone does not establish script freshness.

Initial focused run exposed three layout assertions: existing responsive logic still imposed the old composer minimum, and small-window guidance crowded Narrative. Those were corrected before the final 105-check run. No production changes followed the successful focused/regression/real gates.

G4-08B and G4-07B each retain the previously recorded exit diagnostics (3 ObjectDB instances / 1 resource). These are not new assertion/script failures; baseline evidence is in `docs/mw019/MW-019_IMPLEMENTATION_RETURN.md` and `docs/mw018/MW-018_R1_IMPLEMENTATION_RETURN.md`. No such diagnostics occur in new focused, MW-019 vertical/routes, People/sparse regressions or final export. No unrelated leak fix was attempted.

### Real-model observations for GPT/Owner

Configured profile: `kimi_k3`, model `k3-256k`, effective reasoning `high`, existing `api.kimi.com` provider.

- Fixed opening deliberately exposes the sequential application/identity/registration/retrieval procedure. In **10,455 ms**, the model returns: apply through the procedure; read the notice; ask the doorkeeper; talk to the traveler; observe the surroundings. Each label summarizes its own draft. One draft may describe several connected activities, but the five items are separately selectable alternatives rather than consecutive fragments requiring selection of preceding items.
- Fixed follow-up exposes a public catalogue. In **23,466 ms**, the model returns catalogue search, application, counter inquiry, traveler conversation and reading the notice. The raw responses are unfenced and need no repair. Program performs no semantic assessment of these alternatives; these are manual observations for review, not a product verdict.
- Residual grounding risk is visible: the first traveler draft calls the traveler someone who just finished consulting archives, while the accepted scene only says they just came out. Some drafts also anticipate document/fee/rule details. These are model embellishments, not leaked private input or authoritative world mutations. They remain quality considerations; no semantic filter or invisible prompt tuning was added to suppress the evidence.

## Evidence and reproduction

Committed evidence directory: `docs/mw019/r1/evidence/` (excluded from Godot import with a local `.gdignore`). It contains focused log, 13 regression logs/results, all five visual screenshots, both raw Provider responses/requests, unchanged Owner fingerprints, final import/export logs, export freshness stamp and artifact hashes.

From this task worktree, using fresh roots:

```powershell
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --path . --script 'res://tests/mw019/推荐成对契约界面测试.gd' -- --root=build/mw019/new-focused --visual
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File tests/mw019/运行推荐修订离线验证.ps1 -Root "$PWD/build/mw019/new-regressions"
# Only after deterministic gates; exactly two configured Provider calls:
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File tests/mw019/运行真实推荐验证.ps1 -Root "$PWD/build/mw019/new-real"
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --import --quit
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File ./run-game.ps1 -ValidateExportOnly
```

Automatic approval initially rejected a broad generated-file move. It did not execute. A later narrowly scoped operation verified the exact task path, the eleven files' common creation time during this task's import, absent destinations and before/after hashes, then preserved them under task `build/mw019/r1-generated-imports/`. Owner's same-named unknown files were not touched. EOL-only fixture import noise was verified content-identical before index renormalization. No generated sidecars enter the candidate.

## Remaining risks / next boundary

- Two successful real scenes do not establish general reliability. Prior reviewed fenced-output risk remains under the same strict fail-soft policy; no global Structured Output fix is included.
- Model grounding/alternative quality, label usefulness, 10.5–23.5s observed latency and sustained-play readability need GPT/Owner review. At 960×540 with People open, the recommendation area intentionally shows about one row and requires scrolling; keyboard access and composer visibility are tested, but Owner must judge comfort.
- Existing exit diagnostics are disclosed above. Context Budget correction remains separately queued; no Character/personality/OOC/Debug/UI framework work was performed.
- Keep this worktree through independent review/integration verification. Do not merge main or install this candidate as the Owner build. Focused re-UAT follows reviewed integration of this revision and the separately required Context Budget correction.

**READY FOR INDEPENDENT REVIEW** only. No Engineering PASS, Product PASS or Owner Launch Ready claim.
