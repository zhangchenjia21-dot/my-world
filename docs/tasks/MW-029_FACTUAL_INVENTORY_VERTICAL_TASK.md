# TASK｜MW-029｜Factual Inventory Vertical

Type: G6 Package-5 core factual possession vertical  
Work Item: **MW-029**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner UAT: **may be deferred / combined with later concentrated Product UAT / Package 7 Reality Gate; implementer must not claim Product PASS**  
Required branch: `mw-029-factual-inventory`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-029-factual-inventory`  
Formal Code Base: `f6aae06f6be3be4b7fd24762a10e524b6eb9b683`  
Governance Base at Task Shape: `502c1aff35a8cf87778228d2087348c0170ddd94`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_FACTUAL_INVENTORY_VERTICAL_V1_0_DECISION.md@v1.0`  
Parent route: **G6 Package 5｜Core Inventory Vertical**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Implement the first real `行囊 / Inventory` gameplay vertical.

After this task, when an accepted GM Narrative explicitly establishes that the Player Character now carries/owns a concrete portable item, the existing World semantic lane can materialize that factual possession into durable current Inventory. The player can then open `行囊` and see the current item; later natural-language play can update it or remove it when it is consumed, transferred, lost or otherwise no longer possessed.

The same current Inventory must ground later GM continuation/OOC and Public d20 requests, so the UI and the GM do not disagree about what the player is carrying.

This is a **factual state + projection vertical**. It is not an equipment, loot, crafting or economy system.

## 2. Why now

Packages 3 and 4 now provide real Information and Mechanics surfaces. Package 5 is the final new gameplay-state consumer required before Package 6 can converge proven surfaces into the Internal Dynamic UI Host.

Current implementation has no authoritative Inventory owner. Current Character Source v0.2 also has no explicit factual initial-inventory contract. Therefore the safe minimal route is:

```text
no authoritative Inventory event → empty structured Inventory
accepted Narrative explicitly establishes possession → ADD
later accepted Narrative → UPDATE / REMOVE / no-change
```

Do not invent starting gear or silently expand the external Source contract just to satisfy a fixture.

## 3. Authority / freshness gate

Before production edits:

1. fetch implementation `origin/main` and governance `main`;
2. verify Formal Code Base `f6aae06f6be3be4b7fd24762a10e524b6eb9b683` is still the intended implementation base;
3. verify `G6_FACTUAL_INVENTORY_VERTICAL_V1_0_DECISION.md@v1.0` is still FROZEN/CURRENT;
4. read any newer Owner/GPT decision that explicitly supersedes this packet;
5. STOP only for a genuine superseding decision, incompatible implementation-main advance, or real authority/currentness blocker.

Unrelated governance advances do not invalidate the packet. Do not silently merge newer implementation work into this task.

## 4. Read first

Read at minimum, in this order.

### Governance

