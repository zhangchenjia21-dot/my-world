# TASK｜MW-002｜Selective World Evolution Evaluator

Type: implementation  
Owner: Kimi  
Reviewer: GPT  
Capability-Anchor: **G5-04**  
Revision: **1**  
Review-Round: **0**  
Depends-On: **G5-03 Agency — ENGINEERING PASS / CLOSED**  
Formal Code Base: `zhangchenjia21-dot/my-world` / `0020b92ed506d0441e73b3d8c6482486f8ce6544`  
Status: **ACTIVE — KIMI**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Implement the first selective world-evolution vertical so the current Game may durably advance **one causally-ready non-Player world event** after an ordinary turn's semantic + Agency opportunity reaches terminal, while `hold` remains a fully valid result.

The product vertical to prove is:

```text
ordinary accepted Narrative
→ existing semantic materialization
→ existing Agency opportunity terminal
→ one best-effort World Evolution evaluation
→ hold OR one durable world event
→ next ordinary GM continuation Context can see the current event
→ GM remains free to decide when/how it enters the Player-facing scene
```

This task must not become an every-turn random-event generator or a universal simulation platform.

## 2. Primary Purpose / Core Value

G5-04 serves a core product promise:

> **The world can move without the Player causing every change, but the Player is not constantly pushed around by forced events.**

Engineering acceptance must therefore prove both sides:

- world independence: a real pressure/process can advance outside direct Player causation;
- pacing elasticity: the evaluator can honestly `hold` and create no mutation when nothing deserves progression.

Owner UAT will be required after GPT Independent Review. Kimi must not self-certify Product PASS.

## 3. Why now

G5-01 already owns durable Narrative-established consequences.  
G5-02 owns actor Knowledge Provenance.  
G5-03 already owns intentional actions by stable NPCs and is closed.

The missing consumer is a world process with no single stable NPC owner: weather/environment, aggregate conflict/front movement, institutional/economic/social change, ripening deadlines, disasters or chain reactions.

Do not reopen Faction agency merely because some aggregate event involves a faction.

## 4. Authority / Source Manifest

Refresh both `main`s before implementation, then use this authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/my world/architecture/world/G5_SELECTIVE_WORLD_EVOLUTION_V0_1_DECISION.md` — **FROZEN / CURRENT CANONICAL**.
3. `Vibe-Coding/my world/architecture/world/G5_03_AGENCY_CLOSEOUT_AND_FACTION_DEFERRAL_V1_0_DECISION.md` — closed Agency/Faction boundary.
4. `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md` — protected Agency ordering/scheduling.
5. current `my-world` production code/tests at refreshed `main`.
6. `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

Historical `the-world` documents are rationale only, not implementation authority.

## 5. Read First

Read this initial set only:

1. `AGENTS.md`;
2. current G5-04 canonical decision above;
3. `src/应用壳.gd` around WorldTurn / Agency lifecycle wiring;
4. `src/世界回合/L2_流程层/行动代理调度流程.gd`;
5. `src/世界回合/L0_公理层/世界回合规则.gd`;
6. `src/世界回合/L1_器件层/世界回合上下文投影器.gd`;
7. `src/首次开场/L2_流程层/首次开场运行流程.gd` and the Game-local World setup projector only where needed to build the frozen world-only evaluator input.

Expand the read set only when concrete code evidence requires it; state why in evidence.

Do not reread historical M1 correction genealogy unless an actual regression requires it.

## 6. Decision Digest / Invariants

### INV-01 — Opportunity is not causation

An ordinary accepted Player turn provides a **safe evaluation opportunity**. It does not mean the Player caused the event.

Opening-only GM generation produces no MW-002 opportunity.

No offline / wall-clock evolution is introduced.

### INV-02 — Exact ordering

Preserve:

```text
accepted Narrative
→ semantic lane terminal
→ existing Agency Selector / optional actor cycle
→ Agency opportunity terminal
→ World Evolution evaluation
```

Do not run evolution before Agency. Same-opportunity actor actions may be relevant causal input to evolution.

### INV-03 — `hold` is first-class

The evaluator may return `hold` whenever no causally-ready development merits progression.

`hold`:

- creates no world mutation;
- creates no fake event marker;
- does not retry automatically in the same runtime opportunity;
- is not a failure.

Do not implement fixed cadence, numeric priority or pressure queues.

### INV-04 — One event safety ceiling

One evaluation may advance at most one world event.

This is a v0.1 fan-out bound, not a claim that the world has only one process.

### INV-05 — World event vs Actor Agency

Use World Evolution for changes that need not belong to one stable NPC's intentional decision: environment, aggregate conflict, institutions/economy/social process, deadline ripening, disaster, chain reaction, etc.

Do not move intentional stable-NPC choices out of G5-03 Agency.

