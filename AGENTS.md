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
Zcode + GLM-5.3-flash → primary implementation owner for NEW code-changing tasks
GPT                    → semantics / architecture / task shaping / Independent Review
```

Do not invent low-value work merely to consume quota. At **2026-09-07 00:00 (+08:00)**, absent a new Owner instruction, long-term routing resumes automatically. Gemini review remains CANCELLED / DO NOT EXECUTE.

## 1A. Worktree hygiene — Owner rule

All task worktrees:

`D:/AI/Projects/.worktrees/my-world/<task-or-revision>`

Before creating/removing a worktree, inspect `git worktree list --porcelain`. Remove a completed worktree only after confirming clean + pushed/reachable/integrated + closed/reviewed + no unknown user work. Use `git worktree remove`, then `git worktree prune`; never manually delete a registered worktree.

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
MW-005 Three Kingdoms Literary Style Primer ENGINEERING PASS — OWNER COMBINED UAT (Revision 4 / IR#4)
G5-05 Meaningful Choice / Mechanics Integration ENGINEERING COMPLETE — OWNER COMBINED UAT
MW-006 Mechanics-Grounded World Consequence Vertical ENGINEERING PASS / CLOSED
MW-007 Mechanics Consequence Timeline Continuity ENGINEERING PASS / CLOSED
MW-008 Safe Markdown-Lite Narrative Rendering ENGINEERING PASS / CLOSED
G5-06 Runtime → UI Projection               ENGINEERING PASS / CLOSED
MW-009 Player-Safe Runtime Side Panels      ENGINEERING PASS / CLOSED
G5-07 World Product Tests                   ENGINEERING PASS / CLOSED
MW-010 G5 Living-World Integrated Reality Matrix ENGINEERING PASS / CLOSED (Revision 2 / IR#2)
G5-GATE                                     READY FOR OWNER COMBINED UAT / NOT YET PASS
```

There is no active engineering implementation task. The next authoritative action is the Owner combined G5 product checkpoint:

`docs/g5_gate/G5_COMBINED_OWNER_UAT_CHECKPOINT.md`

Do not create another G5 feature/revision unless that real-play checkpoint exposes a concrete blocker.

## 3. Current Work Item identities

### MW-005

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Revision 4 implementation SHA: aacc65e0f92debb679a8b30708d1452c1426fd76
Review-Round: IR#4
Status: ENGINEERING PASS — OWNER COMBINED UAT
```

Revision 4 changes only the request-only `STYLE_NARRATIVE_ANCHOR_CUE` wording. The literary reference remains expression-only and never Game truth, future canon, Player/actor Knowledge, semantic consequence authority, World Evolution causal input, mechanics-control authority, or mandatory output protocol. Primer/source bytes and Source generation remain unchanged: `58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`.

Formal review: `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR4.md`.

If Owner still finds the prose materially too weak, do not continue indefinite cue-weight escalation; revisit Primer content/selection in the MW-005 revision lineage. If too forceful, reduce the same cue in the same lineage.

### G5-05 / MW-006 / MW-007

```text
MW-006 = ENGINEERING PASS / CLOSED
MW-007 = ENGINEERING PASS / CLOSED
G5-05  = ENGINEERING COMPLETE — OWNER COMBINED UAT
```

Protected mechanics semantics:

```text
Program-owned Public d20 result
→ bounded grounding in normal G5-01 semantic opportunity
→ accepted free-form Narrative remains concrete consequence source
→ durable world consequence
→ Save / close / reopen / Continue / Restore coherent
```

Do not introduce a second mechanics truth, fixed outcome→effect table, fake NO_CHECK mechanics, Narrative gate/retry, or new SQLite mechanics schema.

### MW-008

```text
Work Item: MW-008
Name: Safe Markdown-Lite Narrative Rendering
Implementation SHA: 9f90e634d6d0302e9905f131410f7a33611e8d41
Review-Round: IR#1
Status: ENGINEERING PASS / CLOSED
```

Raw GM Narrative remains authoritative in Conversation/persistence/context; Markdown-lite is disposable UI projection only. Whitelist v0.1: `**text**`, `*text*`, standalone `---`.

### MW-009 / G5-06

```text
MW-009 = ENGINEERING PASS / CLOSED
G5-06  = ENGINEERING PASS / CLOSED
```

Protected projection rule:

```text
Runtime truth
!= GM-visible truth
!= actor-private knowledge
!= human-player-safe UI projection
```

Player-safe projection exposes only safe Player identity, safe World/Entry identity and bounded current Player Character Knowledge facts.

### MW-010 / G5-07

```text
MW-010 Revision 2 / IR#2 = ENGINEERING PASS / CLOSED
G5-07                    = ENGINEERING PASS / CLOSED
```

The integrated matrix proves quiet hold, independent NPC Agency, World Evolution, NPC-only Knowledge vs later Player disclosure, Program-owned d20 → MW-006 → G5-01 consequence, close/reopen reconstruction, no-reroll, Save/Restore counterfactual currentness, and player-safe disclosure boundaries using real FinalCreate/Runtime/SQLite composition and deterministic stubs.

## 4. Combined Owner UAT before G5-GATE

Use:

`docs/g5_gate/G5_COMBINED_OWNER_UAT_CHECKPOINT.md`

The checkpoint covers:

- living-world quiet/independent evolution;
- NPC agency and knowledge secrecy;
- meaningful risky action → Public d20 → natural durable consequence;
- Save/reopen/Restore coherence;
- protagonist-choice boundary;
- player-safe side-panel usefulness/privacy;
- Three Kingdoms prose after MW-005 R4;
- Markdown-lite rendering and visual comfort.

Only Owner may issue Product PASS statuses and the final **G5-GATE PASS**.

If UAT finds a blocker, route it to the owning existing Work Item revision when it is the same outcome; mint a new flat Work Item only for a genuinely distinct outcome.
