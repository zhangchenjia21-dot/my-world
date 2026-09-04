# TASK｜MW-002｜Selective World Evolution Evaluator

Type: implementation  
Owner: Kimi  
Reviewer: GPT  
Capability-Anchor: **G5-04**  
Revision: **2**  
Review-Round: **IR#2**  
Triggered-By: **MW-002 Independent Review IR#1**  
Correction Base: `d42477c45d4699c91ec0e40124ced374101135b9`  
Depends-On: **G5-03 Agency — ENGINEERING PASS / CLOSED**  
Status: **ENGINEERING PASS / CLOSED**

## 1. Outcome

MW-002 implements the first selective World Evolution vertical:

```text
ordinary accepted Narrative
→ semantic materialization
→ Agency opportunity truly terminal
→ one best-effort World Evolution evaluation
→ hold OR at most one durable world event
→ next GM continuation may consume the current event
```

Primary product rule remains:

> **The world can move without the Player causing every change, without forcing an event every turn.**

`hold` is first-class. Player foreground always wins. The Player turn is a safe scheduling opportunity, not causal authority for the event.

## 2. Final engineering lineage

```text
Work Item: MW-002
Capability-Anchor: G5-04
Revision: 2
Review-Round: IR#2
Revision-2 Implementation: 5459c4f8a1d92928129c1d3217a40c6622522496
Revision-2 Evidence: 001106f2c790e70935ea4e54eb721b4aef9e07b4
IR#2: docs/g5_04/MW-002_INDEPENDENT_REVIEW_IR2.md
Verdict: ENGINEERING PASS / CLOSED
```

Revision 1 was reviewed in `MW-002_INDEPENDENT_REVIEW_IR1.md` and returned CORRECTION REQUIRED. Revision 2 closed all four findings without changing Work Item identity.

## 3. Final protected semantics

Protect all of the following unless a later concrete consumer/regression requires change:

- World Evolution evaluates only after an ordinary accepted turn's semantic lane and entire Agency opportunity are terminal;
- Opening-only GM generation creates no evolution opportunity;
- one evaluation may `hold` or advance at most one event;
- `hold` creates no fake event/mutation and does not auto-retry the same runtime opportunity;
- priority judgment remains model-owned; no numeric priority, keyword gate, persistent pressure queue, fixed cadence or random-event engine;
- intentional stable-NPC choices stay in G5-03 Agency;
- aggregate/environment/institution/deadline/disaster/chain-reaction developments may be World Evolution events;
- Program owns world-event / mutation / node identity;
- identity binds exact Game + opportunity turn/hash + evaluated base head;
- durable storage remains additive under `living_world.v0.1`; no SQLite migration/table;
- matching committed event replay is idempotent;
- current consumers require exact accepted turn/hash match;
- new foreground, Public-d20 control start, Restore/progress switch, shutdown or unrelated head change invalidates uncommitted evolution work;
- late callbacks cannot commit obsolete work;
- evaluator causal input uses frozen Game-local **World-only** T0 material + bounded current world consequences;
- opening supplement, protagonist control mode, Character-private Source and Actor Knowledge Provenance are excluded from evaluator causal input;
- mutable Source Library current is never queried during gameplay;
- first real consumer is the next GM continuation Context;
- committed event truth is omniscient GM world truth, not automatic Player or actor knowledge;
- no automatic G5-02 Knowledge creation;
- no automatic visible event announcement;
- no Faction identity/shared-Knowledge/agency platform, universal simulator, event ontology, UI or offline simulation was added.

## 4. Final Agency terminal seam

`opportunity_finished(result)` remains an observability-only seam for the whole Agency opportunity.

It must cover:

- no actors;
- selector terminal/failure/stale/cancel;
- actor cycle terminal;
- equivalent immediate terminal such as all selected actions already durable (`already_committed`).

It carries the frozen opportunity turn/hash and must not change dirty consumption, selector 0..4 behavior, actor concurrency, actor-private input or retry semantics.

## 5. Final validation evidence

Committed Revision-2 evidence reports:

- G5-04 focused: **144 PASS / 0 FAIL**;
- G5-03 Scheduler/Cycle regression: **0 FAIL**;
- G4-08M1 Public-d20 regression: **0 FAIL**;
- G4-07A continuation/context regression: **0 FAIL**;
- G3-04 Save/Restore regression: **PASS**;
- `git diff --check`: clean;
- real Provider calls: **0**.

GPT IR#2 independently inspected the actual correction diff, production seams, test source and evidence. Reviewer environment had no Godot executable and the final commit had no external CI statuses, so GPT did not independently rerun Godot.

## 6. Product acceptance remains open

Engineering completion does **not** close G5-04.

Current route:

```text
MW-002 ENGINEERING PASS / CLOSED
→ Owner G5-04 UAT
→ only Owner Product PASS may close G5-04
→ then G5-05
```

Owner UAT must include both:

1. **Quiet / Life Loop** — no causally ripe process; evaluator can hold without artificial escalation.
2. **Genuine ripe pressure** — a real T0/current world pressure advances credibly without direct Player causation and later enters GM Narrative naturally.

Do not start G5-05 before the Owner verdict.