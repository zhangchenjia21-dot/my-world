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
G4-09UATBC01 Narrative Responsiveness PASS / CLOSED
G4-09UATB Owner Product UAT           ACTIVE — OWNER focused responsiveness retest
G4-GATE                               NOT YET
```

No Codex or Kimi task is active. Do not start G4-10 or G5 while Owner UAT B is active.

## 3. Current execution task — G4-09UATB focused retest

Owner instructions:

`docs/g4_09/G4-09UATB_Owner产品验收说明.md`

Accepted responsiveness review:

`docs/g4_09/G4-09UATBC01_INDEPENDENT_REVIEW.md`

Owner finding preserved:

`docs/g4_09/G4-09UATB_OWNER_FINDING_NARRATIVE_RESPONSIVENESS.md`

Current owner: **OWNER**. Reviewer / semantic owner: **GPT**.

The Owner already accepted Public d20 gameplay/semantics. The remaining UAT only checks responsiveness and adjacent regression safety.

Focused route:

```text
run-game.cmd
→ Continue existing Public d20 Game if desired
→ one ordinary NO_CHECK action
→ verify GM narrative grows progressively while Provider remains active
→ one risky CHECK_REQUIRED action
→ verify durable d20 card appears before result narrative
→ verify result narrative grows progressively
→ verify no duplicate Player/card/reroll/result rewrite
→ Save → Main Menu → Continue
→ Owner responsiveness verdict
```

## 4. Accepted Narrative Responsiveness v0.1 truth

Canonical principle:

```text
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

Accepted implementation truth:

- Public d20 no longer buffers player-visible narrative until whole-response completion;
- NO_CHECK remains one Provider call: validated one-line control header followed by raw streamable narrative body;
- control JSON never becomes Narrative UI text;
- NO_CHECK body streams into provisional Conversation after header validation;
- CHECK_REQUIRED exact Program d20 result remains durable before result-narrative request / visible result text;
- CHECK_REQUIRED result narrative streams through provisional Conversation while the second Provider call is active;
- no per-token canonical SQLite/world persistence;
- Provider fail/cancel leaves partial visible draft unaccepted and excluded from future Context;
- same-process retry reuses the matching unaccepted Player turn;
- durable NO_CHECK/check replay and lost-ACK recovery still avoid replacement Provider calls/rerolls as previously specified;
- next action remains behind the Turn Finalize Barrier until Conversation and required acceptance markers finalize;
- timing observability distinguishes Provider first content, first visible narrative, Provider completion and finalize without secrets/content;
- Conversation/UI/Persistence/Runtime/Provider ownership and SQLite v4 are unchanged;
- canonical Windows export was rebuilt/verified after the correction;
- a real DeepSeek V4 Pro task-owned vertical exercised both CHECK_REQUIRED and NO_CHECK progressive visibility.

Important performance interpretation:

- application-added whole-response buffering is fixed;
- selected-model Provider TTFT/reasoning latency can still be substantial, especially CHECK_REQUIRED because it uses adjudication + result-narrative Provider stages;
- remaining slowness must be diagnosed with timing evidence rather than attributed to per-token persistence.

## 5. Runtime Model Settings v0.1 remains accepted

Protected absent concrete regression:

- app-local settings `user://my-world/settings/provider-runtime.json`;
- exact four player-facing profiles: DeepSeek V4 Pro, DeepSeek V4 Flash, Kimi K3, Kimi K2.7;
- DeepSeek/K3 256K/1M compatibility; K2.7 256K-only;
- DeepSeek/K3 requested reasoning `low/medium/high/max`, with `medium -> effective high`;
- K2.7 fixed Thinking ON / no graded effective effort;
- selected-provider credentials only: `DEEPSEEK_API_KEY` / `KIMI_API_KEY`;
- no cross-provider fallback;
- one Provider seam across Opening, Narrative and Public d20 phases;
- Main Menu settings UI behavior accepted;
- Source/Final Create semantics and SQLite schema v4 remain unchanged.

## 6. Owner UAT disposition

Owner only needs to return the focused responsiveness/regression verdict. Do not re-open the already accepted question of whether Public d20 adds worthwhile gameplay absent a concrete regression.

If focused retest PASS, GPT may close G4-09UATB, G4-09 First Playable B and G4-08 Expansion Pack v0.1, then inspect the canonical roadmap before shaping G4-10.

If focused retest FAIL, record the exact remaining latency/regression seam and apply the correction budget without discarding accepted boundaries not implicated by the failure.

Do not start G5 before G4-GATE.
