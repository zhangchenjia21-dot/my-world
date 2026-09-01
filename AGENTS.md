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
G4-09R1M1 Backend Mechanism           ACTIVE — CODEX
G4-09R1B1 Settings UI                 HOLD — KIMI
G4-GATE                               NOT YET
```

G4-07 Owner Product UAT verdict: **PASS**.

Owner explicitly inserted G4-09R1 before UAT B. Do not resume G4-09UATB until backend + UI + real Provider/freshness review pass.

---

## 3. Current execution task — G4-09R1M1

Formal packet:

`docs/tasks/G4-09R1M1_RUNTIME_MODEL_SETTINGS_MECHANISM_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

Primary owner: **Codex**.  
Reviewer / semantic owner: **GPT**.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Kimi task exists but remains HOLD:

`docs/tasks/G4-09R1B1_MODEL_SETTINGS_UI_TASK.md`

Do not let Codex implement the final player-facing settings UI and do not let Kimi start before M1 Independent Review PASS.

---

## 4. Frozen runtime model settings v0.1

Player-facing catalog:

```text
DeepSeek V4 Pro
DeepSeek V4 Flash
Kimi K3
Kimi K2.7
```

Context choices:

```text
256K
1M
```

Reasoning requested choices:

```text
Low
Medium
High
Max
```

Exact runtime rules:

- DeepSeek V4 Pro → `deepseek-v4-pro`; 256K/1M; low→low, medium→high, high→high, max→max.
- DeepSeek V4 Flash → `deepseek-v4-flash`; 256K/1M; same effort mapping.
- Kimi K3 → `k3-256k` at 256K, `k3` at 1M; same effort mapping.
- Kimi K2.7 → `kimi-for-coding`; 256K only; Thinking ON is fixed and graded effort is unavailable.
- no arbitrary model id, endpoint, fallback chain or provider plugin system.

Credentials:

```text
DEEPSEEK_API_KEY
KIMI_API_KEY
```

Secrets remain environment-only. App settings never store keys.

Default validated setting:

```text
DeepSeek V4 Pro / 256K / High
```

Settings are application-local runtime preferences, not Game/Source truth and not SQLite schema.

---

## 5. Backend acceptance focus

Codex must establish one Program-owned runtime profile seam consumed by every real Provider call:

```text
Opening
ordinary Narrative
Public d20 adjudication
Public d20 resolution narrative
retry/reopen Provider calls
```

No hidden hard-coded DeepSeek path may remain.

Provider selection is explicit; no automatic DeepSeek↔Kimi fallback.

Missing selected Provider credential sends no network request and fails visibly.

Real Kimi runtime support cannot be declared solely from stubs. If local `KIMI_API_KEY` / entitlement is absent, return that exact blocker.

Do not change SQLite schema v4, Source, Final Create or Public d20 semantics.

---

## 6. Accepted Public d20 vertical remains frozen

G4-08B + BC01 remain PASS / CLOSED:

```text
exact Expansion selection
→ Game-local capability
→ stable action_id
→ Program-owned d20
→ Player → mechanic card → GM narrative
→ durable Continue / Load
```

Do not reopen d20 semantics absent a concrete regression caused by provider routing.

---

## 7. Context boundary

The 256K/1M choice is an application runtime context ceiling/capability selection. G2-05 may continue to use less than the ceiling.

Do not pull G7 forward: no summarization, retrieval, memory compression, generic tokenizer platform or long-session redesign in G4-09R1.

---

## 8. Progression

```text
G4-09R1M1 — Codex
→ GPT Independent Review
→ if PASS: activate G4-09R1B1 — Kimi
→ GPT Independent Review
→ real DeepSeek + Kimi integration / Windows freshness
→ refresh Owner UAT instructions
→ resume G4-09UATB — OWNER
```

G4-09, G4-08 and G4-GATE remain open. Do not start G4-10 or G5.