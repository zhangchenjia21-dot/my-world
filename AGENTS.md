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
G4-08B Public d20 UI Integration      PASS / CLOSED
G4-08BC01 UI Projection / Fail-Loud   PASS / CLOSED
G4-09 First Playable B                ACTIVE
G4-09P1 Owner UAT B Production Prep   ACTIVE — CODEX
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

G4-08 parent is not yet Product PASS; it remains active through the real Expansion product vertical / Owner UAT B.

---

## 3. Current execution task — G4-09P1

Formal packet:

`docs/tasks/G4-09P1_OWNER_UAT_B_PRODUCTION_PREP_TASK.md`

Formal Code Base:

`08287d28a9cacfc7795c7c7a35ef4739ff9faf2c`

Accepted G4-08B correction review:

`docs/g4_08b/G4-08BC01_INDEPENDENT_REVIEW.md`

Primary owner: **Codex**.  
Reviewer / semantic owner: **GPT**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Purpose:

> Prepare the Owner's real local environment for First Playable B using the supported Managed Source Library and canonical launcher, then hand off a minimal product UAT route.

Do not ask the Owner to manually copy files into the managed Source Library.

---

## 4. G4-08B final accepted result

G4-08B + BC01 are **PASS / CLOSED** at reviewed HEAD `08287d28a9cacfc7795c7c7a35ef4739ff9faf2c`.

Accepted player path:

```text
Wizard installed Expansion inventory
→ explicit 0..N exact selection / explicit none
→ Review exact Expansion projection
→ Final Create unchanged
→ Game-local capability routing
→ stable action_id
→ ActionAdjudication L3 Host
→ Program-owned Public d20 result
→ Player → mechanic card → GM narrative
→ durable redraw on Continue / Load
```

Accepted invariants:

- no Expansion preserves the G4-07 Narrative path;
- Public d20 UI never owns RNG/total/outcome;
- same durable `check_id` has at most one visible mechanic projection;
- retry/reopen uses the existing durable action identity and never rerolls;
- NO_CHECK has no dice card;
- accepted d20 turns do not use legacy generic Regenerate in v0.1;
- unknown materialized `action_resolution` capability fails visibly and never silently falls back to legacy play;
- explicit none is directly tested through Wizard → Review → frozen payload;
- protected backend paths and SQLite schema v4 are unchanged.

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
- no Expansion never silently enables d20;
- duplicate exact / same capability slot conflict fail closed;
- roll only for genuine uncertainty + meaningful failure cost;
- certain success / certain impossibility / no-cost repeat → no roll;
- Proposal freezes before RNG;
- Program owns die faces / selected roll / total / outcome;
- NO_CHECK remains one Provider call and durable replay-safe;
- CHECK_REQUIRED uses durable Program result before second Provider narrative and never rerolls on retry/restart;
- Expansion owns resolution, not downstream canonical World consequences.

---

## 6. G4-09P1 production-prep rules

Owner production Managed Source Library remains:

```text
user://my-world/source-library
```

Use only the existing SourceLibrary public install API. No manual filesystem copy into managed generations/current pointers.

Install/verify the exact Public d20 package already accepted by G4-08 evidence:

`res://tests/fixtures/g4_08m1/判定与检定_公开d20`

If already installed exactly, verify/reuse it. Never delete Owner generations or rewrite existing World/Character currents merely to satisfy the task.

Canonical Owner launcher remains:

```text
run-game.cmd
```

and freshness validation is:

```powershell
.\run-game.ps1 -ValidateExportOnly
```

Do not introduce a competing launch path.

Codex must also prepare the concise Owner UAT B instruction record under `docs/g4_09/`.

---

## 7. Protected boundaries

G4-09P1 is production preparation, not feature development.

Do not redesign:

- Source schema / Managed Library semantics;
- Composition;
- Final Create;
- Public d20 rules/RNG/durable identities;
- persistence schema;
- Provider protocol;
- accepted G4-08B Wizard/Narrative interaction;
- G8 player-facing Source import;
- G5/G6 systems.

Existing Owner games must not be modified or deleted.

---

## 8. Next progression

```text
G4-09P1 production prep — Codex
→ GPT Independent Review
→ G4-09UATB Owner Product UAT
→ if Owner PASS: Decision Propagation / close First Playable B and G4-08 product vertical
→ continue remaining G4-10 / G4-11 / G4-GATE work
```

Do not declare G4-09 PASS, G4-08 Product PASS, or G4-GATE PASS before explicit Owner UAT B verdict.
