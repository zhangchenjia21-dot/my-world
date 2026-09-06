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
→ sole default production implementer

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
MW-017 People Identity Bridge               READY FOR CODEX
MW-018 People Curation + Card Surface        BLOCKED BY MW-017
MW-013 Internal Declarative UI Host          HOLD / NOT AUTHORIZED
```

Formal current status:

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

Active Task Packet:

`docs/tasks/MW-017_PEOPLE_IDENTITY_BRIDGE_AND_BARRIER_TASK.md`

## 5. Protected world/runtime invariants

- Accepted free-form Narrative remains primary and is not gated by semantic/Knowledge/Agency/Evolution/curation success.
- `World Truth != actor Knowledge != human-player disclosure`.
- Stable actor existence does not imply Player disclosure.
- Stable NPCs may act independently; Player foreground wins.
- World Evolution may hold/selectively advance.
- Public d20 grounds mechanics but is not second world truth.
- Save/reopen/Restore currentness is authoritative.
- raw accepted Narrative bytes remain authoritative; UI is projection.
- leaf UI must never receive omniscient `world_state` and filter locally.

## 6. Current G6 shell / information architecture

```text
Player Status Host
→ portrait + real live mechanic/status contributions only
→ may collapse when empty

Narrative Host
→ primary GM Narrative + Player natural-language action surface

World Information Host
→ grounded player information Surfaces
```

Mother taxonomy:

`概览 / 角色 / 重要经历 / 人物 / 事务 / 行囊 / 系统 / 地图 / 存档`

Current implemented set:

`概览 / 角色 / 重要经历 / 存档`

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
→ expanded = relationship + identity + traits + latest-known details
→ one card = player's current latest-known snapshot of one stable person
```

`latest-known != omniscient NPC current state`.

Off-screen/private actor changes do not update a card until the Player actually learns them.

People is not:

- all stable actors;
- NPC private state viewer;
- biography/history log;
- numeric Relationship/affinity system.

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
→ future Character + Experiences + People one-call curation
→ information_curation currentness
→ player-safe People L3
→ card UI
```

Protected decisions:

- exact stable `local_character_id`, never authoritative display-name matching;
- same-name ambiguity unresolved rather than guessed;
- request-scoped actor/candidate refs only; model never mints durable ID;
- identity receipt lives in existing `living_world` owner;
- People latest-known snapshot lives in `information_curation`, not NPC truth;
- no People-specific default third model call;
- no raw stable actor/profile/private Knowledge/Agency/Evolution dump to People curation;
- no new SQLite table;
- old MW-014/MW-015 record identity chains remain valid through backward-compatible variants;
- no GM-only opening People processing in v0.1;
- no silent historical People backfill for old Games in v0.1;
- People never reuses the MW-015 Initial Character displaced-future baseline recovery exception.

## 10. CURRENT — MW-017

Task:

`docs/tasks/MW-017_PEOPLE_IDENTITY_BRIDGE_AND_BARRIER_TASK.md`

Product consequence: this is backend-only. It does not add the People tab yet. It makes the next People UI task safe by proving exact person identity and same-Turn ordering.

Required boundaries:

- no People UI/navigation;
- no `people_updates` content contract yet;
- no Relationship system;
- no generic event bus/scheduler;
- no historical backfill/opening support;
- no new SQLite table;
- no unreviewed Owner-build installation.

Highest implementer return: `READY FOR INDEPENDENT REVIEW`.

## 11. MW-018 / MW-013

```text
MW-018 People Curation + Card Surface
→ NOT AUTHORIZED until MW-017 Engineering PASS

MW-013 Internal Declarative UI Host
→ HOLD until repeated grounded consumers prove stable patterns
```

## 12. Owner UAT build handoff

Only product-facing outcomes require Owner-build handoff:

```text
Engineering PASS
→ integrate reviewed main
→ safely sync D:/AI/Projects/my-world
→ verify exact local HEAD
→ run run-game.ps1 -ValidateExportOnly
→ Owner UAT
```

Never install an unreviewed branch into the Owner checkout. Never use reset/clean/force to hide dirty/divergent work.

MW-017 is backend-only, so no Owner UAT build is required after its Engineering PASS; proceed to MW-018 shaping instead.
