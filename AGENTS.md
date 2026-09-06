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
→ product semantics / architecture / Task Shaping / dispatch / Independent Review

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

Inspect `git worktree list --porcelain` before create/remove. Never destroy unknown work. Keep an active worktree through GPT Independent Review and integration verification.

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
MW-014 Model-driven Information Curation    ENGINEERING PASS / INTEGRATED
MW-015 Character + Important Experiences    PRODUCT PASS / CLOSED
People Surface product semantics            FROZEN
MW-016 People Architecture Audit            PASS / CLOSED
People identity + curation architecture     FROZEN
MW-017 People Identity Bridge               ENGINEERING PASS / INTEGRATED
MW-018 People Curation + Card Surface        ENGINEERING PASS / INTEGRATED / OWNER UAT DEFERRED
Five Recommended Actions semantics          FROZEN
MW-019 Five Recommended Actions             READY FOR CODEX
MW-013 Internal Declarative UI Host          HOLD / NOT AUTHORIZED
```

Formal current status:

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

Active Task Packet:

`docs/tasks/MW-019_FIVE_RECOMMENDED_ACTIONS_TASK.md`

Current MW-018 review evidence remains:

- `docs/mw018/MW-018_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw018/MW-018_INTEGRATION_VERIFICATION.md`

## 5. Protected world/runtime invariants

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

## 6. Current G6 shell / information architecture

```text
Player Status Host
→ portrait + real live mechanic/status contributions only
→ may collapse when empty

Narrative Host
→ primary GM Narrative + Player natural-language action surface
→ fixed first-party recommended-action guidance may live near composer

World Information Host
→ grounded player information Surfaces
```

Mother taxonomy:

`概览 / 角色 / 重要经历 / 人物 / 事务 / 行囊 / 系统 / 地图 / 存档`

Current integrated set:

`概览 / 角色 / 重要经历 / 人物 / 存档`

Never create fake HP/location/inventory/faction/quest state for completeness.

## 7. Model-driven information curation authority

Canonical:

- `Vibe-Coding/my world/architecture/ui/G6_MODEL_DRIVEN_INFORMATION_CURATION_AUTHORITY_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_CHARACTER_AND_IMPORTANT_EXPERIENCES_V1_0_DECISION.md`
- `Vibe-Coding/my world/architecture/ui/G6_INITIAL_CHARACTER_CURATION_BASELINE_V1_0_DECISION.md`

Frozen rule:

> **Model owns semantic interpretation and curation; Program owns normalized storage, temporal integrity and presentation.**

Program must not replicate open semantics using keyword/regex routers, importance scores, per-event rule trees, relationship state machines, name-matching heuristics or protagonist-choice classifiers.

Program owns machine structure/currentness: IDs, versions, bounded payloads, atomic persistence, idempotence, Save/Restore/Regenerate, stale-future isolation and player-safe projection.

## 8. People Surface product semantics

Canonical:

`Vibe-Coding/my world/architecture/ui/G6_PEOPLE_SURFACE_V1_0_DECISION.md`

```text
People
→ card-based
→ collapsed by default
→ collapsed = player-known identity + brief latest-known positioning
→ expanded = relationship + latest-known summary/details
→ one card = player's current latest-known snapshot of one stable person
```

`latest-known != omniscient NPC current state`.

Off-screen/private actor changes do not update a card until the Player actually learns them.

Model decides card eligibility/content/update/removal. Program does not use name/encounter-count/affinity heuristics.

## 9. People identity + curation architecture

Canonical:

`Vibe-Coding/my world/architecture/ui/G6_PEOPLE_IDENTITY_AND_CURATION_V1_0_DECISION.md`

Approved vertical:

```text
accepted player-authored Turn
→ World semantic lane
→ stable actor materialization + exact identity receipt
→ same-Turn current-version terminal barrier
→ existing Information Curator
→ Character + Experiences + People one-call curation
→ information_curation currentness
→ player-safe People L3
→ card UI
```

Protected decisions include exact stable identity, no authoritative name matching, no People-specific third call, no raw actor/private material, backward-compatible curation history and no People opening/backfill in v0.1.

## 10. MW-017 — ENGINEERING PASS / INTEGRATED

Task:

`docs/tasks/MW-017_PEOPLE_IDENTITY_BRIDGE_AND_BARRIER_TASK.md`

Independent Review:

`docs/mw017/MW-017_INDEPENDENT_REVIEW_IR1.md`

Integration verification:

`docs/mw017/MW-017_INTEGRATION_VERIFICATION.md`

MW-017 is backend-only and requires no Owner product UAT.

## 11. MW-018 — ENGINEERING PASS / INTEGRATED / OWNER UAT DEFERRED

Task:

`docs/tasks/MW-018_PEOPLE_CURATION_AND_CARD_SURFACE_TASK.md`

Independent Review:

`docs/mw018/MW-018_INDEPENDENT_REVIEW_IR1.md`

Integration verification:

`docs/mw018/MW-018_INTEGRATION_VERIFICATION.md`

Integrated People outcome:

```text
right 信息 navigation
→ 概览 | 角色 | 重要经历 | 人物 | 存档

