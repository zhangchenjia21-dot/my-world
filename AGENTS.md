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

## 2. Standing Provider rule

Canonical: `Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`.

Bounded real validation explicitly required by an approved packet is pre-authorized. No repeated Owner confirmation, fallback, hidden Provider/model switch, open-ended retry or secret disclosure.

External Provider outage may leave reality proof pending but does not block reviewable code from commit/push.

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
                                             PARTIAL PASS / CLOSED INTO C02
G5-03M1C02 Semantic-vs-Agency Currentness Separation
                                             ACTIVE — KIMI
G5-03M2 Stable Actor Materialization        NOT YET
G5-04 Event / Priority Evolution            NOT YET
```

Do not start G5-03M2/G5-04 before C02 passes GPT Independent Review.

## 4. Current execution task

Review:

`docs/g5_03/G5-03M1C01_INDEPENDENT_REVIEW.md`

Current packet:

`docs/tasks/G5-03M1C02_SEMANTIC_AGENCY_CURRENTNESS_SEPARATION_CORRECTION_TASK.md`

Canonical Agency design remains:

`Vibe-Coding/my world/architecture/world/G5_MULTI_ACTOR_AGENCY_CYCLE_V0_2_DECISION.md`

Owner: **KIMI** under temporary routing. Reviewer / semantic owner: **GPT**.

## 5. C02 blocking seam

Do not conflate these predicates:

```text
semantic source version is still accepted
!=
Agency handoff is still current
```

Required semantics:

```text
source turn still exists + same accepted GM hash
→ valid G5-01 changes / G5-02 knowledge may materialize

even if a newer foreground turn has started/finished
→ suppress old agency_candidates
→ do not erase accepted semantic truth
```

Agency handoff additionally requires source turn still latest + foreground idle + same hash.

Actual regenerate/correction hash replacement remains stale for both semantic truth and Agency.

## 6. Selection-only handoff

A valid current result may be:

```json
{"changes":[],"knowledge_events":[],"agency_candidates":["stable-npc-id"]}
```

This must be able to start Agency without creating a fake semantic mutation.

Every successful semantic terminal result that can carry Agency Selection must preserve exact:

- `source_turn_index`;
- `source_gm_sha256`;
- validated/suppressed `agency_candidates`;
- `agency_dropped` where applicable.

This also applies when parsed knowledge exists but all knowledge events are dropped by actor allowlist.

Application keeps its own latest/hash/foreground-idle validation before `start_cycle()`.

## 7. Preserve passing M1/C01 behavior

Do not regress:

- one existing semantic-analysis request performs selection; no mandatory selector call;
- 0..4 selected stable Guaranteed NPCs in M1;
- separate concurrent actor-scoped execution requests;
- actor private-knowledge isolation;
- serialized durable sibling commits;
- production Restore invalidation;
- commit-time source/head guards;
- current-hash Knowledge/Agency History filtering;
- stale same-turn cycle replacement;
- replay no duplicate committed actor execution;
- foreground never waits for Agency;
- no SQLite schema/UI/Source/Faction/M2/G5-04 scope.

## 8. Provider rule for C02

**No real Provider call.** Parent M1 real proof remains `PENDING / EXTERNAL PROVIDER UNAVAILABLE`.

## 9. Completion

Kimi runs deterministic/integration regressions, `git diff --check`, writes evidence, commits/pushes, and returns:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```

Do not declare M1/G5-03 PASS or start M2 early.
