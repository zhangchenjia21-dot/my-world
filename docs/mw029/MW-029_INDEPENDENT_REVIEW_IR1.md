# MW-029｜Independent Review IR1

Status: **ENGINEERING PASS_WITH_NOTES**

Reviewer: GPT  
Work Item: **MW-029｜Factual Inventory Vertical / 事实型行囊**  
Formal Code Base: `f6aae06f6be3be4b7fd24762a10e524b6eb9b683`  
Task Packet / Starting HEAD: `574f6ecff87c401d35a8d9e5b95f9edbfecc4fd6`  
Production Implementation HEAD: `5ea0ed9e8826aa51f4900e8e96b10e8cf0c67f0e`  
Submitted Final Candidate: `4c2529ab845db056ef291843a31314e77813ac91`  
Frozen architecture: `Vibe-Coding/my world/architecture/ui/G6_FACTUAL_INVENTORY_VERTICAL_V1_0_DECISION.md@v1.0`

## 1. Freshness / lineage

Independent Review refreshed both canonical repositories before verdict:

- implementation `my-world/main` remained exactly the Formal Code Base `f6aae06f6be3be4b7fd24762a10e524b6eb9b683`;
- governance `Vibe-Coding/main` remained `3c469d9826715dcdd8840f6379cc862c48ba8f77`, current status v17.24 / roadmap v4.7, with MW-029 current and the factual Inventory decision still `FROZEN / CURRENT` v1.0.

The submitted branch is three commits ahead of the Formal Base. The production implementation is `5ea0ed9...`; the final candidate adds task evidence/documentation after the implementation and contains no later unreviewed production mutation.

## 2. Independent architecture / product audit

### 2.1 Factual truth ownership — PASS

Inventory is implemented as a narrow factual gameplay domain rather than Character/Curator prose or a UI-derived list.

The existing World semantic lane remains the sole model opportunity. It receives accepted Player/GM material plus current request-only Inventory references and may return optional ADD/UPDATE/REMOVE facts in that same response. No Inventory Curator, second Provider request, keyword/regex possession classifier or UI-side Narrative parsing is introduced.

The model decides whether the accepted Narrative actually established possession/state change; Program owns normalized event structure, stable identity, exact references, persistence and currentness.

### 2.2 No invented initial inventory — PASS

No initial items are inferred from Character/T0 prose and no default clothes/money/weapons/food are fabricated. With no authoritative Inventory event, the structured Inventory projects empty.

This preserves the frozen boundary and does not prematurely expand the Source/Creator external contract.

### 2.3 Stable item identity / opaque refs — PASS

New item IDs are Program-owned deterministic SHA-256 identities derived from the accepted turn version, candidate ordinal and bounded material. Models cannot submit `item_id` because response shapes are exact-field validated.

Existing items are exposed to the semantic request through fresh request-only `item_ref` values. Ref resolution checks the exact pre-request item snapshot. Unknown, duplicate or stale refs fail soft and do not fall back to display-name matching. Same-name items therefore remain independently addressable.

### 2.4 Event-sourced currentness — PASS

Durable Inventory is stored as version-bound events inside the existing Game-local World/Timeline document rather than as a second SQLite owner or unversioned mutable `current_items` list.

Each event binds:

- source turn index;
- accepted prefix;
- accepted GM SHA-256;
- exact normalized operations;
- deterministic content ID.

Current Inventory is obtained by folding only events whose source version still matches current accepted Conversation. Corrupt events fail soft. UPDATE/REMOVE cannot resurrect an item absent from earlier current events.

The implementation conservatively binds events to the accepted prefix as well as the source GM hash, so replacing earlier accepted history invalidates dependent later Inventory events rather than leaking stale possession. This is consistent with current Timeline/currentness safety.

### 2.5 Atomic World semantic commit — PASS

Inventory is added to the same candidate World snapshot after existing world/knowledge/actor/identity material is assembled, and the existing one durable World mutation commits the combined candidate.

There is no Inventory-specific write path, table or second Timeline mutation. Invalid optional Inventory data is isolated: otherwise-valid World semantics can still commit while Inventory reports `invalid_inventory`; no partial invalid item operation is committed.

### 2.6 Foreground gameplay grounding — PASS

The same player-safe current Inventory projection feeds:

- ordinary continuation;
- OOC continuation;
- Public d20 control/control recovery;
- Public d20 CHECK/NO_CHECK/degraded narrative stages.

Only current `name + summary` material enters these contexts. Raw event records, `player_inventory`, item IDs, item refs and turn maps are not exposed. World-only Evolution does not gain Player-private Inventory material.

This closes the key product contradiction where the UI could know an item exists while the next GM/mechanics request did not.

### 2.7 `行囊` Surface — PASS

World Information navigation is now:

`概览 | 角色 | 重要经历 | 人物 | 事务 | 行囊 | 系统 | 存档`.

