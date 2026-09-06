# TASK｜MW-015 R2｜Model-driven Initial Character Curation Correction

Type: G6 product-correction implementation task  
Work Item: **MW-015**  
Revision: **2**  
Review-Round: **0**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Status: **READY FOR CODEX**  
Task Branch: `mw-015-r2-model-driven-initial-character-curation`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-015-r2`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Repair the Owner-UAT product regression introduced by MW-015 R1 without reverting the accepted left/right information architecture and without moving semantic classification back into Program logic.

Required user-visible result:

```text
left Player Status Host
→ remains collapsed/hidden when no portrait/live mechanic contribution exists

right 角色 Surface
→ materially rich current Character Sheet
→ useful immediately at the beginning of a Game / before the first lived-turn curation
→ continues to evolve after successful lived curator updates
```

The correction must preserve the frozen authority rule:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

The model — not Program title matching, field whitelists, profile-group mapping or per-domain heuristics — decides which starting facts belong in Character and how they should be summarized for the Character Surface.

## 2. Why now

MW-015 R1 is **Owner UAT NOT PASS**.

Observed product defect:

```text
Owner opens the real integrated Game
→ left transitional biography is correctly gone
→ right 角色 only shows headline + summary
→ previously useful background / personality / capability / limitation / goals / principles information is effectively lost
```

This is not an argument to restore the old left panel. It proves that the initial information-c​​uration path is too thin.

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

## 3. Root cause / architecture correction

MW-014 established a post-turn model curator, but the pre-curation Character fallback used by MW-015 R1 is intentionally thin. R1 then removed the old rich left profile, exposing a product gap: the Game has rich frozen starting protagonist material, but no model-curated initial Character state has yet converted that material into the current Character Surface.

Do **not** solve this by teaching Program which authored profile groups are "Character" versus "Inventory".

Correct authority flow:

```text
Game-local frozen starting player-facing protagonist material
+ concise enabled Surface semantics
+ only relevant player-safe Game-local context
↓
Information Curator model
↓
model decides what belongs in current Character and how to summarize it
↓
bounded structured Character curation result
↓
Program normalization + durable currentness
↓
right 角色 Surface
```

This is the same semantic authority already frozen for lived turns, extended to the initial information state.

## 4. Initial curation placement

Atomic Final Create remains Provider-free. **Do not add a Provider call inside Final Create.**

Implement the narrowest safe initial-c​​uration trigger after a Game can be opened/activated and before the player is expected to rely on the Character Surface.

Acceptable placement is a bounded post-create / Game-activation initialization lane using the existing Information Curator infrastructure, provided it is:

- non-blocking to core Game opening/Narrative availability;
- idempotent;
- durable once successful;
- bound to the correct Game/current Timeline baseline;
- retryable/fail-soft;
- free of Source-current lookup;
- not repeated on every render/reopen once a valid current initial/lived curation exists.

Existing Games that already contain frozen Game-local starting profile material must be eligible for this initialization without recreating the Game.

If the existing MW-014 curation model cannot represent an initial baseline cleanly without an authority/schema change, STOP and return the exact architecture gap before implementing a parallel classifier.

## 5. Model input boundary

Initial curation may use only the smallest useful **Game-local / player-safe** inputs, such as:

- frozen starting `player_profile` / equivalent Game-local player-facing protagonist material;
- current accepted opening/current Narrative when useful and already player-visible;
- current curated Character material if any;
- concise Character Surface semantics;
- other current player-visible/protagonist-owned context strictly needed for meaning.

Do not pass:

- Source Library current;
- raw Character `semantic_sections` / GM-private/reference prose not already in the frozen player-facing projection;
- omniscient `world_state` merely because it is available;
- NPC-private Knowledge / Agency plan / hidden Evolution material.

Old Games remain pinned to their own frozen Game-local material.

## 6. Model owns starting information selection

The curator should be told the frozen product semantics for Character:

```text
角色 / Character
→ "现在的我是谁"
→ current protagonist state
→ not a mutation log
```

The model may represent current information such as identity/background, current social identity/role, personality/values/principles, non-numeric capabilities, long-term limitations/traits and long-term goals/self-direction when supported by the actual starting material.

The model must also understand that Character is not the owner of possessions/equipment, numeric mechanic status, relationship truth, open tasks/clues, NPC-private information or omniscient world truth.

These are **prompt/domain semantics for the model**, not Program-side semantic routing rules.

Program must not:

- match titles/keywords such as `物品`, `装备`, `性格`, `目标`;
- maintain a field/group whitelist that semantically classifies authored prose;
- special-case Zhang Chen or any named character;
- parse Narrative to infer Character itself;
- score importance or decide which profile facts are worth showing.

Program may only validate the bounded structured result and write it to the existing Character currentness owner.

## 7. Baseline + lived curation semantics

Required lifecycle:

```text
no valid current Character curation yet
→ model-driven initial curation from frozen Game-local starting material
→ durable current Character state

