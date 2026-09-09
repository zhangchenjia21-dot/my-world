# TASK｜MW-030｜Internal Dynamic UI Host v0.1 + Model-curated Visibility Preference

Type: G6 Package-6 core presentation convergence  
Work Item: **MW-030**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Owner UAT: **deferred / combined with Package 7 concentrated Reality Gate unless Owner requests sooner; implementer must not claim Product PASS**  
Required branch: `mw-030-internal-dynamic-ui-host`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-030-internal-dynamic-ui-host`  
Formal Code Base: `396bfcc0c91cdff6e6816795826b95fa0c0d358c`  
Governance Base at Task Shape: `88c8581cbd02823e53e72e7fb2d28f089b4da5fb`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_INTERNAL_DYNAMIC_UI_HOST_V0_1_DECISION.md@v1.0`  
Visibility authority: `Vibe-Coding/my world/architecture/ui/G6_MODEL_CURATED_SURFACE_VISIBILITY_PREFERENCE_DEFERRED_DECISION.md@v1.1`  
Parent route: **G6 Package 6｜Internal Dynamic UI Host v0.1**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Product outcome

Implement the first **production Internal Dynamic UI Host** from the real information surfaces that now exist.

After this task:

```text
Character / Important Experiences / People / Open Threads / Inventory / System
→ domain-owned player-safe DTO
→ first-party bounded presentation definition
→ one shared Internal Dynamic UI Host
→ Godot Controls
```

The Player-facing information architecture remains:

```text
概览 | 角色 | 重要经历 | 人物 | 事务 | 行囊 | 系统 | 存档
```

The same task also activates the Owner-approved presentation visibility right for the first two domains that have safe stable presentation identity:

```text
People cards
Important Experience entries
→ 隐藏
→ 已隐藏 (N)
→ 恢复显示
```

Hide is **presentation only**. It must not delete semantic information, influence the model, rewind with Restore, or become a generic action system.

This is the final shared-presentation capability before the V0 Core Closure Reality Gate. It is not a UI redesign project and not an external Mod/UI platform.

## 2. Why now

Earlier `MW-013 Internal Declarative UI Host v0.1` was intentionally held because it had only two old consumers and was shaped before the current information architecture existed.

It is now superseded.

The current product has six grounded repeatable surface classes:

- Character;
- Important Experiences;
- People;
- Open Threads;
- factual Inventory;
- System/Public d20.

Their bespoke renderers demonstrate real repeated presentation needs: wrapped text, sections, lists, cards, collapsed People details, empty states, scrollability and structured mechanic fields.

Package 6 therefore has enough consumer evidence to extract a bounded Host without guessing a future external schema.

## 3. Authority / Source Manifest

Authority order for this task:

1. Owner's latest explicit instruction;
2. `Vibe-Coding/AGENTS.md`;
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md` after refresh;
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.8`;
5. `Vibe-Coding/my world/architecture/ui/G6_INTERNAL_DYNAMIC_UI_HOST_V0_1_DECISION.md@v1.0`;
6. visibility decisions v1.1 / People specialization;
7. current implementation code/tests at Formal Base;
8. repository `AGENTS.md` and current GPT Skills.

Historical only / not executable authority:

- `G6_INTERNAL_DECLARATIVE_UI_HOST_V0_1_DECISION.md@0.1` — **SUPERSEDED**;
- old `MW-013_INTERNAL_DECLARATIVE_UI_HOST_V0_1_TASK.md` — **DO NOT EXECUTE**;
- archived/legacy UI plans.

## 4. Freshness gate

Before production edits:

1. fetch implementation `origin/main` and governance `main`;
2. verify implementation Formal Base `396bfcc0c91cdff6e6816795826b95fa0c0d358c` is still the intended Package-6 base;
3. read the current status and current Package-6 architecture;
4. propagate any newer Owner/GPT decision before editing;
5. STOP only for a real superseding product/architecture decision, incompatible main advance, or unresolved authority/currentness blocker.

