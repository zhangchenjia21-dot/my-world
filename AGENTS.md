# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions.
5. this `AGENTS.md` + current Task Packet.
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
MW-002 Selective World Evolution Evaluator ACTIVE — KIMI
G5-GATE                                     NOT YET
```

Current executable task:

`docs/tasks/MW-002_SELECTIVE_WORLD_EVOLUTION_EVALUATOR_TASK.md`

Canonical G5-04 decision:

`Vibe-Coding/my world/architecture/world/G5_SELECTIVE_WORLD_EVOLUTION_V0_1_DECISION.md`

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
Revision: 1
Review-Round: 0
Owner: Kimi
Reviewer: GPT
```

Do not create recursive suffix chains. A same-Outcome correction keeps `MW-002` and advances Revision / Review-Round.

## 4. Protected G5-03 behavior

G5-03 is closed. Do not reopen absent concrete regression/new consumer.

Protect:

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

MW-002 may add only one **observational** Agency-opportunity terminal signal so G5-04 can wake after the entire Agency opportunity settles. It must not alter Agency scheduling semantics.

Do not create a Faction actor/shared-Knowledge platform merely for G5-04. Aggregate faction-related processes may be represented as world events until a concrete Faction consumer proves stronger semantics are needed.

## 5. G5-04 product rule

G5-04 exists to prove:

> **The world can move without the Player causing every change, without forcing an event every turn.**

Core distinction:

```text
World Independence + Player Spotlight
Persistent != Fully Simulated
Evaluation opportunity != event obligation
```

`hold` is a correct first-class result.

Do not build a random-event machine, universal simulation engine, persistent pressure queue or numeric priority system.

## 6. Frozen MW-002 ordering

For one ordinary accepted Player turn:

```text
visible Narrative accepted
↓
existing semantic lane
↓
existing Agency Selector / optional actor cycle
↓
Agency opportunity truly terminal
↓
World Evolution Evaluator gets one best-effort opportunity
↓
hold
OR
advance at most one causally-ready world event
↓
optional single durable world mutation
↓
next GM continuation Context can consume current event
```

The Player turn is the scheduling opportunity, **not causal authority** for the event.

Opening-only GM generation creates no MW-002 opportunity. No offline/wall-clock progression is introduced.

## 7. World-event ownership

World Evolution is for concrete processes not necessarily owned by one stable NPC intentional decision, such as:

- environment/weather/natural process;
- aggregate conflict/front movement;
- institutional/economic/social process;
- deadline ripening;
- disaster/accident;
- chain reaction from prior consequences.

A stable NPC's intentional action remains G5-03 Agency territory.

One evaluation may advance at most one event. That is a v0.1 safety ceiling, not a semantic world limit.

## 8. Evaluator authority / context

Priority judgment stays model-owned. Program may validate only the bounded machine contract/currentness/integrity.

Do not implement keyword gates, scores, fixed cadence or Program event taxonomy.

Evaluator input is bounded GM-level world causality:

1. frozen Game-local T0 **World-only** projection from the opened Game;
2. latest accepted Player action + GM Narrative;
3. recent current-hash semantic world changes;
4. recent current-hash Agency actions/effects;
5. recent current-hash prior evolution events.

Do not include Actor Knowledge Provenance or Character-private Source material.

Do not read mutable Source Library current during gameplay. If frozen world-only material is unexpectedly too large, fail-soft rather than query mutable Source or silently create misleading partial authority.

## 9. Durable / currentness contract

Keep `living_world.v0.1`; no SQLite migration/table.

Durable event shape is equivalent to:

```text
world_evolution_id          Program-owned
opportunity_turn_index
opportunity_gm_sha256
evolution_base_head_id
materialized_at
event
effects[]
```

Program owns event/mutation/node IDs. Opportunity turn/hash is scheduling/currentness metadata, not Player-causation metadata.

Matching committed event replay must not duplicate/re-call Provider. `hold`/failure creates no fake durable record and does not auto-retry same runtime opportunity.

At evaluation start freeze opportunity turn/hash + accepted count + active head. Before commit all must still match and foreground must remain idle.

New foreground / Restore / shutdown / unrelated head change invalidates uncommitted work; late callbacks are inert.

Regenerate/correction leaves stale physical history but current GM Context filters it by accepted hash.

## 10. First real consumer / disclosure

MW-002 must extend the existing World Turn Context projection so the next production GM continuation can see current committed world-evolution events.

Context must explicitly state:

- event = omniscient GM world fact;
- not automatic Player knowledge;
- not automatic actor knowledge;
- GM decides when/how scene and information flow make it relevant.

Do not force a visible event announcement and do not auto-create Knowledge Provenance.

Do not inject evolution events into actor execution requests in MW-002.

## 11. Scope ceilings

Do not:

- gate or format-constrain visible Narrative;
- require an event every turn;
- build pressure DB / priority queue / Thread/Quest scheduler / event ontology;
- build generic Faction identity/Knowledge/agency;
- redesign G5-03 scheduling;
- add UI;
- add SQLite schema/table/migration;
- read mutable Source current;
- add offline simulation;
- change Public d20/mechanics;
- enter G5-05.

MW-001's non-blocking `actors_dropped` ceiling-count advisory remains opportunistic only; do not expand MW-002 to fix unrelated parser code unless it becomes directly touched for a concrete reason.

## 12. Validation / evidence

Focused-first:

- `tests/g5_04/` until green;
- then only directly affected G5-01 context/semantic, G5-02 Knowledge-boundary, G5-03 Scheduler/Cycle, G4-07 continuation-context and one G3-04 Save/Restore regression;
- `git diff --check`;
- real Provider calls = 0 for deterministic Engineering Acceptance.

Evidence path:

`docs/g5_04/MW-002_SELECTIVE_WORLD_EVOLUTION_EVIDENCE.md`

Kimi commits/pushes and returns at most:

`READY FOR INDEPENDENT REVIEW`

GPT then performs actual-code Independent Review.

Because G5-04 changes core world pacing/product feel, **Owner UAT is mandatory after Engineering PASS before G5-04 closure**. Engineering evidence does not prove the world feels active-but-not-event-spammy.
