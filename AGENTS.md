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
G4-09UATB Owner Product UAT           HOLD — NARRATIVE RESPONSIVENESS CORRECTION
G4-09UATBC01 Narrative Responsiveness ACTIVE — CODEX
G4-GATE                               NOT YET
```

Do not start G4-10 or G5 while G4-09UATBC01 is active.

## 3. Current execution task — G4-09UATBC01

Formal task packet:

`docs/tasks/G4-09UATBC01_NARRATIVE_RESPONSIVENESS_STREAMING_TASK.md`

Owner finding:

`docs/g4_09/G4-09UATB_OWNER_FINDING_NARRATIVE_RESPONSIVENESS.md`

Canonical governance decision:

`Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_RESPONSIVENESS_V0_1_DECISION.md`

Current owner: **CODEX**. Reviewer / semantic owner: **GPT**.

Core runtime principle:

```text
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

The current defect is not per-token SQLite persistence. Ordinary Conversation already streams deltas in memory and persists after completion. The Public d20 Host currently buffers narrative until Provider completion, which is the bounded correction target.

Codex must preserve:

- CHECK_REQUIRED exact Program d20 result durable before result narrative begins;
- NO_CHECK one Provider call;
- stable action/check identity and no reroll;
- partial visible draft is provisional and excluded from future Context if fail/cancel;
- no per-token canonical writes;
- next player action remains blocked until current turn finalize completes;
- no UI redesign / no G5 semantic systems / no generic job queue.

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

## 4. Accepted Runtime Model Settings v0.1 truth

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
- real DeepSeek V4 Pro and real Kimi K3 UI-selected Opening completed;
- Source/Final Create semantics and SQLite schema v4 remain unchanged.

## 5. Owner UAT disposition

Owner has already accepted the **gameplay value/semantics** of Public d20. Do not discard that finding.

The overall G4-09UATB remains open only because narrative responsiveness in the Expansion path is a core-loop blocker. After Codex returns and GPT Independent Review passes, Owner UAT resumes as a focused responsiveness/regression retest.

If that focused retest passes, GPT may close G4-09UATB, G4-09 First Playable B and G4-08 Expansion Pack v0.1, then inspect the canonical roadmap before shaping G4-10.

Do not start G5 before G4-GATE.
