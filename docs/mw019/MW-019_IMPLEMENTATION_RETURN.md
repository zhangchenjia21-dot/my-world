# MW-019 — Five Recommended Actions — Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**
Work Item: MW-019; Revision: 1; Reviewer: GPT; Product UAT: Owner (pending combined MW-018 + MW-019 UAT).

## Exact identity / freshness

- Branch: `mw-019-five-recommended-actions`
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-019`
- Implementation/export commit: `bf9996e67d267871e918f82bd9ad6d2fb539ff0b`.
- Final candidate is this commit plus an evidence-only commit; the return message gives its exact SHA. No production source changes in the evidence commit.
- Refreshed implementation main: `b83865c6c4e7bdccf6c40341789e03502baa78a3` (unchanged at final refresh).
- Governance main initially: `3431b830bfb2536dbe56394bc23cf5b02b4822e2`; final refresh: `9b23507bbe4d45f55f42deab1534726f3d2540ef`.
- The latter governance change touches only `workbench/`; `AGENTS.md` and `my world/` authorities are unchanged.
- Task shaping bases remain product `7aa02cc60aa8a87708d3d23477e11e237bb20123`, architecture `7671c29dc609d479458ff4ca5d12e0b8a76fea15`.
- Read latest repository/governance AGENTS, Owner preferences, current Status/Roadmap/Principles, the Five Recommended Actions decision, Task Packet, and MW-018 review/integration context. No authority conflict.

## Implemented vertical

Shell creates one Game-activation-scoped Action Recommender, independently of World semantic / Information Curator / Agency / Evolution workers. Its L3 entrypoint is `src/行动推荐/L3_外交层/行动推荐公开接口.gd`; it instantiates the existing runtime-configured Provider L3 adapter. There is no fallback or Provider preference mutation.

The L2 worker consumes durable Conversation acceptance and Restore signals. Its only player-facing seam is `changed` plus the read-only `snapshot()` of `{status, actions}`. The explicit `interrupt_foreground()` seam covers d20 adjudication before `Conversation.begin_turn`. Shell shuts down transport before closing Runtime; `_exit_tree` also detaches it when a Shell is freed.

The Narrative Host displays five buttons above PlayerInput. Click only replaces the input, focuses it and moves the caret to the end. Full multiline drafts remain intact; button labels alone flatten CR/LF/tab for compact presentation, with exact full text in tooltips. Nothing is submitted until the original Send/Ctrl+Enter path is used. No action identity, dice request, journal entry or World mutation is created by clicking.

## Exact input / response boundaries

Input builder receives only `get_durable_accepted_entries()`. It allowlists Player/GM text into `{conversation:[{player,gm}]}`. No GM context assembler, world_state, Source, actor, Knowledge, Agency, Evolution, curation, ID or receipt is consulted or sent.

- Latest accepted GM and its associated Player text are included in full.
- At most four contiguous recent accepted pairs, newest first for selection then chronological for output.
- UTF-8 JSON user-content limit: **24,576 bytes**, including JSON syntax/escaping.
- Older history is omitted at the first byte overflow. If the latest pair alone exceeds the limit, no request is made and the optional guidance becomes unavailable. No authoritative narrative truncation or semantic retrieval.
- An internal SHA-256 of the **entire** accepted prefix binds the request independently of that bounded model window. The hash never enters model input or UI.

Response parser bounds the accumulated stream to **8,192 UTF-8 bytes** and rejects syntax nesting deeper than two before JSON parsing. Exact top-level object key `actions`; exactly five strings; trim edges; nonempty; each at most **240 Unicode characters**; exact trimmed duplicates rejected. Wrong types, extra keys, 4/6 entries, malformed/fenced JSON, oversized or deep output yield no buttons. There is no missing-action filling, fence stripping, ranking, heuristic diversity check or semantic repair.

The prompt asks the model for varied plausible editable first-person actions, using only visible history, without guaranteed results, secret knowledge or a five-choice gate. **Model owns semantic interpretation; Program owns structure, currentness and presentation.**

## Lifecycle / storage

- Empty accepted history: zero recommendation calls.
- Accepted GM-only opening and ordinary/replacement completion: one deferred fresh opportunity after durable acceptance.
- Activation/reopen and successful Restore: at most one request for the latest accepted prefix when foreground is idle.
- Foreground submission, retry/regenerate/correction: immediately clear state, increment serial, disconnect callbacks and cancel active transport. Failed/cancelled GM creates no recommendation opportunity.
- A monotonically increasing serial protects deferred work and callback closures across Restore, replacement, new attempts and shutdown. Publication also checks current Runtime, foreground state and full-prefix equality.
- Timeout: **120 seconds**, with transport cancellation. Provider failure, cancellation, malformed response or timeout are quiet guidance failures, never Narrative finalization failures.
- Rendering, resizing, changing tabs, editing and clicking cause zero calls.
- No persistent recommendation field/table/migration. No writes to Conversation, World, Timeline, Save, Source or information_curation. Only a later explicit Player submission makes draft text authoritative.

## Verification

All 26 suites in `tests/mw019/运行行动推荐离线验证.ps1` completed with exit 0 and no assertion/script errors; Windows Desktop export also completed with exit 0 and no export/script errors. Full logs and per-suite results: `evidence/regression/` and `evidence/regression-results.json`.

Suites cover MW-019, G2-03/04/05, G4-07A/B, Public d20 UI/mechanics/NO_CHECK idempotency/protocol, MW-017/MW-018, G5-01/02/03/03M2A/03M2B/04, MW-006, MW-014 and MW-015/R2.

After the last presentation-only refinements (actual resize width and newline-safe button labels):

- Final focused/UI run: **122 checks, 0 failures**, no script errors or exit leaks.
- Final real Wizard + legacy/Ctrl+Enter/d20 send test: **0 failures**. Click never calls d20; normal send preserves edited text; d20 starts before Conversation and uses its existing control/narrative route. Manual submission while recommendations stream cancels them immediately.
- G2-03 re-run: **0 failures**.
- Final Windows Desktop export at exact implementation commit: **exit 0, no errors**. EXE/PCK hashes and sizes are in `evidence/manifest.json`. Binaries remain only under task `build/mw019/final/windows/`.
- Three reviewed screenshots: maximized (2560×1351), 1280×720 and 960×540. No horizontal overflow; final short-window recommendation area is 83 px, with Narrative reading area 155 px in the opening fixture. Short/wide hosts use three columns and two rows; other widths use two columns and three rows. Free-form composer retains the existing 112–160 px height policy.
- Five 240-character multiline recommendations remain compact at 960×540, retain full tooltips, and prefill exact full drafts.
- `git diff --check`: clean.

### Existing test assumptions / baseline warnings

Two old G2 tests required narrow test-only repairs, with unchanged assertions of behavior:

1. G2-03's missing-key/DNS fixture now reads an absent task settings path, selecting the validated default; it no longer pairs a DeepSeek dummy key with Owner's currently selected Kimi profile.
2. G2-05 checks the actual `\n\nCurrent Game Context\n` section boundary. The existing GM instruction mentions “Current Game Context” in prose, which is not an included context section.

Both original tests independently fail twice on an archive of unmodified implementation main; see `baseline-g2-03.log` and `baseline-g2-05.log`. No GM/context/Provider production logic was changed to satisfy them.

Existing exit-warning families remain: G5-03 (3 objects/1 resource), G5-04 (43/20), G4-07B (3/1), and Public d20 G4-08B (3/1). The first three match prior MW-017/MW-018 reviewed evidence; G4-08B was independently reproduced on the unmodified main archive in this run (`baseline-d20.log`). The warnings are disclosed, not recast as new MW-019 failures or fixed out of scope.

## Bounded real configured Provider evidence

Current model: **Kimi K3**, `k3-256k`, `high`, 256K; endpoint `https://api.kimi.com/coding/v1/chat/completions`.

