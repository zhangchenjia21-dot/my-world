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
G4-09UATB Owner Product UAT           HOLD
G4-09R1 Runtime Model Settings v0.1   ACTIVE
G4-09R1S0 Semantic Freeze             PASS / CLOSED — GPT
G4-09R1M1 Backend Mechanism           CORRECTION REQUIRED
G4-09R1M1C01 Projection/Kimi Proof    ACTIVE — CODEX
G4-09R1B1 Settings UI                 HOLD — KIMI
G4-GATE                               NOT YET
```

Owner explicitly inserted G4-09R1 before UAT B. Do not resume G4-09UATB until backend + UI + real Provider/freshness review pass.

---

## 3. Current execution task — G4-09R1M1C01

Formal correction packet:

`docs/tasks/G4-09R1M1C01_SETTINGS_PROJECTION_KIMI_PROOF_CORRECTION_TASK.md`

Independent Review:

`docs/g4_09r1/G4-09R1M1_INDEPENDENT_REVIEW.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

Primary owner: **Codex**.  
Reviewer / semantic owner: **GPT**.  
Correction budget: **correction-01**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Kimi task remains HOLD:

`docs/tasks/G4-09R1B1_MODEL_SETTINGS_UI_TASK.md`

Do not let Kimi start before M1C01 Independent Review PASS.

---

## 4. Accepted M1 mechanism — do not reopen generically

Reviewed candidate/evidence HEAD:

`7b183d4b5aecd1b4d0e0f80fbfe235ded4c67344`

Accepted from M1:

- app-local settings `user://my-world/settings/provider-runtime.json`;
- schema `my-world.provider-runtime.v1`;
- default `deepseek_v4_pro / 256k / high`;
- closed four-profile catalog and exact endpoints/model derivation;
- K2.7 + 1M fail-closed;
- DeepSeek/K3 requested→effective mapping;
- K2.7 fixed-thinking capability metadata;
- atomic/fail-safe settings persistence;
- selected-provider-only credentials `DEEPSEEK_API_KEY` / `KIMI_API_KEY`;
- missing selected key = zero network / no fallback;
- one runtime Provider seam used by Opening, Narrative and both Public d20 phases;
- request snapshot immutable while active;
- reasoning-only stream material not emitted as GM narrative;
- launcher can reach Main Menu with either/both/no key;
- real DeepSeek V4 Pro/Flash evidence completed;
- Source/Final Create/Public d20 semantics/SQLite v4 unchanged.

---

## 5. Exact correction focus

### A. UI-safe candidate projection

Future Settings UI must not duplicate backend policy or write settings merely to preview them.

Add a non-mutating backend L3 projection for an unsaved candidate that returns enough non-secret truth to show:

```text
model display/capability
selected + allowed context
requested/effective reasoning
K2.7 fixed thinking
selected-provider configured bool
validation errors
```

It must prove:

- K2.7 + 1M invalid;
- Medium → effective High for DeepSeek/K3;
- K2.7 has no fake effective graded effort;
- no secret values and no UI-owned transport/model-id derivation.

### B. Kimi Thinking wire + reality proof

Frozen product semantics:

```text
Kimi K3    → Thinking ON + low/high/max effort
Kimi K2.7  → Thinking ON fixed; no graded effort
```

Current M1 had no real Kimi credential, so stubs cannot close this. Verify current official Kimi wire behavior and correct payload derivation if explicit Thinking enablement is required.

Real Kimi support cannot be declared until small real calls succeed or a precise credential/entitlement blocker is reported.

No cross-provider fallback and no model substitution.

---

## 6. Frozen model settings catalog

```text
DeepSeek V4 Pro     → deepseek-v4-pro; 256K/1M
DeepSeek V4 Flash   → deepseek-v4-flash; 256K/1M
Kimi K3 / 256K      → k3-256k
Kimi K3 / 1M        → k3
Kimi K2.7 / 256K    → kimi-for-coding
```

Reasoning:

```text
DeepSeek/K3:
Low → low
Medium → high
High → high
Max → max

Kimi K2.7:
Thinking ON fixed; no graded effort control
```

Settings are application-local runtime preferences, not Source/Game/SQLite truth.

---

## 7. Protected boundaries

Do not redesign:

- Source / Managed Library;
- Composition / Final Create;
- Game/Timeline persistence or SQLite schema v4;
- Public d20 semantics/RNG/action identity;
- final Settings UI;
- G7 long-session architecture;
- G8 provider/plugin framework.

---

## 8. Progression

```text
G4-09R1M1C01 — Codex
→ GPT Independent Review
→ if PASS: G4-09R1M1 PASS / CLOSED
→ activate G4-09R1B1 — Kimi
→ GPT Independent Review
→ real DeepSeek + Kimi integration / Windows freshness
→ refresh Owner UAT instructions
→ resume G4-09UATB — OWNER
```

G4-09, G4-08 and G4-GATE remain open. Do not start G4-10 or G5.