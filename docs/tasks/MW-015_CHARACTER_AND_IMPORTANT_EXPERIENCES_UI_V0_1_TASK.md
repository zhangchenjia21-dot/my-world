# TASK｜MW-015｜Character + Important Experiences Surfaces v0.1

Type: G6 executable player-facing UI consumer task  
Work Item: **MW-015**  
Name: **Character + Important Experiences Surfaces v0.1**  
Capability-Anchor: **G6 RPG Experience / Real Information Surfaces**  
Primary Implementer: **KimiCode**  
Reviewer: **GPT**  
Revision: **1**  
Review-Round: **0**  
Status: **READY FOR KIMICODE**  
Task Branch: `mw-015-character-important-experiences-ui-v01`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-015`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Implementation main at task shaping: `7a0eeb35f8f836fa6df98288bef98a8f535b8393`  
Governance main at task shaping: `b56850181b1c7cbabfef721977496e4fa60ca6e3`

## 1. Product / architecture authority

Refresh latest `main` of both repositories before coding. If newer work conflicts with this packet, STOP and report rather than overwriting it.

Read before implementation:

- `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
- `Vibe-Coding/my world/MY_WORLD_架构_CURRENT.md`
- `Vibe-Coding/my world/architecture/ui/G6_SESSION_SHELL_INFORMATION_OWNERSHIP_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/声明式UIHost设计.md`
- `docs/mw014/MW-014_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw014/MW-014_INTEGRATION_VERIFICATION.md`
- `docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`
- repository `AGENTS.md`

MW-014 is already **ENGINEERING PASS / INTEGRATED**. This task is the first real player-facing consumer of its reviewed safe projection seam.

## 2. Product outcome

Implement the actual right-side RPG information experience for:

```text
角色 / Character
→ “现在的我是谁”
→ current evolving Character Sheet

重要经历 / Important Experiences
→ “我是怎样走到现在的”
→ protagonist-centered milestone history
```

At the same time complete the already-frozen left/right responsibility migration:

```text
Player Status Host（左）
→ portrait + real live mechanics/status only
→ current v0.1 has no such grounded consumer, so it may collapse/hide

World Information Host（右）
→ 概览 / 角色 / 重要经历 / 存档
```

Do not create ungrounded tabs for `人物 / 事务 / 行囊 / 系统 / 地图` yet.

## 3. Mandatory data seam

Character and Important Experiences must read only the reviewed MW-014 player-safe L3 projection or an equivalent already-safe public seam:

`src/信息整理/L3_外交层/角色经历投影公开接口.gd`

Expected shape:

```text
character:
  headline
  summary
  groups[]:
    title
    items[]

important_experiences[]:
  title
  description
  time_label
```

Leaf UI must not:

- inspect raw `world_state` to infer Character/milestones;
- call Provider to render/reopen a Surface;
- parse Narrative text to decide importance;
- inspect `information_curation` internal prefix/parent/id/schema;
- read Source Library current;
- read raw Character `semantic_sections` / GM-private material.

**Model owns semantic interpretation and curation; this UI only presents the normalized player-safe result.**

## 4. Right-side navigation — exact v0.1 scope

Extend the current bounded World Information navigation from:

```text
概览 | 存档
```

to:

```text
概览 | 角色 | 重要经历 | 存档
```

Requirements:

- exact four implemented Surfaces only;
- default remains `概览`;
- one active Surface at a time;
- switching Surface is presentation-only and makes no World/Provider mutation;
- do not build a generic navigation framework or declarative host;
- Save callbacks and G3 ownership remain unchanged.

Rename player-visible right Host chrome from generic `世界` to an information-oriented label such as `信息` if needed for consistency. In narrow mode the right toggle should likewise describe the information panel, not imply only World truth.

## 5. Character Surface

Render current Character projection in model-provided order.

Presentation should include:

```text
headline
summary

for each group:
  group title
  group items
```

Allowed semantic groups are already enforced by MW-014 backend; UI must not reclassify or reorder them by meaning.

