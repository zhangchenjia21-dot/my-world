# MW-032 Implementation Return

Status: **READY FOR INDEPENDENT REVIEW**

## Identity and refreshed authority

- Branch/worktree: `mw-032-g6-reality-gate-u1-corrections`, `D:/AI/Projects/.worktrees/my-world/mw-032-g6-reality-gate-u1-corrections`.
- Formal Base / refreshed implementation `origin/main`: `69ac2030b90f4165deb2ecb5302e3743422af585`.
- Starting HEAD / Task Packet: `30ca29f90300e876efefd083c4ef50c25d7fa4b8`.
- Production Implementation HEAD: `41cf4dfb87f12d9d99b9985e4e0dcf6e7f202b25`.
- Final candidate HEAD: the documentation-only commit containing this report; its exact SHA is returned in the delivery message and verified against the remote branch after push. A commit cannot embed its own SHA without changing that SHA. Product bytes are identical to Implementation HEAD.
- Governance refreshed initially to `950d70b60cbfbf2fb9a700d9132c299aba282e8c`, finally to `eb58654568d31d96ea1ee50f100e1ef6b927daa0`. The advance contains only Minecraft planner skill documents; no superseding my-world decision. Status v17.29 / Roadmap v5.0 / G6 Reality Gate U1 Correction Train v1.0 remain applicable. Older AGENTS stage summaries do not override them.

## Implemented F01–F04

| Finding | Production changes | Outcome |
| --- | --- | --- |
| F01 | 世界回合 semantic flow and identity receipt rule; 行囊 public eligibility; 信息整理 turn flow | Newly accepted GM-only Opening enters the existing semantic lane and then shared Curator. Empty Player stays empty; no invented d20/Agency/Evolution. Inventory still belongs exclusively to World semantic mutation. Activation excludes historical replay. |
| F02 | 信息整理 contract, response parser, new L1 整理主体引用器, People projector and L3 presentation contract | Program-owned subject identity is independent of actor identity. Exact request-scoped person/actor refs permit later links while retaining subject and hide identity. |
| F03 | 行动推荐 flow; existing diagnostic contract/observer/panel | One deferred recovery for a still-current prefix after malformed/timeout/Provider failure; total starts at most two. Configuration failure, cancellation, oversize and invalid input do not retry. |
| F04 | 信息整理 Thread projector/L3, shared Curator; 动态展示 contract/preferences/adapter; bounded Shell wiring | Model must return a full reviewed Thread list, stable IDs survive updates, and Threads gain presentation-only hide/recover. |

Implementation commit contains 18 modified production files plus one new L1 file/UID; 11 directly affected test files are adapted and four MW-032 test/runner files added (three Godot UIDs). No product schema/table migration, generic framework, broad Shell refactor or unrelated debt cleanup.

## Contracts and compatibility

New production curation records use `information_curation_lived.v0.4`. Existing v0.2 and v0.3 records retain their original normalization/hash validation and remain readable without rewriting Timeline. Legacy actor-backed People uses exact actor ID as subject ID, preserving the existing presentation-key formula. Focused tests directly construct a v0.2 record and prove unchanged snapshot, identity, hash and read-only bytes.

The model sees bounded player-safe current snapshots and random request-only `person_ref` / `thread_ref`; durable subject/thread IDs and actor IDs stay in Program. New referent IDs derive from Game + accepted prefix + exact Player/GM source role/span + proposal ordinal. A referent never mints an actor or Knowledge/Agency truth. Actor links require a current exact identity receipt. Unknown refs, invalid spans, duplicate subject operations or ambiguous multiple-subject actor links fail soft without name matching. Existing subjects must be updated by their request ref. Snapshot selection/value remains model-owned; same-name subjects remain separate.

New Thread IDs derive from Game + accepted prefix + proposal ordinal. Existing refs retain exact IDs; omission removes, empty list is legitimate empty, null/missing full review is invalid. Old v0.3 Threads bridge by validated source record ID + ordinal, never title equality. Legacy-only projections are not hideable until retained into the new stable schema. Ordinary projection remains title/summary/details; renderer receives only an opaque presentation key.

`ui_visibility.v0.2` adds Threads to the existing People/Important Experiences sidecar. Valid v0.1 reads preserve both arrays with no write-on-read; only explicit hide/recover writes v0.2. Capacity remains 4096 keys per surface; total bytes grows proportionally from 600000 to 900000 for the third surface, with the old version retaining its old bound. Hidden updates remain hidden; reopen keeps preference, Restore rewinds semantic content but not preference. Character/System/Inventory remain non-hideable.

Recommendation recovery disconnects old transport before deferred retry and advances request serial. Foreground/Restore/replacement invalidate pending recovery; stale callbacks cannot publish into a replacement attempt. Same unchanged prefix retains its attempt budget during that activation. New activation permits the existing normal opportunity. Five exact `{label,draft}` pairs, action-mode prefill and never-auto-send remain unchanged. No fallback actions, repair or new Provider lane.

## Verification

All automated Providers are deterministic stubs; **real Provider calls: 0**. Fixtures and SQLite files are task-owned under ignored build roots.

