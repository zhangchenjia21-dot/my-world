# MW-015 R1 — Sparse Important Experiences Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

Date: 2026-09-08

## Exact source identity

- Branch: `mw-015-r1-sparse-milestones`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-015-r1-sparse-milestones`
- Formal code base / refreshed implementation main: `2680b2616db69987a451c9d1bf53b24339a9c7cb`
- Exact starting HEAD: `d7e0826c655d0d74e28de1ae67b74f8e08753502`, clean. The published task branch adds only the formal Task Packet to the code base.
- Implementation HEAD: `aca189b35f5539a190e17a32590c5ca867459df3`
- Final candidate: the evidence-only commit containing this report, directly after implementation HEAD. Its exact SHA is returned in the delivery message once this commit exists. No further production/test changes are included.
- Governance main at start: `5ca3407c94ff42bf671ae63a699b9a8317fe78ec`; pre-push refresh: `621beb52efae65680a40f49caa929087c6049d2b`.
- Packet shaping governance base: `43be10f08564f1f82a1ad2028861cf98ed802aaa`.

Both mains were refreshed before work and before delivery. The final governance update changes status v17.5 → v17.6 and adopts the 2026-09-08 development audit. That decision explicitly keeps current MW-015 R1 uninterrupted, queues context-budget correction after MW-019/before re-UAT and forbids expanding this train for unrelated People UX or broad refactoring. It does not supersede the sparse milestone decision. Implementation main and the remote task branch remained unchanged before push.

Read current implementation/governance AGENTS, Owner collaboration preferences, Task Packet, current status/roadmap, sparse milestone correction, Character/Important Experiences decision, Model-driven Information Curation authority, Package 0 Owner UAT U1, and integrated MW-018 R1 Independent Review/integration evidence. Latest audit adoption was read on refresh. Current correction/status supersede older route summaries where their stage labels lag.

## Root cause and minimal change

Inspection confirms the existing contract/parser/projection already permits `experiences=[]`, independent Character and Experiences output, and durable successful no-op receipts. Program does not auto-append a recap or require a Character mutation before accepting an experience. No materially different mechanism requiring a stop was found.

Production change is confined to **the lived `INSTRUCTIONS` string in one existing L2 file**, `src/信息整理/L2_流程层/回合信息整理流程.gd`:

- Most ordinary accepted turns should produce `experiences=[]`; empty is a normal successful outcome.
- The model judges whether omitting an event would materially weaken a future explanation of the protagonist's self-formation, major life direction or personal turning point.
- A retained entry concisely explains the turning point and its lasting meaning, instead of repeating the whole turn or continuing the recent-history list by habit.
- Quiet events may matter and intense scenes need not matter; no fixed event taxonomy, keyword/score/turn-gap/elapsed-time decision rule.
- Character may change with no milestone; a milestone may be added while Character remains unchanged.

No runtime branch, parser, contract, storage, ID, parent-chain, Provider transport/lane, prompt assembly, UI, navigation or database schema changed. No historical entries were deleted or rewritten. Tests and runners are engineering perimeter files with Chinese responsibility names and tracked Godot UIDs; no new production dependency/layer seam was introduced.

## MW-018 R1 protection / semantic ownership proof

A source comparison against formal base proves all content outside the lived `INSTRUCTIONS` block is identical, including People and Initial instructions. All other production files are unchanged. The v0.2 Player/GM identity evidence bridge remains integrated.

The new deterministic vertical uses the same accepted text and production system prompt, restoring the prior snapshot between two model-stub outcomes. Both empty Experiences and a selected milestone are durably accepted; Program does not veto/mandate either based on the words. It separately proves Character-only mutation with zero new milestones. These tests prove structural freedom, not the semantic correctness of a stub's invented decision.

The paid two-case validation uses the real production Curator request/parser/persistence flow. Case labels and expected counts are assertions only and never enter model messages. Both requests contain the exact same system prompt. Raw model `experiences` equals the durably stored array in each case. There is no post-processing importance filter, retry, prompt tweak between attempts or Provider fallback.

## Validation

[Machine summary](r1/evidence/validation.json), [offline results/logs](r1/evidence/offline-results.json), [complete real requests/responses](r1/evidence/real-provider.json), [Owner data fingerprints](r1/evidence/owner-safety.json), [Windows export log](r1/evidence/windows-export.log).

| Gate | Evidence |
| --- | --- |
| MW-015 R1 focused | **37 checks / 0 failures**, exit 0 |
| Nine affected regressions | all exit 0, zero assertion/script/parse errors and zero exit resource warnings |
| MW-018 R1 within regressions | 81 checks / 0 failures; Player/GM evidence and People card behavior retained |
| Bounded real configured Provider | **Kimi K3 `k3-256k`, 2 Curator calls**, both successful |
| Final Godot import | exit 0, no script/parse errors |
| Windows Desktop export | exit 0, **export_errors=0** |
| Git whitespace / production-scope comparison | clean; only lived prompt changed |

Execution order: focused → affected regressions → two real Provider calls → final import/export. An initial focused compile found a test-only inferred Dictionary type error; it was corrected before the successful deterministic gates. Production prompt was not adjusted after seeing real responses.

Affected suites: MW-014; MW-015 surface; MW-015 R2 initial baseline, UI and contract; MW-017 barrier/identity; MW-018 cards; MW-018 R1 known/off-screen eligibility; G5-01 timeline. Together with the focused test these cover empty-success idempotence, independent outputs, malformed-response preservation, legacy curation compatibility, People disclosure/currentness, Save/Restore/Regenerate/reopen and no backfill.

Real validation fixed two accepted scenes in one isolated Game, with a stubbed frozen initial baseline and stubbed World semantic barriers. Exactly two **real** calls go to the existing Information Curator; there are no real World/Narrative calls. The request recorder delegates unmodified to the configured production Provider.

| Scene | Model result |
| --- | --- |
| Thank the shopkeeper, walk back to the academy and straighten manuscript pages | `{"character":null,"experiences":[],"people_updates":[]}` |
| Personally abandon the family-arranged official career and formally assume long-term medical service | Character update plus **one** milestone, “弃仕途从医，接下乡里医馆之职”; `people_updates=[]` |

Exact milestone text:

> 我亲自递交文书，正式撤回家族为我保留的仕途荐举，结束了为家族求官的道路。随后在乡里医馆的任书上签下名字、接过印信，开始承担乡人诊治的长期职责。这是我亲手选择的人生转折：将多年学成的医术用于救治乡人，并以此作为今后终身的事业方向。

All requests/results in committed evidence are synthetic fixture content. Credentials were injected via the existing whitelist method and never copied or printed. Owner settings/Source/Games/game-library/current DB fingerprints are unchanged. Owner canonical checkout remained on main at `782daf65348f484d636d46260ac2374559cf554d`, retaining its pre-existing `.gitignore` modification and ten screenshot import sidecars. All existing worktrees were preserved. This task's generated imports were retained under its ignored build directory.

Export output stays under `build/mw015/r1/windows/`; checksums for the EXE, separate PCK and SQLite DLL are recorded in `validation.json`. The EXE is the engine template; the PCK carries the updated game content. No Owner build installation occurred.

## Reproduce

From the required worktree, with PowerShell 7 and a fresh task-local output root:

```powershell
$Godot = 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe'
& $Godot --headless --editor --path . --import --quit
& './tests/mw015/运行稀疏经历离线验证.ps1' -Godot $Godot
# Paid/network validation: exactly two fixed production Curator cases.
& './tests/mw015/运行真实稀疏经历验证.ps1' -Godot $Godot
# Create an isolated export output directory first.
New-Item -ItemType Directory -Path 'build/mw015/r1/review-windows'
& $Godot --headless --path . --export-release 'Windows Desktop' 'build/mw015/r1/review-windows/my-world.exe'
```

## Residual risks and handoff

- Two intentionally clear semantic examples demonstrate the required ordinary/turning contrast, not long-session sparsity statistics. Borderline, quiet-but-significant or accumulated developments still require model judgment and Owner re-UAT.
- Character/People outputs remain structurally compatible; the paid test has no People identity evidence. People semantic/evidence preservation is established by unchanged source and existing full regressions, not a new paid People test. Broader Character prose quality is not newly adjudicated here.
- Existing over-generated experiences in old saves remain. No historical cleanup or recap/IA feature was implemented.
- Structured-output failure behavior remains unchanged; no retries/fallbacks/importance heuristics were introduced to manufacture success.
- Per latest v17.6 route, Owner focused re-UAT follows Independent Review/integration of the correction train and the separately queued context-budget fix. This task implements none of that queued work.

Stop at **READY FOR INDEPENDENT REVIEW**. No Engineering/Product PASS is declared, no main merge, no Owner installation.