### 5.1 Initial / no-curation state

Before the first successful lived curation, MW-014 intentionally provides only the safe starting headline/summary and may have zero current groups.

Required behavior:

- show the available headline/summary cleanly;
- if groups are empty, use a quiet player-facing empty/detail hint rather than inventing fields;
- do **not** pull arbitrary frozen profile groups into Character as a UI fallback, because authored groups can include starting possessions that belong to future Inventory;
- do not show `随身物品 / equipment / inventory` merely to make the page look full.

After a successful curator update, the Surface should show the model-curated current groups without reopening the Game.

## 6. Important Experiences Surface

Render the full **current** ordered milestone projection supplied by MW-014.

For each experience:

- title;
- description;
- `time_label` only when non-empty.

When empty, show a quiet empty state such as “尚无需要长期记录的重要经历”。

Do not:

- impose a content deletion cap such as latest 20;
- invent calendar dates from turn count, wall clock or Source era;
- display internal turn/hash/node/id metadata;
- re-score importance in UI;
- convert ordinary Narrative history into milestones locally.

The right panel should remain scrollable/coherent for long content. v0.1 may use ordinary ScrollContainer/VBox composition; no paging framework is required yet.

## 7. Left Player Status Host migration

MW-011 rich left `player_profile` was explicitly accepted as transitional only. MW-015 must end that transitional ownership.

Remove from the left player-facing Host:

```text
name / profile name
headline / summary / biography groups
World / Entry identity
recent Player actions
player turn count
any other “who am I” or session metadata filler
```

Current product has no grounded portrait resolver and no real live mechanic/status contribution. Therefore v0.1 should keep the stable `PlayerPanelHost` placement available in the scene but **collapse/hide it when it has no legitimate Player Status content**.

Requirements:

- do not delete the architectural Host node merely because it is empty today;
- do not invent placeholder HP/stats/portrait;
- do not leave a large empty left column just to preserve a three-column silhouette;
- in narrow mode do not expose a useless Player toggle while the Host has no real content;
- Narrative + World Information should use the released space coherently.

This task does not build the future portrait/status contribution framework.

## 8. Overview cleanup / preservation

Overview remains the current place for:

- World display name;
- selected Entry display name when present;
- bounded player-known facts from the existing safe projection.

Preserve these semantics and disclosure boundaries.

Do not move `recent actions` or `player-turn count` into Overview merely because they are removed from the left. They are not required long-term RPG information Surfaces in v0.1.

## 9. Refresh behavior

The UI must refresh Character / Important Experiences at real lifecycle points without turning rendering into model work.

At minimum:

- initial Game activation / reopen;
- successful MW-014 curator terminal/commit;
- Restore / progress switch where current World+Conversation changes;
- existing full side-panel redraw lifecycle.

Use the existing curator `finished(result)` signal or the narrowest existing seam. A successful curator update should become visible without reopening the Game.

Do not create a generic reactive store/event bus.

Curator failure remains non-blocking: UI keeps the last current durable projection and gameplay continues.

## 10. Responsive / layout behavior

Primary experience remains maximized desktop.

Required checks:

```text
Maximized desktop
1280x720
narrow regression (~960x540 or current project equivalent)
```

Wide/current-empty-left behavior:

```text
Narrative | World Information
```

with Narrative remaining visually primary.

If/when Player Status Host has real content in future, the existing three-Host placement remains available; MW-015 must not redesign the whole shell around a permanent two-column architecture.

Right-side Character and Important Experiences content must wrap/scroll normally and must not overflow into Narrative.

## 11. Explicit no-semantic-judge rule

Do not add any Program logic such as:

- keyword / regex rules deciding what belongs in Character;
- milestone scores;
- event-type importance conditions;
- Character group semantic remapping;
- special-case rules for Cao Cao / Liu Bei / clerical script / Zhang Chen;
- Narrative parsing to infer current state.

If the projection is semantically imperfect, render the current safe projection and report the quality issue. Do not “fix” model meaning in UI code.

