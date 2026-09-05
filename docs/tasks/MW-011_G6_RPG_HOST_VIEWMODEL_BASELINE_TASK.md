# TASK｜MW-011｜G6 RPG Host ViewModel Baseline

Type: implementation / UI-information-architecture / first G6 vertical  
Work Item: **MW-011**  
Name: **G6 RPG Host ViewModel Baseline**  
Capability-Anchor: **G6 RPG Experience & Internal Declarative UI Host**  
Triggered-By: **Owner G5-GATE PASS + final UAT observation that MW-009 side panels are safe/dynamic but too information-thin**  
Implementer: **Zcode + GLM-5.3-flash**（Owner weekend routing override through 2026-09-06 23:59 +08:00）  
Reviewer: **GPT**  
Revision: **1**  
Review-Round: **0**  
Formal Code Base: `my-world/main@23811d8b8b8fc2cbd3f042dca26854e04df7551c`  
Governance / Architecture Base: `Vibe-Coding/main@a780de37b98ff8f156b9cf4cb30e68130136201f`  
Task Branch: `mw-011-g6-rpg-host-viewmodel-baseline`  
Required worktree: `D:/AI/Projects/.worktrees/my-world/mw-011`  
Status: **ACTIVE — ZCODE**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Start G6 with the canonical first step:

```text
Runtime projection
→ presentation-only ViewModel
→ real RPG UI consumer
```

Turn the existing MW-009 thin side panels into a first useful Player Host / World Surface information experience **without fabricating new RPG domain state** and without starting the generic Declarative UI Host yet.

Canonical architecture:

`Vibe-Coding/my world/architecture/ui/G6_RPG_HOST_VIEWMODEL_V0_1_DECISION.md`

G5 is closed. Do not reopen G5 or MW-009 merely because G6 now needs richer presentation.

## 2. Read first

1. root `AGENTS.md`;
2. `Vibe-Coding/AGENTS.md`;
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`;
4. `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md` G6 section;
5. `Vibe-Coding/my world/architecture/ui/声明式UIHost设计.md`;
6. `Vibe-Coding/my world/architecture/ui/G6_RPG_HOST_VIEWMODEL_V0_1_DECISION.md`;
7. `docs/g5_gate/G5_GATE_CLOSEOUT.md`;
8. `docs/mw009/MW-009_INDEPENDENT_REVIEW_IR1.md`;
9. actual current `src/应用壳.gd`, player-safe projection module, Narrative host, Save/Restore UI and current responsive layout code.

Do not read unrelated subsystems merely for completeness.

## 3. Worktree hygiene

Before starting:

1. refresh both repository `main`s;
2. inspect `git worktree list --porcelain`;
3. MW-005 R4 is reviewed and integrated; remove its worktree only if clean, pushed/reachable/integrated and free of unknown user work;
4. use `git worktree remove`, then `git worktree prune`;
5. create exactly:

`D:/AI/Projects/.worktrees/my-world/mw-011`

6. branch:

`mw-011-g6-rpg-host-viewmodel-baseline`

Do not create task worktrees directly under `D:/AI/Projects/`.

## 4. Mandatory two-pass audit before implementation

### Pass A — current presentation/lifecycle

Trace the exact current production owners for:

- PlayerPanelHost / WorldSurfaceHost construction;
- MW-009 player-safe projection refresh on activation/reopen, semantic terminal and Restore;
- accepted Conversation entry shape/currentness;
- Save control ownership and Save/Load/Restore callbacks;
- wide/narrow responsive switching;
- current visual Theme inheritance.

Record the actual functions/signals in evidence.

### Pass B — safe data candidates

Classify each candidate field by authority and disclosure before rendering it.

At minimum inspect:

```text
Player identity / selected profile
World / selected Entry identity
current accepted Player action texts
current accepted-turn count
Player Character known_facts from MW-009
Save display metadata / existing save UI state
NPC Knowledge
raw semantic consequences
Agency actions
World Evolution
GM/source instructions
Literary Style Reference
internal IDs/hashes/fingerprints
Public-d20 control/proposal payload
```

Only the first safe/player-owned set may enter the G6 v0.1 ViewModel. Hidden/omniscient families remain excluded.

Do **not** expose Character `gm_reference` semantic sections merely because the Character is Player-controlled.

## 5. Required ViewModel semantics

Introduce the smallest clear presentation-only ViewModel seam needed by the two side Hosts.

The ViewModel must be:

- deterministic;
- side-effect free;
- non-durable;
- not a second state store;
- no Provider call;
- no SQLite schema/table;
- current timeline / Restore aware;
- built from explicit safe inputs rather than a filtered omniscient `world_state` copy.

The conceptual output must support at least:

```text
Player Host
- player display name
- selected profile label
- safe current World / Entry context
- recent accepted Player actions (bounded, current timeline only)
- accepted Player-turn count

