# MW-010 Independent Review — IR#1

Work Item: **MW-010**  
Name: **G5 Living-World Integrated Reality Matrix**  
Capability-Anchor: **G5-07 World Product Tests**  
Candidate SHA: `78c05887600332b93a4d50cd1d63d639841fb2eb`  
Candidate branch: `mw-010-g5-living-world-integrated-reality-matrix`  
Reviewer: **GPT**  
Review Round: **IR#1**  
Verdict: **NOT PASS — REVISION 2 REQUIRED**

## 1. Review scope

Reviewed against:

- `docs/tasks/MW-010_G5_LIVING_WORLD_INTEGRATED_REALITY_MATRIX_TASK.md`;
- `Vibe-Coding/my world/architecture/world/G5_WORLD_PRODUCT_TEST_MATRIX_V0_1_DECISION.md`;
- candidate commit/diff at `78c0588...`;
- `tests/mw010/生界一体现实矩阵测试.gd`;
- candidate implementation evidence;
- current G5-01/G5-02/G5-03/G5-04/MW-006/MW-007/MW-009 composition semantics.

The candidate correctly preserves the preferred **zero production diff** shape. Compare from current task base shows only:

```text
docs/mw010/MW-010_INTEGRATED_REALITY_MATRIX_EVIDENCE.md
tests/mw010/生界一体现实矩阵测试.gd
tests/mw010/生界一体现实矩阵测试.gd.uid
```

No production file changed.

## 2. What is accepted in IR#1

The candidate materially proves several required cross-capability paths using one real FinalCreate Game + real CurrentGameRuntime + real SQLite + real Shell with deterministic stubs:

- quiet opportunity can legitimately remain `hold`;
- a stable NPC can take a durable independent action and World Evolution can advance without the Player selecting that NPC action;
- those hidden Agency/Evolution truths enter omniscient GM continuation context but remain outside the player-safe side panel;
- Program-owned Public-d20 result precedes Narrative, MW-006 grounding enters the normal semantic opportunity exactly once, and a mechanics-consistent durable consequence is materialized through G5-01;
- close/reopen deep-reconstructs the composed truth families and same `action_id` does not reroll;
- Save/Restore removes Path-A semantic/Player-knowledge material and alternate Path B establishes distinct current truth;
- no second projection/matrix truth store or production schema/platform was introduced.

These are substantive and should be retained.

## 3. Blocking finding F01 — Counterfactual Path A does not create restored-away non-player truth

Canonical G5-07 Scenario B requires the post-Save Path A to create composed current truth including a non-player family (`Agency-or-Evolution`), then prove that this **Path-A-derived non-player truth** stops being current after Restore.

The executable packet states conceptually:

```text
Save S
→ Path A Narrative
→ A-derived semantic consequence / knowledge / Agency-or-Evolution truth
→ verify A current
→ Restore S
→ restored-away A material absent from current consumers
```

But the candidate Path A explicitly drives:

```text
selector → {"actors": []}
evolution → {"decision": "hold"}
```

Therefore Path A creates only semantic consequence + Player knowledge. The Agency action and Evolution event checked after Restore are **pre-S** truth from T2, and the test correctly asserts they remain current. That is useful, but it is not the required counterfactual proof that restored-away non-player truth cannot leak forward.

### Required Revision 2 correction

After Save S, Path A must create at least one uniquely identifiable current non-player truth through the existing production lane, preferably one bounded World Evolution event or Agency action.

Before Restore, prove that Path-A-specific non-player truth:

- is durably current;
- enters current GM continuation context;
- remains outside player-safe projection unless separately learned.

After Restore S, prove that the same Path-A-specific non-player truth:

- is absent from current World snapshot/current record set as appropriate;
- is absent from current GM context;
- is absent from player-safe projection;
- does not re-enter after alternate Path B.

Pre-S T2 Agency/Evolution truth should continue to remain current, preserving the currentness-vs-deletion distinction.

## 4. Blocking finding F02 — Integrated NPC Knowledge → Player Knowledge disclosure transition is missing

Canonical G5-07 Knowledge Boundary requires the composed timeline itself to prove:

```text
NPC-only post-T0 Knowledge Provenance
→ NPC has durable provenance
→ Player Character does not
→ player-safe UI does not show it

later Player Character Knowledge event establishes awareness
→ related fact may now appear through the player-safe knowledge seam
```

The candidate does prove that a hidden NPC Agency action / Evolution event is not player-visible. However, **hidden world/Agency truth is not equivalent to NPC Knowledge Provenance**.

The MW-010 focused matrix creates no NPC-only `knowledge_events` record. Its Player knowledge events are the mechanics-grounded fact at T3 and the Path-A own-change fact; neither is a later disclosure of the NPC-only secret/action from T2.

The separate MW-009 regression remains green, but G5-07's purpose is composition in one integrated timeline; delegating this transition entirely to a prior isolated suite does not satisfy the frozen Scenario D / executable Scenario C requirement.

### Required Revision 2 correction

Use the existing G5-02 semantic seam in the same MW-010 Game timeline to establish one NPC-only post-T0 knowledge fact tied naturally to the independent-actor situation.

Prove:

1. the NPC knowledge record is durable/current for the stable NPC;
2. the Player Character has no corresponding provenance yet;
3. the player-safe panel does not show the fact;
4. a later accepted turn establishes Player Character knowledge of the same or substantively related fact through the normal knowledge seam;
5. the panel may then show the Player-known formulation;
6. if that later Player knowledge is created after Save S, Restore S removes the Player disclosure while the pre-S NPC-only provenance may remain current and still hidden from the panel.

This can be composed with the F01 Path-A correction; no new feature or Provider behavior is required.

## 5. Revision lineage

Both findings are defects in the proof of the **same MW-010 outcome**, not distinct product outcomes.

Therefore:

```text
Work Item: MW-010
Revision: 2
Next Review: IR#2
```

Do not mint a new flat Work ID.

## 6. Production / scope rule for Revision 2

Preferred and expected result remains:

```text
production code diff = 0
```

Revision 2 should modify only the MW-010 focused test/evidence unless the existing production architecture genuinely cannot express either required scenario. If that happens, STOP and report the owning prior-capability defect rather than repairing it under MW-010.

No new schema, branch engine, scenario platform, reactive store, mechanics protocol, G6 UI infrastructure, or MW-005 style change is authorized.

## 7. Test rerun expectation

At minimum rerun:

- revised `tests/mw010/生界一体现实矩阵测试.gd`;
- MW-009 player-safe projection;
- G5-02 Knowledge Provenance;
- G5-03 Agency;
- G5-04 / MW-002 Evolution;
- G5-01 semantic + Restore/currentness;
- MW-006 + MW-007;
- Public-d20 no-reroll/reopen;
- `git diff --check`.

Real Provider calls may remain `0`. Windows export remains optional while production code stays unchanged.

## 8. IR#1 verdict

**NOT PASS — MW-010 Revision 2 REQUIRED.**

The candidate is close and its zero-production-diff composition is the correct direction. Revision 2 is a focused integration-proof completion, not a production redesign.
