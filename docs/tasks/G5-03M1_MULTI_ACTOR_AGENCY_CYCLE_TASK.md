# TASK｜G5-03M1｜Multi-Actor Agency Cycle

Type: **backend mechanism / autonomous multi-actor consumer**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-03 NPC / Faction Agency**  
Prerequisite: **G5-02 PASS / CLOSED**  
Code Base SHA: `405ebafee7d428c4303d4599e78d508130757da5`  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 0. Owner correction / supersession

This packet supersedes `G5-03M1_STABLE_NPC_INDEPENDENT_AGENCY_TASK.md`.

Do **not** implement the old rule:

```text
one eligible turn → evaluate at most one NPC → round-robin
```

Current product requirement:

```text
one eligible world turn
→ select 0..N relevant stable NPCs
→ selected NPCs evaluate independently
→ several NPCs may durably act during the same Agency Cycle
```

## 1. Temporary execution routing

Through 2026-09-06 23:59 (+08:00):

```text
GPT  → semantics / architecture / final Independent Review
Kimi → code-changing implementation owner
Grok → external research/evidence support only if useful
```

Do not wait for Codex quota recovery.

## 2. Read first

Refresh both `main`s, then read:

1. repository `AGENTS.md`;
2. this packet;
3. `G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`;
4. `G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`;
5. current G5-01/G5-02 `src/世界回合/**` implementation;
6. Runtime/Application lifecycle and atomic mutation seams actually required;
7. current Guaranteed-NPC durable setup shape/tests.

Do not implement from the superseded v0.1 task/decision.

## 3. M1 outcome

Implement the first **Agency Cycle** over the stable NPC actors already guaranteed by the current Game:

```text
accepted ordinary player turn
→ existing post-Narrative semantic-analysis lane
   emits changes + knowledge_events + optional agency_candidates
→ validate 0..4 selected Guaranteed-NPC IDs
→ launch one actor-scoped agency request per selected actor
→ several selected actors may independently return hold/act
→ each valid act may become durable world truth
→ later GM Context can see the independent actor actions
```

M1 proves multi-actor scheduling/execution and leaves the candidate-pool abstraction ready for G5-03M2 stable actor materialization beyond Guaranteed NPCs.

## 4. Selection phase — reuse existing semantic request

Do not add a mandatory separate selector Provider call.

Extend the existing G5-01/G5-02 semantic-analysis machine response with an **optional and failure-isolated** field:

```json
{
  "changes": ["..."],
  "knowledge_events": [{"knower_id":"...","fact":"...","basis":"..."}],
  "agency_candidates": ["stable-npc-id-a", "stable-npc-id-b"]
}
```

Required failure isolation:

```text
bad / absent / oversized agency_candidates
→ changes remain independently valid
→ knowledge_events remain independently valid
→ Narrative remains accepted
→ agency selection becomes empty / fail-soft
```

### 4.1 Eligible roster

For M1, eligible agency actors are current `world_state.guaranteed_npcs[*]` with non-empty stable `local_character_id`.

Player Character is never eligible for autonomous agency.

The semantic request already carries the stable actor roster for G5-02. Extend the bounded actor material supplied for **selection** so the selector can plausibly judge whether each eligible NPC has reason to act now.

For each eligible NPC provide bounded material sufficient for selection:

- exact local ID + display name;
- bounded selected Character Source/T0 agency-relevant material;
- that actor's own recent committed Knowledge Provenance;
- that actor's own recent committed agency history (once it exists).

Do not dump the full omniscient GM Context.

Selection instruction must say:

> Judge each candidate from that candidate's own supplied Source, own knowledge and own history. Do not use one actor's private knowledge to justify another actor's selection.

### 4.2 Selection validation and cap

Program validates the returned candidate IDs:

- ID must exist in the eligible stable NPC roster;
- deduplicate;
- preserve model-selected order unless an implementation detail requires stable normalization;
- cap to **4 actors** for v0.2;
- unknown/Player/empty IDs are dropped;
- invalid selection creates no actor request for that item.

No round-robin fallback when the selector returns no candidates.

No retry-until-nonempty selection.

## 5. Execution phase — one isolated request per selected actor

Every selected actor gets its own machine request.

Input must contain only:

1. exact stable actor ID + display name;
2. that actor's exact Game-local Character Source / selected T0 material;
3. only that actor's committed current G5-02 Knowledge Provenance;
4. that actor's own recent committed agency actions/effects;
5. minimal Agency Cycle/source identity.

Must not contain:

- another actor's private knowledge;
- Player-only private knowledge;
- a combined multi-actor private-knowledge action prompt;
- full omniscient GM/world Context as a shortcut.

