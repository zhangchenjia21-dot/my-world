# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions / active Task Packet.
5. this `AGENTS.md` + Independent Review evidence.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Repositories:

- implementation: `zhangchenjia21-dot/my-world`
- governance: `zhangchenjia21-dot/Vibe-Coding`

## 2. Current implementation routing — Owner update 2026-09-06

GPT owns product semantics / architecture / Task Shaping / assignment / Independent Review.

For new implementation tasks:

```text
Codex
→ high-complexity / high-importance / high-blast-radius
→ Runtime / Source / Persistence / Save / world semantics / authority boundaries
→ cross-module refactors / hard debugging / critical integration
→ architecture-critical shared UI infrastructure

KimiCode
→ bounded, clear, lower-risk implementation
→ frontend/UI/interaction on established seams
→ ordinary Character / People / Save surfaces once semantics are frozen
→ content tooling / tests / small refactors

GPT
→ semantics / architecture / shaping / assignment / IR

Owner
→ Product UAT / explicit product verdict
```

Mixed work may split `Codex mechanism + KimiCode consumer`. If a task cannot be safely split and touches core authority/persistence/runtime, prefer Codex.

Do not default new work back to Zcode unless Owner explicitly changes routing.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 3. Task identity / worktree hygiene

Use `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

```text
Capability Anchor != executable Work ID != revision/review lineage
```

New independent work uses flat immutable `MW-xxx`. Same-outcome defects stay same Work ID with Revision/Review increments.

Task worktrees:

`D:/AI/Projects/.worktrees/my-world/<task-or-revision>`

Before create/remove inspect `git worktree list --porcelain`. Remove only closed/reviewed + clean + pushed/reachable + no unknown work. Registered worktrees only via `git worktree remove`, then `git worktree prune`.

Keep active worktree through GPT Independent Review and integration verification unless explicitly disposable.

## 4. Current phase

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G5 World Semantics & GM Runtime             PRODUCT PASS / CLOSED
G5-GATE                                     PRODUCT PASS

G6 RPG Experience & Internal Declarative UI Host ACTIVE
MW-011 RPG Host / Player Profile            PRODUCT PASS / CLOSED
MW-012 Zhang Chen Character Card            ENGINEERING PASS / INTEGRATED
Visual Runtime re-entry                     AUDITED / IMPLEMENTATION DEFERRED
Character + Important Experiences semantics FROZEN
MW-014 Model-driven Information Curation    READY FOR CODEX
MW-013 Internal Declarative UI Host v0.1    HOLD / NOT AUTHORIZED YET
```

Formal current status:

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

## 5. Protected G5 invariants

- Accepted free-form Narrative remains primary and is not gated by semantic/Knowledge/Agency/Evolution success.
- `World Truth != actor Knowledge != human-player disclosure`.
- Stable NPCs may act independently; Player foreground wins.
- World Evolution may `hold` or advance selectively.
- Public d20 grounds mechanics but is not second world truth.
- Save/reopen/Restore currentness remains authoritative.
- Literary Style Reference is expression-only.
- raw accepted Narrative bytes remain authoritative; Markdown-lite remains UI projection.
- leaf UI must not receive omniscient `world_state` and filter locally.

## 6. G6 current UI architecture

Three Hosts:

```text
Player Status Host
→ portrait + live mechanics/status HUD
→ does NOT own “who am I” biography/profile information

Narrative Host
→ what is happening / what do I do next
→ primary visual/interaction surface

World Information Host
→ active player information surfaces
```

Canonical/domain truth ownership is not the same as player information architecture.

Historical The World evidence remains useful:

> Workspace is organized for truth maintenance; UI is organized for player decisions.

Current right-side mother taxonomy:

```text
概览 / 角色 / 重要经历 / 人物 / 事务 / 行囊 / 系统 / 地图 / 存档
```

Do not create a Surface unless it has a real player question, real data ownership, player-safe projection and non-trivial product value. Never invent fake HP/location/inventory/faction/quest state merely to fill UI.

## 7. Frozen Character + Important Experiences semantics

Canonical decisions:

- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`

Frozen product split:

```text
Character
→ evolving current Character Sheet
→ “现在的我是谁”
→ current state, not mutation log

