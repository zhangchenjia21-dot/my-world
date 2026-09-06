# MW-018｜Independent Review IR1

Status: **ENGINEERING PASS**  
Reviewer: GPT  
Reviewed candidate: `c8150a2ee9fa79d929cd0bb5f899132d3d2f6563`  
Reviewed code commit: `e9157f79860437207b73e894647be9f1278f5a74`  
Base: `a1af1ed7aaf2d322b3dfb8659907ba1c8927abf3`

## Verdict

MW-018 passes Engineering Review and is eligible for integration. Product PASS is not claimed; Owner UAT remains required after canonical local build handoff.

## What was independently checked

- actual base→candidate diff and changed-file scope;
- backward-compatible old/new `information_curation` record identity and parent-chain behavior;
- model-driven People semantics with no Program name/importance/relationship heuristics;
- exact request-scoped ref → stable local identity resolution before persistence;
- MW-017 receipt dependency/currentness and same-turn barrier consumption;
- latest-known People fold, full-snapshot replacement and tombstone behavior;
- no re-hydration from raw NPC truth / private Knowledge / Agency / Evolution / Source-current;
- dedicated People L3 returns only `display_name/headline/summary/relationship/details`;
- five-tab right navigation and card UI default-collapse/expand behavior;
- accepted-history replacement, Restore and reopen currentness;
- focused, regression, visual and Windows-export evidence;
- bounded real configured Kimi K3 vertical and Owner-data fingerprint preservation.

## Key accepted findings

1. **Model authority preserved.** Model decides whether a bound person deserves a card and what latest-known prose belongs in it. Program only validates shape, resolves exact identity, persists and projects.
2. **Disclosure boundary preserved.** Curator People input contains only accepted quote/span/request refs plus that implicated person's prior player-known snapshot. Leaf UI receives no local IDs, refs, receipts, hashes or raw world/actor material.
3. **Backward compatibility is real.** Legacy MW-014/MW-015 records retain their original `{prefix,parent,id,result}` validation/hash algorithm; the new lived v0.2 variant is separately identified and mixed parent chains remain valid.
4. **Timeline currentness is correct.** Accepted replacement immediately removes/reverts stale People projection before replacement curation; Restore/reopen rebuild from current accepted history only; People does not use the T0 displaced-future recovery exception.
5. **UI product structure matches the frozen scope.** `概览 | 角色 | 重要经历 | 人物 | 存档`; People is a card list; cards rebuild collapsed; relationship/details are hidden until expansion; no search/filter/portrait/MW-013 scope creep.

## Validation evidence accepted

- focused final: **135 checks / 0 failures**;
- rendered visual run: **127 checks / 0 failures**, including maximized, 1280×720 and 960×540;
- MW-017 + G5 + MW-014/MW-015 regressions pass;
- Windows Desktop export passes;
- `git diff --check` clean;
- known G5-03/G5-04/G4-07B exit resource warnings match the pre-existing reviewed baseline and are not introduced by MW-018.

## Real Provider risk retained for Owner UAT

The bounded Kimi K3 vertical produced one valid current People card for `李亭` through exactly one World semantic request + one existing Information Curator request. In the same run, the model referenced `cand-shenqing` in `people_bindings` but omitted `candidate_ref` from the new `沈青` candidate, so MW-017 correctly left that identity unresolved and MW-018 produced no 沈青 card.

This is **not** an Engineering blocker because:

- the contract is structurally correct and fail-safe;
- the task explicitly requires unresolved/malformed model output to be recorded honestly rather than repaired with name matching;
- same-turn runtime-created actor card creation is proven through the production seams with deterministic adapters;
- at least one real configured Provider card vertical succeeded.

It remains a **Product/UAT reliability risk**: Owner should intentionally interact with a newly introduced person and observe whether a card appears reliably. Do not add Program name heuristics to mask failures.

## Gate

```text
MW-018 Engineering PASS
→ integrate reviewed candidate/review record to main
→ integration verification
→ canonical Owner checkout sync + fresh export
→ Owner UAT
```

Only Owner may declare MW-018 Product PASS.