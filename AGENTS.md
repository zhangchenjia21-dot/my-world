# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions.
5. this `AGENTS.md` + current Task Packet / Independent Review evidence.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Repository remotes: `github.com/zhangchenjia21-dot/my-world` and `github.com/zhangchenjia21-dot/Vibe-Coding`.

Long-term routing:

```text
GPT        → meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. Correct in-flight Kimi work may finish after expiry.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ENGINEERING PASS / CLOSED
G5-03M1 Multi-Actor Agency v0.3             ENGINEERING PASS / CLOSED
G5-03M2 Stable Actor Registry               ENGINEERING PASS / CLOSED
G5-03M2A Registry Foundation                ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization PASS / CLOSED
G5-04 Event / Priority Evolution            ACTIVE
MW-002 Selective World Evolution Evaluator CORRECTION REQUIRED — REVISION 2 / KIMI
G5-GATE                                     NOT YET
```

Current canonical:

`Vibe-Coding/my world/architecture/world/G5_SELECTIVE_WORLD_EVOLUTION_V0_1_DECISION.md`

Current executable packet:

`docs/tasks/MW-002_SELECTIVE_WORLD_EVOLUTION_EVALUATOR_TASK.md`

Independent Review:

`docs/g5_04/MW-002_INDEPENDENT_REVIEW_IR1.md`

G5-03 closeout / Faction deferral remains protected:

`Vibe-Coding/my world/architecture/world/G5_03_AGENCY_CLOSEOUT_AND_FACTION_DEFERRAL_V1_0_DECISION.md`

Parent real G5-03 Provider proof remains `PENDING / EXTERNAL PROVIDER UNAVAILABLE`; do not switch Provider merely to manufacture evidence.

## 3. Task identity / lineage

Use:

`Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`

Keep separate:

```text
Roadmap / Capability Anchor
!= Executable Work Item ID
!= Revision / Review Lineage
```

Current identity:

```text
Work Item: MW-002
Name: Selective World Evolution Evaluator
Capability-Anchor: G5-04
Revision: 2
Review-Round: 1
Triggered-By: MW-002 IR#1
Correction Base: d42477c45d4699c91ec0e40124ced374101135b9
Owner: Kimi
Reviewer: GPT
```

Same Outcome correction stays on `MW-002`. Do not create MW-002C01/R02/PATCH-style IDs.

## 4. Protected G5-03 behavior

G5-03 is closed. Protect:

```text
ordinary accepted Player Narrative
→ mark Agency dirty
→ semantic terminal
→ standalone Selector
→ 0..4 current stable NPCs
→ actor-scoped execution
→ optional durable actor actions
```

Also protect:

- Player foreground always wins;
- selector start consumes one dirty opportunity;
- no same-opportunity automatic retry;
- actor-private material / Knowledge / history;
- Program-owned stable actor identity;
- runtime actor accepted-hash currentness;
- no automatic Knowledge from registry/materialization;
- no mutable Source lookup;
- semantic `agency_candidates` remains non-authoritative/dead.

MW-002 may add only observational whole-opportunity terminal handling; it may not redesign Agency scheduling.

Do not create a Faction actor/shared-Knowledge platform merely for G5-04. Aggregate faction-related processes may remain world events until a real later Faction consumer requires more.

## 5. Frozen G5-04 product rule

> **The world can move without the Player causing every change, without forcing an event every turn.**

```text
World Independence + Player Spotlight
Persistent != Fully Simulated
Evaluation opportunity != event obligation
```

`hold` is a correct first-class result.

Frozen order:

```text
visible ordinary Player Narrative accepted
→ semantic lane
→ existing Agency Selector / optional actor cycle
→ Agency opportunity truly terminal
→ one best-effort World Evolution evaluation
→ hold OR at most one causally-ready world event
→ optional durable mutation
→ next GM continuation may consume the current event
```

Player turn is scheduling opportunity, not event causation. Opening-only GM generation creates no opportunity. No offline/wall-clock progression.

