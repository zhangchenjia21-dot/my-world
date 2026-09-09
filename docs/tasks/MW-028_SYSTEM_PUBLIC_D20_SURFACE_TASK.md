# TASK｜MW-028｜System / Public d20 Surface

Type: G6 Package-4 core mechanics visibility vertical  
Work Item: **MW-028**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner UAT: **may be deferred / combined with later concentrated Product UAT / Package 7 Reality Gate; implementer must not claim Product PASS**  
Required branch: `mw-028-system-public-d20`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-028-system-public-d20`  
Formal Code Base: `5a336d0a993fd7e91b05b98f9b0cc14d2bb47b21`  
Governance Base at Task Shape: `f57ed356eeff55b1c2fdae589f8aea912f2a1666`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_SYSTEM_PUBLIC_MECHANICS_SURFACE_V1_0_DECISION.md@v1.0`  
Parent route: **G6 Package 4｜Core Mechanics Visibility**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Implement the first real `系统 / System` mechanics surface using the already-existing Public d20 owner.

After this task, the Player can open `系统` and reliably review the most recent **real, accepted, current Public d20 CHECKs** that actually occurred on the current Timeline — including what was being checked, Program rolls/math, DC, modifier/stance reasons, result and stakes — without relying on memory of an old inline Narrative dice card.

At the same time, Debug Mode must gain a bounded `mechanics` lane that can tell Owner whether the d20 path produced an accepted CHECK, accepted NO_CHECK, replay/no-new-change, degraded/no-check fallback, failure or cancellation, without exposing control payloads or hidden material.

This task is a **projection + presentation vertical**. It is not a new mechanics system.

## 2. Authority / freshness gate

Before production edits:

1. fetch implementation `origin/main` and governance `main`;
2. verify implementation Formal Code Base `5a336d0a993fd7e91b05b98f9b0cc14d2bb47b21` is still the intended base;
3. read any newer Owner/GPT decision that explicitly supersedes this packet;
4. STOP only for a genuine superseding decision, an incompatible main advance, or a real authority/currentness blocker.

Do not silently merge newer unrelated work into this task.

## 3. Read first

Read at minimum:

### Governance

1. `Vibe-Coding/AGENTS.md`
2. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
3. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.6`
4. `Vibe-Coding/my world/architecture/ui/G6_SYSTEM_PUBLIC_MECHANICS_SURFACE_V1_0_DECISION.md@v1.0`
5. `Vibe-Coding/my world/architecture/observability/G6_UAT_OBSERVABILITY_DEBUG_MODE_V0_1_DECISION.md`
6. `Vibe-Coding/my world/architecture/interaction/G6_CORE_INTERACTION_CONTROL_V1_0_DECISION.md`

### Implementation

1. repo `AGENTS.md`
2. `src/行动判定/L0_公理层/公开D20判定规则.gd`
3. `src/行动判定/L1_器件层/公开机制历史投影器.gd`
4. `src/行动判定/L3_外交层/公开机制历史公开接口.gd`
5. `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
6. `src/ui/叙事对话视图.gd`
7. `src/应用壳.gd`
8. `src/main.tscn`
9. `src/调试观测/L0_公理层/诊断展示契约.gd`
10. `src/调试观测/L3_外交层/会话调试观测公开接口.gd`
11. MW-026 mechanics-context tests/evidence and current Public d20 regression suites
12. MW-027 right-side Surface / real-window tests as a local presentation pattern only — do not copy Information Curator semantics into mechanics.

## 4. Core architecture

### 4.1 Existing Public d20 owner remains authoritative

Do not add a second mechanics truth.

The existing durable records under the Public d20 owner remain the only source for:

- whether an actual CHECK happened;
- raw rolls;
- selected roll;
- modifier / stance;
- DC / total / outcome;
- success intent / failure stakes;
- NO_CHECK durable terminal/currentness.

The System surface must never infer a check from Narrative prose, rerun adjudication, recalculate a different outcome, or store its own copy.

### 4.2 Reuse one current/player-safe mechanics selection

MW-026 already introduced `公开机制历史投影器.gd` for GM continuity. It already validates current accepted mechanics facts against accepted Conversation and excludes OOC/stale/displaced/ambiguous records.

Do **not** build a second independent `System` currentness selector.

Refactor the existing mechanics projector only as much as needed so that one validated record selection can serve both:

```text
current durable Public d20 truth + accepted Conversation
→ one mechanics-owned validation/selection seam
→ existing GM context projection
→ new structural System projection
```

