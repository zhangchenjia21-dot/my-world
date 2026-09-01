# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and current task packet.
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
G4-08M1 Public d20 Mechanism          PASS / CLOSED
G4-08M1C01 NO_CHECK Idempotency       PASS / CLOSED
G4-08B Public d20 UI Integration      CORRECTION REQUIRED
G4-08BC01 UI Projection / Fail-Loud   ACTIVE — KIMI
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

---

## 3. Current execution task — G4-08BC01

Formal correction packet:

`docs/tasks/G4-08BC01_UI_PROJECTION_FAIL_LOUD_CORRECTION_TASK.md`

Formal Code Base:

`3a20234d06c10904c220cd1a49bf29f6ad6769e7`

Independent Review record:

`docs/g4_08b/G4-08B_INDEPENDENT_REVIEW.md`

Primary owner: **Kimi**.  
Reviewer / semantic owner: **GPT**.  
Correction budget: **correction-01**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

The original G4-08B implementation broadly proved Wizard selection, Game-local Public d20 routing, stable action identity/retry, durable card reconstruction, no-Expansion regression and real Provider UI integration. It is not PASS because the mechanic-card live/retry projection is not stable and unknown action-resolution capabilities can degrade to legacy play.

Do not start G4-09 before this correction passes GPT Independent Review.

---

## 4. G4-08BC01 exact correction

### Mechanic card lifecycle

For each durable `check_id`:

```text
at most one visible mechanic projection at a time
```

During `resolution_narrative`, show one transient result before GM completion.

After acceptance, freeze historical association as:

```text
Player action
→ mechanic card
→ GM narrative
```

Use the same order for live acceptance, retry, reopen retry, redraw, Continue and Load/Restore.

Current defect to remove:

- transient card is appended before Player/GM exist and remains stranded after acceptance;
- redraw currently appends the card after GM;
- existing-check retry can append duplicate transient cards through both `request_assembled` and synchronous `streaming{stage=resolution_narrative}` paths.

Use durable `check_id` only as read-only UI projection identity. UI never recomputes dice truth.

### Unsupported capability fail-loud

A materialized Expansion with:

```text
capability_slot = action_resolution
capability_id != action_check.public_d20.v1
```

must never fall back to the no-Expansion G4-07 Provider path.

Surface a player-readable unsupported-rule state, gate Player action input, keep the Game durable/intact, and do not interpret Source prose as code.

### Evidence gap

The dedicated G4-08B explicit-none test is currently empty. Add direct Wizard → Review proof that explicit none produces `拓展 / 无` and a frozen empty Expansion selection.

Remove production debug probe output such as `PROBE card added`.

---

## 5. Frozen Public d20 semantics

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

Frozen:

- Expansion selection is explicit `0..N` exact generations;
- no Expansion preserves G4-07 behavior and never silently enables d20;
- duplicate exact / same capability slot conflict fail closed;
- Program owns die faces / selected roll / total / outcome;
- Proposal freezes before RNG;
- NO_CHECK remains one Provider call;
- CHECK_REQUIRED uses durable Program result before second Provider narrative;
- both branches are stable-action retry/restart idempotent;
- Expansion owns resolution, not downstream canonical World consequences.

---

## 6. Accepted backend boundary

Do not reopen absent concrete evidence:

- Expansion Source / Managed Library exact generations;
- Composition exact `0..N` backend;
- capability-slot compatibility;
- Final Create exact Expansion materialization/provenance;
- Program d20 rules/RNG/result;
- CHECK_REQUIRED no-reroll retry/restart;
- NO_CHECK durable replay identity / lost-ACK recovery;
- SQLite schema v4;
- Provider protocol;
- no executable Source support.

Protected backend paths:

- `src/source/**`
- `src/最终建局/**`
- `src/persistence/**`
- `src/行动判定/L0_公理层/**`
- `src/行动判定/L1_器件层/**`
- `src/行动判定/L2_流程层/**`

---

## 7. Next progression

```text
G4-08BC01 Kimi correction
→ GPT Independent Review
→ if PASS: G4-08B PASS / CLOSED
→ G4-09 First Playable B
→ Owner Source Library Public d20 bootstrap
→ Owner UAT B
```

Do not claim G4-08 PASS from the correction and do not start G5 before the remaining G4 route / G4-GATE complete.