人物
→ safe latest-known card list
→ cards default collapsed
→ expand shows relationship / summary / details
→ accepted replacement / Restore / reopen follow current accepted history
→ hidden/off-screen NPC truth cannot auto-refresh cards
```

Owner explicitly deferred standalone MW-018 UAT. Do not mark Product PASS. After MW-019 integration, prepare one fresh Owner build and run combined UAT.

Retained People UAT risk: real new-actor identity correlation may occasionally be omitted by the model; exact bridge must continue to refuse guessing rather than add display-name matching.

## 12. Five Recommended Actions — FROZEN

Canonical:

`Vibe-Coding/my world/architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_V1_0_DECISION.md`

Protected product rule:

> **Five recommended actions != five allowed actions.**

Target:

```text
accepted GM Narrative
→ dedicated player-safe background Action Recommender
→ exactly five model-generated recommendations
→ click recommendation
→ PREFILL existing PlayerInput only
→ player may edit/ignore
→ normal Send / Ctrl+Enter / Public d20 path remains authoritative
```

Important boundaries:

- free-form input always available;
- recommendation click never auto-sends;
- recommendations use only bounded player-visible accepted Conversation history;
- no raw World/stable actor/Source/private Knowledge/Agency/Evolution input;
- recommendations are ephemeral derived UI and are not persisted;
- accepted GM-only opening gets recommendations;
- foreground action always wins and clears/cancels stale recommendation work;
- Restore/reopen may issue one fresh current-prefix recommendation call;
- failures are fail-soft and never block gameplay;
- no hidden Provider switch;
- no generic Action Intent/MW-013 infrastructure in this task.

## 13. CURRENT — MW-019 Five Recommended Actions

Task:

`docs/tasks/MW-019_FIVE_RECOMMENDED_ACTIONS_TASK.md`

Product target:

```text
GM Narrative accepted
→ five useful recommendation buttons appear near composer
→ player can ignore them and type freely
→ click fills PlayerInput without submitting
→ player edits freely
→ Send follows existing action/adjudication path
```

Implementation must use a dedicated bounded recommendation call, independent from the authoritative Narrative response and from omniscient semantic/curation inputs.

Highest implementer return:

`READY FOR INDEPENDENT REVIEW`

Do not install unreviewed MW-019 into Owner canonical checkout.

## 14. Generic G6-G / MW-013 remain deferred

MW-019 is one fixed first-party `prefill composer` consumer. It does not authorize generic Action Intent schema/dispatcher.

```text
MW-013 Internal Declarative UI Host
→ HOLD

generic bounded Action Intent
→ later, after proven consumers
```

Do not introduce arbitrary callbacks, NodePath execution, generic command bus or external declarative action definitions.

## 15. Combined Owner UAT after MW-019

Required route:

```text
MW-019 candidate
→ GPT Independent Review
→ Engineering PASS
→ integrate reviewed main
→ safely sync D:/AI/Projects/my-world
→ ValidateExportOnly
→ combined Owner UAT: MW-018 + MW-019
```

Combined UAT keeps separate defect lineage:

- People defect → MW-018 revision;
- recommendation defect → MW-019 revision.

Owner must confirm that recommendations reduce blank-composer friction without making the game feel like a forced branching-choice system.
