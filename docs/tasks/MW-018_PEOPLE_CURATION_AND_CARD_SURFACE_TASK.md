# TASK｜MW-018｜People Curation + Card Surface

Type: G6 product-facing vertical implementation  
Work Item: **MW-018**  
Primary Implementer: **Codex**  
Reviewer: **GPT**  
Product Owner / UAT: **Owner**  
Status: **READY FOR CODEX**  
Task Branch: `mw-018-people-curation-card-surface`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-018`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal product-code base: `73004d67ef14be2fb2bb7c386e6a89a604e93f8f`  
MW-017 reviewed integration tip: `27519c0e11ff995df4c584e835dc0be39ee3f4d5`  
Governance base at shaping: `8f38b4998e7b9d77ac731f8248cbc7e7fcc4945d`

## 1. Product outcome

Implement the first real `人物 / People` Surface.

Required user-visible result:

```text
right 信息 navigation
→ 概览 | 角色 | 重要经历 | 人物 | 存档

人物
→ card-based list of people the player currently knows and the model judges worth maintaining
→ every card collapsed by default
→ collapsed card = player-known display identity + very short key positioning
→ expand a card = current latest-known relationship / identity / traits / situation / useful details
→ later player-visible information updates the same person's card
→ hidden/off-screen NPC changes do not update the card until the player learns them
```

People answers:

> **“这局游戏里，我目前知道哪些值得持续记住的人？关于他们，我最近最新了解到的是什么？”**

This is a player-known current snapshot, not an omniscient NPC browser and not a biography/history log.

## 2. Why now

MW-017 is Engineering PASS / integrated and proves the required prerequisite:

```text
accepted player-authored Turn
→ World semantic materialization / exact identity receipt
→ same-turn terminal barrier
→ Information Curator may safely consume that opportunity
```

MW-018 must use this proven seam rather than inventing display-name matching or reading raw stable actor material.

## 3. Primary Purpose / Core Value link

Current product core value remains:

> **长期持续 AI 世界 + 优秀自由 AI GM + 原生 RPG 游戏体验。**

People serves the durable-world promise by turning remembered relationships and recurring people into a player-usable RPG information surface without exposing omniscient backend truth.

INV-PRODUCT-01:

> The People Surface must make the player's lived social world easier to understand **without** turning Runtime/GM omniscience into player knowledge.

## 4. Authority / Source Manifest

Refresh both mains before implementation.

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + `governance/OWNER_AI_COLLABORATION_PREFERENCES_CURRENT.md`.
3. `Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`.
4. `Vibe-Coding/my world/MY_WORLD_项目启动总纲_CURRENT.md` + core principles.
5. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`.
6. `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`.
7. `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`.
8. `docs/mw017/MW-017_INDEPENDENT_REVIEW_IR1.md` + integration verification.
9. repository `AGENTS.md`.
10. current implementation/tests.
11. `Vibe-Coding/skill/gpt/agent-task-packet/SKILL.md` for execution discipline only.

Archive/legacy chats are not authority unless a current source explicitly references them.

If a newer current decision conflicts with this packet, STOP.

## 5. Read first

Initial workset:

1. `AGENTS.md`
2. this Task Packet
3. `docs/mw017/MW-017_INDEPENDENT_REVIEW_IR1.md`
4. `src/世界回合/L3_外交层/人物身份桥公开接口.gd`
5. `src/信息整理/L0_公理层/信息整理契约.gd`
6. `src/信息整理/L2_流程层/回合信息整理流程.gd`
7. `src/信息整理/L3_外交层/角色经历投影公开接口.gd`
8. People-related rendering/navigation paths in `src/应用壳.gd` / `src/main.tscn`

Expand only when concrete evidence requires parser/ViewModel/tests/Runtime owners.

## 6. Frozen product semantics

### DEC-01 — card-first UI

People v0.1 is a card list.

All cards start **collapsed** whenever the Surface is rendered/rebuilt.

Collapsed card shows only concise scan-level information:

```text
player-known display name / identity
headline / very brief positioning
optional one-line brief summary only when necessary
```

Do not show relationship/details by default.

Expanded card may show, when model-supported:

- latest-known identity/social role;
- latest-known situation/current known status;
- natural-language relationship/interaction summary;
- player-known traits/impressions;
- player-known capabilities/limitations;
- other genuinely useful current known details.

