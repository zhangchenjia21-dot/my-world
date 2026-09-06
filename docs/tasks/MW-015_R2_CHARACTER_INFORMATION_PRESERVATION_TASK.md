# TASK｜MW-015 R2｜Character Information Preservation Correction

Type: G6 product-correction implementation task  
Work Item: **MW-015**  
Revision: **2**  
Review-Round: **0**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Status: **READY FOR CODEX**  
Task Branch: `mw-015-r2-character-information-preservation`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-015-r2`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Repair the Owner-UAT product regression introduced by MW-015 R1 without reverting the accepted left/right information architecture.

Required user-visible result:

```text
left Player Status Host
→ remains collapsed/hidden when no portrait/live mechanic contribution exists

right 角色 Surface
→ materially rich current Character Sheet
→ useful immediately before any lived curator update
→ evolves after successful curator updates
```

The correction must restore legitimate Character information that was visible in the Owner-accepted MW-011 rich profile while continuing to exclude information owned by Inventory and other domains.

## 2. Why now

MW-015 R1 is **Owner UAT NOT PASS**.

Read first:

1. `AGENTS.md`
2. `docs/mw015/MW-015_OWNER_UAT_R1_RESULT.md`
3. `docs/tasks/MW-015_CHARACTER_AND_IMPORTANT_EXPERIENCES_UI_V0_1_TASK.md`
4. `docs/tasks/MW-014_MODEL_DRIVEN_CHARACTER_AND_MILESTONE_CURATION_V0_1_TASK.md`
5. `docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`
6. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
7. `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
8. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`

Refresh both repository mains before implementation. If newer current authority conflicts with this packet, STOP and report.

## 3. Root-cause constraint

R1 intentionally avoided using arbitrary starting-profile groups because some authored profile material (notably starting possessions) belongs to future Inventory rather than Character. That concern remains valid.

But R1 over-corrected by reducing the no-curation Character view to headline/summary only. This conflicts with:

- MW-011 Owner-accepted product value: rich background/personality/capability/limitation/goals/principles information;
- MW-014 requirement that frozen starting `player_profile` remain visible/useful before lived curation;
- frozen Character semantics: `角色 = 现在的我是谁`.

Do not treat the thin R1 initial state as the desired baseline.

## 4. Frozen Character-owned starting material

When available in the Game's already-frozen player-facing starting material, the Character Surface should preserve useful information corresponding to:

```text
基本资料
出身 / 来历
当前身份 / 社会角色
性格 / 价值观 / 原则
能力 / 专长说明          # non-numeric
局限 / 长期特征
长期目标 / 自我方向
```

This must be available without requiring the player to first complete a new meaningful Turn.

Explicitly not Character-owned:

```text
starting/current possessions / equipment / money / consumables
→ future Inventory

HP / MP / numeric attributes / Buff / short-term status
→ Player Status / mechanic state

relationship truth
→ People / Relationship

open commitments / tasks / clues / current plan
→ future 事务

omniscient world truth / NPC-private / GM-private material
→ never player-facing Character
```

## 5. No heuristic semantic filter

Do **not** repair this by:

- matching group titles with keywords such as `物品`, `装备`, `性格`, `目标`;
- regex filtering;
- importance scores;
- per-character special cases;
- hard-coded Zhang Chen prose;
- parsing Narrative to reconstruct Character.

Use explicit structured ownership already present in the player-profile / Character projection contract where possible.

If the current frozen game-local representation cannot deterministically distinguish Character-owned material from Inventory/other-domain material without semantic heuristics, **STOP and return an architecture finding** with the exact representation gap. Do not silently invent a new classifier.

A narrow schema/projection correction is allowed if required, but it must preserve existing Game ancestry and must not consult Source Library current for old Games.

## 6. Currentness / baseline + lived curation

Required semantics:

```text
frozen Game-local starting Character material
+
current model-curated lived Character material
→ current Character projection
```

The exact implementation may use replacement/overlay semantics consistent with the existing MW-014 contract, but must prove:

- before first successful curator update: rich useful Character baseline exists;
- after successful curator update: current model-curated Character is visible without reopening;
- starting baseline does not duplicate fields/groups after curation;
- curator can replace/remove/change current Character information according to model authority;
- Regenerate/Restore restores the Character view matching current history;
- reopen reproduces equivalent current view;
- no Source-current backfill into existing Games.

Do not turn UI render/reopen into a Provider call.

## 7. Existing Game compatibility

Owner UAT exposed the defect on a real integrated Game. Correction must cover existing Games whenever the needed frozen player-facing starting material already exists inside that Game.

Do not require the Owner to recreate the Game merely to regain profile information unless Codex proves the old Game does not contain the necessary frozen material and STOPs with evidence.

Never fetch latest Character Source to retrofit an old Game.

## 8. Left Host remains accepted

Do not restore the MW-011 biography panel on the left.

The current architecture remains:

```text
Player Status Host
→ portrait + real live mechanic/status HUD only
→ hidden/collapsed today if empty
```

The product defect is information loss during migration, not the disappearance of the old left column itself.

## 9. Important Experiences

Do not expand scope merely because the current Owner screenshot showed an empty Important Experiences state.

Empty Important Experiences is valid when the model has not judged any current-history event to be a milestone.

Only touch this Surface if required to preserve currentness/regression behavior while correcting Character.

## 10. Engineering acceptance

At minimum prove on the real production path:

1. a fresh Zhang Chen Game shows materially rich Character information before the first lived curator update;
2. an existing compatible Game with frozen starting profile material also regains that rich Character view without Source-current lookup;
3. expected Character-owned material includes background, personality/values/principles, capabilities, limitations and long-term goals when present;
4. starting possessions/equipment do **not** appear in Character;
5. no HP/fake mechanics/relationship/open-task/private material is introduced;
6. left Player Status Host remains collapsed/hidden with no legitimate contribution;
7. successful curator update changes the current Character view without reopening and without duplicate baseline groups;
8. curator failure keeps gameplay non-blocking and preserves the last valid current Character projection;
9. Restore/Regenerate/reopen currentness remains correct;
10. no render-time Provider call;
11. no keyword/regex/title-based semantic classifier or Zhang-Chen-specific UI logic;
12. no Source Library current backfill for existing Games;
13. MW-014, MW-011 privacy, MW-012, G3 Save/Restore, MW-009 safe projection and Narrative critical-path regressions PASS;
14. maximized / 1280x720 / narrow layout remains coherent;
15. `git diff --check` clean;
16. Windows Desktop export PASS.

## 11. Product acceptance target

After Engineering PASS + integration + Owner-build preparation, Owner must be able to open the same product path and see:

```text
角色
→ not just “24岁 · 现代穿越者” + one short sentence
→ materially useful Character Sheet comparable in information value to the accepted MW-011 profile
→ but reorganized according to the new Character ownership boundary
→ no starting possessions in Character
```

Only Owner can declare Product PASS.

## 12. Git / UAT handoff

Follow repository `AGENTS.md` worktree rules.

Do not modify or install an unreviewed candidate into `D:/AI/Projects/my-world` as the Owner build.

Return exact candidate SHA, changed files, root-cause implementation choice, evidence for starting baseline/current curation coexistence, regression/export results, and clean status.

After GPT Engineering PASS and integration, the canonical local checkout + fresh export handoff is a separate required step before Owner UAT.