Conceptual output:

```json
{
  "actor_id": "exact-stable-id",
  "decision": "hold|act",
  "intent": "concise aim",
  "action": "concise action now undertaken",
  "effects": ["immediate established effect"]
}
```

Freeze:

- exact actor ID match;
- `hold` → no mutation;
- `act` → bounded non-empty intent/action;
- effects bounded, immediate/already-established only;
- wrong actor / malformed / oversized / Provider failure → fail-soft;
- no reasoning persisted;
- no hidden d20/check semantics.

Suggested bounds remain small: intent <=256 chars, action <=512, <=4 effects each <=512, or semantically equivalent limits documented in evidence.

## 6. Concurrent background execution

Selected actor Provider requests must be able to progress concurrently, bounded by selected actor count (max 4).

Do not implement a sequential queue that gives actor #1 a systematic chance to act while actors #2..#4 routinely lose the race to the player's next input.

A practical implementation may create one bounded adapter/process per selected actor under one Agency Cycle owner.

Agency remains background/best-effort and must not disable or delay player input.

## 7. Agency Cycle identity / lifecycle

For one eligible source turn create a stable cycle identity from at least:

`game_id + source_turn_index + accepted GM hash + cycle_base_head_id`.

Capture at cycle start:

- source turn index/hash;
- accepted Conversation count/version;
- `cycle_base_head_id`;
- local cycle epoch/token.

Track:

- selected actors;
- active/terminal per-actor requests;
- cycle-owned current head after successful sibling commits;
- invalidated/closed state.

Same already-evaluated/committed source cycle must not duplicate actor actions on replay/reopen.

## 8. Durable commits — several actions may commit in one cycle

Each valid selected actor `act` may create its own durable agency record under existing `living_world`, conceptually:

```text
living_world
  agency_cycles_by_source_turn
    <source_turn_index>
      agency_cycle_id
      source_turn_index
      source_gm_sha256
      cycle_base_head_id
      actions_by_actor
        <actor_id>
          agency_action_id
          actor_id
          intent
          action
          effects[]
          materialized_at
```

Equivalent bounded shape is acceptable if semantics are preserved.

Stable actor-action identity must include at least:

`game_id + agency_cycle_id + actor_id`.

Use only existing `session_runtime.commit_world_mutation_durably(...)`; no SQLite schema/table.

Provider calls may finish concurrently, but durable commits must be serialized. The cycle must distinguish:

```text
head changed by a successful sibling action in this same cycle
→ allowed cycle-owned progression

head changed by unrelated world mutation / Restore / Recovery / new timeline
→ invalidate remaining uncommitted results
```

Already committed sibling actions remain durable if the foreground boundary occurs later.

## 9. Foreground / timeline safety

Foreground always wins.

If a new Conversation attempt starts:

```text
invalidate all remaining queued/active uncommitted actor work
→ best-effort cancel transports
→ never block the new player turn
→ late callbacks cannot commit
```

Likewise invalidate remaining work on:

- Restore/Recovery/progress switch;
- source GM hash replacement;
- accepted Conversation advancement outside this cycle's source;
- unrelated active-head change;
- Game/session close.

Use existing Conversation `attempt_started`, Runtime `restore_completed`, world head and cycle epoch seams; do not modify Conversation semantics merely for convenience.

## 10. GM Context consumer

Extend bounded world Context with committed independent actor actions, for example:

```text
## Independent Actor Actions
Agency Cycle source turn 12
- 孙权 [id]: 派使者核实荆州水军调动
- 曹操 [id]: 命前军加紧控制江面渡口
```

This is omniscient GM world reference only.

Do not automatically make these actions:

- human-player knowledge;
- every actor's knowledge;
- G5-02 provenance for unrelated actors.

The acting actor may see its own prior actions in future selection/execution context.

Keep projection recent/bounded; G7 owns retrieval.

## 11. Application composition

Wire Agency Cycle into real Game Session lifecycle.

Preferred orchestration:

```text
WorldTurn semantic runtime finished
→ semantic result exposes validated agency_candidates
→ Agency Cycle runtime starts selected actor requests if foreground still idle/current
```

If the selector is implemented inside the existing semantic worker, expose only bounded validated selection data needed by agency runtime; do not let Application parse raw model output.

Teardown must cancel all agency transports before closing Game Runtime/writer.

No UI interaction changes.

## 12. Deterministic proofs

Add focused tests for at least:

### A. Multi-actor selection

Task-owned roster has NPC A, B, C.

Controlled semantic response selects A + B.