Do not silently merge unrelated newer implementation work into the task branch.

## 5. Read first

Initial bounded read set:

### Governance

1. `Vibe-Coding/AGENTS.md`
2. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
3. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.8`
4. `Vibe-Coding/my world/architecture/ui/G6_INTERNAL_DYNAMIC_UI_HOST_V0_1_DECISION.md@v1.0`
5. `Vibe-Coding/my world/architecture/ui/G6_MODEL_CURATED_SURFACE_VISIBILITY_PREFERENCE_DEFERRED_DECISION.md@v1.1`
6. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_CARD_VISIBILITY_PREFERENCE_DEFERRED_DECISION.md@v1.1`
7. `Vibe-Coding/my world/architecture/ui/声明式UIHost设计.md` only as supporting history; current decision wins on conflicts.

### Implementation

1. repo `AGENTS.md`
2. `src/应用壳.gd`, `src/main.tscn`
3. `src/ui/人物卡片.gd`, `事务列表.gd`, `行囊列表.gd`, `系统判定列表.gd`
4. Character / Experiences rendering path currently inside `src/应用壳.gd`
5. player-safe L3 projections for Character/Experiences, People, Threads, Inventory, System
6. their L1 folds only where needed to add safe opaque presentation identity
7. MW-023 typography tests and current MW-027/028/029 real-window tests
8. existing Save/Restore, Narrative, Debug and right-nav tests relevant to the touched Shell path.

Only expand reads when evidence is insufficient; explain why if expanded materially.

## 6. Decision digest / invariants

### INV-PRODUCT-01｜Narrative remains primary

The shared Host must reduce duplicated presentation plumbing without taking visual space or control away from Narrative. It must not make information panels more dominant than current product behavior.

### INV-UI-01｜UI never becomes truth owner

Definitions and rendered nodes are disposable presentation material. They never become a second Character/People/Thread/Inventory/Mechanics state.

### INV-UI-02｜Safe DTO before definition

The common Host/leaf renderer receives only bounded presentation definitions derived from domain-owned **player-safe L3 DTOs**. It must not receive Runtime/raw `world_state` and filter truth locally.

### INV-UI-03｜Internal-only

Definitions are first-party program-internal. World/Character/Expansion/Mod packages cannot provide UI definitions in G6.

### INV-UI-04｜No executable definition language

No arbitrary callback/method name, NodePath, expression/binding, SQL/query, filesystem/OS command, Provider call, arbitrary resource path or direct mutation capability in definition data.

### INV-SEM-01｜No semantic redesign

Migration must preserve existing Character, Important Experiences, People, Open Threads, Inventory and System semantics/currentness.

### INV-VIS-01｜Hide != delete

People/Experience hide suppresses ordinary rendering only. Underlying projections/data remain intact, continue updating, and remain legitimate model inputs where already allowed.

### INV-VIS-02｜Visibility preference is not Timeline truth

Hide persists across reopen and does **not** rewind on Restore. It is Game-local presentation preference outside gameplay Timeline state.

### INV-VIS-03｜No text identity

Never identify hidden units by display name, title equality, rendered content hash or list position alone.

### INV-VIS-04｜Bounded eligible set

v0.1 hide only:

- People;
- Important Experiences.

Do not add hide controls to Character, Open Threads, Inventory, System, Debug, Recommendations or errors.

### INV-ROUTE-01｜No old MW-013 resurrection

Do not implement the old two-consumer MW-013 packet or restore its stale assumptions. Reuse only safety lessons that remain compatible with the current Package-6 architecture.

## 7. Bounded internal UI vocabulary

Implement the smallest closed vocabulary that can render current production consumers. Semantics should be equivalent to:

```text
section
text
fact_list
field_list
card
```

Exact names may differ.

### `section`

- bounded `component_id`;
- optional/required bounded title;
- ordered bounded children.

### `text`

