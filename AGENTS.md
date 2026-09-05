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
→ primary implementation owner for NEW code-changing tasks issued after the Owner's 2026-09-05 routing decision

GPT
→ remains semantic / architecture / task-shaping / Independent Review owner
```

Do not invent low-value work merely to consume quota. Stage Gates, Task Packets, scope boundaries and implementer/reviewer separation remain unchanged. At **2026-09-07 00:00 (+08:00)**, absent a new Owner instruction, long-term routing resumes automatically.

MW-004 was a one-item Owner-authorized GPT implementation exception. MW-006 and MW-007 were Owner-authorized Zcode + GLM-5.3-flash tasks and are closed. MW-005 Revision 3 is the current Owner-routed Zcode task under the weekend override. None changes long-term routing.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 1A. Worktree hygiene — Owner rule

Task worktrees must not be scattered directly under `D:/AI/Projects`.

Required location for all new my-world task worktrees:

```text
D:/AI/Projects/.worktrees/my-world/<task-or-revision>
```

Before creating a new task worktree, inspect registered worktrees with `git worktree list --porcelain`. A completed worktree may be removed only after confirming it is clean, its unique commits are safely pushed/reachable, its task is closed, and it contains no unknown user work. Use `git worktree remove`; do not manually delete a registered worktree directory. Run `git worktree prune` after safe removals.

If an old directory is an ordinary clone/copy rather than a registered worktree, do not delete it merely by name; inspect status/branch/remote/unique commits first.

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
MW-005 Three Kingdoms Literary Style Primer OWNER UAT NOT PASS — REVISION 3 / ZCODE
G5-05 Meaningful Choice / Mechanics Integration ENGINEERING COMPLETION EVIDENCE READY — OWNER UAT
MW-006 Mechanics-Grounded World Consequence Vertical ENGINEERING PASS / CLOSED
MW-007 Mechanics Consequence Timeline Continuity ENGINEERING PASS / CLOSED
G5-GATE                                     NOT YET
```

MW-005 remains a distinct Owner-inserted source-content/runtime integration slice anchored to G4. IR#2 proved the v0.1 consumer boundaries, but Owner prose UAT did not observe a strong enough product-level style change. Revision 3 therefore stays on the same Work Item and addresses narrative style **salience/placement**, not mechanics or world truth.

G5-04 is closed after Owner-completed UAT on 2026-09-05.

G5-05 has engineering completion evidence from MW-006 + MW-007. It is not Product-closed until Owner validates a real risky-action path and confirms mechanics matter naturally without dominating play.

Current active executable packet:

- `docs/tasks/MW-005_REVISION3_NARRATIVE_STYLE_SALIENCE_TASK.md`

MW-005 records:

- `docs/tasks/MW-005_THREE_KINGDOMS_LITERARY_STYLE_PRIMER_TASK.md`
- `docs/tasks/MW-005_REVISION2_CONTROL_LANE_STYLE_EXCLUSION_ADDENDUM.md`
- `docs/tasks/MW-005_REVISION3_NARRATIVE_STYLE_SALIENCE_TASK.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR2.md`
- `docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt`

MW-006 / MW-007 review records:

- `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw007/MW-007_INDEPENDENT_REVIEW_IR1.md`

## 3. Current Work Item identities

### MW-005

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Inserted-By: Owner
Triggered-By: G5-04 Owner UAT prose-quality observation
Revision: 3
Review-Round: IR#2 complete; target IR#3
Revision-2 implementation SHA: 583dde4d4dc9e4b6f2b82dd5f0cae0960dcc62cc
Revision-2 evidence SHA: 4e2c467fd9468dfa9c3d296c66e04e16ed9628df
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Status: OWNER UAT NOT PASS — REVISION 3 / ZCODE
```

### MW-006

```text
Work Item: MW-006
Name: Mechanics-Grounded World Consequence Vertical
Capability-Anchor: G5-05 Meaningful Choice / Mechanics Integration
Implementation SHA: adb3ca45c2e869c7685915de18664ee3ce7e6f39
Review-Round: IR#1
Status: ENGINEERING PASS / CLOSED
```

### MW-007

```text
Work Item: MW-007
Name: Mechanics Consequence Timeline Continuity
Capability-Anchor: G5-05 Meaningful Choice / Mechanics Integration
Implementation/Evidence SHA: 9494c92ff3b6c9949ff97b86336dbf36baf90942
Review-Round: IR#1
Reviewer: GPT
Status: ENGINEERING PASS / CLOSED
```

Task identity and lineage follow `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

