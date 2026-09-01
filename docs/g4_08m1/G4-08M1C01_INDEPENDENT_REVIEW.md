# G4-08M1C01 Independent Review

Status: **PASS / CLOSED**  
Reviewer: **GPT**  
Correction: **correction-01**  
Reviewed correction HEAD: `d646427dfe3c4c6328809384e482cd1fdd2204a0`  
Implementation commit: `361508497a4b1344f9326984749bb10a8c47306c`

## 1. Result

G4-08M1C01 **PASS / CLOSED**.

The original M1 blocker was that Expansion-enabled `NO_CHECK` actions accepted caller-owned stable `action_id` at the API boundary but did not persist that identity after a successful no-roll turn. Lost ACK / retry / reopen could therefore invoke Provider again and duplicate an already accepted Player/GM turn.

The correction closes that seam without redesigning Public d20.

## 2. Accepted durable model

`NO_CHECK` now has a separate durable action-resolution identity:

```text
no-check-SHA256(game_id + U+001F + action_id)
```

stored under:

```text
expansion_runtime.public_d20_no_check_actions
```

This is not a fake dice check. The durable record contains the stable action identity, exact Player text, branch, validated reason/narrative, Conversation base identity and acceptance marker, with no dice fields.

Accepted ordering:

```text
strict NO_CHECK envelope validation
→ durable Game-local NO_CHECK resolution
→ durable Conversation acceptance
→ durable accepted marker
```

Replay checks durable CHECK_REQUIRED and NO_CHECK identities before any Provider request. Same action identity appearing in both stores fails loud.

## 3. Lost-ACK / restart verification

Accepted evidence proves:

- first NO_CHECK remains exactly one Provider call and zero RNG;
- same-process replay of the same action_id/text returns already accepted with zero Provider/RNG/new Conversation;
- fresh-runtime and two-distinct-Godot-process replay preserve the exact Game/resolution identity and one Conversation turn;
- same action_id with changed Player text fails `action_payload_conflict` before side effects;
- Provider failure / invalid envelope before a valid NO_CHECK resolution creates no false marker and remains retryable;
- Window A: durable NO_CHECK resolution exists before Conversation → retry consumes stored narrative with zero Provider/RNG;
- Window B: Conversation accepted before final marker → retry matches exact Player+GM pair and finalizes marker with zero Provider/RNG/duplicate turn.

The separate OS-process proof also verifies accepted replay does not mutate the closed SQLite file.

## 4. Neighboring regressions

Correction-01 did not reopen neighboring seams.

Revalidated green:

- CHECK_REQUIRED proposal freeze and Program RNG authority;
- losing-result retry/restart without reroll;
- existing G4-08M1 focused mechanism suite;
- G4-07A Opening Runtime regression;
- G4-07B playable integration regression;
- no-Expansion G4-07 route;
- SQLite schema remains v4;
- no UI paths changed;
- no Provider envelope/message semantics changed, so the prior real Han/Afterglow DeepSeek evidence remains applicable;
- no generic command framework or executable Source support added.

## 5. Final M1 decision

With correction-01 accepted, the parent mechanism task is now:

```text
G4-08M1 Public d20 Mechanism          PASS / CLOSED
G4-08M1C01 NO_CHECK Idempotency       PASS / CLOSED
```

G4-08 itself remains ACTIVE. Product UI/integration is still required before the Expansion vertical can proceed to G4-09 Owner UAT.

Next task:

`docs/tasks/G4-08B_PUBLIC_D20_UI_INTEGRATION_TASK.md`
