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

## 2. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle   PASS / CLOSED
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
G4-05 New Game Wizard                 PASS / CLOSED
G4-06 Atomic Final Create             PASS / CLOSED
G4-07 First Playable A                PASS / CLOSED
G4-08 Expansion Pack v0.1             ACTIVE — gameplay value accepted, final gate pending
G4-08M1 Public d20 Mechanism          PASS / CLOSED
G4-08B Public d20 UI Integration      PASS / CLOSED
G4-09 First Playable B                ACTIVE pending Owner final verdict
G4-09P1 Owner UAT B Production Prep   PASS / CLOSED
G4-09R1 Runtime Model Settings v0.1   PASS / CLOSED
G4-09R1M1 Backend Mechanism           PASS / CLOSED
G4-09R1B1 Settings UI                 PASS / CLOSED AFTER CORRECTION-01
G4-09R1P1 Final Integration/Freshness PASS / CLOSED
G4-09UATBC01 Narrative Responsiveness PASS / CLOSED — streaming goal retained
G4-09UATB Owner Product UAT           HOLD — CORRECTION-02
G4-09UATBC02A d20 Protocol Decoupling PASS / CLOSED
G4-09UATBC02B Failure Visibility      ACTIVE — KIMI
G4-GATE                               NOT YET
```

Do not start G4-10 or G5 while correction-02 is active.

## 3. Current execution task — G4-09UATBC02B

Formal packet:

`docs/tasks/G4-09UATBC02B_PUBLIC_D20_FAILURE_VISIBILITY_TASK.md`

C02A Independent Review:

`docs/g4_09/G4-09UATBC02A_INDEPENDENT_REVIEW.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_RESPONSIVENESS_V0_1_DECISION.md`

Current owner: **KIMI**. Reviewer / semantic owner: **GPT**.

C02B is UI-only. It may surface concise safe terminal failure reasons and at most a compact non-blocking degradation notice. It must not redefine backend mechanics or protocol behavior.

Allowed production path:

- `src/ui/叙事对话视图.gd`

Protected:

- Action Adjudication backend
- Provider
- Persistence / Runtime
- Runtime Model Settings
- Source / Final Create
- SQLite schema

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

## 4. Accepted Model Freedom / Narrative Responsiveness truth

Core principle:

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

Protected absent concrete regression:

- player-visible GM narrative is free-form natural language;
- narrative has no JSON header, sentinel, exact-line or physical-LF framing contract;
- Public d20 mechanics control and narrative are separate selected-provider requests;
- the old `NO_CHECK = exactly one Provider call` optimization is superseded;
- isolated control accepts harmless whitespace / pretty-print formatting;
- malformed control gets at most one bounded internal recovery attempt;
- if control remains unresolved, the action fails soft to ordinary free-form narrative, remains playable, creates no d20 check and no fake NO_CHECK marker;
- valid CHECK_REQUIRED still freezes Program RNG/outcome durably before result narrative;
- narrative streams provisionally with no per-token canonical persistence;
- partial visible draft after fail/cancel is excluded from future Context;
- stable action/check identity and no-reroll remain protected;
- selected Provider only; no cross-provider fallback;
- hard gates remain only where authoritative integrity requires them or no Provider narrative can be produced.

C02B must **not** add a model-format parser, fallback, automatic Provider switching, retry policy, or new blocking state.

## 5. Accepted Runtime Model Settings v0.1 truth

Protected absent concrete regression:

- app-local settings `user://my-world/settings/provider-runtime.json`;
- exact four player-facing profiles: DeepSeek V4 Pro, DeepSeek V4 Flash, Kimi K3, Kimi K2.7;
- DeepSeek/K3 256K/1M compatibility; K2.7 256K-only;
- DeepSeek/K3 requested reasoning `low/medium/high/max`, with `medium -> effective high`;
- K2.7 fixed Thinking ON / no graded effective effort;
- selected-provider credentials only: `DEEPSEEK_API_KEY` / `KIMI_API_KEY`;
- no cross-provider fallback;
- Main Menu settings UI behavior accepted;
- Source/Final Create semantics and SQLite schema v4 remain unchanged.

## 6. Owner UAT disposition

Owner already accepted Public d20 gameplay value. Do not reopen that question absent a concrete gameplay regression.

Owner UAT remains HOLD until C02B passes GPT Independent Review. After C02B passes and Windows/product freshness is current, resume only a focused reliability/responsiveness retest.

If the same decoupled control-lane seam repeatedly fails in real Provider use, do not add more formatting patches. Return for a control-capability redesign per correction-budget governance.

Do not start G5 before G4-GATE.