Do not create stable Faction actor identity / Faction shared Knowledge / Faction action history in MW-002.

### INV-06 — Dedicated evaluator request

Use one dedicated lightweight Provider request after Agency terminal.

Conceptual response:

```json
{
  "decision": "hold | advance",
  "event": "concise summary",
  "effects": ["concrete durable effect"]
}
```

Validation contract:

- exact `hold|advance` decision;
- raw strings only, no coercion;
- `event` max 512 chars;
- `advance` requires non-empty event + 1..4 effects;
- each effect max 512 chars;
- malformed/invalid/provider failure = fail-soft no event;
- ignore unknown extra fields;
- model never supplies authoritative event ID / mutation ID / priority / event taxonomy / Source provenance.

This request must never gate Narrative acceptance or Agency completion.

### INV-07 — Model owns open priority semantics

Prompt the model to decide whether any already-supported world process is causally ready and worth advancing now.

Explicitly instruct:

- not a random-event generator;
- do not make an event just because evaluation was requested;
- preserve Life Loop / downtime;
- do not duplicate durable facts already established;
- choose one meaningful process or hold.

Do not implement Program keyword gates, score thresholds, urgency numbers or `every N turns` logic.

### INV-08 — Program-owned durable identity

Keep `living_world.v0.1` and use an additive collection equivalent to:

```text
living_world.world_evolution_events_by_turn
```

Record:

```text
world_evolution_id
opportunity_turn_index
opportunity_gm_sha256
evolution_base_head_id
materialized_at
event
effects[]
```

Program derives stable `world_evolution_id`, mutation ID and node ID from Game + exact opportunity turn/hash + base head. No wall-clock/random authority in identity.

`opportunity_*` is scheduling/currentness metadata, not Player-causation metadata.

No SQLite migration/table/schema.

### INV-09 — Replay / currentness

If a matching current event is already committed for the same accepted opportunity, a fresh worker/reopen-like re-entry must not issue another evaluator request or append a duplicate event.

Inside one runtime, hold/failure/terminal attempts must not auto-retry the same opportunity.

Do not retroactively evaluate arbitrary historical accepted turns after reopen.

Context currentness requires exact accepted `opportunity_turn_index + opportunity_gm_sha256` match. Regenerate/correction leaves stale physical Timeline history inert rather than deleting history.

### INV-10 — Foreground wins

At evaluator start freeze:

```text
opportunity turn/hash
accepted Conversation count
evolution_base_head_id = current active head
```

Before commit all must still match and foreground must be idle.

New Player attempt, Restore/progress switch, shutdown or unrelated world-head advance invalidates uncommitted evolution work. Late callbacks cannot commit.

Already committed event remains normal durable Timeline truth.

### INV-11 — Minimal G5-03 observability only

Add a single outward Scheduler signal equivalent to:

```text
opportunity_finished(result)
```

It fires exactly once after a dirty opportunity that actually started reaches terminal, including no actors / selector terminal / actor cycle terminal / equivalent already-committed terminal.

Carry frozen opportunity turn index + GM hash.

This is **observability only**. Do not change:

- dirty ownership/consumption;
- semantic-terminal wake;
- selector behavior/cap;
- actor concurrency;
- actor-private material / Knowledge / history;
- foreground invalidation;
- same-opportunity retry policy.

Application may wake MW-002 from this signal.

### INV-12 — Evaluator input is world-level, not actor cognition

Build a bounded evaluator request from:

1. frozen **Game-local T0 World projection only** from the opened Game (World/selected Entry/world instructions/GM instructions/World semantic sections);
2. latest accepted Player action + GM Narrative;
3. recent current-hash semantic world changes;
4. recent current-hash Agency actions/effects;
5. recent current-hash prior World Evolution events.

Do **not** include Actor Knowledge Provenance.

Do not include Player/Character private Source material just because it is present in Game setup.

Do not call mutable Source Library current.

Do not build G7 retrieval/summarization. If the frozen world-only baseline exceeds an explicit safe bound, fail-soft to no evaluation/hold rather than query mutable Source or silently make a misleading partial authority view.

### INV-13 — Next GM Narrative is the first real consumer

Extend the existing World Turn Context projection with bounded current:

```text
## World Evolution Events
```

Recommended latest 4 under the existing overall context budget.

Context guidance must say events are:

- current omniscient GM world facts;
- not automatically Player knowledge;
- not automatically actor knowledge;
- available for the GM to surface when scene / information flow / pacing makes sense.

Do not inject an automatic visible event announcement.

Do not automatically create G5-02 Knowledge.

Do not add evolution events to actor execution requests in MW-002.

## 7. Allowed production seams

Expected scope is limited to the smallest implementation necessary around:

