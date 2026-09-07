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

Canonical governance route is `Vibe-Coding/my world/MY_WORLD_总体规划路线图_CURRENT.md@v4.3` and status is `MY_WORLD_CURRENT_STATUS.md@v17.2`.

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G5 World Semantics & GM Runtime             PRODUCT PASS / CLOSED

G6 RPG Core Closure + UAT Observability + Internal Dynamic UI ACTIVE
```

Current integrated G6 facts:

```text
MW-011 RPG Host / Player Profile            PRODUCT PASS / CLOSED
MW-014 Model-driven Information Curation    ENGINEERING PASS / INTEGRATED
MW-015 Character + Important Experiences    PRODUCT PASS / CLOSED
MW-017 People Identity Bridge               ENGINEERING PASS / INTEGRATED
MW-018 People Curation + Card Surface        ENGINEERING PASS / INTEGRATED / OWNER UAT ACTIVE
MW-019 Five Recommended Actions             ENGINEERING PASS / INTEGRATED / OWNER UAT ACTIVE
```

## 5. CURRENT gate and Owner-active UAT

No new independent production task is current until MW-018 + MW-019 Combined Owner UAT is interpreted and any confirmed bounded revision is closed, unless Owner explicitly changes priority.

Owner is continuing the current UAT. Do not interrupt the play session with a dispatch merely because a finding has been captured.

Current route:

```text
Package 0  MW-018 + MW-019 Combined Owner UAT      ← CURRENT
↓
Package 1  UAT Observability / Debug Mode v0.1
↓
Package 2  OOC + Character-guided Recommendations
↓
Package 3  Open Threads
↓
Package 4  System / Public d20 real consumer
↓
Package 5  factual Inventory vertical
↓
Package 6  Internal Dynamic UI Host v0.1
↓
Package 7  V0 Core Closure Reality Gate
```

Package 1 is intentionally pulled forward because it lowers Owner UAT cost across every later Core Package.

## 6. Package 1 UAT Observability / Debug Mode — ROUTE AUTHORIZED NEXT

After Package 0 closes, GPT must re-Task-Shape this as a bounded executable outcome before dispatch.

Target:

```text
Debug Mode OFF
→ normal player experience unchanged

Debug Mode ON
→ per accepted Turn compact UAT trace
→ domain/lane terminal + changed / no-change / failed / stale / cancelled
→ automatic human-readable error reason on abnormal terminal
```

Initial real consumers should include Narrative, World semantic, actor/NPC materialization/identity bridge, Character, Important Experiences, People, Recommendations, Save/Restore/currentness.

Open Threads, mechanics/System and Inventory join the same read-only diagnostic projection when those domains are implemented.

Boundaries:

- default debug view shows whether a domain changed plus terminal state / Turn / Provider / Model / necessary evidence;
- do not expose hidden GM-private / NPC-private semantic values by default, to avoid accidental UAT spoilers;
- player-visible projections may show safe diff;
- Debug Mode is read-only and never changes model input, world truth, mechanics, mutation, currentness or validation strictness;
- no API key / credential / unrelated local privacy;
- no giant EventBus or speculative universal telemetry framework;
- reuse existing domain terminal/currentness evidence wherever possible.

Full polished player-facing `本回合变化` remains later Product Expansion; Package 1 is the UAT/debug slice only.

## 7. Protected world/runtime invariants

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

## 8. Current G6 shell / IA

```text
Player Status Host
→ portrait + real live mechanic/status contributions only
→ may collapse when empty

Narrative Host
→ primary GM Narrative + Player natural-language action
→ optional five-action guidance near composer

World Information Host
→ grounded player information Surfaces
→ progressively rendered through Internal Dynamic UI Host after Package 6
```

Mother taxonomy:

`概览 / 角色 / 重要经历 / 人物 / 事务 / 行囊 / 系统 / 地图 / 存档`

Current integrated set:

`概览 / 角色 / 重要经历 / 人物 / 存档`

Never create fake HP/location/inventory/faction/quest state for completeness.

## 9. Model-driven information curation authority

Canonical governance decisions:

- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_INITIAL_CHARACTER_CURATION_BASELINE_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`

Frozen rule:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

Program must not replicate open semantics using keyword/regex routers, importance scores, event rule trees, relationship state machines, name-matching heuristics or protagonist-choice classifiers.

## 10. People semantics

People remains player-known latest snapshot, card-based and collapsed by default. `latest-known != omniscient NPC current state`. Off-screen/private actor changes do not update a card until Player learns them. Program does not use name/encounter-count/affinity heuristics.

## 11. Five Recommended Actions + active UAT finding

Protected rule:

> **Five recommended actions != five allowed actions.**

Current product contract remains click-prefill-only, editable, free-form-first, ephemeral and player-safe.

Current Owner UAT has already captured a product finding: recommendation chips currently display long full-action prose and feel crowded; Owner prefers concise action-direction labels in the recommendation area, with the detailed editable action draft generated into PlayerInput only after click. Owner also finds the current recommendation/input UI too small/cramped for comfortable reading.

This is a MW-019 revision candidate, not a new independent feature. Owner is still testing; accumulate further findings and shape one bounded correction only when Owner closes this UAT round.

## 12. Internal Dynamic UI Host v0.1 — ROUTE AUTHORIZED CORE

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

Old MW-013 capability direction is authorized, but old Task Packet is stale and must not be executed as-is.

v0.1 is internal presentation only: typed player-safe projection/contribution, no omniscient local filtering, no arbitrary callbacks/NodePath/OS command/direct authoritative mutation, generic Action Intent deferred, external Source/Expansion Declarative UI deferred to G8.

## 13. Core Inventory / mechanics direction

System Surface only consumes real mechanic state. Shell does not invent generic HP/Mana/Hunger/Money.

Inventory must first have authoritative Game-local ownership/mutation semantics; Narrative mention alone cannot mint formal Inventory. First vertical stays minimal and must prove Save/Restore/reopen currentness.

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
