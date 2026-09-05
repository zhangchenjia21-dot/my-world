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

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns code-changing implementation; GPT remains semantic owner/reviewer. MW-004 was a one-item Owner-authorized GPT implementation exception and does not change general routing.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization PASS / CLOSED
G5-04 Event / Priority Evolution            ACTIVE — OWNER UAT PAUSED FOR MW-005
MW-002 Selective World Evolution Evaluator ENGINEERING PASS / CLOSED
MW-003 Visual Comfort Theme Pass            ENGINEERING PASS — OWNER UAT
MW-004 Minimal Player Agency Principle      IMPLEMENTED — OWNER UAT
MW-005 Three Kingdoms Literary Style Primer ACTIVE — KIMI
G5-GATE                                     NOT YET
```

MW-005 is a distinct Owner-inserted source-content/runtime integration slice anchored to G4. It does not reopen G4, does not make the literary reference World truth, and does not authorize G5-05.

Current executable packet:

`docs/tasks/MW-005_THREE_KINGDOMS_LITERARY_STYLE_PRIMER_TASK.md`

Canonical task input:

`docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt`

## 3. Current Work Item identity

```text
Work Item: MW-005
Name: Three Kingdoms Literary Style Primer v0.1
Capability-Anchor: G4 Primary Source Assets & Local Game
Inserted-By: Owner
Triggered-By: G5-04 Owner UAT prose-quality observation
Revision: 1
Review-Round: 0
Implementation Base: 63262dfe52d9200115544bb0a1f2507795039e33
Owner: Kimi
Reviewer: GPT
Status: ACTIVE — KIMI
```

This is a new independent Outcome under `Vibe-Coding/governance/TASK_IDENTITY_AND_LINEAGE_V1_0.md`.

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
!= mandatory chapter-novel format
```

Model Freedom First remains protected. Do not turn the correction into mandatory `却说` / `且说`, half-classical output, a modern-word blacklist, fixed output shape, parser/classifier gate, or retry loop.

The approved Primer is bounded (~2.6k characters) and is the only content payload for v0.1. Do not commit/import the user's EPUB, full novel, publisher foreword, notes or editorial material.

## 5. MW-005 architecture guardrails

Current `world_pack.v0.2` already supports semantic sections whose `section_type` is an open safe token. Preferred minimal carrier is:

```text
section_type = literary_style_reference
disclosure   = gm_reference
```

No schema v0.3/platform is authorized merely for this task.

Before editing, perform the packet-required two-pass audit of:

1. the real Three Kingdoms authoring/source package + stable `asset_id`;
2. every consumer of World `semantic_sections` / frozen `source_projection` that could treat style material as factual/causal.

Normal first-opening + ordinary GM Narrative are the intended v0.1 consumers. G5-04 `project_world_only()` must exclude the Primer completely. Existing opened Games remain frozen to their prior Source generation and must not read mutable Source current.

Publish/install a new immutable exact Source generation through the existing Source Library flow; do not mutate an existing managed generation in place.

## 6. Required proof / review boundary

Engineering evidence must prove at least:

- new World generation carries the exact approved Primer and fingerprint changes;
- new Game freezes the new reference and normal GM context sees it once under a non-factual literary boundary;
- first opening sees it through the same frozen Game-local path;
- `project_world_only()` contains neither the Primer nor `literary_style_reference`;
- old frozen Game remains unchanged after Source current advances;
- no Knowledge/Agency/World Evolution factual authority is granted to the reference;
- directly affected Source/final-create/opening/context/G5-04 tests remain green;
- `git diff --check` clean; export validation if production GDScript changes require it.

Kimi may return at most `READY FOR INDEPENDENT REVIEW`. GPT performs Independent Review from actual code/evidence. Owner later performs prose A/B UAT.

## 7. Existing open UAT items

MW-004 remains `IMPLEMENTED — OWNER UAT`; do not silently close it. Its minimal Player Agency principle remains protected:

> **The GM owns freedom to advance the world; the Player owns new meaningful choices for the protagonist.**

MW-003 remains `ENGINEERING PASS — OWNER UAT`; positive visual feedback is not silently converted to Product PASS.

G5-04 remains ACTIVE and MW-002 remains CLOSED. MW-005 is a temporary UAT insertion, not a G5-04 failure. Do not start G5-05 before Owner closes G5-04.
