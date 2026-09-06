# TASK｜MW-014｜Model-driven Character + Important Experiences Curation v0.1

Type: G6 executable backend / runtime implementation task  
Work Item: **MW-014**  
Name: **Model-driven Character + Important Experiences Curation v0.1**  
Capability-Anchor: **G6 RPG Experience / Real Information Surfaces**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Revision: **1**  
Review-Round: **0**  
Status: **READY FOR CODEX**  
Task Branch: `mw-014-model-driven-information-curator-v01`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-014`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Implementation main at task shaping: `d78d615435b16801708c9e40137cb6376e48815d`  
Governance authority at task shaping includes commit: `cbab4ed354d10e92c368d70bfb90b7094beb7320`

## 1. Product / architecture authority

Refresh latest `main` of both repositories before coding.

Read before implementation:

- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_SESSION_SHELL_INFORMATION_OWNERSHIP_DECISION.md`
- `Vibe-Coding/my world/architecture/source/G4_GAME_LOCAL_EVOLVABLE_SEMANTICS_DECISION.md`
- `Vibe-Coding/my world/architecture/world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`
- `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
- `docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`

If current main conflicts with this packet, STOP and report rather than overwriting newer work.

## 2. Why this task exists

Current implementation can safely render frozen `player_character.source_projection.player_profile`, but that only answers what the protagonist was at Game creation.

G6 now requires:

```text
Character
→ current evolving protagonist information
→ “现在的我是谁”

Important Experiences
→ selected protagonist milestone history
→ “我是怎样走到现在的”
```

Owner explicitly rejects Program-heavy semantic classifiers for this problem.

Frozen rule:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

The backend therefore must not implement an importance score engine, keyword router, protagonist-choice heuristic or per-event semantic rule forest.

## 3. Required outcome

Implement the smallest real vertical:

```text
accepted Player input
+ accepted GM Narrative
+ bounded current protagonist information
+ bounded recent Important Experiences
+ only relevant player-visible / protagonist-owned current context
+ concise Character / Important Experiences surface semantics
↓
Post-turn Information Curator model call
↓
bounded structured curation result
↓
Program shape normalization + current-turn binding
↓
durable current Character material
+ durable protagonist milestone material
↓
Save / Restore / Regenerate / reopen currentness
↓
player-safe Character projection
+ player-safe Important Experiences projection
```

This task stops at the safe backend/projection seam. It does **not** implement the final Character / Important Experiences Godot Surface UI.

## 4. Model semantic authority — mandatory

The curator model must directly decide, from accepted game context:

- whether this Turn caused a long-term Character change;
- which current Character information should be added, replaced, removed or kept;
- whether the Turn produced an Important Experience;
- whether accepted interaction already represents a meaningful protagonist goal/value/identity/direction change;
- how to summarize current Character information and milestones for player presentation.

Program must not second-guess these open semantic decisions using heuristic content logic.

Forbidden implementation patterns:

```text
keyword / regex semantic routing
importance numeric score tables
per-event-type semantic if/else forest
“promotion/marriage/battle/etc.” hard-coded milestone rules
N-turn / N-day thresholds deciding whether something is long-term
Program parsing Narrative to infer personality/identity
Program protagonist-choice evidence classifier
```

Machine-level schema/type/size checks remain required.

## 5. Curator call placement / foreground behavior

Curator is post-turn background semantic maintenance.

Required behavior:

```text
accepted Narrative
→ remains immediately accepted / playable

