# ADDENDUM｜MW-012 Revision 2｜Content Fidelity + Production Publish Proof

Type: revision addendum / bounded repair  
Work Item: **MW-012**  
Name: **Zhang Chen Player Character Card**  
Capability-Anchor: **G4 Primary Source Assets & Local Game Creation**  
Triggered-By: `docs/mw012/MW-012_INDEPENDENT_REVIEW_IR1.md`  
Implementer: **Zcode + GLM-5.3-flash**  
Reviewer: **GPT**  
Revision: **2**  
Review-Round: **1 → 2**  
Status: **REVISION REQUIRED — READY FOR ZCODE**  
Existing Branch: `mw-012-zhang-chen-player-character-card`  
Required Worktree: `D:/AI/Projects/.worktrees/my-world/mw-012`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 1. Outcome

Repair only the three IR#1 findings while preserving the accepted MW-012 architecture and content identity.

Do not redesign the Character schema, Source ingress, T0 projection or New Game UI.

## 2. Required repairs

### R2-01 — literacy-only wording

In `t0/han_t0_transport.md`, replace the ambiguous statement that Zhang Chen lacks `本地语言文字能力` with unambiguous literacy-only wording.

Required semantics:

- he has not learned clerical script;
- he initially cannot read the era's written material;
- reading may be learned through play;
- this task does **not** assert a new inability to speak/understand local speech;
- no language simulation system is added.

Keep the rest of the T0 profile semantically unchanged.

### R2-02 — make production publish proof real

The current focused test contains dead code after `_finish(); return`; the publish-script smoke assertion must be moved before termination and actually execute.

At minimum prove in a task-owned environment that:

- `scripts/MW-012_张琛角色卡生产Source发布.gd` loads successfully;
- its asset/package constants point to the reviewed Zhang Chen card;
- the normal Managed Source path still validates/publishes/discovers the card.

After the corrected candidate is integrated into current `main`, execute the already Owner-approved bounded production publication command:

```text
godot --headless --path . --script scripts/MW-012_张琛角色卡生产Source发布.gd -- --confirm-owner-production-source-prep
```

Record only safe evidence:

- success/already-installed status;
- `character.han_end.zhang_chen` present in current production Source inventory;
- exact generation fingerprint;
- existing Games modified = false.

Do not expose secrets or arbitrary filesystem content.

### R2-03 — remove unrelated file

Remove the unrelated candidate addition:

`tests/mw004/最小玩家主权原则测试.gd.uid`

unless a concrete MW-012-specific Godot dependency proves it is required. If retained, stop and report the concrete reason before review rather than silently keeping it.

## 3. Preserve accepted R1 behavior

Do not change without a new concrete blocker:

- `asset_id = character.han_end.zhang_chen`;
- `schema_version = character_card.v0.2`;
- `version = 0.1.0`;
- seven Han-end Entry bindings via one reusable `han-t0-transport` profile;
- no cross-world eligibility;
- historical-memory non-canon boundary;
- no automatic famous-person visual recognition;
- Player-owned future allegiance/self-rule/return/reveal choices;
- finite starting possessions;
- no new Character schema / Creator / inventory system / UI redesign / Expansion / declarative UI platform.

The exact generation fingerprint is expected to change if Source bytes change. Report the new exact fingerprint; do not preserve the old fingerprint artificially.

## 4. Focused proof

Rerun at minimum:

- MW-012 focused integration suite with the publish-script smoke now reachable;
- Character Source v0.2 mechanism regression;
- G4-05 Composition regression;
- G4-06 Final Create regression;
- Liu Bei discovery/create regression inside the focused suite;
- `git diff --check`;
- Windows export validation if required by current build/export rules.

Then, after integration, execute the production Source publication step and record its bounded result.

## 5. Return format

Return:

- exact R2 candidate SHA;
- exact changed files relative to refreshed current base;
- corrected T0 wording;
- proof that the previously dead publish-script assertion now runs;
- removal status of the unrelated MW-004 uid;
- new exact generation fingerprint;
- focused/regression results;
- production publication result after integration if already performed;
- confirmation that no broad authoring/platform work was added.

Highest allowed status:

**READY FOR INDEPENDENT REVIEW**