World Overview
- world display name
- selected Entry label
- current Player Character known facts (existing MW-009 boundary)
- accepted Player-turn count
```

Exact internal field names are not frozen.

### Recent Player actions

Use current durable accepted Conversation entries only.

Rules:

- only non-empty Player-authored action text;
- restored-away / regenerated-away entries must not appear;
- bounded to a small product-friendly count, recommended **3–4**;
- exact authored content remains authoritative; any UI ellipsis/truncation is disposable presentation only;
- no model summarization.

## 6. Required Player Host product behavior

Replace the current sparse identity-only presentation with a clear bounded information hierarchy.

At minimum the Player Host should visibly answer:

```text
主角是谁？
这一局处于什么 World / Entry？
最近做了什么？
已经进行了多少个 Player turns？
```

Do not fake:

- HP / stamina;
- current location;
- inventory;
- relationship values;
- faction rank;
- quest state;
- wounds/status;
- numeric attributes;
- resources.

Those require later real G6 domain consumers.

The target is that after several ordinary turns the Player Host no longer consists of two short lines surrounded by dead space.

## 7. Required World Surface product behavior

Create bounded internal navigation for exactly the first two real surfaces:

```text
概览
存档
```

### 概览

Default surface. Show safe World/Entry identity plus current Player-known facts and small safe session metadata.

### 存档

Reuse the existing Save controls and current G3 semantics. This task may rearrange/present them but must not redesign Save/Load/Restore authority or persistence behavior.

The current always-visible Save block must no longer dominate the default World information hierarchy.

Do not add Map / Faction / Relationship / Inventory / Quest placeholder tabs merely to make navigation look complete.

## 8. Preserve disclosure and authority

The following must remain absent from leaf UI/ViewModel data unless a future explicit capability authorizes them:

- NPC-only Knowledge;
- raw `semantic_turns_by_index` consequences;
- Agency actions;
- World Evolution events;
- GM/source instructions;
- Literary Style Reference;
- Source IDs / local IDs / hashes / fingerprints;
- Public-d20 control/proposal payload;
- arbitrary raw `world_state`.

World truth becoming durable does not automatically make it player-visible.

## 9. Explicit non-scope

Do not add in MW-011:

- Internal Declarative UI Host / component DSL;
- external World Pack / Mod UI schema;
- generic ViewModel framework/platform;
- generic event bus/reactive store;
- Runtime Asset Resolution;
- portrait / scene / authored-map loading;
- Character/Relationship/Inventory/Faction/Quest/Map domain systems;
- Expansion mechanic state UI;
- new persistence tables;
- Provider summarization;
- Narrative gate/parser/classifier/retry;
- new Save/Timeline semantics;
- unrelated visual redesign.

A small task-owned or product-owned ViewModel module is expected; a generalized platform is not.

## 10. Focused proof expectations

Use a real FinalCreate Three Kingdoms Game + real Runtime/SQLite + real Shell where practical.

At minimum prove:

1. fresh valid Game renders Player identity/profile + World/Entry context through the new ViewModel;
2. after 2+ accepted Player turns, bounded recent Player actions appear and update without reopen;
3. Player-turn count is deterministic and excludes GM-only Opening;
4. World Overview is the default right surface and Save controls are not shown as the default Overview content;
5. switching to Save exposes the existing functional Save UI;
6. create Save / refresh selector / load confirmation behavior remains connected to existing G3 owners;
7. Player-known fact appears after normal Knowledge materialization;
8. NPC-only Knowledge / raw consequence / Agency / Evolution remain absent from both ViewModel and visible Hosts;
9. Save/reopen reconstructs the same current ViewModel;
10. Restore removes restored-away recent Player actions and known facts from the ViewModel/UI;
11. no internal ID/hash/fingerprint/instruction/style material leaks;
12. no new Runtime truth store or SQLite schema/table;
13. existing MW-009 focused suite remains green;
14. MW-010 integrated matrix remains green;
15. responsive behavior remains usable at maximized desktop, 1280x720 and narrow regression width;
16. `git diff --check` clean;
17. Windows export PASS because production UI GDScript/scene code changes;
18. real Provider calls may remain 0.

Tests must inspect real visible labels/surface state where relevant, not only a standalone Dictionary.

## 11. Product acceptance intent

Engineering PASS is not final G6 product UAT.

Owner should be able to open a normal current build after MW-011 and immediately see a materially more intentional information hierarchy than the G5 screenshot:

- left side contains useful current-session information instead of only identity;
- right side defaults to World information, not Save controls;
- hidden world truth remains hidden;
- Narrative retains the largest and primary reading area.

## 12. Return contract

Push the branch and return:

- implementation/evidence SHA(s);
- base/final head;
- worktree cleanup/path;
- changed files;
- Pass A lifecycle audit;
- Pass B safe-data classification;
- exact ViewModel shape;
- exact Player Host and World Surface hierarchy;
- exact navigation behavior;
- Restore/reopen/currentness proof;
- disclosure-negative proof;
- focused/regression commands and counts;
- production schema diff status;
- Windows export result;
- Provider call count;
- remaining risks.

Return ceiling:

**READY FOR INDEPENDENT REVIEW**

Only GPT may issue Engineering PASS. Owner retains product/UAT authority.
