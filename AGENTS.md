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

Long-term execution routing:

```text
GPT        → Meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

### Temporary execution routing｜effective through 2026-09-06

Canonical temporary Owner decision:

`Vibe-Coding/my world/architecture/foundation/TEMPORARY_EXECUTION_ROUTING_2026-09-03_TO_2026-09-06.md`

Through 2026-09-06 23:59 (+08:00):

```text
GPT        → Meaning / architecture / governance / task shaping / final Independent Review
Kimi       → primary owner for all code-changing implementation tasks, including temporary Codex substitution
Grok Build → external research / evidence discovery / Provider-reality support / secondary technical cross-check
Owner      → Product UAT / explicit product verdict
```

The override auto-expires at 2026-09-07 00:00 (+08:00). Correct in-flight Kimi work may finish under its issued packet.

## 2. Standing authorization for required real Provider validation

Canonical Owner decision:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

Bounded real Provider validation is pre-authorized when an approved Task Packet explicitly requires it and the run remains inside the packet's stated ceiling using the current approved runtime Provider/profile.

Do **not** pause mid-task to ask Owner again merely because the already-specified validation makes a model API call.

The authorization does not permit open-ended loops, hidden Provider/model switching, billing/account changes, sending secrets/unrelated private data, or new external services outside approved scope.

If bounded attempts are exhausted by external Provider timeout/unavailability and offline/integration gates are green, commit/push reviewable work, mark real proof pending, and return for Independent Review. External Provider availability may block reality proof; it does not block code review.

## 3. Current state

```text
G1 Foundation                         PASS / CLOSED
G2 AI Conversation Spine              PASS / CLOSED
G3 Persistence / Save / Timeline      PASS / CLOSED
G4 Primary Source Assets & Local Game Creation
                                      PASS / CLOSED
G4-10 Runtime Asset Resolution        DEFERRED / MOVED TO G6
G4-11 Two Primary Asset Families      PASS / CLOSED
G4-11C01 Narrative Voice Soft Prompt  PASS / CLOSED
G4-GATE                               PASS

G5 World Semantics & GM Runtime       ACTIVE
G5-01 World Turn / Semantic Materialization
                                      PASS / CLOSED
G5-02 Knowledge Provenance            PASS / CLOSED
G5-02M1 Known-Actor Knowledge Spine   ENGINEERING PASS / CLOSED
G5-02M1C01 Actor Roster + Recent Knowledge Projection
                                      PASS / CLOSED
G5-02 real Provider vertical          HISTORICAL GAP / EXTERNAL PROVIDER UNAVAILABLE

G5-03 NPC / Faction Agency            ACTIVE
G5-03M1 Stable Guaranteed-NPC Agency  ACTIVE — KIMI
G5-04 Event / Priority Evolution      NOT YET
G5-GATE                               NOT YET
```

Do not start G5-04 before G5-03M1 Independent Review and GPT decides whether a second Faction slice is required for G5-03 closeout.

## 4. Current execution task — G5-03M1

Task packet:

`docs/tasks/G5-03M1_STABLE_NPC_INDEPENDENT_AGENCY_TASK.md`

Canonical decision:

`Vibe-Coding/my world/architecture/world/G5_STABLE_NPC_AGENCY_V0_1_DECISION.md`

Owner: **KIMI** under temporary routing. Reviewer / semantic owner: **GPT**.

Product question:

> Can a stable Guaranteed NPC independently act from its own Source + durable knowledge, without waiting for the player to explicitly trigger that NPC and without turning background Provider latency into a foreground input gate?

## 5. G5-03M1 protected ordering

```text
Player action
→ free-form visible GM Narrative
→ durable Conversation acceptance
→ existing G5-01/G5-02 semantic lane reaches terminal state
→ optional background Stable-NPC agency evaluation
→ optional atomic agency world mutation
```

Agency is **not** a Turn Finalize Barrier.

If the player starts the next Conversation attempt while agency is queued/active, stale agency must be cancelled/invalidated rather than delaying foreground Narrative. A late callback after invalidation must not commit.

Malformed/hold/provider failure/cancelled agency is fail-soft: no fake world mutation, no Narrative failure, no retry loop, no fallback.

## 6. Actor scope / cognition

G5-03M1 evaluates only stable `guaranteed_npcs[*].local_character_id` actors. Player Character is not autonomously controlled by this lane.

Actor-scoped request material is limited to:

- selected NPC's exact Game-local Character Source projection;
- that NPC's own committed/current G5-02 Knowledge Provenance;
- that NPC's own bounded prior agency history;
- minimal stable identity metadata.

Do not pass full omniscient GM/world Context or another actor's private post-T0 knowledge as a shortcut.

No incidental/emergent NPC identity, Faction identity/agency, universal actor graph or G5-04 priority scheduler in M1.

## 7. Durable agency semantics

A valid `decision=act` may persist one bounded agency record under existing `world_state.living_world`, tied to stable source turn/hash/head/actor identity, using the existing atomic `commit_world_mutation_durably(...)` seam.

A `hold`/invalid/cancelled result creates no fake mutation.

Later omniscient GM Context may receive a bounded `Independent Actor Actions` projection. That projection is GM world reference only; it is not automatic knowledge for every actor and not automatic human-player disclosure.

Do not add SQLite schema/tables.

## 8. Timeline / stale-work safety

Agency is intentionally asynchronous. Before commit, stale work must be rejected if foreground Conversation advanced/started, active world head changed, source GM hash changed, Restore/Recovery switched progress, or session is closing.

Use existing Conversation `attempt_started` and Runtime `restore_completed` seams or an equivalently narrow existing seam. Best-effort transport cancellation is not sufficient without late-callback invalidation.

## 9. G5-01 / G5-02 remain protected

G5-01 and G5-02 are PASS/CLOSED.

Do not reopen their architecture absent a concrete regression.

Protected distinctions remain:

```text
Narrative acceptance != semantic-analysis success
Game / World Truth != actor knowledge != human-player disclosure != omniscient GM Context
```

No Narrative JSON/header/sentinel gate, output classifier, knowledge keyword gate, generic Knowledge Graph, Source mutation, persistence schema migration, Runtime Model Settings/Public d20 change, or G6 visual work.

## 10. Real Provider proof

After deterministic/integration gates are green, G5-03M1 may make at most **one** task-owned real selected-Provider agency request under the standing authorization.

Prefer stubbing unrelated Opening/foreground prerequisites so the bounded call is spent on the feature-specific agency request.

Feature-specific PASS requires a valid stable-actor `act` result, one durable agency record/effect, and later GM Context projection.

`hold`, malformed response, timeout or Provider outage is inconclusive/pending; do not loop until PASS, switch Provider or add fallback.

## 11. Completion

Kimi commits/pushes implementation/tests/evidence and returns:

```text
READY FOR INDEPENDENT REVIEW
```

or, if the single real feature proof is pending/inconclusive:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

GPT owns Independent Review and the decision whether G5-03 needs a later Faction slice. Do not start G5-04 early.
