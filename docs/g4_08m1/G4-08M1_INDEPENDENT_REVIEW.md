# G4-08M1 Independent Review

Status: **CORRECTION REQUIRED — NOT PASS**  
Reviewer: **GPT**  
Reviewed implementation HEAD: `31eca597d144c7c1214ddcc114d718a45fabf9dd`  
Formal task: `docs/tasks/G4-08M1_PUBLIC_D20_EXPANSION_MECHANISM_TASK.md`

## 1. Result

G4-08M1 is **not yet PASS**.

The implementation substantially satisfies the intended architecture:

- `expansion_pack.v0.1` is a real third Source type through the existing Managed Library and exact-generation machinery;
- Composition supports explicit exact Expansion selection and rejects duplicate exact generations / exclusive slot collisions;
- Final Create pins and materializes exact Expansion provenance/rules/binding without Provider calls and without changing SQLite schema v4;
- Public d20 uses strict structured adjudication, Program-owned RNG, Program-owned total/outcome, and durable check resolution;
- CHECK_REQUIRED retry/restart reuses the exact losing/winning result and does not reroll;
- real DeepSeek Han and Afterglow evidence exists;
- no Expansion, no executable Source code, and accepted G4-06/G4-07 regressions are preserved;
- UI ownership was not taken.

However, one blocking idempotency gap remains on the Expansion-enabled `NO_CHECK` path.

## 2. Blocking finding — NO_CHECK stable action replay is not durable

Task Packet §7.1 requires every submitted Player action that reaches adjudication to have a stable identity sufficient for Provider failure/retry/restart idempotency.

Task Packet §7.2 intentionally keeps `NO_CHECK` as a one-Provider-call normal turn, but that does **not** remove the stable-action replay requirement.

Current implementation behavior in `src/行动判定/L2_流程层/公开D20行动判定流程.gd`:

```text
start_action(action_id, player_text)
→ _find_check(action_id)
→ if no durable CHECK record exists, call adjudication Provider
→ NO_CHECK response
→ _accept_narrative(..., {})
→ durable Conversation acceptance
```

`_find_check(action_id)` searches only `expansion_runtime.public_d20_checks`.

For `NO_CHECK`, no check record or other durable `action_id` replay marker is written. After the narrative has already been durably accepted, a repeated call with the same `action_id` therefore has no durable evidence that this action already completed. It can enter Provider adjudication again and append the Player action / GM narrative a second time.

This matters in the ordinary lost-ACK/retry case:

```text
Provider returns valid NO_CHECK + narrative
→ Conversation COMMIT succeeds
→ caller does not receive/retain the successful result
→ same action_id is retried
```

The same issue remains after a fresh-process reopen because accepted Conversation entries do not currently carry the caller-owned `action_id` identity.

The focused test suite verifies that one NO_CHECK execution is one Provider call and durable, but it does **not** replay the same accepted NO_CHECK `action_id` in-process or after process restart.

## 3. Why this is blocking

This violates the frozen M1 identity/idempotency contract, not merely a UI convenience.

If accepted as-is, the first Expansion would have two different replay semantics:

```text
CHECK_REQUIRED → stable action_id, durable replay-safe
NO_CHECK       → stable action_id accepted by API, but not durable replay-safe
```

That is an invalid split because the caller cannot know before adjudication whether the action will become CHECK_REQUIRED or NO_CHECK.

The same submitted Player action must remain exactly-once regardless of which adjudication branch the Provider chooses.

## 4. Correction classification

Classification: **correction-01 — focused seam fix**.

This finding does not reopen:

- Expansion Source architecture;
- exact-generation provenance;
- capability-slot semantics;
- Public d20 rule semantics;
- Program RNG authority;
- CHECK_REQUIRED durable retry/restart;
- G4-07 baseline.

No redesign is required unless the focused correction exposes a neighboring ownership conflict.

## 5. Required correction evidence

Before M1 can PASS, prove at minimum:

1. first Expansion-enabled NO_CHECK action still completes with exactly one Provider call and zero RNG;
2. after durable acceptance, replaying the same `action_id` + same Player text in the same process makes **zero** additional Provider calls and appends **zero** additional Conversation turns;
3. after closing/reopening the Game in a fresh process/runtime, replaying that same `action_id` + same Player text remains already accepted with zero Provider/RNG/duplicate turn;
4. same accepted `action_id` + changed Player text fails loud as an identity/payload conflict;
5. a failure before a valid NO_CHECK result remains retryable and does not publish a false accepted marker;
6. any lost-ACK window between durable Conversation acceptance and the final replay marker is recoverable without another Provider call or duplicate Player turn;
7. CHECK_REQUIRED retry/restart evidence remains green;
8. no-Expansion G4-07 path remains unchanged;
9. schema remains v4 unless a narrowly justified reviewed migration is unavoidable.

## 6. Decision

```text
G4-08M1 Public d20 Mechanism          CORRECTION REQUIRED
G4-08M1C01 NO_CHECK Action Idempotency ACTIVE — CODEX
G4-08B UI Integration                 NOT YET
```

Do not activate Kimi until the correction passes Independent Review.
