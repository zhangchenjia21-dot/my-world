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
G4-08 Expansion Pack v0.1             ACTIVE
G4-08M1 Public d20 Mechanism          PASS / CLOSED
G4-08B Public d20 UI Integration      PASS / CLOSED
G4-09 First Playable B                ACTIVE
G4-09P1 Owner UAT B Production Prep   PASS / CLOSED
G4-09UATB Owner Product UAT           HOLD
G4-09R1 Runtime Model Settings v0.1   ACTIVE
G4-09R1S0 Semantic Freeze             PASS / CLOSED
G4-09R1M1 Backend Mechanism           PASS / CLOSED
G4-09R1B1 Settings UI                 PASS / CLOSED AFTER CORRECTION-01
G4-09R1B1C01A L3 UI Support           PASS / CLOSED
G4-09R1B1C01B UI State Consistency    PASS / CLOSED
G4-09R1P1 Final Integration/Freshness ACTIVE — CODEX
G4-GATE                               NOT YET
```

Owner UAT remains HOLD until G4-09R1P1 Independent Review passes.

## 3. Current execution task — G4-09R1P1

Formal packet:

`docs/tasks/G4-09R1P1_FINAL_INTEGRATION_FRESHNESS_TASK.md`

Accepted Settings UI review:

`docs/g4_09r1/G4-09R1B1_INDEPENDENT_REVIEW.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

Primary owner: **Codex**. Reviewer / semantic owner: **GPT**. Return ceiling: **READY FOR INDEPENDENT REVIEW**.

Kimi has no active task.

## 4. Accepted Runtime Model Settings truth

Accepted and protected absent a concrete regression:

- app-local settings `user://my-world/settings/provider-runtime.json`;
- exact closed profiles: DeepSeek V4 Pro, DeepSeek V4 Flash, Kimi K3, Kimi K2.7;
- DeepSeek/K3 256K/1M compatibility; K2.7 256K-only;
- DeepSeek/K3 requested reasoning `low/medium/high/max` with `medium → effective high`;
- K2.7 fixed Thinking ON / no graded effective effort;
- selected-provider credentials only: `DEEPSEEK_API_KEY` / `KIMI_API_KEY`;
- no cross-provider fallback;
- one Provider seam across Opening, Narrative and both Public d20 phases;
- active request freezes its profile snapshot;
- reasoning-only stream material is not player narrative;
- UI uses L3 `inspect_candidate()` / `validated_default_settings()`, not Runtime Settings internals;
- Main Menu settings Save/Cancel/Escape/restart behavior is accepted;
- real DeepSeek and Kimi UI-selected generation evidence exists;
- Source/Final Create/Public d20 semantics and SQLite schema v4 remain unchanged.

## 5. G4-09R1P1 required result

This is validation/UAT-readiness work, not feature development.

Codex must:

1. rerun real selected-provider UI verticals on current `main`: DeepSeek V4 Pro and Kimi K3 each selected/saved through the actual Main Menu settings surface and each reaching a real accepted Opening;
2. run canonical Windows freshness validation: `.\run-game.ps1 -ValidateExportOnly`;
3. verify production Source/UAT prerequisites remain intact, including the Public d20 Expansion, without modifying Owner Games or manually copying managed Source files;
4. keep real integration tests on task-owned Game/Source/settings roots and never overwrite Owner production model preference merely for testing;
5. rerun the focused Settings UI / Runtime Settings / Public d20 regression floor and `git diff --check`;
6. update the Owner UAT B instructions under `docs/g4_09/` so the product route begins with Main Menu Model Settings before New Game.

Do not redesign model semantics, Provider wire, UI, Source, Composition, d20 or persistence.

## 6. Progression

```text
G4-09R1P1 — Codex
→ GPT Independent Review
→ if PASS: G4-09R1 PASS / CLOSED
→ refresh G4-09UATB instructions/state
→ G4-09UATB ACTIVE — OWNER
```

Do not close G4-09/G4-08 before Owner Product UAT verdict. Do not start G4-10 or G5.