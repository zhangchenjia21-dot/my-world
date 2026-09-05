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

Kimi's already-assigned MW-005 Revision 2 is now engineering-complete and awaiting Owner UAT; it is no longer an active implementation lane.

Do not invent low-value work merely to consume quota. Stage Gates, Task Packets, scope boundaries and implementer/reviewer separation remain unchanged. At **2026-09-07 00:00 (+08:00)**, absent a new Owner instruction, long-term routing resumes automatically.

MW-004 was a one-item Owner-authorized GPT implementation exception. MW-006 was an Owner-authorized Zcode + GLM-5.3-flash implementation and is closed. MW-007 is the current Owner-routed Zcode task under the weekend override. None changes long-term routing.

Gemini review remains CANCELLED / DO NOT EXECUTE.

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
MW-005 Three Kingdoms Literary Style Primer ENGINEERING PASS — OWNER UAT
G5-05 Meaningful Choice / Mechanics Integration ACTIVE
MW-006 Mechanics-Grounded World Consequence Vertical ENGINEERING PASS / CLOSED
MW-007 Mechanics Consequence Timeline Continuity ACTIVE — ZCODE
G5-GATE                                     NOT YET
```

MW-005 is a distinct Owner-inserted source-content/runtime integration slice anchored to G4. It does not reopen G4, does not make the literary reference World truth, and remains independent from G5-05. IR#2 passed; only Owner prose A/B UAT remains.

G5-04 is closed after Owner-completed UAT on 2026-09-05. Closeout:

`docs/g5_04/G5-04_CLOSEOUT.md`

G5-05 is ACTIVE. MW-006 established the first mechanics-grounded consequence vertical. MW-007 is a second, bounded completion proof that composes the existing Public d20 + G5-01 + Save/Restore/Continue seams using production Runtime/SQLite ownership. It must not invent a new mechanics or persistence architecture.

Current active executable packet:

- `docs/tasks/MW-007_MECHANICS_CONSEQUENCE_TIMELINE_CONTINUITY_TASK.md`

MW-005 records:

- `docs/tasks/MW-005_THREE_KINGDOMS_LITERARY_STYLE_PRIMER_TASK.md`
- `docs/tasks/MW-005_REVISION2_CONTROL_LANE_STYLE_EXCLUSION_ADDENDUM.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR1.md`
- `docs/mw005/MW-005_INDEPENDENT_REVIEW_IR2.md`
- `docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt`

MW-006 records:

- `docs/tasks/MW-006_MECHANICS_GROUNDED_WORLD_CONSEQUENCE_TASK.md` — post-implementation governance backfill; see provenance note inside.
- `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md` — authoritative IR#1 PASS.

## 3. Current Work Item identities

### MW-005

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Inserted-By: Owner
Triggered-By: G5-04 Owner UAT prose-quality observation
Revision: 2
Review-Round: IR#2
Revision-2 implementation SHA: 583dde4d4dc9e4b6f2b82dd5f0cae0960dcc62cc
Revision-2 evidence SHA: 4e2c467fd9468dfa9c3d296c66e04e16ed9628df
Owner: Kimi
Reviewer: GPT
Status: ENGINEERING PASS — OWNER UAT
```

### MW-006

```text
Work Item: MW-006
Name: Mechanics-Grounded World Consequence Vertical
Capability-Anchor: G5-05 Meaningful Choice / Mechanics Integration
Authorized-By: Owner
Implementer: Zcode + GLM-5.3-flash
Revision: 1
Review-Round: IR#1
Implementation SHA: adb3ca45c2e869c7685915de18664ee3ce7e6f39
Reviewer: GPT
Status: ENGINEERING PASS / CLOSED
```

### MW-007

```text
Work Item: MW-007
Name: Mechanics Consequence Timeline Continuity
Capability-Anchor: G5-05 Meaningful Choice / Mechanics Integration
Triggered-By: MW-006 Engineering PASS / G5-05 completion audit
Depends-On: MW-006 ENGINEERING PASS / CLOSED
Implementer: Zcode + GLM-5.3-flash
Reviewer: GPT
Revision: 1
Review-Round: 0
Status: ACTIVE — ZCODE
```

