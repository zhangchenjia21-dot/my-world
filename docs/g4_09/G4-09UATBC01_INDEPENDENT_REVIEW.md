# G4-09UATBC01 — Narrative Responsiveness / Public d20 Streaming Critical Path — Independent Review

Status: **PASS / CLOSED**

Reviewer: **GPT**

Reviewed implementation line:

- START_HEAD: `d944f3bbac45cfaa1a02bf61baaa8ecd0421064c`
- IMPLEMENTATION_HEAD: `c03bcab9392ec70066f0a900a8718ab6befc0c33`
- EVIDENCE / FINAL reviewed HEAD: `151bbefe805d3afc7f6f8da377d8c32e0e57cc01`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_RESPONSIVENESS_V0_1_DECISION.md`

## Verdict

G4-09UATBC01 **PASS / CLOSED**.

The correction removes application-added whole-response buffering from the Public d20 narrative path while preserving the accepted stable-action / durable-result / no-reroll semantics.

The Owner's prior positive verdict on Public d20 gameplay remains preserved. Overall `G4-09UATB` is not closed by this engineering review; it resumes as a focused Owner responsiveness/regression retest.

## Reviewed implementation truth

### NO_CHECK

The adjudication contract is now:

```text
{"decision":"NO_CHECK","reason":"..."}
<LF>
raw GM narrative body...
```

The incremental parser buffers only until the first physical LF, validates the complete control header, and only then exposes later body text. It supports arbitrary Provider content-delta chunk boundaries and does not expose control JSON as narrative.

A successful NO_CHECK still uses exactly one Provider request. Once the header is valid, narrative body deltas are appended to the existing provisional Conversation turn while the Provider remains active. No durable Conversation/world write occurs per delta.

On Provider completion, the exact accumulated body is frozen into the durable NO_CHECK resolution, then Conversation is durably accepted, then the NO_CHECK acceptance marker is finalized.

Mid-stream failure/cancel leaves the visible draft provisional: it is not durable and is excluded from future Context. Same-process retry reuses the latest matching unaccepted Player turn instead of adding a duplicate.

Existing lost-ACK Window A/B behavior remains valid: once an exact NO_CHECK resolution is durable, retry/reopen reuses the exact stored narrative with zero replacement Provider calls.

### CHECK_REQUIRED

Ordering remains:

```text
validated proposal
→ Program RNG/outcome
→ exact check durable
→ result-narrative request
→ visible result-narrative deltas
→ durable Conversation acceptance
→ check narrative_accepted marker
```

The second Provider request now establishes/reuses the provisional Conversation turn before streaming. Each player-visible result-narrative delta is appended directly to Conversation draft instead of being buffered until terminal completion.

The exact d20 check is durable before the result-narrative request and before the first visible result-narrative delta. Narrative fail/cancel therefore preserves the same durable roll/outcome; retry/reopen does not reroll and does not duplicate the Player turn.

### Finalize barrier / persistence

The implementation does not modify Conversation, Persistence, Runtime, UI, Provider, Source, Final Create, or Runtime Model Settings ownership.

Provider deltas remain in-memory provisional material. Canonical writes occur at existing durable boundaries only. `turn_ready` / successful terminal publication occurs after Conversation acceptance plus required d20 acceptance marker finalization.

SQLite remains schema v4.

### Timing observability

The d20 Host exposes only monotonic action-relative timing points such as:

```text
request_started
first_provider_content_delta
adjudication_control_completed
durable_check_completed
resolution_narrative_request_started
first_visible_narrative_delta
provider_completed
finalize_completed
turn_ready
```

No prompt, narrative content, key, Authorization value, endpoint payload, or hidden reasoning is included in timing evidence.

## Automated / recovery evidence accepted

Accepted evidence includes:

- incremental header/body parsing across split boundaries;
- malformed/fenced/preamble failure;
- CHECK_REQUIRED non-whitespace trailing body rejection;
- NO_CHECK first visible draft before Provider completion;
- NO_CHECK one Provider call;
- zero durable mutation during streamed body deltas;
- fail/cancel partial draft excluded from durable history and future Context;
- same-process retry without duplicate Player turn;
- CHECK_REQUIRED durable check before result-narrative request/visible delta;
- CHECK_REQUIRED fail/retry with one RNG invocation and preserved exact roll;
- M1/M1C01 replay and lost-ACK regressions;
- real-process restart regressions;
- G4-08B UI ordering regressions;
- no-Expansion / Opening / model-settings / persistence regressions;
- `git diff --check` clean.

## Real Provider / Windows evidence accepted

A task-owned real DeepSeek V4 Pro vertical exercised both branches:

- CHECK_REQUIRED: real adjudication, exact Program d20 durable, result narrative became visible before second Provider completion, then finalized;
- NO_CHECK: one real Provider call, narrative became visible before Provider completion, then finalized.

Recorded monotonic timings demonstrate the intended structural ordering. The reported Godot HTTPClient `status != STATUS_BODY` warning did not create a second terminal, lost durable result, reroll, failed request, or failed final vertical; it is not a blocker for this correction. If it becomes reproducible as a product failure, it should be handled as a separate transport issue rather than by restoring narrative buffering.

Canonical `run-game.ps1 -ValidateExportOnly` rebuilt/verified the Windows export against the corrected checkout.

## Performance interpretation

This correction removes application-added full-response buffering; it does **not** guarantee low Provider TTFT.

The real timing evidence shows that after the fix:

- NO_CHECK application framing adds only a short interval between first Provider content and first visible narrative, while the larger wait is Provider/model time before first content;
- CHECK_REQUIRED still contains two Provider stages, so selected-model reasoning/TTFT can dominate the time before result narrative begins even though that narrative now streams progressively once available.

Therefore any remaining perceived slowness after this correction should first be separated into Provider TTFT / reasoning latency versus application buffering using the new timing seam.

## Product handoff

Resume:

`G4-09UATB Owner Product UAT — ACTIVE — OWNER (focused responsiveness retest)`

The Owner does not need to re-litigate whether Public d20 is worthwhile. Focused retest only needs to confirm:

1. NO_CHECK narrative visibly grows progressively rather than appearing only at terminal completion;
2. CHECK_REQUIRED still shows the durable d20 result first, then result narrative grows progressively;
3. no duplicate Player turn/card/reroll/result rewrite appears;
4. finalized progress still survives Save → Main Menu → Continue;
5. the remaining Provider/model wait is acceptable for real play.

Do not start G4-10 or G5 until the Owner returns the final G4-09UATB verdict.
