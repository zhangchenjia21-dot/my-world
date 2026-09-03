# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire `zhangchenjia21-dot/my-world` repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Resolve authority in this order:

1. Owner current explicit instruction.
2. `zhangchenjia21-dot/Vibe-Coding/AGENTS.md`.
3. current Product / Principles / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. relevant current architecture decisions.
5. this repository `AGENTS.md` and current task packet.
6. verifiable implementation/tests/current HEAD.

Refresh both `main`s before authoritative work. Never overwrite unknown dirty/newer work.

Long-term routing:

```text
GPT        → meaning / architecture / governance / task shaping / Independent Review
Codex      → backend / mechanism / build-launch / validation implementation
Kimi       → frontend / UI / interaction implementation
Grok Build → search / external research / evidence discovery
Owner      → Product UAT / explicit product verdict
```

### Temporary routing through 2026-09-06 23:59 (+08:00)

```text
GPT        → semantics / architecture / governance / final Independent Review
Kimi       → all code-changing implementation tasks, temporarily substituting for Codex
Grok Build → external research / evidence support / secondary cross-check
Owner      → Product UAT / verdict
```

Auto-expiry: 2026-09-07 00:00 (+08:00). Correct in-flight Kimi work may finish under its issued packet.

## 2. Standing authorization for bounded real Provider validation

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`

If an approved Task Packet explicitly requires bounded real selected-Provider validation, it is already Owner-authorized within the packet's exact attempt/call ceiling. Do not pause to ask Owner again.

No open-ended loops, hidden Provider/model switching, billing/account changes, secret disclosure or new external services.

If bounded attempts are exhausted by external Provider timeout/unavailability and offline/integration gates are green, commit/push reviewable work, mark real proof pending, and return for Independent Review. Provider availability may block reality proof; it does not block code review.

## 3. Current state

```text
G1 Foundation                               PASS / CLOSED
G2 AI Conversation Spine                    PASS / CLOSED
G3 Persistence / Save / Timeline            PASS / CLOSED
G4 Primary Source Assets & Local Game       PASS / CLOSED
G4-10 Runtime Asset Resolution              DEFERRED / MOVED TO G6

G5 World Semantics & GM Runtime             ACTIVE
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ACTIVE
G5-03M1 old single-NPC packet               SUPERSEDED / DO NOT EXECUTE
G5-03M1 Multi-Actor Agency Cycle            CORRECTION REQUIRED
G5-03M1C01 Agency Currentness + Timeline Isolation
                                             ACTIVE — KIMI
G5-03M2 Stable Actor Materialization        NOT YET
G5-04 Event / Priority Evolution            NOT YET
```

Do not start G5-03M2 or G5-04 before C01 passes Independent Review.

## 4. Current execution task

Independent Review:

`docs/g5_03/G5-03M1_INDEPENDENT_REVIEW.md`

Correction packet:

`docs/tasks/G5-03M1C01_AGENCY_CURRENTNESS_TIMELINE_ISOLATION_CORRECTION_TASK.md`

Canonical decision remains:

`Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`

Owner: **KIMI** under temporary routing. Reviewer / semantic owner: **GPT**.

The multi-actor architecture is accepted and must not be redesigned:

```text
one semantic-analysis request
→ 0..4 validated stable NPC agency candidates
→ one isolated execution request per selected actor
→ selected requests may progress concurrently
→ several valid sibling actions may durably commit in one Agency Cycle
```

No round-robin fallback.

## 5. Blocking correction seam — currentness / timeline isolation

C01 must fix these concrete production gaps:

1. a semantic result from Turn A must not start Agency after the player has already begun/advanced Turn B;
2. production `restore_completed` / progress-switch lifecycle must invalidate active uncommitted Agency work;
3. every actor commit must verify current accepted source hash/version and distinguish same-cycle sibling head progression from unrelated head changes;
4. Agency Selection and per-actor Execution may only receive **current-hash-matching** durable Knowledge Provenance and Agency History, never stale records from superseded/regenerated Narrative;
5. a new version at the same turn index must replace a stale cycle instead of merging a new action into the old cycle hash;
6. already committed matching actor action must not be re-executed on replay/consideration.

These are one correction seam: **old world versions must never regain authority through asynchronous Agency work**.

## 6. Foreground and timeline invariants

Protected rules:

> **Foreground player freedom outranks background agency completion.**

> **Player owns the timeline.**

If player foreground advances, Restore/Recovery switches progress, source accepted GM hash changes, session closes, or an unrelated world mutation changes the current head:

- remaining uncommitted Agency work becomes invalid;
- best-effort cancel transports;
- late callbacks cannot commit.

Already committed sibling actions before the boundary remain durable in the timeline where they committed.

Within one still-current Agency Cycle, a successful sibling action may advance the cycle-owned expected head and must not stale other siblings.

## 7. Actor knowledge boundary

Every selector actor block and every actor execution request must include only that actor's current material:

- exact stable ID/display name;
- Game-local Character Source/T0 material;
- current-hash-matching G5-02 Knowledge Provenance for that actor only;
- current-hash-matching bounded recent Agency History for that actor only.

Do not expose Player-only / another actor's private knowledge, including stale records whose source GM hash no longer matches current Conversation.

Protected principle:

> **GM omniscience must not become actor omniscience.**

## 8. Passing M1 semantics to preserve

Do not regress:

- selection reuses the existing G5-01/G5-02 semantic request;
- bad/absent `agency_candidates` does not invalidate valid changes/knowledge/Narrative;
- 0..4 validated stable Guaranteed-NPC candidates in M1;
- concurrent per-actor Provider executions;
- serialized atomic world commits through existing `commit_world_mutation_durably(...)`;
- `hold` / malformed / wrong actor / Provider failure fail-soft;
- agency world truth is not automatic Player disclosure or other-actor knowledge;
- no hidden d20/check semantics;
- no SQLite schema/table;
- no Faction/M2/G5-04/UI/G7 scope.

## 9. Provider rule for C01

**Do not make any real Provider call in this correction.**

The parent bounded real attempt was already consumed and timed out before feature-specific Agency proof. C01 is deterministic only.

Real G5-03 feature proof remains:

```text
PENDING / EXTERNAL PROVIDER UNAVAILABLE
```

## 10. Completion

Kimi commits/pushes the focused correction and returns:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

GPT owns Independent Review. Do not declare G5-03M1/G5-03 PASS and do not start M2/G5-04 early.
