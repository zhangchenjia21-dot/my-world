# MW-034 — Information Curator Bounded Recovery

Status: **READY FOR INDEPENDENT REVIEW**

## Lineage

- Starting HEAD: `8abed26d60fea2c5cc8bfbad1c60f08bbb707675`.
- Formal Code Base / implementation main: `651362305a7d4a2872a2da9293b9a2a77e33b7f4`.
- Implementation HEAD: `e5a8464700592ed5c423ca48a8b95c9a53ea3757`.
- Final Candidate: the evidence commit containing this return; exact SHA and confirmed remote tip are supplied in the handoff, avoiding a self-referential hash.
- Branch: `mw-034-g7-information-curator-recovery`.
- Worktree: `D:/AI/Projects/.worktrees/my-world/mw-034-g7-information-curator-recovery`.
- Governance main: `93eb6077b09ed58e03e91e4dad4dd3d1d8842f1f`; Status v18.4 / Roadmap v5.3 / frozen MW-034 architecture v1.0. Refreshed both mains and task branch; no relevant drift.

## Implemented boundary

The Curator process owns one logical initial/lived opportunity and maximum two automatic Provider starts. Recovery is deferred, background-only, and does not become a Narrative gate. Initial profile binding and lived index/prefix/parent remain authoritative; Game and Restore epoch bind the opportunity.

Only the Curator L2 process and its L3 contract comment changed in production. Parser, schema, identity helpers, Provider adapter, Recommendations, d20, World/Agency/Evolution, Context, UI and persistence schema are unchanged. No shared retry framework, repair/extraction/fence stripping, fallback content or Provider fallback.

`retry_pending()` remains explicit repair after an opportunity has ended; calls while initial/recovery is in flight cannot clear `_attempted` and accidentally grant a third automatic start. Durable success still deduplicates.

## Exact failure classifier

Recovery requires attempt 1, a still-current opportunity, and one of:

| Source | Eligible status |
| --- | --- |
| Strict Curator parser | `malformed_response` |
| Curator-owned timer | `timeout` |
| Existing Provider transport/HTTP failure code | `transport`, `http_408`, `http_429`, `http_500`, `http_502`, `http_503`, `http_504` |

Permanent codes map to `configuration_failure`, without recovery:

`missing_key`, `missing_credential`, `invalid_profile`, `invalid_persisted_settings`, `invalid_settings`, `unknown_profile`, `unknown_context_limit`, `unknown_reasoning_request`, `incompatible_context_limit`, `http_401`, `http_403`.

All other Provider codes map to terminal `provider_failure` **without** recovery; unknown is not assumed transient. Provider error prose is ignored. A start Error without a classified failure signal is terminal `start_failed`. Synchronous failure signals retain their classification and cannot be overwritten by the returning Error.

Input/response oversize, invalid profile/storage prerequisites, invalid initial lifecycle result, stale prefix/parent/binding, Restore, explicit cancel, shutdown and persistence failure do not retry. A second recoverable failure also ends the opportunity; no third automatic start.

## Callback and recovery isolation

Each actual request connects four callbacks bound to a monotonic request serial, plus a serial-bound one-shot timer. Every callback checks serial, active/pending/closed state, Game, epoch, and current initial binding or lived prefix/parent before using response content.

On terminal/timeout/cancel/Restore/shutdown, serial is invalidated and signals/timer are disconnected **before** cancelling transport. The existing Provider contract synchronously closes HTTPClient, clears active state and terminates the SSE lifecycle in `cancel()`. Recovery starts deferred after this teardown. Already-queued old bound callbacks retain the old serial and are ignored even after attempt 2 is active. No Provider lifecycle redesign was made.

The pending recovery retains the logical opportunity, excluding competing pumps; it rechecks currentness before attempt 2. Initial input is rebuilt from the current exact profile binding. Lived input is rebuilt from domain owners: identity evidence plus People/Thread/actor refs are fresh for attempt 2, and only those maps validate its output. `_response` is cleared, and the only prompt addition is the bounded system-owned correction cue. No malformed response or old ref is echoed.

Existing single durable initial/lived commit paths remain the only successful exit. No attempt-1 partial writes or duplicated semantic identity are introduced.

## Focused evidence

**441 checks / 0 failures / 0 script errors**, real Provider calls **0**. [Focused log](evidence/focused.log), [safe attempt trace](evidence/safe-attempt-evidence.json).

Production Curator + real isolated Runtime/SQLite + deterministic Provider stub cover:

