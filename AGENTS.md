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
G4-09UATBC02A d20 Protocol Decoupling ACTIVE — CODEX
G4-09UATBC02B Failure Visibility      HOLD — KIMI
G4-GATE                               NOT YET
```

Do not start G4-10 or G5 while correction-02 is active.

## 3. Current execution task — G4-09UATBC02A

Formal packet:

`docs/tasks/G4-09UATBC02A_D20_PROTOCOL_DECOUPLING_TASK.md`

Owner finding:

`docs/g4_09/G4-09UATB_OWNER_FINDING_STREAMING_PROTOCOL_ROBUSTNESS.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_RESPONSIVENESS_V0_1_DECISION.md`

Current owner: **CODEX**. Reviewer / semantic owner: **GPT**.

Core principle:

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

The C01 mixed `control JSON + narrative body` protocol is superseded. Do not repair it by accumulating more parser special cases.

Codex must decouple:

```text
short mechanics control lane
from
free-form player-visible narrative lane
```

Narrative must not require JSON/sentinel/physical-line framing. The old `NO_CHECK = exactly one Provider call` optimization is superseded by reliability/model freedom.

If the isolated control lane remains malformed after one bounded internal recovery attempt, fail-soft this action to ordinary no-Expansion natural-language narrative rather than leaving the player in a dead-end unfinished state. Do not create a fake check or fake successful-adjudication marker.

Preserve:

- selected Provider only / no fallback;
- CHECK_REQUIRED durable Program result before result narrative;
- stable action/check identity / no reroll;
- progressive provisional narrative streaming;
- no per-token persistence;
- Turn Finalize Barrier;
- SQLite v4 and Source/Final Create semantics.

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

## 4. C02B remains HOLD

`docs/tasks/G4-09UATBC02B_PUBLIC_D20_FAILURE_VISIBILITY_TASK.md`

Kimi must not start C02B until GPT closes C02A. C02B only surfaces safe terminal failure reasons and a non-blocking degradation notice; it does not redefine backend behavior.

## 5. Accepted boundaries preserved

The Owner already accepted Public d20 gameplay value. Do not reopen that product question absent a concrete gameplay regression.

Runtime Model Settings v0.1 remains accepted. No model catalog, endpoint, credential, context-limit, reasoning or fallback redesign belongs in correction-02.

## 6. Correction-budget note

This is correction-02. If the **decoupled control lane itself** still repeatedly fails on the same real-model seam after C02A, stop adding formatting patches and return for protocol redesign per governance.

Do not start G5 before G4-GATE.