Fields may be absent/empty. Do not fabricate completeness.

### DEC-02 — latest-known, not omniscient current

A People card represents:

> **the player's latest known snapshot of that person.**

It must not update merely because:

- stable actor material changed;
- NPC Agency acted off-screen;
- World Evolution changed the NPC;
- NPC-private Knowledge changed;
- GM context knows more.

Only accepted player-visible information can support a new People snapshot.

### DEC-03 — no People history product

People is current snapshot only.

Do not render old card versions, relationship history, biography timeline or mutation log.

Internal per-turn records exist only for Timeline currentness/reconstruction.

### DEC-04 — relationship is prose, not a Domain

`relationship` is natural-language **player-known relationship summary** inside the People snapshot.

Do not add:

- affinity/trust/hostility numbers;
- relationship state machine;
- separate Relationship truth owner.

Future real Relationship Domain may supersede this snapshot field via Existing Domain wins.

### DEC-05 — model owns People meaning

The model decides:

- whether a bound person is worth creating a card for;
- whether a card should update, remain unchanged or be removed;
- which latest-known facts matter;
- headline / summary / relationship / details prose;
- whether new information corrects an old belief.

Program must not decide these with:

- name keywords;
- encounter counts;
- importance scores;
- relationship thresholds;
- event-type rules;
- profile-group mapping;
- named-character special cases.

Program owns only structure, exact identity mapping, temporal integrity, persistence and presentation.

## 7. Identity / disclosure input — consume MW-017 exactly

For each current lived opportunity, use MW-017's current identity receipt / request-evidence seam.

The People portion of the Information Curator request may receive only bounded player-safe evidence conceptually like:

```json
{
  "actor_ref": "request-scoped-ref",
  "quote": "accepted GM text span",
  "gm_span": {"start": 0, "length": 2},
  "current_snapshot": { ... player-known snapshot if a card already exists ... }
}
```

Program privately keeps `actor_ref → exact local_character_id` and receipt dependency.

Do not send to the Information Curator for People:

- canonical local IDs as player content;
- complete stable roster;
- raw `source_projection`;
- raw `game_local_material`;
- GM-private Character sections;
- NPC-private Knowledge;
- Agency plan/history;
- hidden World Evolution;
- Source-current data;
- hidden current actor state.

Only current receipt-bound actors are eligible for People update in that turn. Existing cards not implicated by the current receipt remain unchanged without needing to be sent wholesale to the model.

If the semantic terminal failed/cancelled/timed out and no current receipt exists:

```text
Character / Important Experiences curation continues
People component = no-op
existing People cards remain
```

Absence of evidence never means clear all cards.

## 8. One Information Curator call

Do **not** add a separate People Provider call.

Extend the existing lived Information Curator request/response so one bounded request can maintain:

```text
Character
+ Important Experiences
+ People updates for current receipt-bound actors
```

Initial/T0 Character curation remains People-free and unchanged.

GM-only opening remains outside People v0.1.

## 9. Curation response contract

Use a backward-compatible additive lived contract.

Conceptual new response shape:

```json
{
  "character": null,
  "experiences": [],
  "people_updates": [
    {
      "actor_ref": "request-scoped-ref",
      "snapshot": {
        "display_name": "玩家已知称呼",
        "headline": "一句关键定位",
        "summary": "最新已知摘要",
        "relationship": "自然语言关系摘要",
        "details": ["玩家已知详情"]
      }
    }
  ]
}
```

`snapshot: null` / an equivalent explicit tombstone removes that person's card.

A full snapshot replaces the previous snapshot for that exact actor. Program does **not** merge individual prose fields semantically.

Approved structural ceilings:

- max 8 distinct actor updates per turn;
- display_name ≤ 64 chars;
- headline ≤ 160 chars;
- summary ≤ 400 chars;
- relationship ≤ 600 chars;
- details ≤ 8 items;
- each detail ≤ 600 chars;
- existing whole request/response byte ceilings remain.

Duplicate model updates that resolve to the same canonical actor in one response are invalid for People rather than treated as ordered operations.

### Additive failure isolation

People is an additive field. A malformed/unknown/invalid People update must not silently turn into another actor and must not require weakening existing Character/Experiences validation.

Prefer independent People-entry dropping/fail-soft behavior when the base Character/Experiences payload remains structurally valid.