A reasonable implementation is to introduce an internal/pure bounded records projection and derive both outputs from it. Exact naming is implementer-owned.

Critical protection: existing MW-026 `project_context()` behavior/currentness must remain regression-safe. Do not accidentally change GM mechanics continuity while adding UI DTOs.

### 4.3 System structural projection

Expose a dedicated mechanics L3 player-safe structural projection for the Shell/System leaf.

The player-facing System projection contains only actual accepted/current **CHECK** records, maximum recent 12.

Allowed CHECK fields:

```text
accepted_turn
intent
dc
modifier
modifier_reason
stance
situation_reason
raw_rolls
selected_roll
total
outcome
success_intent
failure_stakes
```

The output must be detached/copy-safe and contain no authoritative object reference back into Runtime state.

Do not expose:

```text
action_id
check_id
resolution_id
control raw payload
control proposal envelope
hash / prefix / persistence node id
provider raw response / reasoning
credentials
raw world_state
NPC-private / Knowledge-private / Agency / Evolution material
```

### 4.4 NO_CHECK boundary

Keep NO_CHECK durable truth and existing GM continuity behavior intact.

For v1.0 Player System:

- ordinary accepted `NO_CHECK` is **not** rendered as a persistent System card;
- it remains observable in Debug mechanics terminal evidence;
- it remains usable by existing mechanics continuity/currentness logic;
- do not delete/alter the NO_CHECK owner or turn it into a fake CHECK.

Reason: routine no-roll decisions must not flood a player-facing history surface.

## 5. `系统` Surface

### 5.1 Navigation

World Information Host navigation becomes:

```text
概览 | 角色 | 重要经历 | 人物 | 事务 | 系统 | 存档
```

Do not add the future `行囊` tab yet; Package 5 must first create a real Inventory owner/consumer.

Do not reactivate Player Status Host. Historical Public d20 records belong to the right-side World Information Host, not the left live-status host.

### 5.2 Surface content

Create a bounded first-party leaf view, e.g. a small `系统判定列表.gd` or equivalent local component. Do not build generic Dynamic UI.

Header / section semantics:

```text
近期公开判定
```

Recommended CHECK presentation:

```text
第 N 回合 · <intent>
结果：成功 / 失败
d20：<raw face(s)> → <selected> + <modifier> = <total> vs DC <dc>
形势：<stance / situation_reason>
修正：<modifier_reason>
成功意味着：<success_intent>
失败风险：<failure_stakes>
```

Pure presentation mapping is allowed, e.g.:

```text
normal       → 正常
advantage    → 优势
disadvantage → 劣势
success      → 成功
failure      → 失败
```

Do not change the underlying mechanics values.

Newest accepted CHECK should be easiest to find. A newest-first display is preferred.

### 5.3 Empty state

When current Timeline has no accepted CHECK:

```text
暂无公开判定记录。
```

Do not fill the surface with invented HP / Mana / Hunger / Money / Level / XP / Buff / attributes.

### 5.4 Existing Narrative dice card stays

Do not remove or replace the existing inline d20 card in Narrative.

The task must preserve:

- immediate inline dice result after the action;
- its existing value/math rendering;
- Narrative scroll behavior;
- ordinary free-form play.

System is persistent/reviewable projection, not a replacement for turn-local feedback.

## 6. Refresh timing — prevent one-turn lag

This is a critical integration point.

Current Public d20 flow may accept Conversation before the durable check acceptance marker has finished committing. Therefore a System refresh attached only to `Conversation.generation_completed` can run too early and miss the just-finished CHECK.

Prove and implement a refresh point that runs after adjudication terminal / accepted mechanics marker completion.

Expected lifecycle:

```text
CHECK narrative accepted
→ check acceptance marker durable
→ adjudication finished terminal
→ System projection refresh
→ just-finished CHECK visible immediately
```

Also refresh correctly on:

- Game activation / reopen;
- Restore;
- normal right-surface navigation.

Do not add polling or a second state cache.

## 7. Save / Restore / currentness

System must follow existing authority exactly.

Prove:

- fresh accepted CHECK appears;
- Save/reopen preserves it;
- Restore to before that CHECK removes it;
- Restore to after it restores it;
- corrected/replaced accepted history invalidates displaced mechanics;
- displaced future does not leak after Restore;
- unaccepted durable check is not shown;
- conflicting CHECK + NO_CHECK at one accepted slot fails soft and is not shown;
- OOC never becomes a CHECK/System record.

