# ADDENDUM｜MW-011 Revision 2｜Player Character Profile Projection + Player Host Surface

Type: Owner UAT revision addendum / G6 product correction  
Work Item: **MW-011**  
Name: **G6 RPG Host ViewModel Baseline — Player Character Profile Surface**  
Capability-Anchor: **G6 RPG Experience & Internal Declarative UI Host**  
Triggered-By: Owner UI UAT on integrated `main@6338af5665c5137d9a9528776e77a13ffb924ea6`  
Implementer: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Revision: **2**  
Review-Round: **IR#1 → IR#2**  
Status: **ACTIVE — ZCODE**  
Task Branch: `mw-011-r2-player-character-profile-surface`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-011-r2`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

Formal Code Base at issue: `my-world/main@6338af5665c5137d9a9528776e77a13ffb924ea6`  
Governance/Architecture Base at issue: `Vibe-Coding/main@6cf348bbf4ce9bfb4a794ded6b9fc9f1db813cad`

Canonical architecture:

`Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`

Original R1 packet:

`docs/tasks/MW-011_G6_RPG_HOST_VIEWMODEL_BASELINE_TASK.md`

Original Engineering review:

`docs/mw011/MW-011_INDEPENDENT_REVIEW_IR1.md`

## 1. Why this is MW-011 Revision 2

MW-011 R1 passed Engineering review and was integrated, but Owner UAT on the real fresh Zhang Chen session still shows the same product-level information-density defect: the left Player Host has large dead space and does not communicate the rich Player Character definition.

This is the same MW-011 outcome, not a new independent capability. Per task-lineage governance, keep Work ID `MW-011`, increment Revision/Review Round.

The screenshot also proves MW-012 content integration itself is functioning: Zhang Chen-specific facts reach the opening Narrative. Do not reopen MW-012 semantics or rewrite the Character concept.

## 2. Mandatory pre-implementation audit

Before changing code, refresh latest implementation/governance `main` and perform worktree hygiene exactly per repository policy.

Audit and report the exact current owners of:

- `character_card.v0.2` allowed fields and Character loader validation;
- Character selected-source projection / frozen Game-local `source_projection`;
- MW-009 player-safe projection contract;
- MW-011 RPG Host ViewModel build seam;
- Player Host scene/container hierarchy and responsive behavior;
- MW-012 Zhang Chen production package + production publish path.

STOP rather than inventing a second Source loader, second Game truth store, live Source lookup from an existing Game, or raw `semantic_sections` UI consumer.

## 3. Character Card v0.2 optional `player_profile`

Implement the architecture decision's bounded optional field on **Character Card v0.2 only**.

Conceptual exact shape:

```json
{
  "player_profile": {
    "headline": "24岁 · 现代穿越者",
    "summary": "退役武警义务兵、985高校出身、历史与军事爱好者",
    "groups": [
      {
        "group_id": "background",
        "title": "背景",
        "items": ["...", "..."]
      }
    ]
  }
}
```

Validation requirements:

- field is optional; every existing v0.2 card without it remains valid;
- `headline` non-empty String <=120;
- `summary` non-empty String <=360;
- `groups` Array size 1..8;
- group exact fields = `group_id/title/items`;
- unique safe-token `group_id`;
- `title` non-empty <=60;
- `items` Array size 1..8; each item non-empty String <=160;
- recursively reject existing forbidden live-state fields;
- do not allow callbacks, bindings, NodePaths, expressions, executable code, arbitrary nested dictionaries or UI layout instructions.

This is a bounded internal additive v0.2 presentation extension. Do not mint a v0.3 migration platform and do not broaden World/Expansion schemas.

## 4. Selected projection and frozen ancestry

When a Character generation containing valid `player_profile` is selected as Player Character, copy the validated profile into the existing selected Character projection so Final Create freezes it into that Game-local Player Character `source_projection`.

Required invariant:

```text
old Game frozen without player_profile
→ remains without player_profile
→ does NOT fetch/backfill current Source Library
```

A new Source generation may change what future Games freeze; it must not mutate existing Games.

`player_profile` does not enter GM context and does not become semantic/world authority.

## 5. Separate Player Character Profile Projection

Do not widen MW-009 to read raw Character Source sections.

Add the smallest task-owned domain projection seam, conceptually:

```text
frozen player_character.source_projection.player_profile
→ PlayerCharacterProfileProjection
→ RPG Host ViewModel
```

Properties:

- deterministic;
- side-effect free;
- fail-closed;
- no Provider;
- no Source Library access;
- no filesystem;
- no persistence write;
- no raw `semantic_sections` fallback;
- no `catalog_summary` fallback pretending to be the rich profile;
- no internal IDs/hashes/fingerprints/instructions.

A missing/invalid profile yields an empty profile projection and the existing R1 compact fallback remains usable.

## 6. MW-011 ViewModel extension

Extend the existing presentation-only RPG Host ViewModel with one bounded `player_profile` payload sourced only from the new safe profile projection.

Do not pass `world_state` or full Character `source_projection` into leaf widgets.

Existing R1 fields and behavior remain protected:

```text
player identity/profile
World/Entry
recent accepted Player actions <=4
Player-turn count
Player-known facts via MW-009
Overview/Save navigation
```

Restore/reopen behavior must remain coherent.

## 7. Player Host UI result

Keep the Player Host a single bounded surface in this revision. No generic tab/navigation system and no full Character page.

When a profile exists, show the profile before existing World/recent-action/session material.

Required visible structure:

```text
主角
张琛
现代来客起点
24岁 · 现代穿越者
退役武警义务兵、985高校出身、历史与军事爱好者

