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
MW-017 People Identity Bridge               ENGINEERING PASS / INTEGRATED
MW-018 People Curation + Card Surface        READY FOR CODEX
MW-013 Internal Declarative UI Host          HOLD / NOT AUTHORIZED
```

Formal current status:

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

Active Task Packet:

`docs/tasks/MW-018_PEOPLE_CURATION_AND_CARD_SURFACE_TASK.md`

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

Current implemented set before MW-018:

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

Owner explicitly accepts bounded model calls when they materially improve semantic quality and reduce Runtime semantic-rule complexity.

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
→ Character + Experiences + People one-call curation
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

## 10. MW-017 — ENGINEERING PASS / INTEGRATED

Task:

`docs/tasks/MW-017_PEOPLE_IDENTITY_BRIDGE_AND_BARRIER_TASK.md`

Independent Review:

`docs/mw017/MW-017_INDEPENDENT_REVIEW_IR1.md`

Integration verification:

`docs/mw017/MW-017_INTEGRATION_VERIFICATION.md`

Reviewed outcome:

```text
accepted player-authored Turn
→ exact request-scoped person identity binding
→ same-turn runtime actor mint before binding when needed
→ durable current receipt
→ semantic terminal barrier
→ Information Curator release
```

MW-017 is backend-only and requires no Owner product UAT.

## 11. CURRENT — MW-018

Task:

`docs/tasks/MW-018_PEOPLE_CURATION_AND_CARD_SURFACE_TASK.md`

Product target:

```text
right 信息 navigation
→ 概览 | 角色 | 重要经历 | 人物 | 存档

人物
→ card list
→ cards collapsed by default
→ collapsed = compact identity/headline
→ expanded = player-known relationship + latest-known details
→ later learned information updates the same card
→ hidden/off-screen NPC truth never auto-refreshes the card
```

Implementation must:

- reuse the existing Information Curator call; no third People model call;
- consume only MW-017 receipt-derived accepted evidence + prior player-known snapshot for bound people;
- add a backward-compatible curation record/result variant without rewriting old MW-014/MW-015 IDs;
- keep exact local IDs internal and strip them from leaf People DTO;
- make Regenerate/Restore currentness visible immediately through projection;
- keep GM-only opening / old-history backfill / numeric Relationship out of scope;
- avoid MW-013/general declarative UI abstraction.

Highest implementer return: `READY FOR INDEPENDENT REVIEW`.

After GPT Engineering PASS + integration, MW-018 requires canonical Owner-build sync/export and Owner UAT.

## 12. MW-013 HOLD

```text
MW-013 Internal Declarative UI Host
→ HOLD until repeated grounded consumers prove stable patterns
```

Do not pre-abstract People/Character into a generic external/internal renderer in MW-018.

## 13. Owner UAT build handoff

Product-facing outcomes follow:

```text
Engineering PASS
→ integrate reviewed main
→ safely sync D:/AI/Projects/my-world
→ verify exact local HEAD
→ run run-game.ps1 -ValidateExportOnly
→ Owner UAT
```

Never install an unreviewed branch into the Owner checkout. Never use reset/clean/force to hide dirty/divergent work.

`run-game.cmd` / `run-game.ps1` prove export freshness only against the current local checkout; UAT preparation must first prove that checkout equals the intended reviewed main.
