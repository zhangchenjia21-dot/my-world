# TASK｜MW-002｜Selective World Evolution Evaluator

Type: implementation correction  
Owner: Kimi  
Reviewer: GPT  
Capability-Anchor: **G5-04**  
Revision: **2**  
Review-Round: **1**  
Triggered-By: **MW-002 Independent Review IR#1**  
Correction Base: `d42477c45d4699c91ec0e40124ced374101135b9`  
Depends-On: **G5-03 Agency — ENGINEERING PASS / CLOSED**  
Status: **ACTIVE — KIMI / CORRECTION REQUIRED**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Correct the four bounded Revision-1 review findings without reopening the frozen G5-04 architecture.

The protected product vertical remains:

```text
ordinary accepted Narrative
→ semantic materialization
→ Agency opportunity truly terminal
→ one best-effort World Evolution evaluation
→ hold OR at most one durable world event
→ next GM continuation may consume the current event
```

`hold` remains first-class. Player foreground always wins. World Evolution remains world-level causal material, not actor cognition and not a random-event platform.

## 2. Authority / Read First

Refresh both `main`s before changing code, then read only:

1. `AGENTS.md`;
2. `Vibe-Coding/my world/architecture/world/G5_SELECTIVE_WORLD_EVOLUTION_V0_1_DECISION.md`;
3. `docs/g5_04/MW-002_INDEPENDENT_REVIEW_IR1.md`;
4. `src/应用壳.gd` around WorldTurn/Agency/ActionAdjudication lifecycle wiring;
5. `src/世界回合/L2_流程层/行动代理调度流程.gd`;
6. `src/世界回合/L2_流程层/行动代理循环流程.gd` only to verify the existing `already_committed` return contract;
7. `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`;
8. `src/ui/叙事对话视图.gd` and `src/行动判定/L2_流程层/公开D20行动判定流程.gd` only to verify the existing foreground-start observability seam;
9. `tests/g5_04/选择性世界演化评估测试.gd`.

Do not reread old correction genealogy or broaden scope unless concrete evidence requires it.

## 3. Inherited protected semantics

Revision 1 behavior below is protected and must remain intact:

- dedicated evaluator only after Agency opportunity terminal;
- `hold` → no event/mutation/auto-retry;
- at most one event per opportunity;
- Program-owned deterministic evolution/mutation/node IDs;
- additive `living_world.v0.1`, no SQLite schema/table/migration;
- bounded raw-string parser, malformed/provider failure fail-soft;
- no numeric priority, pressure queue, fixed cadence, event taxonomy or random-event engine;
- no generic Faction actor/shared-Knowledge platform;
- no mutable Source Library current lookup;
- no Actor Knowledge Provenance in evaluator input;
- current event projection filtered by exact accepted turn/hash;
- event is GM world truth, not automatic Player/actor knowledge;
- no UI / offline simulation / Public-d20 mechanics redesign / G5-05.

## 4. Exact Revision-2 corrections

### C1 / F01 — Public-d20 foreground must invalidate background work at action start

Problem: in a d20-enabled Game, Player Send enters `action_adjudication.start_action()` and starts the `control` Provider request before `Conversation.begin_turn()`. Therefore `Conversation.attempt_started` is too late to protect Player foreground authority.

Required behavior:

```text
active Agency / World Evolution background work
→ Player starts Public-d20 action/control request
→ background work invalidated immediately
→ late background callback cannot commit
```

Preferred solution: in Application composition, reuse the existing `action_adjudication.request_assembled(stage, messages)` or equivalent already-existing start observability. Route it to the same common foreground invalidation used by Conversation attempts:

- `agency_scheduler.invalidate_remaining()`;
- `world_evolution_evaluator.invalidate()`.

Do **not** redesign Public-d20 protocol, mechanics, dice, narrative acceptance or UI. Prefer no edit to the d20 runtime/View if the existing signal is sufficient.

Focused proof must use real production wiring: start an active evolution request, begin a Public-d20 action/control stage, verify evolution invalidates before control completes, then deliver a late evolution completion and prove no world commit.

### C2 / F02 — Handle Agency `already_committed` as an immediate terminal

