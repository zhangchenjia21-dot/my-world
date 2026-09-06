# MW-015 Owner UAT — Revision 1 Result

Status: **NOT PASS / CORRECTION REQUIRED**  
Work Item: **MW-015**  
Revision: **1**  
Owner UAT date: **2026-09-06**  
Integrated implementation baseline: `967a856e02b761576cc4dcb773a693530dcf2fc9` + post-integration verification

## 1. Owner verdict

**NOT PASS. MW-015 may not close.**

The Owner launched the integrated application and confirmed that the shell migration itself is present:

- left Player Status Host is collapsed/hidden when no legitimate portrait/mechanic contribution exists;
- right information navigation exposes `概览 / 角色 / 重要经历 / 存档`.

However the `角色` Surface regressed materially in product value. It currently presents only a thin starting headline/summary such as `24岁 · 现代穿越者` plus a short sentence, while the previously Owner-accepted rich profile material is no longer visible.

The Owner explicitly reported that the Character information now feels incomplete and that much of the useful information appears to be missing.

## 2. Root-cause classification

This is primarily a **Task Shaping / cross-contract product regression**, not evidence that the R1 implementer failed to follow its packet.

MW-011 R3 had already received Owner Product PASS specifically because the Player Host exposed materially rich starting Character information including background, personality, capabilities, limitations, goals and principles.

MW-014 then required that the frozen starting `player_profile` remain visible/useful before any lived curator update.

MW-015 R1 nevertheless narrowed the initial/no-curation Character Surface to headline/summary only and prohibited arbitrary profile-group fallback in order to avoid leaking starting possessions into Character. That safety concern was valid, but the chosen correction over-pruned legitimate Character information and violated the product value already proven in MW-011 and the useful-starting-view requirement of MW-014.

Therefore the defect is:

```text
correct left/right responsibility migration
+
incorrect loss of legitimate Character information
```

The left Host collapse itself is **not** rejected by this UAT.

## 3. Frozen correction direction

Keep the accepted IA direction:

```text
Player Status Host
→ portrait + real live mechanics/status only
→ may remain collapsed/hidden today

World Information Host / 角色
→ owns the full player-facing Character Sheet
```

Correction must restore a materially rich Character Sheet from the Game's frozen starting player-facing Character material before the first lived curator update, while excluding information that belongs to other domains, especially starting/current possessions.

Required Character-owned starting material includes, when present in the frozen Game-local profile:

- identity / basic profile;
- origin / background;
- current social identity/role;
- personality / values / principles;
- non-numeric capabilities / strengths;
- limitations / long-term traits;
- long-term goals / self-direction.

Must not reintroduce into Character:

- starting/current possessions, equipment, money or consumables;
- HP/MP/numeric mechanic state;
- relationship truth;
- open tasks/commitments;
- omniscient or GM-private material.

Do not solve this with title-keyword/regex filtering or another Program semantic-judge layer. Use explicit structured contract/projection ownership; if the existing frozen profile representation is insufficient to distinguish safe Character-owned material deterministically, stop for GPT architecture review rather than adding heuristics.

After lived curation succeeds, the current Character Sheet must continue to evolve from the model-curated current state without duplicating or losing the valid starting baseline.

## 4. Lineage / next route

Outcome is unchanged, so this remains the same Work Item:

```text
MW-015
Revision 2
→ Character information preservation correction
→ Codex implementation
→ GPT Independent Review
→ Engineering PASS / integration
→ canonical local checkout sync + fresh export
→ Owner UAT again
```

MW-013 remains HOLD / NOT AUTHORIZED.
