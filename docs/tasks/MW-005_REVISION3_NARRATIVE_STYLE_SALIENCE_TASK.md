# TASK ADDENDUM｜MW-005 Revision 3｜Narrative Style Salience / Late Style Anchor

Type: implementation / model-context integration / product-effect correction  
Work Item: **MW-005 — Three Kingdoms Literary Style Primer v0.1**  
Revision: **3**  
Review target: **IR#3**  
Triggered-By: **Owner UAT on 2026-09-05 — prose change not perceptible enough after IR#2**  
Implementer: **Zcode + GLM-5.3-flash**（Owner weekend routing override）  
Reviewer: **GPT**  
Formal Code Base before this packet: `my-world/main@61aebf1971d84513953ffe730432e0553d93ede3`  
Governance Base: `Vibe-Coding/main@f02e689151f8ecd2fc8afaded31e553330f402c9`  
Task Branch target: `mw-005-r3-style-salience`  
Required worktree path: `D:/AI/Projects/.worktrees/my-world/mw-005-r3`  
Status: **ACTIVE — ZCODE**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Canonical parent packet remains:

`docs/tasks/MW-005_THREE_KINGDOMS_LITERARY_STYLE_PRIMER_TASK.md`

Prior reviews:

- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR2.md`

Revision-2 correction remains protected:

`docs/tasks/MW-005_REVISION2_CONTROL_LANE_STYLE_EXCLUSION_ADDENDUM.md`

## 1. Why Revision 3 exists

Revision 2 is engineering-correct: the Three Kingdoms literary reference reaches narrative consumers and is excluded from Public-d20 mechanics control and G5-04 causal input.

However Owner UAT found that the **product effect is still too weak to perceive reliably**. The prose can contain period nouns such as 粮秣、豪户、县吏、渡口 while the overall sentence rhythm, explanatory structure and narrative distance remain close to generic modern Chinese RPG / web-fiction prose.

This is a Product Value failure of the same MW-005 outcome, not a new Work Item.

Revision 3 must improve **salience and placement of the already-approved literary reference in narrative requests** without converting style into a rigid output protocol.

## 2. Primary outcome

For a new Three Kingdoms Game using the existing approved Source generation, literary style should become **noticeably but naturally present** in normal GM prose:

- dialogue/register should feel more period-rooted;
- military/political information should enter as scene, messenger/report, question/answer, written dispatch or lived observation when natural, rather than defaulting to modern strategy-dashboard exposition;
- sentence rhythm and narrative distance should shift, not merely vocabulary substitution;
- prose must remain readable and free rather than mechanically imitating chapter-novel formulas.

Engineering cannot self-certify this subjective value. Owner UAT remains the final Product gate.

## 3. Frozen authority boundary

The existing literary reference remains expression-only:

```text
Literary Style Reference
= narrative voice / diction / syntax rhythm / address / etiquette / dialogue form / narrative distance / information-delivery exemplar

