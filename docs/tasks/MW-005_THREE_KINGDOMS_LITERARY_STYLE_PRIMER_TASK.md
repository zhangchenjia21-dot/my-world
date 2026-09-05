# TASK｜MW-005｜Three Kingdoms Literary Style Primer v0.1

Type: implementation / source-content integration / product A-B validation  
Owner: Kimi  
Reviewer: GPT  
Capability-Anchor: **G4 Primary Source Assets & Local Game**  
Inserted-By: **Owner**  
Triggered-By: **G5-04 Owner UAT prose-quality observation: Three Kingdoms narrative drifted into modern strategic briefing voice**  
Blocks: **resume of G5-04 Owner UAT prose judgment until one A/B check is available**  
Revision: **1**  
Review-Round: **0**  
Implementation Base: `my-world/main@63262dfe52d9200115544bb0a1f2507795039e33`  
Governance Base: `Vibe-Coding/main@a900d8ec4a4b446b28bf68135c48b81c96c5da61`  
Status: **ACTIVE — KIMI**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Why this task exists

Owner UAT found that Three Kingdoms world facts and world evolution can be plausible while the GM prose still feels wrong for the setting. A representative failure shape is a modern strategy/briefing structure such as multiple regional headings followed by analytical summaries.

The Owner chose a deliberately model-friendly correction: provide a small literary exemplar set derived from *Romance of the Three Kingdoms* so the model can absorb diction, syntax rhythm, address/etiquette, dialogue form, narrative distance and historical-social register without adding a long negative prompt or forcing a chapter-novel template.

This is a distinct content/runtime integration outcome. It is **not** a G5-04 mechanism defect, does not reopen G4, and does not authorize G5-05.

## 2. Primary outcome

For **newly created games using the current Three Kingdoms World Pack generation**, normal GM Narrative should receive a bounded Three-Kingdoms-specific literary style reference that helps prose feel more naturally rooted in the setting.

The intended experience is:

> **The world remains model-authored and free, but its voice has better historical/literary grounding.**

The Primer should help especially with:

- strategist/counsellor dialogue;
- court and diplomatic register;
- ordinary private conversation between historical figures;
- military and political developments entering the scene as narrative rather than a status dashboard;
- town/civilian/social-state narration;
- war movement and intelligence reports.

## 3. Frozen semantic boundary

The Style Primer is **reference material for expression only**.

```text
Literary Style Reference
= diction / syntax rhythm / address / etiquette / dialogue form / narrative distance / historical-social register exemplar

!= current Game world truth
!= future canon
!= original-novel plot authority
!= NPC destiny constraint
!= Player or actor Knowledge
!= World Evolution causal input
!= mandatory chapter-novel format
```

The model may naturally absorb the examples. It must **not** be told to mechanically imitate `却说` / `且说`, force half-classical Chinese, copy fixed formulas, or obey a fixed output structure.

Do not solve this task by adding a growing blacklist of modern words or a long style command list.

## 4. Canonical Primer input

Use exactly the Owner/GPT-approved input file committed with this packet:

`docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt`

This is the v0.1 A/B payload. Do not enlarge or rewrite it during implementation unless a concrete source-contract requirement makes a mechanical formatting adjustment necessary. If semantic content needs changing, stop and return to GPT/Owner rather than silently editing the prose.

The user's uploaded EPUB is **not** implementation input for the Agent and must not be copied into the repository or production Source Library. Do not add the raw EPUB, publisher foreword, notes, editorial material, or the full novel.

## 5. Current architecture facts to preserve

Current Source architecture already supports `world_pack.v0.2` with `semantic_sections`. The current loader accepts any safe-token `section_type`; a schema-version bump is therefore **not required merely to carry this reference**.

Relevant current seams:

- `src/source/L0_公理层/Source合同规则.gd`
- `src/source/L2_流程层/世界包加载流程.gd`
- `src/source/L2_流程层/Source库发布流程.gd`
- `src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd`

Important existing behavior:

- Source Library publishes immutable exact generations and moves `current` to the new generation;
- new Games freeze the selected Source generation into Game-local setup/projection;
- existing Games must not silently read mutable Source `current`;
- ordinary/opening GM context currently projects frozen World semantic material;
- **G5-04 `project_world_only()` currently shares World projection logic and must not receive literary style material as causal World authority.**

## 6. Required implementation shape

### 6.1 First do a two-pass path / consumer audit

Before editing, identify:

1. the actual authoring/source package used to publish the currently installed Three Kingdoms World Pack and its stable `asset_id`;
2. every production consumer of World `semantic_sections` / frozen `source_projection` that could treat a new section as factual/causal material.

Record the findings in evidence. Do not guess package paths or hardcode from chat.

### 6.2 Carry the Primer through the existing World Pack contract

Preferred minimal shape, unless the audit proves an equivalent smaller safe seam:

- add one World `semantic_section` to the Three Kingdoms `world_pack.v0.2` authoring package;
- use `section_type: "literary_style_reference"`;
- use `disclosure: "gm_reference"`;
- content is the exact committed Primer input;
- keep it in the Source generation fingerprint like other contract-owned semantic bytes;
- publish/install it through the existing Source Library publication path, producing a **new exact generation** and making that generation current for future game creation.

Do **not** mutate an existing managed generation in place.

### 6.3 Normal GM Narrative is the first/only v0.1 consumer

In the frozen Game-local context used for:

- first opening; and
- ordinary GM Narrative turns,

