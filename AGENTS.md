# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and the current task packet.
6. verifiable implementation/tests/current HEAD.

Before authoritative work, refresh `main`; never overwrite unknown dirty/newer work.

Execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
```

---

## 2. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle  PASS / CLOSED
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
G4-05 New Game Wizard                 PASS / CLOSED
G4-06 Atomic Final Create             PASS / CLOSED
G4-07 First Playable A                PASS / CLOSED
G4-07A Opening Runtime                PASS / CLOSED
G4-07B Playable UI Integration        PASS / CLOSED
G4-07UAT01 Owner Launch Freshness     PASS / CLOSED
G4-08 Expansion Pack v0.1             ACTIVE
G4-08S0 Expansion Semantic Freeze     PASS / CLOSED
G4-08M1 Public d20 Mechanism          CORRECTION REQUIRED
G4-08M1C01 NO_CHECK Idempotency       ACTIVE — CODEX
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

---

## 3. Current execution task — G4-08M1C01

Formal correction packet:

`docs/tasks/G4-08M1C01_NO_CHECK_ACTION_IDEMPOTENCY_CORRECTION_TASK.md`

Formal Code Base:

`31eca597d144c7c1214ddcc114d718a45fabf9dd`

Independent Review record:

`docs/g4_08m1/G4-08M1_INDEPENDENT_REVIEW.md`

Primary owner: **Codex**.  
Reviewer: **GPT**.  
Correction budget: **correction-01**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

M1 implementation at reviewed HEAD is broadly accepted in shape, but M1 is not PASS because Expansion-enabled `NO_CHECK` actions are not durably replay-safe by stable `action_id` after acceptance/restart.

The focused correction must make the `NO_CHECK` branch exactly-once across lost ACK / retry / reopen without adding a fake check or another Provider call.

Do not activate Kimi until this correction passes GPT Independent Review.

---

## 4. Frozen Public d20 semantics

Canonical authority:

`Vibe-Coding/my world/architecture/source/G4_EXPANSION_V0_1_PUBLIC_D20_DECISION.md`

First real Expansion:

```text
Display Name  判定与检定：公开 d20
asset_id      exp.check_core.public_d20
asset_type    expansion_pack
schema        expansion_pack.v0.1
capability    action_check.public_d20.v1
slot          action_resolution
```

### Optional / compatibility

- Expansion selection is explicit `0..N` exact generations.
- No Expansion means current G4-07 behavior; never silently enable Public d20.
- duplicate exact Expansion → fail closed;
- same exclusive `capability_slot` collision → fail closed;
- no family/genre/year guessing;
- Public d20 works across Han and Afterglow.

### Three no-roll cases

Do not roll when the attempt is:

1. certainly successful under established facts;
2. certainly impossible under established facts/personality/causality;
3. immediately repeatable with no meaningful failure cost.

> Dice decides uncertainty. Dice does not erase reality.

### Rules / authority

```text
d20 + modifier = total

total >= DC → success
total <  DC → failure
```

No natural-1/natural-20 automatic override in v0.1.

```text
normal        1d20
advantage     2d20 take high
disadvantage  2d20 take low
```

Risk Structure / Proposal freezes before RNG. Model never owns die face, total or outcome.

### Provider branches

```text
NO_CHECK
→ one Provider response carries normal GM narrative

CHECK_REQUIRED
→ Proposal
→ validate/freeze
→ Program RNG + durable result
→ second Provider continuation constrained by result
```

The caller supplies one stable `action_id` before it is known which branch the Provider will choose. Therefore **both branches must be retry/restart idempotent by that same identity**.

---

## 5. G4-08M1C01 exact blocker

Current reviewed implementation only searches durable `expansion_runtime.public_d20_checks` by `action_id`.

`NO_CHECK` writes durable Conversation but no durable action-id replay marker. Thus:

```text
NO_CHECK accepted
→ success ACK lost
→ same action_id retried
→ Provider may run again
→ duplicate Player/GM turn may be appended
```

Correction requirements include:

- first NO_CHECK remains one Provider call / zero RNG;
- accepted same-process replay → zero Provider/RNG/Conversation additions;
- fresh-process replay → zero Provider/RNG/Conversation additions;
- same action_id + changed text → fail loud;
- failure before valid NO_CHECK remains retryable;
- lost-ACK windows before/after Conversation acceptance recover without Provider replay;
- CHECK_REQUIRED no-reroll path remains green;
- no-Expansion G4-07 route remains unchanged;
- schema remains v4 unless narrowly justified otherwise.

Do not represent NO_CHECK as a fake d20 check with invented rolls.

---

## 6. Accepted M1 seams not generically reopened

Unless the correction exposes concrete neighboring failure, do not redesign:

- Expansion third Source type / strict package contract;
- Managed Library exact/current generation behavior;
- exact Composition `0..N` selections;
- exclusive capability slot conflict;
- Final Create exact Expansion materialization/provenance;
- Program-owned d20 RNG / total / outcome;
- CHECK_REQUIRED durable resolution and no-reroll retry/restart;
- real Han / Afterglow Provider semantics;
- no executable Source code;
- SQLite schema v4;
- UI-neutral ownership.

Correction-01 is a focused action replay seam fix.

---

## 7. UI boundary

Do not implement in M1C01:

- Wizard Expansion selector / Review UI;
- mechanic-card rendering;
- click-to-roll / dice animation.

Kimi G4-08B remains **NOT YET**.

---

## 8. Next progression

```text
G4-08M1C01 correction — Codex
→ GPT Independent Review
→ if PASS: G4-08M1 PASS / CLOSED
→ G4-08B UI/integration — Kimi
→ GPT Independent Review
→ G4-09 First Playable B
→ Owner UAT B
```

Do not claim G4-08 PASS from M1 alone and do not start G5 before the remaining G4 route / G4-GATE complete.
