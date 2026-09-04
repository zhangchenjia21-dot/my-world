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

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. Correct in-flight Kimi work may finish after expiry.

Gemini review remains CANCELLED / DO NOT EXECUTE.

## 2. Current state

```text
G1-G4                                        PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ENGINEERING PASS / CLOSED
G5-03M1 Multi-Actor Agency v0.3             ENGINEERING PASS / CLOSED
G5-03M2 Stable Actor Registry               ENGINEERING PASS / CLOSED
G5-03M2A Registry Foundation                ENGINEERING PASS / CLOSED
MW-001 Runtime Narrative Actor Materialization PASS / CLOSED
G5-04 Event / Priority Evolution            ACTIVE — OWNER UAT
MW-002 Selective World Evolution Evaluator ENGINEERING PASS / CLOSED
G5-GATE                                     NOT YET
```

Current canonical:

`Vibe-Coding/my world/architecture/world/G5_SELECTIVE_WORLD_EVOLUTION_V0_1_DECISION.md`

MW-002 final packet:

`docs/tasks/MW-002_SELECTIVE_WORLD_EVOLUTION_EVALUATOR_TASK.md`

Independent Reviews:

- `docs/g5_04/MW-002_INDEPENDENT_REVIEW_IR1.md` — CORRECTION REQUIRED
- `docs/g5_04/MW-002_INDEPENDENT_REVIEW_IR2.md` — ENGINEERING PASS / CLOSED

Do not start G5-05 until Owner Product UAT closes G5-04.

## 3. Final MW-002 lineage

```text
Work Item: MW-002
Name: Selective World Evolution Evaluator
Capability-Anchor: G5-04
Revision: 2
Review-Round: IR#2
Triggered-By: MW-002 IR#1
Revision-2 Implementation: 5459c4f8a1d92928129c1d3217a40c6622522496
Revision-2 Evidence: 001106f2c790e70935ea4e54eb721b4aef9e07b4
Verdict: ENGINEERING PASS / CLOSED
```

Same Outcome correction stayed on `MW-002`; do not create C01/R02/PATCH-style identities for historical reference.

## 4. Protected G5-03 behavior

G5-03 remains closed. Protect:

```text
ordinary accepted Player Narrative
→ mark Agency dirty
→ semantic terminal
→ standalone Selector
→ 0..4 current stable NPCs
→ actor-scoped execution
→ optional durable actor actions
```

Also protect:

- Player foreground always wins;
- selector start consumes one dirty opportunity;
- no same-opportunity automatic retry;
- actor-private material / Knowledge / history;
- Program-owned stable actor identity;
- runtime actor accepted-hash currentness;
- no automatic Knowledge from registry/materialization;
- no mutable Source lookup;
- semantic `agency_candidates` remains non-authoritative/dead.

The MW-002 `opportunity_finished` seam is observational only. It covers no-actors, selector terminal, actor-cycle terminal and equivalent immediate terminal such as `already_committed`, while preserving dirty ownership, 0..4 cap, concurrency and retry semantics.

Do not create a generic Faction actor/shared-Knowledge platform merely for symmetry. Current Faction deferral remains protected.

## 5. Frozen G5-04 product semantics

> **The world can move without the Player causing every change, without forcing an event every turn.**

```text
World Independence + Player Spotlight
Persistent != Fully Simulated
Evaluation opportunity != event obligation
```

Frozen runtime order:

```text
visible ordinary Player Narrative accepted
→ semantic lane
→ existing Agency Selector / optional actor cycle
→ Agency opportunity truly terminal
→ one best-effort World Evolution evaluation
→ hold OR at most one causally-ready world event
→ optional durable mutation
→ next GM continuation may consume the current event
```

The Player turn is the scheduling opportunity, not causal authority. Opening-only GM generation creates no opportunity. No offline/wall-clock progression.

## 6. Protected MW-002 behavior

Do not reopen absent a concrete regression/new consumer:

- `hold` is valid, creates no fake mutation and does not auto-retry the same runtime opportunity;
- at most one event per evaluator opportunity;
- priority judgment is model-owned; no numeric priority, keyword gate, persistent pressure queue, fixed cadence, random-event engine or universal event taxonomy;
- intentional stable-NPC choices remain G5-03 Agency territory;
- Program owns deterministic world-event / mutation / node IDs;
- identity binds exact Game + opportunity turn/hash + evaluated base head;
- storage remains additive under `living_world.v0.1`; no SQLite migration/table;
- committed event replay is idempotent;
- current consumers require exact accepted turn/hash match;
- new ordinary foreground, Public-d20 control start, Restore/progress switch, shutdown or unrelated head change invalidates uncommitted evolution work;
- late callbacks cannot commit obsolete work;
- evaluator input uses frozen Game-local **World-only** T0 authority + bounded current world consequences;
- `opening_supplement`, protagonist control mode, Character-private Source and Actor Knowledge Provenance are excluded from evaluator causal input;
- mutable Source Library current is never queried during gameplay;
- first real consumer is next GM continuation Context;
- event truth is omniscient GM world truth, not automatic Player or actor knowledge;
- no automatic G5-02 Knowledge creation;
- no forced visible event announcement;
- no generic Faction platform / universal simulator / offline evolution / UI / G5-05 work.

## 7. Engineering evidence

Revision-2 committed evidence reports:

- G5-04 focused: **144 PASS / 0 FAIL**;
- G5-03 Scheduler/Cycle regression: **0 FAIL**;
- G4-08M1 Public-d20 regression: **0 FAIL**;
- G4-07A continuation/context regression: **0 FAIL**;
- G3-04 Save/Restore regression: **PASS**;
- `git diff --check`: clean;
- real Provider calls = 0.

GPT IR#2 independently inspected the actual correction diff, production seams, focused test source and evidence. Reviewer environment had no Godot executable and the final commit had no external CI statuses, so GPT did not independently rerun Godot.

## 8. Current Owner UAT gate

G5-04 is not closed yet. Owner UAT is mandatory because automated tests cannot prove pacing quality.

UAT must counterpose:

1. **Quiet / Life Loop** — no causally ripe world process. Expected: evaluator can hold; no artificial escalation; free activity / downtime / relationships retain breathing room.
2. **Genuine ripe pressure** — a real T0/current world pressure is ready even without direct Player causation. Expected: one credible consequence advances, remains durable, and subsequent GM Narrative uses/surfaces it naturally without feeling like a forced random event.

Only Owner Product PASS closes G5-04. Until then:

- do not mint/start G5-05 work;
- do not reinterpret Engineering PASS as Product PASS;
- do not change the frozen G5-04 architecture merely to optimize a UAT scenario.

## 9. Other protected state

G5-03 closeout / Faction deferral:

`Vibe-Coding/my world/architecture/world/G5_03_AGENCY_CLOSEOUT_AND_FACTION_DEFERRAL_V1_0_DECISION.md`

Parent real G5-03 Provider proof remains honestly:

`PENDING / EXTERNAL PROVIDER UNAVAILABLE`

Do not switch Provider merely to manufacture evidence.