## 6. Protected MW-002 Revision-1 behavior

Do not rewrite working architecture while correcting IR#1:

- dedicated evaluator after Agency terminal;
- hold with no fake mutation;
- one-event ceiling;
- Program deterministic event/mutation/node identity;
- bounded raw-string parser and fail-soft invalid/provider results;
- additive `living_world.v0.1`, no SQLite schema change;
- committed-event replay idempotence;
- current accepted-hash event filtering;
- first real consumer = next GM World Turn Context;
- event is omniscient GM world fact, not automatic Player/actor knowledge;
- no Actor Knowledge Provenance in evaluator input;
- no mutable Source Library current lookup;
- no pressure DB / numeric priority / fixed cadence / random-event engine;
- no Faction platform / UI / offline simulation / G5-05.

## 7. MW-002 IR#1 correction requirements

Revision 1 actual-code Independent Review found four bounded issues.

### F01 — Public-d20 foreground start

With Public d20 enabled, Player Send starts the adjudication `control` Provider request before `Conversation.begin_turn()`. Therefore `Conversation.attempt_started` alone is too late to invalidate old background work.

Revision 2 must use the earliest existing adjudication-start observability in Application composition (prefer existing `request_assembled`) to invalidate both Agency and World Evolution immediately. Do not redesign Public d20 mechanics/protocol/UI.

Required focused proof: active evolution → Public-d20 control starts → evolution invalidates → late callback cannot commit.

### F02 — Agency `already_committed` immediate terminal

`AgencyCycle.start_cycle()` can return `already_committed` with zero actors and no later `cycle_finished`. Scheduler must treat that as an immediate terminal, clean the runtime, emit exactly one frozen-turn/hash `opportunity_finished`, wake World Evolution once, and remain re-armed for a later dirty opportunity.

No dirty/cap/concurrency/retry change.

### F03 — true World-only baseline

Current `project_world_only()` reuses the general Game block and leaks protagonist control mode + arbitrary `opening_supplement` into evaluator causal input.

Revision 2 must project only frozen World/selected Entry/world instructions/GM instructions/World semantic sections plus a neutral Game-local authority header. It must exclude opening supplement, control mode, all Character material and Actor Knowledge.

Required test uses a nonempty private opening-supplement marker.

### F04 — production Restore-active proof

Add the missing focused path:

```text
active World Evolution
→ production Restore/progress switch
→ evaluator invalidated
→ late callback
→ restored head/world unchanged
→ no event commit
```

Also prove any synchronous Agency invalidation terminal during Restore cannot leave a surviving evolution request/commit.

## 8. Revision-2 edit / validation ceiling

Preferred production edits only:

- `src/应用壳.gd`;
- `src/世界回合/L2_流程层/行动代理调度流程.gd`;
- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`;
- `tests/g5_04/选择性世界演化评估测试.gd`;
- evidence/task docs.

Read-only unless existing seams prove insufficient:

- `src/ui/叙事对话视图.gd`;
- `src/行动判定/L2_流程层/公开D20行动判定流程.gd`;
- `src/世界回合/L2_流程层/行动代理循环流程.gd`.

Focused-first. After G5-04 focused green, run only:

- one G5-03 Scheduler/Cycle regression;
- one minimal G4-08/Public-d20 regression;
- one G4-07 continuation/context regression;
- one G3-04 Save/Restore regression;
- `git diff --check`;
- real Provider calls = 0.

Do not restore broad matrices.

## 9. Review / UAT route

Kimi commits/pushes Revision 2 and returns at most:

`READY FOR INDEPENDENT REVIEW`

GPT then performs **MW-002 IR#2** against correction base `d42477c45d4699c91ec0e40124ced374101135b9`.

Owner UAT remains blocked until Engineering PASS. G5-04 may close only after Owner Product PASS on both quiet/hold and genuine-ripe-pressure scenarios.