- bounded text;
- closed emphasis/style role only, e.g. `body | heading | muted`;
- no arbitrary markup/expression execution.

### `fact_list`

- optional bounded title;
- ordered bounded strings;
- presentation bullet/list only.

### `field_list`

- optional bounded title;
- ordered `{label,value}` pairs;
- no typed gameplay values or mutation semantics.

### `card`

- bounded title/subtitle as genuinely needed;
- ordered children;
- fixed `collapsible` boolean where current People behavior requires it;
- optional **opaque presentation visibility key** only for approved hideable cards.

The component definition MUST NOT contain arbitrary click actions. Hide/recover is a Host-owned fixed first-party action activated only by validated visibility metadata.

Do not add meter, badge taxonomy, generic actions, map, form controls, arbitrary grid/table language or extension registry.

## 8. Validator / failure behavior

Create a deterministic bounded validator/materializer.

At minimum prove:

- known kinds only;
- exact known fields;
- safe non-empty component IDs;
- duplicate component IDs reject the definition/contribution safely;
- bounded recursion depth;
- bounded component/list/string sizes;
- enum/boolean values restricted to the closed contract;
- arbitrary nested dictionaries rejected;
- executable-looking unknown fields cannot cause behavior;
- malformed/unsupported definition fails soft locally and never blocks Narrative, Save, World semantics or domain projection.

Do not build JSON Schema infrastructure or external version negotiation.

## 9. Production surface migration

Migrate production rendering for the targeted six surfaces through the common Host unless an independently evidenced blocker requires a narrower subset. The minimum acceptable integrated result is **at least three distinct real surface classes using the same renderer**, but a deliberate failure to migrate one of the six must be documented with concrete technical evidence and must not leave an unsafe hybrid abstraction.

### 9.1 Character

Input: current Character player-safe L3 projection.

Preserve:

- headline;
- summary;
- model-owned groups/titles/items;
- quiet empty state;
- no inventory/People/live mechanics contamination.

No hide controls in v0.1.

### 9.2 Important Experiences

Preserve sparse milestone order/title/description and no fake turn/date label.

Add stable opaque presentation key for each current milestone using legitimate current curation record identity + event ordinal (or an equivalent Program-owned stable derivation).

Do not expose raw record ID.

Eligible for hide/recover.

### 9.3 People

Preserve current five player-safe display fields and default-collapsed card behavior.

Add a presentation-specific safe projection that exposes an opaque presentation key derived from the exact stable Game-local actor identity. Do not expose raw actor/local ID to the renderer/preference file.

Same-name actors must remain independently hideable.

Eligible for hide/recover.

### 9.4 Open Threads

Preserve title/summary/details and current model-owned replacement semantics.

Do **not** add per-Thread hide. Current Thread contract has no stable item identity; do not use title/text/index as a substitute.

### 9.5 Inventory

Preserve exact current factual `name + summary`, honest empty baseline and read-only behavior.

No hide control. No item action buttons.

### 9.6 System / Public d20

Preserve exact Program-owned CHECK facts, newest-first/max12, empty state and current field labels/math.

No hide control. Inline Narrative dice card remains unchanged and outside the common surface renderer.

### 9.7 Bespoke renderer retirement

Once a production surface is fully migrated and tests prove equivalence, retire/delete its now-unused bespoke renderer when safe. Do not maintain two live production rendering paths for the same surface merely to reduce diff size.

Do not perform unrelated Shell-wide refactoring.

## 10. Opaque presentation identity

### People

Use a deterministic opaque key derived from legitimate stable actor identity and Game scope, for example conceptually:

```text
sha256("people|" + game_id + "|" + stable_actor_id)
```

The exact algorithm may differ but must be deterministic, scoped and opaque.

### Important Experiences

Use a deterministic opaque key derived from the validated curation record identity + event ordinal, conceptually:

```text
sha256("experience|" + game_id + "|" + current_record_id + "|" + ordinal)
```

Do not use event title/description content as identity.

