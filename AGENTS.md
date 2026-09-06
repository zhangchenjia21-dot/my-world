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
MW-018 People Curation + Card Surface        ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING
Five Recommended Actions semantics          FROZEN
MW-019 Five Recommended Actions             ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING
MW-013 Internal Declarative UI Host          HOLD / NOT AUTHORIZED
```

Formal current status:

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

Current combined UAT evidence:

- `docs/mw018/MW-018_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw018/MW-018_INTEGRATION_VERIFICATION.md`
- `docs/mw019/MW-019_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw019/MW-019_INTEGRATION_VERIFICATION.md`

No new product implementation task is authorized until the combined MW-018 + MW-019 Owner UAT is interpreted, unless Owner explicitly inserts a new independent goal.

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
→ optional five-action guidance near composer

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

## 11. MW-018 — ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING

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

Retained Owner-UAT risk: real new-actor identity correlation may occasionally be omitted by the model. Exact bridge must continue to refuse guessing rather than add display-name matching.

No Product PASS exists until Owner accepts the real application.

## 12. Five Recommended Actions — FROZEN

Canonical:

`Vibe-Coding/my world/architecture/ui/G6_FIVE_RECOMMENDED_ACTIONS_V1_0_DECISION.md`

Protected product rule:

> **Five recommended actions != five allowed actions.**

Approved behavior:

```text
accepted GM Narrative
→ dedicated player-safe Action Recommender
→ exactly five model-generated suggestions on valid structured output
→ recommendation click PREFILLS PlayerInput only
→ Player may edit or ignore
→ normal Send / Ctrl+Enter / Public d20 remains authoritative
```

Protected boundaries:

- free-form input always available;
- click never auto-sends;
- recommender consumes only bounded player-visible accepted Conversation material;
- no raw World/stable actor/Source/private Knowledge/Agency/Evolution input;
- recommendations are ephemeral and not persisted;
- accepted GM-only opening receives recommendations;
- foreground action wins and clears/cancels stale recommendation work;
- Restore/reopen may issue one fresh current-prefix request;
- failure is fail-soft;
- no hidden Provider fallback;
- no generic Action Intent or MW-013 infrastructure is authorized by this feature.

## 13. MW-019 — ENGINEERING PASS / INTEGRATED / OWNER UAT PENDING

Task:

`docs/tasks/MW-019_FIVE_RECOMMENDED_ACTIONS_TASK.md`

Reviewed implementation:

`bf9996e67d267871e918f82bd9ad6d2fb539ff0b`

Reviewed candidate + evidence:

`5a06f636e332c600d9a5bb327a92792ec7c42c17`

Independent Review:

`docs/mw019/MW-019_INDEPENDENT_REVIEW_IR1.md`

Integration verification:

`docs/mw019/MW-019_INTEGRATION_VERIFICATION.md`

Engineering evidence includes 122 focused checks / 0 failures, 26 regression/export suites with exit code 0, Windows Desktop export PASS and bounded real configured Kimi K3 validation.

Retained Product/UAT risk:

- one of two real Kimi recommendation calls returned Markdown-fenced JSON and was intentionally rejected by the strict contract;
- do not add heuristic fence stripping, hidden retry or Provider fallback merely to manufacture success;
- if normal Owner play frequently shows unavailable recommendations, keep the correction in MW-019 lineage and address the structured-output/model seam deliberately.

No Product PASS exists until Owner accepts the real application.

## 14. SillyTavern functional reference — NON-CANONICAL

Owner-requested upstream feature study is preserved in governance at:

`Vibe-Coding/my world/experience/SILLYTAVERN_UPSTREAM_FUNCTIONAL_REFERENCE_AUDIT_2026-09-06.md`

It is reference evidence for future improvement only. It does not authorize current implementation, replace this repository's architecture or reopen closed tasks by itself.

## 15. MW-013 / generic Action Intent remain deferred

MW-019 is one fixed first-party `prefill composer` consumer. It does not authorize generic Action Intent schema/dispatcher.

```text
MW-013 Internal Declarative UI Host
→ HOLD

generic bounded Action Intent
→ later, after proven consumers
```

Do not introduce arbitrary callbacks, NodePath execution, generic command bus or external declarative action definitions.

## 16. CURRENT — combined Owner UAT build handoff

The Owner's canonical playable checkout is:

`D:/AI/Projects/my-world`

Required route:

```text
inspect local branch/status/worktrees
→ preserve unknown dirty/local work
→ safely fetch + fast-forward main to exact current origin/main
→ verify exact local HEAD
→ run run-game.ps1 -ValidateExportOnly
→ Owner Launch Ready
→ combined Owner UAT MW-018 + MW-019
```

Never install a task branch as the Owner build. Never use reset/clean/force to hide divergence.

`run-game.cmd` / `run-game.ps1` prove export freshness only against the current local checkout; UAT preparation must first prove that checkout equals the intended reviewed main.

## 17. Combined Owner UAT target

### MW-018 People

```text
人物 tab exists
→ useful card appears/updates after normal player-authored turns involving people
→ card starts collapsed
→ collapsed state is quick to scan
→ expansion reveals relationship / latest-known details
→ no obvious private/omniscient/debug information
→ later learned information updates the same card
```

Prefer testing one known person and one newly introduced person.

### MW-019 Recommendations

```text
accepted opening / completed GM turn
→ five recommendations appear reasonably quickly when generation succeeds
→ suggestions are useful without feeling mandatory
→ no obvious hidden/omniscient information
→ click fills composer but does not send
→ text remains freely editable
→ manual free-form action remains effortless
→ next action / Regenerate / Restore never leaves stale suggestions
```

Combined UAT keeps separate defect lineage:

- People defect → MW-018 revision;
- recommendation defect → MW-019 revision.

Do not continue to the next independent product task until Owner verdicts are interpreted, unless Owner explicitly changes priority.