背景
• ...

性格
• ...

能力
• ...

局限
• ...

初始目标
• ...

行为原则
• ...

随身物品
• ...

世界：...
最近行动
已进行了 N 个玩家回合
```

Use authored group order. Make the left Host vertically scrollable if required; Narrative Host must remain the primary/largest surface. Do not render raw Markdown Source prose.

The exact microcopy can follow current Chinese UI conventions, but the information hierarchy above is required.

## 8. Zhang Chen profile generation update

Update the integrated first-party Zhang Chen package only by adding the bounded `player_profile` presentation material derived from the already approved Character concept.

Required groups in authored order:

```text
background   / 背景
personality  / 性格
capabilities / 能力
limits       / 局限
goals        / 初始目标
principles   / 行为原则
possessions  / 随身物品
```

Content must faithfully reflect the already frozen MW-012 semantics, including at least:

- age 24 / modern physical-transport origin;
- retired PAP conscript background, 985 university background, history/military interest;
- steady/rational/fair/decisive personality;
- physical fitness, modern combat training, war/logistics/organization perspective, modern humanities/social-science knowledge;
- weaker social skill, strong aversion to corrupt/roundabout officialdom, no local identity/network, initially cannot read clerical-script-era writing;
- survival + seek a route home as initial goals; later allegiance/self-rule remains Player-owned;
- no indiscriminate killing of innocents, no easy betrayal, no intentional civilian harm, no grave evil purely for private gain;
- military canteen, military knife, watch, compass, compressed food.

Do not add superhuman combat ability, modern supply channels, guaranteed historical outcomes, automatic famous-person recognition, local relationships or extra equipment.

Because Source bytes change, increment the Zhang Chen package version normally (expected `0.1.1`) and produce a new immutable generation fingerprint. Update the bounded Owner production publish script/evidence accordingly. Existing Games must remain unchanged.

## 9. Focused proof requirements

At minimum prove all of the following with actual visible/runtime seams, not dictionary-only tests:

1. legacy Character Card v0.2 without `player_profile` still validates/installs/selects/Final Creates;
2. valid bounded `player_profile` validates and malformed/oversized/unknown-field shapes fail loudly;
3. selected projection freezes the exact profile into the new Game;
4. profile projector reads only frozen `player_profile` and never exposes `semantic_sections`/GM material;
5. fresh Zhang Chen game visibly shows headline + all seven group titles with representative items in Player Host before any Player turn;
6. raw unique GM-reference/private sentinel text is absent from ViewModel and visible labels;
7. recent actions and Player-turn count still update after 2+ turns;
8. Player-known facts still come only from MW-009 and continue to update;
9. close/reopen reproduces the same profile + R1 ViewModel;
10. Save/Restore preserves frozen profile and removes only restored-away dynamic actions/facts as before;
11. an existing pre-R2 Game without `player_profile` remains profile-empty and does not live-fetch the newly published Zhang Chen generation;
12. Liu Bei / other existing card path without `player_profile` remains valid and usable;
13. MW-009 focused regression green;
14. MW-011 R1 focused regression green or intentionally updated with equivalent coverage;
15. MW-012 focused integration regression green after Zhang Chen version/fingerprint update;
16. G4 Character Source v0.2 + Final Create regressions green;
17. Overview/Save navigation and Save callbacks remain green;
18. responsive wide/1280/narrow behavior remains coherent; Player Host scroll does not steal Narrative primacy;
19. `git diff --check` clean;
20. Windows export PASS;
21. Provider calls = 0;
22. no SQLite schema/table change.

## 10. Production publication proof

After the reviewed candidate content is ready in the task worktree, use only the existing bounded Owner-approved Zhang Chen production publication seam. Do not create a generic arbitrary-path installer.

Record safe evidence for the new current generation:

- asset id `character.han_end.zhang_chen`;
- version expected `0.1.1`;
- exact new generation fingerprint;
- current production inventory discovers it;
- existing Games modified = false.

The Owner's current pre-R2 Game is allowed to remain on the old generation and therefore may remain visually thin; final Owner UAT should create a fresh Zhang Chen Game from the new generation.

## 11. Non-scope / stop conditions

Do not add or redesign:

- full Character Surface or generic Player tabs;
- portrait / scene / map runtime assets;
- Inventory/Relationship/Faction/Quest/Location mechanics;
- generic UI DSL / Internal Declarative UI Host;
- Mod/Creator schema;
- Provider profile summarization;
- automatic Markdown parsing of semantic Source sections;
- new persistence tables;
- GM Narrative gates;
- G5 Knowledge/Agency/Evolution semantics.

STOP and report if the required frozen profile cannot be added through the existing Character selected-projection / Final Create ancestry without inventing a second Source or persistence owner.

## 12. Return format

Return:

- exact candidate SHA;
- refreshed base SHA;
- exact changed files;
- audit conclusion;
- exact `player_profile` contract implemented;
- Zhang Chen new version + exact fingerprint;
- proof old Game does not backfill;
- focused/regression/export results;
- production publication result;
- confirmation no raw `semantic_sections` or GM/private data reached UI;
- confirmation no generic UI/platform work was added.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**