1. `Vibe-Coding/AGENTS.md`
2. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
3. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.7`
4. `Vibe-Coding/my world/architecture/ui/G6_FACTUAL_INVENTORY_VERTICAL_V1_0_DECISION.md@v1.0`
5. `Vibe-Coding/my world/architecture/ui/G6_SYSTEM_PUBLIC_MECHANICS_SURFACE_V1_0_DECISION.md@v1.0` — adjacent Surface/currentness pattern only
6. `Vibe-Coding/my world/architecture/observability/G6_UAT_OBSERVABILITY_DEBUG_MODE_V0_1_DECISION.md`

### Implementation

1. repo `AGENTS.md`
2. `src/世界回合/L2_流程层/语义物化流程.gd`
3. `src/世界回合/L1_器件层/语义变更响应解析器.gd`
4. `src/世界回合/L0_公理层/世界回合规则.gd`
5. `src/世界回合/L3_外交层/世界回合公开接口.gd`
6. `src/首次开场/L2_流程层/首次开场运行流程.gd`
7. `src/行动判定/L2_流程层/公开D20行动判定流程.gd`
8. `src/应用壳.gd`, `src/main.tscn`
9. `src/调试观测/L0_公理层/诊断展示契约.gd`
10. `src/调试观测/L3_外交层/会话调试观测公开接口.gd`
11. MW-027/MW-028 Surface and real-window tests as presentation/currentness patterns
12. current Save/Restore and World semantic regression suites

Only expand the read set when evidence is insufficient; if expanded, record why.

## 5. Decision digest / invariants

### INV-PRODUCT-01｜Inventory means factual current possession

`行囊` answers what the Player Character currently truly possesses/carries on the current Timeline. It must not become a prose memory surface, task list, Character trait, inferred equipment list or UI-only cache.

### INV-01｜No invented initial inventory

No authoritative Inventory event means structured Inventory is empty.

Do not:

- infer starting items from Character/T0 prose;
- add default clothing/money/weapon/food;
- change Character Source v0.2 external schema in this task;
- create a Creator/inventory authoring workflow.

A deterministic fixture may establish the first item through an accepted Narrative + semantic response; it must traverse the production mutation path.

### INV-02｜Existing World semantic call is the semantic writer

Inventory possession change is extracted in the **same existing** semantic materialization Provider opportunity that already handles world changes/knowledge/identity.

No Inventory-specific Provider call, Curator, polling worker or second semantic lane.

### INV-03｜Inventory optional subfield is fail-soft relative to existing semantic domains

Extend the semantic machine response with a bounded optional Inventory subfield. Invalid/oversized Inventory material must fail-soft to no Inventory mutation without invalidating otherwise-valid existing `changes / knowledge_events / new_actor_candidates / people_bindings` behavior.

Conversely, do not create a second partial persistence path: all valid outputs for the turn still converge into the existing single World candidate commit.

### INV-04｜Minimal mutation vocabulary only

Support only:

```text
ADD
UPDATE
REMOVE
```

Interpretation is model-owned from accepted Narrative; Program does not keyword-route verbs.

A reasonable machine shape is:

```json
"inventory_updates": {
  "add": [{"name":"...","summary":"..."}],
  "update": [{"item_ref":"...","name":"...","summary":"..."}],
  "remove": [{"item_ref":"..."}]
}
```

Exact naming may vary if the same semantics/tests remain clear. Keep exact-field validation and small bounds. Suggested structural limits unless current code conventions justify a nearby equivalent:

- <= 8 total item operations per turn;
- name <= 120 Unicode chars;
- summary <= 600 Unicode chars;
- request-only item_ref <= 128 chars;
- current projected Inventory bounded to a sane defensive ceiling (e.g. 64) without inventing gameplay capacity/weight semantics.

These are parser/context safety bounds, not RPG inventory capacity rules.

### INV-05｜Stable item identity is Program-owned

Persist an internal stable item identity for each added item. Model responses never supply authoritative `item_id`.

For ADD, mint replay-safe deterministic Program identity from exact accepted source version + ordinal/material (or an equivalent deterministic method). Same accepted version reprocessing must not create duplicate identities.

Display name is never identity.

### INV-06｜Existing item targeting uses opaque request refs

Before the semantic request, derive current Inventory and give the model request-only opaque `item_ref` values mapped internally to exact current stable items.

UPDATE/REMOVE must use those refs.

Never resolve existing items by name equality. Unknown, duplicate or stale refs fail-soft and do not mutate.

Do not expose stable item IDs to the model as free-form authority.

### INV-07｜Event/version currentness, not mutable-list-only truth

Do not implement Inventory as only one mutable current-items array with no source-version binding.

Persist bounded Inventory event records bound to exact accepted turn identity, at least:

- source turn index;
- exact accepted GM hash/version;
- normalized operations with internal stable IDs.

Current Inventory is derived by folding only records that still match current accepted Conversation, in accepted order.

Required consequence:

```text
turn T adds item
→ T is Regenerated/replaced
→ old T inventory record no longer current
→ item disappears immediately from current projection
```

Later UPDATE/REMOVE events that target an item no longer present after such replacement fail-soft during fold.

### INV-08｜No new SQLite owner

Inventory events live in the existing Game-local durable World document / Timeline snapshot. No new table, database, file or UI persistence store.

### INV-09｜Player-safe L3 projection

Create an Inventory-owned L3 seam that can project current Inventory from Runtime/current accepted Conversation.

Leaf player DTO is only:

```text
name
summary
```

Detached copies only. UI receives no raw Runtime/world_state/event records/item_id/hash/ref.

### INV-10｜Current Inventory grounds future foreground play

Current player-safe Inventory must enter later foreground model context through a bounded factual block.

At minimum cover:

- ordinary continuation;
- OOC / GM Guidance continuation;
- Public d20 control;
- Public d20 narrative stages.

Do not inject raw events/IDs.

Do not expand `project_world_only()` / World Evolution with Player-private Inventory authority.

If implementing through a shared Inventory L3 `project_context(...)`, use that same projection seam for all consumers rather than independently serializing Inventory in several modules.

### INV-11｜World semantic request receives exact current item refs

The semantic extractor itself must receive the current Inventory snapshot plus request-only opaque refs so UPDATE/REMOVE can target existing items exactly.

The model may only mutate Inventory when the accepted turn actually establishes a possession/state change. Merely mentioning, seeing or interacting with an environmental object is not sufficient unless accepted Narrative makes current player possession true.

### INV-12｜UI placement

After MW-029, navigation is exactly:

```text
概览 | 角色 | 重要经历 | 人物 | 事务 | 行囊 | 系统 | 存档
```

`行囊` is a read-only current Surface with:

- heading/section `当前行囊`;
- `name + summary` per item;
- empty state `当前没有已记录的随身物品。`;
- >=20px ordinary text;
- existing vertical scrolling on crowded/narrow content.

No item buttons, checkbox, drag/drop or editor.

### INV-13｜Natural-language action remains the only item-action UX

Player uses/gives/drops items by typing ordinary natural-language role actions. Do not add “Use / Equip / Drop” action controls.

### INV-14｜Refresh timing

Inventory updates only after World semantic durable commit.

Reuse the existing Shell semantic-terminal player-safe refresh seam. Do not show a proposed Inventory update while the semantic Provider request is still pending.

### INV-15｜Debug inventory lane

Extend existing Debug with `inventory`, based on safe structured terminal evidence from World semantic materialization.

At minimum distinguish:

- committed changed;
- committed no-change;
- failed;
- cancelled;
- stale/currentness rejected where applicable.

Safe fields may include bounded counts such as `added / updated / removed / total`.

Never show item prose, item IDs/refs, raw semantic payload or private world data.

### INV-16｜No semantic rule engine

Program validates structure/refs/currentness only. It must not contain keyword/regex rules such as “if text contains 获得 then add item”, name matching, item-type classifiers or fixed consumption heuristics.

## 6. Implementation shape

Exact file layout is implementer-owned within the repository layering rules, but the preferred bounded decomposition is:

```text
src/行囊/
  L0  Inventory contract / event validation / stable identity
  L1  current fold + request-ref resolution / safe projector
  L3  current player-safe projection + context projection
