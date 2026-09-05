# ADDENDUM｜MW-010 Revision 2｜Counterfactual + Knowledge Boundary Completion

Work Item: **MW-010**  
Capability-Anchor: **G5-07 World Product Tests**  
Revision: **2**  
Triggered by: `docs/mw010/MW-010_INDEPENDENT_REVIEW_IR1.md`  
Implementer: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Status: **ACTIVE — REVISION 2**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

This addendum narrows the existing MW-010 contract. All unchanged requirements from:

`docs/tasks/MW-010_G5_LIVING_WORLD_INTEGRATED_REALITY_MATRIX_TASK.md`

remain authoritative.

## 1. Revision 2 outcome

Complete the two missing pieces in the **same real MW-010 Game timeline** while preserving:

```text
production code diff = 0
```

Required additions:

1. Path A after Save S creates one uniquely identifiable non-player current truth via existing Agency or World Evolution, and Restore proves that Path-A-specific truth is no longer current.
2. The integrated timeline contains an NPC-only Knowledge Provenance fact, proves it is hidden from Player-safe UI, then later gives the Player Character normal Knowledge Provenance of the same/substantively related fact and proves disclosure becomes allowed.

No feature growth is authorized.

## 2. F01 exact proof shape — restored-away non-player truth

Use the existing Save S counterfactual section.

After Save S and during Path A, create a unique non-player truth such as:

```text
PATH_A_EVOLUTION
or
PATH_A_AGENCY_ACTION
```

through the normal production lane.

Before Restore S assert:

```text
Path-A non-player record exists/current
GM continuation Context contains it
Player-safe side panel does not expose it merely because it is World/GM truth
```

After Restore S assert:

```text
Path-A non-player current record no longer exists / no longer matches current snapshot
GM continuation Context does not contain it
Player-safe side panel does not contain it
```

Then create alternate Path B and assert the Path-A non-player truth does not reappear.

Keep the existing pre-S T2 Agency/Evolution records and prove they remain current after Restore S. This distinction is required:

```text
pre-S truth remains
restored-away Path-A truth disappears
```

Do not require physical deletion of historical rows outside the current snapshot semantics.

## 3. F02 exact proof shape — NPC Knowledge → later Player disclosure

In the same composed timeline, create one valid post-T0 NPC-only Knowledge Provenance event through the normal semantic materialization seam.

Preferred placement: around the existing T2 independent-actor situation so the fact is naturally related to the NPC's own plan/action.

Example conceptual relationship only:

```text
NPC-only provenance:
孙权 knows that a private water-defense order/plan exists

Player-safe panel:
must not show that fact yet
```

Then, on a later accepted turn, create a normal Player Character Knowledge event for the same or substantively related information.

Assert:

```text
before Player provenance:
NPC record durable/current
Player has no matching provenance
panel hidden

after Player provenance:
Player knowledge record durable/current
panel may display the Player-known formulation
```

Strongly preferred composition with the existing counterfactual:

```text
NPC-only provenance = pre-S
Player later learns it = Path A after S
Restore S
→ Player disclosure disappears
→ pre-S NPC provenance remains current
→ panel remains hidden
```

This proves both Knowledge asymmetry and timeline currentness in one scenario.

Do not infer Player knowledge from Agency/Evolution/world truth. The Player-visible fact must arrive through `knowledge_events` for the Player Character.

## 4. Preserve already accepted MW-010 evidence

Do not regress:

- quiet `hold` case;
- independent NPC action;
- World Evolution advance;
- omniscient GM Context vs player-safe projection boundary;
- Program-owned d20 result;
- MW-006 grounding exactly once;
- normal G5-01 mechanics consequence;
- close/reopen family reconstruction;
- no-reroll same `action_id` after reopen;
- alternate Path B currentness;
- zero production diff;
- no second truth store/schema/platform.

## 5. Worktree / branch

Continue the existing task lineage. Do **not** create a new Work Item.

Before editing:

1. fetch current `my-world/main` and `Vibe-Coding/main`;
2. reconcile the current MW-010 branch with the new IR/addendum governance commits;
3. keep the existing worktree if it is clean/appropriate:

`D:/AI/Projects/.worktrees/my-world/mw-010`

4. continue branch:

`mw-010-g5-living-world-integrated-reality-matrix`

Do not delete the active MW-010 worktree before IR#2.

## 6. Changed-file expectation

Expected Revision 2 changes:

```text
tests/mw010/生界一体现实矩阵测试.gd
docs/mw010/MW-010_INTEGRATED_REALITY_MATRIX_EVIDENCE.md
```

plus `.uid` only if tooling changes it.

Any production-code change is unexpected. If production code appears necessary, STOP and report the prior capability that cannot express the frozen scenario.

## 7. Regression expectation

At minimum rerun:

```text
tests/mw010/生界一体现实矩阵测试.gd
tests/mw009/玩家安全侧栏投影测试.gd
tests/g5_02/已知角色知识溯源测试.gd
tests/g5_03/多角色行动代理循环测试.gd
tests/g5_04/选择性世界演化评估测试.gd
tests/g5_01/世界回合语义物化测试.gd
tests/g5_01/世界回合时间线恢复测试.gd
tests/mw006/机制锚定世界后果垂直测试.gd
tests/mw007/机制后果时间线连续性测试.gd
relevant Public-d20 no-reroll/reopen suite
git diff --check
```

Real Provider calls may remain `0`.

## 8. Return contract

Return:

- Revision 2 SHA;
- exact base/final head;
- changed files;
- exact added Path-A non-player truth and pre/post-Restore assertions;
- exact NPC-only knowledge fact and later Player-known related fact;
- proof of panel behavior before/after Player provenance and after Restore;
- focused/regression counts;
- confirmation production diff remains zero;
- any blocker.

Return ceiling:

**READY FOR INDEPENDENT REVIEW**
