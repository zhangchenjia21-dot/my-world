# TASK｜G5-03M1R01｜Agency Scheduler v0.3 Simplification Redesign

Type: **redesign-01 / same-seam correction-budget escalation**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-03M1 Multi-Actor Agency Cycle**  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW** or **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## 0. Important: do not roll back the previous implementation

Refresh both `main`s first.

**Do not reset/revert to pre-G5-03 commits.**

The v0.2/C01 work contains accepted downstream behavior that must be preserved. This task is a targeted redesign of the upstream scheduling/selection seam.

Current C02 packet is superseded and must not be executed:

`docs/tasks/G5-03M1C02_SEMANTIC_AGENCY_CURRENTNESS_SEPARATION_CORRECTION_TASK.md`

## 1. Preserve these existing production capabilities

Keep and reuse where possible:

- `AgencyCycleRuntimeProcess` multi-actor per-actor execution;
- one isolated Provider request per selected actor;
- concurrent selected actor requests, max 4;
- actor-private Source / current-hash-matching Knowledge / own agency history;
- serialized durable commits through `commit_world_mutation_durably(...)`;
- same-cycle sibling expected-head progression;
- foreground/Restore cancellation of uncommitted actor work;
- stale Knowledge/Agency History filtering;
- stale same-turn cycle replacement where still relevant;
- replay skip for already committed matching actor action;
- bounded `Independent Actor Actions` later GM Context projection;
- no automatic Player/other-actor knowledge grant.

Do not replace these with a new generic actor simulator.

## 2. Remove the v0.2 coupling

The G5-01/G5-02 semantic-analysis lane must stop selecting Agency actors.

Production semantic contract returns only:

```json
{
  "changes": [],
  "knowledge_events": []
}
```

Required changes:

1. remove Agency Selection instructions/material from the semantic-analysis prompt;
2. remove `agency_candidates` as a production semantic handoff to Application;
3. remove `world_turn_runtime.finished → candidates → start Agency Cycle` coupling;
4. restore semantic currentness to its own accepted source-version semantics: an older accepted turn may still materialize valid changes/knowledge if its GM hash remains current at that index;
5. foreground advancing must not erase otherwise-valid G5-01/G5-02 truth.

Parser compatibility may tolerate an unknown extra field if convenient, but Agency behavior must not depend on it.

## 3. Add a standalone Agency Scheduler / Selector

Implement the smallest stateful runtime process/interface that owns Agency scheduling. Naming may follow repository layering conventions.

Responsibilities:

```text
accepted ordinary player turn
→ mark Agency dirty
→ wait for a safe background opportunity
→ one standalone selector request over current latest world snapshot
→ validate 0..4 stable NPC IDs
→ start/reuse existing AgencyCycleRuntimeProcess
```

Do not create a SQLite table/schema.

### 3.1 Dirty/coalescing

A durable accepted ordinary player turn marks scheduler dirty.

If A/B/C turns occur before Agency can run, do not queue three historical selectors. Keep one dirty condition and later evaluate the **latest current world snapshot**.

No mandatory one-turn-one-cycle relation.

### 3.2 Safe selector start

Selector may start only when all are true:

- current Session ready;
- dirty=true;
- Conversation foreground idle;
- semantic worker has no active or queued analysis;
- no selector or Agency Cycle currently active.

Use the semantic worker's terminal signal only as a scheduling wake-up if useful. Do not consume candidates from that result.

If semantic analysis terminally fails/malformed/no-change, Agency may still run after the worker is idle.

### 3.3 Selector snapshot/input

Freeze at selector start:

- latest accepted ordinary `turn_index`;
- latest GM hash;
- current world head ID.

Build a bounded GM-level selector prompt containing enough current information to answer only:

> Which eligible stable actors plausibly deserve an independent action evaluation now?

May include bounded:

- latest accepted player action + GM narrative;
- current materialized world-change Context;
- stable Guaranteed-NPC roster with exact IDs and bounded Source summaries;
- useful current world/knowledge/agency state.

Selector is allowed GM-level visibility. It does not grant knowledge to actors.

Minimal output:

```json
{"actors":["stable-id-a","stable-id-b"]}
```

Validate IDs against current eligible Guaranteed NPCs; reject Player/unknown/empty; dedupe; cap 4. No round-robin fallback and no retry-until-nonempty.

## 4. Selector currentness

Before selector output may start an Agency Cycle, require:

- same latest accepted turn index/hash as frozen selector snapshot;
- same world head as frozen selector snapshot;
- foreground still idle;
- Session still current/ready.

If stale:

- discard output;
- no actor execution;
- no fake mutation;
- no automatic retry loop for the obsolete opportunity.

## 5. Foreground semantics

On new Conversation attempt:

- cancel/invalidate active selector;
- invalidate remaining uncommitted actor executions;
- preserve already committed sibling actions;
- clear the obsolete dirty opportunity.

When a later player turn is successfully durably accepted, mark dirty again.

If the foreground attempt fails/cancels, do not automatically resurrect the missed old Agency opportunity.

Player input must never wait for selector or actor execution.

## 6. Restore / recovery / close

On Restore/Recovery progress switch or Session close:

- cancel selector;
- invalidate remaining uncommitted actor executions;
- clear obsolete dirty state;
- late selector/actor callbacks cannot commit/start new work.

Do not auto-run Agency just because a Save was loaded.

## 7. Existing Agency Cycle adaptation

Reuse the current `AgencyCycleRuntimeProcess` rather than replacing it.

Adapt its anchor if needed so an actual cycle is bound to the **latest accepted turn/world snapshot at selector time**. Existing source turn/hash/head identities may continue to serve as this anchor.

Preserve:

- sibling expected-head progression;
- unrelated head-change invalidation;
- current source hash guard;
- actor-private execution;
- replay no-duplicate.

## 8. Required deterministic proofs

Add/reshape focused tests to prove at least:

### A. Semantic lane independent from Agency

Turn A accepted → semantic A active → player advances Turn B → A semantic completes with valid change/knowledge and unchanged A GM hash.

Expected:

- A change/knowledge may still materialize;
- no semantic field starts Agency;
- foreground unaffected.

### B. Standalone selector selects multiple actors

After latest semantic work settles and foreground idle:

- dirty scheduler starts exactly one selector request;
- controlled selector returns A+B+Player+unknown;
- only A+B validated;
- existing Agency Cycle starts separate concurrent A/B execution requests.

### C. Coalescing

A/B/C accepted before selector opportunity.

Expected:

- no three-selector catch-up queue;
- when background settles, one selector evaluates latest C snapshot;
- selector prompt/anchor corresponds to C.

### D. Selector stale on foreground

Selector active → player starts new foreground attempt → late selector completion.

Expected zero actor executions from stale selector.

### E. Selector stale on world-head/Restore

Selector active → unrelated head change or Restore → late completion.

Expected zero actor executions and no auto-retry.

### F. Multi-actor downstream preserved

A+B selected → separate concurrent actor requests → both valid acts may durably commit regardless completion order; hold/failure sibling remains fail-soft.

### G. Actor knowledge isolation preserved

A execution contains only A's current knowledge/history; B/Player private knowledge absent.

### H. Replay preserved

Already committed matching actor action does not produce a second execution request/mutation.

### I. No mandatory one-turn-one-cycle

At least one proof explicitly shows an accepted player turn can be superseded/coalesced without its own Agency Cycle and the latest world still receives a valid later Agency evaluation.

## 9. Regression floor

Run at minimum:

- rewritten/full G5-03 M1 focused suite;
- G5-02 knowledge suite;
- G5-01 semantic materialization + timeline suite;
- affected Conversation/Context tests;
- affected G3 Save/Restore tests;
- affected G4 continuation/application tests;
- Public d20 regression if Application orchestration path is touched;
- `git diff --check`.

## 10. Real Provider proof

After all deterministic/integration gates are green, standing authorization permits this **new redesign task** to use at most:

```text
1 real standalone selector request
+
up to 2 real selected actor execution requests
```

Maximum 3 feature-owned calls.

Important:

- stub/mock Narrative and semantic prerequisites;
- do not spend a real Narrative request merely to reach Agency;
- no retry loop;
- no fallback/hidden Provider switch;
- if selector/actor Provider is unavailable, commit/push reviewable work and mark real proof pending under the standing outage rule.

## 11. Scope ceiling

Do not implement:

- G5-03M2 actor registry/materialization;
- Faction agency;
- G5-04 event/priority scheduler;
- generic background timer/polling universe simulation;
- new persistence schema/table;
- UI surfaces;
- Source schema/generation changes;
- mechanics/d20 changes;
- G6/G7.

## 12. Evidence

Create:

`docs/g5_03/G5-03M1R01_AGENCY_SCHEDULER_V0_3_EVIDENCE.md`

Record:

- START_HEAD / implementation/final HEAD;
- exact reused vs replaced production components;
- proof semantic lane no longer carries Agency Selection;
- scheduler dirty/coalescing lifecycle;
- selector snapshot/currentness behavior;
- multi-actor concurrency/knowledge isolation/replay preservation;
- real Provider result or honest pending status;
- all regression results;
- final `git diff --check`.

## 13. Completion

Commit/push `origin/main` and return:

```text
READY FOR INDEPENDENT REVIEW
```

or if the bounded selector/actor reality proof is unavailable:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not start G5-03M2 until GPT Independent Review passes this redesign.