- new G5-04 World Evolution parser/rules/runtime process + L3 interface under the existing `世界回合` area (or another clearly owned minimal world-runtime seam if current layering requires it);
- `src/世界回合/L2_流程层/行动代理调度流程.gd` only for terminal observability signal;
- `src/应用壳.gd` only for lifecycle/wake/invalidation composition;
- `src/世界回合/L0_公理层/世界回合规则.gd` for record/identity/currentness helpers if appropriate;
- `src/世界回合/L1_器件层/世界回合上下文投影器.gd` for the real GM consumer;
- a minimal frozen World-only Game-local projector/helper reusing durable setup, without Source lookup;
- `tests/g5_04/` focused tests and compact evidence.

If implementation requires a new SQLite schema, generic Faction platform, UI, Public d20 changes or Agency scheduling redesign, stop and report instead of improvising.

## 8. Prohibited scope

Do not:

- change visible Narrative format/acceptance;
- require world event every turn;
- build `pressure DB`, `priority queue`, Quest/Thread scheduler, event taxonomy or random-event table;
- create Faction actor/Knowledge platform;
- reactivate semantic `agency_candidates`;
- change G5-03 dirty/foreground/0..4/concurrency semantics;
- add UI;
- add SQLite schema/table/migration;
- read mutable Source current;
- add offline/wall-clock simulation;
- alter Public d20/mechanics;
- enter G5-05.

## 9. Required deterministic focused proofs

Create `tests/g5_04/` focused tests proving at minimum:

1. **Hold** — one evaluator request, `hold`, zero event/mutation.
2. **Advance** — valid result creates exactly one Program-owned durable event mutation with bounded event/effects.
3. **Failure isolation** — malformed/invalid/provider failure produces no event and does not alter accepted Narrative / prior Agency truth.
4. **Opening exclusion** — Opening-only generation never creates an evolution opportunity.
5. **Production ordering** — semantic terminal → Agency opportunity terminal → World Evolution; never evolution-before-Agency.
6. **Input composition** — frozen Game-local World T0 + current semantic consequences + same-opportunity Agency action/effects + prior current evolution events appear as appropriate.
7. **No private cognition / Source lookup** — Actor Knowledge Provenance and Character-private Source are absent; no mutable Source Library access.
8. **Program identity** — exact opportunity turn/hash + base head participate in deterministic identity.
9. **Replay** — matching committed event prevents second evaluator request and duplicate event, including fresh-worker/reopen-like re-entry.
10. **Regenerate currentness** — old physical event remains historical but is excluded from current GM Context on hash mismatch.
11. **Foreground/Restore safety** — new foreground or Restore invalidates active evaluation; late completion cannot commit.
12. **Save/reopen/Restore** — exact event survives when the save contains it; restoring an earlier snapshot removes it from current truth normally.
13. **Real GM consumer** — production `assemble_continuation_messages()` includes current event/effects with explicit GM-only / no-auto-knowledge guidance.
14. **G5-03 protection** — terminal observability works without changing dirty/foreground/selector cap/concurrency semantics.
15. **One-event ceiling / no platform** — one opportunity cannot commit multiple evolution records and implementation contains no numeric priority/pressure queue mechanism.

Use deterministic Provider stubs. Real Provider calls = 0 for Engineering Acceptance.

## 10. Validation budget

During development: run only `tests/g5_04/` until green.

After focused green, run one minimal affected regression pass:

- directly affected G5-01 semantic/context projection tests;
- G5-02 Knowledge boundary/context test;
- one directly relevant G5-03 Scheduler/Cycle dirty/wake/foreground suite;
- G4-07 continuation / FirstOpening context path (the real GM consumer);
- one G3-04 Save/Restore suite;
- `git diff --check`.

Do not run unrelated full-project/UI/Public-d20/G4 creation matrices absent a concrete regression reason.

## 11. Evidence

Write:

`docs/g5_04/MW-002_SELECTIVE_WORLD_EVOLUTION_EVIDENCE.md`

Include:

- Work Item / Capability Anchor / Revision;
- refreshed START_HEAD and implementation FINAL_HEAD;
- changed files;
- invariant → code mapping;
- focused results;
- minimal affected regressions;
- actual ordering proof;
- explicit no mutable Source lookup / no Actor Knowledge input;
- real Provider calls = 0;
- `git diff --check`;
- confirmation no Faction platform / pressure DB / SQLite migration / UI / G5-05 scope.

Before push, refresh `main` again; if authority/task/target production files moved, stop and re-audit rather than overwrite.

## 12. Stop / Return

Commit and push implementation + evidence, then return at most:

`READY FOR INDEPENDENT REVIEW`

Do not self-certify Engineering PASS or Product PASS.

After GPT Independent Review PASS, this capability requires **Owner UAT** before G5-04 may close.
