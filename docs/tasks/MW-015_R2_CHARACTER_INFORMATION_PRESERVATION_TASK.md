# TASK｜MW-015 R2｜Model-driven Initial Character Curation Correction

Type: G6 product-correction implementation task  
Work Item: **MW-015**  
Revision: **2**  
Review-Round: **0**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Status: **READY FOR CODEX — ARCHITECTURE GAP RESOLVED**  
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
→ useful immediately at Game activation, without requiring a new player-authored Turn
→ does not depend on GM opening success
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

This is not an argument to restore the old left panel. It proves that the initial information-curation path is too thin.

Read first:

1. `AGENTS.md`
2. `docs/mw015/MW-015_OWNER_UAT_R1_RESULT.md`
3. `docs/mw015/r2/MW-015_R2_INITIAL_CURATION_ARCHITECTURE_GAP.md` from pushed evidence `cbe0f12c411f046cc17318fd1be856dcd2c13e43`
4. `docs/tasks/MW-015_CHARACTER_AND_IMPORTANT_EXPERIENCES_UI_V0_1_TASK.md`
5. `docs/tasks/MW-014_MODEL_DRIVEN_CHARACTER_AND_MILESTONE_CURATION_V0_1_TASK.md`
6. `docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`
7. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
8. `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
9. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
10. `Vibe-Coding/my world/architecture/ui/G6_INITIAL_CHARACTER_CURATION_BASELINE_V1_0_DECISION.md`

Refresh both repository mains before implementation. If newer current authority conflicts with this packet, STOP and report.

## 3. Root cause / architecture correction

MW-014 established a post-turn model curator, but the pre-curation Character fallback used by MW-015 R1 is intentionally thin. R1 then removed the old rich left profile, exposing a product gap: the Game has rich frozen starting protagonist material, but no model-curated initial Character state has yet converted that material into the current Character Surface.

Do **not** solve this by teaching Program which authored profile groups are "Character" versus "Inventory".

Correct authority flow:

```text
Game-local frozen starting player-facing protagonist material
+ concise Character Surface semantics
↓
Information Curator model
↓
model decides what belongs in current Character and how to summarize it
↓
bounded structured Character curation result
↓
Program normalization + durable Game/T0 baseline currentness
↓
right 角色 Surface
```

This is the same semantic authority already frozen for lived turns, extended to the initial information state.

## 4. Architecture decision — APPROVED

The architecture gap reported at `cbe0f12c411f046cc17318fd1be856dcd2c13e43` is resolved by:

`Vibe-Coding/my world/architecture/ui/G6_INITIAL_CHARACTER_CURATION_BASELINE_V1_0_DECISION.md`

Mandatory decision:

> **Initial Character curation is Game/T0-scoped information baseline, not a synthetic Conversation Turn and not dependent on accepted GM opening.**

Atomic Final Create remains Provider-free. **Do not add a Provider call inside Final Create.**

Reuse the existing `information_curation` owner and existing World/Timeline durable mutation machinery. A narrow backward-compatible schema evolution is authorized to represent an optional Program-owned initial record, e.g.:

```text
information_curation
→ schema
→ optional initial
→ turns
```

No new SQLite table is authorized.

Required storage semantics:

- existing `{schema, turns}` data remains readable;
- old Games without an initial record remain valid and eligible for initialization;
- initial record identity/binding is Program-owned and based on normalized frozen Game-local player-safe starting material;
- model does not mint final IDs/hashes;
- initial record is not bound to accepted Player/GM prefix hashes;
- adding initial must not invalidate or rewrite existing turn record IDs/parent chains;
- no Source-current lookup/backfill.

Do not fabricate accepted Turn 0, negative indices or synthetic Conversation entries.

## 5. Initial curation trigger / input boundary

Implement the narrowest safe post-create / Game-activation initialization lane using existing Provider/Information Curator infrastructure.

Trigger requirements:

- eligible once the Game/runtime can be safely activated;
- independent of opening success/cancel/failure;
- may wait for Provider availability, but must not semantically depend on opening;
- non-blocking to core Game opening/Narrative path;
- idempotent;
- durable once successful;
- retryable/fail-soft;
- not repeated on every render/reopen once a valid baseline exists;
- existing Games with frozen Game-local starting profile material are eligible without recreation.

Initial curation input is deliberately T0/Game-local and should not race with opening semantics. Use only the smallest useful player-safe material, such as:

- frozen starting `player_profile` / equivalent Game-local player-facing protagonist material;
- concise Character Surface semantics;
- only other frozen player-safe protagonist/T0 material strictly required to interpret that profile.

Do **not** require or consume opening Narrative as the authority for this baseline.

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

Program may validate the bounded structured result, its allowed Character output vocabulary and machine-level size/type constraints, then persist it.

## 7. Baseline + lived curation semantics

Required projection/lifecycle:

```text
thin frozen safe fallback
↓
valid model-curated Initial Character Baseline, when present
↓
current valid lived turn curation records in existing causal order
```

The initial baseline must **not** become the parent of MW-014 turn records if that would invalidate historical turn identities.

Later lived Character snapshots remain authoritative over the initial baseline when they provide a current Character result. A later turn result with `character = null` means the previous current Character remains.

Must prove:

- initial Character information is useful before the first player-authored lived Turn;
- later lived curation does not duplicate a second baseline copy;
- the model can change/remove current Character information later;
- existing turn record IDs/parent linkage remain valid;
- initialization does not become a render-time Provider call;
- no Source-current backfill occurs.

## 8. Restore / Regenerate / reopen currentness

Initial baseline validity is **Game/T0-bound**, not accepted-history-bound.

Therefore:

- Regenerate of later Narrative does not semantically invalidate a valid initial baseline;
- Restore must still remove/revert lived turn curation according to restored accepted history;
- Restore must never import displaced-future lived Character or milestones;
- if a restored snapshot lacks initial but the same frozen starting-material binding still applies, Runtime may safely preserve/re-attach/re-materialize the same valid Game/T0 baseline because it contains no future lived information;
- avoid repeated Provider calls when a valid baseline result for the same frozen binding is already durably available;
- if no valid baseline result exists, bounded initial curation may run again;
- reopen with a valid baseline requires no Provider call.

Implementation must prove that this special baseline behavior cannot leak displaced-future turn curation.

## 9. Existing Game compatibility

Owner UAT exposed the defect on a real integrated Game. R2 must cover existing Games whenever they already contain the needed frozen player-facing starting material.

Expected path:

```text
open existing compatible Game
→ no valid initial baseline
→ bounded initial curator from that Game's own frozen material
→ successful result becomes durable/current
→ Character Surface refreshes
```

If the old Game lacks the necessary frozen player-facing material, STOP with evidence rather than consulting current Source.

## 10. Left Host remains accepted

Do not restore the MW-011 biography panel on the left.

```text
Player Status Host
→ portrait + real live mechanic/status HUD only
→ hidden/collapsed today if empty
```

The product defect is loss of model-curated information during the IA migration, not the disappearance of the old left column itself.

## 11. Important Experiences scope

Initial baseline must not create Important Experiences from static biography.

There is no accepted lived event at T0 initialization. Persist Character baseline only; initial milestone additions are invalid for this lifecycle lane.

This is a causality/lifecycle constraint, not Program judging event importance.

Normal Important Experiences remain model-owned and turn/timeline-bound through the existing lived curation flow.

## 12. Engineering acceptance

At minimum prove on the real production path:

1. a fresh Zhang Chen Game obtains a materially rich model-curated Character baseline before the first player-authored lived Turn;
2. this baseline does not require successful accepted GM opening;
3. an existing compatible Game with frozen starting profile material obtains the same class of useful baseline without recreation or Source-current lookup;
4. the baseline is produced through a real model-curation seam, not Program semantic mapping;
5. model output can include supported background/personality/values/capabilities/limitations/long-term-goal material when semantically appropriate;
6. possessions/equipment and other non-Character semantics are excluded by model curation, not keyword/title filters in Program;
7. initial record is Program-bound to normalized frozen Game-local starting material;
8. old `{schema, turns}` curation data remains readable and can evolve to the new representation without losing turn records;
9. existing turn curation IDs/parent chains remain valid when an initial baseline is added;
10. left Player Status Host remains collapsed/hidden with no legitimate contribution;
11. later successful lived curator update changes current Character without reopening or duplicated baseline groups;
12. curator failure remains fail-soft/non-blocking and preserves the last valid current projection;
13. Restore/Regenerate/reopen currentness follows §8 and leaks no future lived information;
14. no render-time Provider call;
15. no Program keyword/regex/title/field semantic classifier or named-character special case;
16. no Source Library current backfill for existing Games;
17. Atomic Final Create still performs zero Provider calls;
18. player-safe disclosure boundaries remain intact;
19. no new SQLite table;
20. MW-014, MW-011 privacy, MW-012, G3 Save/Restore, MW-009 safe projection and Narrative critical-path regressions PASS;
21. maximized / 1280x720 / narrow layout remains coherent;
22. `git diff --check` clean;
23. Windows Desktop export PASS.

Also provide at least one real Provider smoke of **initial** Character curation from realistic frozen Zhang Chen starting material, demonstrating that the model returns a useful Character Sheet while omitting possessions from Character without Program heuristics.

## 13. Product acceptance target

After Engineering PASS + integration + Owner-build preparation, Owner opens the real Game and sees:

```text
角色
→ materially useful current Character Sheet immediately
→ does not require first taking a new action
→ does not disappear merely because opening failed
→ information selection/summary reflects model understanding of frozen protagonist material
→ not just headline + one short sentence
→ no obvious Inventory/private/debug leakage
```

Then after meaningful play, the same Surface evolves through the normal model curator.

Only Owner can declare Product PASS.

## 14. Git / UAT handoff

Follow repository `AGENTS.md` worktree rules.

Continue the existing MW-015 R2 branch/worktree after refreshing both mains and reading the new architecture decision. The prior gap-report commit is evidence, not the implementation candidate.

Do not modify or install an unreviewed candidate into `D:/AI/Projects/my-world` as the Owner build.

Return exact candidate SHA, changed files, initial owner/schema evolution, initial binding/identity, selected activation trigger, proof opening independence, exact model input boundary, proof semantic selection remains model-owned, backward compatibility, turn-chain preservation, currentness/retry behavior, regressions/export results, real Provider smoke, and clean status.

After GPT Engineering PASS and integration, the canonical local checkout + fresh export handoff is a separate required step before Owner UAT.