Problem: `AgencyCycle.start_cycle()` may return `status=already_committed`, `actor_count=0` when all selected actor actions already exist durably. No actor request starts and no `cycle_finished` signal follows; current Scheduler leaves `agency_cycle_runtime` attached and never emits `opportunity_finished`.

Required behavior:

- detect the immediate terminal return;
- detach/free the cycle runtime safely;
- emit exactly one `opportunity_finished` carrying the frozen opportunity turn/hash;
- send no duplicate actor request;
- World Evolution wakes exactly once;
- Scheduler remains able to handle a later new dirty opportunity.

Do not change dirty consumption, semantic-terminal wake ownership, selector behavior, 0..4 cap, actor concurrency, actor-private inputs or retry semantics.

### C3 / F03 — Make `project_world_only()` actually World-only

Problem: current helper calls general `_append_game()`, which injects protagonist control mode and arbitrary `opening_supplement` into the evaluator baseline.

Required baseline contains only the frozen Game-local World/T0 authority needed by canonical:

- World identity/provenance/material;
- exact selected Entry if any;
- world instructions / GM instructions;
- World semantic sections;
- only minimal neutral header needed to state this is frozen Game-local truth.

Must exclude:

- `opening_supplement`;
- protagonist control mode;
- Player/Character material;
- Character-private Source;
- Actor Knowledge Provenance.

Do not query mutable Source current and do not silently truncate oversized World authority.

Focused proof: place `PRIVATE_OPENING_SUPPLEMENT_MARKER` in opening supplement and prove evaluator request excludes it while World/Entry markers remain.

### C4 / F04 — Add the missing active-evaluation production Restore proof

Required test path:

```text
production Game/Shell with a Save
→ World Evolution request active
→ production Restore/progress switch
→ evaluator invalidated
→ late evaluator callback
→ restored head/world remain authoritative
→ no evolution event commits
```

Also verify any synchronous Agency invalidation terminal caused by Restore cannot leave a surviving evolution request or later commit.

No architecture change is required unless this test exposes one.

## 5. Allowed production edit surfaces

Preferred:

- `src/应用壳.gd`;
- `src/世界回合/L2_流程层/行动代理调度流程.gd`;
- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`;
- `tests/g5_04/选择性世界演化评估测试.gd`;
- this packet / evidence.

Read-only unless genuinely required:

- `src/ui/叙事对话视图.gd`;
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`;
- `src/世界回合/L2_流程层/行动代理循环流程.gd`.

If existing signals are insufficient and an extra production seam is necessary, keep it minimal and document why. Do not improvise a new platform or protocol.

## 6. Focused acceptance for Revision 2

Before returning, prove at least:

1. Public-d20 control start invalidates active Agency + World Evolution immediately; late evolution cannot commit.
2. Existing ordinary Conversation-attempt invalidation still works.
3. `already_committed` Agency cycle becomes one clean immediate terminal: no actor call, runtime cleanup, exactly one terminal signal, one evolution wake, later dirty opportunity still works.
4. World-only baseline excludes nonempty opening supplement and control mode while retaining exact World/Entry material.
5. Active evaluation + production Restore invalidates and late callback cannot modify restored truth.
6. Existing hold/advance/parser/idempotence/current-hash/context-consumer protections remain green.

Development: run only `tests/g5_04/` until green.

After focused green, run one minimal affected pass:

- one G5-03 Scheduler/Cycle regression;
- one G4-08/Public-d20 regression (now required by C1);
- one G4-07 continuation/context regression because World-only projector is touched;
- one G3-04 Save/Restore regression;
- `git diff --check`;
- real Provider calls = 0.

Do not restore a broad project matrix.

## 7. Evidence

Update the same evidence path:

`docs/g5_04/MW-002_SELECTIVE_WORLD_EVOLUTION_EVIDENCE.md`

Record:

- Revision 2 / Review-Round 1;
- correction base `d42477c45d4699c91ec0e40124ced374101135b9`;
- exact implementation/evidence commits;
- F01–F04 correction mapping;
- focused results and minimal affected regressions;
- no architecture/scope expansion;
- real Provider calls = 0;
- `git diff --check`.

## 8. Stop / Return

Commit + push. Return at most:

`READY FOR INDEPENDENT REVIEW`

Do not claim Engineering PASS or Product PASS. Owner UAT remains blocked until GPT IR#2 PASS.