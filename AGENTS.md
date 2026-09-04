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

Gemini review remains CANCELLED / DO NOT EXECUTE. Review flow: Kimi implementation → GPT Independent Review.

## 2. Current state

```text
G1-G4                                      PASS / CLOSED
G5-01 World Turn / Semantic Materialization PASS / CLOSED
G5-02 Knowledge Provenance                  PASS / CLOSED
G5-03 NPC / Faction Agency                  ACTIVE
G5-03M1R01 Agency Scheduler v0.3            REDESIGN ACTIVE
G5-03M1R01C01                               CLOSED INTO C02
G5-03M1R01C02 Dirty Opportunity             PASS
G5-03M1R02 Semantic-Terminal Wake Ownership ACTIVE — KIMI
G5-03M2 Stable Actor Materialization        NOT YET
G5-04 Event / Priority Evolution            NOT YET
```

Do not start M2/G5-04 before R02 Independent Review PASS.

## 3. Current task

Review:

`docs/g5_03/G5-03M1R01C02_INDEPENDENT_REVIEW.md`

Execute:

`docs/tasks/G5-03M1R02_SEMANTIC_TERMINAL_WAKE_OWNERSHIP_SIMPLIFICATION_TASK.md`

Canonical decision remains:

`Vibe-Coding/my world/architecture/world/G5_AGENCY_SCHEDULER_V0_3_DECISION.md`

## 4. Frozen behavior

Keep:

```text
ordinary accepted turn
→ semantic changes + knowledge only
→ one dirty Agency opportunity
→ semantic worker settles
→ standalone selector over post-semantic latest current world
→ 0..4 stable actors
→ concurrent actor-scoped Agency Cycle
```

The normal wake ownership is now explicit:

```text
generation_completed → mark_dirty only
semantic finished     → consider_agency
```

Do not re-couple Agency Selection into semantic analysis. Do not add timers/polling/retry loops.

Preserve C02 dirty consumption, multi-actor concurrency, actor-private Knowledge/History, current-hash filtering, sibling durable commits/head progression, foreground/Restore cancellation and replay no duplicate.

## 5. Validation rule for R02

Keep this task narrow. Iterate on G5-03 focused tests only. After focused green, run one final affected pass: G5-01 semantic, G4-01 Application lifecycle, G4-07B Application integration, Public d20 Application regression, and `git diff --check`.

Do not rerun unrelated full G2/G3/G5-02 suites absent a concrete failure reason.

**Zero real Provider calls.** Parent real G5-03 proof remains pending honestly.

## 6. Scope ceiling

Do not implement M2 actor registry, Faction agency, G5-04, new SQLite schema/table, UI, Source changes, mechanics changes, G6 or G7.

## 7. Completion

Return:

`READY FOR INDEPENDENT REVIEW — REAL PROVIDER PROOF PENDING`