Presentation keys:

- are UI identity only;
- do not become model inputs;
- do not become world/entity IDs;
- may be visible to the Host/preference owner but need not be displayed to Player.

## 11. Presentation preference owner

Implement one small Game-local visibility-preference owner outside Timeline gameplay state.

Recommended default root:

```text
user://my-world/presentation-preferences/
```

Scope by current `game_id` and a small validated schema such as:

```text
ui_visibility.v0.1
hidden_by_surface:
  people: [opaque_key...]
  important_experiences: [opaque_key...]
```

Exact shape may differ but must remain bounded and store **only opaque keys / preference metadata**, never copied People/Experience prose.

Requirements:

- ordinary reopen/Continue preserves hide state;
- Restore does not rewind it;
- no SQLite gameplay table/column;
- explicit hide/recover is the only writer;
- rendering/tab switching does not write;
- corrupt preference file fails soft to visible/default behavior without harming Game data;
- safe/atomic replacement or equivalent bounded write behavior;
- a task-owned test root/override must be available so tests never touch Owner preference files.

Do not turn this into a general settings framework.

## 12. Fixed hide / recovery UX

The Host may have a closed fixed mechanism such as:

```text
card with validated visibility key
→ fixed 隐藏 button
→ Host emits hide_requested(surface_id, opaque_key)
→ Shell/presentation owner updates preference
→ surface re-renders
```

No callback name/method path comes from definition data.

Each eligible surface with current hidden items must expose a bounded recovery path:

```text
已隐藏 (N)
→ current hidden cards/items
→ 恢复显示
```

Hidden area can be collapsed by default.

A hidden card that has changed semantically since hiding must remain hidden and, when shown in the hidden drawer/recovered, display its **current** content rather than a stale stored copy.

## 13. Currentness and refresh

The Host owns no semantic cache/currentness.

On activation, Curator terminal, World semantic terminal, accepted-history replacement, Restore and relevant tab navigation, definitions are rebuilt from each current domain projection exactly as existing Shell refresh ownership requires.

Visibility preference filtering happens only after the current safe projection exists.

If a hidden semantic item is no longer current due to Restore/Regenerate, it simply does not render. Its separate hide preference may remain stored so the same legitimate stable item stays hidden if it becomes current again.

## 14. No Provider / domain expansion

This task must add **zero Provider calls**.

Do not:

- route layout through a model;
- ask the Information Curator to produce UI definitions;
- make hide state a curation prompt input;
- add new gameplay truth/state;
- add new SQLite gameplay storage;
- add Thread identity merely for hide;
- add Character item/group identity merely for hide.

## 15. Focused deterministic acceptance

Create a non-vacuous MW-030 focused suite exercising production Host/Shell and actual domain projections.

### 15.1 Host contract

Prove valid definitions render expected Godot Controls/text for every implemented kind.

Prove fail-soft rejection for at least:

- unknown kind;
- unknown field;
- duplicate component ID;
- excessive recursion;
- oversized string/list/component count;
- arbitrary callback/NodePath/expression/resource/query-looking fields.

No rejected definition may execute anything or block Narrative.

### 15.2 Real surface convergence

Using real production Shell + isolated Runtime/SQLite fixtures, prove at least three and preferably all six targeted surfaces actually instantiate/render through the shared Host class/path, rather than copying its vocabulary into separate bespoke renderers.

Prove content equivalence for:

- Character current sheet;
- Important Experiences;
- People collapsed card;
- Threads;
- Inventory;
- System d20 history.

### 15.3 People visibility

Prove with two stable same-name People actors if feasible:

- opaque presentation keys differ;
- no raw actor ID or display-name matching owns hide identity;
- hide one card and only that card leaves visible area;
- underlying People projection still contains it;
- later People snapshot update keeps it hidden;
- hidden drawer shows updated current content;
- recover shows current content;
- reopen preserves hide;
- Restore does not rewind hide preference;
- hide/recover causes zero Provider calls and zero Game/Timeline mutation.