Task identity and lineage follow `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

## 4. MW-005 protected result

The Style Primer is expression reference only:

```text
Literary Style Reference
= diction / syntax / etiquette / dialogue / narrative-distance exemplar
!= Game world truth
!= future canon
!= original-novel plot authority
!= NPC destiny
!= Player/actor Knowledge
!= World Evolution causal input
!= mechanics-adjudication input
!= mandatory chapter-novel format
```

Current Three Kingdoms carrier:

```text
World semantic section
section_type = literary_style_reference
disclosure   = gm_reference
```

IR#2 establishes the v0.1 consumer matrix:

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

The published Source generation remains immutable:

`58966f73dfade50b0aa7536aad38a8840e614016975e8beba0735f7dd14ab443`

Do not republish it merely for the Runtime consumer correction. Existing opened Games remain frozen to their prior exact generation and must not read mutable Source current.

Model Freedom First remains protected. Do not turn the Primer into mandatory `却说` / `且说`, half-classical output, a modern-word blacklist, fixed output shape, parser/classifier gate, or retry loop. Do not commit/import the user's EPUB, full novel, publisher foreword, notes or editorial material.

IR#2 includes one non-blocking future advisory: if a future product decision introduces Character-card `literary_style_reference` sections, mechanics-control exclusion must be re-audited for that new carrier. Do not build that speculative generalization now.

## 5. MW-006 protected result

MW-006 established this narrow authority flow:

```text
existing authoritative Public d20 CHECK_REQUIRED resolution
→ request-time grounding in the existing G5-01 semantic opportunity
→ accepted Narrative remains the source of concrete scene consequence
→ existing semantic mutation seam materializes supported durable consequences
```

Do not regress this into:

- `SUCCESS/FAILURE → fixed world effect` tables;
- a second mechanics truth/store;
- rerolls;
- fake NO_CHECK mechanics;
- Narrative parser/gate/retry protocols;
- extra semantic replay opportunities;
- direct raw-mechanics injection into G5-04;
- Actor Knowledge shortcuts;
- SQLite mechanics schema work.

The accepted-turn reader deliberately fails closed when no unique accepted durable check matches; loss of optional grounding is preferable to guessed mechanics authority.

## 6. MW-007 protected outcome

MW-007 is an integration/durability proof, not a new mechanics feature.

It must prove with task-owned SQLite and production Runtime seams that:

```text
CHECK_REQUIRED
→ authoritative d20 result
→ accepted free-form Narrative
→ MW-006-grounded G5-01 semantic consequence
→ Save / close / reopen / Continue consistency
→ Restore rewinds restored-away future truth coherently
```

Preferred result when architecture is already correct is **test/evidence only with zero production diff**. A production fix is allowed only for a real defect already implied by current canonical semantics. If fixing it requires a new SQLite migration, mechanics truth, Public-d20 protocol, Timeline architecture, extra semantic replay, or collision with the now-merged MW-005 consumer boundary, STOP and return to GPT/Owner.

Zcode must refresh/rebase onto latest `main` containing MW-005 Revision 2 before final handoff and rerun the focused matrix.

## 7. Required proof / review boundary

MW-005 has passed Engineering IR#2. Owner UAT must now use a **new** Three Kingdoms Game and judge actual prose value, including period-rooted dialogue, intelligence delivery, war/administrative voice, readability, absence of mechanical chapter-novel tics, no future-plot leakage, and preserved Player Agency.

For MW-007, Engineering evidence must prove at least:

- post-consequence Save + close/reopen preserves the accepted Narrative, exact d20 truth and semantic consequence without reroll/duplication;
- later continuation Context sees the valid committed consequence through the existing World Turn context seam;
- Restore to a pre-action Save removes restored-away Conversation/world consequence and does not leak ghost mechanics grounding/future Context according to current persistence ownership;
- MW-006 and G5-01 timeline regressions remain green;
- no SQLite schema/table/migration change;
- no regression of MW-005 Revision-2 control/narrative consumer boundary;
- `git diff --check` clean; export validation if production GDScript changes.

Zcode may return at most `READY FOR INDEPENDENT REVIEW`. GPT performs actual-code Independent Review. Owner retains Product/UAT authority.

## 8. Existing open UAT / debt items

MW-005 is `ENGINEERING PASS — OWNER UAT`; do not claim Product PASS until Owner performs the new-Game A/B prose check.

MW-004 remains `IMPLEMENTED — OWNER UAT`; do not silently close it. Its minimal Player Agency principle remains protected:

> **The GM owns freedom to advance the world; the Player owns new meaningful choices for the protagonist.**

MW-003 remains `ENGINEERING PASS — OWNER UAT`; positive visual feedback is not silently converted to Product PASS.

A pre-existing G3-04 persistence assertion is stale after MW-004 because the shared GM instruction legitimately contains the literal phrase `Current Game Context`. MW-006 did not introduce this failure. Repair it separately; do not fold it into MW-005, MW-006 or MW-007.