Curator call
→ may run after acceptance
→ updates information state when successful
```

Curator failure / timeout / malformed output:

- must not invalidate the accepted Narrative;
- must not roll back the accepted Player/GM Turn;
- must not block the next Player action by default;
- must fail soft and remain retry/repair capable;
- must not silently fabricate fallback Character/milestone semantics in Program.

Do not turn curation into a second Narrative acceptance gate.

## 6. Curator input boundary

Curator needs enough context to understand meaning but must not receive unrelated omniscient/private material that can leak into player-facing information.

Input should be the smallest useful set drawn from real current owners, such as:

- accepted Player input for the source Turn;
- accepted GM Narrative for the source Turn;
- current curated Character information;
- bounded recent Important Experiences;
- frozen starting Character/profile material as needed for continuity;
- relevant protagonist-owned / player-visible current facts already safe to expose;
- concise product semantics for Character and Important Experiences.

Do not pass raw all-world omniscient state, NPC-private Knowledge, GM-private Source prose, Agency private plans, hidden Evolution events or unrelated backstage material merely because it is available.

`World Truth != actor Knowledge != human-player disclosure` remains protected.

## 7. v0.1 Character semantics

The model may maintain current player-facing material corresponding to these product groups:

```text
基本资料
出身 / 来历
当前身份 / 社会角色
性格 / 价值观 / 原则
能力 / 专长说明          # non-numeric
局限 / 长期特征
长期目标 / 自我方向
```

Exact internal field names may differ, but the contract must remain bounded and presentation-safe.

Do not store/render as Character:

- HP / MP / numeric RPG attributes / Buff / short-term state;
- Inventory / Equipment / money / consumables;
- Relationship truth;
- current open tasks/commitments;
- player Knowledge/intelligence;
- full mutation history.

Those remain separate current/future domains/surfaces.

## 8. v0.1 Important Experiences semantics

Important Experiences are protagonist-centered milestones, not every durable fact or Turn.

The model decides significance contextually.

The Program may provide semantic guidance/examples from the frozen Decision, but those examples must not be compiled into a rule engine.

Milestone presentation material should support at minimum:

- deterministic identity/currentness linkage owned by Program;
- player-facing title;
- player-facing concise description;
- player-facing game-world time label when real current time data is available; otherwise do not invent calendar precision;
- causal/source-turn lineage kept internally, not rendered as hashes/IDs.

No arbitrary maximum content-history deletion limit. Storage may remain bounded per individual record; UI paging/collapse is a later consumer concern.

## 9. Structured curation contract

Design the **smallest bounded contract that proves this vertical**.

Prefer a contract that lets the model express current Character result cleanly without forcing Program to understand semantic diffs.

Acceptable approaches include, for example:

```text
A. full bounded current Character snapshot + current-turn milestone additions
```

or

```text
B. bounded Character operations + current-turn milestone operations
```

Choose based on lower semantic/integrity complexity in the existing Runtime.

Whichever is chosen, prove:

- known operation/field types only;
- bounded strings/counts/depth;
- no executable expressions/callbacks;
- no model-provided authoritative local IDs or source fingerprints;
- Program derives/owns durable identities and source-turn linkage;
- malformed result fails soft;
- identical successful replay cannot duplicate state/milestones.

Do **not** create a universal all-Surface JSON protocol in MW-014.

## 10. Durable representation / currentness

Use the existing World/Timeline mutation architecture where practical. Do not create an independent side database that escapes Save/Restore.

Required semantics:

```text
successful curation for accepted Turn/version
→ durable Character/milestone material belongs to that current history

same accepted Turn/version replay
→ same durable semantic result / no duplicate milestone

Regenerate replacing source GM version
→ old curation is no longer current

Restore to before curation
→ current Character reverts
→ restored-away milestone disappears

reopen current Game
→ equivalent current projections reconstruct
```

Displaced future history need not be physically deleted solely for UI; currentness must be authoritative.

No model-driven SQLite schema mutation.

## 11. Starting profile / migration semantics

Existing frozen `player_profile` remains the accepted starting presentation source.

The new evolving Character projection must preserve a useful initial Character view before any curator update.

Allowed pattern:

```text
frozen starting player_profile
+ current model-curated lived Character material
→ current Character projection
```

or an equivalent deterministic model that preserves starting data without reading Source Library current.

Must preserve:

- old Games do not silently backfill from latest Source;
- Source update does not alter existing Game;
- raw Character `semantic_sections`, GM-private/reference material and Source-current lookup do not reach player-facing output.

Do not mutate the immutable Source generation.

## 12. Provider integration

Use existing Provider infrastructure; do not build a second Provider stack.

A dedicated curator request/prompt is authorized if that yields cleaner responsibility and better quality.

Owner explicitly accepts one additional bounded model call for this purpose.

Prompt/contract should emphasize:

- trust the model to make semantic judgments;
- Character = current self, not history log;
- Important Experiences = meaningful protagonist milestones;
- long-term goals != current open tasks;
- other established Domains should not be duplicated in Character;
- do not invent hidden/unobserved player information;
- ordinary events can be important when context makes them important;
- no need to update anything when nothing materially changed.

Do not enumerate every possible RPG event type.

## 13. Player-safe projection seam

Expose deterministic presentation-only projections for later KimiCode UI consumption.

At minimum provide:

```text
Character projection
→ current bounded player-facing Character groups/material