```

Then minimally integrate:

- World semantic Rules/parser/process for optional Inventory output + same atomic candidate commit;
- foreground context consumers;
- Shell + first-party `行囊` leaf view;
- Debug observer/contract;
- focused / real-window / regression tests.

Do not create L2 Inventory worker unless a real stateful process is necessary; the existing World semantic process already owns mutation timing.

## 7. Scope

### Allowed

- new narrow `src/行囊/**` module;
- bounded extensions to World semantic parser/rules/process;
- bounded current Inventory context integration in existing narrative/Public d20 paths;
- `src/应用壳.gd`, `src/main.tscn`, one first-party Inventory list/view;
- bounded Debug inventory lane additions;
- focused tests/evidence under `tests/mw029`, `docs/mw029`;
- necessary adjacent test expectation update from seven → eight authorized tabs;
- task-only fixture additions.

### Prohibited

- Information Curator ownership of Inventory;
- second Provider call/adapter;
- new SQLite table/database/file truth;
- Source contract/schema changes for initial items;
- Final Create default item fabrication;
- Character profile prose parsing;
- equipment slots/stats;
- NPC inventory;
- containers/storage;
- stack arithmetic framework;
- loot/crafting/shop/economy/currency;
- numeric durability/weight/capacity;
- action buttons / generic Action Intent;
- Dynamic UI abstraction;
- general Shell refactor;
- G3 Context debt repair;
- unrelated warning cleanup.

## 8. Required behavioral proof

Build a deterministic production-path vertical that establishes at least this sequence:

```text
A. no Inventory event → 行囊 empty
B. accepted role action + GM Narrative explicitly establishes possession of one item
C. same existing World semantic call returns ADD
D. durable commit → 行囊 shows exact item
E. next foreground request sees bounded current Inventory context
F. later accepted role action + GM Narrative changes/uses/transfers/loses that exact item
G. semantic UPDATE or REMOVE uses opaque current item_ref, not display-name identity
H. durable commit → 行囊 changes immediately
I. Save/reopen and Restore before/after reproduce exact current Inventory
J. Regenerate/replace source turn invalidates superseded Inventory event
```

Also prove an ordinary accepted turn may result in zero Inventory change.

For a `use` example, do not hard-code “use = remove”. Exercise either:

- use without possession change → no-change; or
- use changes factual state → UPDATE; or
- consumable use → REMOVE,

according to the controlled semantic response.

## 9. Engineering acceptance

### 9.1 Inventory contract/currentness

Prove:

- no-event baseline is empty;
- exact bounded ADD/UPDATE/REMOVE parse/validation;
- invalid Inventory subfield fails soft without losing otherwise-valid existing semantic domains;
- Program-owned deterministic item identity;
- same-name distinct items are not collapsed by display name;
- exact opaque item_ref targeting;
- unknown/duplicate/stale refs do not mutate;
- event source turn/hash binding;
- corrected/regenerated accepted version invalidates old event;
- displaced future cannot leak through Restore;
- reopen does no historical Provider backfill.

### 9.2 Atomic World semantic integration

Prove one accepted turn produces at most the **existing one** semantic Provider opportunity, and valid Inventory + existing world/knowledge/identity changes share the existing durable World candidate commit.

No second Inventory persistence mutation for the same semantic result.

### 9.3 Context grounding

Capture derived request messages and prove current safe Inventory reaches:

- ordinary continuation / OOC;
- Public d20 control;
- Public d20 narrative.

Canary-test that event IDs/hashes/item IDs/item refs/private raw material do not reach those foreground messages.

Prove World-only evolution input does **not** gain Inventory material.

### 9.4 UI

Real Shell must show eight tabs in exact order:

`概览 | 角色 | 重要经历 | 人物 | 事务 | 行囊 | 系统 | 存档`.

At 960×540, 1280×720, 1920×1080:

- `行囊` readable/operable;
- ordinary text >=20px;
- no horizontal overflow;
- crowded bounded list vertically scrollable;
- composer remains usable;
- Player Status Host stays collapsed absent true live-status content;
- tab switching/rendering makes zero Provider requests and zero durable writes.

### 9.5 Debug

Prove safe `inventory` rows for changed/no-change/failure/cancel/stale cases as available from current semantic lifecycle.

No item prose, IDs, refs, raw Provider output or private canary.

Restore clears prior diagnostic epoch and late callback cannot cross it.

### 9.6 Adjacent regressions

Run directly affected suites including at least:

- World semantic materialization / knowledge / identity / Agency wake/currentness;
- Save / reopen / Restore / Regenerate;
- OOC;
- Public d20 contract/control/no-reroll/context/System;
- Character / Important Experiences / People / Threads;
- Debug;
- Narrative scroll;
- gameplay typography.

If known G3 Context assertions still fail, reproduce them on the exact Formal Code Base and preserve them as baseline debt; do not suppress or repair them inside MW-029.

### 9.7 Import/export

Before return:

- final Godot 4.7.2 import;
- fresh Windows export;
- `run-game.ps1 -ValidateExportOnly`;
- verify EXE/PCK/SQLite DLL non-empty;
- record task-local PCK hash/freshness;
- do not launch Owner game;
- do not install Owner build.

## 10. Real Provider evidence

Real Provider calls are **not required for Engineering PASS** because deterministic tests can prove protocol/currentness/persistence and Owner has deferred Product confirmation.

If the existing configured Provider can be safely sampled without touching Owner Game, a small isolated semantic smoke may be recorded as supplemental Product evidence. It must not become a blocker, must not add retry/rule hacks to force a preferred result, and must not be used to claim Product PASS.

## 11. Product Value Acceptance

Primary product value for this increment:

> Player possessions should become dependable game facts that can be acted on later, not fragile prose details that the UI and GM may forget or contradict.

Engineering can prove the owner/currentness/context/UI mechanics. It cannot fully prove whether a real model naturally extracts item acquisition/removal at the right semantic granularity during varied play.

Deferred Owner/Product evidence should eventually judge:

- does `行囊` contain things the player genuinely considers “what I currently carry” rather than every mentioned object;
- does it remove/update items naturally when play changes possession;
- does the GM actually respect the visible Inventory in later action/OOC;
- does the surface feel useful without turning the game into a rigid item-management UI.

Failure signals are Product failures, not mere polish:

- model routinely adds environmental/non-owned objects;
- consumed/transferred/lost items persist for many turns;
- GM denies or forgets items visible in `行囊`;
- free-form item use is constrained by a Program whitelist.

Per current Owner instruction, this Product confirmation may be concentrated into Package 7 Reality Gate unless Owner asks sooner.

## 12. Git / worktree / return protocol

- Work only in `D:/AI/Projects/.worktrees/my-world/mw-029-factual-inventory` on branch `mw-029-factual-inventory`.
- Do not modify Owner canonical checkout.
- Do not force push/reset/clean destructively.
- Preserve unrelated local/unknown files.
- Commit production implementation separately from evidence/return documentation where practical.
- Push branch and verify remote SHA.
- Do **not** merge `main`.
- Do **not** install Owner build.
- Do **not** claim Product PASS.

Return exactly:

```text
READY FOR INDEPENDENT REVIEW

Starting: <sha>
Implementation: <sha>
Final candidate: <sha>
Focused/window/regression summary
Godot import/export/ValidateExportOnly summary
Real Provider calls: <n>
Known baseline failures/notes
```

Include a repository-native `docs/mw029/MW-029_IMPLEMENTATION_RETURN.md` and task-owned evidence.
