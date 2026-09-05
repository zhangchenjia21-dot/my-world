# TASK｜MW-010｜G5 Living-World Integrated Reality Matrix

Type: implementation / integration-test / G5-07 engineering reality proof  
Work Item: **MW-010**  
Name: **G5 Living-World Integrated Reality Matrix**  
Capability-Anchor: **G5-07 World Product Tests**  
Implementer: **Zcode + GLM-5.3-flash**（Owner weekend routing override）  
Reviewer: **GPT**  
Formal Code Base: `my-world/main@bed9c882a421552f7f72e3c578273ac436a43609`  
Governance / Architecture Base: `Vibe-Coding/main@1019440346be33425d31d9a19994a6939fe26d96`  
Task Branch: `mw-010-g5-living-world-integrated-reality-matrix`  
Required worktree path: `D:/AI/Projects/.worktrees/my-world/mw-010`  
Status: **ACTIVE — ZCODE**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Build the G5-07 engineering integration matrix that proves the already-existing G5 capabilities remain coherent when composed into one real durable Game timeline.

Preferred result:

```text
production code diff = 0
+ real FinalCreate / Runtime / SQLite integration tests
+ evidence
```

This task is not a feature-growth task.

## 2. Canonical authority

Read and obey:

`Vibe-Coding/my world/architecture/world/G5_WORLD_PRODUCT_TEST_MATRIX_V0_1_DECISION.md`

Protected distinction:

```text
engineering integration proof
!= Owner product-feel UAT
```

MW-010 proves ordering, currentness, persistence and disclosure. The Owner later judges whether the composed RPG actually feels alive and coherent.

## 3. Read First

1. `AGENTS.md`
2. `Vibe-Coding/AGENTS.md`
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
4. this Task Packet
5. `Vibe-Coding/my world/architecture/world/G5_WORLD_PRODUCT_TEST_MATRIX_V0_1_DECISION.md`
6. `docs/g5_06/G5-06_CLOSEOUT.md`
7. `docs/mw009/MW-009_INDEPENDENT_REVIEW_IR1.md`
8. G5-01 / G5-02 / G5-03 / G5-04 current decisions and directly relevant production paths
9. `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md`
10. `docs/mw007/MW-007_INDEPENDENT_REVIEW_IR1.md`
11. actual Shell / CurrentGameRuntime / WorldTurn / Agency / WorldEvolution / Public-d20 / player-safe projection seams used by the matrix

Do not read unrelated subsystems merely for completeness.

## 4. Worktree hygiene

Before starting:

1. refresh both repository `main`s;
2. inspect `git worktree list --porcelain`;
3. MW-009 is now Engineering PASS and integrated into `main`; remove its worktree only if it is clean, pushed/reachable and contains no unknown user work;
4. use `git worktree remove`, then `git worktree prune`;
5. create exactly:

`D:/AI/Projects/.worktrees/my-world/mw-010`

Do not create a new task worktree directly under `D:/AI/Projects/`.

## 5. Mandatory two-pass audit before writing tests

### Pass A — production composition/lifecycle

Trace the exact ordering and current owners for:

```text
accepted Narrative
→ semantic materialization
→ Knowledge / runtime actor materialization
→ Agency opportunity
→ World Evolution opportunity
→ later GM Context
```

Also trace:

- Public-d20 CHECK_REQUIRED durable resolution → accepted Narrative → MW-006 grounding → semantic consequence;
- Save / close / reopen;
- Restore/progress switch;
- player-safe projection refresh/currentness.

Record the actual functions/signals and currentness identities in evidence.

### Pass B — cross-capability authority/currentness

For each truth family classify:

- durable owner;
- currentness key/hash;
- GM-visible consumer;
- actor-private consumer;
- player-safe consumer;
- Restore/replacement behavior.

At minimum cover:

```text
semantic consequences
Knowledge Provenance
runtime/stable actor identity if used
Agency actions
World Evolution events
Public-d20 resolution + mechanics-grounded consequence
player-safe side-panel projection
```

Do not code until the matrix can be expressed using existing production owners.

## 6. Required integrated scenarios

Use real FinalCreate Game + real CurrentGameRuntime + real SQLite. Use task-owned deterministic Provider stubs where model choices need to be controlled.

### Scenario A — Player Absence / World Independence

Prove both:

1. a quiet opportunity can legitimately produce `hold` / no fabricated world event;
2. a separate mature non-player pressure can advance through existing Agency and/or World Evolution without treating the Player action as its causal author.

The Player turn may provide the scheduling opportunity only.

### Scenario B — Counterfactual Propagation

Use Save/Restore, not a new branch engine:

```text
Save S
→ materially distinct Path A Narrative
→ A-derived current world/knowledge/non-player truth
→ verify A current
→ Restore S
→ materially distinct Path B Narrative
→ verify restored-away A no longer enters current GM Context or player-safe projection
→ verify B may establish its own current truth
```

Physical historical rows may remain where existing persistence intentionally retains history. Test currentness, not destructive deletion.

Do not probe the known MW-007 exact reused-action-id advisory as part of this scenario.

### Scenario C — Independent Actor + Knowledge Boundary

Prove a stable NPC can take a durable independent action through G5-03 without the Player choosing it.

Then prove:

```text
NPC-only secret/action
→ may be GM current-world reference
→ does NOT appear in player-safe side panel

later Player Character Knowledge event establishes awareness
→ related fact may now appear through the knowledge seam
```

### Scenario D — Mechanics → living-world consequence

Run one bounded existing Public-d20 path:

```text
meaningful risky Player action
→ Program-owned d20 resolution
→ free-form accepted Narrative
→ MW-006 grounding
→ normal G5-01 consequence
```

Prove the consequence is consistent with the authoritative mechanics fact, survives close/reopen once, and does not reroll/duplicate.

Do not implement hardcoded `success/failure → world effect` mappings.

### Scenario E — Save / reopen / Restore composition

Across the composed scenario prove coherent reconstruction/rewind for all truth families actually created:

- Conversation;
- semantic consequence;
- Player/NPC Knowledge;
- independent actor action;
- World Evolution event when an advance case is created;
- mechanics-grounded consequence;
- player-safe projection.

## 7. Stop rule on discovered defects

If MW-010 exposes a real production defect in a previously closed capability:

**STOP and report it.**

Do not silently repair the prior capability under MW-010. Identify the likely owning Work Item/capability so GPT can route a proper Revision according to task-lineage governance.

The only production modifications allowed in MW-010 are strictly test-observability seams that add no product behavior and are demonstrably necessary; prefer no production change. If such a seam seems needed, explain it in evidence before using it.

## 8. Focused proof expectations

The integrated test must prove actual state/projection, not merely string-search fixture files.

At minimum assert:

1. quiet hold does not manufacture an event;
2. non-player world/actor development can become durable independently;
3. Path A current truth disappears from current consumers after Restore and alternate Path B;
4. stable NPC independent action is durable and current;
5. NPC-only knowledge/private truth does not enter player-safe projection;
6. Player Character knowledge later permits safe disclosure;
7. Public-d20 resolution remains Program-owned and no-reroll;
8. mechanics-grounded consequence materializes through normal G5-01 seam;
9. close/reopen reconstructs current composed state exactly enough for all tested consumers;
10. Restore rewinds restored-away current truth coherently;
11. MW-009 player-safe projection still excludes hidden Runtime truth;
12. no second world/mechanics/knowledge/timeline truth store was created;
13. SQLite schema/table set unchanged;
14. real Provider calls may remain 0;
15. `git diff --check` clean.

## 9. Regression matrix

Run the new integrated matrix plus directly affected existing suites. At minimum include bounded roots for:

- G5-01 semantic/currentness + Restore;
- G5-02 Knowledge Provenance;
- G5-03 Agency;
- MW-002 / G5-04 World Evolution;
- MW-006;
- MW-007;
- MW-009;
- Public d20 no-reroll/reopen;
- Save/Restore Runtime;
- MW-008 UI rendering smoke if the real Shell is exercised.

If production GDScript/scene code remains unchanged, a new Windows export validation is optional; if production code changes, export validation is mandatory.

## 10. Explicit non-scope

Do not add:

- new gameplay systems;
- generic scenario/simulation platform;
- new Timeline/branch system;
- new SQLite schema/table;
- generic event bus/ViewModel;
- G6 declarative/dynamic UI host;
- Faction/Quest/Inventory/Map systems;
- new Public-d20 protocol;
- Narrative output parser/gate/classifier/retry;
- Provider summarization/retrieval platform;
- MW-005 style-weight changes in this Work Item.

The Owner-requested bounded MW-005 style-weight polish is queued separately for the combined Owner UAT and must not contaminate MW-010's G5-07 engineering identity.

## 11. Return contract

Push the task branch and return:

- implementation/evidence SHA(s);
- remote branch;
- base/final head;
- worktree cleanup/path;
- changed files;
- Pass A lifecycle audit;
- Pass B authority/currentness matrix;
- exact scenario topology;
- test commands and counts;
- production diff status (prefer zero);
- SQLite schema unchanged proof;
- Provider call count;
- export result if applicable;
- any discovered prior-capability blocker;
- remaining risks.

Return ceiling:

**READY FOR INDEPENDENT REVIEW**

Only GPT may issue Engineering PASS. Only Owner may issue product/G5-GATE PASS.
