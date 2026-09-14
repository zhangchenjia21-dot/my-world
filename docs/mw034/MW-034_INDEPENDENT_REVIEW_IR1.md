# MW-034 Independent Review — IR1

Verdict: **ENGINEERING PASS_WITH_NOTES**

Review scope: `MW-034 — G7 Information Curator Bounded Recovery`

## 1. Reviewed lineage

- Formal Code Base / current reviewed `main`: `651362305a7d4a2872a2da9293b9a2a77e33b7f4`
- Task Packet / Starting HEAD: `8abed26d60fea2c5cc8bfbad1c60f08bbb707675`
- Implementation HEAD: `e5a8464700592ed5c423ca48a8b95c9a53ea3757`
- Codex Final Candidate: `2f94fd2a843173370e3d9de01fd804f063067014`
- Task branch: `mw-034-g7-information-curator-recovery`
- Governance reviewed: `Vibe-Coding/main@93eb6077b09ed58e03e91e4dad4dd3d1d8842f1f`
- Frozen architecture: `G7_INFORMATION_CURATOR_BOUNDED_RECOVERY_V1_0_DECISION.md@v1.0`

Freshness check found no relevant implementation-main or governance drift. Candidate is a linear descendant of the Task Packet; the evidence commit is one child of the implementation commit and changes documentation/evidence only.

## 2. Production review conclusion

No blocking defect found.

The implementation remains lane-local to Information Curator. Production changes are confined to the Curator L2 lifecycle plus the L3 contract comment; the strict Curator parser/schema, Provider implementation, persistence schema, Recommendations, Public d20, World semantic, Agency, Evolution, Narrative, Context and UI remain unchanged.

The resulting lifecycle is genuinely bounded:

```text
logical Curator opportunity
→ attempt 1
→ only malformed_response / Curator timeout / allowlisted transient Provider failure may schedule recovery
→ request serial invalidated + callbacks/timer detached + old transport terminal/cancelled
→ deferred currentness check
→ attempt 2 with rebuilt current material + bounded correction cue
→ success commit once OR terminal fail-soft
```

One logical opportunity cannot obtain a third automatic Provider start. `retry_pending()` remains a later explicit repair seam and is ignored while the logical opportunity is still active/recovery-pending.

## 3. Callback / transport isolation

PASS.

Each actual Provider request receives a monotonic request serial and serial-bound delta/completed/failed/cancelled callbacks plus a serial-bound one-shot timer.

Before timeout/cancel/Restore/shutdown recovery can proceed, `_disconnect_request()` increments the serial, disconnects the request callbacks and timer, and only then cancels an active Provider transport. The current production Provider `cancel()` synchronously closes `HTTPClient`, clears ACTIVE state and emits its terminal signal; because Curator callbacks are already detached, that synchronous terminal cannot mutate the next attempt.

Queued old bound callbacks retain the old serial and are rejected by `_accept_callback()` even after attempt 2 becomes active. Restore additionally increments the Runtime epoch and clears the logical opportunity.

Focused tests inject captured attempt-1 delta/completed/failed/cancelled callbacks after attempt 2 starts and prove they cannot contaminate the response, terminate attempt 2 or commit state.

## 4. Currentness / request-scoped authority

PASS.

Initial recovery remains bound to Game + exact initial profile binding + Runtime/Restore epoch.

Lived recovery remains bound to Game + accepted index + exact prefix + curation parent + epoch. Currentness is rechecked before recovery and again at callback use/commit boundaries.

Attempt 2 rebuilds lived request material from current owners. People, Thread and actor request refs are regenerated. The strict existing parser validates attempt-2 output only against attempt-2 maps; attempt-1 refs have no write authority and there is no display-name matching fallback.

Restore, stale prefix, stale parent and changed initial binding terminate old work without displaced write.

## 5. Failure classifier

PASS for the frozen MW-034 boundary.

Automatic recovery is restricted to attempt 1 plus:

- `malformed_response`;
- Curator-owned `timeout`;
- `transport`;
- `http_408`;
- `http_429`;
- `http_500` / `502` / `503` / `504`.

Permanent configuration/profile/credential statuses, 401/403, unknown Provider statuses, input/response oversize, invalid storage/profile prerequisites, stale/currentness failures, cancel/shutdown and persistence failure do not retry.

The production Provider contract independently confirms that network lifecycle failures use `transport` and non-2xx HTTP responses use `http_<status>`, while runtime-setting failures are surfaced before network start. Unknown codes are fail-closed rather than assumed transient.

## 6. Parser / semantic authority

PASS.

No parser repair, Markdown-fence stripping, JSON extraction, regex cleanup, schema relaxation, fallback Character/People/Threads or fabricated fields were added. Recovery is a new model request; malformed attempt-1 response text is cleared and never included in attempt 2.

Only a successfully parsed still-current candidate can reach the pre-existing single durable curation commit. Attempt 1 performs no partial semantic write.

## 7. Focused evidence

PASS.

`tests/mw034/` uses the production Curator process and real isolated Runtime/SQLite with a deterministic Provider stub.

Recorded result:

- **441 checks / 0 failures**
- real Provider calls: **0**

Evidence covers initial/lived malformed recovery, all allowlisted transient statuses, permanent/unknown no-retry, second-failure ceiling, timeout late-callback injection, response/input oversize, persistence failure, cancel/shutdown, Restore at attempt1/pending/attempt2, stale prefix/parent, fresh People/Thread/actor refs, raw malformed/private canary exclusion, later opportunity continuity, explicit repair, foreground independence and reopen dedupe.

Three pre-existing tests were adjusted only to exhaust the newly authorized second attempt before asserting their original terminal/no-mutation behavior. Their safety assertions were not removed.

## 8. Regression / product-path evidence

PASS.

- **49 / 49** existing relevant suites pass.
- MW-033 focused: **206 / 206**.
- MW-027 final recheck: **157 / 157**.
- three-size real-window host smoke: **484 / 484**, exit 0.

Five existing teardown-warning suites retain the reviewed bounded ObjectDB/resource-at-exit warning family with exit 0; evidence records reviewed-base equivalence. No retained failing suite.

## 9. Build evidence

PASS.

- Godot `4.7.2.stable.official.ed1daf0bf` final import: exit 0.
- fresh Windows export / `run-game.ps1 -ValidateExportOnly`: exit 0.
- export freshness metadata records product fingerprint `a8a1f0e4f619ae0de82f3b6e486de62b377148a1415693d55a84a923ce1954be` and build time `2026-09-14T01:29:17.3199110Z`.
- evidence commit changes no product inputs after the implementation commit.
- no Owner build install/launch or real Game/Source/settings/preferences mutation is claimed.

## 10. Notes / residual risk

1. **Live Provider quality remains unproven.** All MW-034 acceptance is deterministic; real Provider calls = 0. This does not block Engineering acceptance and belongs to the later concentrated Product test.
2. Provider stream parser status `malformed_stream` is not allowlisted as transient. It therefore fails closed with no automatic recovery. This is consistent with the frozen rule that unknown/non-classified Provider failures must not be assumed transient, but it is a possible future evidence point if live providers exhibit malformed SSE frames.
3. Late-callback safety relies on the current Provider `cancel()` contract being synchronous/terminal plus Curator request serial isolation. If a future adapter changes cancellation to asynchronous reuse semantics, this lifecycle must be revalidated.
4. Existing bounded ObjectDB/resource-at-exit warnings remain nonblocking and unchanged.

## 11. Review verdict

> **MW-034 = ENGINEERING PASS_WITH_NOTES**

No Product PASS is claimed. No Package-8 completion or generic Structured Output Reliability platform is claimed.

Reviewed candidate is acceptable for non-force reviewed integration.