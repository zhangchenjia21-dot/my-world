# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / Freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and current task packet.
6. verifiable implementation/tests/current HEAD.

Before authoritative work, refresh both `main`s; never overwrite unknown dirty/newer work.

Execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

## 2. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4-01 Application Shell / Lifecycle   PASS / CLOSED
G4-02R1 Source semantic re-audit      PASS / CLOSED
G4-03 Managed Local Source Library    PASS / CLOSED
G4-04 Multi-Game / Game Library       PASS / CLOSED
G4-05 New Game Wizard                 PASS / CLOSED
G4-06 Atomic Final Create             PASS / CLOSED
G4-07 First Playable A                PASS / CLOSED
G4-08 Expansion Pack v0.1             PASS / CLOSED
G4-09 First Playable B                PASS / CLOSED
G4-09UATB Owner Product UAT           PASS / CLOSED
G4-10 Runtime Asset Resolution        DEFERRED / MOVED TO G6
G4-10M1 Mechanism                     SUPERSEDED / DO NOT EXECUTE
G4-11 Two Primary Asset Families      ACTIVE — CLOSEOUT
G4-11P1 Engineering Reality Prep      PASS / CLOSED
G4-11UAT Owner Reality Test           PASS / CLOSED
G4-11C01 Narrative Voice Soft Prompt  ACTIVE — CODEX
G4-GATE                               HOLD — awaiting C01 review only
```

Do not start G5 before G4-11C01 Independent Review + formal G4-GATE closeout.

## 3. Current task — G4-11C01 Narrative Voice Soft Prompt Tuning

Formal packet:

`docs/tasks/G4-11C01_NARRATIVE_VOICE_SOFT_PROMPT_TUNING_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_NARRATIVE_VOICE_SOFT_PROMPT_TUNING_DECISION.md`

Current owner: **CODEX**. Reviewer / semantic owner: **GPT**.

Expected production scope:

```text
src/context/上下文组装器.gd
+ focused tests/evidence
```

Owner has already passed the G4-11 two-family reality product gate. This task addresses only a non-blocking finding that different worlds still converge too strongly toward the same general narrative prose voice.

The intended change is one generic shared-GM soft creative instruction encouraging language texture to follow current World / Character / scene naturally.

No standalone Owner UAT or real Provider run is required for this micro-fix.

Return ceiling: **READY FOR INDEPENDENT REVIEW**.

## 4. C01 hard boundaries

Core invariant:

> **Narrative style is guidance, not an acceptance gate.**

Do not add:

- required narrative format;
- mandatory vocabulary;
- genre keyword validators;
- style similarity scoring/thresholds;
- output classifiers;
- reject/retry/regenerate because prose style is judged insufficient;
- second-model style review;
- world-specific hardcoded templates;
- Provider/model-settings changes;
- Source package/schema/generation changes;
- d20 changes;
- persistence/SQLite changes;
- G5 world semantics.

Tests may assert prompt projection only. They must not assert that model output contains Han/fantasy keywords or a required prose style.

## 5. G4-11 accepted product/engineering truth

Owner result:

`docs/g4_11/G4-11UAT_OWNER_RESULT.md`

Owner confirmed the two worlds are materially different. Narrative prose convergence is a non-blocking quality finding only.

P1 engineering evidence remains accepted:

- real current selected Provider for both family verticals;
- Opening + 3 durable continuations each;
- Save / close / exact reopen / Continue;
- distinct Game IDs and SQLite files;
- A→B→A→B→A isolation;
- exact Source ancestry under newer task-owned Source-current publication;
- no opposite-family Context leakage;
- no visual dependency;
- Owner production surfaces unchanged.

Do not reopen this evidence absent a concrete regression.

## 6. Visual deferral — protected current route

Owner explicitly deferred visual runtime work to G6.

```text
G4-10 Runtime Asset Resolution = DEFERRED / MOVED TO G6
G4-10M1 = SUPERSEDED / DO NOT EXECUTE
```

Do not implement portrait / scene / authored-map loading, image pipeline, visual resolver or map presentation during C01/G5.

## 7. Protected Model Freedom / Narrative Responsiveness truth

```text
Model Freedom First
+
Visible Narrative First
+
Canonical Commit Behind a Turn Finalize Barrier
```

Public d20 semantics and Runtime Model Settings are PASS/CLOSED and must not be reopened absent a concrete regression.

## 8. After C01

If GPT Independent Review passes C01:

```text
G4-11C01 PASS / CLOSED
→ G4-11 PASS / CLOSED
→ G4-GATE PASS
→ G4 CLOSED
→ GPT shapes G5-01
```

Current roadmap title for the first G5 task:

`G5-01 Minimum Playable T0 + World Turn / Semantic Materialization`

Do not implement G5-01 from the title alone. GPT must first freeze its semantics/ownership/acceptance boundary.
