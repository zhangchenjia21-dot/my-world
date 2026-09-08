# MW-015 R1 Independent Review — IR1

Date: 2026-09-08  
Work item: MW-015 / Revision 1  
Verdict: **ENGINEERING PASS_WITH_NOTES**  
Product verdict: **NOT GRANTED — focused Owner re-UAT still required**

## 1. Review identity

- Formal code base: `2680b2616db69987a451c9d1bf53b24339a9c7cb`
- Exact task starting HEAD: `d7e0826c655d0d74e28de1ae67b74f8e08753502`
- Implementation HEAD: `aca189b35f5539a190e17a32590c5ca867459df3`
- Submitted final candidate: `a9cb2ba7c253e8a9c2d07cbf058a6b8d55d16338`
- Governance refreshed during review: `621beb52efae65680a40f49caa929087c6049d2b`
- Current audit adoption does not supersede MW-015 R1; it explicitly keeps it uninterrupted and queues context-budget correction later.

This review does not accept the Builder completion claim as proof. It independently inspected the formal-base diff, production change, test semantics, committed evidence and current governance.

## 2. Scope / diff review

Formal base → implementation contains one production change only:

`src/信息整理/L2_流程层/回合信息整理流程.gd`

The production delta is confined to the lived Information Curator system instructions. No production parser, contract, persistence, Timeline/currentness, UI, navigation, Provider transport, SQLite schema, People identity bridge or Character projection code changed.

The remaining implementation-side files are task packet and focused/real-provider test perimeter files.

No scope expansion into `简要回顾`, IA, Debug Mode, MW-019, OOC or Dynamic UI was found.

## 3. Semantic correction review

The prompt now makes four intended distinctions explicit:

1. `Important Experiences` is selected life history, not a rolling turn recap.
2. Most ordinary accepted turns should legitimately return `experiences=[]`.
3. The model, not Program heuristics, judges whether an event materially belongs in the protagonist's long-term life trajectory.
4. Character mutation and milestone mutation remain independent.

The implementation also explicitly preserves semantic freedom: quiet events may matter, intense events may not; no event-type list, keyword classifier, score, turn interval or elapsed-time rule was introduced.

This is consistent with the frozen Model Freedom / Information Curation authority and the sparse-milestone correction decision.

## 4. MW-018 R1 protection

No MW-018 R1 production identity/evidence code changed.

The current People instruction block remains intact, including Player/GM source-role evidence semantics. Existing MW-018 R1 focused regression is included in the submitted evidence and reports 81 checks / 0 failures.

No evidence was found of a regression back to GM-only People evidence, display-name authority or a new People Provider call.

## 5. Deterministic acceptance review

The new focused vertical is useful because it does not encode event meaning in Program logic. It demonstrates that:

- an ordinary accepted turn can commit `experiences=[]` successfully;
- the same production prompt can accept a model-selected milestone without Program significance filtering;
- Character can change with zero new milestone;
- a milestone can be stored with Character unchanged;
- successful no-op is durable/idempotent;
- Restore / Regenerate / reopen currentness remain compatible.

This proves structural freedom and currentness, not model semantic quality by itself.

## 6. Real Provider evidence review

Committed real-provider evidence uses configured Kimi K3 (`k3-256k`) for exactly two real Information Curator calls in isolated fixture state.

Case A — routine:

- player thanks a shopkeeper, returns to the academy and straightens manuscript pages;
- model returns `character=null`, `experiences=[]`, `people_updates=[]`.

Case B — life-turning:

- protagonist formally abandons the family-arranged official career and assumes long-term medical service;
- model returns a current Character update and exactly one milestone.

The two cases use the same production system prompt. Test labels/expected counts are assertion-only and are not inserted into the model request. Evidence records that raw model `experiences` equal the durably stored result; no Program importance filter, hidden retry, prompt switch or Provider fallback appears in the path.

This is credible bounded evidence for the intended semantic contrast.

## 7. Validation evidence review

Submitted machine evidence records:

- focused: 37 checks / 0 failures;
- 9 affected regression suites, all exit 0;
- real Provider: 2 calls, experience counts `[0,1]`, raw experience output preserved;
- final import: no script/parse errors;
- Windows export: exit 0, `export_errors=0`;
- Owner data fingerprints unchanged.

The implementation report correctly does not elevate these results to Product PASS.

## 8. Findings

### Blocking findings

None.

### Notes / retained risks

N-01 — Two intentionally clear model cases do not establish long-session sparsity. Owner re-UAT must verify ordinary play no longer accumulates a recap-like milestone every turn.

N-02 — Re-UAT must also verify the correction has not become semantically over-restrictive: a quiet or superficially ordinary event that genuinely reshapes the protagonist should still be recordable when the model judges it important.

N-03 — Existing over-generated historical entries remain in old saves by design. This revision governs new curation only.

N-04 — Current structured-output reliability behavior is unchanged; malformed model output remains a separate seam.

## 9. Verdict

**ENGINEERING PASS_WITH_NOTES**

The revision is bounded, matches the frozen product correction, keeps semantic authority with the model, preserves MW-018 R1 and currentness, and has credible deterministic + bounded real-Provider evidence.

It is eligible for integration into `main`.

No Product PASS is granted. Final MW-015 product acceptance remains part of the focused Owner re-UAT after MW-019 R1 and the queued context-budget correctness correction are integrated.