later accepted lived Turn
→ normal MW-014 model curator evaluates current Character again
→ replace/update/remove according to model semantic authority
```

Must prove:

- initial Character information is useful before the first player-authored lived Turn;
- later lived curation does not duplicate a second baseline copy;
- the model can change/remove current Character information later;
- Restore/Regenerate/reopen returns the Character projection matching the current history;
- initialization does not become a render-time Provider call;
- no Source-current backfill occurs.

## 8. Existing Game compatibility

Owner UAT exposed the defect on a real integrated Game. R2 must cover existing Games whenever they already contain the needed frozen player-facing starting material.

Expected path:

```text
open existing compatible Game
→ detect no valid current model-curated Character baseline
→ schedule bounded initial curator
→ successful result becomes durable/current
→ Character Surface refreshes without Game recreation
```

If the old Game lacks the necessary frozen player-facing material, STOP with evidence rather than consulting current Source.

## 9. Left Host remains accepted

Do not restore the MW-011 biography panel on the left.

```text
Player Status Host
→ portrait + real live mechanic/status HUD only
→ hidden/collapsed today if empty
```

The product defect is loss of model-curated information during the IA migration, not the disappearance of the old left column itself.

## 10. Important Experiences scope

Do not invent Important Experiences merely from static starting biography in order to make the page look populated.

R2's required outcome is the initial **Character** information state. Existing Important Experiences semantics remain model-owned and timeline-bound.

If a current accepted opening/event is independently judged by the existing model-curation contract to be a milestone, preserve that existing authority; do not add Program rules either way.

## 11. Engineering acceptance

At minimum prove on the real production path:

1. a fresh Zhang Chen Game obtains a materially rich model-curated Character baseline before the first player-authored lived Turn;
2. an existing compatible Game with frozen starting profile material obtains the same class of useful baseline without recreation or Source-current lookup;
3. the baseline is produced through a real model-curation seam, not Program semantic mapping;
4. model output can include supported background/personality/values/capabilities/limitations/long-term-goal material when semantically appropriate;
5. possessions/equipment and other non-Character semantics are excluded by model curation, not keyword/title filters in Program;
6. left Player Status Host remains collapsed/hidden with no legitimate contribution;
7. later successful lived curator update changes current Character without reopening or duplicated baseline groups;
8. curator failure remains fail-soft/non-blocking and preserves the last valid current projection;
9. Restore/Regenerate/reopen currentness remains correct;
10. no render-time Provider call;
11. no Program keyword/regex/title/field semantic classifier or named-character special case;
12. no Source Library current backfill for existing Games;
13. Atomic Final Create still performs zero Provider calls;
14. player-safe disclosure boundaries remain intact;
15. MW-014, MW-011 privacy, MW-012, G3 Save/Restore, MW-009 safe projection and Narrative critical-path regressions PASS;
16. maximized / 1280x720 / narrow layout remains coherent;
17. `git diff --check` clean;
18. Windows Desktop export PASS.

Also provide at least one real Provider smoke of **initial** Character curation from realistic frozen Zhang Chen starting material, demonstrating that the model returns a useful Character Sheet while omitting possessions from Character without Program heuristics.

## 12. Product acceptance target

After Engineering PASS + integration + Owner-build preparation, Owner opens the real Game and sees:

```text
角色
→ materially useful current Character Sheet immediately
→ information selection/summary reflects model understanding of the frozen protagonist material
→ not just headline + one short sentence
→ no obvious Inventory/private/debug leakage
```

Then after meaningful play, the same Surface evolves through the normal model curator.

Only Owner can declare Product PASS.

## 13. Git / UAT handoff

Follow repository `AGENTS.md` worktree rules.

Do not modify or install an unreviewed candidate into `D:/AI/Projects/my-world` as the Owner build.

Return exact candidate SHA, changed files, selected initial-curation trigger and rationale, exact model input boundary, proof that semantic selection remains model-owned, currentness/retry behavior, regressions/export results, real Provider smoke, and clean status.

After GPT Engineering PASS and integration, the canonical local checkout + fresh export handoff is a separate required step before Owner UAT.
