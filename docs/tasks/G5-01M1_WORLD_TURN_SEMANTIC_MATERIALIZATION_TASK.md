# TASK｜G5-01M1｜World Turn / Semantic Materialization Spine

Type: **backend/runtime implementation + real integration proof**  
Owner: **CODEX**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-01 Minimum Playable T0 + World Turn / Semantic Materialization**  
Prerequisite: **G4-GATE PASS / G4 CLOSED**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Read first

Refresh both repository `main`s, then read the minimum authority set:

1. `AGENTS.md`;
2. `Vibe-Coding/my world/MY_WORLD_核心设计原则_CURRENT.md`;
3. `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`;
4. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`;
5. `Vibe-Coding/my world/architecture/world/G5_WORLD_TURN_SEMANTIC_MATERIALIZATION_V0_1_DECISION.md`;
6. current implementation seams around `Conversation`, current Game Session Runtime, current Context/Game-context projection, Provider adapter and world mutation persistence.

Do not read unrelated governance depth by default.

## 2. Outcome

Implement the first minimal living-world semantic vertical:

```text
accepted free-form player/GM Conversation turn
→ separate best-effort semantic analysis request
→ 0..N durable newly-established consequences
→ Program-owned World Turn record
→ existing atomic world mutation / Timeline
→ safe projection into later Context
```

Visible Narrative remains completely free-form and is accepted before this auxiliary lane matters.

## 3. Frozen semantic contract

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_WORLD_TURN_SEMANTIC_MATERIALIZATION_V0_1_DECISION.md`

Protect especially:

```text
Model authors the world
Runtime makes it durable
Player owns the timeline
```

and:

```text
Narrative acceptance
!= semantic-analysis success
```

G5-01M1 must not make semantic extraction a new gameplay gate.

## 4. Expected architecture / scope

Prefer a new bounded backend module, for example:

```text
src/世界回合/
  L0_公理层/
  L1_器件层/
  L2_流程层/
  L3_外交层/
```

Names may follow repository conventions; do not create framework layers without actual need.

Allowed focused integration seams:

- current Game Session Runtime;
- Application Shell/runtime composition needed to own/start a semantic worker;
- existing Opening/continuation Game-context projection seam if needed to expose committed materialized changes;
- existing Provider L3 adapter **by reuse only**;
- focused tests/runners/evidence.

Protected unless a concrete blocker is proven:

- `src/domain/会话.gd` semantics;
- `src/ui/**`;
- Persistence schema / migrations;
- Source package/schema/generation code;
- Runtime Model Settings;
- Public d20;
- Save/Restore semantics;
- G6 visual paths.

If production UI changes or a persistence schema migration appear necessary, STOP and return the blocker to GPT rather than expanding scope silently.

## 5. Trigger ordering

Production semantic analysis must begin only from a **durably accepted** ordinary player/GM turn.

A useful existing seam is `Conversation.generation_completed`, because production `Current Game Session Runtime` emits it only after durable Conversation persistence succeeds. Reuse current ordering rather than creating a second acceptance state.

GM-only Opening (`player_text == ""`) is excluded from G5-01 v0.1 materialization.

Do not start semantic analysis from provisional streaming text or failed/cancelled attempts.

## 6. Analysis lane

Use a separate non-visible Provider request through the currently selected runtime profile/shared adapter.

No cross-provider fallback and no hidden model switch.

The analysis request asks only for machine semantic data equivalent to:

```json
{"changes":["concise durable consequence"]}
```

It should distinguish newly established persistent consequences from atmosphere, hypothetical possibilities, unfulfilled player intent and prose style.

The response is machine-control/analysis material, not Narrative. It may be parsed as structured data, but parsing failure must fail-soft.

G5-01 v0.1 permits **one analysis attempt only** per newly accepted ordinary turn. No automatic recovery loop.

Do not persist raw Provider payload, prompts, reasoning or credentials.

## 7. Fail-soft semantics

For analysis transport/missing-key/malformed/invalid/empty-result/`changes=[]`:

```text
accepted Conversation remains accepted
no fake semantic World Turn is committed
no retry loop is started
no action becomes terminal failure
player may continue
```

Expose a stable non-secret status/result seam for tests/future observability, but do not add UI in M1.

Persistence failure while committing a valid semantic candidate:

- does not publish candidate world state in memory;
- does not roll back accepted Conversation;
- returns/records stable semantic-materialization failure status;
- does not create a fake committed record.

## 8. Durable record

On valid non-empty changes, clone current `world_state` and materialize an optional living-world namespace equivalent to:

```text
living_world
  schema_version = living_world.v0.1
  semantic_turns_by_index
    <turn_index>
      world_turn_id
      source_turn_index
      source_gm_sha256
      materialized_at
      changes[]
```

Use Program-owned stable `world_turn_id` + world mutation identity derived from Game identity + source turn index + accepted GM content identity/hash.

