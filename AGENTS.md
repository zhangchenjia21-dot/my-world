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
G4-09R1B1 Settings UI                 CORRECTION REQUIRED
G4-09R1B1C01A L3 UI Support           ACTIVE — CODEX
G4-09R1B1C01B UI State Consistency    HOLD — KIMI
G4-GATE                               NOT YET
```

Owner UAT remains HOLD until B1 correction plus final integration/freshness pass.

---

## 3. Current execution task — G4-09R1B1C01A

Formal packet:

`docs/tasks/G4-09R1B1C01A_RUNTIME_SETTINGS_L3_UI_SUPPORT_TASK.md`

Independent Review finding:

`docs/g4_09r1/G4-09R1B1_INDEPENDENT_REVIEW.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

Primary owner: **Codex**.  
Reviewer / semantic owner: **GPT**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Kimi correction packet exists but remains HOLD:

`docs/tasks/G4-09R1B1C01B_UI_STATE_CONSISTENCY_CORRECTION_TASK.md`

Do not let Kimi start C01B before GPT Independent Review passes C01A.

---

## 4. Accepted runtime model settings backend

Accepted and protected absent concrete regression:

- app-local settings `user://my-world/settings/provider-runtime.json`;
- schema `my-world.provider-runtime.v1`;
- exact default `deepseek_v4_pro / 256k / high`;
- closed four-profile catalog;
- DeepSeek V4 Pro / Flash, Kimi K3 256K/1M, Kimi K2.7 exact model derivation;
- K2.7 + 1M fails closed;
- DeepSeek/K3 requested→effective reasoning mapping;
- K2.7 fixed Thinking ON / no graded effective effort;
- selected-provider-only credentials and no fallback;
- one Provider seam for Opening, Narrative and both Public d20 phases;
- active request freezes profile;
- reasoning-only stream material is not player narrative;
- real DeepSeek V4 Pro/Flash and real Kimi `k3-256k`, `k3`, `kimi-for-coding` calls completed;
- Source/Final Create/Public d20 semantics/SQLite v4 unchanged.

C01A may only add the UI-supporting L3 projection described below. Do not reopen Provider/model semantics.

---

## 5. B1 review findings / correction boundary

Reviewed B1/evidence HEAD:

`fcdcec66edad41afbb93f4a5e9cc70174402be5c`

Accepted B1 work includes Main Menu settings entry, exact four display models, valid `inspect_candidate()` preview, Medium→actual High disclosure, valid K2.7/256K fixed-thinking UI, Save/Cancel/restart persistence, non-secret credential display, desktop layout evidence, and real DeepSeek + Kimi UI-selection-to-Opening generation.

Remaining blockers:

1. `K3 / 1M → select K2.7` yields an invalid context, but current failure branch leaves graded reasoning enabled and hides fixed-Thinking explanation.
2. Application Shell directly imports Runtime Settings L0 to obtain `validated_default()` for invalid persisted recovery; UI must depend on L3 only.
3. Settings overlay has no explicit `ui_cancel` / Escape path.

C01A owns backend support only:

```text
validated default through L3
+
incompatible candidate returns safe partial capability truth
```

No UI changes in C01A.

---

## 6. Next UI correction after C01A

After GPT passes C01A, Kimi executes:

`docs/tasks/G4-09R1B1C01B_UI_STATE_CONSISTENCY_CORRECTION_TASK.md`

Required result:

```text
remove UI → L0 dependency
K2.7 fixed-thinking truth visible even while 1M is invalid
Save remains disabled until 256K is selected
switching back to graded model re-enables reasoning
Escape/ui_cancel = Cancel without Save
```

Compatibility/effective truth must still be backend-derived.

---

## 7. Protected boundaries

Do not redesign:

- Source / Managed Library;
- Composition / Final Create;
- Game/Timeline persistence or SQLite schema v4;
- Public d20 semantics/RNG/action identity;
- Provider wire/model identities absent concrete regression;
- G7 long-session architecture;
- G8 provider/plugin framework.

---

## 8. Progression

```text
G4-09R1B1C01A — Codex
→ GPT Independent Review
→ G4-09R1B1C01B — Kimi
→ GPT Independent Review
→ G4-09R1B1 PASS / CLOSED
→ final real Provider / Windows freshness integration
→ refresh Owner UAT instructions
→ resume G4-09UATB — OWNER
```

G4-09, G4-08 and G4-GATE remain open. Do not start G4-10 or G5.