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

Kimi
→ completes MW-005 Revision 2 because it was already assigned before the override

GPT
→ remains semantic / architecture / task-shaping / Independent Review owner
```

Do not invent low-value work merely to consume quota. Stage Gates, Task Packets, scope boundaries and implementer/reviewer separation remain unchanged. At **2026-09-07 00:00 (+08:00)**, absent a new Owner instruction, long-term routing resumes automatically.

MW-004 was a one-item Owner-authorized GPT implementation exception. MW-006 was an Owner-authorized Zcode + GLM-5.3-flash implementation and is closed. Neither changes long-term routing.

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
MW-005 Three Kingdoms Literary Style Primer CORRECTION REQUIRED — REVISION 2 / KIMI
G5-05 Meaningful Choice / Mechanics Integration ACTIVE
MW-006 Mechanics-Grounded World Consequence Vertical ENGINEERING PASS / CLOSED
G5-GATE                                     NOT YET
```

MW-005 is a distinct Owner-inserted source-content/runtime integration slice anchored to G4. It does not reopen G4, does not make the literary reference World truth, and remains independent from G5-05.

G5-04 is closed after Owner-completed UAT on 2026-09-05. Closeout:

`docs/g5_04/G5-04_CLOSEOUT.md`

G5-05 is now authorized and ACTIVE. MW-006 is its first closed engineering vertical; it does not close G5-05 as a whole.

Current executable packets for MW-005:

- `docs/tasks/MW-005_THREE_KINGDOMS_LITERARY_STYLE_PRIMER_TASK.md`
- `docs/tasks/MW-005_REVISION2_CONTROL_LANE_STYLE_EXCLUSION_ADDENDUM.md`

Canonical MW-005 task input:

`docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt`

MW-006 records:

- `docs/tasks/MW-006_MECHANICS_GROUNDED_WORLD_CONSEQUENCE_TASK.md` — post-implementation governance backfill; see provenance note inside.
- `docs/mw006/MW-006_INDEPENDENT_REVIEW_IR1.md` — authoritative IR#1 PASS.

## 3. Current parallel Work Item identities

### MW-005

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Inserted-By: Owner
Triggered-By: G5-04 Owner UAT prose-quality observation
Revision: 2
Review-Round: IR#1 completed; target IR#2
Implementation Base for correction: current main after IR#1 governance propagation
Owner: Kimi
Reviewer: GPT
Status: CORRECTION REQUIRED — REVISION 2 / KIMI
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

Task identity and lineage follow `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

## 4. MW-005 protected semantics

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

Model Freedom First remains protected. Do not turn the correction into mandatory `却说` / `且说`, half-classical output, a modern-word blacklist, fixed output shape, parser/classifier gate, or retry loop.

The approved Primer is bounded (~2.6k characters) and is the only content payload for v0.1. Do not commit/import the user's EPUB, full novel, publisher foreword, notes or editorial material.

Revision 2 specifically requires style material to be excluded from Public-d20 `control` / `control_recovery` while remaining available to Opening and GM Narrative stages. Do not republish the Source generation for this runtime-only correction.

## 5. MW-005 architecture guardrails

Current `world_pack.v0.2` already supports semantic sections whose `section_type` is an open safe token. Current carrier:

```text
section_type = literary_style_reference
disclosure   = gm_reference
```

No schema v0.3/platform is authorized merely for this task.

Normal first-opening + ordinary GM Narrative are the intended consumers. G5-04 `project_world_only()` and Public-d20 mechanics-control lanes must exclude the Primer completely. Existing opened Games remain frozen to their prior Source generation and must not read mutable Source current.

Current published Primer generation remains immutable; Revision 2 must not create a new generation merely to change a Runtime consumer.

## 6. MW-006 protected result

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

## 7. Required proof / review boundary

For MW-005 Revision 2, Engineering evidence must prove at least:

- Public-d20 `control` and `control_recovery` receive normal factual Game-local context but no literary style reference;
- subsequent GM Narrative stages still receive the Primer exactly once under the non-factual boundary;
- existing Opening / ordinary continuation / old-new generation freeze behavior remains green;
- `project_world_only()` still excludes the Primer;
- Source generation fingerprint remains unchanged;
- directly affected Public-d20 retry/no-reroll and MW-006 grounding regressions remain green;
- `git diff --check` clean; export validation if production GDScript changes require it.

Kimi may return at most `READY FOR INDEPENDENT REVIEW`. GPT performs IR#2 from actual code/evidence. Owner later performs prose A/B UAT.

MW-006 is already `ENGINEERING PASS / CLOSED`; do not reopen or redesign it merely while doing later G5-05 work. A new independent Outcome requires a new flat Work Item ID.

## 8. Existing open UAT / debt items

MW-004 remains `IMPLEMENTED — OWNER UAT`; do not silently close it. Its minimal Player Agency principle remains protected:

> **The GM owns freedom to advance the world; the Player owns new meaningful choices for the protagonist.**

MW-003 remains `ENGINEERING PASS — OWNER UAT`; positive visual feedback is not silently converted to Product PASS.

A pre-existing G3-04 persistence assertion is stale after MW-004 because the shared GM instruction legitimately contains the literal phrase `Current Game Context`. MW-006 did not introduce this failure. Repair it separately; do not fold it into MW-006.
