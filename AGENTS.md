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
G5-06 Runtime → UI Projection               ACTIVE
MW-009 Player-Safe Runtime Side Panels      ACTIVE — ZCODE
G5-07 World Product Tests                   NOT YET
G5-GATE                                     NOT YET
```

Owner explicitly authorized proceeding to G5-06 without another isolated G5-05 UAT cycle. G5-05 is **not Product-closed**; its real-play validation is deferred to the later combined G5-07/G5-GATE pass.

MW-005 Revision 3 passed Engineering IR#3. Owner still wants a modest additional style-weight adjustment before the later combined product test, but that work is deferred and must not interrupt G5-06. Do not silently create MW-005 Revision 4 inside MW-009.

MW-008 Revision 1 / IR#1 is Engineering PASS / CLOSED. Its accepted presentation rule is UI-only Markdown-lite projection; raw Narrative truth remains unchanged.

Current active executable packet:

- `docs/tasks/MW-009_PLAYER_SAFE_RUNTIME_SIDE_PANELS_TASK.md`

Current G5-06 architecture:

- `Vibe-Coding/my world/architecture/world/G5_PLAYER_SAFE_RUNTIME_UI_PROJECTION_V0_1_DECISION.md`

Relevant records:

- `docs/g5_05/G5-05_ENGINEERING_COMPLETION_CHECKPOINT.md`
- `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw007/MW-007_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw008/MW-008_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR3.md`

## 3. Current Work Item identities

### MW-005

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Revision: 3 engineering result complete
Review-Round: IR#3
Revision-3 implementation SHA: a52236c5ec55bf07a727b4e07c4ef63572b18555
Status: ENGINEERING PASS — OWNER FOLLOW-UP POLISH/UAT DEFERRED
```

Protected result: Style reference is expression-only, never Game truth, future canon, Player/actor Knowledge, World Evolution causality, mechanics-control authority or semantic-consequence authority. Current Source generation remains immutable `58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443` until an explicit future Revision changes content.

### MW-006 / MW-007 / G5-05

```text
MW-006 = ENGINEERING PASS / CLOSED
MW-007 = ENGINEERING PASS / CLOSED
G5-05  = ENGINEERING COMPLETE — OWNER UAT DEFERRED / PROGRESSION AUTHORIZED
```

Protected mechanics semantics:

```text
Program-owned Public d20 result
→ bounded grounding in the normal G5-01 semantic opportunity
→ accepted free-form Narrative remains the source of concrete consequence
→ durable world consequence
→ Save / close / reopen / Continue / Restore coherent
```

Do not introduce a second mechanics truth, fixed outcome→effect table, reroll redesign, fake NO_CHECK mechanics, Narrative gate/retry, new SQLite mechanics schema, raw-mechanics injection into G5-04 or actor-knowledge shortcuts.

### MW-008

```text
Work Item: MW-008
Name: Safe Markdown-Lite Narrative Rendering
Capability-Anchor: G2 Narrative Conversation View / presentation
Implementation SHA: 9f90e634d6d0302e9905f131410f7a33611e8d41
Review-Round: IR#1
Status: ENGINEERING PASS / CLOSED
```

Protected presentation semantics:

```text
raw GM Narrative
→ Conversation / persistence / future context unchanged
→ disposable UI-only rendering
```

Whitelist v0.1: `**text**`, `*text*`, standalone `---`. Arbitrary Godot BBCode-like model text remains literal. IR#1 advisory: some unsupported mixed/nested emphasis may style oddly rather than fully literal-fail-soft; do not expand into a general Markdown engine absent real UAT evidence.

### MW-009

```text
Work Item: MW-009
Name: Player-Safe Runtime Side Panels
Capability-Anchor: G5-06 Runtime → UI Projection
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: ACTIVE — ZCODE
```

## 4. G5-06 protected semantics

Core rule:

```text
Runtime truth
!= GM-visible truth
!= actor-private knowledge
!= human-player-safe UI projection
```

Disclosure belongs to the projection boundary. UI widgets must not receive the whole omniscient `world_state` and filter it themselves.

MW-009 first vertical may expose only:

```text
Player Character safe identity
World / selected Entry safe identity
recent current Player Character Knowledge Provenance facts
```

It must exclude raw:

```text
NPC knowledge
semantic world-change ledger
independent actor actions
World Evolution events
GM/source instructions
Style Primer
internal IDs/hashes/fingerprints
mechanics-control/proposal payloads
```

Currentness must follow accepted Conversation turn/hash matching. Restore/reopen must reconstruct the same safe projection; stale or invalid data fails closed.

Use the existing Player/World side panels. Do not build full G6 Character Sheet, journal, map, faction, inventory, visual asset runtime, generic ViewModel/event bus, Player Knowledge database or new persistence schema.

## 5. Review / UAT boundary

MW-009 may return at most `READY FOR INDEPENDENT REVIEW`. GPT reviews actual code/tests.

Owner has chosen to combine remaining product checks later rather than stop the mainline after every slice. Before G5-GATE, combined validation must still cover:

- G5-05 risky action → d20 → natural durable consequence → Save/reopen consistency;
- player-safe disclosure boundary;
- world/actor independence and Knowledge boundaries;
- MW-005 prose quality after the requested bounded follow-up weight adjustment;
- MW-003/MW-004 open UAT items as appropriate.

Engineering completion does not substitute for G5-GATE product judgment.
