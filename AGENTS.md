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

Repository remotes: `github.com/zhangchenjia21-dot/my-world` and `github.com/zhangchenjia21-dot/Vibe-Coding`.

Long-term routing:

```text
GPT        → meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

Owner weekend routing override through **2026-09-06 23:59 (+08:00)**:

```text
Zcode + GLM-5.3-flash
→ primary implementation owner for NEW code-changing tasks issued during the override

GPT
→ remains semantic / architecture / task-shaping / Independent Review owner
```

Do not invent low-value work merely to consume quota. Stage Gates, Task Packets, scope boundaries and implementer/reviewer separation remain unchanged. At **2026-09-07 00:00 (+08:00)**, absent a new Owner instruction, long-term routing resumes automatically.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 1A. Worktree hygiene — Owner rule

Task worktrees must not be scattered directly under `D:/AI/Projects`.

Required location for all new my-world task worktrees:

```text
D:/AI/Projects/.worktrees/my-world/<task-or-revision>
```

Before creating a new task worktree, inspect registered worktrees with `git worktree list --porcelain`. A completed worktree may be removed only after confirming it is clean, unique commits are pushed/reachable or integrated, its task is closed/reviewed, and it contains no unknown user work. Use `git worktree remove`; never manually delete a registered worktree directory. Run `git worktree prune` after safe removals.

Keep the active task worktree through Independent Review unless GPT/Owner explicitly authorizes cleanup.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization PASS / CLOSED
G5-04 Event / Priority Evolution            PRODUCT PASS / CLOSED
MW-002 Selective World Evolution Evaluator ENGINEERING PASS / CLOSED
MW-003 Visual Comfort Theme Pass            ENGINEERING PASS — OWNER UAT
MW-004 Minimal Player Agency Principle      IMPLEMENTED — OWNER UAT
MW-005 Three Kingdoms Literary Style Primer ENGINEERING PASS — OWNER FOLLOW-UP POLISH/UAT DEFERRED
G5-05 Meaningful Choice / Mechanics Integration ENGINEERING COMPLETE — OWNER UAT DEFERRED / PROGRESSION AUTHORIZED
MW-006 Mechanics-Grounded World Consequence Vertical ENGINEERING PASS / CLOSED
MW-007 Mechanics Consequence Timeline Continuity ENGINEERING PASS / CLOSED
MW-008 Safe Markdown-Lite Narrative Rendering ENGINEERING PASS / CLOSED
G5-06 Runtime → UI Projection               ENGINEERING PASS / CLOSED
MW-009 Player-Safe Runtime Side Panels      ENGINEERING PASS / CLOSED
G5-07 World Product Tests                   ACTIVE
MW-010 G5 Living-World Integrated Reality Matrix ACTIVE — ZCODE
G5-GATE                                     NOT YET
```

Owner explicitly directed the project back onto the G5 mainline and deferred remaining product-feel checks into one later combined UAT.

Current active executable packet:

- `docs/tasks/MW-010_G5_LIVING_WORLD_INTEGRATED_REALITY_MATRIX_TASK.md`

Current G5-07 architecture:

- `Vibe-Coding/my world/architecture/world/G5_WORLD_PRODUCT_TEST_MATRIX_V0_1_DECISION.md`

Recent closeout/reviews:

- `docs/mw009/MW-009_INDEPENDENT_REVIEW_IR1.md`
- `docs/g5_06/G5-06_CLOSEOUT.md`
- `docs/mw008/MW-008_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw007/MW-007_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR3.md`

## 3. Current Work Item identities

