# TASK｜MW-012｜Zhang Chen Player Character Card

Type: implementation / first-party content integration  
Owner: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Capability-Anchor: **G4 Primary Source Assets & Local Game Creation**  
Inserted-By: **Owner during G6**  
Depends-On: current Character Card v0.2 / Managed Source Library / New Game compatibility flow  
Revision: **1**  
Review-Round: **0**  
Status: **OWNER-INSERTED — READY FOR ZCODE**  
Base: `zhangchenjia21-dot/my-world@c58c3b395551fef4a8487a46d7793ecc3b26ec63` or latest refreshed `main` if newer  
Task Branch: `mw-012-zhang-chen-player-character-card`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-012`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Add the Owner-approved **张琛** Character Card to the current playable product so that it can be selected as the **Player Character during New Game** for the supported Han-end / Three Kingdoms Entries.

This is a first-party content integration task, not a new Character schema, Creator, UI redesign or RPG mechanic.

Owner-approved semantic input is frozen at:

`docs/tasks/inputs/MW-012_ZHANG_CHEN_CHARACTER_CARD_V0_1.md`

Treat that file as the content authority for v0.1. Do not silently rewrite the character into a different protagonist concept.

## 2. Required implementation semantics

Use the existing Character Card contract and the same real product ingress that makes current first-party selectable Character Cards (for example 刘备) available to the New Game flow.

Expected stable identity unless a current validator requires a different legal form:

```text
asset_id: character.han_end.zhang_chen
display_name: 张琛
asset_type: character_card
schema: existing character_card.v0.2
version: 0.1.0
player_character_supported: true
```

Do **not** add a new schema merely to express this character.

### 2.1 T0 compatibility

The intended card behavior is an alternative game-start profile: Zhang Chen is physically transported into whichever supported Three Kingdoms Entry the Player selects, age 24, with no prior local life history.

Support all currently valid Han-end Entries where existing Character Card v0.2 can legally bind a T0 profile:

- 184 Yellow Turban;
- 189 Luoyang crisis;
- 196 Emperor Xu / Xuchang-era start;
- 200 Guandu eve;
- 208 Red Cliffs eve;
- 214 Yizhou transition;
- 220 Han–Wei transition.

Each profile must bind to the exact current world/entry IDs used by production Source contracts. Audit those IDs from current source truth; do not copy labels as machine IDs from this packet.

The card must not become cross-world eligible merely because it exists. Incompatible non-Han worlds must continue to fail/filter through the existing compatibility semantics.

### 2.2 Historical knowledge boundary

This is a hard semantic requirement:

```text
Zhang Chen's remembered modern history
= protagonist background knowledge / belief
!= current Game World Truth
!= guaranteed future canon
!= NPC destiny
!= World Evolution causal command
```

The GM may use his remembered history as information the protagonist can reason from. The Game is free to diverge. Once events diverge, remembered history may be wrong or obsolete.

Do not encode Three Kingdoms future events into World truth, T0 event obligations, scheduler queues or NPC instructions merely because Zhang Chen remembers them.

Likewise, knowing a famous person's name/history does not grant automatic visual identification of an unidentified stranger without in-world evidence.

### 2.3 Player agency

The card establishes background, traits, values, memories, possessions and starting circumstance only.

It must not pre-author future meaningful protagonist choices such as:

- choosing Liu Bei / Cao Cao / Sun Quan;
- swearing allegiance;
- founding a faction;
- revealing future knowledge;
- choosing whether to return home or remain;
- killing/sparing a person.

Existing MW-004 protagonist-choice semantics remain protected.

### 2.4 Initial possessions

Represent only the Owner-approved starting possessions through the existing Character/T0 source semantics if that contract already has a legal place for them:

- military-style water bottle;
- military utility/combat knife;
- wristwatch;
- compass;
- portable compressed food.

Do not invent firearms, ammunition, radio, phone, electricity, infinite supplies or other modern equipment.

If the current Character Card contract has no authoritative inventory field, keep these possessions in the appropriate character/T0 semantic content rather than creating a new inventory database or schema in MW-012.

## 3. Product ingress audit — mandatory before editing

Before implementation, identify the **real current mechanism** by which first-party Character Cards become available in Owner New Game.

Specifically trace:

```text
first-party Character package/source files
→ Managed Source Library generation
→ New Game character discovery / compatibility
→ Player Character selection
→ Final Create frozen Game-local projection
→ Opening / continuation context
```

The finished card must use that real path.

Do **not** satisfy this task by adding only a test fixture that the Owner product never discovers. Do not hardcode `张琛` directly into the picker UI.

If fresh audit proves there is no product-owned first-party ingress corresponding to the currently selectable cards and making this card available would require a genuinely new asset-distribution architecture seam, STOP and report that finding to GPT rather than inventing a broad platform under MW-012.

## 4. Content representation guidance

Prefer a small number of reusable semantic sections plus T0-bound profiles rather than duplicating the entire biography seven times, provided the current v0.2 Source contract supports this without weakening exact generation semantics.

The card should materially convey to GM context:

- modern origin / physical transport premise;
- retired PAP conscript + strong fitness/military bearing;
- modern close-combat fundamentals and war/logistics perspective;
- 985-university background;
- economics/philosophy/sociology/history foundation and institutional thinking;
- major Three Kingdoms event-memory advantage with the non-canon boundary above;
- steady, rational, fair, decisive personality;
- initial goals: survival + seek a route home; later allegiance/self-rule remains open;
- moral boundaries;
- social weakness and strong aversion to corruption/official cynicism;
- no local network/status;
- cannot initially read clerical script (隶书), but may learn;
- finite starting possessions.

Keep prose usable as model context. Do not turn the card into a giant essay or fixed plot script.

## 5. Non-scope

Do not add:

- portrait/image asset;
- numeric HP/STR/INT character-sheet system;
- new inventory system;
- new language simulation;
- new Character Card schema;
- Character Creator/editor;
- new Source marketplace/import platform;
- new mechanics Expansion;
- New Game UI redesign;
- hardcoded future-history scheduler;
- protagonist output gate/classifier/retry;
- G6 declarative UI work.

MW-011 remains the G6 mainline UI task. Avoid touching its implementation seam unless the current main already contains its reviewed result by the time MW-012 is executed.

## 6. Acceptance proof

At minimum prove with current product/source seams:

1. the package validates under the existing Character Card v0.2 contract;
2. exact immutable generation/fingerprint is produced through the normal Managed Source path;
3. New Game with the Han-end world can discover/select **张琛** as Player Character without a manual file-copy hack;
4. compatibility succeeds for each supported Han-end Entry intended above;
5. an unrelated incompatible world does not gain false eligibility;
6. Final Create with at least the 208 Red Cliffs Entry + 张琛 succeeds through the real product creation seam;
7. frozen Game-local Player projection identifies 张琛 and the selected T0 profile correctly;
8. Opening/continuation GM context receives the substantive character material, including transport premise, abilities, limits, goals and historical-knowledge non-canon boundary;
9. existing 刘备 Character Card discovery/create path remains green;
10. no existing Game is mutated merely because the new Source generation is added;
11. no schema migration or Provider call is needed for installation/discovery validation;
12. `git diff --check` clean;
13. Windows export validation PASS if product-build inputs change.

Use real product/source integration tests where available. Test-only parser acceptance is insufficient if the Owner picker still cannot see the card.

## 7. Worktree discipline

MW-011 may still be active. Do not remove or reuse its worktree.

Create exactly:

`D:/AI/Projects/.worktrees/my-world/mw-012`

on branch:

`mw-012-zhang-chen-player-character-card`

from refreshed current `main`.

Before creation run `git worktree list --porcelain`. Do not disturb unknown dirty worktrees. Keep MW-012 worktree through GPT Independent Review.

## 8. Return format

Return only after pushing the candidate branch and provide:

- exact candidate SHA;
- changed files;
- real first-party Source ingress discovered;
- exact Zhang Chen asset ID/version/generation fingerprint;
- supported T0 binding matrix;
- focused test/export evidence;
- confirmation that no broad schema/UI/mechanics platform was added;
- any residual product caveat.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**
