# G5-03M1 Multi-Actor Agency Cycle — Independent Review

Status: **CORRECTION REQUIRED**  
Reviewer: **GPT**  
Reviewed implementation: `3b5d104682f33f594cf72178a754ef044ff97469`  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`

## 1. Review verdict

The multi-actor architecture is accepted:

- selection reuses the existing semantic-analysis request rather than adding a mandatory selector call;
- one accepted world window may select several stable NPCs;
- actor execution is isolated one request per selected actor;
- selected actor requests can be active concurrently;
- sibling valid actions can commit as separate atomic world mutations;
- `hold` / malformed / Provider failure remain fail-soft;
- no round-robin single-NPC scheduler, SQLite schema, UI, Faction platform, G5-04 scheduler or hidden d20 was introduced.

However, **current-version / current-timeline isolation is incomplete**. This is blocking because Agency is intentionally asynchronous and Player foreground/timeline ownership is protected semantics.

## 2. Blocking finding A — late semantic result can start Agency after foreground already advanced

Application invalidates an Agency Cycle when `Conversation.attempt_started` fires, but that only protects a cycle that already exists.

Concrete race:

```text
Turn A Narrative accepted
→ Turn A semantic analysis still running
→ Player starts Turn B
→ no Agency Cycle exists yet, so attempt_started has nothing to invalidate
→ Turn A semantic analysis later finishes with agency_candidates
→ _on_world_turn_finished(...) starts a new Turn A Agency Cycle anyway
```

`_on_world_turn_finished(...)` currently does not require:

- Conversation idle;
- source turn still latest accepted ordinary turn;
- source GM hash still current;
- accepted Conversation count/version unchanged since the source result.

This violates **Foreground player freedom outranks background agency completion**.

## 3. Blocking finding B — Restore is not wired to invalidate active Agency

`session_runtime.restore_completed` is connected to `_on_restore_completed(...)`, but that handler currently only refreshes save controls.

The focused Restore test manually calls `cycle.invalidate_remaining()` after changing a fake head. Therefore it proves the process can be invalidated, but does **not** prove the production Restore lifecycle actually performs that invalidation.

A real Save Restore can occur while Agency requests are active because Agency is not Conversation generation. Remaining pre-Restore callbacks must be invalidated automatically.

## 4. Blocking finding C — no commit-time currentness / unrelated-head guard

`AgencyCycleRuntimeProcess._on_actor_completed(...)` commits immediately after parsing a valid actor result.

It does not verify before commit that:

- the source accepted GM hash is still current;
- accepted Conversation has not advanced;
- Conversation is not in a newer foreground generation;
- current `active_head_id` equals the cycle-owned expected head;
- a head change came from this cycle's own sibling commit rather than an unrelated world mutation.

The decision explicitly allows **sibling head progression** while requiring unrelated head change to invalidate remaining actors. That distinction is not currently enforced by production code.

## 5. Blocking finding D — actor-local Knowledge / Agency History can include stale superseded records

Both:

- semantic `_agency_selection_block()`; and
- Agency execution `_actor_request(actor_id)`

scan durable `knowledge_turns_by_index` and prior `agency_cycles_by_source_turn` by actor ID, but do not filter records against the **current accepted Conversation hashes**.

Concrete failure:

```text
Turn N old Narrative establishes secret F for NPC A
→ knowledge F materializes
→ player regenerate/corrects Turn N so F never happened
→ G5-02 ordinary GM Context correctly excludes stale F by GM-hash mismatch
→ Agency selector/executor still reads stale F directly from living_world
→ NPC A can act from erased timeline knowledge
```

This violates both:

- `Player owns the timeline`; and
- `GM omniscience must not become actor omniscience` / current durable Knowledge Provenance semantics.

Agency history needs the same current-hash filtering.

## 6. Blocking finding E — a new version can merge into a stale cycle at the same turn index

`Rules.build_agency_candidate(...)` currently reuses any existing `agency_cycles_by_source_turn[turn_index]` record when non-empty.

It does not require that the existing cycle matches the new cycle identity / source GM hash.

Concrete failure:

```text
Turn N old GM hash A → old Agency Cycle A exists
→ player replaces Turn N Narrative → current GM hash B
→ new Agency Cycle B produces a valid action
→ build_agency_candidate finds old turn-index record and merges the new action into Cycle A
→ stored cycle still carries old hash A
→ later GM Context rejects the whole cycle as stale
```

Current-branch replacement must use the new cycle when the stored turn-index cycle does not match. Historical old versions remain available through Timeline/Save snapshots rather than being merged into current truth.

## 7. Review gap — replay test does not prove no duplicate execution

The current H test proves only that a reconstructed cycle identity can match. It shuts the replay cycle down before a real controlled actor completion and does not prove that an already committed actor is skipped without another execution/commit.

This should be tightened while correcting the currentness seam, but no new generalized replay platform is required.

## 8. Accepted / protected implementation

Do **not** redesign these passing parts:

- multi-actor `0..4` selector contract;
- same semantic request selection;
- separate actor-scoped execution requests;
- concurrent Provider execution;
- serialized atomic durable commits;
- action/intent/effect bounds;
- fail-soft `hold` / malformed / Provider failure;
- later omniscient GM agency projection;
- no automatic knowledge grant from hidden agency action;
- no Faction/G5-04/UI/schema scope.

## 9. Provider evidence

The task-owned real validation remains:

```text
PENDING / EXTERNAL PROVIDER UNAVAILABLE
```

The bounded attempt timed out during ordinary Narrative before feature-specific agency proof. Do not spend another real Provider attempt in the correction.

## 10. Required next step

Execute:

`docs/tasks/G5-03M1C01_AGENCY_CURRENTNESS_TIMELINE_ISOLATION_CORRECTION_TASK.md`

Then return for GPT Independent Review.
