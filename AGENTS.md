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

GPT owns product semantics / architecture / Task Shaping / dispatch / Independent Review.

New production implementation tasks default to:

```text
Codex
→ sole default implementation agent
→ Runtime / Source / Persistence / Save / world semantics / authority boundaries
→ frontend/UI/interaction / ordinary Surfaces / visual polish
→ cross-module refactors / debugging / tests / tooling
→ architecture-critical shared infrastructure

GPT
→ semantics / architecture / shaping / dispatch / Independent Review

Owner
→ Product UAT / explicit product verdict
```

Do not continue routine Codex/KimiCode splitting. KimiCode, Zcode or another implementation agent may be used again only if Owner explicitly re-authorizes it for a future task.

Complexity / importance / blast radius still determine task splitting, spike need, acceptance depth and review rigor; they no longer choose between Codex and KimiCode.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 3. Task identity / worktree hygiene

Use `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

```text
Capability Anchor != executable Work ID != revision / review lineage
```

New independent work uses flat immutable `MW-xxx`. Same-outcome defects stay same Work ID with Revision / Review increments.

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
MW-014 Model-driven Information Curation    ENGINEERING PASS / INTEGRATED
MW-015 Character + Important Experiences    PRODUCT PASS / CLOSED
G6-D next grounded outcome                  PEOPLE SURFACE AUDIT / NOT YET AUTHORIZED TO IMPLEMENT
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

Current right-side mother taxonomy:

```text
概览 / 角色 / 重要经历 / 人物 / 事务 / 行囊 / 系统 / 地图 / 存档
```

Only grounded Surfaces appear. Never invent fake HP/location/inventory/faction/quest state merely to fill UI.

Current implemented right-side Surfaces are:

```text
概览 / 角色 / 重要经历 / 存档
```

## 7. Frozen Character + Important Experiences semantics

Canonical decisions:

- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_INITIAL_CHARACTER_CURATION_BASELINE_V1_0_DECISION.md`

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

Owner explicitly accepts bounded model calls when they materially improve semantic quality and reduce Runtime semantic-rule complexity.

## 9. MW-015 — PRODUCT PASS / CLOSED

Final Owner record:

`docs/mw015/r2/MW-015_R2_OWNER_UAT_RESULT.md`

Accepted product outcome:

```text
Game activation
→ Initial Character curator is eligible without successful opening / Player-authored Turn
→ model receives frozen Game-local player-safe starting material
→ model decides what belongs in Character and how to summarize it
→ durable Game/T0 Character baseline
→ right 角色 shows rich current Character information

later lived Turns
→ existing MW-014 curator continues evolving Character
```

Left Player Status Host remains hidden while no real portrait/mechanic contribution exists.

Visual density / typography / spacing / hierarchy are deferred G6 UI polish and do not reopen MW-015.

## 10. MW-014 — ENGINEERING PASS / INTEGRATED

Task:

`docs/tasks/MW-014_MODEL_DRIVEN_CHARACTER_AND_MILESTONE_CURATION_V0_1_TASK.md`

Independent Review:

`docs/mw014/MW-014_INDEPENDENT_REVIEW_IR1.md`

Integration verification:

`docs/mw014/MW-014_INTEGRATION_VERIFICATION.md`

The reviewed L3 consumer seam is:

`src/信息整理/L3_外交层/角色经历投影公开接口.gd`

It exposes presentation-safe current Character + Important Experiences and requires no Provider call to render/reopen.

## 11. Zhang Chen accepted generation

```text
asset_id: character.han_end.zhang_chen
schema: character_card.v0.2
version: 0.1.1
generation fingerprint:
0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4
```

Protected semantics remain unchanged.

## 12. Visual Runtime disposition

```text
Runtime Asset Resolution = DEFERRED
portrait / scene / authored-map = DEFERRED
```

Re-enter only for real authored first-party visual demand.

```text
authored visual presentation != gameplay/world/location/knowledge authority
map image != topology/current location/travel/pathfinding/GIS
```

Do not invent portrait or status data just to keep the left Host visible.

## 13. CURRENT — People Surface audit

The next strongest G6-D candidate is `人物 / People`, but implementation is not yet authorized.

Existing grounded facts:

- G5 already has Program-owned stable actor identities and runtime-created stable NPC materialization;
- actor Knowledge and Agency are durable and private by actor;
- current generic player-safe projection exposes only Player Character known facts, not a dedicated actor/relationship read model;
- stable registry membership does not imply human-player disclosure;
- no mature Relationship truth owner exists yet.

Therefore do not implement People by dumping `stable_npcs` or all known Runtime actors into UI.

Current product/architecture audit must decide:

```text
What exact player question does People answer?
Which people become visible to the human player?
What player-safe information may be shown per person?
How are entries bound to Program-owned stable actor identity?
What belongs to future Relationship rather than People v0.1?
Does model-driven curation extend to People, and with what disclosure-safe input?
How do Save / Restore / Regenerate affect People currentness?
```

Only after Owner + GPT freeze the People semantics should a new flat MW-xxx Codex Task Packet be created.

## 14. MW-013 HOLD

Task packet exists:

`docs/tasks/MW-013_INTERNAL_DECLARATIVE_UI_HOST_V0_1_TASK.md`

Current authoritative state:

```text
HOLD / NOT AUTHORIZED TO IMPLEMENT YET
```

Do not continue Declarative UI Host until several grounded real Surfaces / mechanic consumers establish repeated patterns.

## 15. Owner UAT build handoff — mandatory for product-facing work

The Owner's canonical local playable checkout is:

`D:/AI/Projects/my-world`

Every product-facing implementation follows:

```text
Implementation candidate
→ GPT Independent Review
→ Engineering PASS
→ integration to main
→ canonical local checkout synchronization
→ fresh Windows export verification
→ Owner UAT
```

Never install an unreviewed task branch into the Owner checkout. Never overwrite unknown dirty/divergent local work. Do not use reset/clean/force to hide divergence.

`run-game.cmd` / `run-game.ps1` prove export freshness only against the current local checkout; UAT preparation must first prove the checkout equals the intended reviewed main.

## 16. Immediate route

```text
People Surface product/architecture audit
→ Owner discussion / semantic freeze
→ if grounded: mint next flat MW-xxx Task
→ Codex implementation
→ GPT Independent Review
→ integration after Engineering PASS
→ canonical local checkout + fresh export
→ Owner UAT

if People is not sufficiently grounded:
→ do not force an empty/fake Surface
→ choose the next grounded G6 consumer from current evidence
```
