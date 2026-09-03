# TASK｜G5-01M1C02｜Restore Timeline Isolation Correction

Type: **focused backend correction / correction-01**  
Owner: **KIMI**  
Reviewer / semantic owner: **GPT**  
Parent: **G5-01M1 World Turn / Semantic Materialization Spine**  
Prerequisite: `G5-01M1_INDEPENDENT_REVIEW.md`  
Return ceiling: **READY FOR INDEPENDENT REVIEW**

## 0. Temporary execution routing

Owner temporary routing is active through 2026-09-06 23:59 (+08:00):

`Vibe-Coding/my world/architecture/foundation/TEMPORARY_EXECUTION_ROUTING_2026-09-03_TO_2026-09-06.md`

This code-changing correction is assigned to **Kimi**. Do not wait for Codex quota recovery and do not reimplement G5-01M1 from scratch.

## 1. Read first

Refresh both `main`s, then read only the minimum set:

1. repository `AGENTS.md`;
2. `docs/g5_01/G5-01M1_INDEPENDENT_REVIEW.md`;
3. this packet;
4. `Vibe-Coding/my world/architecture/world/G5_WORLD_TURN_SEMANTIC_MATERIALIZATION_V0_1_DECISION.md`;
5. current `src/世界回合/L2_流程层/语义物化流程.gd`;
6. current Game Runtime Restore signal/seam and existing G5-01 focused/timeline tests.

Do not read unrelated project depth by default.

## 2. Outcome

Fix one specific Timeline isolation defect without changing the G5-01 architecture:

> A committed Restore/Recovery must establish a new current timeline boundary for the semantic worker. Ephemeral analysis/attempt state from an abandoned future must not suppress or mutate semantic materialization in the restored timeline.

Protected principle:

> **Player owns the timeline.**

## 3. Concrete defect

Current `SemanticMaterializationProcess` keeps timeline-local in-memory state:

```text
_attempted_versions
_queue
_active
```

Current Game Runtime emits `restore_completed` after a durable progress switch, but the semantic worker does not react to it.

As a result, a semantic version attempted in a future branch can remain in `_attempted_versions` after Restore and incorrectly suppress the same legitimate accepted version if the player later reaches it again.

## 4. Required behavior after committed Restore / Recovery

Use the existing Runtime progress-switch signal/seam. Do not modify SQLite schema or Save/Restore authority.

After `restore_completed`:

1. **abandoned-future attempt suppression must not survive** into the restored timeline;
2. queued semantic work created before the Restore must be dropped/quarantined;
3. an active pre-Restore semantic request must become ineligible to commit into the restored timeline;
4. if transport cancellation is available, cancel the stale active semantic request best-effort, without affecting accepted Conversation;
5. even if a late `completed` callback arrives after Restore, the old request must not commit a World Turn;
6. Restore itself must not automatically launch a semantic Provider request;
7. existing matching World Turn records in restored `world_state` remain authoritative/idempotent through durable lookup;
8. a later newly accepted version in the restored timeline is evaluated normally.

A small timeline epoch/generation token or equivalent explicit invalidation design is acceptable. Keep it local to the World Turn process unless actual code proves a narrower existing seam is insufficient.

## 5. Required regression scenario A — exact future replay after Restore

Add a deterministic controlled/SQLite test proving:

```text
Save at timeline T
→ accept future Turn N with player/GM pair P/G
→ semantic attempt/materialization occurs
→ Restore to T, removing future Turn N + World Turn
→ create a new accepted Turn N with the exact same P/G text
→ semantic worker sends a new analysis request for the restored timeline
→ valid result can commit a World Turn again
```

The test must fail against the pre-correction implementation because `_attempted_versions` retains the abandoned future version.

Do not weaken stable mutation identity. The restored timeline may legitimately reuse the same deterministic World Turn/mutation identity because the old future node is no longer current; Persistence/Timeline semantics remain authoritative.

## 6. Required regression scenario B — active analysis cannot cross Restore

Add a deterministic test proving:

```text
accepted future turn
→ semantic request starts but has not completed
→ Restore/Recovery commits an older timeline
→ old Provider request later completes (or emits a late callback)
→ no World Turn from that stale request is committed to restored current world
```

If the implementation cancels the transport, the test should still exercise the late-callback safety/invalidation seam rather than trusting cancellation alone.

Also prove queued pre-Restore work does not continue after Restore.

## 7. Preserve existing semantics

Must remain true:

- visible Narrative is accepted independently of semantic analysis;
- exactly one semantic-analysis attempt per newly accepted ordinary version within the active timeline;
- GM-only Opening skipped;
- malformed/transport/empty analysis fail-soft;
- no automatic recovery loop;
- no cross-provider fallback;
- no Source mutation;
- no narrative JSON/header/sentinel gate;
- no universal entity/fact ontology;
- no G5-02/03/04 scope;
- no UI or persistence schema change;
- current Context projection still requires committed/current matching truth.

## 8. Real Provider validation

**Do not make a real Provider call for this correction.**

The parent M1 real vertical remains:

`PENDING / EXTERNAL PROVIDER UNAVAILABLE`.

This correction is fully provable with deterministic controlled + SQLite integration tests. Do not consume Provider attempts to prove a Restore epoch invariant.

## 9. Required tests

At minimum run:

- updated `tests/g5_01/世界回合语义物化测试.gd` if touched/relevant;
- updated `tests/g5_01/世界回合时间线恢复测试.gd` or a narrowly named additional Restore isolation test;
- directly affected G3 Save/Restore regression;
- directly affected G4 continuation/context regression if the implementation touches those seams.

Run `git diff --check` and explicitly record PASS.

## 10. Scope ceiling

Expected production change is narrow, preferably limited to:

```text
src/世界回合/L2_流程层/语义物化流程.gd
```

plus focused tests/evidence.

A tiny L0/L1 helper adjustment is allowed if truly necessary. Do not modify `src/runtime/当前游戏会话运行时.gd` merely to add a new Restore mechanism: the existing `restore_completed` signal already exists. If that existing seam proves insufficient, STOP and return the concrete reason to GPT before expanding scope.

Protected:

- `src/domain/会话.gd` semantics;
- `src/ui/**`;
- persistence schema/migrations;
- Source code/schema/generation;
- Runtime Model Settings;
- Public d20;
- G6 visuals.

## 11. Evidence

Create/update a focused evidence file under `docs/g5_01/`, for example:

`G5-01M1C02_RESTORE_TIMELINE_ISOLATION_EVIDENCE.md`

Record:

- START_HEAD / IMPLEMENTATION_HEAD / FINAL_HEAD;
- exact changed paths;
- defect reproduction before fix or a test description that demonstrably targets it;
- post-fix exact-future-replay result;
- active/queued pre-Restore invalidation result;
- directly affected regressions;
- `git diff --check` PASS;
- explicit statement: **no real Provider call was made**;
- explicit statement: parent M1 real Provider vertical remains pending.

## 12. Completion boundary

Commit and push to `origin/main`, then return only:

```text
READY FOR INDEPENDENT REVIEW
```

Do not declare G5-01M1 Engineering PASS, G5-01 Product PASS, G5-02 active, or the real Provider vertical passed. GPT owns review/transition; Owner owns product verdict.