## 4. MW-005 protected semantics and Revision-3 direction

The Style Primer is expression reference only:

```text
Literary Style Reference
= diction / syntax / etiquette / dialogue / narrative-distance / information-delivery exemplar
!= Game world truth
!= future canon
!= original-novel plot authority
!= NPC destiny
!= Player/actor Knowledge
!= World Evolution causal input
!= mechanics-adjudication input
!= semantic-consequence authority
!= mandatory chapter-novel format
```

Current Three Kingdoms carrier remains:

```text
World semantic section
section_type = literary_style_reference
disclosure   = gm_reference
```

IR#2 consumer boundary remains protected:

```text
first opening                         INCLUDE
ordinary continuation GM narrative   INCLUDE
Public d20 resolution narrative       INCLUDE
Public d20 NO_CHECK narrative         INCLUDE
Public d20 degraded narrative         INCLUDE
Public d20 control                     EXCLUDE
Public d20 control_recovery            EXCLUDE
G5-04 project_world_only()             EXCLUDE
```

Owner UAT after IR#2 found the prose shift insufficiently perceptible. Revision 3 must keep Primer/source bytes and generation unchanged while making the existing reference a **single late narrative-only style anchor** with a concise positive steering cue. Do not solve this by duplication, longer negative prompts, output gates, mandatory formulas, blacklists or a generic style framework.

The published Source generation remains immutable:

`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`

If runtime salience correction still fails Owner UAT, revisit the Primer content itself in a later Revision instead of endlessly increasing prompt weight.

Literal Markdown rendering (`**张飞**`, `---`) visible in the narrative UI is a separate presentation outcome and must not be folded into MW-005 Revision 3.

## 5. G5-05 protected result

MW-006 established:

```text
existing authoritative Public d20 CHECK_REQUIRED resolution
→ request-time grounding in the existing G5-01 semantic opportunity
→ accepted Narrative remains the source of concrete scene consequence
→ existing semantic mutation seam materializes supported durable consequences
```

MW-007 independently proved with zero production diff that the resulting mechanics-grounded consequence participates coherently in:

```text
Save → close → reopen → Continue
and
pre-action Save → mechanics/consequence → Restore
```

No second mechanics truth, hardcoded outcome-effect table, reroll protocol, Narrative gate/retry, new SQLite schema or generic persistence framework was introduced.

One non-blocking advisory remains: after Restore, reusing the exact same caller-owned `action_id` for a restored-away future action fails loud on the existing mutation identity conflict rather than silently rerolling/reusing truth. Do not redesign identity absent a real product reproduction.

## 6. Review / UAT boundaries

MW-005 Revision 3 may return at most `READY FOR INDEPENDENT REVIEW`. GPT performs IR#3. Owner then repeats new-Game prose UAT.

G5-05 is engineering-ready for Owner product validation. A suitable UAT path is:

```text
meaningful risky action
→ visible Public d20 result
→ natural GM consequence
→ later world remains consistent
→ Save/reopen remembers it
```

Owner should also confirm `NO_CHECK` remains natural and mechanics do not dominate every action.

MW-004 remains `IMPLEMENTED — OWNER UAT`; do not silently close it. MW-003 remains `ENGINEERING PASS — OWNER UAT`.

A pre-existing G3-04 assertion is stale after MW-004 because it treats the literal phrase `Current Game Context` in GM instructions as proof of raw-context leakage. Repair separately; do not fold it into MW-005/G5-05.
