# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md` + Owner collaboration preferences.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions / active Task Packet.
5. this `AGENTS.md` + Independent Review evidence.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Repositories:

- implementation: `zhangchenjia21-dot/my-world`
- governance: `zhangchenjia21-dot/Vibe-Coding`

## 2. Agent routing

```text
GPT
→ product semantics / correction architecture / Task Shaping / dispatch / Independent Review / UAT interpretation

Codex
→ sole default production implementer and local UAT-build preparation agent

Owner
→ Product UAT / explicit product verdict for player-facing outcomes
```

KimiCode / Zcode / other implementers require explicit future Owner re-authorization. Gemini review remains cancelled.

## 3. Task identity / worktrees

Use `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

```text
Capability Anchor != executable Work ID != Revision/Review lineage
```

New independent outcomes use flat immutable `MW-xxx`. Same-outcome defects stay on the same Work ID with Revision/Review increments.

Task worktrees:

`D:/AI/Projects/.worktrees/my-world/<task-or-revision>`

Inspect worktrees before create/remove. Never destroy unknown work. Keep active worktree through GPT Independent Review and integration verification.

## 4. Current phase / route

Canonical governance route is `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.3` and status is `MY_WORLD_CURRENT_STATUS.md@v17.3`.

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G5 World Semantics & GM Runtime             PRODUCT PASS / CLOSED

G6 RPG Core Closure + UAT Observability + Internal Dynamic UI ACTIVE
```

Current G6 facts:

```text
MW-011 RPG Host / Player Profile            PRODUCT PASS / CLOSED
MW-014 Model-driven Information Curation    ENGINEERING PASS / INTEGRATED
MW-015 Character + Important Experiences    HISTORICAL PRODUCT PASS / POST-PASS FINDING REOPENED
MW-017 People Identity Bridge               ENGINEERING PASS / INTEGRATED
MW-018 People Curation + Card Surface        ENGINEERING PASS / INTEGRATED / PRODUCT FAIL — REVISION REQUIRED
MW-019 Five Recommended Actions             ENGINEERING PASS / INTEGRATED / PRODUCT FAIL — REVISION REQUIRED
```

Formal Owner UAT record:

`docs/uat/G6_PACKAGE0_OWNER_UAT_U1.md`

## 5. CURRENT gate — Package 0 correction shaping

Combined Owner UAT U1 is complete. Do not treat MW-018 or MW-019 as Product PASS.

Preferred correction order from current governance status:

```text
A. MW-018 Revision
→ known/off-screen player-known People eligibility
→ exact identity seam remains mandatory
→ no display-name guessing
↓
B. MW-015 Revision
→ Important Experiences returns to sparse milestone semantics
↓
C. MW-019 Revision
→ concise recommendation labels
→ click produces detailed editable composer draft
→ five standalone alternative next actions
→ larger/more readable recommendation + composer UI
↓
focused Owner re-UAT
↓
Package 0 close
↓
Package 1 UAT Observability / Debug Mode v0.1
```

Because MW-018 and MW-015 both touch Information Curation, do not make conflicting parallel edits without an explicit integration plan.

## 6. MW-018 UAT correction boundary

Observed failure:

- Player had already learned about `钟繇` and later explicitly recalled him in a player-authored turn.
- No `钟繇` People card appeared.
- Two incidental current-scene soldiers did receive cards.

Current architecture makes only current identity-receipt-bound actors eligible for People update. This is too narrow relative to frozen People product semantics.

Correction must preserve:

- People = player-known latest snapshot, not actor registry;
- exact stable identity, never display-name/fuzzy/first-match authority;
- Player assertion alone does not automatically mint World Truth or a real actor when identity/existence is unresolved;
- model decides persistent memory value; Program does not add encounter-count/name/importance thresholds;
- off-screen/player-known persons may be considered when safely exact-resolved through accepted history/current evidence;
- unresolved identity remains no update rather than guessed card;
- incidental scene actors do not get cards merely because they are receipt candidates.

The correction may extend the existing identity/receipt seam if needed, but must remain bounded and currentness-safe; do not create a universal entity resolver.

## 7. MW-015 post-PASS correction boundary

Observed extended-play failure: `重要经历` behaved like per-turn recap.

Required correction:

- Important Experiences remain sparse protagonist milestones;
- ordinary turns very often produce no update;
- model judges lasting identity/life-trajectory significance;
- no turn-count threshold, keyword router, importance score or Program semantic rule engine.

Not yet authorized by this finding alone:

- adding a separate `简要回顾` product surface;
- moving `重要经历` under Character or otherwise changing top-level IA.

Those remain explicit future product decisions unless Owner approves them.

## 8. MW-019 UAT correction boundary

Protected rule:

> **Five recommended actions != five allowed actions.**

Confirmed corrections:

```text
recommendation display
→ concise standalone action-direction label
→ click
→ detailed editable draft in PlayerInput
→ never auto-send
```

Five recommendations must be five independently selectable next-action alternatives, not one plan split into five sequential sentences.

Program must not enforce fixed semantic categories/diversity quotas; model/prompt owns open recommendation semantics.

Also increase practical font/control/padding/spacing for recommendation/composer readability. This is bounded playability correction, not final visual polish.

Character-guided recommendation tendency remains later Core Package work and does not replace this basic independence requirement.

## 9. Package 1 UAT Observability / Debug Mode — ROUTE AUTHORIZED NEXT

After Package 0 closes, GPT re-Task-Shapes this as a new bounded executable outcome.

Target:

```text
Debug Mode OFF
→ normal player experience unchanged

Debug Mode ON
→ per accepted Turn compact UAT trace
→ domain/lane terminal + changed / no-change / failed / stale / cancelled
→ automatic human-readable error reason on abnormal terminal
```

Initial consumers: Narrative, World semantic, actor/NPC materialization/identity bridge, Character, Important Experiences, People, Recommendations, Save/Restore/currentness.

Open Threads, mechanics/System and Inventory join the same read-only diagnostic projection later.

Boundaries:

- default debug view shows whether a domain changed plus terminal state / Turn / Provider / Model / necessary evidence;
- do not expose hidden GM-private / NPC-private semantic values by default;
- player-visible projections may show safe diff;
- Debug Mode is read-only and never changes model input, world truth, mechanics, mutation, currentness or validation strictness;
- no API key / credential / unrelated local privacy;
- no giant EventBus or speculative universal telemetry framework.

Full polished player-facing `本回合变化` remains later Product Expansion; Package 1 is the UAT/debug slice only.

## 10. Protected world/runtime invariants

- Accepted free-form Narrative remains primary and is not gated by semantic/Knowledge/Agency/Evolution/curation/recommendation success.
- `World Truth != actor Knowledge != human-player disclosure`.
- Stable actor existence does not imply Player disclosure.
- Stable NPCs may act independently; Player foreground wins.
- World Evolution may hold/selectively advance.
- Public d20 grounds mechanics but is not second world truth.
- Save/reopen/Restore currentness is authoritative.
- raw accepted Narrative bytes remain authoritative; UI is projection.
- leaf UI must never receive omniscient `world_state` and filter locally.
- free-form Player natural-language action remains primary.

## 11. Current G6 shell / IA

```text
Player Status Host
→ portrait + real live mechanic/status contributions only
→ may collapse when empty

Narrative Host
→ primary GM Narrative + Player natural-language action
→ optional recommendation guidance near composer

World Information Host
→ grounded player information Surfaces
→ progressively rendered through Internal Dynamic UI Host after Package 6
```

Mother taxonomy:

`概览 / 角色 / 重要经历 / 人物 / 事务 / 行囊 / 系统 / 地图 / 存档`

Current integrated set:

`概览 / 角色 / 重要经历 / 人物 / 存档`

Never create fake HP/location/inventory/faction/quest state for completeness.

## 12. Model-driven information curation authority

Canonical governance decisions:

- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_INITIAL_CHARACTER_CURATION_BASELINE_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`

Frozen rule remains:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

## 13. Internal Dynamic UI Host v0.1 — ROUTE AUTHORIZED CORE

Expected consumer evidence before implementation:

- Character;
- Important Experiences;
- People;
- Open Threads;
- System / Public d20;
- Inventory.

Old MW-013 capability direction is authorized, but old Task Packet is stale and must not be executed as-is.

v0.1 is internal presentation only: typed player-safe projection/contribution, no omniscient local filtering, no arbitrary callbacks/NodePath/OS command/direct authoritative mutation, generic Action Intent deferred, external Source/Expansion Declarative UI deferred to G8.

## 14. V0 Core Closure Gate

After Package 6, Owner reality run must prove one continuous Game across roughly 20–30 turns, including new NPC, OOC, d20, item mutation, Save/reopen, Restore, free-form deviation from recommendations, at least 3 Dynamic UI consumer types, and useful Debug/UAT traces.

Exit only by explicit Owner `V0 Core Game Loop = PRODUCT PASS`.

## 15. Post-closure route

After Core Product PASS:

```text
G7 Context Orchestrator / Structured Output / Knowledge integrity
→ G8 richer surfaces / full player-facing consequence diff / player utility / model ops / Source / Reference / Creator
→ external UI contract only from proven Internal Dynamic UI vocabulary
→ G9 Standalone Alpha
```

Visual Runtime remains deferred until real authored first-party demand. Generic Action Intent remains deferred.