Prove:

- one existing semantic-analysis request only;
- selection validates A+B;
- no round-robin extra C;
- two agency executions are launched for A+B;
- Player/unknown IDs are rejected.

### B. Selector failure isolation

Valid G5-01 changes + valid G5-02 knowledge + malformed/oversized `agency_candidates`:

- changes still commit normally;
- knowledge still commits normally;
- no agency execution;
- Narrative unchanged.

### C. Per-actor knowledge isolation

A knows F; B knows G; Player knows P.

Execution request A contains F, not G/P.

Execution request B contains G, not F/P.

### D. Several acts in the same cycle

A and B requests are both active/concurrent.

Return valid `act` for both in either completion order.

Prove:

- both actor actions become durable;
- serialized atomic world mutations succeed through cycle-owned head progression;
- one does not stale the other merely because it committed first;
- later GM Context contains both.

### E. Mixed results

A=`act`, B=`hold`, C=malformed/provider failure.

Only A creates durable action; foreground remains unaffected.

### F. Foreground race

A commits before next player attempt; B still active.

Then player starts next turn and B later completes.

Prove:

- A remains durable;
- B cannot late-commit;
- player turn is not blocked.

Also test no actor completed before foreground → zero agency mutation.

### G. Restore race

Multiple actor requests active; Restore commits; late completions create zero new agency actions in restored timeline.

### H. Replay/reopen

Committed cycle/action identities do not duplicate; Save/reopen preserves multi-actor actions in later GM Context.

### I. Bound

Selector returns >4 valid IDs; only first/selected bounded 4 execute. No hidden fallback loops.

## 13. Regression gates

At minimum:

- new G5-03 focused tests;
- G5-02 focused knowledge tests including C01 roster/recency;
- G5-01 semantic + Timeline tests;
- affected G2 Conversation/Context tests;
- affected G3 Save/Restore tests;
- affected G4 continuation/Application composition tests;
- `git diff --check`.

No real Provider calls until deterministic/integration gates are green.

## 14. Real Provider validation — pre-authorized

Standing authorization applies.

For this M1, after all offline gates are green, bounded real proof may use at most:

```text
1 real combined semantic-selection request
+
up to 2 real selected actor agency execution requests
```

Maximum 3 feature-owned real model requests. No retries beyond this ceiling, no fallback, no hidden Provider switch.

Prefer task-owned setup and stub unrelated Opening/foreground prerequisites.

Feature-specific PASS should prove at minimum:

- selector returns at least two valid stable NPC candidates; and
- at least two selected actor requests are actually issued; and
- at least one actor returns a valid `act` that becomes durable; ideally both act, but a valid hold from one actor is not fabricated as failure.

If Provider timeout/unavailability or inconclusive selection prevents proof within the ceiling:

```text
real G5-03 multi-actor vertical = PENDING / INCONCLUSIVE OR EXTERNAL PROVIDER UNAVAILABLE
→ commit/push reviewable implementation/tests/evidence
→ READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

## 15. Scope ceiling

Expected production scope:

- existing semantic parser/process extension for optional `agency_candidates`;
- new bounded Agency Cycle runtime/module;
- bounded actor-scoped context helper/projection;
- minimal Application lifecycle wiring;
- existing world mutation seam only.

Protected:

- `src/domain/会话.gd` semantics;
- `src/ui/**`;
- persistence schema/migrations;
- Source schema/generation;
- Runtime Model Settings;
- Public d20;
- arbitrary emergent actor identity;
- Faction agency;
- G5-04 general event/priority scheduler;
- G5-05 mechanics;
- G6/G7.

Do not build a universal actor simulation platform.

## 16. Evidence

Create:

`docs/g5_03/G5-03M1_MULTI_ACTOR_AGENCY_CYCLE_EVIDENCE.md`

Record:

- START/implementation/final heads;
- changed paths;
- actual `agency_candidates` response/parser semantics;
- selection cap and validation;
- concurrency mechanism;
- cycle identity and sibling-safe head progression;
- per-actor context isolation evidence;
- multi-act/mixed/foreground/Restore/replay tests;
- regressions + `git diff --check`;
- real Provider profile/result without secrets;
- explicit no extra selector call, no UI/schema/Faction/G5-04 scope creep.

## 17. Completion

Commit/push to `origin/main` and return:

```text
READY FOR INDEPENDENT REVIEW
```

or if bounded real proof is pending:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not declare G5-03 PASS/CLOSED. GPT owns Independent Review and then shapes G5-03M2 stable actor materialization so important non-Guaranteed named NPCs can enter the candidate pool.
