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
→ product semantics / architecture / Task Shaping / dispatch / Independent Review / UAT interpretation

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

Canonical governance route is `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.2` and status is `MY_WORLD_CURRENT_STATUS.md@v17.0`.

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G5 World Semantics & GM Runtime             PRODUCT PASS / CLOSED

G6 RPG Core Closure + Internal Dynamic UI   ACTIVE
```

Current integrated G6 facts:

```text
MW-011 RPG Host / Player Profile            PRODUCT PASS / CLOSED
MW-014 Model-driven Information Curation    ENGINEERING PASS / INTEGRATED
MW-015 Character + Important Experiences    PRODUCT PASS / CLOSED
MW-017 People Identity Bridge               ENGINEERING PASS / INTEGRATED
MW-018 People Curation + Card Surface        ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING
MW-019 Five Recommended Actions             ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING
```

## 5. CURRENT gate

No new independent production task is current until MW-018 + MW-019 Combined Owner UAT is interpreted, unless Owner explicitly inserts a new goal.

Current route:

```text
Package 0  MW-018 + MW-019 Combined Owner UAT      ← CURRENT
↓
Package 1  OOC + Character-guided Recommendations
↓
Package 2  Open Threads
↓
Package 3  System / Public d20 real consumer
↓
Package 4  factual Inventory vertical
↓
Package 5  Internal Dynamic UI Host v0.1
↓
Package 6  V0 Core Closure Reality Gate
```

Core Closure first. Creator / Reference / model management / diagnostics / richer information features remain post-closure unless a real blocker requires a minimal seam.

## 6. Protected world/runtime invariants

- Accepted free-form Narrative remains primary and is not gated by semantic/Knowledge/Agency/Evolution/curation/recommendation success.
- `World Truth != actor Knowledge != human-player disclosure`.
- Stable actor existence does not imply Player disclosure.
- Stable NPCs may act independently; Player foreground wins.
- World Evolution may hold/selectively advance.
- Public d20 grounds mechanics but is not second world truth.
- Save/reopen/Restore currentness is authoritative.
- raw accepted Narrative bytes remain authoritative; UI is projection.
- leaf UI must never receive omniscient `world_state` and filter locally.
- free-form Player natural-language action remains primary; recommendations never define the legal action set.

## 7. Current G6 shell / IA

```text
Player Status Host
→ portrait + real live mechanic/status contributions only
→ may collapse when empty

Narrative Host
→ primary GM Narrative + Player natural-language action
→ optional five-action guidance near composer

World Information Host
→ grounded player information Surfaces
→ progressively rendered through Internal Dynamic UI Host after Package 5
```

Mother taxonomy:

`概览 / 角色 / 重要经历 / 人物 / 事务 / 行囊 / 系统 / 地图 / 存档`

Current integrated set:

`概览 / 角色 / 重要经历 / 人物 / 存档`

Never create fake HP/location/inventory/faction/quest state for completeness.

## 8. Model-driven information curation authority

Canonical governance decisions:

- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_INITIAL_CHARACTER_CURATION_BASELINE_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`

Frozen rule:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

Program must not replicate open semantics using keyword/regex routers, importance scores, event rule trees, relationship state machines, name-matching heuristics or protagonist-choice classifiers.

## 9. People semantics

```text
People
→ card-based
→ collapsed by default
→ collapsed = player-known identity + brief latest-known positioning
→ expanded = relationship + latest-known summary/details
→ one card = player's current latest-known snapshot of one stable person
```

`latest-known != omniscient NPC current state`.

Off-screen/private actor changes do not update a card until Player learns them. Program does not use name/encounter-count/affinity heuristics.

## 10. Five Recommended Actions

Protected rule:

> **Five recommended actions != five allowed actions.**

```text
accepted GM Narrative
→ dedicated player-safe Action Recommender
→ exactly five suggestions on valid structured output
→ click PREFILLS PlayerInput only
→ Player edits/ignores freely
→ normal Send / Ctrl+Enter / Public d20 remains authoritative
```

No raw World/stable actor/Source/private Knowledge/Agency/Evolution input. Recommendations are ephemeral, fail-soft and not persisted. No hidden Provider fallback.

## 11. MW-018 / MW-019 Owner UAT

Owner build route:

```text
D:/AI/Projects/my-world
→ inspect local branch/status/worktrees
→ preserve unknown dirty/local work
→ safely fetch + fast-forward main
→ verify exact local HEAD
→ run run-game.ps1 -ValidateExportOnly
→ Owner Launch Ready
```

Never install a task branch as Owner build. Never reset/clean/force to hide divergence.

People defect → MW-018 revision.  
Recommendation defect → MW-019 revision.

## 12. Internal Dynamic UI Host v0.1 — ROUTE AUTHORIZED CORE

Owner explicitly promoted Dynamic UI into the V0 Core Closure path.

Expected consumer evidence before implementation:

- Character;
- Important Experiences;
- People;
- Open Threads;
- System / Public d20;
- Inventory.

Correct order:

```text
multiple real internal consumers
→ repeated component patterns
→ re-Task-Shape Internal Dynamic UI Host v0.1
→ implementation + Independent Review + Owner UAT
→ V0 Core Closure Reality Gate
```

### Old MW-013 packet

```text
MW-013 capability direction = ROUTE AUTHORIZED
old Task Packet             = STALE / DO NOT EXECUTE AS-IS
current execution           = NOT YET — wait for Packages 2–4 consumer evidence
```

Do not dispatch the old packet merely because the capability is now core. Re-shape from current consumers and current architecture first.

### Dynamic UI boundaries

v0.1 is internal presentation only:

- typed player-safe projection / mechanic contribution;
- section/group, field, card/list, collapse/expand, bounded status contribution as proven;
- no omniscient `world_state` filtering at renderer;
- no arbitrary GDScript callbacks;
- no NodePath execution;
- no OS/filesystem command;
- no direct authoritative mutation;
- generic Action Intent remains deferred;
- external Source/Expansion Declarative UI remains deferred to G8.

## 13. Core Inventory / mechanics direction

System Surface only consumes real mechanic state. Shell does not invent generic HP/Mana/Hunger/Money.

Inventory must first have authoritative Game-local ownership/mutation semantics; Narrative mention alone cannot mint formal Inventory. First vertical stays minimal and must prove Save/Restore/reopen currentness.

## 14. V0 Core Closure Gate

After Package 5, Owner reality run must prove one continuous Game across roughly 20–30 turns, including new NPC, OOC, d20, item mutation, Save/reopen, Restore, free-form deviation from recommendations, and at least 3 Dynamic UI consumer types.

Exit only by explicit Owner `V0 Core Game Loop = PRODUCT PASS`.

## 15. Post-closure route

After Core Product PASS:

```text
G7 Context Orchestrator / Structured Output / Knowledge integrity
→ G8 richer surfaces / player utility / model ops / Source / Reference / Creator
→ external UI contract only from proven Internal Dynamic UI vocabulary
→ G9 Standalone Alpha
```

Visual Runtime remains deferred until real authored first-party demand. Generic Action Intent remains deferred.
