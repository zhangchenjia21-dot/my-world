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
Owner      → Product UAT / explicit product verdict
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
G4-09P1 Owner UAT B Production Prep   PASS / CLOSED
G4-09UATB Owner Product UAT           ACTIVE — OWNER
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

G4-08 parent is not yet Product PASS. It remains active until the Owner returns an explicit G4-09UATB verdict.

---

## 3. Current execution task — G4-09UATB

Formal packet:

`docs/tasks/G4-09UATB_OWNER_PRODUCT_UAT_TASK.md`

Product instructions:

`docs/g4_09/G4-09UATB_Owner产品验收说明.md`

Accepted production-prep review:

`docs/g4_09/G4-09P1_INDEPENDENT_REVIEW.md`

Current owner: **OWNER**.  
Semantic/review owner: **GPT**.

No Codex or Kimi execution task is active.

The Owner verdict must be explicit `PASS` or `FAIL`. Engineering evidence cannot substitute for this product verdict.

---

## 4. Accepted Public d20 vertical

G4-08B + BC01 are PASS / CLOSED. Accepted path:

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
- UI never owns RNG/total/outcome;
- one durable `check_id` has at most one visible mechanic projection;
- retry/reopen reuses the durable action identity and never rerolls;
- NO_CHECK has no dice card;
- accepted d20 turns do not use legacy generic Regenerate in v0.1;
- unknown materialized `action_resolution` capability fails visibly and never falls back to legacy play;
- SQLite remains schema v4.

---

## 5. Frozen Public d20 semantics

Canonical authority:

`Vibe-Coding/my world/architecture/source/G4_EXPANSION_V0_1_PUBLIC_D20_DECISION.md`

```text
Display Name  判定与检定：公开 d20
asset_id      exp.check_core.public_d20
asset_type    expansion_pack
schema        expansion_pack.v0.1
capability    action_check.public_d20.v1
slot          action_resolution
```

Frozen:

- Expansion selection is explicit exact generations;
- no silent enable;
- duplicate exact / same capability slot conflict fail closed;
- roll only for genuine uncertainty + meaningful failure cost;
- Proposal freezes before RNG;
- Program owns dice / selected roll / total / outcome;
- NO_CHECK remains one Provider call and replay-safe;
- CHECK_REQUIRED uses durable Program result and never rerolls on retry/restart;
- Expansion owns resolution, not downstream canonical World consequences.

---

## 6. Owner UAT B route

Launch only through:

`run-game.cmd`

Preferred Game:

```text
World      汉末三国：天下未定
Entry      208 / 赤壁前夕
Player     刘备
NPC        孙权 (optional guaranteed)
Expansion  判定与检定：公开 d20
```

Owner validates:

1. Review visibly lists the Expansion.
2. Real DeepSeek Opening completes.
3. A genuinely risky action produces a public d20 card.
4. GM continuation respects the Program result.
5. An ordinary/no-risk action produces no unnecessary dice card.
6. Save → Main Menu → Continue preserves the same Game/history/result.
7. Most importantly, Public d20 adds worthwhile gameplay.

Return format:

```text
PASS
```

or:

```text
FAIL
<what felt wrong / what broke>
```

Do not ask the Owner to manipulate managed Source Library internals.

---

## 7. Production prep accepted state

G4-09P1 is PASS / CLOSED at reviewed HEAD `cf8b9cb998263ae44f6f8c2f145f78dd815ef176`.

Accepted recorded production facts:

- Public d20 exact generation is installed/current through SourceLibrary public API;
- fingerprint `e40bf3cb1059a4952d4230ae624fc3a0ba9bc705e279b13fef8cd1e795ca5ec1`;
- production inventory observed World 2 / Character 6 / Expansion 1;
- Owner games were not modified by the prep utility;
- canonical Windows export freshness validation passed;
- G4-08B smoke remained green;
- Provider-facing semantics were unchanged.

---

## 8. Next progression

```text
G4-09UATB Owner Product UAT
→ explicit Owner PASS / FAIL
→ GPT Decision Propagation
```

If PASS:

```text
G4-09 First Playable B      PASS / CLOSED
G4-08 Expansion Pack v0.1   Product PASS / CLOSED
→ G4-10 Runtime Asset Resolution
→ G4-11 Two Primary Asset Families Reality Test
→ G4-GATE
```

If FAIL, GPT classifies the concrete product seam and routes the smallest correction.

Do not start G4-10 or G5 before the required verdict/progression. G4-GATE remains NOT YET.
