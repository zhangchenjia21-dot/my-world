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

MW-015 was the final already-authorized KimiCode implementation round and is now integrated. New production implementation tasks default to:

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
MW-014 Model-driven Information Curation    ENGINEERING PASS / INTEGRATED
MW-015 Character + Important Experiences UI ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING
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

Only grounded Surfaces appear. Never invent fake HP/location/inventory/faction/quest state merely to fill UI.

Current grounded right-side Surfaces are:

```text
概览 / 角色 / 重要经历 / 存档
```

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

The former rich left panel is a transitional implementation that MW-015 has now migrated away from. Identity/profile material belongs in the right Character Surface; when no portrait/mechanic contribution exists, the left Player Status Host may collapse/hide rather than duplicate biography.

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

Do not modify MW-014 semantic authority/persistence behavior inside a UI correction unless the task explicitly stops and escalates a backend defect.

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

## 13. MW-015 — ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING

Executable task:

`docs/tasks/MW-015_CHARACTER_AND_IMPORTANT_EXPERIENCES_UI_V0_1_TASK.md`

Reviewed implementation candidate:

`3387cba213a2680b08f78b07a63ee0ecee5417ce`

Integrated main commit:

`967a856e02b761576cc4dcb773a693530dcf2fc9`

Integration verification:

`docs/mw015/MW-015_INTEGRATION_VERIFICATION.md`

Integrated product vertical:

```text
MW-014 player-safe Character / Important Experiences projection
↓
right-side 概览 | 角色 | 重要经历 | 存档
↓
Character current Sheet + milestone history
↓
left transitional biography removed
↓
empty Player Status Host collapses/hides until real portrait/mechanic consumer exists
```

No Product PASS exists until Owner UAT succeeds in the real application.

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

`run-game.cmd` / `run-game.ps1` guarantee export freshness only against the **current local checkout**. They do not prove that this checkout already equals the reviewed/integrated GitHub `main`.

Therefore every product-facing implementation must complete two distinct handoffs:

```text
Implementation candidate
→ GPT Independent Review
→ Engineering PASS
→ integration to main
→ canonical local checkout synchronization
→ fresh Windows export verification
→ Owner UAT
```

Rules:

1. The implementer must **not** install an unreviewed task branch into `D:/AI/Projects/my-world` and present it as the Owner build.
2. After Engineering PASS and integration, the local-execution agent for UAT preparation defaults to Codex unless Owner says otherwise.
3. Before touching `D:/AI/Projects/my-world`, inspect branch/status/worktrees. Never overwrite unknown dirty work, local commits, or divergence.
4. If the canonical checkout is clean and safely fast-forwardable, fetch and fast-forward `main` to the exact reviewed/integrated `origin/main` (or the explicitly specified integration SHA).
5. Verify local `HEAD` equals the intended integrated commit before export.
6. Run `./run-game.ps1 -ValidateExportOnly` (PowerShell equivalent accepted) so `build/windows/my-world.exe`, `.pck`, and freshness metadata are rebuilt/validated against that checkout.
7. Report the exact local `HEAD` and export-validation result. Owner UAT starts only after this handoff passes.
8. If local checkout is dirty, divergent, on an unexpected branch, or cannot reach the intended integration commit, STOP and report; never use reset/clean/force to make the problem disappear.
9. Do not edit `run-game.cmd` on every task merely to force freshness. The launcher remains generic; the required operation is **sync reviewed main → validate fresh export → hand off to Owner**.

For non-product-facing tasks that do not require Owner UAT, this build handoff is not automatically required.

## 16. Immediate route

```text
prepare canonical local checkout + fresh export for MW-015 Owner UAT
→ Owner UAT
→ if PASS: mark MW-015 PRODUCT PASS / CLOSED
→ choose next grounded G6 outcome
→ all new implementation tasks default to Codex

if Owner UAT NOT PASS:
→ GPT root-cause / scope classification
→ same MW-015 revision lineage for same-outcome defects
→ Codex implements required correction
→ GPT Independent Review
→ integrate after Engineering PASS
→ canonical local checkout sync + fresh export
→ Owner UAT again
```