!= Game world truth
!= future canon
!= original-novel plot authority
!= NPC destiny
!= Player/actor Knowledge
!= World Evolution causal input
!= Public-d20 control authority
!= semantic-consequence authority
!= mandatory output format
```

Model Freedom First remains protected.

Do **not** add:

- mandatory `却说` / `且说` / poetry / chapter-ending formulas;
- forced semi-classical Chinese;
- a growing blacklist of modern words;
- fixed first-line / heading / JSON / sentinel protocol;
- Narrative parser/classifier/gate/retry;
- style scoring or rejection loop;
- hardcoded prose templates;
- a generic style-policy platform.

## 4. Source / content constraint for Revision 3

Revision 3 deliberately isolates **runtime salience** before changing source content.

Therefore:

- keep the approved Primer bytes unchanged;
- keep `docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt` unchanged;
- keep the World section bytes unchanged;
- keep Source generation unchanged:
  `58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`;
- **do not republish Source**;
- do not import/commit the EPUB/full novel/editorial material.

If a materially stronger content payload proves necessary, STOP and return evidence. Do not silently create Primer v0.2 inside Revision 3.

## 5. Read First

1. `AGENTS.md`
2. `Vibe-Coding/AGENTS.md`
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
4. this Revision-3 packet
5. `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR2.md`
6. `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`
7. `src/首次开场/L2_流程层/首次开场运行流程.gd`
8. `src/context/上下文组装器.gd`
9. `src/行动判定/L2_流程层/公开D20行动判定流程.gd`

Expand only when actual production tracing requires it; record why.

## 6. Mandatory worktree hygiene before coding

Owner explicitly requested cleanup of task worktrees scattered under `D:/AI/Projects` and a permanent location rule for future Agent work.

Before creating the Revision-3 worktree:

1. From `D:/AI/Projects/my-world`, run `git worktree list --porcelain`.
2. Inspect status/branch/remote state for known old task directories, including when present:
   - `D:/AI/Projects/my-world-mw006`
   - `D:/AI/Projects/my-world-baseline`
   - `D:/AI/Projects/my-world-mw007`
3. Remove a registered worktree **only** when all are true:
   - task is closed/reviewed;
   - worktree is clean;
   - all unique commits are pushed/reachable remotely or already integrated;
   - it contains no unknown user work.
4. Use `git worktree remove <path>`; do not manually delete a registered worktree directory.
5. Run `git worktree prune` after safe removals.
6. If `my-world-baseline` is an ordinary clone/copy rather than a registered worktree, do not delete it merely by name. Inspect `status`, branch, remote and unique commits; report it if safety is uncertain.
7. **All new task worktrees must live under:**

```text
D:/AI/Projects/.worktrees/my-world/<task-or-revision>
```

For this task use exactly:

```text
D:/AI/Projects/.worktrees/my-world/mw-005-r3
```

Do not create `D:/AI/Projects/my-world-*` task directories again.

At handoff report what was removed, what was retained and why. Keep the active Revision-3 worktree until GPT IR#3 unless explicitly instructed otherwise.

## 7. Two-pass audit before implementation

### Pass A — actual request placement / dilution audit

Using a **new frozen Three Kingdoms Game** carrying the approved generation, capture actual assembled requests for:

- first opening;
- ordinary continuation with at least one materialized World Turn record;
- Public d20 `control`;
- Public d20 `control_recovery`;
- `no_check_narrative`;
- `resolution_narrative`;
- `degraded_narrative`.

For each relevant system message record:

- total system-content character count;
- position/range of `## Literary Style Reference`;
- characters after the literary block before end of system content;
- whether Player/NPC/factual World material appears after it;
- whether materialized World Turn text appears after it;
- whether mechanics rules/authority text appears after it;
- whether the Primer appears once, more than once, or not at all.

Do not infer salience merely from `contains(marker)`.

### Pass B — positive steering audit

Inspect the current global GM instructions, literary boundary text and Primer itself.

Determine whether the current request gives the model a strong enough **positive expression target**, as distinct from the many negative authority disclaimers.

The correction should prefer a small explicit narrative-only steering cue over larger prompts. The cue may tell the model that, when a Literary Style Reference exists, it is the default voice anchor for Chinese Narrative and should influence sentence rhythm, address/etiquette, information delivery and narrative distance while remaining readable and non-formulaic.

One concrete known failure shape may be named: defaulting to modern strategy-dashboard / consulting-report style summaries for military-political information. Do not turn this into a growing blacklist.

## 8. Frozen implementation direction

Revision 3 must make the literary reference a **single, late, narrative-only style anchor** rather than merely one semantic section buried among factual context.

Required semantics:

```text
Factual Game/World/Character/World-Turn context
→ remains factual context

Literary Style Reference
→ derived request-only expression material
→ appears exactly once in narrative requests
→ placed late enough to remain salient to the narrative generation
→ carries a concise positive style cue
```

Choose the smallest explicit seam. A likely shape is to separate factual projected context from derived style-reference text and let narrative consumers append the style anchor at the end of their narrative-context construction. This is a direction, not a mandate to create a generic policy abstraction.

The final consumer matrix remains:

```text
first opening                           INCLUDE late style anchor
ordinary continuation GM narrative     INCLUDE late style anchor
Public d20 resolution narrative        INCLUDE late style anchor
Public d20 NO_CHECK narrative          INCLUDE late style anchor
Public d20 degraded narrative          INCLUDE late style anchor

Public d20 control                      EXCLUDE all style material/cue
Public d20 control_recovery             EXCLUDE all style material/cue
G5-04 project_world_only()              EXCLUDE all style material/cue
G5-01 semantic analysis                 EXCLUDE as mechanics/causal authority
Actor Knowledge                         EXCLUDE as knowledge authority
```

Do not duplicate the full Primer in two places just to create salience.

## 9. Required focused proof

Add/extend task-owned tests to capture **actual final request messages**, not only projector return values.

At minimum prove:

1. **ordinary continuation** with a committed materialized World Turn contains the Primer exactly once and the narrative style anchor occurs after factual World/Character + materialized World Turn request material;
2. **first opening** contains the Primer exactly once under the non-factual literary boundary and receives the concise positive style cue;
3. `resolution_narrative`, `no_check_narrative`, and `degraded_narrative` each contain the Primer exactly once as narrative-only style material;
4. `control` and `control_recovery` contain neither Primer content, `literary_style_reference`, literary boundary, nor the new positive style cue;
5. G5-04 world-only projection still excludes all style material;
6. Primer bytes and Source generation fingerprint are unchanged;
7. no extra Narrative output gate/retry/parser/classifier exists;
8. MW-006 mechanics grounding still passes;
9. MW-007 timeline continuity focused proof still passes after rebasing/integration;
10. directly affected first-opening/Public-d20/MW-005 regressions remain green;
11. `git diff --check` clean;
12. Windows export validation passes if production GDScript changes;
13. real Provider calls may remain 0 for Engineering Acceptance. A bounded diagnostic real-provider A/B may be run only if current credentials/provider are already safely available; it is supplementary and cannot substitute for Owner UAT.

## 10. Product Value Acceptance

Engineering PASS only proves that the style signal is correctly and safely delivered.

Owner UAT must use a **new** Three Kingdoms Game and judge whether the prose now changes perceptibly while staying natural.

PASS signal:

- the difference is visible without inspecting prompts;
- not just period nouns—the syntax rhythm, social register, dialogue form and narrative distance feel more rooted;
- remote information is more often dramatized or delivered diegetically when appropriate instead of defaulting to a strategy dashboard;
- prose remains readable;
- no mechanical chapter-novel tics;
- no future-plot leakage;
- Player Agency remains intact.

If Owner still cannot perceive a meaningful difference, do not claim success. The next correction should revisit the Primer content itself rather than endlessly adding prompt weight.

## 11. Explicit non-scope

Do not fix in this Revision:

- literal Markdown rendering such as `**张飞**` / `---` visible in the UI — that is a separate presentation outcome and must receive its own flat Work Item;
- G5-06 UI projection;
- MW-007 mechanics/timeline semantics;
- Public-d20 mechanics design;
- world-evolution scheduling;
- Player Agency design;
- source schema/version;
- long-context retrieval/summarization platform.

## 12. Stop Conditions

STOP and report instead of broadening if the correction appears to require:

- changing Primer/source bytes or publishing a new Source generation;
- a generic style framework/policy engine;
- a Narrative quality classifier/gate/retry loop;
- Source schema changes;
- changes to mechanics authority;
- changes to G5-04 causal input;
- a second copy/store of style truth.

## 13. Git / return contract

- Start from fresh latest `main` after MW-007 IR integration.
- Use branch `mw-005-r3-style-salience` in the required `.worktrees` path.
- Before final push, fetch latest `main`, reconcile non-destructively and rerun focused regressions.
- Push exact commits.

Return:

- implementation SHA;
- evidence SHA;
- remote branch;
- actual base/final head;
- active worktree path;
- worktree-cleanup report;
- changed files;
- Pass A request-placement measurements;
- Pass B steering audit;
- exact final style-anchor ordering for every consumer stage;
- proof Primer appears exactly once in narrative requests;
- control/control_recovery exclusion proof;
- Source fingerprint/bytes unchanged proof;
- regression commands/results;
- export result if applicable;
- real Provider call count;
- remaining risks.

Return ceiling:

`READY FOR INDEPENDENT REVIEW`

Only GPT may issue Engineering PASS. Only Owner may issue Product PASS / CLOSED.