Same accepted content replay must not duplicate a record or advance a second semantically identical head.

Use the existing `commit_world_mutation_durably(...)` / Timeline/Persistence seam. Do not create a new SQLite owner/table for M1.

## 9. Regenerate / correction safety

The same Conversation turn index can later acquire different accepted GM text through regenerate/latest-turn correction.

A semantic record is eligible for Context projection only when:

```text
record.source_turn_index exists in current accepted Conversation
AND
record.source_gm_sha256 == sha256(current accepted gm_text at that turn)
```

Therefore a stale old semantic record must never enter a new request after accepted narrative replacement.

A successful materialization for the new accepted version replaces that turn-index record in the next world snapshot. Timeline/Save/Restore preserve historical snapshots naturally.

Do not invent an irreversible compensation/event system in M1.

## 10. Context projection

Add a compact derived section for committed matching World Turn changes to subsequent Game Context/request material.

Requirements:

- committed records only;
- source-hash match against current accepted Conversation;
- no raw analysis data/reasoning;
- bounded recent/relevant projection; do not dump unbounded semantic history;
- preserve T0/source quarantine;
- keep `Context bounded != Context starved`;
- no prose-output validator.

G7 owns long-session retrieval optimization.

## 11. Explicit non-scope

Do not implement:

- Knowledge Provenance / player-known logic (G5-02);
- NPC/Faction autonomous decisions (G5-03);
- Event/Priority background world evolution (G5-04);
- universal entity/fact graph;
- generic Location/Relationship/Inventory/Injury systems;
- Public d20 redesign;
- UI world panels;
- visual asset runtime;
- long-session vector/retrieval platform.

`changes[]` is a turn-level durable consequence ledger, not the permanent ontology of every future Domain.

## 12. Required tests / evidence

### A. Offline controlled vertical

Prove:

1. provisional/streaming text never materializes;
2. cancel/failure never materializes;
3. durable accepted ordinary turn triggers exactly one semantic request;
4. valid non-empty analysis commits exactly one World Turn mutation;
5. valid empty changes commits no mutation;
6. malformed/transport analysis leaves Conversation accepted and commits no mutation;
7. semantic persistence failure does not publish candidate memory state or roll back Conversation;
8. same accepted-content replay is idempotent/no duplicate;
9. GM-only Opening is skipped;
10. existing G4 Game without `living_world` remains valid and can gain the field on first successful mutation.

### B. Regenerate/correction/Timeline

Prove:

- old semantic record with mismatched GM hash is excluded from Context after accepted replacement;
- successful rematerialization replaces the same turn-index record;
- Save/Restore returns Conversation + matching semantic snapshot coherently;
- no stale future semantic memory leaks after Restore.

### C. Context

Prove a subsequent assembled Provider request contains committed matching materialized change(s), while malformed/uncommitted/stale records do not.

### D. Existing regressions

Run directly affected Conversation / Context / Opening / Save-Restore / world-mutation regressions and any affected G4 gameplay test.

Do not alter G4 accepted semantics merely to make new tests easier.

### E. Real selected-Provider proof

Use task-owned Source/Game roots and `Expansion = none`.

At least one real current-selected-Provider ordinary action must:

```text
free-form Narrative accepted durable
→ semantic analysis request
→ >=1 change parsed
→ atomic World Turn commit
→ close/reopen
→ later request includes committed matching change
```

Choose one natural action likely to establish a persistent consequence. If the first real turn legitimately yields no durable changes, at most one additional natural turn may be used; do not loop until the model satisfies a benchmark.

If repository/tool policy requires explicit authorization before the real call and authorization is not already available, return the exact blocker after all offline gates are green; do not fake real-provider evidence.

Owner production Source/Games/settings/credentials must remain unchanged. Use task-owned mutable roots and safe before/after fingerprints.

## 13. Hygiene / safety

- no full hidden prompt/payload/reasoning/credentials committed;
- no Owner AppData or task-owned SQLite committed;
- no Source mutation;
- no cross-provider fallback;
- no per-token world writes;
- `git diff --check` final result explicitly recorded;
- Windows/build freshness only if changed runtime packaging paths require it; do not create a build task by default.

## 14. Evidence document

Create:

`docs/g5_01/G5-01M1_WORLD_TURN_SEMANTIC_MATERIALIZATION_EVIDENCE.md`

Record:

- START_HEAD / IMPLEMENTATION_HEAD / EVIDENCE_HEAD;
- changed paths;
- architecture summary;
- offline test results;
- real-provider safe summary when authorized;
- idempotency/correction/restore proof;
- Owner safety proof;
- final `git diff --check` result;
- explicit statement that Narrative acceptance is not gated by semantic analysis.

## 15. Completion boundary

Return only:

```text
READY FOR INDEPENDENT REVIEW
```

Do not declare G5-01 PASS, G5 Product PASS, G5-02 active or G5-GATE PASS. GPT owns review/transition; Owner owns the later product checkpoint.
