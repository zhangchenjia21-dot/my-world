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
G6 Surface / Information Architecture       ACTIVE — OWNER + GPT DISCUSSION
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
Player Host
→ who am I / how am I now
→ long-term high-frequency compact HUD

Narrative Host
→ what is happening / what do I do next
→ primary visual/interaction surface

World Surface Host
→ secondary RPG information actively queried by Player
```

Canonical/domain truth ownership is not the same as player information architecture.

Historical The World evidence remains useful:

> Workspace is organized for truth maintenance; UI is organized for player decisions.

Current discussion draft:

`Vibe-Coding/my world/architecture/ui/G6_SURFACE_INFORMATION_ARCHITECTURE_DRAFT_V0_1.md`

This draft is NOT implementation authority.

Candidate long-term Surface mother taxonomy:

```text
概览 / 角色 / 人物 / 行囊 / 事务 / 系统 / 地图 / 存档
```

Do not create a Surface unless it has:

```text
real player question
+ real domain owner
+ player-safe projection
+ non-trivial product value
```

Never invent fake HP/location/inventory/faction/quest state just to fill UI.

## 7. MW-011 accepted outcome

Final Owner record:

`docs/mw011/MW-011_OWNER_UAT_R3_RESULT.md`

Accepted chain:

```text
optional Character Card player_profile
→ selected Character projection
→ Final Create freezes Game-local profile
→ fail-closed Player Character Profile Projection
→ presentation-only RPG Host ViewModel
→ rich Player Host
```

Old Games do not backfill latest Source. No raw `semantic_sections` / GM-private / catalog/internal identity reaches Player profile UI.

The rich left panel is accepted for MW-011, but future redistribution to right-side Character/World surfaces is deferred G6 IA work.

## 8. Zhang Chen accepted generation

```text
asset_id: character.han_end.zhang_chen
schema: character_card.v0.2
version: 0.1.1
generation fingerprint:
0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4
```

Protected semantics remain unchanged.

## 9. Visual Runtime disposition

```text
Runtime Asset Resolution = DEFERRED
portrait / scene / authored-map = DEFERRED
```

Re-enter only for real authored first-party visual demand.

```text
authored visual presentation != gameplay/world/location/knowledge authority
map image != topology/current location/travel/pathfinding/GIS
```

## 10. MW-013 HOLD

Task packet exists:

`docs/tasks/MW-013_INTERNAL_DECLARATIVE_UI_HOST_V0_1_TASK.md`

But current status is:

```text
HOLD / NOT AUTHORIZED TO IMPLEMENT YET
```

Hold notice:

`docs/tasks/MW-013_HOLD_NOTICE.md`

If Codex already created branch/worktree or local changes:

- stop code-changing work;
- do not merge/push to main;
- preserve isolated work;
- report branch/worktree/HEAD/status;
- wait for explicit re-authorization.

Do not continue Declarative UI Host until several grounded real Surfaces / mechanic consumers establish repeated patterns.

## 11. Immediate route

```text
Owner + GPT discuss G6 Surface / IA draft
→ freeze first real Surface
→ GPT shapes exact Task Packet
→ assign Codex or KimiCode based on seam/risk
→ implementation
→ GPT Independent Review
→ Owner UAT
```

No new implementation task is authorized merely by this `AGENTS.md`.