Important Experiences
→ protagonist-centered milestone history
→ “我是怎样走到现在的”

Inventory
→ owns starting/current possessions in player IA
→ starting possessions do not belong in Character Surface
```

Character Surface groups include current identity/profile material such as origin/background, current social identity/role, personality/values/principles, non-numeric capabilities, long-term limitations/traits and long-term goals/self-direction.

Long-term goals belong to Character; current unresolved work belongs to future `事务`.

## 8. Model-driven information curation authority

Frozen rule:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

The model, not Program heuristics, decides:

- what changed semantically;
- what is important;
- whether Character current state changes;
- whether an event belongs in Important Experiences;
- whether accepted interaction already represents a meaningful protagonist decision;
- how player-facing information should be summarized.

Program must not build a parallel semantic judge from keyword rules, regexes, score tables, per-event-type branches, protagonist-choice evidence heuristics or mechanical long-term thresholds.

Program remains responsible for machine-level structure and integrity:

```text
current Game/Timeline binding
accepted Turn/version binding
stable identities
bounded payload syntax/type/size
atomic persistence
idempotent replay
Save / Restore / Regenerate currentness
stale-future isolation
crash/retry correctness
player-safe serialization/projection
```

Owner explicitly accepts an additional bounded model call to improve curation quality and reduce Runtime semantic complexity.

## 9. MW-011 accepted outcome / transition note

Final Owner record:

`docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`

Existing accepted chain:

```text
optional Character Card player_profile
→ selected Character projection
→ Final Create freezes Game-local profile
→ fail-closed Player Character Profile Projection
→ presentation-only RPG Host ViewModel
→ rich Player Host
```

Old Games do not backfill latest Source. No raw `semantic_sections` / GM-private / catalog/internal identity reaches Player profile UI.

The rich left panel remains accepted transitional implementation until the right-side Character Surface exists. After that, identity/profile information moves right; if no portrait/mechanic contribution exists, left may collapse rather than duplicate biography.

## 10. Zhang Chen accepted generation

```text
asset_id: character.han_end.zhang_chen
schema: character_card.v0.2
version: 0.1.1
generation fingerprint:
0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4
```

Protected semantics remain unchanged.

## 11. Visual Runtime disposition

```text
Runtime Asset Resolution = DEFERRED
portrait / scene / authored-map = DEFERRED
```

Re-enter only for real authored first-party visual demand.

```text
authored visual presentation != gameplay/world/location/knowledge authority
map image != topology/current location/travel/pathfinding/GIS
```

## 12. ACTIVE — MW-014

Executable task:

`docs/tasks/MW-014_MODEL_DRIVEN_CHARACTER_AND_MILESTONE_CURATION_V0_1_TASK.md`

Identity:

```text
Work Item: MW-014
Name: Model-driven Character + Important Experiences Curation v0.1
Primary Implementer: Codex
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: READY FOR CODEX
Branch: mw-014-model-driven-information-curator-v01
Worktree: D:/AI/Projects/.worktrees/my-world/mw-014
Return ceiling: READY FOR INDEPENDENT REVIEW
```

Required outcome:

```text
accepted Player input + GM Narrative + bounded current player information
→ Post-turn Information Curator model call
→ bounded structured curation
→ normalized durable Character current material
+ protagonist milestone material
→ Save/Restore/Regenerate/reopen currentness
→ player-safe Character + Important Experiences projections
```

This task is backend/projection only. Final Godot Character/Important Experiences Surface UI is a later KimiCode task after MW-014 Engineering PASS/integration.

## 13. MW-013 HOLD

Task packet exists:

`docs/tasks/MW-013_INTERNAL_DECLARATIVE_UI_HOST_V0_1_TASK.md`

But current status is:

```text
HOLD / NOT AUTHORIZED TO IMPLEMENT YET
```

Do not continue Declarative UI Host until several grounded real Surfaces / mechanic consumers establish repeated patterns.

## 14. Immediate route

```text
MW-014 Codex implementation
→ GPT Independent Review
→ integrate only after Engineering PASS
→ shape/authorize KimiCode Character + Important Experiences UI consumer
→ GPT Independent Review
→ Owner UAT
→ People Surface / mechanic-state consumer / next grounded surfaces
→ only later re-evaluate MW-013
```
