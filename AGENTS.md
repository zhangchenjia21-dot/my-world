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

MW-004 was a one-item Owner-authorized GPT implementation exception. MW-006 and MW-007 were Owner-authorized Zcode tasks and are closed. MW-005 Revision 3 was implemented by Zcode and passed GPT IR#3; it now awaits Owner UAT. MW-008 is the current Zcode task under the weekend override.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 1A. Worktree hygiene — Owner rule

Task worktrees must not be scattered directly under `D:/AI/Projects`.

Required location for all new my-world task worktrees:

```text
D:/AI/Projects/.worktrees/my-world/<task-or-revision>
```

Before creating a new task worktree, inspect registered worktrees with `git worktree list --porcelain`. A completed worktree may be removed only after confirming it is clean, its unique commits are safely pushed/reachable, its task is closed/reviewed, and it contains no unknown user work. Use `git worktree remove`; do not manually delete a registered worktree directory. Run `git worktree prune` after safe removals.

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
MW-005 Three Kingdoms Literary Style Primer ENGINEERING PASS — OWNER UAT (Revision 3 / IR#3)
G5-05 Meaningful Choice / Mechanics Integration ENGINEERING COMPLETION EVIDENCE READY — OWNER UAT
MW-006 Mechanics-Grounded World Consequence Vertical ENGINEERING PASS / CLOSED
MW-007 Mechanics Consequence Timeline Continuity ENGINEERING PASS / CLOSED
MW-008 Safe Markdown-Lite Narrative Rendering ACTIVE — ZCODE
G5-GATE                                     NOT YET
```

G5-04 is closed after Owner-completed UAT on 2026-09-05.

G5-05 has engineering completion evidence from MW-006 + MW-007. It is not Product-closed until Owner validates a real risky-action path and confirms mechanics matter naturally without dominating play.

MW-005 remains a distinct Owner-inserted source-content/runtime integration outcome anchored to G4. Revision 3 passed Engineering IR#3 after moving the existing Primer into a single late Narrative-only style anchor. Only Owner prose UAT remains; if the style change is still not perceptible, revisit Primer content rather than adding more prompt weight.

MW-008 is a separate presentation task triggered by literal Markdown such as `**张飞**` and `---` appearing in the Narrative UI. It must not alter MW-005 style semantics or raw Narrative truth.

Current active executable packet:

- `docs/tasks/MW-008_SAFE_MARKDOWN_LITE_NARRATIVE_RENDERING_TASK.md`

Relevant review/task records:

- `docs/tasks/MW-005_THREE_KINGDOMS_LITERARY_STYLE_PRIMER_TASK.md`
- `docs/tasks/MW-005_REVISION2_CONTROL_LANE_STYLE_EXCLUSION_ADDENDUM.md`
- `docs/tasks/MW-005_REVISION3_NARRATIVE_STYLE_SALIENCE_TASK.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR2.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR3.md`
- `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw007/MW-007_INDEPENDENT_REVIEW_IR1.md`

## 3. Current Work Item identities

### MW-005

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Revision: 3
Review-Round: IR#3
Revision-3 implementation SHA: a52236c5ec55bf07a727b4e07c4ef63572b18555
Reviewer: GPT
Status: ENGINEERING PASS — OWNER UAT
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
Status: ENGINEERING PASS / CLOSED
```

### MW-008

```text
Work Item: MW-008
Name: Safe Markdown-Lite Narrative Rendering
Capability-Anchor: G2 Narrative Conversation View / presentation
Inserted-By: Owner UAT observation during G5
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: ACTIVE — ZCODE
```

Task identity and lineage follow `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

## 4. MW-005 protected result

The Style Primer remains expression reference only:

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

Current Three Kingdoms carrier remains a World `semantic_section` with `section_type=literary_style_reference`, `disclosure=gm_reference`.

Revision 3 / IR#3 establishes:

```text
Opening / ordinary continuation / d20 Narrative
→ single late request-only style anchor
→ factual/mechanics material first
→ concise positive voice cue

Public d20 control/control_recovery
→ no style material/cue

G5-04 world-only / G5-01 semantic
→ no style material/cue
```

Published Source generation remains immutable:

`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`

Do not republish or change Primer bytes unless a later Owner-approved Revision explicitly changes content.

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

## 6. MW-008 protected semantics

MW-008 is presentation-only:

```text
raw model GM Narrative
→ Conversation / persistence / future context unchanged
→ UI-only Markdown-lite rendering
```

Initial whitelist:

- `**text**` bold;
- `*text*` italic;
- standalone `---` thematic separator.

Do not feed raw model text to unrestricted Godot BBCode. Arbitrary `[color]`, `[url]`, `[img]`, `[font]` etc. must remain literal. Streaming chunk boundaries must not corrupt Markdown interpretation. A transient view-only current-GM raw buffer is allowed but must never become a second durable history store.

Do not expand MW-008 into full CommonMark/GFM, HTML, links/images, a model-output Markdown protocol or G5-06 world-state UI projection.

## 7. Review / UAT boundaries

MW-005: Owner must repeat UAT with a **new Three Kingdoms Game**. If the visible style difference remains weak, next action is Primer-content review, not more salience prompt weight.

G5-05: Owner may validate a real path:

```text
meaningful risky action
→ visible Public d20 result
→ natural GM consequence
→ later world remains consistent
→ Save/reopen remembers it
```

Also confirm NO_CHECK remains natural and mechanics do not dominate every action.

MW-008 may return at most `READY FOR INDEPENDENT REVIEW`. GPT reviews actual rendering code/tests. Owner then checks normal-play appearance.

MW-004 remains `IMPLEMENTED — OWNER UAT`; MW-003 remains `ENGINEERING PASS — OWNER UAT`.

A pre-existing G3-04 assertion is stale after MW-004 because it treats the literal phrase `Current Game Context` in GM instructions as proof of raw-context leakage. Repair separately; do not fold it into MW-005/G5-05/MW-008.