Do not make an invalid People ref corrupt otherwise-valid Character/Experiences meaning.

A globally malformed/non-JSON response may continue to fail the whole existing curator call under current behavior.

## 10. Durable owner / backward compatibility

People current snapshots remain under existing `information_curation`; no new SQLite table and no stable-actor truth mutation.

Implement a backward-compatible **new lived curation record/result variant**.

Requirements:

- existing MW-014/MW-015 historical `{prefix,parent,id,result}` records and existing result hash semantics remain valid;
- do not inject `people_updates: []` into an old result before validating its historical ID;
- old and new validated record IDs can form one mixed parent chain;
- new record binds People updates to the exact MW-017 `identity_receipt_id` when People evidence is available;
- no receipt / failed semantic terminal is a legitimate People-no-op dependency;
- existing Character/Experiences currentness semantics remain unchanged.

New record identity must include all machine material that changes its currentness/meaning, including the exact accepted prefix, parent, new result variant and receipt dependency when present.

Do not rewrite old records or migrate historical IDs.

## 11. People fold / internal projection

Internally derive current People state from valid current curation records in accepted order:

```text
start empty
→ exact actor snapshot replaces prior snapshot
→ tombstone removes
→ unchanged actors retain prior snapshot
```

Identity key is exact stable `local_character_id` internally.

A current People snapshot is valid only while its actor identity remains current/applicable under the accepted history.

Do not re-hydrate the card from current NPC truth after it was curated.

No displaced-future/T0 fixed-node recovery for People.

### Stable presentation order

v0.1 should use deterministic **first-card-appearance order** for visible cards. Updating a card does not reorder it.

This is presentation ordering, not a semantic importance score.

Tombstone removes it; a later genuinely recreated card may appear as a new current first-appearance position in the restored/current history.

## 12. Player-safe People L3 seam

Add the narrowest dedicated People player-safe projection/DTO seam under the information/presentation boundary.

Leaf UI receives only presentation content such as:

```text
display_name
headline
summary
relationship
details[]
```

Leaf UI must not receive:

- local_character_id;
- actor_ref;
- receipt ID;
- prefix/hash;
- origin/provenance;
- raw stable actor material;
- Knowledge/Agency/Evolution internals;
- `information_curation` storage object.

Rendering/reopen is zero Provider call.

## 13. UI / navigation

Add `人物` to the existing right-side information navigation in this order:

```text
概览 | 角色 | 重要经历 | 人物 | 存档
```

People Surface:

- integrated into the existing World Information Host;
- uses actual cards/panels, not one giant raw text label;
- every card default collapsed;
- click/toggle expands only that card;
- expanded detail remains inside the existing right-side scroll experience;
- no search/filter/sort control in v0.1;
- no persisted expand/collapse preference required;
- no portrait/Visual Runtime requirement;
- no generic declarative host abstraction.

Quiet empty state is allowed, e.g. no current People cards yet.

Do not create a fake card from stable registry merely to avoid emptiness.

## 14. Immediate currentness refresh

People projection must reflect current Timeline **before** a replacement curator completes.

Required behavior:

```text
Regenerate/correction durably replaces accepted history
→ stale People update/card disappears/reverts immediately on next UI projection
→ do not wait for new curation to finish before hiding stale future information
```

Add only the narrow Shell refresh seam required after accepted-history currentness changes.

This refresh may also correctly redraw Character/Important Experiences from their current projections; it must not trigger Provider calls.

Restore already refreshes current surfaces and must include People.

## 15. Existing Game / opening policy

v0.1 does not historically backfill People.

Existing Games:

```text
old history
→ unchanged / no People backfill
new player-authored accepted Turn after feature
→ normal identity receipt + People curation opportunity
```

No Source-current/stable-roster dump is allowed as retrofit.

GM-only opening does not create/update People in this version.

## 16. Engineering Acceptance

At minimum prove through production seams:

1. right navigation is exactly `概览 | 角色 | 重要经历 | 人物 | 存档`;
2. a current identity receipt + accepted player-visible text can create a People card through the **existing Information Curator call**, no third Provider call;
3. model sees request-scoped actor ref + accepted quote/span + only that actor's current player-known snapshot when present;
4. model never receives raw stable actor material/private Knowledge/Agency/Evolution/Source-current through People input;
5. Program resolves model actor refs to exact stable local identity before durable persistence;
6. unknown/stale/duplicate refs cannot mutate another actor;
7. People-entry validation failure does not corrupt otherwise-valid Character/Experiences curation;
8. card update is full snapshot replacement; untouched cards remain unchanged;
9. tombstone removes a card without deleting/mutating the stable NPC;
10. same-name actors remain distinct internally and never use name authoritative matching;
11. collapsed cards show only compact identity/headline/optional brief summary;
12. relationship/details are hidden until that card is expanded;
13. cards are collapsed by default after render/rebuild;
14. expanded card displays only player-known curated snapshot fields;
15. first-card-appearance ordering is deterministic and update does not reorder;
16. hidden Agency/World Evolution/private actor-material mutation does not change People projection;
17. later accepted player-visible information can update the card;
18. Restore before card creation removes it;
19. Restore between v1/v2 card versions returns v1;
20. accepted Regenerate/correction immediately removes/reverts stale People content before replacement curation completes;
21. reopen reconstructs equivalent People cards with zero Provider call;
22. no GM-opening People processing;
23. old Game missing People history remains valid and receives no automatic backfill;
24. old MW-014/MW-015 curation records/IDs/parent chain remain valid in mixed history;
25. Initial Character baseline remains unchanged and People-free;
26. no `local_character_id`, actor_ref, receipt/prefix/hash, raw `information_curation` or private canary reaches leaf People DTO;
27. no new SQLite table/migration;
28. Narrative acceptance remains non-blocking/fail-soft;
29. MW-017 identity/barrier suite remains green;
30. MW-014/MW-015 Character/Important Experiences regressions remain green;
31. relevant G5 actor/Knowledge/Agency/currentness regressions remain green;
32. maximized, 1280x720 and narrow/960-class layout remain coherent and People cards scroll without horizontal overflow;
33. `git diff --check` clean;
34. Windows Desktop export PASS.

## 17. Real Provider vertical

After offline/focused gates pass, run at least one bounded real configured Provider vertical if credentials/provider are available.

Use isolated task-owned Game state with a realistic accepted player turn that establishes/updates at least one person.

The real proof should show:

```text
World semantic call
→ current identity receipt
→ same existing Information Curator call
→ valid People update
→ safe projected card
```

Inspect that card language is useful and based only on player-visible evidence; record malformed/unresolved model output honestly.

Do not silently switch Provider or add heuristics to force success.

Owner production settings/Source/Games must remain fingerprint-identical.

## 18. Product Value Acceptance / Owner UAT target

Engineering tests cannot declare People product success.

After Engineering PASS + integration + canonical local build handoff, Owner should be able to play a real turn involving a person and observe:

```text
人物 tab appears
→ a useful person card appears/updates
→ card is collapsed by default
→ collapsed state is quick to scan
→ expanding reveals relationship and useful latest-known details
→ no obvious backend/private/omniscient information is shown
→ later learned information updates the card
→ information the player has not learned remains unchanged/unknown
```

Owner also validates that the Surface feels like an RPG人物志 rather than a debug registry.

Agent return ceiling is **READY FOR INDEPENDENT REVIEW**, never Product PASS.

## 19. Explicit non-scope

Do not implement:

- numeric Relationship/affinity;
- People history/biography timeline;
- search/filter/sort framework;
- pagination platform;
- portraits or Visual Runtime;
- NPC inventory/private Knowledge viewer;
- Faction page;
- GM-opening People processing;
- historical model backfill;
- generic Entity/Knowledge graph;
- MW-013 Internal Declarative UI Host;
- external declarative People schema;
- unrelated global UI polish.

## 20. Git / evidence / return

Use the required task worktree. Do not modify the Owner canonical checkout as the implementation candidate.

Before final evidence:

```text
git rev-parse HEAD
git status --short
git diff --check
```

Return exact:

- candidate SHA;
- refreshed implementation/governance bases;
- changed files;
- new curation record/result compatibility design;
- exact People input evidence and private ref mapping;
- People fold/projection design;
- UI navigation/card implementation summary;
- currentness refresh behavior;
- focused/regression/export results;
- real Provider vertical result;
- clean status.

Do not merge main. Do not declare Product PASS. Do not install the unreviewed candidate into `D:/AI/Projects/my-world`.
