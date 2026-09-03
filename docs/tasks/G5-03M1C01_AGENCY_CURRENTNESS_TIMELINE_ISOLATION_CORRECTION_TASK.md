# TASK｜G5-03M1C01｜Agency Currentness + Timeline Isolation Correction

Type: **focused backend correction**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-03M1 Multi-Actor Agency Cycle**  
Prerequisite implementation: `3b5d104682f33f594cf72178a754ef044ff97469`  
Independent Review: `docs/g5_03/G5-03M1_INDEPENDENT_REVIEW.md`  
Canonical decision: `Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING**

## 0. Scope

This is **correction-01**, not a redesign.

Keep the accepted M1 architecture:

```text
one semantic-analysis request
→ 0..4 agency_candidates
→ isolated concurrent actor executions
→ several actor actions may commit in one Agency Cycle
```

Fix only current-version / timeline isolation and the directly related replay proof.

Do not revert to one-NPC round-robin. Do not start G5-03M2, Faction agency or G5-04.

## 1. No real Provider call

Do **not** call any real Provider in this correction.

The parent bounded real attempt was already consumed and timed out before feature-specific proof. All correction evidence must be deterministic/stubbed.

## 2. Required correction A — stale semantic handoff must not start Agency

Before Application starts an Agency Cycle from `world_turn_runtime.finished`, require the result still belongs to the current foreground state.

At minimum prove all of:

- source turn index is still the latest accepted ordinary Conversation turn;
- source GM hash equals the current accepted GM text hash;
- Conversation is idle / not generating a newer foreground turn;
- a new foreground attempt that began before semantic completion prevents that older semantic result from starting Agency.

The semantic lane should also avoid exposing usable `agency_candidates` from a stale accepted version. This protection must apply even when the semantic response contains **agency candidates only** with no `changes` or `knowledge_events`.

Ensure no-changes result carries the source GM hash when needed for handoff validation.

Required deterministic race:

```text
Turn A accepted
→ semantic request A active
→ player starts Turn B before A completes
→ complete semantic A with valid agency_candidates
→ zero Agency Cycle / zero actor execution for A
→ foreground Turn B remains usable
```

## 3. Required correction B — real Restore wiring invalidates Agency

Production Restore/Recovery progress-switch lifecycle must invalidate all remaining uncommitted Agency work.

Do not rely on a test manually calling `invalidate_remaining()` as a substitute for product wiring.

Use existing `restore_completed` / progress-switch seam or equivalently narrow Runtime signal.

Required integration proof:

```text
Application/session with active multi-actor Agency Cycle
→ perform committed Restore through Runtime product seam
→ production Restore callback automatically invalidates cycle
→ simulate old actor late completion
→ zero stale post-Restore agency mutation
```

Already committed sibling actions before the Restore boundary may remain in the pre-Restore timeline according to existing Save/Timeline semantics; no post-Restore late result may commit into the restored current branch.

## 4. Required correction C — commit-time currentness and cycle-owned head progression

Before each actor action commit, validate that the Agency Cycle is still current.

Capture / track enough state to distinguish:

```text
current head changed by this same cycle's successful sibling commit
→ allowed cycle-owned progression

