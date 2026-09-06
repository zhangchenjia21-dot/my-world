# MW-011 Owner UI UAT — Revision 1 Result

Date: 2026-09-06  
Work Item: MW-011  
Revision under test: 1  
Integrated main: `6338af5665c5137d9a9528776e77a13ffb924ea6`  
Engineering status before UAT: PASS / integrated  
Owner product verdict: **NOT PASS — REVISION 2 REQUIRED**

## 1. What passed

The Owner's real playable screenshot confirms the G6 R1 shell is integrated and functioning:

- Player Host renders the selected protagonist identity and T0 profile;
- World Surface defaults to `概览` and exposes bounded `存档` navigation;
- Narrative remains the dominant center surface;
- Zhang Chen-specific Character Card content is reaching GM context and is reflected in the opening prose;
- the Owner considered the current literary prose/style acceptable.

No evidence from this UAT indicates that MW-012 Character Source failed to load.

## 2. Product failure

The left Player Host remains materially too thin at a fresh game opening.

Observed visible content is essentially:

```text
主角
张琛
现代来客起点
世界 / Entry
最近行动：尚无已完成的行动
玩家回合：0
```

Large vertical space remains unused even though the selected Zhang Chen Character Card contains rich approved material: age, modern origin/background, personality, capabilities, limitations, goals, moral principles and starting possessions.

Therefore MW-011 R1 did not fully satisfy the Owner-level product outcome that the Player Host become a genuinely useful RPG information surface.

## 3. Root cause

This is an architecture/data-projection gap, not a missing-content defect.

Current chain:

```text
Character Card rich semantic_sections
→ frozen Character source_projection
→ MW-009 player-safe projection (identity/profile/world/entry/known_facts only)
→ MW-011 ViewModel (+ recent actions / turn count)
→ Player Host
```

Character Card v0.2 currently gives semantic sections only `gm_reference` / `gm_private` disclosure. R1 correctly refused to expose them directly to the human player. There is no explicit player-facing Character profile projection.

## 4. Required disposition

Per same-outcome task lineage, continue as:

**MW-011 Revision 2 — Player Character Profile Projection + Player Host Surface**

Canonical decision:

`Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`

Executable addendum:

`docs/tasks/MW-011_REVISION2_PLAYER_CHARACTER_PROFILE_SURFACE_ADDENDUM.md`

MW-012 semantics remain accepted and must not be rewritten merely to satisfy UI presentation.
