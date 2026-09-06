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

Long-term routing:

```text
GPT        → semantics / architecture / task shaping / Independent Review
Codex      → backend / mechanism implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

Owner weekend override remains active through **2026-09-06 23:59 (+08:00)**:

```text
Zcode + GLM-5.3-flash → primary implementation owner for NEW code-changing tasks
GPT                    → semantics / architecture / task shaping / Independent Review
```

At **2026-09-07 00:00 (+08:00)**, absent a new Owner instruction, long-term routing resumes automatically. Gemini review remains CANCELLED / DO NOT EXECUTE.

## 1A. Task identity

Use `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

```text
Capability Anchor != executable Work ID != revision/review lineage
```

New independent work uses flat immutable `MW-xxx`. Same-outcome defects stay the same Work ID with Revision + Review-Round increments.

## 1B. Worktree hygiene

All task worktrees:

`D:/AI/Projects/.worktrees/my-world/<task-or-revision>`

Before creating/removing worktrees inspect `git worktree list --porcelain`. Remove only closed/reviewed + clean + pushed/reachable/integrated + no unknown user work. Registered worktrees are removed only with `git worktree remove`, followed by `git worktree prune`.

Keep the active task worktree through GPT Independent Review.

## 2. Current phase

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G5 World Semantics & GM Runtime             PRODUCT PASS / CLOSED
G5-GATE                                     PRODUCT PASS

G6 RPG Experience & Internal Declarative UI Host ACTIVE
MW-011 R1 G6 RPG Host ViewModel Baseline    ENGINEERING PASS / INTEGRATED; OWNER UI UAT NOT PASS
MW-011 Revision 2 Player Profile Surface    ACTIVE — ZCODE
MW-012 Zhang Chen Player Character Card     ENGINEERING PASS / INTEGRATED; CARD CONTENT INGRESS CONFIRMED
```

Formal current status:

`Vibe-Coding/my world/MY_WORLD_CURRENT_STATUS.md`

## 3. Closed G5 results that remain protected

```text
G5-01 World Turn / Semantic Materialization           PASS / CLOSED
G5-02 Knowledge Provenance                            PASS / CLOSED
G5-03 NPC / Faction Agency                            ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization        PASS / CLOSED
G5-04 Event / Priority Evolution                      PRODUCT PASS / CLOSED
MW-002 Selective World Evolution Evaluator            ENGINEERING PASS / CLOSED
MW-003 Visual Comfort Theme Pass                      PRODUCT PASS / CLOSED
MW-004 Minimal Player Agency Principle                PRODUCT PASS / CLOSED
MW-005 Three Kingdoms Literary Style Primer R4        PRODUCT PASS / CLOSED
G5-05 Meaningful Choice / Mechanics Integration       PRODUCT PASS / CLOSED
MW-006 Mechanics-Grounded World Consequence Vertical ENGINEERING PASS / CLOSED
MW-007 Mechanics Consequence Timeline Continuity      ENGINEERING PASS / CLOSED
MW-008 Safe Markdown-Lite Narrative Rendering         PRODUCT PASS / CLOSED
G5-06 Runtime → UI Projection                         ENGINEERING PASS / CLOSED
MW-009 Player-Safe Runtime Side Panels                ENGINEERING PASS / CLOSED
G5-07 World Product Tests                             PRODUCT PASS / CLOSED
MW-010 Living-World Integrated Reality Matrix R2      ENGINEERING PASS / CLOSED
```

### Core world/runtime invariants

- Accepted free-form Narrative remains primary and is not gated by semantic/knowledge/agency/evolution extraction success.
- Runtime makes established world consequences durable without creating a universal simulator.
- World Truth != actor Knowledge != human-player disclosure.
- Stable NPCs may act independently; Player foreground wins.
- World Evolution may `hold` or advance selectively; Player turns are scheduling opportunities, not universal causes.
- Program-owned Public d20 results ground normal G5-01 semantic opportunities; accepted Narrative remains the concrete scene consequence source.
- Save/reopen/Restore currentness remains authoritative.

### MW-008 presentation invariant

Raw GM Narrative remains authoritative in Conversation/persistence/context. Markdown-lite is disposable UI projection only. v0.1 whitelist: `**text**`, `*text*`, standalone `---`.

### MW-009 disclosure invariant

```text
Runtime truth
!= GM-visible truth
!= actor-private knowledge
!= human-player-safe UI projection
```

Do not pass omniscient `world_state` into leaf UI and then filter it there.

### MW-005 style invariant

Literary Style Reference is expression-only. It is not Game truth, future canon, Player/actor Knowledge, semantic consequence authority, World Evolution input, mechanics-control authority, or mandatory output protocol.

## 4. MW-011 Revision 1 disposition

Canonical R1 architecture:

`Vibe-Coding/my world/architecture/ui/G6_RPG_HOST_VIEWMODEL_V0_1_DECISION.md`

R1 task:

`docs/tasks/MW-011_G6_RPG_HOST_VIEWMODEL_BASELINE_TASK.md`

R1 review:

`docs/mw011/MW-011_INDEPENDENT_REVIEW_IR1.md`

Post-review rebase verification:

`docs/mw011/MW-011_POST_IR1_REBASE_VERIFICATION.md`

Integrated R1 main commit:

`7972ab74ccc1d5368f8ca32d4fd4fd83173aa04d`

R1 Engineering remains PASS. Owner UI UAT on 2026-09-06 found the fresh Player Host still materially too thin because rich Character Card content has no explicit player-facing projection.

Formal UAT result:

`docs/mw011/MW-011_OWNER_UAT_R1_RESULT.md`

This is a same-outcome defect, therefore **MW-011 Revision 2**.

## 5. ACTIVE — MW-011 Revision 2

Canonical R2 architecture:

`Vibe-Coding/my world/architecture/ui/G6_PLAYER_CHARACTER_PROFILE_PROJECTION_V0_1_DECISION.md`

Executable R2 addendum:

`docs/tasks/MW-011_REVISION2_PLAYER_CHARACTER_PROFILE_SURFACE_ADDENDUM.md`

Identity:

```text
Work Item: MW-011
Revision: 2
Review-Round: IR#1 → IR#2
Name: Player Character Profile Projection + Player Host Surface
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Branch: mw-011-r2-player-character-profile-surface
Worktree: D:/AI/Projects/.worktrees/my-world/mw-011-r2
Status: ACTIVE — ZCODE
Return ceiling: READY FOR INDEPENDENT REVIEW
```

Required data flow:

```text
optional Character Card v0.2 player_profile
→ existing selected Character projection / Final Create freeze
→ Game-local frozen player_profile
→ new fail-closed Player Character Profile Projection
→ existing MW-011 presentation-only ViewModel
→ richer Player Host
```

### R2 player-profile contract

`player_profile` is optional and presentation-only:

```text
headline: String
summary: String
groups[]:
  group_id: safe token
  title: String
  items: Array[String]
