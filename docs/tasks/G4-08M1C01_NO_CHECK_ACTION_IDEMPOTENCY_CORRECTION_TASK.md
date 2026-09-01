# G4-08M1C01 — NO_CHECK Action Idempotency Correction

Status: **ACTIVE — CODEX**  
Parent task: **G4-08M1 Public d20 Expansion Mechanism**  
Correction budget: **correction-01**  
Primary owner: **Codex**  
Reviewer: **GPT**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal Code Base:

`31eca597d144c7c1214ddcc114d718a45fabf9dd`

Independent Review finding:

`docs/g4_08m1/G4-08M1_INDEPENDENT_REVIEW.md`

## 1. Purpose

Close exactly one blocking seam: an Expansion-enabled action that resolves as `NO_CHECK` must be durably replay-safe by its caller-owned stable `action_id`, just like the `CHECK_REQUIRED` branch.

Do not redesign Public d20 or widen scope.

## 2. Current defect

Current `PublicD20ActionAdjudicationProcess.start_action()` checks durable completion only through `expansion_runtime.public_d20_checks`.

A successful `NO_CHECK` branch writes the Player/GM Conversation but writes no durable action-id marker. Therefore after a lost ACK or fresh-process reopen, retrying the same `action_id` can call Provider again and append a duplicate turn.

## 3. Required semantics

The caller cannot know before adjudication which branch the Provider will choose. Therefore:

```text
same action_id + same Player payload
→ at most one accepted Player/GM turn
```

must hold for both:

```text
CHECK_REQUIRED
NO_CHECK
```

For an already accepted NO_CHECK action:

```text
same action_id + same Player text
→ already_accepted / equivalent replay result
→ Provider calls = 0
→ RNG calls = 0
→ Conversation additions = 0
```

For:

```text
same action_id + changed Player text
```

fail loud as payload/identity conflict.

## 4. Durable ordering

Use the smallest existing durable seam that can make the NO_CHECK branch restart-safe. Do not create a generic command framework.

The implementation must cover both lost-ACK windows:

### Window A — after Provider NO_CHECK result, before Conversation acceptance

A retry/restart must not require a second Provider call if the validated NO_CHECK result/narrative has already been durably frozen for that action.

### Window B — after Conversation durable acceptance, before final accepted/replay marker publication

A retry/restart must recover the already accepted Conversation turn and finalize the marker without a second Provider call or duplicate Player turn.

A narrow durable NO_CHECK action-resolution marker under the existing v4 Game-local state is acceptable if it preserves ownership boundaries. Reusing/expanding an existing stable Conversation identity seam is also acceptable if it does not broaden G3 semantics unnecessarily.

Do not represent a NO_CHECK action as a fake d20 check with invented dice fields.

## 5. Required data

Whatever narrow marker is chosen must be sufficient to prove/recover at least:

```text
action_id
player_text or equivalent payload identity
branch = NO_CHECK
validated reason
validated narrative or a durable equivalent sufficient to avoid Provider replay
conversation base/index identity sufficient for recovery
accepted/not-yet-accepted state
```

Do not inject this audit/replay marker into ordinary model Context every turn.

## 6. Required tests/evidence

### A — first NO_CHECK execution

Expansion-enabled action returns valid `NO_CHECK`:

- exactly one Provider call;
- zero RNG;
- exactly one durable Conversation turn;
- durable action replay identity exists.

### B — same-process replay

Immediately submit the same `action_id` + same text again:

- zero Provider calls;
- zero RNG;
- no new check;
- no new Conversation turn;
- return already accepted/equivalent stable result.

### C — fresh-process/reopen replay

Close the Game, open it in a fresh runtime/process, submit the same `action_id` + same text:

- zero Provider calls;
- zero RNG;
- no duplicate Conversation turn;
- exact already accepted action remains identifiable.

### D — payload conflict

Same accepted `action_id` + changed Player text:

- explicit fail-loud conflict;
- no Provider/RNG/Conversation side effect.

### E — pre-result failure

Provider fails or returns invalid envelope before a valid NO_CHECK result is durably frozen:

- no false completed marker;
- same action remains retryable.

### F — lost-ACK recovery windows

Inject/construct task-only failure windows proving:

1. durable NO_CHECK result exists but Conversation not yet accepted → retry resumes without Provider;
2. Conversation accepted but final marker not yet published/acknowledged → retry recovers without Provider and without duplicate turn.

### G — neighboring regressions

Re-run and keep green:

- CHECK_REQUIRED Provider-failure/restart/no-reroll cases;
- real/focused Program RNG tests;
- no-Expansion G4-07 route;
- G4-07A/B focused regressions;
- `git diff --check`.

Real DeepSeek re-run is not mandatory unless the correction changes Provider message/envelope semantics. If it does, re-run the relevant real Provider evidence.

## 7. Protected boundaries

Do not add:

- UI changes;
- click-to-roll;
- attributes/skills/combat;
- new Expansion semantics;
- generic task/command/event framework;
- executable Source support;
- schema migration unless unavoidable and explicitly justified.

Do not alter the accepted CHECK_REQUIRED RNG/result semantics except where necessary to share a narrowly correct action-replay seam.

## 8. Return contract

Return after pushing implementation/evidence to `main`:

```text
START_HEAD
IMPLEMENTATION_HEAD
changed paths
exact durable NO_CHECK replay identity/ordering
Evidence A-G
schema before/after
real Provider rerun: yes/no and why
UI paths changed: none
```

Return ceiling:

> **READY FOR INDEPENDENT REVIEW**

Do not declare G4-08M1 PASS and do not activate Kimi.
