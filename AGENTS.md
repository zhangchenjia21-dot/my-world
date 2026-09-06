# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions.
5. this `AGENTS.md` + current Task Packet / Independent Review evidence.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Repositories:

- implementation: `zhangchenjia21-dot/my-world`
- governance: `zhangchenjia21-dot/Vibe-Coding`

## 1A. Current implementation routing — Owner update 2026-09-06

GPT owns product semantics / architecture / Task Shaping / agent assignment / Independent Review.

For **new implementation tasks**, GPT chooses between Codex and KimiCode by complexity, importance, blast radius and architectural authority:

```text
Codex
→ high-complexity / high-importance / high-blast-radius
→ Runtime / Source / Persistence / Save / world semantics / authority boundaries
→ cross-module refactors / hard debugging / critical integration
→ architecture-critical UI tightly coupled to core state

KimiCode
→ bounded, clear, lower-risk work
→ frontend/UI/interaction over established seams
→ ordinary surfaces/consumers, content tools, test additions, small refactors
→ batch content production once contracts are stable

GPT
→ semantics / architecture / Task Shaping / assignment / Independent Review

Owner
→ Product UAT / explicit product verdict
```

Cleanly separable mixed work may be split `Codex mechanism/backend + KimiCode UI/consumer`. If a task cannot be safely split and touches core authority/persistence/runtime, prefer Codex.

Do not default new work back to Zcode unless Owner explicitly changes routing again.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 1B. Task identity

Use `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

```text
Capability Anchor != executable Work ID != revision/review lineage
```

New independent work uses flat immutable `MW-xxx`. Same-outcome defects stay the same Work ID with Revision + Review-Round increments.

## 1C. Worktree hygiene

All task worktrees:

`D:/AI/Projects/.worktrees/my-world/<task-or-revision>`

Before creating/removing worktrees inspect `git worktree list --porcelain`. Remove only closed/reviewed + clean + pushed/reachable/integrated + no unknown user work. Registered worktrees are removed only with `git worktree remove`, followed by `git worktree prune`.

Keep active task worktrees through GPT Independent Review and integration verification unless explicitly disposable.

## 2. Current phase

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G5 World Semantics & GM Runtime             PRODUCT PASS / CLOSED
G5-GATE                                     PRODUCT PASS

G6 RPG Experience & Internal Declarative UI Host ACTIVE
MW-011 G6 RPG Host / Player Profile outcome PRODUCT PASS / CLOSED
MW-012 Zhang Chen Player Character Card     ENGINEERING PASS / INTEGRATED
G6 Visual Runtime re-entry                  AUDITED — IMPLEMENTATION DEFERRED
MW-013 Internal Declarative UI Host v0.1    READY FOR CODEX
```

Formal current status:

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

## 3. Protected G5 invariants

- Accepted free-form Narrative remains primary and is not gated by semantic/Knowledge/Agency/Evolution extraction success.
- Runtime may materialize established consequences without becoming a universal simulator.
- `World Truth != actor Knowledge != human-player disclosure`.
- Stable NPCs may act independently; Player foreground wins.
- World Evolution may `hold` or advance selectively.
- Program-owned Public d20 grounds normal mechanics opportunities; accepted Narrative remains the concrete scene consequence source.
- Save/reopen/Restore currentness remains authoritative.
- Literary Style Reference is expression-only, never game truth/mechanics/evolution authority.
- Raw accepted Narrative bytes remain authoritative; Markdown-lite is disposable UI projection only.
- Do not pass omniscient `world_state` to leaf UI and filter there.

## 4. MW-011 final disposition

Formal Owner closeout:

`docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`

Current disposition:

```text
MW-011 R1 / IR#1              ENGINEERING PASS / INTEGRATED
MW-011 R1 Owner UI UAT        NOT PASS
MW-011 R2 / IR#2              NOT PASS
MW-011 R3 / IR#3              ENGINEERING PASS / INTEGRATED
MW-011 R3 Owner UI UAT        PRODUCT PASS
MW-011                         CLOSED
```

Accepted profile data flow remains:

```text
optional Character Card v0.2 player_profile
→ selected Character projection
→ Final Create freezes profile into Game-local source_projection
→ fail-closed Player Character Profile Projection
→ presentation-only RPG Host ViewModel
→ rich bounded Player Host
```

Protect these boundaries:

- existing v0.2 cards without `player_profile` remain valid;
- old Games do not backfill from Source current;
- projector reads only frozen Game-local profile;
- no raw `semantic_sections`, `gm_reference`, `gm_private`, `catalog_summary`, IDs/hashes/fingerprints or Source-current fallback reaches Player UI;
- MW-009 remains owner of current Player-known facts;
- Narrative remains primary;
- no stat ontology, Inventory mechanics, external UI DSL, Mod schema, Provider summarization or persistence table was added.

### Deferred IA note from Owner UAT

Some current Player Host material may later move to future right-side World/secondary surfaces after those surfaces and categories are grounded.

Current placement is accepted. Do not reopen MW-011 simply to redistribute fields.

Do not create empty right-side tabs for 人物 / 关系 / 势力 / 任务 / 物品 / 地图 / Timeline until a real domain owner and player-safe projection exist.

## 5. Zhang Chen current generation

Protected accepted generation:

```text
asset_id: character.han_end.zhang_chen
schema: character_card.v0.2
version: 0.1.1
generation fingerprint:
0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4
```

Visible authored groups:

```text
背景
性格
能力
局限
初始目标
行为原则
随身物品
```

MW-012 semantics remain protected: physical transport, age 24 at selected T0, no local prior identity/network/history, historical memory as protagonist belief rather than guaranteed future truth, no automatic famous-person recognition, written-script-only literacy limitation, finite starting possessions, Player ownership of future meaningful choices.

## 6. G6 visual-runtime re-entry disposition

Canonical audit:

`Vibe-Coding/my world/architecture/ui/G6_VISUAL_RUNTIME_REENTRY_AUDIT_2026-09-06.md`

Current decision:

```text
Runtime Asset Resolution implementation = DEFERRED
portrait / scene / authored-map implementation = DEFERRED
```

Do not build visual/media infrastructure merely to satisfy roadmap ordering. Re-enter only when a real first-party authored visual demand exists.

Keep:

```text
authored visual presentation != gameplay/world/location/knowledge authority
map image != topology/current location/travel/pathfinding/GIS
```

## 7. ACTIVE — MW-013 Internal Declarative UI Host v0.1

Canonical architecture:

`Vibe-Coding/my world/architecture/ui/G6_INTERNAL_DECLARATIVE_UI_HOST_V0_1_DECISION.md`

Executable task:

`docs/tasks/MW-013_INTERNAL_DECLARATIVE_UI_HOST_V0_1_TASK.md`

Identity:

```text
Work Item: MW-013
Name: Internal Declarative UI Host v0.1
Capability-Anchor: G6 RPG Experience & Internal Declarative UI Host
Primary Implementer: Codex
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: READY FOR CODEX
Branch: mw-013-internal-declarative-ui-host-v01
Worktree: D:/AI/Projects/.worktrees/my-world/mw-013
Return ceiling: READY FOR INDEPENDENT REVIEW
```

Required data flow:

```text
existing safe RPG Host ViewModel
→ bounded program-internal UI definition material
→ reusable Internal Declarative UI Host renderer
→ Godot Controls
```

v0.1 proves reuse with at least Player Host structured information + World Overview structured information.

Authorized kinds only:

```text
section
status_list
fact_list
```

Definitions are internal and generated from already-safe ViewModel material. They cannot query Runtime or Source and cannot execute code.

Forbidden in MW-013:

- external World/Character/Expansion UI definitions;
- G8 schema/Mod authoring;
- arbitrary callback/method dispatch;
- arbitrary NodePath/expression/binding/SQL/runtime query;
- filesystem/OS/Provider capability;
- raw `world_state` or raw Character sections;
- new domain owners/persistence tables;
- Action Intent;
- visual resolver/portrait/scene/map;
- right-side IA redistribution;
- Narrative/Composer or Save-action declarativization.

Save controls and Narrative/Composer remain imperative and unchanged.

## 8. G6 route discipline

```text
Runtime projection
→ presentation-only ViewModel
→ real UI consumer                         DONE / MW-011
→ visual-runtime re-entry audit            DONE / DEFER IMPLEMENTATION
→ grounded real surfaces                   only as real domain owners exist
→ Internal Declarative UI Host v0.1        ACTIVE / MW-013
→ bounded Action Intent
→ responsive / Theme / navigation
→ Owner UAT / visual polish
```

External World Pack / Mod UI declaration remains G8.

## 9. Immediate route

```text
Codex refreshes implementation + governance main
→ creates/uses D:/AI/Projects/.worktrees/my-world/mw-013
→ implements only MW-013 bounded scope
→ pushes exact clean candidate
→ GPT Independent Review on actual diff/tests/evidence
→ only after PASS may integration / Owner UAT proceed
```