present the style section under a clearly non-factual literary reference boundary.

Preferred projection shape:

```text
World factual / semantic authority
...

## Literary Style Reference
<small authority notice>
<Primer>
```

Do not leave the Primer visually/semantically indistinguishable from ordinary World factual sections if a small projector separation can prevent that ambiguity.

### 6.4 Hard exclusion from causal / cognition consumers

At minimum, prove that `section_type == "literary_style_reference"` is absent from:

- `project_world_only()` used by G5-04 World Evolution;
- any semantic materialization input that interprets World semantic sections as current facts, if such a consumer exists;
- Knowledge Provenance inputs/targets as factual material;
- Agency actor-private material unless current architecture already has an explicitly style-only non-cognitive seam and using it is strictly necessary (v0.1 should normally **not** add this);
- Player knowledge;
- durable world mutations/events.

Do not build a generic ontology/platform to achieve this. A small explicit filter/classification at the correct projection seam is preferred.

### 6.5 Frozen-generation behavior

Required:

```text
old Game created before MW-005
→ keeps its already-frozen old World generation / no silent style injection

new Game created after the new Three Kingdoms generation is current
→ freezes the new generation including style reference
→ normal GM context sees it
```

No runtime read of mutable `SourceLibrary.current` from an opened existing Game.

## 7. Explicit non-scope

Do **not** implement any of the following:

- full *Romance of the Three Kingdoms* corpus in Runtime;
- EPUB ingestion;
- retrieval / embeddings / vector DB / semantic search / RAG;
- G7 context platform;
- new universal Style Pack schema/platform;
- Source schema v0.3 unless the two-pass audit proves the existing semantic-section carrier is impossible (stop for review first);
- SQLite migration/table;
- style settings UI;
- user-selectable writing styles;
- generic style engine for all Worlds;
- mandatory `却说` / `且说` / poetry / chapter headings;
- negative word blacklist;
- Narrative parser/classifier/rejection/finalize gate;
- changes to MW-004 Player Agency semantics;
- changes to G5-04 scheduling/priority/event semantics;
- changes to G5-03 Agency scheduling;
- Public-d20 changes;
- Faction/Quest/Thread platform work.

## 8. Content integrity rules

- Commit only the bounded derived Primer input already supplied with this task.
- Do not commit the uploaded EPUB or full-book text.
- Do not silently restore specific original-novel people/places/outcomes into neutralized exemplars.
- Square-bracket role placeholders are exemplar de-identification devices, not an output format for the GM.
- The authority note must explicitly say the examples do not define current Game facts or future.

## 9. Focused automated proof

Add the smallest focused tests necessary to prove the architecture rather than prose taste.

At minimum prove:

1. `world_pack.v0.2` accepts/preserves a `literary_style_reference` semantic section and its bytes affect generation fingerprint;
2. a new Game/frozen setup can contain the section without consulting Source current later;
3. normal Game-local GM context includes the Primer once under a clear literary-reference boundary;
4. first-opening context includes it through the same frozen Game-local authority path;
5. `project_world_only()` excludes the Primer completely;
6. an old frozen Game fixture without the section remains unchanged when Source current advances;
7. no Narrative output protocol/gate was added;
8. existing directly affected Source loading/publication and first-opening/context tests remain green.

Do not assert prose quality from automated tests.

## 10. Minimal regression set

Run only directly affected coverage plus compile/static hygiene. At minimum:

- Source World Pack v0.2 load/projection tests;
- Source Library publication/current/exact generation tests;
- Game-local setup/freeze tests used by final create;
- first-opening context projection tests;
- G2-05/context assembly path as affected;
- G5-04 world-only baseline/evaluator context test proving no style leakage;
- `git diff --check`;
- Windows export validation if production GDScript changed in a way that enters export.

Do not run the entire G5 matrix unless a concrete failure requires it.

Real Provider calls are not required for engineering evidence.

## 11. Product A/B UAT handoff

After engineering review, Owner will create a **new** Three Kingdoms game via `run-game.cmd` and compare against prior experience.

Success signals:

- counsellors and officials sound more naturally situated in the setting without all becoming ornate rhetoricians;
- remote political/military developments enter through scene, messenger, report, question/answer or narrative flow rather than repeated `XX方向：` dashboard headings;
- battle/administrative narration feels less like a modern strategy-game briefing;
- prose remains clear and playable, not forced into dense semi-classical Chinese;
- `却说` / `且说` / chapter-novel formulas do not become mechanical tics;
- no future plot from the novel appears merely because it existed in the Primer;
- Player Agency principle from MW-004 remains intact.

This is an A/B product experiment. If the style becomes overfit, the first correction is to **reduce/adjust exemplars**, not add more negative prompt constraints.

## 12. Evidence / return contract

Return with:

- implementation commit SHA;
- evidence commit SHA;
- exact Three Kingdoms `asset_id` and previous/new generation fingerprints;
- authoring package path used for publication (path only; no secrets);
- changed-file list;
- two-pass consumer audit result;
- proof old Game remains frozen;
- proof new Game receives the reference;
- proof `project_world_only()` does not contain the Primer or `literary_style_reference`;
- focused/regression test commands and PASS/FAIL counts;
- export validation result if applicable;
- real Provider call count;
- any remaining risk.

Kimi may return at most:

`READY FOR INDEPENDENT REVIEW`

Do not self-certify Engineering PASS or Product PASS.
