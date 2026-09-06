# MW-011 Independent Review IR#3 — Committed Profile Source + Reproducible Candidate Evidence

Status: **ENGINEERING PASS — INTEGRATION READY / OWNER UI UAT AFTER INTEGRATION**  
Work Item: **MW-011**  
Revision: **3**  
Review-Round: **IR#3**  
Reviewer: **GPT**  
Reviewed branch head: `78bd5ce26b5ec8a465a9f5d6fbcdb536925d5fc0`  
Production/content test HEAD recorded by implementer: `16c42d576b28c6119c26ff310b426d0caec202ce`  
R2 mechanism commit in lineage: `09de33c3ac34485b7a5ec7e807d0e2464d04c7ca`  
Original R3 implementation base: `6968e137e210430bab37e0a9bdbb74c346ba8bfa`  
Current implementation `main` at review time: `4118a4907becbf5c1c65166855776064fd5a1c32`  
Governance `main` at review time: `9ab0e9c9a8ff75bea60a0c3ac0ee49f3317f17ba`  
Architecture: `Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`  
R3 addendum: `docs/tasks/MW-011_REVISION3_COMMITTED_PROFILE_SOURCE_AND_REPRODUCIBLE_EVIDENCE_ADDENDUM.md`

## 1. Verdict

**ENGINEERING PASS.**

Revision 3 resolves the IR#2 candidate-integrity blocker. The exact pushed lineage now contains the Zhang Chen `source.json` bytes that the profile tests and production publication consume. The package is version `0.1.1`, contains the bounded seven-group `player_profile`, and is version-consistent with the bounded production publication script.

The R2 mechanism remains accepted: bounded optional Character presentation data is frozen through normal Game-local Source ancestry, projected through a separate fail-closed Player Character Profile projector, added to the existing presentation-only RPG Host ViewModel, and rendered in a scrollable Player Host without widening MW-009 or exposing raw Character semantic sections.

No Revision 4 is required.

## 2. Candidate lineage and exact-byte reconciliation

GitHub comparison of the original R3 base `6968e137...` to branch head `78bd5ce2...` shows three commits in one linear lineage.

The R3 correction commit:

`16c42d576b28c6119c26ff310b426d0caec202ce`

changes exactly the previously missing first-party Source package file:

`tests/fixtures/mw012/汉末三国/张琛/source.json`

The branch-head commit `78bd5ce2...` changes only:

`docs/mw011/MW-011_R2_PROFILE_SURFACE_EVIDENCE.md`

relative to `16c42d5...`. Therefore the production/content bytes exercised by the recorded clean test/publication run at `16c42d5...` are byte-identical at reviewed branch head `78bd5ce2...`; the post-test commit is evidence-only.

Current `main` advanced separately to record IR#2 / R3 governance documents. That divergence is documentation/governance-only. The reviewed R3 implementation must be reconciled onto refreshed `main` before Owner UAT, with no semantic rewrite.

## 3. IR#2 blocker F01 resolved — Zhang Chen Source bytes are committed

Independent inspection of `16c42d5.../tests/fixtures/mw012/汉末三国/张琛/source.json` confirms:

```text
schema_version = character_card.v0.2
asset_id       = character.han_end.zhang_chen
version        = 0.1.1
player_character_supported = true
```

and a committed bounded `player_profile`:

```text
headline = 24岁 · 现代穿越者
summary  = 退役武警义务兵、985高校出身、历史与军事爱好者；身体被整体搬运到汉末，从零开始。

groups in authored order:
background   / 背景
personality  / 性格
capabilities / 能力
limits       / 局限
goals        / 初始目标
principles   / 行为原则
possessions  / 随身物品
```

The content remains within the Owner-approved MW-012 Character semantics: age/background, physical transport, personality, modern knowledge/war perspective, limitations, initial goals, moral values and the five finite starting possessions. It does not add superhuman powers, local relationships, guaranteed history, automatic famous-person recognition, or pre-authored allegiance/self-rule decisions.

## 4. IR#2 blocker F02 resolved — package/script identity is consistent

The reviewed R2/R3 lineage contains:

`scripts/MW-012_张琛角色卡生产Source发布.gd`

with:

`VERSION := "0.1.1"`

and the committed package now also declares `version = 0.1.1`.

The previous clean-checkout contradiction (`script 0.1.1` vs committed package `0.1.0`) is therefore removed.

The R3 evidence records a production publication run from exact clean HEAD `16c42d5...` with:

```text
status = already_installed
asset_id = character.han_end.zhang_chen
version = 0.1.1
generation_fingerprint = 0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4
zhang_chen_present = true
owner_games_modified = false
```

GitHub exposes no CI/check status for this branch, so runtime command results remain implementer evidence; unlike IR#2, the exact committed bytes are now consistent with and capable of supporting those results.