### 15.4 Important Experiences visibility

Prove:

- opaque key is based on legitimate stable curation record/event identity, not title/text/index-only identity;
- hide affects only presentation;
- underlying milestone projection remains current;
- reopen preserves hide;
- Restore does not rewind preference;
- if the milestone becomes non-current it disappears naturally; when the same stable milestone becomes current again its hide preference still applies;
- recover displays current projection;
- no Provider or gameplay mutation from hide/recover.

### 15.5 Non-hideable protection

Prove no generic hide control appears for:

- Inventory;
- System;
- Open Threads;
- Character.

Do not add per-Thread key/hide via text hashing.

### 15.6 Currentness/regressions

Prove Restore/Regenerate semantics of each migrated domain remain owned by the existing safe projection. Dynamic Host definitions must not freeze stale copies.

## 16. Real-window acceptance

At minimum exercise real production Shell at:

```text
960×540
1280×720
1920×1080
```

Include realistic populated states for multiple migrated surfaces plus hidden-item recovery UI.

At all sizes prove:

- ordinary gameplay visible text >=20px;
- no inaccessible horizontal overflow;
- long content remains vertically reachable;
- People collapse remains usable;
- hidden drawer/recover remains reachable;
- Narrative composer remains usable;
- no empty Player Status Host is forced open;
- eight nav tabs remain usable.

Screenshots should be captured for review evidence, but automated geometry/text assertions remain required.

## 17. Regression gates

Run directly affected suites including at least:

- MW-014/015 Character + Important Experiences;
- MW-018 People + R1 eligibility;
- MW-027 Open Threads;
- MW-028 System/Public d20;
- MW-029 Inventory;
- MW-022 Debug;
- MW-023 typography;
- MW-021 Narrative scroll;
- MW-024 OOC;
- MW-025 recommendations;
- G2 Conversation/Narrative critical path;
- G3 Save/Restore/currentness paths touched by Shell refresh/navigation.

Known G3 Context failures may remain only if reproduced on an isolated exact Formal Base; do not suppress or silently repair unrelated debt.

## 18. Build / Git evidence

Before final return:

- worktree clean;
- candidate pushed and remote SHA exact;
- `git diff --check` clean;
- Godot 4.7.2 final import;
- fresh Windows export;
- `run-game.ps1 -ValidateExportOnly`;
- EXE/PCK/SQLite DLL non-empty;
- record fresh PCK hash/freshness;
- do not launch Owner game;
- do not mutate Owner canonical Game/Source/settings/preferences.

## 19. Explicit non-scope

Do not implement:

- external Source/Expansion/Mod UI definitions;
- G8 authoring/schema/versioning;
- generic Action Intent;
- arbitrary UI DSL/plugins;
- new semantic surfaces/domains;
- Thread stable identity redesign;
- per-Thread hide;
- Character group/item hide;
- Inventory/System hide;
- portrait/scene/map Visual Runtime;
- Map Surface;
- new Provider calls;
- new gameplay SQLite owner;
- G3 Context debt cleanup;
- full Shell rewrite;
- unrelated visual redesign/polish.

## 20. Return protocol

Return:

- Starting HEAD;
- Production Implementation HEAD;
- Final candidate HEAD;
- exact pushed branch SHA / clean status;
- actual component vocabulary and validator bounds;
- list of real surfaces migrated through the common Host;
- evidence no raw Runtime/world enters leaf renderer;
- preference-store path/schema/test override;
- opaque People/Experience presentation identity method;
- visibility behavior/reopen/Restore evidence;
- proof no System/Inventory/Thread/Character accidental hide;
- focused + real-window counts/results;
- regression manifest including any exact-baseline failures;
- final Godot import/export/freshness/PCK hash;
- confirmation real Provider calls = 0;
- residual Product evidence.

Do not merge `main`.
Do not install Owner build.
Do not claim Product PASS.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**
