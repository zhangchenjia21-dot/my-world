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
G4-09UATBC02A d20 Protocol Decoupling PASS / CLOSED
G4-09UATBC02B Failure Visibility      PASS / CLOSED AFTER C01
G4-09UATBC02BC01 Persistence Visibility PASS / CLOSED
G4-09UATBC02P1 Final Windows Freshness ACTIVE — CODEX
G4-09UATB Owner Product UAT           HOLD — awaiting final current-head Windows freshness
G4-GATE                               NOT YET
```

Do not start G4-10 or G5 before Owner UAT/final gate closure.

## 3. Current execution task — G4-09UATBC02P1

Formal packet:

`docs/tasks/G4-09UATBC02P1_FINAL_WINDOWS_FRESHNESS_TASK.md`

Current owner: **CODEX**. Reviewer / semantic owner: **GPT**.

This is validation-only. No production behavior change is expected.

Required closeout:

- refresh both `main` branches;
- run canonical `.\run-game.ps1 -ValidateExportOnly` against the current final correction-02 source head, rebuilding stale Windows export if required;
- run focused G4-08B/C02B/C02BC01 UI integration;
- confirm SQLite v4 and protected Owner/Source/settings/credential surfaces untouched;
- `git diff --check` clean.

Do not rerun real Provider benchmarks solely for this task; C02A real DeepSeek/Kimi evidence remains authoritative because C02B/C02BC01 changed only UI projection.

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

## 4. Protected Model Freedom / Narrative Responsiveness truth

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
- old `NO_CHECK = exactly one Provider call` optimization is superseded;
- malformed isolated control gets at most one bounded recovery attempt;
- if still unresolved, action fails soft to ordinary narrative with no fake d20/NO_CHECK truth;
- valid CHECK_REQUIRED freezes Program RNG/outcome durably before result narrative;
- narrative streams provisionally with no per-token canonical persistence;
- partial visible draft after fail/cancel is excluded from future Context;
- stable action/check identity and no-reroll remain protected;
- selected Provider only; no cross-provider fallback;
- legitimate hard failures show concise safe player-readable reasons and retain recovery controls.

Do not add parser formatting special cases, provider fallback, retry frameworks, or new blocking gates.

## 5. Owner UAT disposition

Owner already accepted Public d20 gameplay value. Do not reopen that question absent a concrete gameplay regression.

After G4-09UATBC02P1 PASS, resume only a focused reliability/responsiveness Owner retest. Do not start G5 before G4-GATE.
