# MW-020 Integration Verification

Date: 2026-09-08  
Work item: **MW-020｜Core Context Budget Accounting Correction**  
Status: **INTEGRATED / ENGINEERING PASS_WITH_NOTES**

## Integration identity

- Pre-integration `main`: `f5dea508be2db5904c2d5ebc726b6f130d8c57fe`
- Implementation HEAD: `b423a5b3c7cdecd1d836920f1b053e3675a3bb0e`
- Submitted candidate: `9677f6987312230facb351964f6d800748618cf2`
- Independent Review: `docs/mw020/MW-020_INDEPENDENT_REVIEW_IR1.md`
- Review commit: `66c28807e5074e1c59373b9139adb64fc2989944`
- Integration method: **non-force fast-forward** of `main` to the reviewed commit

Immediately before integration, remote `main` was re-read and remained exactly the reviewed Formal Base. Compare metadata showed the review commit as a strict descendant with the same merge base. No unreviewed production delta, merge conflict, history rewrite or force update was introduced.

## Integrated result

The integrated correction keeps `MAX_PROJECTED_CHARS = 16000` and changes only context-budget accounting:

- actual assembled context String is the sole budget truth;
- Materialized World Changes heading and block separators count exactly once;
- Knowledge / Agency / Evolution each test the exact proposed joined String;
- omitted sections spend no fictitious separator/body budget;
- exact 16000-character assembled context is allowed;
- a candidate that would make the result 16001 is omitted under existing whole-section policy;
- durable Agency material that physically fits is no longer lost by double-counting earlier world-change bodies;
- accepted-hash / stale-future / Restore currentness behavior is unchanged;
- no total-budget increase, Context Orchestrator, semantic retrieval, Provider call or persistence/schema change.

## Evidence retained

Focused final evidence: **178 checks / 0 failures**.

Directly affected suites: G5-01 semantic, G5-01 timeline, G5-02, G5-03, G5-04, MW-007 — all exit 0 with no assertion/parse/script errors. G5-03/G5-04 retain pre-existing resource-exit diagnostics already classified as non-blocking.

Final Godot import / Windows export validation evidence is committed under `docs/mw020/evidence/`.

## Remaining boundary

MW-020 requires no separate Owner product verdict. Its Engineering gate is closed.

Known retained behavior: genuine context pressure still omits an entire non-fitting later section; that is the frozen current policy and future long-session context quality remains G7 work.

## Next state

Package-0 pre-re-UAT implementation corrections are now all reviewed and integrated:

- MW-018 R1 People known/off-screen eligibility — Engineering PASS_WITH_NOTES / Product re-UAT pending;
- MW-015 R1 sparse Important Experiences — Engineering PASS_WITH_NOTES / Product re-UAT pending;
- MW-019 R1 Recommendation UX — Engineering PASS_WITH_NOTES / Product re-UAT pending;
- MW-020 context budget accounting — Engineering PASS_WITH_NOTES / integrated, no standalone Product gate.

Proceed directly to **Fresh Owner Build Prep** from current reviewed `main`, then focused Owner re-UAT. Do not insert new product development before that build unless build preparation discovers a blocker.