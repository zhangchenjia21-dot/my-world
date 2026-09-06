# TASK｜MW-013｜Internal Declarative UI Host v0.1

Type: G6 executable implementation task  
Work Item: **MW-013**  
Name: **Internal Declarative UI Host v0.1**  
Capability-Anchor: **G6 RPG Experience & Internal Declarative UI Host**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Revision: **1**  
Review-Round: **0**  
Status: **READY FOR CODEX**  
Task Branch: `mw-013-internal-declarative-ui-host-v01`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-013`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Implementation main at task shaping: `f68623e3915b67d6bfefe4eacef62c895b4e789f`  
Canonical architecture at task shaping: `Vibe-Coding/main` containing `my world/architecture/ui/G6_INTERNAL_DECLARATIVE_UI_HOST_V0_1_DECISION.md`

## 1. Product / architecture authority

Read before implementation:

- `Vibe-Coding/my world/architecture/ui/G6_INTERNAL_DECLARATIVE_UI_HOST_V0_1_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/声明式UIHost设计.md`
- `Vibe-Coding/my world/architecture/ui/G6_RPG_HOST_VIEWMODEL_V0_1_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`
- `docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`
- `docs/mw011/MW-011_INDEPENDENT_REVIEW_IR3.md`

Also refresh current implementation/governance `main` before coding. Current task packet never authorizes overwriting newer/unknown work.

## 2. Why this task exists

MW-011 has now passed Owner Product UAT and provides two real structured UI consumers:

```text
Player Host
→ player-safe identity/profile/recent-actions/session material

World Overview
→ World/Entry identity + Player-known facts/session material
```

The visual-runtime re-entry audit intentionally remains deferred because no materially authored first-party visual demand exists yet.

The next G6 step is therefore to prove a **small internal safe renderer from these real consumers**, not to build an external Mod UI platform.

## 3. Required outcome

Implement:

```text
existing safe RPG Host ViewModel
→ bounded internal UI definition material
→ reusable Internal Declarative UI Host renderer
→ Godot Controls
```

At least two real consumers must use the same renderer:

1. Player Host structured information;
2. World Overview structured information.

Save controls remain imperative and unchanged.
Narrative stream/composer remain imperative and unchanged.

## 4. v0.1 vocabulary — exact scope

Only these component kinds are authorized:

```text
section
status_list
fact_list
```

Do not add a generic vocabulary merely because it seems reusable.

Expected internal data concepts:

```text
section
- component_id
- kind
- title
- children[]

status_list
- component_id
- kind
- optional title
- items[] { label, value }

fact_list
- component_id
- kind
- optional title
- items[] string
```

Exact implementation names may differ if the semantics and bounds remain identical.

## 5. Mandatory safety properties

Definitions are **program-internal presentation material** only.

They must never be loaded from World/Character/Expansion packages in this task.

No definition may contain/execute:

- arbitrary GDScript callbacks/method dispatch;
- arbitrary NodePath;
- expressions / `${...}` / binding language;
- SQL/runtime queries;
- filesystem or OS commands;
- Provider prompts/calls;
- raw `world_state`;
- raw Character `semantic_sections`;
- Source Library current lookup;
- arbitrary Godot resource/scene path supplied as data;
- direct mutation capability.

Definitions receive only already-safe ViewModel material.

## 6. Bounds / validation

Create the smallest deterministic validator/materializer required for the internal definitions.

At minimum:

- known component kinds only;
- exact/known fields per kind;
- safe non-empty internal component IDs;
- duplicate component IDs rejected within one definition tree;
- bounded string lengths and item counts;
- bounded small recursion depth;
- no nested arbitrary values;
- malformed/unsupported contribution fails closed/soft and never blocks Narrative gameplay.

Do not create an external JSON schema/versioning framework.

## 7. Player Host migration

Use the new renderer for the repeatable structured Player material that already passed Owner UAT, such as:

- Player profile headline/summary/groups;
- safe Player/world/session status rows where appropriate;
- recent Player actions as display-only list if represented without changing semantics.

Preserve:

- current left/right information placement;
- MW-011 profile frozen-generation behavior;
- recent-action count/currentness behavior;
- Player Host scroll behavior;
- Narrative primacy.

This task must not implement the Owner's deferred future left/right redistribution.

## 8. World Overview migration

Use the same renderer for current Overview structured material:

- World identity;
- Entry identity;
- Player-known facts;
- safe turn/session metadata already present.

Preserve `概览 / 存档` navigation.

Save controls/callbacks remain their current application/G3-owned implementation.

Do not add empty tabs for 人物 / 关系 / 势力 / 任务 / 物品 / 地图 / Timeline.

## 9. No data-owner expansion

This task must not invent:

- Character runtime stats;
- Inventory state;
- Relationship/Faction state;
- Quest/Thread state;
- Map topology/current location;
- new Knowledge semantics;
- new persistence tables;
- visual assets/resolver;
- Action Intent.

If implementation appears to require a new domain owner, STOP and report rather than adding one.

## 10. Focused acceptance proof

Create task-owned tests that prove actual renderer behavior, not only dictionary validation.

At minimum prove:

1. valid `section/status_list/fact_list` definitions render expected Godot controls/text;
2. unknown kind/unknown field/duplicate ID/excess depth/oversized material is rejected or omitted safely;
3. definition data cannot trigger callback/NodePath/expression/runtime query behavior;
4. fresh Zhang Chen `0.1.1` Player Host still visibly contains the accepted profile information in the same authored order;
5. Player Host recent actions + player-turn count still update after turns;
6. World Overview still shows World/Entry and MW-009 Player-known facts;
7. semantic/NPC/private/GM/internal material remains absent from visible Player/World surfaces;
8. reopen rebuilds equivalent visible definitions from current safe ViewModel;
9. Restore removes restored-away dynamic actions/facts while static frozen profile remains;
10. `概览 / 存档` navigation and G3 Save callbacks remain functional;
11. existing Character card without `player_profile` still gets the compact fallback rather than renderer failure;
12. wide/maximized, 1280x720 and narrow regression remain coherent;
13. Narrative stream/composer behavior unchanged;
14. Provider calls = 0 for focused tests;
15. no SQLite schema/table changes;
16. `git diff --check` clean;
17. Windows export PASS.

Required regressions include at least:

- MW-009 safe projection;
- MW-011 profile surface/baseline;
- MW-012 Zhang Chen integration;
- G3 Save UI;
- narrative streaming critical path.

## 11. Evidence integrity

Return exact pushed candidate and evidence from that candidate.

Before final evidence:

```text
git rev-parse HEAD
git status --short
```

Final `git status --short` must be empty.

Do not report tests run against dirty/uncommitted bytes.

## 12. Non-scope

Explicitly excluded:

- G8 external declarative UI schema;
- World/Character/Expansion-provided UI definitions;
- arbitrary code plugin system;
- `meter`, `badge`, `card`, `action_list`, `secondary_view`, `map_overlay`, filters;
- bounded Action Intent;
- portrait/scene/map runtime resolution;
- right-side IA redistribution;
- UI preference persistence;
- Narrative/Composer refactor;
- Save action declarativization.

## 13. Return protocol

Return:

- exact candidate SHA;
- exact refreshed base SHA;
- exact changed files;
- architecture audit conclusion;
- internal definition shapes actually implemented;
- validator bounds;
- two real consumer migrations;
- proof no raw Runtime/Source/executable capability enters definitions;
- focused/regression/export results;
- `git status --short` clean proof;
- confirmation no persistence/domain/platform scope expansion.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**
