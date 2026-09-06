# ADDENDUM｜MW-011 Revision 3｜Committed Profile Source + Reproducible Candidate Evidence

Type: Independent Review correction addendum  
Work Item: **MW-011**  
Name: **G6 RPG Host ViewModel Baseline — Player Character Profile Surface**  
Capability-Anchor: **G6 RPG Experience & Internal Declarative UI Host**  
Triggered-By: `docs/mw011/MW-011_INDEPENDENT_REVIEW_IR2.md`  
Implementer: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Revision: **3**  
Review-Round: **IR#2 → IR#3**  
Status: **REVISION REQUIRED — READY FOR ZCODE**  
Existing branch: `mw-011-r2-player-character-profile-surface` may be reused after refresh/rebase, or use `mw-011-r3-player-character-profile-source-fix` if a clean branch is safer.  
Required worktree: keep/reuse `D:/AI/Projects/.worktrees/my-world/mw-011-r2` only if clean and safe; otherwise create `D:/AI/Projects/.worktrees/my-world/mw-011-r3` through normal worktree hygiene.  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Repair the candidate/evidence mismatch discovered in IR#2 without redesigning the accepted R2 mechanism.

The exact pushed candidate must contain the same Zhang Chen profile bytes that are tested, fingerprinted and production-published.

## 2. Mandatory refresh

Before editing:

- refresh `zhangchenjia21-dot/my-world/main`;
- refresh `zhangchenjia21-dot/Vibe-Coding/main`;
- inspect current worktrees and dirty state;
- do not discard unknown user work;
- preserve the R2 mechanism unless a concrete integration conflict requires STOP/report.

Current formal review is:

`docs/mw011/MW-011_INDEPENDENT_REVIEW_IR2.md`

Canonical architecture remains:

`Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`

## 3. R3-01 — commit the actual Zhang Chen profile Source

The reviewed R2 branch claimed this file changed but did not actually commit it:

`tests/fixtures/mw012/汉末三国/张琛/source.json`

Commit the real intended first-party update.

Required properties:

```text
schema_version = character_card.v0.2
asset_id       = character.han_end.zhang_chen
version        = 0.1.1   # unless a concrete final-byte reason requires the next version
player_character_supported = true
```

Add the bounded `player_profile` with the exact R2 contract:

```text
headline
summary
groups[1..8]
  group_id
  title
  items[1..8]
```

Required seven authored groups, in this order:

```text
background   / 背景
personality  / 性格
capabilities / 能力
limits       / 局限
goals        / 初始目标
principles   / 行为原则
possessions  / 随身物品
```

Content must remain faithful to the already accepted MW-012 Owner semantics. Do not add powers, equipment, relationships, guaranteed history, automatic person-recognition or new Character decisions.

## 4. R3-02 — exact candidate identity must be self-consistent

The production publish script, package and evidence must agree on the same version.

At candidate HEAD:

```text
scripts/MW-012_张琛角色卡生产Source发布.gd VERSION
== committed Zhang Chen source.json version
== loaded generation identity.version
```

Do not leave a script expecting `0.1.1` while the committed package remains `0.1.0`.

## 5. R3-03 — clean candidate proof

All focused and regression evidence must come from the exact pushed candidate, not a dirty worktree.

Before final test/publication evidence, record:

```text
git rev-parse HEAD
git status --short
```

`git status --short` must be empty.

Then run at minimum:

- `tests/mw011r2/玩家档案表面测试.gd`;
- MW-011 R1 regression;
- MW-009 regression;
- MW-012 integration regression with updated version/fingerprint expectations;
- G4 Character v0.2 mechanism regression;
- G4 Composition + Final Create regression;
- Save/Restore UI regression;
- relevant living-world / d20 / narrative regressions named in R2 evidence;
- `git diff --check`;
- Windows export validation.

Provider calls remain 0. SQLite schema/table remains unchanged.

## 6. R3-04 — production publication from exact committed bytes

Only after the exact candidate is committed and clean, execute the existing bounded Owner-approved publication seam:

```text
godot --headless --path . --script scripts/MW-012_张琛角色卡生产Source发布.gd -- --confirm-owner-production-source-prep
```

Record safe evidence:

- exact clean candidate HEAD used for publication;
- status installed/already-installed;
- `character.han_end.zhang_chen`;
- exact version;
- exact generation fingerprint computed from the committed candidate bytes;
- current production inventory discovers the same generation;
- `owner_games_modified=false`.

Do not preserve the previously reported `0b6cb72a...` fingerprint unless the final clean committed bytes actually reproduce it.

## 7. R3-05 — evidence integrity

Update `docs/mw011/MW-011_R2_PROFILE_SURFACE_EVIDENCE.md` or create an R3 evidence file so the changed-file list matches GitHub compare exactly.

Do not list files that are only modified locally but absent from the pushed candidate.

The evidence must explicitly distinguish:

```text
candidate bytes reviewed
runtime test results from that candidate
production publication result from that candidate
```

## 8. Preserve accepted R2 mechanism

Do not redesign without a concrete blocker:

- optional bounded Character Card v0.2 `player_profile`;
- existing cards without it remain valid;
- selected projection freezes it through normal Game-local ancestry;
- no existing Game backfill from Source current;
- separate fail-closed Player Character Profile Projection;
- no raw semantic_sections/catalog_summary/GM/private fallback;
- MW-009 remains unchanged as Player-known-facts owner;
- ViewModel remains presentation-only;
- Player Host renders profile before World/recent action/session data;
- left Host scrolls; Narrative remains primary;
- no generic UI DSL, stat ontology, Inventory mechanics, Mod schema, Provider summarization or persistence changes.

## 9. Optional same-file cleanup

If `src/main.tscn` is touched in R3, duplicate identical `layout_mode` / `separation` assignments inside `PlayerPanelColumn` may be removed as a no-semantic-change cleanup. Do not otherwise broaden UI polish scope.

## 10. Return format

Return:

- exact R3 candidate SHA;
- exact refreshed base SHA;
- `git status --short` proof from final candidate (clean);
- exact GitHub changed-file list;
- committed Zhang Chen version and visible `player_profile` groups;
- exact new generation fingerprint;
- focused/regression/export results;
- production publication result from the exact committed candidate;
- confirmation old Games do not backfill;
- confirmation no raw GM/semantic material reaches UI;
- confirmation no architecture/platform scope was added.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**