`行囊` is read-only and renders `当前行囊`, `name + summary`, or `当前没有已记录的随身物品。`. It adds no use/equip/drop buttons, checkbox, search/sort, capacity meter or fake RPG properties. Players continue to manipulate possessions through free-form role actions.

The leaf consumes only detached L3 safe DTOs and never receives Runtime/raw World for local filtering.

### 2.8 Refresh / Restore / Regenerate / reopen — PASS

Inventory refresh reuses the existing safe-panel refresh after World semantic terminal, so pending semantic proposals are never shown as facts.

Focused evidence proves:

- ADD appears only after semantic durable terminal;
- Save/Restore before and after possession changes projection immediately;
- a real accepted Regenerate replacement invalidates the old Inventory event before replacement semantics settle;
- late semantic callbacks cannot cross a Restore epoch;
- close/reopen reconstructs the same current Inventory;
- reopen does not trigger historical semantic backfill.

### 2.9 Debug inventory lane — PASS

Debug extends the existing World semantic observer with a bounded `inventory` lane. It reports safe structural counts (`added/updated/removed/total`) and committed/no-change/failed/cancelled semantics without exposing item prose, IDs, refs, raw model output or private canaries.

OOC does not create a semantic/Inventory opportunity. Restore epoch handling prevents stale late callbacks from publishing current diagnostics.

## 3. Independent test-quality audit

The focused suite exercises production Runtime, SQLite, Shell, World semantic worker, Inventory L3/fold, foreground context assembly and Debug observer with controlled Provider stubs; it is not a test-only replacement implementation.

High-value assertions include:

- empty truthful baseline;
- ADD/UPDATE/REMOVE/no-change use;
- deterministic replay/no duplicate item;
- same-name distinct items;
- exact, unknown, duplicate and stale ref behavior;
- corrupted event rejection;
- replaced/OOC source invalidation;
- exact bounds and optional-subfield isolation;
- one combined World + Inventory Timeline commit;
- pending semantic not visible;
- safe Inventory in action/OOC/all d20 stages with zero extra Provider calls;
- World-only exclusion;
- Restore both directions, Regenerate invalidation, late-callback epoch isolation;
- real close/reopen and no backfill;
- 64-item defensive-bound scrolling and eight-tab UI behavior;
- Debug privacy canaries.

Recorded focused and real-window suites each report **174 checks / 0 failures**.

## 4. Regression / build audit

The direct regression batch contains 43 suites:

- **41 pass**;
- G3-03 still fails `opaque World JSON is not injected as Game Context`;
- G3-05 persistence still fails `raw World/Prompt truth leaked into Context`.

Both failures were reproduced on an isolated archive of the exact Formal Code Base `f6aae06f...`; they are retained Context debt rather than MW-029 regressions.

Known teardown/resource warnings remain in their pre-existing suites and are not new Inventory blockers.

Godot 4.7.2 final import passes. Fresh Windows export and `run-game.ps1 -ValidateExportOnly` pass. Task-local EXE/PCK/SQLite DLL are present and non-empty; recorded PCK SHA-256 is `746a3825017ad56f8db20f1cab0a2efd56918b330c60d99a47794e8b1f7a98da`.

## 5. Findings

No blocking engineering defect found.

No frozen-architecture rollback found:

- no invented initial gear;
- no second Inventory truth/store;
- no extra Provider call;
- no Program semantic possession rules;
- no display-name identity fallback;
- no raw Inventory owner/ID/ref leakage into leaf/foreground context;
- no Inventory mutation controls in UI;
- no World-only authority expansion;
- no Save/Restore/Regenerate currentness regression found.

## 6. Notes / remaining Product evidence

### N-01｜Real-model Inventory semantic quality remains Product evidence

MW-029 intentionally used zero real Provider calls. Engineering proves the authority, persistence, currentness, context and UI vertical, but not varied real-model judgment quality for naturally distinguishing possession from mention, choosing UPDATE vs REMOVE, or staying quiet when nothing changed.

This remains Owner/Product evidence for the later concentrated UAT / Package 7 Reality Gate.

### N-02｜Conservative dependent-currentness

Inventory events bind the accepted prefix, so replacing earlier accepted history conservatively invalidates later dependent Inventory events. This prioritizes stale-state safety and is not a blocker for the current V0 vertical; future broader correction semantics may revisit dependency granularity if real product evidence requires it.

### N-03｜Known G3 Context debt remains

The two exact-baseline G3 Context failures remain retained debt. Do not interrupt the Core-first route with unrelated cleanup.

## 7. Verdict

**ENGINEERING PASS_WITH_NOTES**

MW-029 is safe to integrate by non-force fast-forward from the exact Formal Code Base through this reviewed branch lineage.

This verdict does **not** claim Product PASS. Proper post-integration state:

> **Package 5 / MW-029 = ENGINEERING PASS_WITH_NOTES / INTEGRATED / PRODUCT CONFIRMATION DEFERRED**

Per the current Core-first route, proceed directly to Package 6 `Internal Dynamic UI Host v0.1` architecture/task shaping rather than requesting standalone Owner UAT now.