- initial malformed → exactly one recovery → one durable baseline node, no experience; reopen zero starts;
- lived malformed → recovery → one record/experience; fresh People and Thread refs preserve existing stable identities;
- valid actor receipt creates different actor refs per attempt; old actor ref has no authority, fresh ref binds exact stable actor;
- strict parser rejects old Thread refs, independently withholds People writes for old People/actor refs; parser itself is unchanged;
- attempt-2 prompt excludes attempt-1 malformed canary and prior refs; private actor canary is excluded;
- timeout teardown followed by attempt 2; captured old delta/completed/failed/cancelled callbacks cannot contaminate, commit or terminate it;
- all seven recognized transient codes recover successfully; permanent and unknown codes do not retry;
- second malformed, timeout and transport failures produce no third automatic start;
- initial/lived input oversize, response oversize and persistence failure do not retry;
- explicit cancel/shutdown in flight and while recovery is pending prevent recovery;
- real Restore during initial and lived attempt 1, pending recovery and attempt 2 invalidates old work; any subsequent initial start belongs to the new Restore epoch;
- stale prefix while pending and stale completion on attempt 2 cannot commit; displaced parent prevents old recovery while permitting a new current logical opportunity;
- later accepted lived turns continue after final failure; explicit initial/lived `retry_pending()` repair still works;
- in-flight `retry_pending()` cannot reset the two-start budget;
- accepted Narrative/foreground action remains independent of Curator success;
- reopened recovered initial/lived records do not trigger duplicate curation.

New diagnostic fields are mode, attempt, recovery scheduled/started and elapsed time, using the existing local request ordinal. Existing internal prefix/epoch currentness metadata remains for the existing observer; no new raw payload/ID/ref fields are exposed. Archived attempt evidence uses a safe structural allowlist. UI/Debug projection remains unchanged.

## Affected and broad regressions

**49/49 existing relevant suites passed**, plus **MW-033 focused 206/206**. [Manifest](evidence/regression-results.json), [suite logs](evidence/regressions/), [MW-033 log](evidence/mw033-focused.log).

Coverage includes G2 Conversation/Narrative, G3 Save/Restore/reopen/Recovery including G3-03/G3-05, G4 Opening/continuation and d20, G5 World/Knowledge/Agency/Evolution/currentness, initial Character, Experiences, People/R1, Threads, Information Curation, Recommendations recovery, MW-032 and MW-033.

Three directly affected old tests assumed terminal failure after a single recoverable Curator response. They now explicitly exhaust two attempts before checking their original no-mutation/final-terminal assertions: MW-014 timeout/permanent-status, MW-015 R2 transient initial failure, MW-027 malformed/timeout plus serial-bound old callback injection. No safety assertions were removed; no unrelated test relaxation. After the final in-flight repair guard, full focused was rerun and Threads was additionally rechecked: **157/157** ([log](evidence/mw027-final.log)); affected Character/curation suites and MW-033 also passed with that guard.

Five retained nonblocking teardown warning suites match reviewed base evidence exactly: G4-07B, G4-08B, G5-03, G5-04, MW-003, each two ObjectDB/resource-at-exit lines, exit 0. [Reviewed-base comparison](evidence/baseline-warning-comparison.json). No retained failing suite.

Existing three-size real-window host smoke: **484/484**, exit 0, at 960×540 / 1280×720 / 1920×1080. [Log](evidence/window.log), [visually inspected representative screenshots](evidence/window/). No UI redesign; navigation, composer, scrolling and safe surfaces remain usable.

## Final build

Godot `4.7.2.stable.official.ed1daf0bf` final import: **exit 0**. Fresh Windows export via `run-game.ps1 -ValidateExportOnly`: **exit 0**, explicitly rebuilt/verified, game launch skipped. No script/parse/export errors or warnings in final build logs.

[Import](evidence/import-final.log), [export](evidence/export-final.log), [freshness](evidence/export-freshness.json), [artifact hashes](evidence/windows-artifacts.json).

- Built at `2026-09-14T01:29:17.3199110Z` from Implementation HEAD product bytes.
- Product fingerprint: `a8a1f0e4f619ae0de82f3b6e486de62b377148a1415693d55a84a923ce1954be`.
- EXE `build/windows/my-world.exe`: 103035904 bytes.
- PCK `build/windows/my-world.pck`: 2691376 bytes, SHA256 `7525c4500cf4c6c7bfded2fc33e2f6f3aadf0edcf62d6fa2f4608948ae6ec66a`.
- SQLite DLL `build/windows/libgdsqlite.windows.template_debug.x86_64.dll`: 3163136 bytes.
- Final evidence commit changes no product inputs; export remains task-local.

## Preservation, deviations and residual risk

Owner canonical checkout was not updated, installed or launched; its local `.gitignore` and unknown sidecars were left untouched. No Owner real Game/Source/settings/preferences mutation, main merge or force push. Real Provider calls: **0**.

The new task worktree acquired the usual 13 tracked fixture import line-ending artifacts and 11 untracked import/UID sidecars during Godot validation. They are preserved and excluded from commits ([hashes](evidence/preserved-import-artifacts.json)); no uncommitted product changes. Do not bulk clean them.

Only scope adjustment was updating the three directly affected single-attempt regression expectations to the authorized two-attempt lifecycle. No retained failure. The late-callback guarantee depends on the existing synchronous terminal/cancel transport contract plus request-bound callback serials; a future asynchronous adapter must preserve that contract. Live Provider curation quality remains unverified and belongs to later concentrated Product validation. This return does not claim Product PASS, Package-8 completion or a shared reliability platform.