### MW-005

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Current engineering baseline: Revision 3 / IR#3
Revision-3 implementation SHA: a52236c5ec55bf07a727b4e07c4ef63572b18555
Status: ENGINEERING PASS — OWNER FOLLOW-UP POLISH/UAT DEFERRED
```

Protected result: Style reference is expression-only, never Game truth, future canon, Player/actor Knowledge, World Evolution causality, mechanics-control authority or semantic-consequence authority. Current Source generation remains immutable `58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443` until an explicit future Revision changes content.

Owner has requested one **bounded additional style-weight polish** before the later combined G5 product test. It is queued separately and must not contaminate MW-010. Do not create another style platform, output gate or mandatory pseudo-classical format.

### G5-05 / MW-006 / MW-007

```text
MW-006 = ENGINEERING PASS / CLOSED
MW-007 = ENGINEERING PASS / CLOSED
G5-05  = ENGINEERING COMPLETE — OWNER UAT DEFERRED / PROGRESSION AUTHORIZED
```

Protected mechanics semantics:

```text
Program-owned Public d20 result
→ bounded grounding in normal G5-01 semantic opportunity
→ accepted free-form Narrative remains concrete consequence source
→ durable world consequence
→ Save / close / reopen / Continue / Restore coherent
```

Do not introduce a second mechanics truth, fixed outcome→effect table, reroll redesign, fake NO_CHECK mechanics, Narrative gate/retry, new SQLite mechanics schema, raw-mechanics injection into G5-04 or actor-knowledge shortcuts.

### MW-008

```text
Work Item: MW-008
Name: Safe Markdown-Lite Narrative Rendering
Implementation SHA: 9f90e634d6d0302e9905f131410f7a33611e8d41
Review-Round: IR#1
Status: ENGINEERING PASS / CLOSED
```

Protected presentation semantics: raw GM Narrative remains authoritative in Conversation/persistence/context; Markdown-lite is disposable UI projection only. Whitelist v0.1: `**text**`, `*text*`, standalone `---`.

### MW-009 / G5-06

```text
Work Item: MW-009
Name: Player-Safe Runtime Side Panels
Capability-Anchor: G5-06 Runtime → UI Projection
Implementation/Evidence SHA: c2805e816d8bcda73b7bc662a2fe091e55daf0af
Review-Round: IR#1
Status: ENGINEERING PASS / CLOSED

G5-06 = ENGINEERING PASS / CLOSED
```

Protected projection rule:

```text
Runtime truth
!= GM-visible truth
!= actor-private knowledge
!= human-player-safe UI projection
```

The player-safe projection exposes only safe Player identity, safe World/Entry identity and bounded current Player Character Knowledge facts. Hidden NPC Knowledge, raw consequences, Agency, World Evolution, GM/source instructions, Style Primer, internal IDs/hashes/fingerprints and mechanics-control material are absent from the projection object.

### MW-010

```text
Work Item: MW-010
Name: G5 Living-World Integrated Reality Matrix
Capability-Anchor: G5-07 World Product Tests
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: ACTIVE — ZCODE
```

Preferred result is **zero production diff** plus real FinalCreate / CurrentGameRuntime / SQLite integration tests. If the matrix exposes a defect in a previously closed capability, STOP and report the owning capability; do not silently repair it under MW-010.

## 4. G5-07 protected semantics

G5-07 is an integrated reality proof, not another feature-growth phase.

Required engineering scenarios include:

```text
Player Absence / World Independence
Counterfactual Propagation via Save/Restore + alternate path
Independent Actor
Knowledge Boundary
Public d20 → living-world consequence
Save / reopen / Restore composition
player-safe disclosure currentness
```

Use real production Runtime/persistence/composition and deterministic task-owned model stubs where needed. Do not create a generic scenario engine, branch simulator, event bus, ViewModel platform, new persistence schema, new mechanics protocol or G6 dynamic/declarative UI host.

Automated proof does not substitute for Owner product judgment.

## 5. Combined UAT before G5-GATE

After MW-010 Engineering PASS, prepare one combined Owner checkpoint rather than isolated UAT loops.

It must cover as appropriate:

- G5-05 risky action → d20 → natural durable consequence → Save/reopen consistency;
- player-safe disclosure usefulness/privacy;
- world/actor independence and Knowledge boundaries;
- MW-005 prose after the queued bounded style-weight polish;
- MW-004 protagonist-choice boundary;
- MW-003 visual comfort;
- MW-008 rendering unobtrusiveness.

Only Owner may issue the final product/G5-GATE verdict.