Exactly **2 recommendation requests**, using task-owned synthetic player-visible conversations durably accepted through production Runtime. No real GM/World/curation request and no Owner Game content was used.

1. Opening: **ready / exact five distinct actions**, 3,935 ms.
2. Ordinary accepted turn: **unavailable**, 4,868 ms. The model returned a Markdown-fenced JSON block; strict parser rejected it as specified. No fence stripping, retry, hidden Provider switch or invented buttons.

The Task Packet's minimum one successful real recommendation call is satisfied; two successful calls are **not** claimed. The exact sanitized requests, raw responses and five accepted actions are preserved in `evidence/real-provider.json`. Owner settings, Source, Games, game-library and current DB fingerprints match before/after (`owner-safety-*.json`).

The five successful opening actions were:

1. 我先走到亭边向陈安道谢，问他明早接的是什么货、渡口今晚是否还有船过河。
2. 我去找城门旁的守卫，打听城里今晚何处可以投宿，以及夜里城门几点关闭。
3. 我沿着河堤走到渡口附近，看看那盏灯下有没有船家，顺便问今晚或明早过河的价格。
4. 我问陈安是否缺人手帮忙搬货，愿以劳力换取他明早带我去渡口并介绍船家。
5. 我先在附近查看积水深浅和路况，确认通往渡口的路是否安全，再决定今晚去哪边过夜。

