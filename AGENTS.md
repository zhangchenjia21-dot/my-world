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
MW-011 G6 RPG Host ViewModel Baseline       ACTIVE — ZCODE
MW-012 Zhang Chen Player Character Card     OWNER-INSERTED — READY FOR ZCODE
```

Formal G5 closeout:

`docs/g5_gate/G5_GATE_CLOSEOUT.md`

Owner explicitly accepted G5 and authorized G6. The final G5 UAT also established a G6 product requirement: MW-009 side panels are safe and dynamic but too information-thin for the final RPG UI.

MW-012 is a bounded Owner-inserted Character Source integration during G6. It does not reopen G4 and does not replace MW-011 as the G6 mainline.

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

## 4. G6 first vertical

Canonical architecture:

`Vibe-Coding/my world/architecture/ui/G6_RPG_HOST_VIEWMODEL_V0_1_DECISION.md`

Executable packet:

`docs/tasks/MW-011_G6_RPG_HOST_VIEWMODEL_BASELINE_TASK.md`

Identity:

```text
Work Item: MW-011
Name: G6 RPG Host ViewModel Baseline
Capability-Anchor: G6 RPG Experience & Internal Declarative UI Host
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: ACTIVE — ZCODE
Branch: mw-011-g6-rpg-host-viewmodel-baseline
Worktree: D:/AI/Projects/.worktrees/my-world/mw-011
```

G6 starts with the canonical order:

```text
Runtime projection
→ presentation-only ViewModel
→ real RPG UI consumer
```

MW-011 must improve the existing Player Host / World Surface information architecture using real existing safe data. It must not fabricate HP/location/inventory/relationship/faction/quest state just to fill space.

Required first product behavior:

- Player Host: identity/profile + safe World/Entry context + bounded recent accepted Player actions + turn count;
- World Surface default Overview: World/Entry + current Player-known facts + small safe session metadata;
- World Surface `存档`: existing G3 Save controls/semantics behind bounded navigation instead of dominating default overview;
- Restore/reopen/currentness and MW-009 disclosure boundaries remain correct.

## 5. Owner-inserted MW-012 Character Source

Executable packet:

`docs/tasks/MW-012_ZHANG_CHEN_PLAYER_CHARACTER_CARD_TASK.md`

Owner-approved content input:

`docs/tasks/inputs/MW-012_ZHANG_CHEN_CHARACTER_CARD_V0_1.md`

Identity:

```text
Work Item: MW-012
Name: Zhang Chen Player Character Card
Capability-Anchor: G4 Primary Source Assets & Local Game Creation
Inserted-By: Owner during G6
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: OWNER-INSERTED — READY FOR ZCODE
Branch: mw-012-zhang-chen-player-character-card
Worktree: D:/AI/Projects/.worktrees/my-world/mw-012
```

Required result:

```text
Owner-approved 张琛 concept
→ existing Character Card v0.2 contract
→ real first-party Managed Source ingress
→ selectable Player Character for supported Han-end Entries
→ exact Game-local frozen projection/context
```

Protected MW-012 semantics:

- physical body transport into whichever selected Han-end Entry/T0 the Player chooses;
- age 24, no prior local identity/network/history;
- remembered Three Kingdoms history is protagonist memory/belief, not current Game truth, guaranteed future canon, NPC destiny or World Evolution command;
- knowledge of famous figures does not grant automatic visual identification without in-world evidence;
- future meaningful Zhang Chen choices remain Player-owned;
- no new Character schema, inventory system, Creator, UI redesign, mechanic Expansion or declarative UI work;
- do not satisfy the task with a test-only fixture or hardcoded picker entry: use the real product Source ingress that currently makes first-party cards selectable.

MW-011 and MW-012 must use separate worktrees. Do not disturb either task's active work.

## 6. G6 platform discipline

Supporting design:

`Vibe-Coding/my world/architecture/ui/声明式UIHost设计.md`

Do **not** begin G6 by building a universal UI DSL.

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

External World Pack / Mod UI declaration belongs to G8, not G6.

Do not create generic event bus/reactive store/ViewModel platform, arbitrary expression binding, arbitrary GDScript callbacks, or raw Runtime access from declarative definitions.
