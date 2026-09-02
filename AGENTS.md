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
G4-08 Expansion Pack v0.1             ACTIVE pending Owner verdict
G4-08M1 Public d20 Mechanism          PASS / CLOSED
G4-08B Public d20 UI Integration      PASS / CLOSED
G4-09 First Playable B                ACTIVE pending Owner verdict
G4-09P1 Owner UAT B Production Prep   PASS / CLOSED
G4-09R1 Runtime Model Settings v0.1   PASS / CLOSED
G4-09R1M1 Backend Mechanism           PASS / CLOSED
G4-09R1B1 Settings UI                 PASS / CLOSED AFTER CORRECTION-01
G4-09R1P1 Final Integration/Freshness PASS / CLOSED
G4-09UATB Owner Product UAT           ACTIVE — OWNER
G4-GATE                               NOT YET
```

No Codex or Kimi task is active. Do not start G4-10 while Owner UAT B is active.

## 3. Current execution task — G4-09UATB

Owner product-only instructions:

`docs/g4_09/G4-09UATB_Owner产品验收说明.md`

Accepted model-settings final review:

`docs/g4_09r1/G4-09R1P1_INDEPENDENT_REVIEW.md`

Current owner: **OWNER**. Reviewer / semantic owner: **GPT**.

Exact preferred route:

```text
run-game.cmd
-> Main Menu 模型设置
-> choose desired model / context / reasoning and Save
-> reopen once and confirm effective summary
-> New Game
-> World: 汉末三国：天下未定
-> Entry: 208｜赤壁前夕
-> Character: 刘备
-> Expansion: 判定与检定：公开 d20
-> real Opening
-> one genuinely risky action -> visible d20 card
-> one ordinary/no-risk action -> no unnecessary d20 card
-> Save -> Main Menu -> Continue
-> Owner product verdict
```

Owner UAT is not a Provider benchmark. The Owner may choose whichever accepted runtime configuration they want for the play session.

## 4. Accepted Runtime Model Settings v0.1 truth

Protected absent concrete regression:

- app-local settings `user://my-world/settings/provider-runtime.json`;
- exact four player-facing profiles: DeepSeek V4 Pro, DeepSeek V4 Flash, Kimi K3, Kimi K2.7;
- DeepSeek/K3 256K/1M compatibility; K2.7 256K-only;
- DeepSeek/K3 requested reasoning `low/medium/high/max`, with `medium -> effective high`;
- K2.7 fixed Thinking ON / no graded effective effort;
- selected-provider credentials only: `DEEPSEEK_API_KEY` / `KIMI_API_KEY`;
- no cross-provider fallback;
- one Provider seam across Opening, Narrative and both Public d20 phases;
- UI uses Runtime Settings L3 projection/default seams, not internal rules;
- Main Menu Save/Cancel/Escape/reopen/restart behavior accepted;
- real DeepSeek V4 Pro and real Kimi K3 UI-selected Opening completed on the final launch line;
- canonical Windows export freshness rebuilt/validated after model-settings UI acceptance;
- Source/Final Create/Public d20 semantics and SQLite schema v4 remain unchanged.

Formal final review:

`docs/g4_09r1/G4-09R1P1_INDEPENDENT_REVIEW.md`

## 5. Owner UAT disposition

Engineering evidence does not replace the Owner product verdict.

Owner returns:

```text
PASS
```

or:

```text
FAIL
<where it is not fun, natural, or correct>
```

If PASS, GPT closes G4-09UATB, G4-09 First Playable B and G4-08 Expansion Pack v0.1, propagates the decision, then inspects the canonical roadmap before shaping G4-10 Runtime Asset Resolution.

If FAIL, GPT records the exact product seam and routes a bounded correction according to ownership/correction-budget rules.

Do not start G5 before G4-GATE.