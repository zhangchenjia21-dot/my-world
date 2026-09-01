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
G4-09R1M1 Backend Mechanism           PASS / CLOSED
G4-09R1M1C01 Projection/Kimi Proof    PASS / CLOSED
G4-09R1B1 Settings UI                 ACTIVE — KIMI
G4-GATE                               NOT YET
```

Owner explicitly inserted G4-09R1 before UAT B. Do not resume G4-09UATB until UI Independent Review plus final real Provider/freshness integration pass.

---

## 3. Current execution task — G4-09R1B1

Formal packet:

`docs/tasks/G4-09R1B1_MODEL_SETTINGS_UI_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

Accepted backend review:

`docs/g4_09r1/G4-09R1M1C01_INDEPENDENT_REVIEW.md`

Primary owner: **Kimi**.  
Reviewer / semantic owner: **GPT**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Codex has no active backend task.

---

## 4. Accepted runtime model settings backend

Reviewed backend/evidence HEAD:

`6ea825ba0ea0d5a57728c55789f437ff9626b6cb`

Accepted and protected absent concrete regression:

- app-local settings `user://my-world/settings/provider-runtime.json`;
- schema `my-world.provider-runtime.v1`;
- default `deepseek_v4_pro / 256k / high`;
- closed four-profile catalog;
- exact model identities:
  - DeepSeek V4 Pro → `deepseek-v4-pro`;
  - DeepSeek V4 Flash → `deepseek-v4-flash`;
  - Kimi K3 256K → `k3-256k`;
  - Kimi K3 1M → `k3`;
  - Kimi K2.7 256K → `kimi-for-coding`;
- K2.7 + 1M fails closed;
- DeepSeek/K3 requested→effective reasoning `low→low`, `medium→high`, `high→high`, `max→max`;
- K2.7 fixed Thinking ON / no graded effective effort;
- atomic/fail-safe settings persistence;
- selected-provider-only credentials `DEEPSEEK_API_KEY` / `KIMI_API_KEY`;
- missing selected key = zero network / no fallback;
- one runtime Provider seam used by Opening, Narrative and both Public d20 phases;
- active request freezes profile;
- reasoning-only stream material is not player narrative;
- real DeepSeek V4 Pro/Flash and real Kimi `k3-256k`, `k3`, `kimi-for-coding` calls completed;
- Source/Final Create/Public d20 semantics/SQLite v4 unchanged.

---

## 5. Frontend ownership / mandatory backend seam

Kimi owns presentation and interaction only.

For unsaved settings preview, UI must use:

```text
ModelRuntimeSettingsPublicInterface.inspect_candidate(settings)
```

That backend projection owns:

```text
profile display/provider
selected + allowed context
requested/effective reasoning
graded vs fixed thinking
selected-provider credential configured bool
validation failures
```

UI must not duplicate provider compatibility or requested→effective mapping and must not construct endpoint/model-id/request payload fields.

Required UI surface from Main Menu:

```text
模型
上下文上限
思考强度
DeepSeek / Kimi credential status
实际配置摘要
Save / Cancel
```

Exact display models:

```text
DeepSeek V4 Pro
DeepSeek V4 Flash
Kimi K3
Kimi K2.7
```

K2.7: 256K only, graded effort disabled, visible fixed-thinking explanation.
Medium on DeepSeek/K3: selectable, summary must disclose actual High.

No API-key editing, custom endpoint, custom model id, fallback routing, in-game settings drawer or per-Game model pinning.

---

## 6. Real integration requirement

Backend reality proof already established both Provider families.

B1 must additionally prove the actual Main Menu settings surface can select and persist settings and drive at least:

```text
one DeepSeek UI selection → real generation
one Kimi UI selection     → real generation
```

Do not expose credentials or substitute another model/provider.

Layouts must remain usable at 1280×720, 960×540 and maximized desktop. Continue/New Game/Public d20 UI must remain green.

---

## 7. Protected boundaries

Do not redesign:

- Source / Managed Library;
- Composition / Final Create;
- Game/Timeline persistence or SQLite schema v4;
- Public d20 semantics/RNG/action identity;
- backend Provider profile/catalog semantics absent concrete regression;
- G7 long-session architecture;
- G8 provider/plugin framework.

---

## 8. Progression

```text
G4-09R1B1 — Kimi
→ GPT Independent Review
→ final real DeepSeek + Kimi product integration / Windows freshness
→ refresh Owner UAT instructions
→ resume G4-09UATB — OWNER
```

G4-09, G4-08 and G4-GATE remain open. Do not start G4-10 or G5.