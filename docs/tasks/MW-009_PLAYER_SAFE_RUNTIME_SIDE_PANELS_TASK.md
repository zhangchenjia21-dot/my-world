# TASK｜MW-009｜Player-Safe Runtime Side Panels

Type: implementation / G5-06 first consumer / UI projection  
Work Item: **MW-009**  
Capability-Anchor: **G5-06 Runtime → UI Projection**  
Implementer: **Zcode + GLM-5.3-flash**（Owner weekend routing override）  
Reviewer: **GPT**  
Formal Code Base: `my-world/main@a7165dcebdce3bf3f3f512e9e4c26278bf21967f`  
Governance / Architecture Base: `Vibe-Coding/main@5b2acb9c866b630ec039ef4009b5552768205058`  
Task Branch: `mw-009-player-safe-runtime-side-panels`  
Required worktree path: `D:/AI/Projects/.worktrees/my-world/mw-009`  
Status: **ACTIVE — ZCODE**  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Implement the first G5-06 player-safe consumer of durable Runtime truth using the existing gameplay side panels.

The completed vertical should visibly replace the current placeholder-only sidebars with:

```text
Player panel
→ safe Player Character identity

World panel
→ safe World / selected Entry identity
→ bounded recent facts durably known by the Player Character
```

The UI must not receive or expose omniscient World Evolution, private NPC knowledge, independent actor actions, raw world consequence ledgers or internal IDs merely because those truths exist in Runtime.

## 2. Why now

G5-01 through G5-05 have already established durable world consequences, Knowledge Provenance, independent Agency, selective World Evolution and mechanics-grounded consequences.

G5-06 is now the mainline task. Its purpose is to prove:

> **Runtime truth can become useful player-facing state through an explicit disclosure boundary.**

This task is intentionally not a full G6 RPG UI build.

Owner has authorized progression to G5-06 while the remaining G5-05 product UAT is deferred to later combined product testing. See:

`docs/g5_05/G5-05_ENGINEERING_COMPLETION_CHECKPOINT.md`

## 3. Canonical architecture

Read and obey:

`Vibe-Coding/my world/architecture/world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`

Core invariant:

```text
Runtime truth
!= GM-visible truth
!= actor-private knowledge
!= human-player-safe UI projection
```

The projection boundary owns disclosure. The UI widget must not receive the entire raw `world_state` and filter secrets itself.

## 4. Read First

1. `AGENTS.md`
2. `Vibe-Coding/AGENTS.md`
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`
4. this Task Packet
5. `Vibe-Coding/my world/architecture/world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`
6. `Vibe-Coding/my world/architecture/world/G5_KNOWLEDGE_PROVENANCE_V0_1_DECISION.md`
7. `src/main.tscn`
8. `src/应用壳.gd`
9. `src/runtime/当前游戏会话运行时.gd`
10. `src/世界回合/L1_器件层/世界回合上下文投影器.gd`
11. directly relevant G5-01/G5-02/Restore tests

Expand only when real production tracing requires it; record why.

## 5. Mandatory two-pass audit before coding

### Pass A — producer/currentness audit

Trace the actual current Runtime shape for:

- frozen Game-local World identity / selected Entry;
- frozen Player Character identity / selected profile;
- `living_world.knowledge_turns_by_index`;
- Player Character `local_character_id` resolution;
- current accepted Conversation turn/hash matching;
- semantic-lane completion ordering;
- Save/reopen/Restore publication ordering.

Determine the narrowest lifecycle refresh points that can update the side panels after Player Character knowledge changes without reacting to hidden Agency/World Evolution as if they were disclosed.

### Pass B — disclosure consumer audit

Explicitly inspect these truth families and classify whether they may enter this v0.1 player-safe projection:

```text
Player Character identity                        YES, bounded safe fields only
World / selected Entry identity                  YES, bounded safe fields only
Player Character post-T0 Knowledge Provenance    YES
NPC Knowledge Provenance                         NO
semantic_turns_by_index raw consequences         NO
agency_cycles_by_source_turn                     NO
world_evolution_events_by_turn                   NO
GM/source instructions                           NO
literary_style_reference                         NO
internal IDs / hashes / generation fingerprints  NO
Public-d20 internal control/proposal payload      NO
```

Do not code until the audit confirms the exact production field shapes and currentness rules.

## 6. Worktree hygiene

Owner rule remains:

```text
all new my-world task worktrees
→ D:/AI/Projects/.worktrees/my-world/<task>
```

Before creating MW-009:

1. from the main repo run `git worktree list --porcelain`;
2. MW-008 has passed GPT IR#1 and is integrated into `main`; its worktree may be removed only if clean, pushed/reachable and free of unknown user work;
3. use `git worktree remove`, then `git worktree prune`;
4. never manually delete a registered worktree;
5. create this task at exactly:

`D:/AI/Projects/.worktrees/my-world/mw-009`

Keep the active MW-009 worktree through GPT Independent Review unless explicitly told otherwise.

## 7. Required projection semantics

Create the smallest explicit player-safe projection seam. The exact file/module placement may follow repository layering after the audit, but semantics are frozen.

### 7.1 Player Character safe identity

Projection may expose:

- display name;
- selected profile display name if it exists and is already part of the frozen selected local projection.

Must not expose:

- `local_character_id` in production copy;
- Source asset ID;
- generation fingerprint;
- raw Character semantic sections;
- GM-only/source instructions.

### 7.2 World safe identity

Projection may expose:

- World display name;
- selected Entry display name if one exists.

Must not expose:

- Source IDs/fingerprints;
- future/unselected Entry material;
- raw semantic sections;
- Style Primer;
- GM instructions.

### 7.3 Recent Player Character known facts

Read only valid current knowledge provenance where:

```text
record is structurally valid
AND source turn/hash matches current accepted Conversation
AND event.knower_id == current Player Character local_character_id
```

Return only display-safe fact text.

Bounds:

- latest **8 facts maximum**;
- deterministic order, preferably chronological with newest information visually easy to find;
- exact duplicate strings may be conservatively de-duplicated keeping newest;
- no Provider summarization;
- no semantic similarity clustering.

If data is invalid/stale/ambiguous, omit it. Never fall back to omniscient truth.

## 8. Existing UI consumer

Use the existing `PlayerPanelHost` and `WorldSurfaceHost` in `src/main.tscn`.

Target product shape is intentionally simple:

```text
主角
刘备
<selected profile display name, if useful>

