# MW-012 Independent Review IR#1 — Zhang Chen Player Character Card

Status: **NOT PASS — REVISION 2 REQUIRED**  
Work Item: **MW-012**  
Revision: **1**  
Review-Round: **IR#1**  
Reviewer: **GPT**  
Reviewed candidate: `82c4c21656ee08bbfa48d3257174c6c6359747ca`  
Candidate parent: `fef7c203bfc5ccc4645cfb4b28fb30c46c05adb9`  
Task: `docs/tasks/MW-012_ZHANG_CHEN_PLAYER_CHARACTER_CARD_TASK.md`  
Owner content authority: `docs/tasks/inputs/MW-012_ZHANG_CHEN_CHARACTER_CARD_V0_1.md`

## 1. Verdict

**NOT PASS. Revision 2 is required.**

The core Source integration is directionally correct and most acceptance coverage is strong: the candidate uses the existing `character_card.v0.2` contract, normal Managed Source Library installation/discovery, seven Han-end Entry bindings, Final Create, frozen Game-local projection and GM context. It does not add a new schema, picker hardcoding, inventory platform or G6 declarative UI work.

However, three bounded defects prevent Engineering PASS.

## 2. Finding F01 — T0 text overstates the Owner-approved language limitation

`tests/fixtures/mw012/汉末三国/张琛/t0/han_t0_transport.md` currently says:

> `没有本地语言文字能力（不识隶书）`

The Owner-approved concept establishes only that Zhang Chen has not learned clerical script and initially cannot read Three-Kingdoms-era written material. The task explicitly keeps a new language-simulation system out of scope.

The current phrase can reasonably be read as "no local spoken-language ability plus no writing ability", which materially changes the protagonist premise and introduces a language limitation the Owner did not specify.

### Required correction

Preserve the intended literacy-only limitation, e.g. wording equivalent to:

`没有本地书面文字识读能力（不识隶书）`

or another unambiguous formulation that says he initially cannot read the era's written script, without asserting inability to speak/understand local speech.

Do not add a language simulation mechanic.

## 3. Finding F02 — claimed production publish-script proof is unreachable, and Owner production installation is not completed

`tests/mw012/张琛角色卡集成测试.gd` calls:

```gdscript
runtime.close()
_finish()
return
```

before the later block that loads `scripts/MW-012_张琛角色卡生产Source发布.gd` and asserts its contract constants.

Therefore that assertion is dead code and is never executed by the focused suite. The evidence document nevertheless claims that the production prep script's compile/contract smoke is covered.

The evidence also states that actual publication to the Owner production Source Library remains for the Owner to execute. The Owner had already explicitly requested that the card be added to the current playable product, so MW-012 is not complete while the only current-product activation step is left unexecuted.

### Required correction

1. Make the publish-script smoke assertion reachable and actually execute it in the focused test (without touching Owner production data).
2. After the reviewed content is integrated, execute the bounded existing production publish command against the Owner's production Source Library using the already-approved opt-in semantics.
3. Record safe evidence that `character.han_end.zhang_chen` is present as the current generation in production inventory. Do not record secrets or mutate existing Games.
4. Confirm New Game inventory can discover the installed current generation through the normal Source Library seam.

Do not broaden the script into an arbitrary-path installer or new asset platform.

## 4. Finding F03 — unrelated unreported file in candidate

The actual compare contains:

`tests/mw004/最小玩家主权原则测试.gd.uid`

as a newly added file. It is unrelated to MW-012 and is omitted from the candidate's stated changed-file list.

### Required correction

Remove this unrelated MW-004 `.uid` from the MW-012 candidate unless a concrete current Godot requirement proves it is necessary for MW-012 (none is evident from the reviewed diff). Revision evidence must list the exact actual changed files.

## 5. What already passes

The following aspects are accepted and should not be redesigned in Revision 2:

- stable identity `character.han_end.zhang_chen` / `character_card.v0.2` / `0.1.0`;
- Player-character eligibility via the existing card field rather than picker hardcoding;
- one reusable `han-t0-transport` profile bound to the seven current Han-end Entries;
- unrelated-world `no_world_coverage` behavior;
- physical-transport premise, age 24 and no pre-existing local identity/network;
- modern history memory as protagonist belief/knowledge, not World Truth, guaranteed canon, NPC destiny or World Evolution command;
- no automatic visual recognition of famous figures without in-world evidence;
- Player-owned future allegiance/self-rule/reveal/return choices;
- existing Character/Managed Source/Final Create/GM-context architecture;
- no new schema, Creator, inventory platform, mechanic or declarative UI system.

## 6. Revision 2 scope

Revision 2 is intentionally small:

```text
clarify literacy-only T0 wording
+ repair reachable publish-script proof
+ complete Owner-approved production Source publication after integration
+ remove unrelated MW-004 uid
+ rerun focused/regression proof
```

No broader Character authoring pipeline belongs inside MW-012. The separate throughput concern exposed by this task may inform a later first-party batch-authoring task.

## 7. Current status

MW-012 R1 / IR#1:

**NOT PASS — REVISION 2 REQUIRED**

Use the same Work ID `MW-012`; do not mint a new Work ID for these same-outcome corrections.
