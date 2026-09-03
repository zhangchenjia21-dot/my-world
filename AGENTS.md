# my world — Repository Agent Rules

Status: current repository instruction  
Scope: entire repository unless a deeper `AGENTS.md` narrows a subtree.

## 1. Authority / freshness

Authority order:

1. Owner current explicit instruction.
2. `Vibe-Coding/AGENTS.md`.
3. current Product / Architecture / Roadmap / Status under `Vibe-Coding/my world/`.
4. current architecture decisions.
5. this `AGENTS.md` + current Task Packet.
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

Temporary through 2026-09-06 23:59 (+08:00): Kimi owns all code-changing implementation tasks; GPT remains semantic owner/reviewer. Correct in-flight Kimi work may finish after expiry.

Owner has temporarily declined Gemini adversarial review. `docs/tasks/G5-03M1R01_GEMINI_ADVERSARIAL_REVIEW_TASK.md` is CANCELLED / DO NOT EXECUTE. Review flow remains Kimi implementation → GPT Independent Review.

## 2. Standing Provider rule

Canonical: `Vibe-Coding/my world/architecture/foundation/REAL_PROVIDER_VALIDATION_STANDING_AUTHORIZATION.md`.

Bounded validation explicitly required by an approved packet is pre-authorized. No fallback, hidden Provider/model switch, open-ended retry or repeated Owner confirmation. External Provider outage may leave reality proof pending without blocking reviewable code from commit/push.

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
G5-03M1 Multi-Actor Agency                  REDESIGN ACTIVE
G5-03M1C01                                  HISTORICAL PARTIAL PASS
G5-03M1C02                                  SUPERSEDED / DO NOT EXECUTE
G5-03M1R01 Agency Scheduler v0.3            CORRECTION REQUIRED
G5-03M1R01C01 Scheduler Lifecycle/Snapshot  ACTIVE — KIMI
G5-03M2 Stable Actor Materialization        NOT YET
G5-04 Event / Priority Evolution            NOT YET
```

Do not execute old C02 or Gemini review packets. Do not start M2/G5-04 before R01C01 Independent Review PASS.

## 4. Current execution task

Independent Review:

`docs/g5_03/G5-03M1R01_INDEPENDENT_REVIEW.md`

Current correction:

`docs/tasks/G5-03M1R01C01_SCHEDULER_PRODUCTION_LIFECYCLE_CURRENT_SNAPSHOT_CORRECTION_TASK.md`

Canonical decision remains:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## 5. Accepted v0.3 architecture

Do not redesign:

```text
accepted ordinary turn
→ semantic lane handles changes + knowledge only
→ standalone Agency Scheduler marks dirty
→ once foreground idle + semantic queue settled
→ standalone selector over latest current world snapshot
→ validated 0..4 stable actors
→ existing concurrent actor-scoped Agency Cycle
```

Preserve:

- multi-actor concurrent actor requests;
- actor-private Source/current Knowledge/own history;
- serialized sibling durable commits and expected-head progression;
- foreground/Restore cancellation;
- replay no duplicate;
- no automatic Player/other-actor knowledge grant.

## 6. Current blocking correction seam

R01C01 fixes only production Scheduler lifecycle/current snapshot:

1. production durable ordinary-turn acceptance must actually call Scheduler dirty wiring; tests must not be the only caller of `mark_dirty()`;
2. terminal `AgencyCycleRuntimeProcess` must be cleaned so later accepted turns can run future Agency cycles;
3. selector `Recent World Changes` must exclude semantic records whose source GM hash no longer matches current accepted Conversation;
4. selector/cycle terminal cleanup must not strand Scheduler or create an automatic retry loop.

Do not re-couple Agency selection into semantic analysis.

## 7. Provider rule for R01C01

**Zero real Provider calls.** This correction is deterministic production wiring/lifecycle only. Parent real G5-03 proof remains pending honestly.

## 8. Scope ceiling

Do not implement M2 actor registry, Faction agency, G5-04 scheduler, generic universe polling, new SQLite schema/table, UI, Source changes, mechanics/d20 changes, G6 or G7.

## 9. Completion

Kimi runs focused + regression tests, `git diff --check`, writes evidence, commits/pushes and returns:

```text
READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING
```