世界
汉末三国
赤壁之战前夕

主角所知
• ...
• ...
```

Exact copy may be adjusted for natural Chinese, but do not display engineering labels, IDs, hashes or provenance enums.

When no post-T0 known fact exists, show a quiet empty state such as `尚无新的已知事实。`

Do not create tabs, filters, search, journal editing, sorting controls or a generic ViewModel framework.

## 9. Refresh behavior

Prefer existing lifecycle seams.

The panel must refresh correctly on:

- initial Game activation/reopen;
- successful semantic-lane terminal when Player Character knowledge may have changed;
- successful Restore/progress switch.

Do **not** refresh/show new content merely because Agency or World Evolution committed hidden world truth.

If the actual audit proves existing callbacks are insufficient, add only the narrowest durable-world-changed signal required by this real consumer. Do not create an event bus/store framework.

## 10. Required focused proof

Add task-owned proof using actual Runtime structures and the real side-panel consumer.

At minimum prove:

1. a frozen Game displays correct Player Character and World/Entry names without internal IDs/fingerprints;
2. a valid Player Character knowledge fact A displays;
3. an NPC-only knowledge fact B does **not** display;
4. a raw semantic world consequence C does **not** display merely because it is World truth;
5. an independent actor action D does **not** display;
6. a World Evolution event E does **not** display;
7. if a later valid Player Character knowledge event explicitly carries the substance of C/D/E, that knowledge fact may then display through the knowledge seam;
8. stale hash-mismatched knowledge is excluded;
9. semantic commit adding Player Character knowledge refreshes the panel without reopen;
10. Save/close/reopen reconstructs the same safe projection;
11. Restore to before a known fact removes the restored-away fact;
12. invalid projection input fails closed to a safe/empty display and never dumps raw world state;
13. MW-008 Narrative rendering remains green;
14. G5-02 Knowledge Provenance and G5-01 Restore/currentness regressions remain green;
15. `git diff --check` clean;
16. Windows export validation PASS if production GDScript/scene changes;
17. real Provider calls may remain 0.

Use stubs/fixtures for semantic extraction where appropriate. Engineering proof is about disclosure/currentness, not model prose quality.

## 11. Explicit non-scope

Do not implement:

- full Character Sheet;
- inventory/equipment;
- relationships;
- faction UI;
- quests/journal system;
- map/location UI;
- portrait/scene/map asset runtime;
- generic ViewModel/event bus/store;
- separate universal human Player Knowledge database;
- model-generated UI summaries;
- raw omniscient World dashboard;
- editable knowledge;
- new SQLite tables/schema;
- G6 visual host/platform;
- G7 context retrieval.

Also do not alter MW-005 literary-style behavior in this task. Owner has requested a later bounded style-weight adjustment, but it is deliberately deferred so G5-06 can proceed on the mainline.

## 12. Stop conditions

STOP and report before broadening if implementation appears to require:

- a new persistence schema/table;
- a universal Player Knowledge store;
- exposing raw omniscient `world_state` to UI as the normal contract;
- a generic ViewModel/event-bus platform;
- model/Provider summarization to decide disclosure;
- redesign of G5-02 Knowledge Provenance;
- redesign of Agency/World Evolution authority;
- G6 visual asset runtime.

## 13. Product Value Acceptance

Engineering PASS must prove that the player-safe boundary is real and that the existing side panels become useful without becoming a spoiler/debug dashboard.

Owner product check may be combined with the later G5-07/G5-GATE test pass.

Desired user-visible feeling:

> The side panels help me remember who I am, where this game is grounded, and what my character has learned — without exposing the GM's hidden world simulation.

## 14. Git / return contract

Before final push, fetch latest `main`, reconcile non-destructively and rerun the focused matrix.

Return:

- implementation SHA;
- evidence SHA;
- remote branch;
- base/final head;
- worktree path + cleanup report;
- changed files;
- Pass A producer/currentness audit;
- Pass B disclosure audit;
- exact player-safe projection shape;
- proof raw hidden truth never reaches the projection object;
- live refresh proof;
- reopen/Restore proof;
- regression results;
- export result;
- real Provider call count;
- remaining risks.

Return ceiling:

`READY FOR INDEPENDENT REVIEW`

Only GPT may issue Engineering PASS. Only Owner may issue Product/G5-GATE PASS.