## Architecture / boundaries / remaining product risk

New module dependencies are downward L3 → L2 → L1/L0, and its only cross-module Provider dependency is the reviewed L3 seam. Existing Runtime/Conversation remain their owners. Shell/leaf consumer uses recommendation L3; no leaf receives omniscient input. No generic intent bus, callbacks registry, NodePath execution, MW-013, ranking or recommendation persistence was introduced. New business filenames and contract comments use Chinese.

Model formatting reliability remains an observed risk (one fenced response among two samples). The strict fail-soft behavior is intentional. Suggestion usefulness, perceived freedom and combined People experience remain **Owner UAT pending**; engineering checks cannot supply Product PASS.

Owner canonical checkout remains main at `7aa02cc60aa8a87708d3d23477e11e237bb20123`; its existing dirty `.gitignore` and ten untracked screenshot import sidecars were preserved. No candidate installation, main merge, reset/clean/force, Owner Source/Game edit or product verdict occurred.

## Changed implementation / test files

- `src/main.tscn`
- `src/ui/叙事对话视图.gd`
- `src/应用壳.gd`
- `src/行动推荐/L0_公理层/行动推荐契约.gd`
- `src/行动推荐/L0_公理层/行动推荐契约.gd.uid`
- `src/行动推荐/L1_器件层/推荐响应解析器.gd`
- `src/行动推荐/L1_器件层/推荐响应解析器.gd.uid`
- `src/行动推荐/L1_器件层/推荐材料构建器.gd`
- `src/行动推荐/L1_器件层/推荐材料构建器.gd.uid`
- `src/行动推荐/L2_流程层/行动推荐流程.gd`
- `src/行动推荐/L2_流程层/行动推荐流程.gd.uid`
- `src/行动推荐/L3_外交层/行动推荐公开接口.gd`
- `src/行动推荐/L3_外交层/行动推荐公开接口.gd.uid`
- `tests/g2_03_会话视图离线测试.gd`
- `tests/g2_05_上下文组装离线测试.gd`
- `tests/mw019/真实推荐验证.gd`
- `tests/mw019/真实推荐验证.gd.uid`
- `tests/mw019/行动推荐发送判定测试.gd`
- `tests/mw019/行动推荐发送判定测试.gd.uid`
- `tests/mw019/行动推荐纵向测试.gd`
- `tests/mw019/行动推荐纵向测试.gd.uid`
- `tests/mw019/运行真实推荐验证.ps1`
- `tests/mw019/运行行动推荐离线验证.ps1`

The following evidence-only commit adds this report and `docs/mw019/evidence/` (logs, results, three screenshots, exact real Provider records, Owner fingerprints and hash manifest). Log presentation is normalized to LF with trailing whitespace removed; raw model response string values in JSON are preserved exactly. `evidence/.gdignore` keeps evidence out of the Godot resource tree.

## Review / UAT handoff

Highest returned status: **READY FOR INDEPENDENT REVIEW**.

Next owner: GPT Independent Review. After reviewed Engineering PASS and integration, perform a fresh canonical Owner build handoff for combined MW-018 + MW-019 UAT. Do not treat this candidate or the test export as the Owner playable version.