current head changed by unrelated mutation / Restore / other timeline progress
→ invalidate remaining uncommitted actor results
```

At minimum guard:

- current accepted source GM hash;
- accepted Conversation count/version has not advanced beyond the cycle source;
- no newer foreground generation is active;
- current `active_head_id` equals the cycle-owned expected head;
- cycle/session not invalidated/closing.

After one sibling commit succeeds, update the cycle-owned expected head to that committed head before another sibling may commit.

Required deterministic proof:

```text
A + B active in same cycle
→ A commits
→ expected head advances to A's node
→ B commits successfully
```

and separately:

```text
A + B active
→ unrelated world mutation changes head
→ B returns valid act
→ B cannot commit
```

No new persistence owner or SQLite schema.

## 5. Required correction D — actor-local memory must be current-hash matching

Both Agency Selection material and actor Execution material must include only **current durable** Knowledge Provenance / Agency History.

Do not scan by actor ID alone.

For Knowledge:

- validate record shape;
- require its `source_turn_index` exists in current accepted Conversation;
- require `source_gm_sha256` matches the current accepted GM hash for that turn;
- then include only events whose `knower_id` equals the selected actor.

For prior Agency History:

- validate cycle/action shape;
- require cycle source turn/hash matches current accepted Conversation;
- include only that actor's own action;
- keep bounded recent material.

Required regression:

```text
old Turn N says NPC A learns secret F
→ durable knowledge F exists
→ replace accepted Turn N with a different GM Narrative where F never happened
→ Agency selector input for A must not contain F
→ actor execution input for A must not contain F
```

Add equivalent stale agency-history exclusion proof.

Do not solve this with prose instructions alone; Program must filter stale records before sending the request.

## 6. Required correction E — replacement at same turn index must not merge into stale cycle

`build_agency_candidate(...)` or its caller must only merge sibling actions into an existing cycle if that stored cycle is the **same current Agency Cycle**.

If the current world snapshot contains a stale cycle at the same `source_turn_index` but different current source hash / cycle identity, the new current cycle must replace that turn-index record before adding its action.

Required proof:

```text
Turn N old GM hash A has durable Agency Cycle A
→ accepted Turn N replaced with GM hash B
→ new Cycle B actor acts
→ current world stores Cycle B with hash B
→ old Cycle A is not merged into current branch
→ later GM Context projects the new action
```

Historical Cycle A remains recoverable only through existing Timeline/Save historical snapshots; do not build compensating undo logic.

## 7. Replay / reopen proof tightening

For an already committed matching current Agency Cycle, an actor that already has a committed action must not be re-executed merely because the cycle seam is considered again.

Replace the current identity-only H assertion with an actual behavioral proof:

```text
matching cycle already contains actor A action
→ replay/consider same source version with A selected again
→ no new Provider execution for A
→ no second mutation
```

A minimal skip based on existing matching `actions_by_actor` is sufficient. Do not build a general distributed job ledger.

## 8. Preserve passing semantics

Must remain true:

- one semantic Provider request, no mandatory selector request;
- 0..4 validated stable NPC candidates;
- selected actor execution requests can be concurrently active;
- each actor request contains only its own Source/current knowledge/current history;
- several valid sibling acts may durably commit within one cycle;
- `hold` / malformed / wrong actor / Provider failure fail-soft;
- player input is never delayed waiting for Agency;
- Agency actions do not automatically become Player disclosure or other actors' knowledge;
- no hidden checks/d20;
- no round-robin fallback;
- no Faction/G5-03M2/G5-04 scope.

## 9. Expected production scope

Keep correction bounded around existing M1 seams, likely:

- `src/世界回合/L2_流程层/语义物化流程.gd`;
- `src/世界回合/L2_流程层/行动代理循环流程.gd`;
- `src/世界回合/L0_公理层/世界回合规则.gd` if cycle replacement helper belongs there;
- `src/应用壳.gd` Restore / semantic handoff wiring;
- focused G5-03 tests/evidence.

The existing Context projector may be reused for hash semantics; do not build G7 retrieval.

Protected unless a concrete blocker is returned first:

- `src/domain/会话.gd` semantics;
- `src/ui/**`;
- persistence schema/migrations;
- Source schema/generation;
- Runtime Model Settings;
- Public d20;
- G5-03M2 actor registry;
- Faction identity/agency;
- G5-04+;
- G6/G7.

## 10. Regression gates

Run at minimum:

- corrected G5-03 focused suite including all new race/replacement/stale-memory cases;
- G5-02 knowledge suite;
- G5-01 semantic + Timeline suite;
- affected G2 Conversation/Context tests;
- affected G3 Save/Restore tests;
- affected G4 Application/continuation/Public d20 integration tests;
- `git diff --check`.

## 11. Evidence

Create:

`docs/g5_03/G5-03M1C01_AGENCY_CURRENTNESS_TIMELINE_ISOLATION_EVIDENCE.md`

Record:

- START_HEAD / IMPLEMENTATION_HEAD / FINAL_HEAD;
- exact changed paths;
- late-semantic-after-foreground proof;
- production Restore-wiring proof;
- sibling-head allowed vs unrelated-head rejected proof;
- stale Knowledge + stale Agency History filtering proof;
- same-turn replacement proof;
- actual no-duplicate replay proof;
- regressions;
- `git diff --check` PASS;
- explicit **no real Provider call**;
- no M2/Faction/G5-04/UI/schema scope creep.

## 12. Completion

Commit/push to `origin/main` and return:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not declare G5-03M1 or G5-03 PASS/CLOSED.