Important Experiences projection
→ current ordered player-facing milestone list/material
```

Projection must not include:

- raw prompt/provider response;
- chain-of-thought/reasoning;
- internal IDs/hashes/fingerprints;
- NPC private knowledge/plans;
- GM-private Source material;
- stale future material;
- persistence/debug metadata.

No Provider call may be required merely to render/reopen the UI projection.

## 14. Focused acceptance proof

Task-owned tests/evidence must prove the real production seam, not a detached parser only.

At minimum prove:

1. accepted ordinary Turn can complete even when curator fails;
2. successful curator result can update current Character material;
3. successful curator result can add a milestone;
4. a no-change curator result creates no fake Character/milestone change;
5. Program does not use keyword/score/event-type semantic classification to decide importance;
6. malformed/oversized/unknown structured output fails soft without corrupting Game or Narrative;
7. identical same-version replay is idempotent and does not duplicate milestones;
8. Regenerate/replacement makes superseded curation non-current;
9. Restore to before a Character change/milestone removes it from current projections;
10. reopen reconstructs equivalent current Character + milestone projections;
11. starting frozen `player_profile` remains visible/useful before lived updates;
12. Source current / raw semantic sections / GM-private material cannot backfill Character projection;
13. NPC-private Knowledge / Agency / hidden Evolution material is absent from curator player-facing output path;
14. player-safe projections contain no internal IDs/hashes/persistence metadata;
15. no SQLite schema/table changes unless Codex proves the existing topology cannot safely represent this vertical and STOPs for GPT decision before implementing such expansion;
16. `git diff --check` clean;
17. Windows export PASS;
18. existing G3 Save/Restore, G5 world semantic lane, MW-009 projection, MW-011 profile projection, MW-012 Zhang Chen regressions PASS.

Also provide at least one production-path **real Provider smoke** (non-test fixture) demonstrating the curator returns coherent structured Character/milestone curation from a realistic accepted-turn example. This is semantic evidence, not full Product UAT.

## 15. Reality examples for evidence

Use examples that distinguish actual model judgment from Program rules.

Example A — low significance:

```text
Player: “曹操这人确实比我想象中有意思。”
Narrative: ordinary follow-up, no commitment made
Expected semantic quality:
- no invented “lifelong allegiance to Cao Cao”
- usually no milestone
```

Example B — real lived evolution:

```text
accepted history establishes that Zhang Chen, after sustained learning, can now read common clerical-script documents
Expected:
- Character current capability/limitation updates coherently
- milestone may be created if model judges it life-significant
```

Example C — explicit major direction:

```text
Player explicitly decides to remain and serve a faction/person long-term
Expected:
- model may update long-term direction/current social identity as context warrants
- important experience may be created
```

These are **semantic smoke scenarios**, not hard-coded Program assertions keyed to words like “曹操/效忠/隶书”. Tests should inject model outputs deterministically; real Provider smoke checks actual quality.

## 16. Explicit non-scope

Do not implement in MW-014:

- final Character / Important Experiences Godot Surface UI;
- left-panel visual redistribution;
- portrait/media resolver;
- Inventory Domain / 行囊;
- Relationship/Faction UI or new relationship semantics;
- Thread/Quest/事务 Domain;
- Map/spatial authority;
- System/mechanic status UI;
- generic all-Surface curation platform;
- Internal Declarative UI Host / MW-013;
- Action Intent;
- G7 long-session retrieval platform;
- external Mod/World Pack curation schema.

## 17. Evidence integrity / return protocol

Before final evidence:

```text
git rev-parse HEAD
git status --short
```

Final status must be clean.

Push exact candidate branch and return:

- exact candidate SHA;
- exact refreshed implementation base SHA;
- exact governance main SHA read before coding;
- changed files;
- selected curator call placement and why;
- exact structured curation shape and bounds;
- durable/currentness representation;
- proof that no Program semantic rule engine was introduced;
- Provider context/disclosure boundary;
- focused/regression/export results;
- real Provider semantic smoke result;
- clean `git status --short`;
- confirmation of non-scope.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**