```

Existing Character Card v0.2 without the field remains valid.

Do not expose raw `semantic_sections`, `gm_reference`, `gm_private`, instructions, IDs/hashes/fingerprints or omniscient Runtime state. Do not look up latest Source Library bytes to enrich an existing Game. Old Games remain on their frozen Character generation.

MW-009 stays the owner of current Player-known facts and must not be broadened to parse raw Character Source prose.

### Zhang Chen R2 presentation update

MW-012 Character semantics remain protected. R2 may add a faithful structured `player_profile` to a new Zhang Chen Source generation for future Games, normally bumping package version from `0.1.0` to `0.1.1`.

Required visible groups:

```text
背景
性格
能力
局限
初始目标
行为原则
随身物品
```

No new powers, equipment, local relationships, guaranteed history, automatic famous-person recognition or semantic changes.

## 6. MW-012 remains integrated / protected

Task:

`docs/tasks/MW-012_ZHANG_CHEN_PLAYER_CHARACTER_CARD_TASK.md`

Formal R2 review:

`docs/mw012/MW-012_INDEPENDENT_REVIEW_IR2.md`

Integrated main commit:

`6338af5665c5137d9a9528776e77a13ffb924ea6`

Protected semantics:

- physical body transport into the selected Han-end T0;
- age 24, no prior local identity/network/history;
- remembered Three Kingdoms history is protagonist memory/belief, not current Game truth or guaranteed future canon;
- knowing famous names does not grant automatic visual identification;
- future allegiance/self-rule/return/reveal decisions remain Player-owned;
- literacy limitation is written-script only; no invented spoken-language incapacity;
- starting possessions remain finite and exactly bounded by the Owner-approved card.

Do not reopen MW-012 simply because MW-011 needs a richer human-player presentation projection.

## 7. G6 platform discipline

Supporting design:

`Vibe-Coding/my world/architecture/ui/声明式UIHost设计.md`

Canonical order is consumer-first:

```text
real safe projection / ViewModel / consumer
→ real visual consumer needs
→ Runtime Asset Resolution where actually required
→ richer Character / Relationship / Inventory / Faction / Map / Save surfaces
→ Expansion mechanic state consumer
→ Internal Declarative UI Host v0.1
→ bounded Action Intent
→ responsive/navigation/polish
```

MW-011 R2 is a bounded real-consumer correction. Do not turn it into a universal Character ontology, generic event bus/reactive store/ViewModel platform, arbitrary UI DSL, Mod schema, Creator, portrait pipeline, Inventory mechanics or Provider summarization.

External World Pack / Mod UI declaration belongs to G8, not G6.
