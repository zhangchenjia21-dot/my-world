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
G4-08B Public d20 UI Integration      ACTIVE — KIMI
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

---

## 3. Current execution task — G4-08B

Formal packet:

`docs/tasks/G4-08B_PUBLIC_D20_UI_INTEGRATION_TASK.md`

Formal Code Base:

`d646427dfe3c4c6328809384e482cd1fdd2204a0`

Primary owner: **Kimi**.  
Reviewer / semantic owner: **GPT**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Accepted mechanism reviews:

- `docs/g4_08m1/G4-08M1_INDEPENDENT_REVIEW.md`
- `docs/g4_08m1/G4-08M1C01_INDEPENDENT_REVIEW.md`

G4-08B owns UI/interaction only:

```text
Wizard Expansion inventory / selection
→ Review projection
→ Game-local capability-aware Narrative routing
→ stable action_id lifecycle / retry interaction
→ public mechanic-card projection
→ Continue / Load redraw
```

Do not redesign accepted backend mechanism.

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

Frozen:

- Expansion selection is explicit `0..N` exact generations;
- no Expansion preserves G4-07 behavior and never silently enables d20;
- duplicate exact / same capability slot conflict fail closed;
- roll only when uncertainty + meaningful failure stakes exist;
- certain success / certain impossibility / no-cost repeat → no roll;
- Program owns die faces / selected roll / total / outcome;
- Proposal freezes before RNG;
- no natural-1/20 auto override;
- NO_CHECK remains one Provider call;
- CHECK_REQUIRED uses durable Program result before second Provider narrative;
- both branches are stable-action retry/restart idempotent;
- Expansion owns resolution, not downstream canonical World consequences.

---

## 5. Accepted M1 mechanism boundary

Do not reopen absent concrete evidence:

- Expansion third Source type / Managed Library exact generations;
- Composition exact `0..N` backend;
- capability-slot compatibility;
- Final Create exact Expansion materialization/provenance;
- Program d20 rules/RNG/result;
- CHECK_REQUIRED no-reroll retry/restart;
- NO_CHECK durable replay identity / lost-ACK recovery;
- SQLite schema v4;
- real Han / Afterglow Provider evidence;
- no executable Source support.

Protected backend paths include:

- `src/source/**`
- `src/最终建局/**`
- `src/persistence/**`
- `src/行动判定/L0_公理层/**`
- `src/行动判定/L1_器件层/**`
- `src/行动判定/L2_流程层/**`

If a genuinely missing L3 UI-neutral projection blocks G4-08B, stop and report it rather than bypassing ownership.

---

## 6. G4-08B interaction rules

### Wizard

- show installed Expansion generations from existing inventory;
- no auto-select;
- explicit none remains valid;
- use `composition.set_expansion()` / `confirm_expansion_none()` as authority;
- Review shows actual selected Expansion names/versions;
- no import UI in this task.

### Runtime

No Expansion → preserve exact G4-07 Narrative path.

Public d20 → route Player action through:

`src/行动判定/L3_外交层/行动判定公开接口.gd`

UI supplies a stable opaque `action_id` and must not call `conversation.begin_turn()` first.

Retry after durable action failure/cancel reuses the same action_id/text; do not generate a fresh identity merely because Provider failed.

On reopen, an unresolved durable Public d20 action must be surfaced/retried rather than silently forgotten.

### Mechanic card

Card is read-only projection of durable Program truth. UI never rolls/recomputes/edits it.

Show accepted CHECK_REQUIRED results and rebuild them on Continue / Load from durable state. NO_CHECK has no dice card.

For Public d20 sessions, do not use the legacy post-accept generic Regenerate path in v0.1; unaccepted failures use `重试行动`. No-Expansion retains existing regenerate behavior.

---

## 7. Next progression

```text
G4-08B Kimi UI integration
→ GPT Independent Review
→ G4-09 First Playable B
→ Owner UAT B
→ remaining G4 gate work
```

Do not declare G4-08 PASS from UI implementation alone. Do not start G4-09 or G5 yourself.