## 5. IR#2 blocker F03 resolved — focused test is now reproducible from candidate bytes

The focused test loads the real package at:

`res://tests/fixtures/mw012/汉末三国/张琛`

and requires the real loaded Source / frozen Game / visible Player Host to contain `24岁 · 现代穿越者` and seven profile groups.

Those exact authored bytes now exist in the pushed candidate. The R3 evidence records a clean-head run at `16c42d5...` with:

`tests/mw011r2/玩家档案表面测试.gd — 45 assertions / 0 failures`.

The focused test additionally exercises real Final Create, Runtime/SQLite, real Shell rendering, reopen and Restore. This is materially stronger than dictionary-only proof.

## 6. Mechanism review

The accepted mechanism remains within the frozen R2 architecture:

- Character Card v0.2 gains one optional bounded `player_profile`; legacy cards that omit it remain valid.
- Validation is fail-loud at Source load time and bounded to `headline / summary / groups[group_id/title/items]` with explicit size/cardinality limits.
- Existing recursively forbidden live-state keys remain rejected by the normal Character Source validation path.
- `project_character_t0()` carries only the validated authored profile through the existing selected Character projection.
- Final Create continues to freeze that selected projection into Game-local state; no new persistence owner or table is introduced.
- `PlayerCharacterProfileProjectionDevice` reads only the frozen Game-local `player_profile`, revalidates it fail-closed, and has no Source Library, `semantic_sections`, `catalog_summary`, Provider or filesystem fallback.
- MW-009 remains unchanged as owner of current Player-known facts.
- RPG Host ViewModel receives the separate safe profile projection and exposes only headline/summary + display group titles/items; `group_id` and internal Source identity are not sent to leaf UI.
- Player Host renders profile before World/recent-action/session material and is vertically scrollable; Narrative retains the established 60% desktop stretch ratio.
- Game-local Opening/GM context continues to consume Character `semantic_sections`; it does not consume `player_profile`, preserving presentation-vs-GM authority separation.

## 7. Regression evidence

R3 evidence records the following from the exact clean production/content HEAD:

```text
MW-011 R2 focused profile surface     0 failures / 45 assertions
MW-011 R1 baseline                    0 failures
MW-009 safe side-panel projection     0 failures
MW-010 living-world matrix            0 failures
MW-012 Zhang Chen integration         0 failures
G4 Source v0.2 mechanism              0 failures
G4 Composition                        0 failures
G4 Final Create                       0 failures
G3 Save/Restore UI                    0 failures
Public d20 / narrative critical path  0 failures
git diff --check                      clean
Windows export                        PASS
Provider calls                        0
SQLite schema/table                   unchanged
```

No GitHub Actions status is attached to the branch, so these execution counts are implementer-run evidence. GPT independently inspected the actual Source bytes, mechanism code, visible Shell rendering code and focused test assertions.

## 8. Old-Game ancestry / no backfill

The profile projector consumes only:

`Game-local player_character.source_projection.player_profile`

and has no path to Source Library current generations. Therefore a pre-R2 Game frozen without this field remains profile-empty; a fresh Game created from Zhang Chen `0.1.1` freezes the rich profile. Reopen/Save/Restore preserve the frozen profile while dynamic timeline-derived actions/facts retain their existing currentness semantics.

This satisfies the required Source ancestry boundary.

## 9. Documentation advisory — non-blocking

The implementer evidence section titled `Changed files` omits the two generated `.gd.uid` additions that GitHub compare reports for the new profile projector and focused test. The review independently reconciled the exact GitHub file set, and the omission does not alter production/content bytes, test semantics or publication identity.

This is recorded as a documentation precision advisory, not a Revision 4 blocker. Future evidence packets should either enumerate generated `.uid` files as well or explicitly state that the human-readable list excludes generated UID companions.

A separate pre-existing advisory remains: Source generation fingerprints may vary across line-ending normalization environments until the earlier G4-03 line-ending stability matter is formally resolved. This does not invalidate the reviewed same-checkout generation/publication result.

## 10. Disposition

```text
MW-011 R1 / IR#1           ENGINEERING PASS / INTEGRATED
MW-011 R1 Owner UI UAT     NOT PASS
MW-011 R2 / IR#2           NOT PASS
MW-011 R3 / IR#3           ENGINEERING PASS — INTEGRATION READY
```

Next step:

```text
reconcile reviewed R3 lineage onto refreshed current main without semantic changes
→ run focused integration smoke/export as appropriate
→ push remote main
→ Owner creates a FRESH Zhang Chen 0.1.1 Game
→ Owner UI UAT on the rich Player Host
```

Do not request Owner UAT against the old Zhang Chen `0.1.0` Game, because its frozen profile correctly remains absent.