Do not add System-specific persistence.

## 8. Debug `mechanics` lane

Extend the existing bounded Debug seam rather than creating another observer system.

Add `mechanics` to the closed diagnostic lane vocabulary and subscribe the existing Debug observer to the current Public d20 adjudication terminal.

The lane must be able to safely distinguish at least:

- new accepted CHECK;
- new accepted NO_CHECK;
- already accepted / replay with no new change;
- accepted degraded/no-control path with no real CHECK where applicable;
- failed;
- cancelled.

If an existing stale/currentness-rejected terminal exists, surface it through the same bounded reason vocabulary; do not invent a fake stale state if the producer cannot produce one.

Recommended safe Debug evidence:

```text
lane=mechanics
terminal=<committed|failed|cancelled|...>
change=<changed|no-change|unknown>
code=<check_accepted|no_check_accepted|already_accepted|degraded|...>
counts={checks: 0|1, no_checks: 0|1}
```

Exact labels may follow current Debug conventions.

For a newly persisted CHECK or NO_CHECK, mechanics durable truth changed. For `already_accepted`/replay, no new change should be reported.

Never put into Debug rows:

- intent/stakes prose if not already part of current safe Debug contract;
- raw control JSON;
- Provider text;
- IDs/hashes;
- raw world state;
- private actor/world material.

Debug remains read-only, in-memory, capacity-bounded and OFF by default.

Important composition order: Debug observer is prepared before action adjudication on activation. Wire the adjudication producer into the existing observer when it is created; do not add a global EventBus.

## 9. No model / Provider expansion

This task requires **zero new semantic/model calls**.

System is a deterministic projection of Program-owned mechanics truth.

Real Provider calls are **not required** for MW-028 acceptance. Prefer controlled fixtures/stubs so the task does not spend Provider budget merely to prove UI/currentness plumbing.

Do not route System through Information Curator.

## 10. Focused deterministic acceptance

Build a non-vacuous focused MW-028 suite that exercises production seams.

### 10.1 Safe records projection

Prove:

- one accepted CHECK projects exact safe values including integer-normalized `raw_rolls`, selected, total, DC and outcome;
- no internal ID/control/private canary enters System projection;
- ordinary accepted NO_CHECK remains in existing continuity where expected but is absent from System list;
- max recent count is 12;
- display ordering is deterministic;
- unaccepted CHECK absent;
- OOC absent;
- stale/replaced/displaced-future absent;
- conflicting CHECK/NO_CHECK slot absent;
- JSON persistence round-trip numbers retain correct integer semantics;
- projection is detached from authoritative World state.

### 10.2 Existing GM context regression

Because projector internals may be refactored, explicitly prove MW-026 behavior remains intact:

- accepted CHECK context still reaches later ordinary continuation;
- accepted CHECK context still reaches OOC;
- accepted NO_CHECK continuity remains intact;
- failure stakes remain present where previously required;
- private canaries remain absent;
- Restore before/after behavior remains correct;
- no new Provider call is introduced;
- output shape/text is not accidentally changed in a way that breaks current consumers/tests.

### 10.3 Immediate Surface refresh

Use a controlled action-adjudication path and prove:

```text
before terminal: new check may not yet be eligible
adjudication accepted terminal after marker commit
→ System refresh
→ new CHECK is visible without waiting for another player turn/reopen/tab cycle
```

This test must catch the known ordering risk rather than merely calling `_render_system_surface()` manually after mutating fixture state.

### 10.4 Debug terminal proof

Exercise real observer wiring with controlled adjudication terminals for:

- accepted CHECK;
- accepted NO_CHECK;
- already accepted replay;
- degraded accepted path if applicable;
- failed;
- cancelled.

Prove rows contain only safe bounded structural evidence.

## 11. Player-facing / real-window acceptance

At minimum test:

- 0 CHECK empty state;
- 1 CHECK readable card;
- multi-CHECK history up to 12;
- newest result easy to locate;
- nav order `概览 | 角色 | 重要经历 | 人物 | 事务 | 系统 | 存档`;
- tab switching does not lose adjacent Character / Experiences / People / Threads content;
- System tab open/render causes zero Provider calls and zero durable writes;
- inline Narrative d20 card remains present/unchanged after an actual controlled CHECK;
- long text wraps rather than horizontal-overflows.

Real-window matrix:

```text
960×540
1280×720
1920×1080
```

At all sizes:

- ordinary gameplay visible text >=20px;
- no inaccessible horizontal overflow;
- long System history remains reachable through bounded vertical scrolling;
- Narrative composer remains usable;
- right host does not force Player Status Host open.