- Focused: **98 checks / 0 failures**, exit 0, no script errors or exit warnings. See [focused.log](evidence/focused.log). Includes Opening factual Inventory/negative environment object/empty Threads/new actor, referent-only People, exact later link, ambiguity/same-name, old People/Thread schemas, preference compatibility, Restore/reopen, bounded recovery/timeout/configuration failure/stale callbacks.
- Real-window: **484 checks / 0 failures**, exit 0, at **960×540 / 1280×720 / 1920×1080**. Real main.tscn fixture; ordinary effective font size >=20px, Thread hide/recovery reachable, vertical overflow supported, no unusable horizontal overflow, Narrative/composer/recommendations usable. [Window log](evidence/window.log), [27 screenshots](evidence/window/). Three Thread recovery screenshots were visually inspected. Window run preceded only an identity collision guard/configuration retry adjustment and final comment/test additions; presentation implementation was unchanged.
- Direct regressions: **45 suites; 43 exit 0; 2 exact-baseline failures retained**. Full [manifest](evidence/regression-results.json) and logs include MW-018/R1, MW-019 lifecycle/pairs/routes, MW-024/025/026, MW-027/028/029/030, MW-022/023, G2, G3, G5, Agency/Evolution and MW-021 (101 checks / 0 failures).
- Final regression process was interrupted after 39 completed suites; remaining six were run separately. MW-021 first rejected a Windows-backslash fixture path with exit 2 before testing; rerun using its required normalized isolated path passed. No assertion was suppressed. Archived G5-04 log trailing whitespace was trimmed; raw log remains in the ignored build root.
- Four successful suites (G4-08B, G5-03, G5-04, MW-003) retain two ObjectDB/resource-at-exit warning lines each; recorded in manifest.
- Old fixtures expecting opening-skipped/one-shot unavailable/nullable Threads were updated for the frozen corrections. A **test-only** old-scene adapter translates explicit fixture intent using exact current refs; production never repairs legacy model output. MW-032 focused tests use the new protocol directly.

### Retained exact-baseline failures

`git archive 69ac2030b90f4165deb2ecb5302e3743422af585` produced an isolated unmodified Formal Base, imported separately and ran the same two scripts with isolated roots:

1. G3-03 上下文恢复与界面测试: `opaque World JSON is not injected as Game Context`, exit 1, failures=1. [Baseline](evidence/formal-base-g3_03.log), [candidate](evidence/regressions/g3_03.log).
2. G3-05 恢复时间线持久化测试: `raw World/Prompt truth leaked into Context`, exit 1. [Baseline](evidence/formal-base-g3_05.log), [candidate](evidence/regressions/g3_05-persistence.log).

These Context debts were not changed or suppressed. [Formal Base import](evidence/formal-base-import.log).

## Final import and fresh Windows export

Godot `4.7.2.stable.official.ed1daf0bf`; final import exit 0. Fresh Windows export and `run-game.ps1 -ValidateExportOnly` exit 0, explicitly reported rebuilt against current checkout and game launch skipped. No script/parse/export error or warning found in final import/export logs. [Import](evidence/import-final.log), [export/validation](evidence/export-validation.log).

Built at `2026-09-13T08:51:12.4368797Z`; input fingerprint `a53b4625d7a1a3d097e26bc5a9788cc583e04b32b87a0929e3341cf3ed103b1e`. This fingerprint covers the final production bytes committed as Implementation HEAD; subsequent commit adds only report/evidence. [Freshness](evidence/export-freshness.json), [artifact sizes/timestamps/hashes](evidence/windows-artifacts.json).

- EXE: `build/windows/my-world.exe`, 103035904 bytes.
- PCK: `build/windows/my-world.pck`, 2649560 bytes; SHA256 `63386adf4aae645b7587f7ee2b08f6174e6c1141d30b907fe976a9185d303214`.
- SQLite DLL: `build/windows/libgdsqlite.windows.template_debug.x86_64.dll`, 3163136 bytes.

## Architecture, preservation and risks

New L1 reference mechanism depends only on same-module L0. Modified cross-module production interactions retain public L3 boundaries; no new upward/internal-layer dependency was introduced. Subject/Thread identity stays behind player-safe L3 projection; no name classifier or semantic scoring. Public projection comments describe the changed identity contract. Tests/docs stay outside the four business layers. `git diff --check` passed.

Only 11 known task-generated import/UID sidecars were removed from this task worktree after backup/hash recording; content-identical fixture import line endings were normalized. [Cleanup manifest](evidence/task-generated-sidecar-cleanup.json). Owner checkout was only read for status and still shows its `.gitignore` local edit and ten original untracked sidecars. No main merge, Owner build installation/launch, Owner real Game/Source/settings/preference mutation, or real Provider call.

Residual risks: semantic People/Thread quality remains model-owned and untested against a live Provider in this task; large current safe inputs retain existing fail-soft bounds rather than adding ranking/G7 orchestration. Two G3 Context failures and exit warnings remain as documented. Product UAT is explicitly deferred by Task Packet; this return does not declare Engineering PASS, Product PASS or G6 closure.
