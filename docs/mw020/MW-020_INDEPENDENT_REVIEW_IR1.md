# MW-020 Independent Review — IR1

Date: 2026-09-08  
Work item: **MW-020｜Core Context Budget Accounting Correction**  
Reviewer: **GPT**  
Verdict: **ENGINEERING PASS_WITH_NOTES**  
Product verdict: **not applicable as a standalone gate; integrate before fresh Package-0 Owner build**

## 1. Review identity

- Formal base: `f5dea508be2db5904c2d5ebc726b6f130d8c57fe`
- Task starting HEAD: `3eb663b1a348f41c98b8e3be9ac4796e8ebedb9a`
- Implementation HEAD: `b423a5b3c7cdecd1d836920f1b053e3675a3bb0e`
- Submitted final candidate: `9677f6987312230facb351964f6d800748618cf2`
- Task branch: `mw-020-context-budget-accounting`
- Task Packet: `docs/tasks/MW-020_CORE_CONTEXT_BUDGET_ACCOUNTING_TASK.md`

Both implementation and governance mains were refreshed before review. Implementation `main` remained exactly the Formal Base; governance remained on the active MW-020 route. No newer authority superseded the task.

## 2. Independent scope inspection

Independent Base → Implementation comparison confirms the only production file changed is:

`src/世界回合/L1_器件层/世界回合上下文投影器.gd`

Other implementation-commit changes are the published Task Packet plus MW-020 tests/runner. Evidence and return-report files are added only in the final evidence commit.

No Provider prompt, storage/schema, recommendation, People, Important Experiences, Debug Mode, Context Orchestrator, semantic retrieval/ranking or unrelated architecture-debt refactor is present.

## 3. Root-cause / correction review

The pre-task source had two accounting defects in the same projection path:

1. initial World Changes selection counted only block bodies while the rendered heading/separators also consume the 16,000-character budget;
2. later Agency/Evolution checks combined a parallel `projected_chars` body counter with an already assembled `text`, thereby counting earlier world-change bodies twice.

The implementation removes the parallel body counter and makes the actual assembled String the budget truth.

### Initial World Changes

For every candidate newest-first block set, production now builds the exact candidate output:

- Materialized World Changes heading;
- actual joined blocks;
- actual block separators.

It accepts only when that exact String length is `<= MAX_PROJECTED_CHARS`.

This preserves the existing newest-first / whole-block / break-on-nonfit policy while fixing the accounting only.

### Later sections

A local `_join_section(context_text, section)` exactly mirrors final assembly:

- no separator for the first non-empty section;
- exactly `\n\n` between two non-empty sections;
- omitted/empty sections spend no separator budget.

Knowledge, Agency and Evolution each test:

`_join_section(current_context_text, candidate_section).length() <= 16000`

and the caller then uses the same helper to perform the actual append.

Therefore the measured representation and the rendered representation cannot diverge on heading/separator cost.

## 4. Acceptance checks

### AC-01 audit-equivalent Agency inclusion — PASS

Committed focused evidence exercises real isolated SQLite/runtime durability and actual later GM continuation-message assembly.

A valid current world-change context of 10,000 characters plus a durable Agency action produces a corrected context of 10,093 characters with the Agency action present. After Restore to the pre-Agency save, the context returns to 10,000 and the restored-away Agency action is absent.

This directly covers the user-visible risk behind the audit finding: a durable NPC action that physically fits is no longer lost by double accounting.

### AC-02 exact fit — PASS

Focused measurements contain exact-16000 accepted cases for:

- World + Knowledge;
- World + Knowledge + Agency;
- World + Knowledge + Agency + Evolution;
- initial World Changes alone.

The target section is retained and final `context_text.length()` is exactly 16000.

### AC-03 one-over — PASS

Equivalent 16001 candidate cases omit the target whole section and return a final context below/equal to the ceiling. Existing all-or-nothing later-section behavior is preserved.

### AC-04 heading / separator accounting — PASS

The production implementation checks the exact assembled string, and focused tests separately assert the rendered heading/block separators and inter-section `\n\n` framing. No approximate parallel counter remains.

### AC-05 initial section hard ceiling — PASS

A physically 16000-character World Changes section keeps four blocks; a 16001-character candidate drops the oldest whole block under the existing selection policy. Final returned context never exceeds the ceiling.

### AC-06 Knowledge → Agency → Evolution current assembled text — PASS

Each later projector receives the current String, not a body count. Evidence includes a case where Knowledge is omitted for nonfit but Agency then fits exactly; the omitted Knowledge does not consume fictitious budget.

### AC-07 section order — PASS

Order remains:

`Materialized World Changes → Actor Knowledge Provenance → Independent Actor Actions → World Evolution Events`.

No new ranking/reordering policy is introduced.

### AC-08 currentness / stale isolation — PASS

Focused tests retain accepted-hash filtering for all four material families, same-index replacement handling, displaced-future exclusion, reopen and Restore behavior. Existing production filter logic outside accounting remains unchanged.

### AC-09 legitimate quiet/hold — PASS

No-Agency / no-Evolution and empty-world projections remain quiet. Existing World Evolution `hold` behavior remains legal and is covered again by G5-04 regression.

### AC-10 prohibited expansion — PASS

`MAX_PROJECTED_CHARS` remains 16000. No Provider call, semantic retrieval/ranking, summarization, partial line truncation, persistence/schema owner, G7 Context Orchestrator or unrelated refactor was added.

## 5. Validation evidence review

Committed final focused log reports **178 checks / 0 failures**. It contains explicit boundary/currentness/durable-consumer assertions rather than only a summary claim.

The candidate also retains a baseline run of the same test against the old production behavior, where the accounting defect produces failures. This strengthens causality but is not treated as the final success result.

Six directly affected regressions are committed with exit 0 and zero assertion/parse/script errors:

- G5-01 semantic;
- G5-01 timeline/Restore;
- G5-02 Knowledge;
- G5-03 Agency;
- G5-04 World Evolution/hold;
- MW-007 timeline continuity.

G5-03 and G5-04 retain previously known resource-exit diagnostic families; no evidence indicates a new MW-020 regression.

Final Godot import and Windows export evidence is present. No real Provider validation is required for this deterministic accounting defect, consistent with the Task Packet.

## 6. Findings

**No blocking finding.**

### N-01 — unchanged whole-section omission under genuine pressure

When a complete later section truly does not fit, it is still omitted rather than partially compressed/truncated. This is the explicitly frozen existing behavior, not an MW-020 defect. Long-session context quality remains future G7 work.

### N-02 — existing exit resource diagnostics

G5-03/G5-04 retain known ObjectDB/resource exit diagnostics. They are disclosed and not introduced by the one-file accounting correction. Do not expand this task to repair them.

## 7. Verdict

**MW-020 = ENGINEERING PASS_WITH_NOTES.**

The implementation fixes the reproduced accounting defect without changing semantic selection policy or widening scope. It is eligible for non-force fast-forward integration if `main` is still exactly the reviewed Formal Base.

After reviewed integration, proceed directly to fresh Package-0 Owner build preparation. Do not insert additional development work before the already planned focused Owner re-UAT unless a new blocker is discovered during build preparation.