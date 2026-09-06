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

MW-011 Revision 3 has completed its Zcode integration/closeout. Subsequent new implementation tasks use the Codex/KimiCode routing above; do not default new work back to Zcode unless the Owner explicitly changes routing again.

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
MW-011 R1 G6 RPG Host ViewModel Baseline    ENGINEERING PASS / INTEGRATED
MW-011 R1 Owner UI UAT                      NOT PASS — Player Host too thin
MW-011 R2 Player Profile Surface            IR#2 NOT PASS
MW-011 R3 Player Profile Surface            ENGINEERING PASS / INTEGRATED — OWNER UI UAT
MW-012 Zhang Chen Player Character Card     ENGINEERING PASS / INTEGRATED
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

## 4. MW-011 lineage

### Revision 1

R1 Engineering review:

`docs/mw011/MW-011_INDEPENDENT_REVIEW_IR1.md`

Integrated R1 main commit:

`7972ab74ccc1d5368f8ca32d4fd4fd83173aa04d`

R1 Owner UI UAT later found the Player Host still too information-thin despite rich Character content reaching GM Narrative.

### Revision 2 / Revision 3 architecture

Canonical architecture:

`Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`

R2 task:

`docs/tasks/MW-011_REVISION2_PLAYER_CHARACTER_PROFILE_SURFACE_ADDENDUM.md`

R2 review:

`docs/mw011/MW-011_INDEPENDENT_REVIEW_IR2.md`

R3 correction task:

`docs/tasks/MW-011_REVISION3_COMMITTED_PROFILE_SOURCE_AND_REPRODUCIBLE_EVIDENCE_ADDENDUM.md`

R3 formal review:

`docs/mw011/MW-011_INDEPENDENT_REVIEW_IR3.md`

R3 integration verification:

`docs/mw011/MW-011_R3_INTEGRATION_VERIFICATION.md`

Current verdict:

**MW-011 Revision 3 / IR#3 = ENGINEERING PASS — INTEGRATED / OWNER UI UAT.**

Reviewed branch head:

`78bd5ce26b5ec8a465a9f5d6fbcdb536925d5fc0`

Production/content test HEAD:

`16c42d576b28c6119c26ff310b426d0caec202ce`

Integration commit:

`12eedba6a6da47d351d33fb544efbdaa188c85b8`

The integration merge has the reviewed branch head as a direct parent. Comparison from the reviewed head to integrated main shows only governance/review documents after the reviewed outcome; no production/content bytes were rewritten.

## 5. Player Character Profile contract

Accepted G6 profile data flow:

```text
optional Character Card v0.2 player_profile
→ existing selected Character projection
→ Final Create freezes profile into Game-local source_projection
→ separate fail-closed Player Character Profile Projection
→ MW-011 presentation-only ViewModel
→ rich bounded Player Host
```

`player_profile` is authored presentation material, not gameplay/world authority.

Conceptual shape:

```text
headline: String
summary: String
groups[]:
  group_id: safe token
  title: String
  items: Array[String]
```

Protect these boundaries:

- existing Character Card v0.2 without the field remains valid;
- old Games do not backfill from Source current;
- projector reads only frozen Game-local `player_profile` and fails closed;
- no raw `semantic_sections`, `gm_reference`, `gm_private`, `catalog_summary`, internal IDs/hashes/fingerprints or Source-current fallback reaches Player UI;
- MW-009 remains owner of current Player-known facts;
- ViewModel remains presentation-only;
- Player Host scrolls vertically; Narrative remains primary;
- no generic UI DSL, stat ontology, Inventory mechanics, Mod schema, Provider summarization or persistence table.

## 6. Zhang Chen current generation

Protected MW-012 semantics remain in force. The accepted R3 profile generation is:

```text
asset_id: character.han_end.zhang_chen
schema: character_card.v0.2
version: 0.1.1
generation fingerprint:
0b6cb72af535ef6147f71cb7592fe6ba048626dd997acf54c4e6893c848b59e4
```

Visible authored groups, in order:

```text
背景
性格
能力
局限
初始目标
行为原则
随身物品
```

Do not add powers, equipment, local relationships, guaranteed future history, automatic famous-person recognition or preselect later allegiance/self-rule choices.

The Owner's older Zhang Chen `0.1.0` Game remains profile-empty by design. Final UAT must use a **fresh 0.1.1 Game**.

## 7. G6 platform discipline

Supporting design:

`Vibe-Coding/my world/architecture/ui/声明式UIHost设计.md`

Canonical order remains consumer-first:

```text
Runtime projection
→ presentation-only ViewModel
→ real UI consumer
→ Runtime Asset Resolution only for actual visual consumers
→ portrait / scene / authored-map presentation
→ Character / Relationship / Inventory / Faction / Map / Save real surfaces
→ Expansion mechanic-state consumer
→ Internal Declarative UI Host v0.1
→ bounded Action Intent
→ responsive / Theme / navigation
→ Owner UAT / visual polish
```

Do not manufacture a generic platform before real consumers establish the need. External World Pack / Mod UI declaration remains G8.

## 8. Immediate route

```text
Owner creates a fresh Zhang Chen 0.1.1 Game
→ Owner UI UAT on rich Player Host
→ GPT records product verdict
→ if PASS, close MW-011 product outcome
→ shape next real G6 consumer / visual vertical
→ assign that new task to Codex or KimiCode under current Owner routing
```