## 12. Focused acceptance proof

Create task-owned tests/evidence proving the **real Godot consumer**, not only dictionary formatting.

At minimum prove:

1. right navigation contains exactly `概览 / 角色 / 重要经历 / 存档` and only one mode is visible at a time;
2. Overview still renders World/Entry + MW-009 player-known facts and no private material;
3. initial Character Surface renders safe headline/summary and a coherent empty-detail state when groups are absent;
4. initial Character Surface does not backfill starting possessions or arbitrary Source groups;
5. a current MW-014 Character projection renders group titles/items in projection order;
6. Important Experiences renders current milestones in causal order, title/description, and only nonempty time labels;
7. an empty milestone projection renders a quiet empty state;
8. curator success refreshes Character/Important Experiences without reopening and without a render-time Provider call;
9. curator failure does not blank accepted Narrative or block Player input;
10. Regenerate/Restore currentness removes stale/restored-away Character/milestone content after UI refresh;
11. left Player Status Host contains no biography/profile/world/recent-actions/turn-count material;
12. with no portrait/mechanic contribution, left Host is collapsed/hidden and narrow mode exposes no useless Player toggle;
13. Narrative remains primary and World Information remains usable at maximized, 1280x720 and narrow regression sizes;
14. Save Surface and Load/Restore callbacks remain functional and unchanged in ownership;
15. UI consumes no raw `world_state`, curation IDs/hashes/schema, NPC private knowledge, Agency plan or hidden Evolution material;
16. no Program semantic classifier / score / rule tree is introduced;
17. Provider calls = 0 for focused UI render tests;
18. no SQLite schema/table changes;
19. `git diff --check` clean;
20. Windows Desktop export PASS.

Required regressions should include the relevant existing suites for:

- MW-014 curation/backend projection;
- MW-009 safe projection;
- MW-011 ViewModel/profile safety (update historical visual expectations only where the new frozen IA intentionally supersedes them; do not weaken privacy/currentness assertions);
- MW-012 Zhang Chen integration;
- G3 Save/Restore UI;
- Narrative streaming/action critical path.

## 13. Owner UAT target after Engineering PASS

After GPT Independent Review and integration, Owner UAT should be able to verify in the real app:

```text
open Game
→ right 信息 panel has 概览 / 角色 / 重要经历 / 存档
→ 角色 shows current Character
→ play a meaningful Turn
→ curator updates current Character / milestone when model judges appropriate
→ 重要经历 reflects current milestone history
→ left no longer contains biography filler
→ Restore / Regenerate returns visible info to the matching history
```

UI implementation is not Product PASS until Owner explicitly accepts this experience.

## 14. Non-scope

Do not implement in MW-015:

- new Information Curator backend semantics;
- prompt tuning / model-quality heuristics;
- Inventory Domain / 行囊;
- People / Relationship / Faction UI;
- Thread / Quest / 事务;
- System mechanic state / HP / MP / attributes;
- portrait / scene / authored-map runtime resolution;
- top context date/location system;
- Internal Declarative UI Host / MW-013;
- generic all-Surface navigation framework;
- bounded Action Intent;
- UI preference persistence / splitter framework;
- G7 retrieval/performance platform;
- G8 external Mod UI schema.

If implementation appears to require new Runtime authority/persistence/domain semantics, STOP and report rather than expanding KimiCode scope.

## 15. Evidence integrity / return protocol

Before final evidence:

```text
git rev-parse HEAD
git status --short
```

Final status must be clean.

Push exact candidate branch and return:

- candidate SHA;
- refreshed implementation base SHA;
- governance main SHA read before coding;
- exact changed files;
- navigation and Surface structure implemented;
- exact MW-014 safe projection seam consumed;
- left Host migration behavior;
- refresh/lifecycle behavior;
- responsive evidence;
- focused/regression/export results;
- proof no raw Runtime/private data or Program semantic judge was introduced;
- `git diff --check` result;
- clean `git status --short`.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**

Do not merge main and do not claim Engineering PASS.