## 12. Regression gates

Run the directly affected suites, including at least:

- existing Public d20 contract/control/RNG/no-reroll/persistence/currentness;
- existing inline d20 Narrative presentation;
- MW-026 mechanics context + OOC continuity;
- MW-021 Narrative scrolling;
- MW-022 Debug Mode;
- MW-023 gameplay typography;
- MW-024 OOC zero-mechanics invariant;
- MW-027 Threads/right-nav/currentness;
- G2/G3 Conversation/Save/Restore paths touched by the projection lifecycle.

Known exact-baseline G3 Context failures may remain only if reproduced on an isolated checkout of the exact Formal Code Base. Do not suppress, relabel or silently fix unrelated debt.

## 13. Protected invariants

Must preserve:

- Public d20 stable action identity / no-reroll semantics;
- Program RNG and exact roll/result arithmetic;
- durable CHECK / NO_CHECK acceptance markers;
- free-form natural-language action as primary path;
- OOC zero d20 behavior;
- Narrative raw accepted bytes;
- Save / Restore / Regenerate currentness;
- MW-026 mechanics continuity context;
- existing inline dice card;
- Debug OFF ordinary experience;
- UI = projection, never second truth;
- World Truth != actor Knowledge != human-player disclosure;
- >=20px ordinary gameplay typography;
- no fake mechanics/state added to fill a surface.

## 14. Explicit non-scope

Do not implement:

- d20 balance/redesign;
- new action resolution mechanics;
- HP / MP / Mana / Hunger / Money / Level / XP / Buff framework;
- character stats engine;
- generic mechanics registry or universal System schema;
- Inventory / equipment / loot / economy;
- Quest/Open Threads redesign;
- Player Status Host historical d20 content;
- Dynamic UI Host;
- generic Action Intent;
- Narrative Preference / Reality Correction;
- Provider/model settings work;
- external Source UI contract;
- general Shell refactor;
- G3 Context debt cleanup;
- unrelated layer/warning cleanup.

## 15. Engineering acceptance

Engineering can be PASS only if Independent Review can establish that:

1. System shows exact current Program-owned CHECK truth, not inferred prose;
2. one shared mechanics currentness selector serves GM continuity and System rather than duplicated authority;
3. NO_CHECK does not flood Player System and remains intact in mechanics continuity/Debug;
4. just-finished CHECK appears immediately after adjudication terminal;
5. Restore/currentness/displaced future are correct;
6. no unsafe/private/internal fields reach leaf UI or Debug;
7. zero new Provider calls / zero System persistence owner;
8. Debug mechanics terminal evidence is truthful;
9. existing d20 mechanics and inline dice card regressions pass;
10. right-side UI remains readable/operable at all three required sizes;
11. adjacent Package 2/3 surfaces and navigation are not regressed.

## 16. Product Value Acceptance

The task delivers product value only if a Player can answer, from the normal game UI:

> “最近哪些真正的 d20 判定发生过？骰了什么、怎么算、成败和风险是什么？”

without opening Debug, reading logs, inspecting JSON, or replaying old chat history.

The Surface should feel like a durable player-readable mechanics record, not an internal developer log.

Ordinary non-roll actions should not swamp the view with `NO_CHECK` noise, and no fabricated RPG stats should appear merely to make `系统` look fuller.

Owner Product confirmation may remain deferred/combined under current governance. Codex must not declare Product PASS.

## 17. Final validation / return

After focused + regression gates:

1. run final Godot **4.7.2** import;
2. produce fresh Windows export;
3. run `run-game.ps1 -ValidateExportOnly` or current equivalent;
4. do not install/sync an Owner build unless explicitly requested later;
5. commit + push all task work to `mw-028-system-public-d20`;
6. leave worktree clean.

Write:

`docs/mw028/MW-028_IMPLEMENTATION_RETURN.md`

Return:

- exact Starting HEAD;
- exact production Implementation HEAD;
- exact Final candidate HEAD;
- changed production files;
- focused test result/count;
- real-window results at all three sizes;
- regression results and exact-base reproduction for any retained failure;
- final import/export/ValidateExportOnly result;
- Provider-call count (expected 0 for task acceptance evidence);
- residual risks / Product evidence boundary.

Do not merge `main`.
Do not install Owner build.
Do not mark Package 4 Product PASS.

Highest allowed return state:

**READY FOR INDEPENDENT REVIEW**
